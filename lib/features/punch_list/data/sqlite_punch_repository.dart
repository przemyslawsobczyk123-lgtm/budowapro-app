import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/diary/data/sqlite_journal_repository.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/domain/punch_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

final class SqlitePunchRepository implements PunchRepository {
  factory SqlitePunchRepository({
    required AppDatabase database,
    required SqliteJournalRepository journalRepository,
    required String Function() idGenerator,
    required DateTime Function() utcNow,
  }) =>
      SqlitePunchRepository._(database, journalRepository, idGenerator, utcNow);

  const SqlitePunchRepository._(
    this._database,
    this._journalRepository,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final SqliteJournalRepository _journalRepository;
  final String Function() _idGenerator;
  final DateTime Function() _utcNow;

  @override
  Future<DefectRecord> createDefect(DefectInput input) {
    return _database.transaction<DefectRecord>((transaction) async {
      await _validateDefectInput(transaction, input);
      final entry = await _journalRepository.createInTransaction(
        transaction,
        input.toJournalInput(),
      );
      await _replaceResolutionAttachments(
        transaction,
        projectId: input.projectId,
        defectId: entry.id,
        attachmentIds: input.resolutionAttachmentIds,
      );
      await _syncTechnicalDefectLinks(
        transaction,
        projectId: input.projectId,
        defectId: entry.id,
        reportAttachmentIds: input.attachmentIds,
        resolutionAttachmentIds: input.resolutionAttachmentIds,
      );
      final saved = (await _findDefect(
        transaction,
        projectId: input.projectId,
        defectId: entry.id,
      ))!;
      _validateClosureEvidence(saved);
      return saved;
    });
  }

  @override
  Future<DefectRecord> updateDefect({
    required String projectId,
    required String defectId,
    required DefectInput input,
  }) {
    if (input.projectId != projectId) {
      throw ArgumentError.value(input.projectId, 'input.projectId');
    }
    return _database.transaction<DefectRecord>((transaction) async {
      final existing = await _findDefect(
        transaction,
        projectId: projectId,
        defectId: defectId,
      );
      if (existing == null) throw const DefectNotFoundException();
      await _validateDefectInput(transaction, input);
      await _journalRepository.updateInTransaction(
        transaction,
        projectId: projectId,
        entryId: defectId,
        input: input.toJournalInput(),
      );
      await _replaceResolutionAttachments(
        transaction,
        projectId: projectId,
        defectId: defectId,
        attachmentIds: input.resolutionAttachmentIds,
      );
      await _syncTechnicalDefectLinks(
        transaction,
        projectId: projectId,
        defectId: defectId,
        reportAttachmentIds: input.attachmentIds,
        resolutionAttachmentIds: input.resolutionAttachmentIds,
      );
      final saved = (await _findDefect(
        transaction,
        projectId: projectId,
        defectId: defectId,
      ))!;
      _validateClosureEvidence(saved);
      return saved;
    });
  }

  @override
  Future<DefectRecord?> findDefectById({
    required String projectId,
    required String defectId,
  }) async {
    final database = await _database.open();
    return _findDefect(database, projectId: projectId, defectId: defectId);
  }

  @override
  Future<Page<DefectRecord>> listDefects(
    DefectQuery query,
    PageRequest request,
  ) async {
    final database = await _database.open();
    final filter = _defectFilter(query);
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM ${AppDatabase.journalEntriesTable} '
      'WHERE ${filter.sql}',
      filter.arguments,
    );
    final rows = await database.query(
      AppDatabase.journalEntriesTable,
      columns: const <String>['id'],
      where: filter.sql,
      whereArgs: filter.arguments,
      orderBy:
          "CASE defect_severity WHEN 'critical' THEN 0 WHEN 'high' THEN 1 "
          "WHEN 'medium' THEN 2 ELSE 3 END ASC, "
          'CASE WHEN due_at_utc_ms IS NULL THEN 1 ELSE 0 END ASC, '
          'due_at_utc_ms ASC, occurred_at_utc_ms DESC, id DESC',
      limit: request.limit,
      offset: request.offset,
    );
    final defects = <DefectRecord>[];
    for (final row in rows) {
      final defect = await _findDefect(
        database,
        projectId: query.projectId,
        defectId: row['id']! as String,
      );
      if (defect != null) defects.add(defect);
    }
    return Page<DefectRecord>(
      items: defects,
      totalCount: countRows.single['total']! as int,
      request: request,
    );
  }

  @override
  Future<PunchSummary> summarizeDefects({
    required String projectId,
    required DateTime now,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '''
        SELECT
          COUNT(*) AS open_count,
          COALESCE(
            SUM(CASE WHEN defect_severity = 'critical' THEN 1 ELSE 0 END),
            0
          )
            AS critical_count,
          COALESCE(
            SUM(CASE
              WHEN due_at_utc_ms IS NOT NULL AND due_at_utc_ms < ? THEN 1
              ELSE 0
            END),
            0
          ) AS overdue_count
        FROM ${AppDatabase.journalEntriesTable}
        WHERE project_id = ? AND entry_type = 'defect' AND status <> 'closed'
      ''',
      <Object?>[_milliseconds(now.toUtc()), projectId],
    );
    final row = rows.single;
    return PunchSummary(
      openCount: row['open_count']! as int,
      criticalCount: row['critical_count']! as int,
      overdueCount: row['overdue_count']! as int,
    );
  }

  @override
  Future<DefectRecord> setDefectStatus({
    required String projectId,
    required String defectId,
    required JournalEntryStatus status,
  }) {
    if (!allowedStatusesFor(JournalEntryType.defect).contains(status) ||
        status == JournalEntryStatus.draft) {
      throw ArgumentError.value(status, 'status');
    }
    return _database.transaction<DefectRecord>((transaction) async {
      final defect = await _findDefect(
        transaction,
        projectId: projectId,
        defectId: defectId,
      );
      if (defect == null) throw const DefectNotFoundException();
      if (status == JournalEntryStatus.closed) {
        _validateClosureEvidence(defect, closing: true);
      }
      await _journalRepository.updateInTransaction(
        transaction,
        projectId: projectId,
        entryId: defectId,
        input: _journalInputWithStatus(defect.entry.input, status),
      );
      return (await _findDefect(
        transaction,
        projectId: projectId,
        defectId: defectId,
      ))!;
    });
  }

  void _validateClosureEvidence(DefectRecord defect, {bool closing = false}) {
    if (!closing && !defect.isClosed) return;
    if (defect.requiresResolutionPhoto &&
        defect.resolutionAttachmentIds.isEmpty) {
      throw const DefectClosureEvidenceRequiredException();
    }
    if (defect.requiresSignedProtocol && !defect.hasSignedProtocol) {
      throw const DefectClosureProtocolRequiredException();
    }
  }

  @override
  Future<AcceptanceProtocol> createProtocol(AcceptanceProtocolInput input) {
    return _saveProtocol(input: input);
  }

  @override
  Future<AcceptanceProtocol> updateProtocol({
    required String projectId,
    required String protocolId,
    required AcceptanceProtocolInput input,
  }) {
    if (input.projectId != projectId) {
      throw ArgumentError.value(input.projectId, 'input.projectId');
    }
    return _saveProtocol(protocolId: protocolId, input: input);
  }

  Future<AcceptanceProtocol> _saveProtocol({
    String? protocolId,
    required AcceptanceProtocolInput input,
  }) {
    return _database.transaction<AcceptanceProtocol>((transaction) async {
      await _validateProtocolInput(transaction, input);
      final existing = protocolId == null
          ? null
          : await _findProtocol(
              transaction,
              projectId: input.projectId,
              protocolId: protocolId,
            );
      if (protocolId != null && existing == null) {
        throw const AcceptanceProtocolNotFoundException();
      }
      final id = protocolId ?? _idGenerator();
      final now = _utcNow().toUtc();
      final values = <String, Object?>{
        'id': id,
        'project_id': input.projectId,
        'title': input.title,
        'status': _protocolStatusToStorage(input.status),
        'inspected_at_utc_ms': _milliseconds(input.inspectedAtUtc),
        'stage_id': input.stageId,
        'room_label': input.roomLabel,
        'contractor_contact_id': input.contractorContactId,
        'notes': input.notes,
        'created_at_utc_ms': _milliseconds(existing?.createdAtUtc ?? now),
        'updated_at_utc_ms': _milliseconds(now),
      };
      if (existing == null) {
        await transaction.insert(
          AppDatabase.acceptanceProtocolsTable,
          values,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } else {
        await transaction.update(
          AppDatabase.acceptanceProtocolsTable,
          values,
          where: 'project_id = ? AND id = ?',
          whereArgs: <Object?>[input.projectId, id],
        );
      }
      await _replaceProtocolRelations(
        transaction,
        projectId: input.projectId,
        protocolId: id,
        defectIds: input.defectIds,
        attachmentIds: input.signedAttachmentIds,
      );
      await _syncTechnicalProtocolLinks(
        transaction,
        projectId: input.projectId,
        protocolId: id,
        defectIds: input.defectIds,
      );
      return (await _findProtocol(
        transaction,
        projectId: input.projectId,
        protocolId: id,
      ))!;
    });
  }

  @override
  Future<AcceptanceProtocol?> findProtocolById({
    required String projectId,
    required String protocolId,
  }) async {
    final database = await _database.open();
    return _findProtocol(
      database,
      projectId: projectId,
      protocolId: protocolId,
    );
  }

  @override
  Future<Page<AcceptanceProtocol>> listProtocols(
    AcceptanceProtocolQuery query,
    PageRequest request,
  ) async {
    final database = await _database.open();
    final clauses = <String>['project_id = ?'];
    final arguments = <Object?>[query.projectId];
    if (query.searchText != null) {
      final pattern = _likePattern(query.searchText!);
      clauses.add(
        "(LOWER(title) LIKE ? ESCAPE '!' OR "
        "LOWER(COALESCE(notes, '')) LIKE ? ESCAPE '!' OR "
        "LOWER(COALESCE(room_label, '')) LIKE ? ESCAPE '!')",
      );
      arguments.addAll(<Object?>[pattern, pattern, pattern]);
    }
    if (query.statuses.isNotEmpty) {
      clauses.add('status IN (${_placeholders(query.statuses.length)})');
      arguments.addAll(query.statuses.map(_protocolStatusToStorage));
    }
    final where = clauses.join(' AND ');
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM ${AppDatabase.acceptanceProtocolsTable} '
      'WHERE $where',
      arguments,
    );
    final rows = await database.query(
      AppDatabase.acceptanceProtocolsTable,
      columns: const <String>['id'],
      where: where,
      whereArgs: arguments,
      orderBy: 'inspected_at_utc_ms DESC, id DESC',
      limit: request.limit,
      offset: request.offset,
    );
    final protocols = <AcceptanceProtocol>[];
    for (final row in rows) {
      final protocol = await _findProtocol(
        database,
        projectId: query.projectId,
        protocolId: row['id']! as String,
      );
      if (protocol != null) protocols.add(protocol);
    }
    return Page<AcceptanceProtocol>(
      items: protocols,
      totalCount: countRows.single['total']! as int,
      request: request,
    );
  }

  Future<void> _validateDefectInput(
    DatabaseExecutor executor,
    DefectInput input,
  ) async {
    await _requireActiveProject(executor, input.projectId);
    await _requireOptionalTarget(
      executor,
      AppDatabase.projectStagesTable,
      input.projectId,
      input.stageId,
    );
    await _requireOptionalTarget(
      executor,
      AppDatabase.contactsTable,
      input.projectId,
      input.responsibleContactId,
    );
    await _requireAttachments(
      executor,
      projectId: input.projectId,
      attachmentIds: <String>{
        ...input.attachmentIds,
        ...input.resolutionAttachmentIds,
      },
      accepts: (mediaType) => mediaType.startsWith('image/'),
    );
  }

  Future<void> _validateProtocolInput(
    DatabaseExecutor executor,
    AcceptanceProtocolInput input,
  ) async {
    await _requireActiveProject(executor, input.projectId);
    await _requireOptionalTarget(
      executor,
      AppDatabase.projectStagesTable,
      input.projectId,
      input.stageId,
    );
    await _requireOptionalTarget(
      executor,
      AppDatabase.contactsTable,
      input.projectId,
      input.contractorContactId,
    );
    if (input.defectIds.isNotEmpty) {
      final rows = await executor.query(
        AppDatabase.journalEntriesTable,
        columns: const <String>['id'],
        where:
            'project_id = ? AND entry_type = ? '
            'AND id IN (${_placeholders(input.defectIds.length)})',
        whereArgs: <Object?>[input.projectId, 'defect', ...input.defectIds],
      );
      if (rows.length != input.defectIds.length) {
        throw const PunchRelationNotFoundException();
      }
    }
    await _requireAttachments(
      executor,
      projectId: input.projectId,
      attachmentIds: input.signedAttachmentIds,
      accepts: (mediaType) =>
          mediaType == 'application/pdf' || mediaType.startsWith('image/'),
    );
  }

  Future<DefectRecord?> _findDefect(
    DatabaseExecutor executor, {
    required String projectId,
    required String defectId,
  }) async {
    final entry = await _journalRepository.findByIdInTransaction(
      executor,
      projectId: projectId,
      entryId: defectId,
    );
    if (entry == null || entry.type != JournalEntryType.defect) return null;
    final resolutionRows = await executor.query(
      AppDatabase.defectResolutionAttachmentsTable,
      columns: const <String>['attachment_id'],
      where: 'project_id = ? AND defect_id = ?',
      whereArgs: <Object?>[projectId, defectId],
      orderBy: 'sort_order ASC',
    );
    final protocolRows = await executor.rawQuery(
      '''
        SELECT
          links.protocol_id,
          CASE WHEN protocols.status = 'signed' AND EXISTS (
            SELECT 1
            FROM ${AppDatabase.acceptanceProtocolAttachmentsTable} files
            WHERE files.project_id = links.project_id
              AND files.protocol_id = links.protocol_id
          ) THEN 1 ELSE 0 END AS is_signed
        FROM ${AppDatabase.acceptanceProtocolDefectsTable} links
        INNER JOIN ${AppDatabase.acceptanceProtocolsTable} protocols
          ON protocols.project_id = links.project_id
          AND protocols.id = links.protocol_id
        WHERE links.project_id = ? AND links.defect_id = ?
        ORDER BY protocols.inspected_at_utc_ms DESC, links.protocol_id DESC
      ''',
      <Object?>[projectId, defectId],
    );
    return DefectRecord(
      entry: entry,
      resolutionAttachmentIds: resolutionRows.map(
        (row) => row['attachment_id']! as String,
      ),
      acceptanceProtocolIds: protocolRows.map(
        (row) => row['protocol_id']! as String,
      ),
      hasSignedProtocol: protocolRows.any((row) => row['is_signed'] == 1),
    );
  }

  Future<AcceptanceProtocol?> _findProtocol(
    DatabaseExecutor executor, {
    required String projectId,
    required String protocolId,
  }) async {
    final rows = await executor.query(
      AppDatabase.acceptanceProtocolsTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, protocolId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final defectRows = await executor.query(
      AppDatabase.acceptanceProtocolDefectsTable,
      columns: const <String>['defect_id'],
      where: 'project_id = ? AND protocol_id = ?',
      whereArgs: <Object?>[projectId, protocolId],
      orderBy: 'sort_order ASC',
    );
    final attachmentRows = await executor.query(
      AppDatabase.acceptanceProtocolAttachmentsTable,
      columns: const <String>['attachment_id'],
      where: 'project_id = ? AND protocol_id = ?',
      whereArgs: <Object?>[projectId, protocolId],
      orderBy: 'sort_order ASC',
    );
    final row = rows.single;
    return AcceptanceProtocol(
      id: row['id']! as String,
      input: AcceptanceProtocolInput(
        projectId: row['project_id']! as String,
        title: row['title']! as String,
        inspectedAt: _dateTime(row['inspected_at_utc_ms']!),
        status: _protocolStatusFromStorage(row['status']! as String),
        stageId: row['stage_id'] as String?,
        roomLabel: row['room_label'] as String?,
        contractorContactId: row['contractor_contact_id'] as String?,
        notes: row['notes'] as String?,
        defectIds: defectRows.map((item) => item['defect_id']! as String),
        signedAttachmentIds: attachmentRows.map(
          (item) => item['attachment_id']! as String,
        ),
      ),
      createdAt: _dateTime(row['created_at_utc_ms']!),
      updatedAt: _dateTime(row['updated_at_utc_ms']!),
    );
  }

  Future<void> _replaceResolutionAttachments(
    DatabaseExecutor executor, {
    required String projectId,
    required String defectId,
    required Iterable<String> attachmentIds,
  }) async {
    await executor.delete(
      AppDatabase.defectResolutionAttachmentsTable,
      where: 'project_id = ? AND defect_id = ?',
      whereArgs: <Object?>[projectId, defectId],
    );
    var order = 0;
    for (final attachmentId in attachmentIds) {
      await executor.insert(
        AppDatabase.defectResolutionAttachmentsTable,
        <String, Object?>{
          'project_id': projectId,
          'defect_id': defectId,
          'attachment_id': attachmentId,
          'sort_order': order++,
        },
      );
    }
  }

  Future<void> _replaceProtocolRelations(
    DatabaseExecutor executor, {
    required String projectId,
    required String protocolId,
    required Iterable<String> defectIds,
    required Iterable<String> attachmentIds,
  }) async {
    await executor.delete(
      AppDatabase.acceptanceProtocolDefectsTable,
      where: 'project_id = ? AND protocol_id = ?',
      whereArgs: <Object?>[projectId, protocolId],
    );
    await executor.delete(
      AppDatabase.acceptanceProtocolAttachmentsTable,
      where: 'project_id = ? AND protocol_id = ?',
      whereArgs: <Object?>[projectId, protocolId],
    );
    var order = 0;
    for (final defectId in defectIds) {
      await executor
          .insert(AppDatabase.acceptanceProtocolDefectsTable, <String, Object?>{
            'project_id': projectId,
            'protocol_id': protocolId,
            'defect_id': defectId,
            'sort_order': order++,
          });
    }
    order = 0;
    for (final attachmentId in attachmentIds) {
      await executor.insert(
        AppDatabase.acceptanceProtocolAttachmentsTable,
        <String, Object?>{
          'project_id': projectId,
          'protocol_id': protocolId,
          'attachment_id': attachmentId,
          'sort_order': order++,
        },
      );
    }
  }

  Future<void> _syncTechnicalDefectLinks(
    DatabaseExecutor executor, {
    required String projectId,
    required String defectId,
    required Iterable<String> reportAttachmentIds,
    required Iterable<String> resolutionAttachmentIds,
  }) async {
    await executor.delete(
      AppDatabase.technicalPhotoLinksTable,
      where: 'project_id = ? AND relation_type = ? AND target_id = ?',
      whereArgs: <Object?>[projectId, 'defect', defectId],
    );
    await _insertTechnicalLinksForAttachments(
      executor,
      projectId: projectId,
      relationType: 'defect',
      targetId: defectId,
      attachmentIds: <String>{
        ...reportAttachmentIds,
        ...resolutionAttachmentIds,
      },
    );
  }

  Future<void> _syncTechnicalProtocolLinks(
    DatabaseExecutor executor, {
    required String projectId,
    required String protocolId,
    required Iterable<String> defectIds,
  }) async {
    await executor.delete(
      AppDatabase.technicalPhotoLinksTable,
      where: 'project_id = ? AND relation_type = ? AND target_id = ?',
      whereArgs: <Object?>[projectId, 'acceptance_protocol', protocolId],
    );
    final ids = defectIds.toList(growable: false);
    if (ids.isEmpty) return;
    final rows = await executor.rawQuery(
      '''
        SELECT attachment_id
        FROM ${AppDatabase.journalEntryAttachmentsTable}
        WHERE project_id = ? AND journal_entry_id IN (${_placeholders(ids.length)})
        UNION
        SELECT attachment_id
        FROM ${AppDatabase.defectResolutionAttachmentsTable}
        WHERE project_id = ? AND defect_id IN (${_placeholders(ids.length)})
      ''',
      <Object?>[projectId, ...ids, projectId, ...ids],
    );
    await _insertTechnicalLinksForAttachments(
      executor,
      projectId: projectId,
      relationType: 'acceptance_protocol',
      targetId: protocolId,
      attachmentIds: rows.map((row) => row['attachment_id']! as String),
    );
  }

  Future<void> _insertTechnicalLinksForAttachments(
    DatabaseExecutor executor, {
    required String projectId,
    required String relationType,
    required String targetId,
    required Iterable<String> attachmentIds,
  }) async {
    final ids = attachmentIds.toSet().toList(growable: false);
    if (ids.isEmpty) return;
    final rows = await executor.query(
      AppDatabase.technicalPhotosTable,
      columns: const <String>['attachment_id'],
      where:
          'project_id = ? AND attachment_id IN (${_placeholders(ids.length)})',
      whereArgs: <Object?>[projectId, ...ids],
    );
    for (final row in rows) {
      await executor.insert(
        AppDatabase.technicalPhotoLinksTable,
        <String, Object?>{
          'project_id': projectId,
          'attachment_id': row['attachment_id'],
          'relation_type': relationType,
          'target_id': targetId,
          'created_at_utc_ms': _milliseconds(_utcNow().toUtc()),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}

Future<void> _requireActiveProject(
  DatabaseExecutor executor,
  String projectId,
) async {
  final rows = await executor.query(
    AppDatabase.projectsTable,
    columns: const <String>['id'],
    where: 'id = ? AND is_archived = 0 AND deletion_pending = 0',
    whereArgs: <Object?>[projectId],
    limit: 1,
  );
  if (rows.isEmpty) throw const PunchRelationNotFoundException();
}

Future<void> _requireOptionalTarget(
  DatabaseExecutor executor,
  String table,
  String projectId,
  String? targetId,
) async {
  if (targetId == null) return;
  final rows = await executor.query(
    table,
    columns: const <String>['id'],
    where: 'project_id = ? AND id = ?',
    whereArgs: <Object?>[projectId, targetId],
    limit: 1,
  );
  if (rows.isEmpty) throw const PunchRelationNotFoundException();
}

Future<void> _requireAttachments(
  DatabaseExecutor executor, {
  required String projectId,
  required Iterable<String> attachmentIds,
  required bool Function(String mediaType) accepts,
}) async {
  final ids = attachmentIds.toSet().toList(growable: false);
  if (ids.isEmpty) return;
  final rows = await executor.query(
    AppDatabase.costAttachmentsTable,
    columns: const <String>['id', 'media_type'],
    where:
        'project_id = ? AND availability = ? '
        'AND id IN (${_placeholders(ids.length)})',
    whereArgs: <Object?>[projectId, 'available', ...ids],
  );
  if (rows.length != ids.length ||
      rows.any((row) {
        final mediaType = row['media_type'] as String?;
        return mediaType == null || !accepts(mediaType.toLowerCase());
      })) {
    throw const PunchRelationNotFoundException();
  }
}

JournalEntryInput _journalInputWithStatus(
  JournalEntryInput input,
  JournalEntryStatus status,
) => JournalEntryInput(
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
  decisionMakerContactId: input.decisionMakerContactId,
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

({String sql, List<Object?> arguments}) _defectFilter(DefectQuery query) {
  final clauses = <String>['project_id = ?', "entry_type = 'defect'"];
  final arguments = <Object?>[query.projectId];
  if (query.searchText != null) {
    final pattern = _likePattern(query.searchText!);
    clauses.add(
      "(LOWER(title) LIKE ? ESCAPE '!' OR "
      "LOWER(COALESCE(body, '')) LIKE ? ESCAPE '!' OR "
      "LOWER(COALESCE(defect_room_label, '')) LIKE ? ESCAPE '!')",
    );
    arguments.addAll(<Object?>[pattern, pattern, pattern]);
  }
  if (query.statuses.isNotEmpty) {
    clauses.add('status IN (${_placeholders(query.statuses.length)})');
    arguments.addAll(query.statuses.map(_journalStatusToStorage));
  }
  if (query.severities.isNotEmpty) {
    clauses.add(
      'defect_severity IN (${_placeholders(query.severities.length)})',
    );
    arguments.addAll(query.severities.map((severity) => severity.name));
  }
  if (query.stageId != null) {
    clauses.add('stage_id = ?');
    arguments.add(query.stageId);
  }
  if (query.responsibleContactId != null) {
    clauses.add('responsible_contact_id = ?');
    arguments.add(query.responsibleContactId);
  }
  if (query.roomLabel != null) {
    clauses.add('LOWER(defect_room_label) = ?');
    arguments.add(query.roomLabel);
  }
  if (query.overdueOnly) {
    clauses.add("status <> 'closed'");
    clauses.add('due_at_utc_ms IS NOT NULL AND due_at_utc_ms < ?');
    arguments.add(_milliseconds(query.nowUtc));
  }
  return (sql: clauses.join(' AND '), arguments: arguments);
}

String _journalStatusToStorage(JournalEntryStatus value) => switch (value) {
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

String _protocolStatusToStorage(AcceptanceProtocolStatus value) =>
    switch (value) {
      AcceptanceProtocolStatus.draft => 'draft',
      AcceptanceProtocolStatus.finalized => 'finalized',
      AcceptanceProtocolStatus.signed => 'signed',
    };

AcceptanceProtocolStatus _protocolStatusFromStorage(String value) =>
    switch (value) {
      'draft' => AcceptanceProtocolStatus.draft,
      'finalized' => AcceptanceProtocolStatus.finalized,
      'signed' => AcceptanceProtocolStatus.signed,
      _ => throw StateError('Unknown acceptance protocol status'),
    };

String _placeholders(int count) => List<String>.filled(count, '?').join(', ');

String _likePattern(String value) {
  final escaped = value
      .toLowerCase()
      .replaceAll('!', '!!')
      .replaceAll('%', '!%')
      .replaceAll('_', '!_');
  return '%$escaped%';
}

int _milliseconds(DateTime value) =>
    DatabaseValueCodec.dateTimeToUtcMilliseconds(value);

DateTime _dateTime(Object value) =>
    DatabaseValueCodec.utcMillisecondsToDateTime(value as int);
