import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/captures/domain/capture_repository.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/schedule/data/sqlite_schedule_repository.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteCaptureRepository implements CaptureRepository {
  factory SqliteCaptureRepository({
    required AppDatabase database,
    required SqliteCostRepository costRepository,
    required SqliteDocumentRepository documentRepository,
    required SqliteScheduleRepository scheduleRepository,
    required String Function() idGenerator,
    required DateTime Function() utcNow,
  }) {
    return SqliteCaptureRepository._(
      database,
      costRepository,
      documentRepository,
      scheduleRepository,
      idGenerator,
      utcNow,
    );
  }

  const SqliteCaptureRepository._(
    this._database,
    this._costRepository,
    this._documentRepository,
    this._scheduleRepository,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final SqliteCostRepository _costRepository;
  final SqliteDocumentRepository _documentRepository;
  final SqliteScheduleRepository _scheduleRepository;
  final String Function() _idGenerator;
  final DateTime Function() _utcNow;

  @override
  Future<CaptureDraft> create(CaptureDraftInput input) {
    return _database.transaction<CaptureDraft>((transaction) async {
      await _requireAvailableAttachments(transaction, input);
      final now = _utcNow().toUtc();
      final draft = CaptureDraft(
        id: _idGenerator(),
        input: input,
        status: input.status,
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        AppDatabase.captureDraftsTable,
        _draftToRow(draft),
      );
      await _replaceAttachmentLinks(transaction, draft);
      return draft;
    });
  }

  @override
  Future<CaptureDraft> update({
    required String projectId,
    required String captureId,
    required CaptureDraftInput input,
  }) {
    return _database.transaction<CaptureDraft>((transaction) async {
      final existing = await _requireOpenDraft(
        transaction,
        projectId: projectId,
        captureId: captureId,
      );
      if (input.projectId != existing.projectId) {
        throw ArgumentError.value(input.projectId, 'input.projectId');
      }
      await _requireAvailableAttachments(transaction, input);
      final updated = CaptureDraft(
        id: existing.id,
        input: input,
        status: input.status,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
      );
      await _updateDraft(transaction, updated);
      await _replaceAttachmentLinks(transaction, updated);
      return updated;
    });
  }

  @override
  Future<CaptureDraft?> findById({
    required String projectId,
    required String captureId,
  }) async {
    return _findById(
      await _database.open(),
      projectId: projectId,
      captureId: captureId,
    );
  }

  @override
  Future<Page<CaptureDraft>> list(
    CaptureDraftQuery query,
    PageRequest page,
  ) async {
    final database = await _database.open();
    final filter = _queryFilter(query);
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM ${AppDatabase.captureDraftsTable} '
      'WHERE ${filter.sql}',
      filter.arguments,
    );
    final rows = await database.query(
      AppDatabase.captureDraftsTable,
      where: filter.sql,
      whereArgs: filter.arguments,
      orderBy: 'created_at_utc_ms DESC, id DESC',
      limit: page.limit,
      offset: page.offset,
    );
    return Page<CaptureDraft>(
      items: await _draftsFromRows(database, rows),
      totalCount: countRows.single['count']! as int,
      request: page,
    );
  }

  @override
  Future<int> countOpen({required String projectId}) async {
    final normalizedProjectId = CaptureDraftQuery(
      projectId: projectId,
    ).projectId;
    final database = await _database.open();
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM ${AppDatabase.captureDraftsTable} '
      "WHERE project_id = ? AND status != 'classified'",
      <Object?>[normalizedProjectId],
    );
    return rows.single['count']! as int;
  }

  @override
  Future<CaptureDraft> classify({
    required String projectId,
    required String captureId,
    required String currencyCode,
  }) {
    return _database.transaction<CaptureDraft>((transaction) async {
      final existing = await _requireOpenDraft(
        transaction,
        projectId: projectId,
        captureId: captureId,
      );
      if (!existing.canClassify) {
        throw const CaptureDraftNotReadyException();
      }

      final targetId = switch (existing.type) {
        CaptureDraftType.photo ||
        CaptureDraftType.document ||
        CaptureDraftType.voice => _classifyAttachments(transaction, existing),
        CaptureDraftType.cost => _classifyCost(
          transaction,
          existing,
          currencyCode,
        ),
        CaptureDraftType.task => _classifyTask(transaction, existing),
        CaptureDraftType.note ||
        CaptureDraftType.decision ||
        CaptureDraftType.defect => Future<String>.value(existing.id),
      };
      final classified = CaptureDraft(
        id: existing.id,
        input: existing.input,
        status: CaptureDraftStatus.classified,
        targetType: captureTargetFor(existing.type),
        targetId: await targetId,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
      );
      await _updateDraft(transaction, classified);
      return classified;
    });
  }

  @override
  Future<CaptureDraft> merge({
    required String projectId,
    required String retainedCaptureId,
    required String mergedCaptureId,
  }) {
    if (retainedCaptureId == mergedCaptureId) {
      throw const CaptureDraftMergeException();
    }
    return _database.transaction<CaptureDraft>((transaction) async {
      final retained = await _requireOpenDraft(
        transaction,
        projectId: projectId,
        captureId: retainedCaptureId,
      );
      final merged = await _requireOpenDraft(
        transaction,
        projectId: projectId,
        captureId: mergedCaptureId,
      );
      if (retained.type != merged.type) {
        throw const CaptureDraftMergeException();
      }

      final input = CaptureDraftInput(
        projectId: retained.projectId,
        type: retained.type,
        title: retained.title ?? merged.title,
        content: _mergeContent(retained.content, merged.content),
        attachmentIds: <String>{
          ...retained.attachmentIds,
          ...merged.attachmentIds,
        },
        grossAmountMinorUnits:
            retained.input.grossAmountMinorUnits ??
            merged.input.grossAmountMinorUnits,
        vatRateBasisPoints:
            retained.input.vatRateBasisPoints ??
            merged.input.vatRateBasisPoints,
        scheduledAt:
            retained.input.scheduledAtUtc ?? merged.input.scheduledAtUtc,
        timeZoneId: retained.input.timeZoneId ?? merged.input.timeZoneId,
      );
      await _requireAvailableAttachments(transaction, input);
      final result = CaptureDraft(
        id: retained.id,
        input: input,
        status: input.status,
        createdAt: retained.createdAtUtc,
        updatedAt: _utcNow(),
      );
      await _updateDraft(transaction, result);
      await transaction.delete(
        AppDatabase.captureDraftAttachmentsTable,
        where: 'project_id = ? AND capture_id IN (?, ?)',
        whereArgs: <Object?>[projectId, retainedCaptureId, mergedCaptureId],
      );
      await _insertAttachmentLinks(transaction, result);
      await transaction.delete(
        AppDatabase.captureDraftsTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, mergedCaptureId],
      );
      return result;
    });
  }

  @override
  Future<List<String>> reject({
    required String projectId,
    required String captureId,
  }) {
    return _database.transaction<List<String>>((transaction) async {
      final existing = await _requireOpenDraft(
        transaction,
        projectId: projectId,
        captureId: captureId,
      );
      await transaction.delete(
        AppDatabase.captureDraftsTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, captureId],
      );
      return existing.attachmentIds.toList(growable: false);
    });
  }

  Future<String> _classifyAttachments(
    DatabaseExecutor transaction,
    CaptureDraft draft,
  ) async {
    final documentType = draft.type == CaptureDraftType.photo
        ? ProjectDocumentType.photo
        : ProjectDocumentType.other;
    for (final attachmentId in draft.attachmentIds) {
      await _documentRepository.saveDetailsInTransaction(
        transaction,
        projectId: draft.projectId,
        documentId: attachmentId,
        metadata: DocumentMetadata(
          title: draft.title!,
          type: documentType,
          description: draft.content,
        ),
        contextLinks: const <DocumentRelation>[],
      );
    }
    return draft.attachmentIds.first;
  }

  Future<String> _classifyCost(
    DatabaseExecutor transaction,
    CaptureDraft draft,
    String currencyCode,
  ) async {
    final rate = VatRate.values.firstWhere(
      (value) => value.basisPoints == draft.input.vatRateBasisPoints,
    );
    final cost = await _costRepository.insertDraftInTransaction(
      transaction,
      CostDraftInput(
        CostEntryInput(
          projectId: draft.projectId,
          name: draft.title!,
          type: CostEntryType.cost,
          status: CostStatus.planned,
          amount: VatBreakdown.fromGross(
            Money(
              minorUnits: draft.input.grossAmountMinorUnits!,
              currencyCode: currencyCode,
            ),
            rate,
          ),
          entryDate: _utcNow(),
          source: CostSource.manual,
          attachmentIds: draft.attachmentIds,
          note: draft.content,
        ),
      ),
    );
    return cost.id;
  }

  Future<String> _classifyTask(
    DatabaseExecutor transaction,
    CaptureDraft draft,
  ) async {
    final event = await _scheduleRepository.insertInTransaction(
      transaction,
      projectId: draft.projectId,
      input: ScheduleEventInput(
        title: draft.title!,
        kind: ScheduleEventKind.task,
        status: ScheduleEventStatus.planned,
        startsAt: draft.input.scheduledAtUtc!,
        timeZoneId: draft.input.timeZoneId!,
        isAllDay: false,
        note: draft.content,
        reminderEnabled: false,
        reminderLeadMinutes: 0,
      ),
    );
    return event.id;
  }

  Future<CaptureDraft> _requireOpenDraft(
    DatabaseExecutor executor, {
    required String projectId,
    required String captureId,
  }) async {
    final draft = await _findById(
      executor,
      projectId: projectId,
      captureId: captureId,
    );
    if (draft == null) throw const CaptureDraftNotFoundException();
    if (!draft.isOpen) throw const CaptureDraftNotReadyException();
    return draft;
  }

  Future<CaptureDraft?> _findById(
    DatabaseExecutor executor, {
    required String projectId,
    required String captureId,
  }) async {
    final rows = await executor.query(
      AppDatabase.captureDraftsTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, captureId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (await _draftsFromRows(executor, rows)).single;
  }

  Future<List<CaptureDraft>> _draftsFromRows(
    DatabaseExecutor executor,
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) return const <CaptureDraft>[];
    final projectId = rows.first['project_id']! as String;
    final ids = rows.map((row) => row['id']! as String).toList();
    final placeholders = List<String>.filled(ids.length, '?').join(', ');
    final attachmentRows = await executor.query(
      AppDatabase.captureDraftAttachmentsTable,
      where: 'project_id = ? AND capture_id IN ($placeholders)',
      whereArgs: <Object?>[projectId, ...ids],
      orderBy: 'capture_id ASC, sort_order ASC',
    );
    final attachmentsByCapture = <String, List<String>>{};
    for (final row in attachmentRows) {
      (attachmentsByCapture[row['capture_id']! as String] ??= <String>[]).add(
        row['attachment_id']! as String,
      );
    }
    return rows
        .map(
          (row) => _draftFromRow(
            row,
            attachmentsByCapture[row['id']! as String] ?? const <String>[],
          ),
        )
        .toList(growable: false);
  }

  Future<void> _requireAvailableAttachments(
    DatabaseExecutor executor,
    CaptureDraftInput input,
  ) async {
    if (input.attachmentIds.isEmpty) return;
    final placeholders = List<String>.filled(
      input.attachmentIds.length,
      '?',
    ).join(', ');
    final rows = await executor.query(
      AppDatabase.costAttachmentsTable,
      columns: const <String>['id'],
      where: 'project_id = ? AND availability = ? AND id IN ($placeholders)',
      whereArgs: <Object?>[
        input.projectId,
        'available',
        ...input.attachmentIds,
      ],
    );
    if (rows.length != input.attachmentIds.length) {
      throw ArgumentError.value(input.attachmentIds, 'attachmentIds');
    }
  }

  Future<void> _updateDraft(
    DatabaseExecutor executor,
    CaptureDraft draft,
  ) async {
    final count = await executor.update(
      AppDatabase.captureDraftsTable,
      _draftToRow(draft),
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[draft.projectId, draft.id],
    );
    if (count != 1) throw const CaptureDraftNotFoundException();
  }

  Future<void> _replaceAttachmentLinks(
    DatabaseExecutor executor,
    CaptureDraft draft,
  ) async {
    await executor.delete(
      AppDatabase.captureDraftAttachmentsTable,
      where: 'project_id = ? AND capture_id = ?',
      whereArgs: <Object?>[draft.projectId, draft.id],
    );
    await _insertAttachmentLinks(executor, draft);
  }

  Future<void> _insertAttachmentLinks(
    DatabaseExecutor executor,
    CaptureDraft draft,
  ) async {
    for (var index = 0; index < draft.attachmentIds.length; index++) {
      await executor
          .insert(AppDatabase.captureDraftAttachmentsTable, <String, Object?>{
            'project_id': draft.projectId,
            'capture_id': draft.id,
            'attachment_id': draft.attachmentIds[index],
            'sort_order': index,
          });
    }
  }
}

({String sql, List<Object?> arguments}) _queryFilter(CaptureDraftQuery query) {
  final clauses = <String>['project_id = ?'];
  final arguments = <Object?>[query.projectId];
  if (query.statuses.isNotEmpty) {
    clauses.add(
      'status IN (${List<String>.filled(query.statuses.length, '?').join(', ')})',
    );
    arguments.addAll(query.statuses.map(_statusToStorage));
  }
  if (query.types.isNotEmpty) {
    clauses.add(
      'capture_type IN '
      '(${List<String>.filled(query.types.length, '?').join(', ')})',
    );
    arguments.addAll(query.types.map(_typeToStorage));
  }
  return (sql: clauses.join(' AND '), arguments: arguments);
}

Map<String, Object?> _draftToRow(CaptureDraft draft) => <String, Object?>{
  'id': draft.id,
  'project_id': draft.projectId,
  'capture_type': _typeToStorage(draft.type),
  'status': _statusToStorage(draft.status),
  'title': draft.title,
  'content': draft.content,
  'gross_amount_minor_units': draft.input.grossAmountMinorUnits,
  'vat_rate_basis_points': draft.input.vatRateBasisPoints,
  'scheduled_at_utc_ms': draft.input.scheduledAtUtc == null
      ? null
      : DatabaseValueCodec.dateTimeToUtcMilliseconds(
          draft.input.scheduledAtUtc!,
        ),
  'time_zone_id': draft.input.timeZoneId,
  'target_type': draft.targetType == null
      ? null
      : _targetToStorage(draft.targetType!),
  'target_id': draft.targetId,
  'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
    draft.createdAtUtc,
  ),
  'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
    draft.updatedAtUtc,
  ),
};

CaptureDraft _draftFromRow(
  Map<String, Object?> row,
  List<String> attachmentIds,
) {
  final input = CaptureDraftInput(
    projectId: row['project_id']! as String,
    type: _typeFromStorage(row['capture_type']! as String),
    title: row['title'] as String?,
    content: row['content'] as String?,
    attachmentIds: attachmentIds,
    grossAmountMinorUnits: row['gross_amount_minor_units'] as int?,
    vatRateBasisPoints: row['vat_rate_basis_points'] as int?,
    scheduledAt: switch (row['scheduled_at_utc_ms']) {
      final int value => DatabaseValueCodec.utcMillisecondsToDateTime(value),
      _ => null,
    },
    timeZoneId: row['time_zone_id'] as String?,
  );
  return CaptureDraft(
    id: row['id']! as String,
    input: input,
    status: _statusFromStorage(row['status']! as String),
    targetType: switch (row['target_type']) {
      final String value => _targetFromStorage(value),
      _ => null,
    },
    targetId: row['target_id'] as String?,
    createdAt: DatabaseValueCodec.utcMillisecondsToDateTime(
      row['created_at_utc_ms']! as int,
    ),
    updatedAt: DatabaseValueCodec.utcMillisecondsToDateTime(
      row['updated_at_utc_ms']! as int,
    ),
  );
}

String? _mergeContent(String? retained, String? merged) {
  if (retained == null) return merged;
  if (merged == null || merged == retained) return retained;
  return '$retained\n\n$merged';
}

String _typeToStorage(CaptureDraftType value) => value.name;

CaptureDraftType _typeFromStorage(String value) =>
    CaptureDraftType.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => throw FormatException('Unknown capture type: $value'),
    );

String _statusToStorage(CaptureDraftStatus value) => switch (value) {
  CaptureDraftStatus.needsReview => 'needs_review',
  CaptureDraftStatus.ready => 'ready',
  CaptureDraftStatus.classified => 'classified',
};

CaptureDraftStatus _statusFromStorage(String value) => switch (value) {
  'needs_review' => CaptureDraftStatus.needsReview,
  'ready' => CaptureDraftStatus.ready,
  'classified' => CaptureDraftStatus.classified,
  _ => throw FormatException('Unknown capture status: $value'),
};

String _targetToStorage(CaptureTargetType value) => switch (value) {
  CaptureTargetType.document => 'document',
  CaptureTargetType.costDraft => 'cost_draft',
  CaptureTargetType.scheduleTask => 'schedule_task',
  CaptureTargetType.note => 'note',
  CaptureTargetType.decision => 'decision',
  CaptureTargetType.defect => 'defect',
};

CaptureTargetType _targetFromStorage(String value) => switch (value) {
  'document' => CaptureTargetType.document,
  'cost_draft' => CaptureTargetType.costDraft,
  'schedule_task' => CaptureTargetType.scheduleTask,
  'note' => CaptureTargetType.note,
  'decision' => CaptureTargetType.decision,
  'defect' => CaptureTargetType.defect,
  _ => throw FormatException('Unknown capture target: $value'),
};
