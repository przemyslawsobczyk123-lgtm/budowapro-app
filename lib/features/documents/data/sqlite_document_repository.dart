import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

typedef DocumentUtcNow = DateTime Function();

final class SqliteDocumentRepository implements DocumentRepository {
  factory SqliteDocumentRepository({
    required AppDatabase database,
    required DocumentUtcNow utcNow,
  }) => SqliteDocumentRepository._(database, utcNow);

  const SqliteDocumentRepository._(this._database, this._utcNow);

  static const Duration warrantyExpiringWindow = Duration(days: 30);

  final AppDatabase _database;
  final DocumentUtcNow _utcNow;

  @override
  Future<ProjectDocument?> findById({
    required String projectId,
    required String documentId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '$_documentSelect WHERE a.project_id = ? AND a.id = ? '
      "AND a.availability = 'available' LIMIT 1",
      <Object?>[projectId, documentId],
    );
    if (rows.isEmpty) return null;
    return (await _documentsFromRows(database, rows)).single;
  }

  @override
  Future<Page<ProjectDocument>> list(
    DocumentQuery query,
    PageRequest page,
  ) async {
    final database = await _database.open();
    final filter = _buildFilter(query, _utcNow().toUtc());
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total $_documentFrom WHERE ${filter.sql}',
      filter.arguments,
    );
    final rows = await database.rawQuery(
      '$_documentSelect WHERE ${filter.sql} '
      'ORDER BY ${_orderBy(query.sort)} LIMIT ? OFFSET ?',
      <Object?>[...filter.arguments, page.limit, page.offset],
    );
    return Page<ProjectDocument>(
      items: await _documentsFromRows(database, rows),
      totalCount: countRows.single['total']! as int,
      request: page,
    );
  }

  @override
  Future<DocumentFilterOptions> filterOptions({
    required String projectId,
  }) async {
    final database = await _database.open();
    final stageRows = await database.query(
      AppDatabase.projectStagesTable,
      columns: const <String>['id', 'template_stage_key', 'custom_name'],
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
      orderBy: 'sort_order ASC, id ASC',
    );
    final roomRows = await database.rawQuery(
      '''
        SELECT target_id, MIN(label) AS label
        FROM ${AppDatabase.documentContextLinksTable}
        WHERE project_id = ? AND relation_type = 'room'
        GROUP BY target_id
        ORDER BY LOWER(MIN(label)) ASC, target_id ASC
      ''',
      <Object?>[projectId],
    );
    return DocumentFilterOptions(
      stages: stageRows.map(
        (row) => DocumentFilterOption(
          id: row['id']! as String,
          label: (row['custom_name'] ?? row['template_stage_key'])! as String,
        ),
      ),
      rooms: roomRows.map(
        (row) => DocumentFilterOption(
          id: row['target_id']! as String,
          label: row['label']! as String,
        ),
      ),
    );
  }

  @override
  Future<ProjectDocument> updateMetadata({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
  }) {
    return _database.transaction<ProjectDocument>((transaction) async {
      await _requireDocument(
        transaction,
        projectId: projectId,
        documentId: documentId,
      );
      await _upsertMetadata(
        transaction,
        projectId: projectId,
        documentId: documentId,
        metadata: metadata,
      );
      return (await _findDocument(
        transaction,
        projectId: projectId,
        documentId: documentId,
      ))!;
    });
  }

  @override
  Future<ProjectDocument> replaceContextLinks({
    required String projectId,
    required String documentId,
    required Iterable<DocumentRelation> links,
  }) {
    return _database.transaction<ProjectDocument>((transaction) async {
      await _requireDocument(
        transaction,
        projectId: projectId,
        documentId: documentId,
      );
      await _replaceContextLinks(
        transaction,
        projectId: projectId,
        documentId: documentId,
        links: links,
      );
      return (await _findDocument(
        transaction,
        projectId: projectId,
        documentId: documentId,
      ))!;
    });
  }

  @override
  Future<ProjectDocument> saveDetails({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
    required Iterable<DocumentRelation> contextLinks,
  }) {
    return _database.transaction<ProjectDocument>((transaction) async {
      await _requireDocument(
        transaction,
        projectId: projectId,
        documentId: documentId,
      );
      await _upsertMetadata(
        transaction,
        projectId: projectId,
        documentId: documentId,
        metadata: metadata,
      );
      await _replaceContextLinks(
        transaction,
        projectId: projectId,
        documentId: documentId,
        links: contextLinks,
      );
      return (await _findDocument(
        transaction,
        projectId: projectId,
        documentId: documentId,
      ))!;
    });
  }

  @override
  Future<List<ProjectDocument>> findPotentialDuplicates({
    required String projectId,
    required String sha256,
    String? excludingDocumentId,
  }) async {
    final normalizedHash = sha256.trim().toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(normalizedHash)) {
      throw ArgumentError.value(sha256, 'sha256');
    }
    final database = await _database.open();
    final clauses = <String>[
      'a.project_id = ?',
      'a.sha256 = ?',
      "a.availability = 'available'",
    ];
    final arguments = <Object?>[projectId, normalizedHash];
    final excluded = excludingDocumentId?.trim();
    if (excluded != null && excluded.isNotEmpty) {
      clauses.add('a.id != ?');
      arguments.add(excluded);
    }
    final rows = await database.rawQuery(
      '$_documentSelect WHERE ${clauses.join(' AND ')} '
      'ORDER BY a.imported_at_utc_ms DESC, a.id ASC',
      arguments,
    );
    return _documentsFromRows(database, rows);
  }

  static Future<void> _requireDocument(
    DatabaseExecutor executor, {
    required String projectId,
    required String documentId,
  }) async {
    final rows = await executor.query(
      AppDatabase.costAttachmentsTable,
      columns: const <String>['id'],
      where: 'project_id = ? AND id = ? AND availability = ?',
      whereArgs: <Object?>[projectId, documentId, 'available'],
      limit: 1,
    );
    if (rows.isEmpty) throw const DocumentNotFoundException();
  }

  Future<void> _upsertMetadata(
    DatabaseExecutor executor, {
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
  }) async {
    await executor.rawInsert(
      '''
        INSERT INTO ${AppDatabase.documentMetadataTable} (
          project_id,
          attachment_id,
          title,
          document_type,
          description,
          document_date_utc_ms,
          warranty_starts_at_utc_ms,
          warranty_ends_at_utc_ms,
          warranty_reminder_at_utc_ms,
          updated_at_utc_ms
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(project_id, attachment_id) DO UPDATE SET
          title = excluded.title,
          document_type = excluded.document_type,
          description = excluded.description,
          document_date_utc_ms = excluded.document_date_utc_ms,
          warranty_starts_at_utc_ms = excluded.warranty_starts_at_utc_ms,
          warranty_ends_at_utc_ms = excluded.warranty_ends_at_utc_ms,
          warranty_reminder_at_utc_ms = excluded.warranty_reminder_at_utc_ms,
          updated_at_utc_ms = excluded.updated_at_utc_ms
      ''',
      <Object?>[
        projectId,
        documentId,
        metadata.title,
        metadata.type.name,
        metadata.description,
        _milliseconds(metadata.documentDateUtc),
        _milliseconds(metadata.warrantyStartsAtUtc),
        _milliseconds(metadata.warrantyEndsAtUtc),
        _milliseconds(metadata.warrantyReminderAtUtc),
        DatabaseValueCodec.dateTimeToUtcMilliseconds(_utcNow()),
      ],
    );
  }

  static Future<void> _replaceContextLinks(
    DatabaseExecutor executor, {
    required String projectId,
    required String documentId,
    required Iterable<DocumentRelation> links,
  }) async {
    final normalizedLinks = links.toList(growable: false);
    _requireUniqueContextLinks(normalizedLinks);
    await _validateContextLinks(
      executor,
      projectId: projectId,
      links: normalizedLinks,
    );
    await executor.delete(
      AppDatabase.documentContextLinksTable,
      where: 'project_id = ? AND attachment_id = ?',
      whereArgs: <Object?>[projectId, documentId],
    );
    for (var index = 0; index < normalizedLinks.length; index += 1) {
      final link = normalizedLinks[index];
      await executor.insert(
        AppDatabase.documentContextLinksTable,
        <String, Object?>{
          'project_id': projectId,
          'attachment_id': documentId,
          'relation_type': link.type.name,
          'target_id': link.targetId,
          'label': link.label,
          'sort_order': index,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  static Future<void> _validateContextLinks(
    DatabaseExecutor executor, {
    required String projectId,
    required List<DocumentRelation> links,
  }) async {
    for (final link in links) {
      switch (link.type) {
        case DocumentRelationType.stage:
          await _requireTarget(
            executor,
            table: AppDatabase.projectStagesTable,
            projectId: projectId,
            targetId: link.targetId,
          );
        case DocumentRelationType.contact:
          await _requireTarget(
            executor,
            table: AppDatabase.contactsTable,
            projectId: projectId,
            targetId: link.targetId,
          );
        case DocumentRelationType.room:
          break;
        case DocumentRelationType.cost:
        case DocumentRelationType.checklistItem:
        case DocumentRelationType.quote:
          throw ArgumentError.value(
            link.type,
            'links',
            'native feature links cannot be replaced from the document catalog',
          );
        case DocumentRelationType.decision:
        case DocumentRelationType.defect:
        case DocumentRelationType.device:
          throw ArgumentError.value(
            link.type,
            'links',
            'the target feature is not implemented yet',
          );
      }
    }
  }

  static Future<void> _requireTarget(
    DatabaseExecutor executor, {
    required String table,
    required String projectId,
    required String targetId,
  }) async {
    final rows = await executor.query(
      table,
      columns: const <String>['id'],
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, targetId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw ArgumentError.value(targetId, 'links', 'target does not exist');
    }
  }
}

const String _documentFrom =
    '''
  FROM ${AppDatabase.costAttachmentsTable} a
  LEFT JOIN ${AppDatabase.documentMetadataTable} m
    ON m.project_id = a.project_id AND m.attachment_id = a.id
''';

const String _documentSelect =
    '''
  SELECT
    a.*,
    COALESCE(m.title, a.display_name) AS document_title,
    COALESCE(m.document_type, 'other') AS document_type,
    m.description AS document_description,
    m.document_date_utc_ms AS document_date_utc_ms,
    m.warranty_starts_at_utc_ms AS warranty_starts_at_utc_ms,
    m.warranty_ends_at_utc_ms AS warranty_ends_at_utc_ms,
    m.warranty_reminder_at_utc_ms AS warranty_reminder_at_utc_ms
  $_documentFrom
''';

Future<ProjectDocument?> _findDocument(
  DatabaseExecutor executor, {
  required String projectId,
  required String documentId,
}) async {
  final rows = await executor.rawQuery(
    '$_documentSelect WHERE a.project_id = ? AND a.id = ? '
    "AND a.availability = 'available' LIMIT 1",
    <Object?>[projectId, documentId],
  );
  if (rows.isEmpty) return null;
  return (await _documentsFromRows(executor, rows)).single;
}

Future<List<ProjectDocument>> _documentsFromRows(
  DatabaseExecutor executor,
  List<Map<String, Object?>> rows,
) async {
  if (rows.isEmpty) return const <ProjectDocument>[];
  final projectId = rows.first['project_id']! as String;
  final documentIds = rows.map((row) => row['id']! as String).toList();
  final relations = await _loadRelations(
    executor,
    projectId: projectId,
    documentIds: documentIds,
  );
  return rows
      .map((row) {
        final documentId = row['id']! as String;
        final importedAt = DatabaseValueCodec.utcMillisecondsToDateTime(
          row['imported_at_utc_ms']! as int,
        );
        return ProjectDocument(
          id: documentId,
          projectId: projectId,
          displayName: row['display_name']! as String,
          metadata: DocumentMetadata(
            title: row['document_title']! as String,
            type: _documentTypeFromStorage(row['document_type']! as String),
            description: row['document_description'] as String?,
            documentDate: _dateTime(row['document_date_utc_ms']),
            warrantyStartsAt: _dateTime(row['warranty_starts_at_utc_ms']),
            warrantyEndsAt: _dateTime(row['warranty_ends_at_utc_ms']),
            warrantyReminderAt: _dateTime(row['warranty_reminder_at_utc_ms']),
          ),
          byteSize: row['byte_size']! as int,
          mediaType: row['media_type'] as String?,
          sha256: row['sha256'] as String?,
          hasPreview: row['preview_storage_key'] != null,
          importedAt: importedAt,
          relations: relations[documentId] ?? const <DocumentRelation>[],
        );
      })
      .toList(growable: false);
}

Future<Map<String, List<DocumentRelation>>> _loadRelations(
  DatabaseExecutor executor, {
  required String projectId,
  required List<String> documentIds,
}) async {
  final placeholders = List<String>.filled(documentIds.length, '?').join(', ');
  final arguments = <Object?>[projectId, ...documentIds];
  final rows = await executor.rawQuery(
    '''
      SELECT attachment_id, relation_type, target_id, label
      FROM (
        SELECT
          l.attachment_id,
          'cost' AS relation_type,
          l.cost_entry_id AS target_id,
          c.name AS label
        FROM ${AppDatabase.costEntryAttachmentsTable} l
        INNER JOIN ${AppDatabase.costEntriesTable} c
          ON c.project_id = l.project_id AND c.id = l.cost_entry_id
        WHERE l.project_id = ? AND l.attachment_id IN ($placeholders)

        UNION ALL

        SELECT
          l.attachment_id,
          'checklistItem' AS relation_type,
          l.checklist_item_id AS target_id,
          COALESCE(i.custom_title, i.template_item_key) AS label
        FROM ${AppDatabase.checklistItemAttachmentsTable} l
        INNER JOIN ${AppDatabase.checklistItemsTable} i
          ON i.project_id = l.project_id AND i.id = l.checklist_item_id
        WHERE l.project_id = ? AND l.attachment_id IN ($placeholders)

        UNION ALL

        SELECT
          l.attachment_id,
          'quote' AS relation_type,
          l.quote_id AS target_id,
          q.title AS label
        FROM ${AppDatabase.quoteAttachmentsTable} l
        INNER JOIN ${AppDatabase.contractorQuotesTable} q
          ON q.project_id = l.project_id AND q.id = l.quote_id
        WHERE l.project_id = ? AND l.attachment_id IN ($placeholders)

        UNION ALL

        SELECT attachment_id, relation_type, target_id, label
        FROM ${AppDatabase.documentContextLinksTable}
        WHERE project_id = ? AND attachment_id IN ($placeholders)
      ) relations
      ORDER BY attachment_id ASC, relation_type ASC, target_id ASC
    ''',
    <Object?>[...arguments, ...arguments, ...arguments, ...arguments],
  );
  final byDocument = <String, List<DocumentRelation>>{};
  for (final row in rows) {
    byDocument
        .putIfAbsent(
          row['attachment_id']! as String,
          () => <DocumentRelation>[],
        )
        .add(
          DocumentRelation(
            type: _relationTypeFromStorage(row['relation_type']! as String),
            targetId: row['target_id']! as String,
            label: row['label']! as String,
          ),
        );
  }
  return byDocument;
}

_DocumentFilter _buildFilter(DocumentQuery query, DateTime nowUtc) {
  final clauses = <String>['a.project_id = ?', "a.availability = 'available'"];
  final arguments = <Object?>[query.projectId];
  final search = query.searchText;
  if (search != null) {
    final pattern = _likePattern(search);
    clauses.add(
      "(LOWER(COALESCE(m.title, a.display_name)) LIKE ? ESCAPE '\\' "
      "OR LOWER(COALESCE(m.description, '')) LIKE ? ESCAPE '\\' "
      "OR LOWER(a.display_name) LIKE ? ESCAPE '\\')",
    );
    arguments.addAll(<Object?>[pattern, pattern, pattern]);
  }
  if (query.types.isNotEmpty) {
    final values = query.types.map((value) => value.name).toList()..sort();
    clauses.add(
      "COALESCE(m.document_type, 'other') IN (${_placeholders(values.length)})",
    );
    arguments.addAll(values);
  }
  if (query.stageIds.isNotEmpty) {
    final values = query.stageIds.toList()..sort();
    final placeholders = _placeholders(values.length);
    clauses.add('''
      (
        EXISTS (
          SELECT 1 FROM ${AppDatabase.documentContextLinksTable} dl
          WHERE dl.project_id = a.project_id
            AND dl.attachment_id = a.id
            AND dl.relation_type = 'stage'
            AND dl.target_id IN ($placeholders)
        )
        OR EXISTS (
          SELECT 1
          FROM ${AppDatabase.costEntryAttachmentsTable} al
          INNER JOIN ${AppDatabase.costEntriesTable} c
            ON c.project_id = al.project_id AND c.id = al.cost_entry_id
          WHERE al.project_id = a.project_id
            AND al.attachment_id = a.id
            AND c.stage_id IN ($placeholders)
        )
        OR EXISTS (
          SELECT 1
          FROM ${AppDatabase.checklistItemAttachmentsTable} al
          INNER JOIN ${AppDatabase.checklistItemsTable} i
            ON i.project_id = al.project_id AND i.id = al.checklist_item_id
          WHERE al.project_id = a.project_id
            AND al.attachment_id = a.id
            AND i.stage_id IN ($placeholders)
        )
        OR EXISTS (
          SELECT 1
          FROM ${AppDatabase.quoteAttachmentsTable} al
          INNER JOIN ${AppDatabase.contractorQuotesTable} q
            ON q.project_id = al.project_id AND q.id = al.quote_id
          WHERE al.project_id = a.project_id
            AND al.attachment_id = a.id
            AND q.stage_id IN ($placeholders)
        )
      )
    ''');
    arguments.addAll(<Object?>[...values, ...values, ...values, ...values]);
  }
  if (query.roomIds.isNotEmpty) {
    final values = query.roomIds.toList()..sort();
    clauses.add('''
      EXISTS (
        SELECT 1 FROM ${AppDatabase.documentContextLinksTable} dl
        WHERE dl.project_id = a.project_id
          AND dl.attachment_id = a.id
          AND dl.relation_type = 'room'
          AND dl.target_id IN (${_placeholders(values.length)})
      )
    ''');
    arguments.addAll(values);
  }
  if (query.fromInclusiveUtc != null) {
    clauses.add('COALESCE(m.document_date_utc_ms, a.imported_at_utc_ms) >= ?');
    arguments.add(_milliseconds(query.fromInclusiveUtc));
  }
  if (query.toExclusiveUtc != null) {
    clauses.add('COALESCE(m.document_date_utc_ms, a.imported_at_utc_ms) < ?');
    arguments.add(_milliseconds(query.toExclusiveUtc));
  }
  if (query.warrantyStates.isNotEmpty) {
    final now = DatabaseValueCodec.dateTimeToUtcMilliseconds(nowUtc);
    final expiring = DatabaseValueCodec.dateTimeToUtcMilliseconds(
      nowUtc.add(SqliteDocumentRepository.warrantyExpiringWindow),
    );
    final stateClauses = <String>[];
    for (final state in query.warrantyStates) {
      switch (state) {
        case DocumentWarrantyState.withoutWarranty:
          stateClauses.add('m.warranty_ends_at_utc_ms IS NULL');
        case DocumentWarrantyState.active:
          stateClauses.add('m.warranty_ends_at_utc_ms > ?');
          arguments.add(expiring);
        case DocumentWarrantyState.expiringSoon:
          stateClauses.add(
            '(m.warranty_ends_at_utc_ms >= ? '
            'AND m.warranty_ends_at_utc_ms <= ?)',
          );
          arguments.addAll(<Object?>[now, expiring]);
        case DocumentWarrantyState.expired:
          stateClauses.add('m.warranty_ends_at_utc_ms < ?');
          arguments.add(now);
      }
    }
    clauses.add('(${stateClauses.join(' OR ')})');
  }
  return _DocumentFilter(sql: clauses.join(' AND '), arguments: arguments);
}

String _orderBy(DocumentSort sort) => switch (sort) {
  DocumentSort.newest =>
    'COALESCE(m.document_date_utc_ms, a.imported_at_utc_ms) DESC, a.id ASC',
  DocumentSort.oldest =>
    'COALESCE(m.document_date_utc_ms, a.imported_at_utc_ms) ASC, a.id ASC',
  DocumentSort.nameAscending =>
    'LOWER(COALESCE(m.title, a.display_name)) ASC, a.id ASC',
};

void _requireUniqueContextLinks(List<DocumentRelation> links) {
  final keys = links
      .map((link) => '${link.type.name}:${link.targetId}')
      .toSet();
  if (keys.length != links.length) {
    throw ArgumentError.value(links, 'links', 'contains duplicates');
  }
}

String _placeholders(int count) => List<String>.filled(count, '?').join(', ');

String _likePattern(String value) {
  final escaped = value
      .toLowerCase()
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
  return '%$escaped%';
}

int? _milliseconds(DateTime? value) =>
    value == null ? null : DatabaseValueCodec.dateTimeToUtcMilliseconds(value);

DateTime? _dateTime(Object? value) => value == null
    ? null
    : DatabaseValueCodec.utcMillisecondsToDateTime(value as int);

ProjectDocumentType _documentTypeFromStorage(String value) =>
    ProjectDocumentType.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => throw const FormatException('Unsupported document type'),
    );

DocumentRelationType _relationTypeFromStorage(String value) =>
    DocumentRelationType.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => throw const FormatException('Unsupported relation type'),
    );

final class _DocumentFilter {
  const _DocumentFilter({required this.sql, required this.arguments});

  final String sql;
  final List<Object?> arguments;
}
