import 'dart:convert';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/diary/domain/journal_repository.dart';
import 'package:budowapro/shared/models/defect_severity.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteJournalRepository implements JournalRepository {
  const SqliteJournalRepository({
    required AppDatabase database,
    required String Function() idGenerator,
    required DateTime Function() utcNow,
  }) : this._(database, idGenerator, utcNow);

  const SqliteJournalRepository._(
    this._database,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final String Function() _idGenerator;
  final DateTime Function() _utcNow;

  @override
  Future<JournalEntry> create(JournalEntryInput input) {
    return _database.transaction<JournalEntry>(
      (transaction) => createInTransaction(transaction, input),
    );
  }

  Future<JournalEntry> createInTransaction(
    DatabaseExecutor transaction,
    JournalEntryInput input,
  ) async {
    await _validateRelations(transaction, input);
    final now = _utcNow().toUtc();
    final entry = JournalEntry(
      id: _idGenerator(),
      input: input,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    );
    await transaction.insert(
      AppDatabase.journalEntriesTable,
      _entryToRow(entry),
    );
    await _replaceRelations(transaction, entry);
    await _insertRevision(
      transaction,
      entry: entry,
      action: 'created',
      createdAt: now,
    );
    return entry;
  }

  @override
  Future<JournalEntry> update({
    required String projectId,
    required String entryId,
    required JournalEntryInput input,
  }) {
    return _database.transaction<JournalEntry>(
      (transaction) => updateInTransaction(
        transaction,
        projectId: projectId,
        entryId: entryId,
        input: input,
      ),
    );
  }

  Future<JournalEntry> updateInTransaction(
    DatabaseExecutor transaction, {
    required String projectId,
    required String entryId,
    required JournalEntryInput input,
  }) async {
    final existing = await _findById(transaction, projectId, entryId);
    if (existing == null) throw const JournalEntryNotFoundException();
    if (input.projectId != projectId) {
      throw ArgumentError.value(input.projectId, 'input.projectId');
    }
    var normalizedInput = input;
    var approval = existing.approval;
    if (_isDecision(existing.type)) {
      final contentChanged =
          _approvalFingerprint(existing.input) !=
          _approvalFingerprint(normalizedInput);
      if (approval != null && contentChanged) {
        normalizedInput = _withStatus(
          normalizedInput,
          JournalEntryStatus.proposal,
        );
        approval = null;
      } else if (normalizedInput.status != JournalEntryStatus.approved &&
          normalizedInput.status != JournalEntryStatus.implemented) {
        approval = null;
      } else if (approval == null) {
        throw const JournalDecisionApprovalRequiredException();
      }
    }
    await _validateRelations(transaction, normalizedInput);
    final now = _utcNow().toUtc();
    final updated = JournalEntry(
      id: existing.id,
      input: normalizedInput,
      createdAt: existing.createdAtUtc,
      updatedAt: now,
      revision: existing.revision + 1,
      approval: approval,
    );
    await transaction.update(
      AppDatabase.journalEntriesTable,
      _entryToRow(updated),
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, entryId],
    );
    await _replaceRelations(transaction, updated);
    await _insertRevision(
      transaction,
      entry: updated,
      action: existing.status == updated.status ? 'updated' : 'status_changed',
      createdAt: now,
    );
    return updated;
  }

  @override
  Future<JournalEntry?> findById({
    required String projectId,
    required String entryId,
  }) async {
    final database = await _database.open();
    return _findById(database, projectId, entryId);
  }

  @override
  Future<void> delete({required String projectId, required String entryId}) {
    return _database.transaction<void>((transaction) async {
      await _deletePolymorphicRelations(
        transaction,
        projectId: projectId,
        entryId: entryId,
      );
      final deleted = await transaction.delete(
        AppDatabase.journalEntriesTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, entryId],
      );
      if (deleted == 0) throw const JournalEntryNotFoundException();
    });
  }

  static Future<void> _deletePolymorphicRelations(
    DatabaseExecutor executor, {
    required String projectId,
    required String entryId,
  }) async {
    await executor.delete(
      AppDatabase.roomChoiceOutputsTable,
      where: 'project_id = ? AND output_type = ? AND record_id = ?',
      whereArgs: <Object?>[projectId, 'decision', entryId],
    );
    await executor.delete(
      AppDatabase.roomRecordLinksTable,
      where: 'project_id = ? AND record_type = ? AND record_id = ?',
      whereArgs: <Object?>[projectId, 'journal', entryId],
    );
    await executor.delete(
      AppDatabase.documentContextLinksTable,
      where: 'project_id = ? AND relation_type IN (?, ?) AND target_id = ?',
      whereArgs: <Object?>[projectId, 'decision', 'defect', entryId],
    );
    await executor.delete(
      AppDatabase.technicalPhotoLinksTable,
      where: 'project_id = ? AND relation_type IN (?, ?) AND target_id = ?',
      whereArgs: <Object?>[projectId, 'decision', 'defect', entryId],
    );
  }

  Future<JournalEntry?> findByIdInTransaction(
    DatabaseExecutor executor, {
    required String projectId,
    required String entryId,
  }) {
    return _findById(executor, projectId, entryId);
  }

  @override
  Future<Page<JournalEntry>> list(
    JournalEntryQuery query,
    PageRequest request,
  ) async {
    final database = await _database.open();
    final filter = _queryFilter(query);
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM ${AppDatabase.journalEntriesTable} '
      'WHERE ${filter.sql}',
      filter.arguments,
    );
    final rows = await database.query(
      AppDatabase.journalEntriesTable,
      where: filter.sql,
      whereArgs: filter.arguments,
      orderBy: 'occurred_at_utc_ms DESC, id DESC',
      limit: request.limit,
      offset: request.offset,
    );
    return Page<JournalEntry>(
      items: await _entriesFromRows(database, rows),
      totalCount: countRows.single['count']! as int,
      request: request,
    );
  }

  @override
  Future<JournalEntry> setStatus({
    required String projectId,
    required String entryId,
    required JournalEntryStatus status,
  }) async {
    final existing = await findById(projectId: projectId, entryId: entryId);
    if (existing == null) throw const JournalEntryNotFoundException();
    if (_isDecision(existing.type) && status == JournalEntryStatus.approved) {
      throw const JournalDecisionApprovalRequiredException();
    }
    final input = _withStatus(existing.input, status);
    return update(projectId: projectId, entryId: entryId, input: input);
  }

  @override
  Future<JournalEntry> approveDecision({
    required String projectId,
    required String entryId,
    required String approvedByContactId,
  }) {
    return _database.transaction<JournalEntry>((transaction) async {
      final existing = await _findById(transaction, projectId, entryId);
      if (existing == null) throw const JournalEntryNotFoundException();
      if (!_isDecision(existing.type) ||
          existing.input.selectedOption == null) {
        throw const JournalDecisionIncompleteException();
      }
      if (!await _exists(
        transaction,
        AppDatabase.contactsTable,
        projectId,
        approvedByContactId,
      )) {
        throw const JournalEntryRelationNotFoundException();
      }
      if (existing.status == JournalEntryStatus.approved &&
          existing.approval?.approvedByContactId == approvedByContactId) {
        return existing;
      }
      final now = _utcNow().toUtc();
      final approved = JournalEntry(
        id: existing.id,
        input: _withStatus(
          existing.input,
          JournalEntryStatus.approved,
          decisionMakerContactId:
              existing.input.decisionMakerContactId ?? approvedByContactId,
        ),
        createdAt: existing.createdAtUtc,
        updatedAt: now,
        revision: existing.revision + 1,
        approval: JournalApproval(
          approvedByContactId: approvedByContactId,
          approvedAt: now,
        ),
      );
      await transaction.update(
        AppDatabase.journalEntriesTable,
        _entryToRow(approved),
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, entryId],
      );
      await _insertRevision(
        transaction,
        entry: approved,
        action: 'status_changed',
        createdAt: now,
      );
      return approved;
    });
  }

  @override
  Future<DecisionImpactSummary> decisionImpactSummary({
    required String projectId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '''
        SELECT
          COUNT(*) AS decision_count,
          COALESCE(SUM(cost_delta_minor_units), 0) AS cost_delta_minor_units,
          COALESCE(SUM(schedule_delta_days), 0) AS schedule_delta_days
        FROM ${AppDatabase.journalEntriesTable}
        WHERE project_id = ?
          AND entry_type IN ('decision', 'scope_change')
          AND status IN ('approved', 'implemented')
          AND approved_at_utc_ms IS NOT NULL
          AND approved_by_contact_id IS NOT NULL
      ''',
      <Object?>[projectId],
    );
    final row = rows.single;
    return DecisionImpactSummary(
      projectId: projectId,
      approvedDecisionCount: row['decision_count']! as int,
      costDeltaMinorUnits: row['cost_delta_minor_units']! as int,
      scheduleDeltaDays: row['schedule_delta_days']! as int,
    );
  }

  @override
  Future<List<JournalEntryRevision>> revisions({
    required String projectId,
    required String entryId,
  }) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.journalEntryRevisionsTable,
      where: 'project_id = ? AND journal_entry_id = ?',
      whereArgs: <Object?>[projectId, entryId],
      orderBy: 'revision DESC',
    );
    return rows.map(_revisionFromRow).toList(growable: false);
  }

  Future<JournalEntry?> _findById(
    DatabaseExecutor executor,
    String projectId,
    String entryId,
  ) async {
    final rows = await executor.query(
      AppDatabase.journalEntriesTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, entryId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (await _entriesFromRows(executor, rows)).single;
  }

  Future<List<JournalEntry>> _entriesFromRows(
    DatabaseExecutor executor,
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) return const <JournalEntry>[];
    final projectId = rows.first['project_id']! as String;
    final ids = rows.map((row) => row['id']! as String).toList(growable: false);
    final placeholders = List<String>.filled(ids.length, '?').join(', ');
    final attachmentRows = await executor.query(
      AppDatabase.journalEntryAttachmentsTable,
      where: 'project_id = ? AND journal_entry_id IN ($placeholders)',
      whereArgs: <Object?>[projectId, ...ids],
      orderBy: 'journal_entry_id ASC, sort_order ASC',
    );
    final attachmentsByEntry = <String, List<String>>{};
    for (final row in attachmentRows) {
      (attachmentsByEntry[row['journal_entry_id']! as String] ??= <String>[])
          .add(row['attachment_id']! as String);
    }
    final linkRows = await executor.query(
      AppDatabase.journalEntryLinksTable,
      where: 'project_id = ? AND journal_entry_id IN ($placeholders)',
      whereArgs: <Object?>[projectId, ...ids],
      orderBy: 'journal_entry_id ASC, sort_order ASC',
    );
    final linksByEntry = <String, List<JournalRelation>>{};
    for (final row in linkRows) {
      final entryId = row['journal_entry_id']! as String;
      (linksByEntry[entryId] ??= <JournalRelation>[]).add(
        JournalRelation(
          type: _relationTypeFromStorage(row['relation_type']! as String),
          targetId: row['target_id']! as String,
          purpose: _relationPurposeFromStorage(
            row['relation_purpose']! as String,
          ),
          label: row['label'] as String?,
        ),
      );
    }
    return rows
        .map(
          (row) => _entryFromRow(
            row,
            attachmentsByEntry[row['id']! as String] ?? const <String>[],
            linksByEntry[row['id']! as String] ?? const <JournalRelation>[],
          ),
        )
        .toList(growable: false);
  }

  Future<void> _validateRelations(
    DatabaseExecutor executor,
    JournalEntryInput input,
  ) async {
    if (input.attachmentIds.isNotEmpty) {
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
        throw const JournalEntryRelationNotFoundException();
      }
    }
    if (input.stageId != null &&
        !await _exists(
          executor,
          AppDatabase.projectStagesTable,
          input.projectId,
          input.stageId!,
        )) {
      throw const JournalEntryRelationNotFoundException();
    }
    for (final relation in input.relations) {
      final table = switch (relation.type) {
        JournalRelationType.stage => AppDatabase.projectStagesTable,
        JournalRelationType.contact => AppDatabase.contactsTable,
        JournalRelationType.checklist => AppDatabase.checklistItemsTable,
        JournalRelationType.schedule => AppDatabase.scheduleEventsTable,
        JournalRelationType.cost => AppDatabase.costEntriesTable,
        JournalRelationType.capture => AppDatabase.captureDraftsTable,
      };
      if (!await _exists(executor, table, input.projectId, relation.targetId)) {
        throw const JournalEntryRelationNotFoundException();
      }
    }
    if (input.responsibleContactId != null &&
        !await _exists(
          executor,
          AppDatabase.contactsTable,
          input.projectId,
          input.responsibleContactId!,
        )) {
      throw const JournalEntryRelationNotFoundException();
    }
    if (input.decisionMakerContactId != null &&
        !await _exists(
          executor,
          AppDatabase.contactsTable,
          input.projectId,
          input.decisionMakerContactId!,
        )) {
      throw const JournalEntryRelationNotFoundException();
    }
    if (input.sourceCaptureId != null &&
        !await _exists(
          executor,
          AppDatabase.captureDraftsTable,
          input.projectId,
          input.sourceCaptureId!,
        )) {
      throw const JournalEntryRelationNotFoundException();
    }
  }

  Future<bool> _exists(
    DatabaseExecutor executor,
    String table,
    String projectId,
    String id,
  ) async {
    final rows = await executor.query(
      table,
      columns: const <String>['id'],
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> _replaceRelations(
    DatabaseExecutor executor,
    JournalEntry entry,
  ) async {
    await executor.delete(
      AppDatabase.journalEntryAttachmentsTable,
      where: 'project_id = ? AND journal_entry_id = ?',
      whereArgs: <Object?>[entry.projectId, entry.id],
    );
    for (var index = 0; index < entry.attachmentIds.length; index++) {
      await executor
          .insert(AppDatabase.journalEntryAttachmentsTable, <String, Object?>{
            'project_id': entry.projectId,
            'journal_entry_id': entry.id,
            'attachment_id': entry.attachmentIds[index],
            'sort_order': index,
          });
    }
    await executor.delete(
      AppDatabase.journalEntryLinksTable,
      where: 'project_id = ? AND journal_entry_id = ?',
      whereArgs: <Object?>[entry.projectId, entry.id],
    );
    for (var index = 0; index < entry.relations.length; index++) {
      final relation = entry.relations[index];
      await executor
          .insert(AppDatabase.journalEntryLinksTable, <String, Object?>{
            'project_id': entry.projectId,
            'journal_entry_id': entry.id,
            'relation_type': _relationTypeToStorage(relation.type),
            'target_id': relation.targetId,
            'relation_purpose': _relationPurposeToStorage(relation.purpose),
            'label': relation.label,
            'sort_order': index,
          });
    }
  }

  Future<void> _insertRevision(
    DatabaseExecutor executor, {
    required JournalEntry entry,
    required String action,
    required DateTime createdAt,
  }) async {
    await executor
        .insert(AppDatabase.journalEntryRevisionsTable, <String, Object?>{
          'id': _idGenerator(),
          'project_id': entry.projectId,
          'journal_entry_id': entry.id,
          'revision': entry.revision,
          'action': action,
          'snapshot_json': jsonEncode(_snapshot(entry)),
          'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
            createdAt,
          ),
        });
  }

  Map<String, Object?> _snapshot(JournalEntry entry) {
    final input = entry.input;
    return <String, Object?>{
      'type': _typeToStorage(input.type),
      'status': _statusToStorage(input.status),
      'title': input.title,
      'body': input.body,
      'weather': input.weather,
      'people': input.people,
      'workPerformed': input.workPerformed,
      'deliveries': input.deliveries,
      'delays': input.delays,
      'nextSteps': input.nextSteps,
      'problem': input.problem,
      'variants': input.variants,
      'selectedOption': input.selectedOption,
      'rationale': input.rationale,
      'stageId': input.stageId,
      'responsibleContactId': input.responsibleContactId,
      'decisionMakerContactId': input.decisionMakerContactId,
      'defectSeverity': input.defectSeverity?.name,
      'roomLabel': input.roomLabel,
      'requiresResolutionPhoto': input.requiresResolutionPhoto,
      'requiresSignedProtocol': input.requiresSignedProtocol,
      'dueAtUtcMs': input.dueAt == null
          ? null
          : DatabaseValueCodec.dateTimeToUtcMilliseconds(input.dueAt!),
      'costDeltaMinorUnits': input.costDeltaMinorUnits,
      'scheduleDeltaDays': input.scheduleDeltaDays,
      'approvedByContactId': entry.approval?.approvedByContactId,
      'approvedAtUtcMs': entry.approval == null
          ? null
          : DatabaseValueCodec.dateTimeToUtcMilliseconds(
              entry.approval!.approvedAtUtc,
            ),
      'occurredAtUtcMs': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        input.occurredAt,
      ),
      'attachmentIds': input.attachmentIds,
      'relations': input.relations
          .map(
            (relation) => <String, Object?>{
              'type': _relationTypeToStorage(relation.type),
              'targetId': relation.targetId,
              'purpose': _relationPurposeToStorage(relation.purpose),
              'label': relation.label,
            },
          )
          .toList(growable: false),
    };
  }

  Map<String, Object?> _entryToRow(JournalEntry entry) {
    final input = entry.input;
    return <String, Object?>{
      'id': entry.id,
      'project_id': input.projectId,
      'entry_type': _typeToStorage(input.type),
      'status': _statusToStorage(input.status),
      'title': input.title,
      'body': input.body,
      'weather': input.weather,
      'people': input.people,
      'work_performed': input.workPerformed,
      'deliveries': input.deliveries,
      'delays': input.delays,
      'next_steps': input.nextSteps,
      'problem': input.problem,
      'variants': input.variants,
      'selected_option': input.selectedOption,
      'rationale': input.rationale,
      'stage_id': input.stageId,
      'responsible_contact_id': input.responsibleContactId,
      'decision_maker_contact_id': input.decisionMakerContactId,
      'defect_severity': input.defectSeverity?.name,
      'defect_room_label': input.roomLabel,
      'requires_resolution_photo': input.requiresResolutionPhoto ? 1 : 0,
      'requires_signed_protocol': input.requiresSignedProtocol ? 1 : 0,
      'due_at_utc_ms': input.dueAt == null
          ? null
          : DatabaseValueCodec.dateTimeToUtcMilliseconds(input.dueAt!),
      'cost_delta_minor_units': input.costDeltaMinorUnits,
      'schedule_delta_days': input.scheduleDeltaDays,
      'approved_by_contact_id': entry.approval?.approvedByContactId,
      'approved_at_utc_ms': entry.approval == null
          ? null
          : DatabaseValueCodec.dateTimeToUtcMilliseconds(
              entry.approval!.approvedAtUtc,
            ),
      'source_capture_id': input.sourceCaptureId,
      'occurred_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        input.occurredAt,
      ),
      'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        entry.createdAtUtc,
      ),
      'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        entry.updatedAtUtc,
      ),
      'revision': entry.revision,
    };
  }

  JournalEntry _entryFromRow(
    Map<String, Object?> row,
    List<String> attachmentIds,
    List<JournalRelation> relations,
  ) {
    final input = JournalEntryInput(
      projectId: row['project_id']! as String,
      type: _typeFromStorage(row['entry_type']! as String),
      title: row['title']! as String,
      occurredAt: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['occurred_at_utc_ms']! as int,
      ),
      status: _statusFromStorage(row['status']! as String),
      body: row['body'] as String?,
      weather: row['weather'] as String?,
      people: row['people'] as String?,
      workPerformed: row['work_performed'] as String?,
      deliveries: row['deliveries'] as String?,
      delays: row['delays'] as String?,
      nextSteps: row['next_steps'] as String?,
      problem: row['problem'] as String?,
      variants: row['variants'] as String?,
      selectedOption: row['selected_option'] as String?,
      rationale: row['rationale'] as String?,
      stageId: row['stage_id'] as String?,
      responsibleContactId: row['responsible_contact_id'] as String?,
      decisionMakerContactId: row['decision_maker_contact_id'] as String?,
      defectSeverity: row['defect_severity'] == null
          ? null
          : DefectSeverity.values.firstWhere(
              (severity) => severity.name == row['defect_severity'],
            ),
      roomLabel: row['defect_room_label'] as String?,
      requiresResolutionPhoto: row['requires_resolution_photo'] == 1,
      requiresSignedProtocol: row['requires_signed_protocol'] == 1,
      dueAt: row['due_at_utc_ms'] == null
          ? null
          : DatabaseValueCodec.utcMillisecondsToDateTime(
              row['due_at_utc_ms']! as int,
            ),
      costDeltaMinorUnits: row['cost_delta_minor_units'] as int?,
      scheduleDeltaDays: row['schedule_delta_days'] as int?,
      attachmentIds: attachmentIds,
      relations: relations,
      sourceCaptureId: row['source_capture_id'] as String?,
    );
    return JournalEntry(
      id: row['id']! as String,
      input: input,
      createdAt: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['created_at_utc_ms']! as int,
      ),
      updatedAt: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['updated_at_utc_ms']! as int,
      ),
      revision: row['revision']! as int,
      approval:
          row['approved_by_contact_id'] == null ||
              row['approved_at_utc_ms'] == null
          ? null
          : JournalApproval(
              approvedByContactId: row['approved_by_contact_id']! as String,
              approvedAt: DatabaseValueCodec.utcMillisecondsToDateTime(
                row['approved_at_utc_ms']! as int,
              ),
            ),
    );
  }

  JournalEntryRevision _revisionFromRow(Map<String, Object?> row) {
    return JournalEntryRevision(
      id: row['id']! as String,
      projectId: row['project_id']! as String,
      entryId: row['journal_entry_id']! as String,
      revision: row['revision']! as int,
      action: row['action']! as String,
      snapshotJson: row['snapshot_json']! as String,
      createdAtUtc: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['created_at_utc_ms']! as int,
      ),
    );
  }

  JournalEntryInput _withStatus(
    JournalEntryInput input,
    JournalEntryStatus status, {
    String? decisionMakerContactId,
  }) {
    return JournalEntryInput(
      projectId: input.projectId,
      type: input.type,
      title: input.title,
      occurredAt: input.occurredAt,
      status: status,
      body: input.body,
      weather: input.weather,
      people: input.people,
      workPerformed: input.workPerformed,
      deliveries: input.deliveries,
      delays: input.delays,
      nextSteps: input.nextSteps,
      problem: input.problem,
      variants: input.variants,
      selectedOption: input.selectedOption,
      rationale: input.rationale,
      stageId: input.stageId,
      responsibleContactId: input.responsibleContactId,
      decisionMakerContactId:
          decisionMakerContactId ?? input.decisionMakerContactId,
      defectSeverity: input.defectSeverity,
      roomLabel: input.roomLabel,
      requiresResolutionPhoto: input.requiresResolutionPhoto,
      requiresSignedProtocol: input.requiresSignedProtocol,
      dueAt: input.dueAt,
      costDeltaMinorUnits: input.costDeltaMinorUnits,
      scheduleDeltaDays: input.scheduleDeltaDays,
      attachmentIds: input.attachmentIds,
      relations: input.relations,
      sourceCaptureId: input.sourceCaptureId,
    );
  }
}

bool _isDecision(JournalEntryType type) =>
    type == JournalEntryType.decision || type == JournalEntryType.scopeChange;

String _approvalFingerprint(JournalEntryInput input) {
  return jsonEncode(<String, Object?>{
    'type': _typeToStorage(input.type),
    'title': input.title,
    'body': input.body,
    'problem': input.problem,
    'variants': input.variants,
    'selectedOption': input.selectedOption,
    'rationale': input.rationale,
    'stageId': input.stageId,
    'responsibleContactId': input.responsibleContactId,
    'decisionMakerContactId': input.decisionMakerContactId,
    'defectSeverity': input.defectSeverity?.name,
    'roomLabel': input.roomLabel,
    'requiresResolutionPhoto': input.requiresResolutionPhoto,
    'requiresSignedProtocol': input.requiresSignedProtocol,
    'dueAtUtcMs': input.dueAt?.millisecondsSinceEpoch,
    'costDeltaMinorUnits': input.costDeltaMinorUnits,
    'scheduleDeltaDays': input.scheduleDeltaDays,
    'occurredAtUtcMs': input.occurredAt.millisecondsSinceEpoch,
    'attachmentIds': input.attachmentIds,
    'relations': input.relations
        .map(
          (relation) => <String, Object?>{
            'type': _relationTypeToStorage(relation.type),
            'targetId': relation.targetId,
            'purpose': _relationPurposeToStorage(relation.purpose),
            'label': relation.label,
          },
        )
        .toList(growable: false),
  });
}

({String sql, List<Object?> arguments}) _queryFilter(JournalEntryQuery query) {
  final clauses = <String>['project_id = ?'];
  final arguments = <Object?>[query.projectId];
  if (query.types.isNotEmpty) {
    clauses.add(
      'entry_type IN (${List<String>.filled(query.types.length, '?').join(', ')})',
    );
    arguments.addAll(query.types.map(_typeToStorage));
  }
  if (query.statuses.isNotEmpty) {
    clauses.add(
      'status IN (${List<String>.filled(query.statuses.length, '?').join(', ')})',
    );
    arguments.addAll(query.statuses.map(_statusToStorage));
  }
  if (query.stageId != null) {
    clauses.add('stage_id = ?');
    arguments.add(query.stageId);
  }
  if (query.searchTerm != null) {
    clauses.add(
      '(lower(title) LIKE ? OR lower(body) LIKE ? OR lower(problem) LIKE ?)',
    );
    final term = '%${query.searchTerm}%';
    arguments.addAll(<Object?>[term, term, term]);
  }
  if (query.from != null) {
    clauses.add('occurred_at_utc_ms >= ?');
    arguments.add(DatabaseValueCodec.dateTimeToUtcMilliseconds(query.from!));
  }
  if (query.to != null) {
    clauses.add('occurred_at_utc_ms <= ?');
    arguments.add(DatabaseValueCodec.dateTimeToUtcMilliseconds(query.to!));
  }
  return (sql: clauses.join(' AND '), arguments: arguments);
}

String _typeToStorage(JournalEntryType value) => switch (value) {
  JournalEntryType.daily => 'daily',
  JournalEntryType.note => 'note',
  JournalEntryType.decision => 'decision',
  JournalEntryType.defect => 'defect',
  JournalEntryType.scopeChange => 'scope_change',
};

JournalEntryType _typeFromStorage(String value) => switch (value) {
  'daily' => JournalEntryType.daily,
  'note' => JournalEntryType.note,
  'decision' => JournalEntryType.decision,
  'defect' => JournalEntryType.defect,
  'scope_change' => JournalEntryType.scopeChange,
  _ => throw StateError('Unknown journal entry type'),
};

String _statusToStorage(JournalEntryStatus value) => switch (value) {
  JournalEntryStatus.draft => 'draft',
  JournalEntryStatus.open => 'open',
  JournalEntryStatus.inProgress => 'in_progress',
  JournalEntryStatus.proposal => 'proposal',
  JournalEntryStatus.pending => 'pending',
  JournalEntryStatus.approved => 'approved',
  JournalEntryStatus.rejected => 'rejected',
  JournalEntryStatus.implemented => 'implemented',
  JournalEntryStatus.recheck => 'recheck',
  JournalEntryStatus.fixed => 'fixed',
  JournalEntryStatus.closed => 'closed',
};

JournalEntryStatus _statusFromStorage(String value) => switch (value) {
  'draft' => JournalEntryStatus.draft,
  'open' => JournalEntryStatus.open,
  'in_progress' => JournalEntryStatus.inProgress,
  'proposal' => JournalEntryStatus.proposal,
  'pending' => JournalEntryStatus.pending,
  'approved' => JournalEntryStatus.approved,
  'rejected' => JournalEntryStatus.rejected,
  'implemented' => JournalEntryStatus.implemented,
  'recheck' => JournalEntryStatus.recheck,
  'fixed' => JournalEntryStatus.fixed,
  'closed' => JournalEntryStatus.closed,
  _ => throw StateError('Unknown journal entry status'),
};

String _relationTypeToStorage(JournalRelationType value) => switch (value) {
  JournalRelationType.stage => 'stage',
  JournalRelationType.contact => 'contact',
  JournalRelationType.checklist => 'checklist',
  JournalRelationType.schedule => 'schedule',
  JournalRelationType.cost => 'cost',
  JournalRelationType.capture => 'capture',
};

JournalRelationType _relationTypeFromStorage(String value) => switch (value) {
  'stage' => JournalRelationType.stage,
  'contact' => JournalRelationType.contact,
  'checklist' => JournalRelationType.checklist,
  'schedule' => JournalRelationType.schedule,
  'cost' => JournalRelationType.cost,
  'capture' => JournalRelationType.capture,
  _ => throw StateError('Unknown journal relation type'),
};

String _relationPurposeToStorage(JournalRelationPurpose value) =>
    switch (value) {
      JournalRelationPurpose.context => 'context',
      JournalRelationPurpose.blocks => 'blocks',
    };

JournalRelationPurpose _relationPurposeFromStorage(String value) =>
    switch (value) {
      'context' => JournalRelationPurpose.context,
      'blocks' => JournalRelationPurpose.blocks,
      _ => throw StateError('Unknown journal relation purpose'),
    };
