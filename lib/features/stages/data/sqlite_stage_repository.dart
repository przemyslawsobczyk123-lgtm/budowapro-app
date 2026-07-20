import 'dart:math';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/features/stages/domain/stage_template.dart';
import 'package:sqflite/sqflite.dart';

typedef StageIdGenerator = String Function();
typedef StageUtcNow = DateTime Function();

final class SqliteStageRepository implements StageRepository {
  factory SqliteStageRepository({
    required AppDatabase database,
    StageIdGenerator? idGenerator,
    StageUtcNow? utcNow,
  }) {
    return SqliteStageRepository._(
      database,
      idGenerator ?? _secureStageId,
      utcNow ?? DateTime.now,
    );
  }

  const SqliteStageRepository._(
    this._database,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final StageIdGenerator _idGenerator;
  final StageUtcNow _utcNow;

  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) {
    return _database.transaction<List<ProjectStage>>((transaction) async {
      await _ensureSeeded(transaction, projectId, template);
      return _listStages(transaction, projectId);
    });
  }

  @override
  Future<List<ChecklistItem>> listChecklistItems({
    required String projectId,
    required String stageId,
  }) async {
    final database = await _database.open();
    return _listChecklistItems(database, projectId, stageId: stageId);
  }

  @override
  Future<ProjectStage> addCustomStage({
    required String projectId,
    required String name,
  }) {
    final normalizedName = _requiredText(name, 'name', maximumLength: 80);
    return _database.transaction<ProjectStage>((transaction) async {
      await _requireProject(transaction, projectId);
      final orderRows = await transaction.rawQuery(
        'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order '
        'FROM ${AppDatabase.projectStagesTable} WHERE project_id = ?',
        <Object?>[projectId],
      );
      final now = _utcNow().toUtc();
      final id = _idGenerator();
      await transaction
          .insert(AppDatabase.projectStagesTable, <String, Object?>{
            'project_id': projectId,
            'id': id,
            'template_stage_key': null,
            'custom_name': normalizedName,
            'status': _stageStatusToStorage(StageStatus.planned),
            'sort_order': orderRows.single['next_order']! as int,
            'planned_start_utc_ms': null,
            'planned_end_utc_ms': null,
            'planned_budget_minor_units': null,
            'created_at_utc_ms': _dateToStorage(now),
            'updated_at_utc_ms': _dateToStorage(now),
          }, conflictAlgorithm: ConflictAlgorithm.abort);
      return (await _findStage(transaction, projectId, id))!;
    });
  }

  @override
  Future<ProjectStage> renameStage({
    required String projectId,
    required String stageId,
    required String name,
  }) {
    final normalizedName = _requiredText(name, 'name', maximumLength: 80);
    return _database.transaction<ProjectStage>((transaction) async {
      final changed = await transaction.update(
        AppDatabase.projectStagesTable,
        <String, Object?>{
          'template_stage_key': null,
          'custom_name': normalizedName,
          'updated_at_utc_ms': _dateToStorage(_utcNow()),
        },
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, stageId],
      );
      if (changed != 1) {
        throw const StageNotFoundException();
      }
      return (await _findStage(transaction, projectId, stageId))!;
    });
  }

  @override
  Future<void> reorderStages({
    required String projectId,
    required List<String> stageIds,
  }) {
    return _database.transaction<void>((transaction) async {
      final rows = await transaction.query(
        AppDatabase.projectStagesTable,
        columns: const <String>['id'],
        where: 'project_id = ?',
        whereArgs: <Object?>[projectId],
      );
      final existingIds = rows.map((row) => row['id']! as String).toSet();
      final requestedIds = stageIds.map((id) => id.trim()).toList();
      if (requestedIds.length != existingIds.length ||
          requestedIds.toSet().length != requestedIds.length ||
          requestedIds.toSet().difference(existingIds).isNotEmpty) {
        throw const StageOrderMismatchException();
      }
      final now = _dateToStorage(_utcNow());
      for (var index = 0; index < requestedIds.length; index++) {
        await transaction.update(
          AppDatabase.projectStagesTable,
          <String, Object?>{'sort_order': index, 'updated_at_utc_ms': now},
          where: 'project_id = ? AND id = ?',
          whereArgs: <Object?>[projectId, requestedIds[index]],
        );
      }
    });
  }

  @override
  Future<ProjectStage> updateStage({
    required String projectId,
    required String stageId,
    required StageDetailsInput input,
  }) {
    return _database.transaction<ProjectStage>((transaction) async {
      final changed = await transaction.update(
        AppDatabase.projectStagesTable,
        <String, Object?>{
          'status': _stageStatusToStorage(input.status),
          'planned_start_utc_ms': _nullableDateToStorage(input.plannedStart),
          'planned_end_utc_ms': _nullableDateToStorage(input.plannedEnd),
          'planned_budget_minor_units': input.plannedBudgetMinorUnits,
          'updated_at_utc_ms': _dateToStorage(_utcNow()),
        },
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, stageId],
      );
      if (changed != 1) {
        throw const StageNotFoundException();
      }
      return (await _findStage(transaction, projectId, stageId))!;
    });
  }

  @override
  Future<ChecklistItem> addChecklistItem({
    required String projectId,
    required String stageId,
    required String title,
    required ChecklistItemDetailsInput input,
  }) {
    final normalizedTitle = _requiredText(title, 'title', maximumLength: 160);
    validateChecklistResolution(
      status: input.status,
      evidenceRequirement: input.evidenceRequirement,
      evidenceCount: 0,
      statusReason: input.statusReason,
      evidenceWaiverComment: input.evidenceWaiverComment,
    );
    return _database.transaction<ChecklistItem>((transaction) async {
      if (await _findStage(transaction, projectId, stageId) == null) {
        throw const StageNotFoundException();
      }
      final orderRows = await transaction.rawQuery(
        'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order '
        'FROM ${AppDatabase.checklistItemsTable} '
        'WHERE project_id = ? AND stage_id = ?',
        <Object?>[projectId, stageId],
      );
      final now = _utcNow().toUtc();
      final id = _idGenerator();
      await transaction.insert(
        AppDatabase.checklistItemsTable,
        _checklistInputToRow(
          projectId: projectId,
          id: id,
          stageId: stageId,
          customTitle: normalizedTitle,
          input: input,
          sortOrder: orderRows.single['next_order']! as int,
          createdAt: now,
          updatedAt: now,
        ),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return (await _findChecklistItem(transaction, projectId, id))!;
    });
  }

  @override
  Future<ChecklistItem> updateChecklistItem({
    required String projectId,
    required String checklistItemId,
    required ChecklistItemDetailsInput input,
  }) {
    return _database.transaction<ChecklistItem>((transaction) async {
      final existing = await _findChecklistItem(
        transaction,
        projectId,
        checklistItemId,
      );
      if (existing == null) {
        throw const ChecklistItemNotFoundException();
      }
      final evidenceRequirement = existing.templateKey == null
          ? input.evidenceRequirement
          : existing.evidenceRequirement;
      validateChecklistResolution(
        status: input.status,
        evidenceRequirement: evidenceRequirement,
        evidenceCount: existing.evidenceIds.length,
        statusReason: input.statusReason,
        evidenceWaiverComment: input.evidenceWaiverComment,
      );
      await transaction.update(
        AppDatabase.checklistItemsTable,
        <String, Object?>{
          'status': _checklistStatusToStorage(input.status),
          'importance': _importanceToStorage(input.importance),
          'due_at_utc_ms': _nullableDateToStorage(input.dueDate),
          'assignee_label': input.assignee,
          'note': input.note,
          'risk_if_skipped': input.riskIfSkipped,
          'status_reason': input.statusReason,
          'evidence_requirement': _evidenceToStorage(evidenceRequirement),
          'evidence_waiver_comment': input.evidenceWaiverComment,
          'updated_at_utc_ms': _dateToStorage(_utcNow()),
        },
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, checklistItemId],
      );
      return (await _findChecklistItem(
        transaction,
        projectId,
        checklistItemId,
      ))!;
    });
  }

  @override
  Future<ChecklistItem> attachEvidence({
    required String projectId,
    required String checklistItemId,
    required String attachmentId,
  }) {
    return _database.transaction<ChecklistItem>((transaction) async {
      final item = await _findChecklistItem(
        transaction,
        projectId,
        checklistItemId,
      );
      if (item == null) {
        throw const ChecklistItemNotFoundException();
      }
      final attachments = await transaction.query(
        AppDatabase.costAttachmentsTable,
        columns: const <String>['id', 'media_type'],
        where: 'project_id = ? AND id = ? AND availability = ?',
        whereArgs: <Object?>[projectId, attachmentId, 'available'],
        limit: 1,
      );
      if (attachments.isEmpty) {
        throw const ChecklistEvidenceNotFoundException();
      }
      final mediaType = attachments.single['media_type'] as String?;
      if (item.evidenceRequirement == EvidenceRequirement.photo &&
          (mediaType == null || !mediaType.startsWith('image/'))) {
        throw const ChecklistEvidenceNotFoundException();
      }
      final orderRows = await transaction.rawQuery(
        'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order '
        'FROM ${AppDatabase.checklistItemAttachmentsTable} '
        'WHERE project_id = ? AND checklist_item_id = ?',
        <Object?>[projectId, checklistItemId],
      );
      await transaction.insert(
        AppDatabase.checklistItemAttachmentsTable,
        <String, Object?>{
          'project_id': projectId,
          'checklist_item_id': checklistItemId,
          'attachment_id': attachmentId,
          'sort_order': orderRows.single['next_order']! as int,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return (await _findChecklistItem(
        transaction,
        projectId,
        checklistItemId,
      ))!;
    });
  }

  @override
  Future<ChecklistItem> detachEvidence({
    required String projectId,
    required String checklistItemId,
    required String attachmentId,
  }) {
    return _database.transaction<ChecklistItem>((transaction) async {
      final item = await _findChecklistItem(
        transaction,
        projectId,
        checklistItemId,
      );
      if (item == null) {
        throw const ChecklistItemNotFoundException();
      }
      final remainingCount = item.evidenceIds.contains(attachmentId)
          ? item.evidenceIds.length - 1
          : item.evidenceIds.length;
      validateChecklistResolution(
        status: item.status,
        evidenceRequirement: item.evidenceRequirement,
        evidenceCount: remainingCount,
        statusReason: item.statusReason,
        evidenceWaiverComment: item.evidenceWaiverComment,
      );
      await transaction.delete(
        AppDatabase.checklistItemAttachmentsTable,
        where: 'project_id = ? AND checklist_item_id = ? AND attachment_id = ?',
        whereArgs: <Object?>[projectId, checklistItemId, attachmentId],
      );
      return (await _findChecklistItem(
        transaction,
        projectId,
        checklistItemId,
      ))!;
    });
  }

  Future<void> _ensureSeeded(
    DatabaseExecutor transaction,
    String projectId,
    ProjectTemplate template,
  ) async {
    await _requireProject(transaction, projectId);
    final existingRows = await transaction.query(
      AppDatabase.projectStagesTable,
      columns: const <String>['id'],
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
    );
    final existingIds = existingRows.map((row) => row['id']! as String).toSet();
    final now = _utcNow().toUtc();
    final definitions = StageTemplateCatalog.forProject(template);
    for (var stageIndex = 0; stageIndex < definitions.length; stageIndex++) {
      final definition = definitions[stageIndex];
      final stageId = _stageKeyToStorage(definition.stageKey);
      if (!existingIds.contains(stageId)) {
        await transaction.insert(
          AppDatabase.projectStagesTable,
          <String, Object?>{
            'project_id': projectId,
            'id': stageId,
            'template_stage_key': stageId,
            'custom_name': null,
            'status': _stageStatusToStorage(StageStatus.planned),
            'sort_order': stageIndex,
            'planned_start_utc_ms': null,
            'planned_end_utc_ms': null,
            'planned_budget_minor_units': null,
            'created_at_utc_ms': _dateToStorage(now),
            'updated_at_utc_ms': _dateToStorage(now),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      for (
        var itemIndex = 0;
        itemIndex < definition.checklistItems.length;
        itemIndex++
      ) {
        final item = definition.checklistItems[itemIndex];
        final itemStorageKey = _checklistKeyToStorage(item.key);
        await transaction.insert(
          AppDatabase.checklistItemsTable,
          <String, Object?>{
            'project_id': projectId,
            'id': '${stageId}_$itemStorageKey',
            'stage_id': stageId,
            'template_item_key': itemStorageKey,
            'custom_title': null,
            'status': _checklistStatusToStorage(ChecklistStatus.todo),
            'importance': _importanceToStorage(item.importance),
            'due_at_utc_ms': null,
            'assignee_label': null,
            'note': null,
            'risk_if_skipped': null,
            'status_reason': null,
            'evidence_requirement': _evidenceToStorage(
              item.evidenceRequirement,
            ),
            'evidence_waiver_comment': null,
            'sort_order': itemIndex,
            'created_at_utc_ms': _dateToStorage(now),
            'updated_at_utc_ms': _dateToStorage(now),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

  Future<List<ProjectStage>> _listStages(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    final rows = await executor.rawQuery(
      '''
        SELECT s.*,
          COUNT(c.id) AS checklist_total,
          COALESCE(SUM(CASE WHEN c.status = 'completed' THEN 1 ELSE 0 END), 0)
            AS checklist_completed,
          COALESCE(SUM(CASE WHEN c.status = 'skipped' THEN 1 ELSE 0 END), 0)
            AS checklist_skipped,
          COALESCE(SUM(CASE WHEN c.status = 'blocked' THEN 1 ELSE 0 END), 0)
            AS checklist_blocked
        FROM ${AppDatabase.projectStagesTable} s
        LEFT JOIN ${AppDatabase.checklistItemsTable} c
          ON c.project_id = s.project_id AND c.stage_id = s.id
        WHERE s.project_id = ?
        GROUP BY s.project_id, s.id
        ORDER BY s.sort_order ASC, s.id ASC
      ''',
      <Object?>[projectId],
    );
    return rows.map(_stageFromRow).toList(growable: false);
  }

  Future<ProjectStage?> _findStage(
    DatabaseExecutor executor,
    String projectId,
    String stageId,
  ) async {
    final stages = await _listStages(executor, projectId);
    for (final stage in stages) {
      if (stage.id == stageId) {
        return stage;
      }
    }
    return null;
  }

  Future<List<ChecklistItem>> _listChecklistItems(
    DatabaseExecutor executor,
    String projectId, {
    String? stageId,
    String? checklistItemId,
  }) async {
    final clauses = <String>['project_id = ?'];
    final arguments = <Object?>[projectId];
    if (stageId != null) {
      clauses.add('stage_id = ?');
      arguments.add(stageId);
    }
    if (checklistItemId != null) {
      clauses.add('id = ?');
      arguments.add(checklistItemId);
    }
    final rows = await executor.query(
      AppDatabase.checklistItemsTable,
      where: clauses.join(' AND '),
      whereArgs: arguments,
      orderBy: 'sort_order ASC, id ASC',
    );
    if (rows.isEmpty) {
      return const <ChecklistItem>[];
    }
    final itemIds = rows.map((row) => row['id']! as String).toList();
    final placeholders = List.filled(itemIds.length, '?').join(', ');
    final evidenceRows = await executor.rawQuery(
      '''
        SELECT checklist_item_id, attachment_id
        FROM ${AppDatabase.checklistItemAttachmentsTable}
        WHERE project_id = ? AND checklist_item_id IN ($placeholders)
        ORDER BY checklist_item_id ASC, sort_order ASC
      ''',
      <Object?>[projectId, ...itemIds],
    );
    final evidenceByItem = <String, List<String>>{};
    for (final row in evidenceRows) {
      evidenceByItem
          .putIfAbsent(row['checklist_item_id']! as String, () => <String>[])
          .add(row['attachment_id']! as String);
    }
    return rows
        .map(
          (row) => _checklistItemFromRow(
            row,
            evidenceByItem[row['id']] ?? const <String>[],
          ),
        )
        .toList(growable: false);
  }

  Future<ChecklistItem?> _findChecklistItem(
    DatabaseExecutor executor,
    String projectId,
    String checklistItemId,
  ) async {
    final items = await _listChecklistItems(
      executor,
      projectId,
      checklistItemId: checklistItemId,
    );
    return items.isEmpty ? null : items.single;
  }

  static Future<void> _requireProject(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    final rows = await executor.query(
      AppDatabase.projectsTable,
      columns: const <String>['id'],
      where: 'id = ? AND deletion_pending = ?',
      whereArgs: <Object?>[projectId, 0],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const StageNotFoundException();
    }
  }
}

Map<String, Object?> _checklistInputToRow({
  required String projectId,
  required String id,
  required String stageId,
  required String customTitle,
  required ChecklistItemDetailsInput input,
  required int sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  return <String, Object?>{
    'project_id': projectId,
    'id': id,
    'stage_id': stageId,
    'template_item_key': null,
    'custom_title': customTitle,
    'status': _checklistStatusToStorage(input.status),
    'importance': _importanceToStorage(input.importance),
    'due_at_utc_ms': _nullableDateToStorage(input.dueDate),
    'assignee_label': input.assignee,
    'note': input.note,
    'risk_if_skipped': input.riskIfSkipped,
    'status_reason': input.statusReason,
    'evidence_requirement': _evidenceToStorage(input.evidenceRequirement),
    'evidence_waiver_comment': input.evidenceWaiverComment,
    'sort_order': sortOrder,
    'created_at_utc_ms': _dateToStorage(createdAt),
    'updated_at_utc_ms': _dateToStorage(updatedAt),
  };
}

ProjectStage _stageFromRow(Map<String, Object?> row) {
  final total = row['checklist_total']! as int;
  final completed = row['checklist_completed']! as int;
  final skipped = row['checklist_skipped']! as int;
  final blocked = row['checklist_blocked']! as int;
  return ProjectStage(
    id: row['id']! as String,
    projectId: row['project_id']! as String,
    templateKey: switch (row['template_stage_key']) {
      final String value => _stageKeyFromStorage(value),
      _ => null,
    },
    customName: row['custom_name'] as String?,
    status: _stageStatusFromStorage(row['status']! as String),
    sortOrder: row['sort_order']! as int,
    plannedStart: _nullableDateFromStorage(row['planned_start_utc_ms']),
    plannedEnd: _nullableDateFromStorage(row['planned_end_utc_ms']),
    plannedBudgetMinorUnits: row['planned_budget_minor_units'] as int?,
    progress: StageProgress.fromCounts(
      totalItems: total,
      completedItems: completed,
      skippedItems: skipped,
      blockedItems: blocked,
    ),
    createdAt: _dateFromStorage(row['created_at_utc_ms']! as int),
    updatedAt: _dateFromStorage(row['updated_at_utc_ms']! as int),
  );
}

ChecklistItem _checklistItemFromRow(
  Map<String, Object?> row,
  List<String> evidenceIds,
) {
  return ChecklistItem(
    id: row['id']! as String,
    projectId: row['project_id']! as String,
    stageId: row['stage_id']! as String,
    templateKey: switch (row['template_item_key']) {
      final String value => _checklistKeyFromStorage(value),
      _ => null,
    },
    customTitle: row['custom_title'] as String?,
    status: _checklistStatusFromStorage(row['status']! as String),
    importance: _importanceFromStorage(row['importance']! as String),
    dueDate: _nullableDateFromStorage(row['due_at_utc_ms']),
    assignee: row['assignee_label'] as String?,
    note: row['note'] as String?,
    riskIfSkipped: row['risk_if_skipped'] as String?,
    statusReason: row['status_reason'] as String?,
    evidenceRequirement: _evidenceFromStorage(
      row['evidence_requirement']! as String,
    ),
    evidenceWaiverComment: row['evidence_waiver_comment'] as String?,
    evidenceIds: evidenceIds,
    sortOrder: row['sort_order']! as int,
    createdAt: _dateFromStorage(row['created_at_utc_ms']! as int),
    updatedAt: _dateFromStorage(row['updated_at_utc_ms']! as int),
  );
}

String _stageKeyToStorage(ProjectStageKey value) => switch (value) {
  ProjectStageKey.planning => 'planning',
  ProjectStageKey.formalities => 'formalities',
  ProjectStageKey.stateZero => 'state_zero',
  ProjectStageKey.shellOpen => 'shell_open',
  ProjectStageKey.shellClosed => 'shell_closed',
  ProjectStageKey.demolition => 'demolition',
  ProjectStageKey.installations => 'installations',
  ProjectStageKey.plaster => 'plaster',
  ProjectStageKey.finishing => 'finishing',
  ProjectStageKey.handover => 'handover',
};

ProjectStageKey _stageKeyFromStorage(String value) => switch (value) {
  'planning' => ProjectStageKey.planning,
  'formalities' => ProjectStageKey.formalities,
  'state_zero' => ProjectStageKey.stateZero,
  'shell_open' => ProjectStageKey.shellOpen,
  'shell_closed' => ProjectStageKey.shellClosed,
  'demolition' => ProjectStageKey.demolition,
  'installations' => ProjectStageKey.installations,
  'plaster' => ProjectStageKey.plaster,
  'finishing' => ProjectStageKey.finishing,
  'handover' => ProjectStageKey.handover,
  _ => throw StateError('Unknown stage key'),
};

String _checklistKeyToStorage(ChecklistTemplateKey value) => switch (value) {
  ChecklistTemplateKey.soilResearch => 'soil_research',
  ChecklistTemplateKey.surveyorBuildingSetout => 'surveyor_building_setout',
  ChecklistTemplateKey.siteRoadPowerWater => 'site_road_power_water',
  ChecklistTemplateKey.excavationFoundationLevels =>
    'excavation_foundation_levels',
  ChecklistTemplateKey.underSlabSewerAndRisers => 'under_slab_sewer_and_risers',
  ChecklistTemplateKey.waterPenetration => 'water_penetration',
  ChecklistTemplateKey.powerPenetration => 'power_penetration',
  ChecklistTemplateKey.telecomPenetration => 'telecom_penetration',
  ChecklistTemplateKey.gasPenetration => 'gas_penetration',
  ChecklistTemplateKey.gateIntercomGardenReserve =>
    'gate_intercom_garden_reserve',
  ChecklistTemplateKey.heatPumpOutdoorReserve => 'heat_pump_outdoor_reserve',
  ChecklistTemplateKey.foundationGrounding => 'foundation_grounding',
  ChecklistTemplateKey.continuityMeasurement => 'continuity_measurement',
  ChecklistTemplateKey.horizontalVerticalWaterproofing =>
    'horizontal_vertical_waterproofing',
  ChecklistTemplateKey.drainage => 'drainage',
  ChecklistTemplateKey.concealedWorksPhotos => 'concealed_works_photos',
  ChecklistTemplateKey.concreteDeliveryAndAcceptance =>
    'concrete_delivery_and_acceptance',
  ChecklistTemplateKey.postFoundationSurvey => 'post_foundation_survey',
};

ChecklistTemplateKey _checklistKeyFromStorage(String value) => switch (value) {
  'soil_research' => ChecklistTemplateKey.soilResearch,
  'surveyor_building_setout' => ChecklistTemplateKey.surveyorBuildingSetout,
  'site_road_power_water' => ChecklistTemplateKey.siteRoadPowerWater,
  'excavation_foundation_levels' =>
    ChecklistTemplateKey.excavationFoundationLevels,
  'under_slab_sewer_and_risers' => ChecklistTemplateKey.underSlabSewerAndRisers,
  'water_penetration' => ChecklistTemplateKey.waterPenetration,
  'power_penetration' => ChecklistTemplateKey.powerPenetration,
  'telecom_penetration' => ChecklistTemplateKey.telecomPenetration,
  'gas_penetration' => ChecklistTemplateKey.gasPenetration,
  'gate_intercom_garden_reserve' =>
    ChecklistTemplateKey.gateIntercomGardenReserve,
  'heat_pump_outdoor_reserve' => ChecklistTemplateKey.heatPumpOutdoorReserve,
  'foundation_grounding' => ChecklistTemplateKey.foundationGrounding,
  'continuity_measurement' => ChecklistTemplateKey.continuityMeasurement,
  'horizontal_vertical_waterproofing' =>
    ChecklistTemplateKey.horizontalVerticalWaterproofing,
  'drainage' => ChecklistTemplateKey.drainage,
  'concealed_works_photos' => ChecklistTemplateKey.concealedWorksPhotos,
  'concrete_delivery_and_acceptance' =>
    ChecklistTemplateKey.concreteDeliveryAndAcceptance,
  'post_foundation_survey' => ChecklistTemplateKey.postFoundationSurvey,
  _ => throw StateError('Unknown checklist key'),
};

String _stageStatusToStorage(StageStatus value) => switch (value) {
  StageStatus.planned => 'planned',
  StageStatus.inProgress => 'in_progress',
  StageStatus.blocked => 'blocked',
  StageStatus.completed => 'completed',
};

StageStatus _stageStatusFromStorage(String value) => switch (value) {
  'planned' => StageStatus.planned,
  'in_progress' => StageStatus.inProgress,
  'blocked' => StageStatus.blocked,
  'completed' => StageStatus.completed,
  _ => throw StateError('Unknown stage status'),
};

String _checklistStatusToStorage(ChecklistStatus value) => switch (value) {
  ChecklistStatus.todo => 'todo',
  ChecklistStatus.inProgress => 'in_progress',
  ChecklistStatus.blocked => 'blocked',
  ChecklistStatus.completed => 'completed',
  ChecklistStatus.skipped => 'skipped',
};

ChecklistStatus _checklistStatusFromStorage(String value) => switch (value) {
  'todo' => ChecklistStatus.todo,
  'in_progress' => ChecklistStatus.inProgress,
  'blocked' => ChecklistStatus.blocked,
  'completed' => ChecklistStatus.completed,
  'skipped' => ChecklistStatus.skipped,
  _ => throw StateError('Unknown checklist status'),
};

String _importanceToStorage(ChecklistImportance value) => switch (value) {
  ChecklistImportance.low => 'low',
  ChecklistImportance.normal => 'normal',
  ChecklistImportance.high => 'high',
  ChecklistImportance.critical => 'critical',
};

ChecklistImportance _importanceFromStorage(String value) => switch (value) {
  'low' => ChecklistImportance.low,
  'normal' => ChecklistImportance.normal,
  'high' => ChecklistImportance.high,
  'critical' => ChecklistImportance.critical,
  _ => throw StateError('Unknown checklist importance'),
};

String _evidenceToStorage(EvidenceRequirement value) => switch (value) {
  EvidenceRequirement.none => 'none',
  EvidenceRequirement.anyAttachment => 'any_attachment',
  EvidenceRequirement.photo => 'photo',
};

EvidenceRequirement _evidenceFromStorage(String value) => switch (value) {
  'none' => EvidenceRequirement.none,
  'any_attachment' => EvidenceRequirement.anyAttachment,
  'photo' => EvidenceRequirement.photo,
  _ => throw StateError('Unknown evidence requirement'),
};

int _dateToStorage(DateTime value) {
  return DatabaseValueCodec.dateTimeToUtcMilliseconds(value);
}

int? _nullableDateToStorage(DateTime? value) {
  return value == null ? null : _dateToStorage(value);
}

DateTime _dateFromStorage(int value) {
  return DatabaseValueCodec.utcMillisecondsToDateTime(value);
}

DateTime? _nullableDateFromStorage(Object? value) {
  return value == null ? null : _dateFromStorage(value as int);
}

String _requiredText(
  String value,
  String argumentName, {
  required int maximumLength,
}) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, argumentName);
  }
  return normalized;
}

String _secureStageId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
