import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

typedef TechnicalPhotoIdGenerator = String Function();
typedef TechnicalPhotoUtcNow = DateTime Function();

final class SqliteTechnicalPhotoRepository implements TechnicalPhotoRepository {
  factory SqliteTechnicalPhotoRepository({
    required AppDatabase database,
    required SqliteDocumentRepository documentRepository,
    required TechnicalPhotoIdGenerator idGenerator,
    required TechnicalPhotoUtcNow utcNow,
  }) => SqliteTechnicalPhotoRepository._(
    database,
    documentRepository,
    idGenerator,
    utcNow,
  );

  const SqliteTechnicalPhotoRepository._(
    this._database,
    this._documentRepository,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final SqliteDocumentRepository _documentRepository;
  final TechnicalPhotoIdGenerator _idGenerator;
  final TechnicalPhotoUtcNow _utcNow;

  @override
  Future<List<TechnicalAlbumOverview>> listAlbums({
    required String projectId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '''
        SELECT
          al.*,
          COUNT(CASE WHEN a.availability = 'available' THEN 1 END) AS photo_count
        FROM ${AppDatabase.technicalAlbumsTable} al
        LEFT JOIN ${AppDatabase.technicalPhotosTable} p
          ON p.project_id = al.project_id AND p.album_id = al.id
        LEFT JOIN ${AppDatabase.costAttachmentsTable} a
          ON a.project_id = p.project_id AND a.id = p.attachment_id
        WHERE al.project_id = ?
        GROUP BY al.project_id, al.id
        ORDER BY al.updated_at_utc_ms DESC, LOWER(al.title) ASC, al.id ASC
      ''',
      <Object?>[projectId],
    );
    return rows
        .map(
          (row) => TechnicalAlbumOverview(
            album: _albumFromRow(row),
            photoCount: row['photo_count']! as int,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<TechnicalAlbum> createAlbum(TechnicalAlbumInput input) {
    return _database.transaction<TechnicalAlbum>((transaction) async {
      await _requireActiveProject(transaction, input.projectId);
      await _requireOptionalTarget(
        transaction,
        table: AppDatabase.projectStagesTable,
        projectId: input.projectId,
        targetId: input.stageId,
        argumentName: 'stageId',
      );
      final now = _utcNow().toUtc();
      final id = _idGenerator();
      await transaction.insert(
        AppDatabase.technicalAlbumsTable,
        <String, Object?>{
          'project_id': input.projectId,
          'id': id,
          'title': input.title,
          'album_kind': input.kind.name,
          'stage_id': input.stageId,
          'description': input.description,
          'created_at_utc_ms': _milliseconds(now),
          'updated_at_utc_ms': _milliseconds(now),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return (await _findAlbum(
        transaction,
        projectId: input.projectId,
        albumId: id,
      ))!;
    });
  }

  @override
  Future<TechnicalAlbum> updateAlbum({
    required String projectId,
    required String albumId,
    required TechnicalAlbumInput input,
  }) {
    if (input.projectId != projectId) {
      throw ArgumentError.value(input.projectId, 'input.projectId');
    }
    return _database.transaction<TechnicalAlbum>((transaction) async {
      if (await _findAlbum(
            transaction,
            projectId: projectId,
            albumId: albumId,
          ) ==
          null) {
        throw const TechnicalAlbumNotFoundException();
      }
      await _requireOptionalTarget(
        transaction,
        table: AppDatabase.projectStagesTable,
        projectId: projectId,
        targetId: input.stageId,
        argumentName: 'stageId',
      );
      await transaction.update(
        AppDatabase.technicalAlbumsTable,
        <String, Object?>{
          'title': input.title,
          'album_kind': input.kind.name,
          'stage_id': input.stageId,
          'description': input.description,
          'updated_at_utc_ms': _milliseconds(_utcNow().toUtc()),
        },
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, albumId],
      );
      return (await _findAlbum(
        transaction,
        projectId: projectId,
        albumId: albumId,
      ))!;
    });
  }

  @override
  Future<TechnicalPhoto?> findPhotoById({
    required String projectId,
    required String attachmentId,
  }) async {
    final database = await _database.open();
    return _findPhoto(
      database,
      projectId: projectId,
      attachmentId: attachmentId,
    );
  }

  @override
  Future<Page<TechnicalPhoto>> listPhotos(
    TechnicalPhotoQuery query,
    PageRequest page,
  ) async {
    final database = await _database.open();
    final filter = _buildFilter(query);
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total $_photoFrom WHERE ${filter.sql}',
      filter.arguments,
    );
    final rows = await database.rawQuery(
      '$_photoSelect WHERE ${filter.sql} '
      'ORDER BY p.captured_at_utc_ms DESC, p.attachment_id ASC '
      'LIMIT ? OFFSET ?',
      <Object?>[...filter.arguments, page.limit, page.offset],
    );
    return Page<TechnicalPhoto>(
      items: await _photosFromRows(database, rows),
      totalCount: countRows.single['total']! as int,
      request: page,
    );
  }

  @override
  Future<TechnicalPhoto> createPhoto(TechnicalPhotoInput input) {
    return _savePhoto(input, requireExisting: false);
  }

  @override
  Future<TechnicalPhoto> updatePhoto(TechnicalPhotoInput input) {
    return _savePhoto(input, requireExisting: true);
  }

  Future<TechnicalPhoto> _savePhoto(
    TechnicalPhotoInput input, {
    required bool requireExisting,
  }) {
    return _database.transaction<TechnicalPhoto>((transaction) async {
      await _requireActiveProject(transaction, input.projectId);
      final currentRows = await transaction.query(
        AppDatabase.technicalPhotosTable,
        columns: const <String>['checklist_item_id', 'created_at_utc_ms'],
        where: 'project_id = ? AND attachment_id = ?',
        whereArgs: <Object?>[input.projectId, input.attachmentId],
        limit: 1,
      );
      if (requireExisting && currentRows.isEmpty) {
        throw const TechnicalPhotoNotFoundException();
      }
      if (!requireExisting && currentRows.isNotEmpty) {
        throw const TechnicalPhotoConflictException();
      }
      final attachment = await _requireImageAttachment(
        transaction,
        projectId: input.projectId,
        attachmentId: input.attachmentId,
      );
      final album = await _findAlbum(
        transaction,
        projectId: input.projectId,
        albumId: input.albumId,
      );
      if (album == null) throw const TechnicalAlbumNotFoundException();
      var stageId = input.stageId ?? album.stageId;
      if (input.stageId != null &&
          album.stageId != null &&
          input.stageId != album.stageId) {
        throw ArgumentError.value(
          input.stageId,
          'stageId',
          'must match the selected album stage',
        );
      }
      final checklistStageId = await _checklistStageId(
        transaction,
        projectId: input.projectId,
        checklistItemId: input.checklistItemId,
      );
      stageId ??= checklistStageId;
      if (stageId != null &&
          checklistStageId != null &&
          checklistStageId != stageId) {
        throw ArgumentError.value(
          input.checklistItemId,
          'checklistItemId',
          'must belong to the selected stage',
        );
      }
      await _requireOptionalTarget(
        transaction,
        table: AppDatabase.projectStagesTable,
        projectId: input.projectId,
        targetId: stageId,
        argumentName: 'stageId',
      );
      await _requireOptionalTarget(
        transaction,
        table: AppDatabase.contactsTable,
        projectId: input.projectId,
        targetId: input.contractorContactId,
        argumentName: 'contractorContactId',
      );
      await _validateLinks(transaction, input);

      await _documentRepository.saveDetailsInTransaction(
        transaction,
        projectId: input.projectId,
        documentId: input.attachmentId,
        metadata: DocumentMetadata(
          title: input.title,
          type: ProjectDocumentType.photo,
          description: input.description,
          documentDate: input.capturedAtUtc,
        ),
        contextLinks: await _documentContextLinks(
          transaction,
          projectId: input.projectId,
          attachmentId: input.attachmentId,
          stageId: stageId,
          contactId: input.contractorContactId,
        ),
      );

      final now = _utcNow().toUtc();
      final createdAt = currentRows.isEmpty
          ? now
          : _dateTime(currentRows.single['created_at_utc_ms']!);
      final values = <String, Object?>{
        'project_id': input.projectId,
        'attachment_id': input.attachmentId,
        'album_id': input.albumId,
        'title': input.title,
        'captured_at_utc_ms': _milliseconds(input.capturedAtUtc),
        'installation_type': input.installationType.name,
        'stage_id': stageId,
        'zone_label': input.zoneLabel,
        'contractor_contact_id': input.contractorContactId,
        'checklist_item_id': input.checklistItemId,
        'description': input.description,
        'created_at_utc_ms': _milliseconds(createdAt),
        'updated_at_utc_ms': _milliseconds(now),
      };
      if (currentRows.isEmpty) {
        await transaction.insert(
          AppDatabase.technicalPhotosTable,
          values,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } else {
        await transaction.update(
          AppDatabase.technicalPhotosTable,
          values,
          where: 'project_id = ? AND attachment_id = ?',
          whereArgs: <Object?>[input.projectId, input.attachmentId],
        );
      }
      await _replaceTags(transaction, input);
      await _replaceLinks(transaction, input, createdAt: now);
      await _replaceChecklistEvidence(
        transaction,
        projectId: input.projectId,
        attachmentId: input.attachmentId,
        previousChecklistItemId: currentRows.isEmpty
            ? null
            : currentRows.single['checklist_item_id'] as String?,
        checklistItemId: input.checklistItemId,
      );

      return TechnicalPhoto(
        attachmentId: input.attachmentId,
        projectId: input.projectId,
        albumId: input.albumId,
        title: input.title,
        capturedAt: input.capturedAtUtc,
        installationType: input.installationType,
        stageId: stageId,
        zoneLabel: input.zoneLabel,
        contractorContactId: input.contractorContactId,
        checklistItemId: input.checklistItemId,
        description: input.description,
        tags: input.tags,
        links: input.links,
        displayName: attachment['display_name']! as String,
        mediaType: attachment['media_type']! as String,
        hasPreview: attachment['preview_storage_key'] != null,
        importedAt: _dateTime(attachment['imported_at_utc_ms']!),
      );
    });
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
  if (rows.isEmpty) {
    throw ArgumentError.value(projectId, 'projectId', 'project is unavailable');
  }
}

Future<void> _requireOptionalTarget(
  DatabaseExecutor executor, {
  required String table,
  required String projectId,
  required String? targetId,
  required String argumentName,
}) async {
  if (targetId == null) return;
  final rows = await executor.query(
    table,
    columns: const <String>['id'],
    where: 'project_id = ? AND id = ?',
    whereArgs: <Object?>[projectId, targetId],
    limit: 1,
  );
  if (rows.isEmpty) {
    throw ArgumentError.value(targetId, argumentName, 'target does not exist');
  }
}

Future<Map<String, Object?>> _requireImageAttachment(
  DatabaseExecutor executor, {
  required String projectId,
  required String attachmentId,
}) async {
  final rows = await executor.query(
    AppDatabase.costAttachmentsTable,
    columns: const <String>[
      'display_name',
      'media_type',
      'preview_storage_key',
      'imported_at_utc_ms',
    ],
    where: 'project_id = ? AND id = ? AND availability = ?',
    whereArgs: <Object?>[projectId, attachmentId, 'available'],
    limit: 1,
  );
  if (rows.isEmpty) throw const TechnicalPhotoNotFoundException();
  final mediaType = rows.single['media_type'] as String?;
  if (mediaType == null || !mediaType.toLowerCase().startsWith('image/')) {
    throw ArgumentError.value(mediaType, 'attachmentId', 'must be an image');
  }
  return rows.single;
}

Future<String?> _checklistStageId(
  DatabaseExecutor executor, {
  required String projectId,
  required String? checklistItemId,
}) async {
  if (checklistItemId == null) return null;
  final rows = await executor.query(
    AppDatabase.checklistItemsTable,
    columns: const <String>['stage_id'],
    where: 'project_id = ? AND id = ?',
    whereArgs: <Object?>[projectId, checklistItemId],
    limit: 1,
  );
  if (rows.isEmpty) {
    throw ArgumentError.value(
      checklistItemId,
      'checklistItemId',
      'target does not exist',
    );
  }
  return rows.single['stage_id']! as String;
}

Future<List<DocumentRelation>> _documentContextLinks(
  DatabaseExecutor executor, {
  required String projectId,
  required String attachmentId,
  required String? stageId,
  required String? contactId,
}) async {
  final links = <DocumentRelation>[];
  final preservedRows = await executor.query(
    AppDatabase.documentContextLinksTable,
    columns: const <String>['relation_type', 'target_id', 'label'],
    where:
        'project_id = ? AND attachment_id = ? '
        "AND relation_type NOT IN ('stage', 'contact')",
    whereArgs: <Object?>[projectId, attachmentId],
    orderBy: 'sort_order ASC',
  );
  for (final row in preservedRows) {
    links.add(
      DocumentRelation(
        type: DocumentRelationType.values.firstWhere(
          (type) => type.name == row['relation_type'],
        ),
        targetId: row['target_id']! as String,
        label: row['label']! as String,
      ),
    );
  }
  if (stageId != null) {
    final rows = await executor.query(
      AppDatabase.projectStagesTable,
      columns: const <String>['template_stage_key', 'custom_name'],
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, stageId],
      limit: 1,
    );
    links.add(
      DocumentRelation(
        type: DocumentRelationType.stage,
        targetId: stageId,
        label:
            (rows.single['custom_name'] ?? rows.single['template_stage_key'])!
                as String,
      ),
    );
  }
  if (contactId != null) {
    final rows = await executor.query(
      AppDatabase.contactsTable,
      columns: const <String>['display_name'],
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, contactId],
      limit: 1,
    );
    links.add(
      DocumentRelation(
        type: DocumentRelationType.contact,
        targetId: contactId,
        label: rows.single['display_name']! as String,
      ),
    );
  }
  return links;
}

Future<void> _replaceTags(
  DatabaseExecutor executor,
  TechnicalPhotoInput input,
) async {
  await executor.delete(
    AppDatabase.technicalPhotoTagsTable,
    where: 'project_id = ? AND attachment_id = ?',
    whereArgs: <Object?>[input.projectId, input.attachmentId],
  );
  for (final tag in input.tags) {
    await executor.insert(
      AppDatabase.technicalPhotoTagsTable,
      <String, Object?>{
        'project_id': input.projectId,
        'attachment_id': input.attachmentId,
        'tag': tag,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}

Future<void> _validateLinks(
  DatabaseExecutor executor,
  TechnicalPhotoInput input,
) async {
  for (final link in input.links) {
    final rows = switch (link.type) {
      TechnicalPhotoLinkType.cost => await executor.query(
        AppDatabase.costEntriesTable,
        columns: const <String>['id'],
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[input.projectId, link.targetId],
        limit: 1,
      ),
      TechnicalPhotoLinkType.decision => await executor.query(
        AppDatabase.journalEntriesTable,
        columns: const <String>['id'],
        where:
            'project_id = ? AND id = ? '
            "AND entry_type IN ('decision', 'scope_change')",
        whereArgs: <Object?>[input.projectId, link.targetId],
        limit: 1,
      ),
      TechnicalPhotoLinkType.defect => await executor.query(
        AppDatabase.journalEntriesTable,
        columns: const <String>['id'],
        where: 'project_id = ? AND id = ? AND entry_type = ?',
        whereArgs: <Object?>[input.projectId, link.targetId, 'defect'],
        limit: 1,
      ),
      TechnicalPhotoLinkType.acceptanceProtocol => await executor.query(
        AppDatabase.acceptanceProtocolsTable,
        columns: const <String>['id'],
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[input.projectId, link.targetId],
        limit: 1,
      ),
    };
    if (rows.isEmpty) {
      throw ArgumentError.value(
        link.targetId,
        'links',
        'target does not exist in the project',
      );
    }
  }
}

Future<void> _replaceLinks(
  DatabaseExecutor executor,
  TechnicalPhotoInput input, {
  required DateTime createdAt,
}) async {
  await executor.delete(
    AppDatabase.technicalPhotoLinksTable,
    where: 'project_id = ? AND attachment_id = ?',
    whereArgs: <Object?>[input.projectId, input.attachmentId],
  );
  final createdAtMilliseconds = _milliseconds(createdAt.toUtc());
  for (final link in input.links) {
    await executor.insert(
      AppDatabase.technicalPhotoLinksTable,
      <String, Object?>{
        'project_id': input.projectId,
        'attachment_id': input.attachmentId,
        'relation_type': _linkTypeToStorage(link.type),
        'target_id': link.targetId,
        'created_at_utc_ms': createdAtMilliseconds,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}

Future<void> _replaceChecklistEvidence(
  DatabaseExecutor executor, {
  required String projectId,
  required String attachmentId,
  required String? previousChecklistItemId,
  required String? checklistItemId,
}) async {
  if (previousChecklistItemId != null &&
      previousChecklistItemId != checklistItemId) {
    await executor.delete(
      AppDatabase.checklistItemAttachmentsTable,
      where: 'project_id = ? AND checklist_item_id = ? AND attachment_id = ?',
      whereArgs: <Object?>[projectId, previousChecklistItemId, attachmentId],
    );
  }
  if (checklistItemId == null) return;
  final existing = await executor.query(
    AppDatabase.checklistItemAttachmentsTable,
    columns: const <String>['attachment_id'],
    where: 'project_id = ? AND checklist_item_id = ? AND attachment_id = ?',
    whereArgs: <Object?>[projectId, checklistItemId, attachmentId],
    limit: 1,
  );
  if (existing.isNotEmpty) return;
  final orderRows = await executor.rawQuery(
    '''
      SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order
      FROM ${AppDatabase.checklistItemAttachmentsTable}
      WHERE project_id = ? AND checklist_item_id = ?
    ''',
    <Object?>[projectId, checklistItemId],
  );
  await executor.insert(
    AppDatabase.checklistItemAttachmentsTable,
    <String, Object?>{
      'project_id': projectId,
      'checklist_item_id': checklistItemId,
      'attachment_id': attachmentId,
      'sort_order': orderRows.single['next_order']! as int,
    },
    conflictAlgorithm: ConflictAlgorithm.abort,
  );
}

Future<TechnicalAlbum?> _findAlbum(
  DatabaseExecutor executor, {
  required String projectId,
  required String albumId,
}) async {
  final rows = await executor.query(
    AppDatabase.technicalAlbumsTable,
    where: 'project_id = ? AND id = ?',
    whereArgs: <Object?>[projectId, albumId],
    limit: 1,
  );
  return rows.isEmpty ? null : _albumFromRow(rows.single);
}

TechnicalAlbum _albumFromRow(Map<String, Object?> row) => TechnicalAlbum(
  id: row['id']! as String,
  projectId: row['project_id']! as String,
  title: row['title']! as String,
  kind: TechnicalAlbumKind.values.firstWhere(
    (kind) => kind.name == row['album_kind'],
  ),
  stageId: row['stage_id'] as String?,
  description: row['description'] as String?,
  createdAt: _dateTime(row['created_at_utc_ms']!),
  updatedAt: _dateTime(row['updated_at_utc_ms']!),
);

Future<TechnicalPhoto?> _findPhoto(
  DatabaseExecutor executor, {
  required String projectId,
  required String attachmentId,
}) async {
  final rows = await executor.rawQuery(
    '$_photoSelect WHERE p.project_id = ? AND p.attachment_id = ? '
    "AND a.availability = 'available' LIMIT 1",
    <Object?>[projectId, attachmentId],
  );
  if (rows.isEmpty) return null;
  return (await _photosFromRows(executor, rows)).single;
}

Future<List<TechnicalPhoto>> _photosFromRows(
  DatabaseExecutor executor,
  List<Map<String, Object?>> rows,
) async {
  if (rows.isEmpty) return const <TechnicalPhoto>[];
  final ids = rows.map((row) => row['attachment_id']! as String).toList();
  final tagRows = await executor.query(
    AppDatabase.technicalPhotoTagsTable,
    columns: const <String>['attachment_id', 'tag'],
    where: 'project_id = ? AND attachment_id IN (${_placeholders(ids.length)})',
    whereArgs: <Object?>[rows.first['project_id'], ...ids],
    orderBy: 'attachment_id ASC, tag ASC',
  );
  final tagsByPhoto = <String, List<String>>{};
  for (final row in tagRows) {
    tagsByPhoto
        .putIfAbsent(row['attachment_id']! as String, () => <String>[])
        .add(row['tag']! as String);
  }
  final linkRows = await executor.query(
    AppDatabase.technicalPhotoLinksTable,
    columns: const <String>['attachment_id', 'relation_type', 'target_id'],
    where: 'project_id = ? AND attachment_id IN (${_placeholders(ids.length)})',
    whereArgs: <Object?>[rows.first['project_id'], ...ids],
    orderBy: 'attachment_id ASC, relation_type ASC, target_id ASC',
  );
  final linksByPhoto = <String, List<TechnicalPhotoLink>>{};
  for (final row in linkRows) {
    (linksByPhoto[row['attachment_id']! as String] ??= <TechnicalPhotoLink>[])
        .add(
          TechnicalPhotoLink(
            type: _linkTypeFromStorage(row['relation_type']! as String),
            targetId: row['target_id']! as String,
          ),
        );
  }
  return rows
      .map(
        (row) => TechnicalPhoto(
          attachmentId: row['attachment_id']! as String,
          projectId: row['project_id']! as String,
          albumId: row['album_id']! as String,
          title: row['title']! as String,
          capturedAt: _dateTime(row['captured_at_utc_ms']!),
          installationType: TechnicalInstallationType.values.firstWhere(
            (type) => type.name == row['installation_type'],
          ),
          stageId: row['stage_id'] as String?,
          zoneLabel: row['zone_label'] as String?,
          contractorContactId: row['contractor_contact_id'] as String?,
          checklistItemId: row['checklist_item_id'] as String?,
          description: row['description'] as String?,
          tags: tagsByPhoto[row['attachment_id']] ?? const <String>[],
          links:
              linksByPhoto[row['attachment_id']] ??
              const <TechnicalPhotoLink>[],
          displayName: row['display_name']! as String,
          mediaType: row['media_type']! as String,
          hasPreview: row['preview_storage_key'] != null,
          importedAt: _dateTime(row['imported_at_utc_ms']!),
        ),
      )
      .toList(growable: false);
}

_TechnicalPhotoFilter _buildFilter(TechnicalPhotoQuery query) {
  final clauses = <String>['p.project_id = ?', "a.availability = 'available'"];
  final arguments = <Object?>[query.projectId];
  final search = query.searchText;
  if (search != null) {
    final pattern = _likePattern(search);
    clauses.add('''
      (
        LOWER(p.title) LIKE ? ESCAPE '!'
        OR LOWER(COALESCE(p.description, '')) LIKE ? ESCAPE '!'
        OR LOWER(COALESCE(p.zone_label, '')) LIKE ? ESCAPE '!'
        OR EXISTS (
          SELECT 1 FROM ${AppDatabase.technicalPhotoTagsTable} search_tags
          WHERE search_tags.project_id = p.project_id
            AND search_tags.attachment_id = p.attachment_id
            AND LOWER(search_tags.tag) LIKE ? ESCAPE '!'
        )
      )
    ''');
    arguments.addAll(<Object?>[pattern, pattern, pattern, pattern]);
  }
  _addValuesFilter(clauses, arguments, 'p.album_id', query.albumIds);
  _addValuesFilter(clauses, arguments, 'p.stage_id', query.stageIds);
  _addValuesFilter(
    clauses,
    arguments,
    'p.installation_type',
    query.installationTypes.map((type) => type.name),
  );
  if (query.tags.isNotEmpty) {
    final values = query.tags.toList()..sort();
    clauses.add('''
      EXISTS (
        SELECT 1 FROM ${AppDatabase.technicalPhotoTagsTable} filter_tags
        WHERE filter_tags.project_id = p.project_id
          AND filter_tags.attachment_id = p.attachment_id
          AND filter_tags.tag IN (${_placeholders(values.length)})
      )
    ''');
    arguments.addAll(values);
  }
  if (query.fromInclusiveUtc != null) {
    clauses.add('p.captured_at_utc_ms >= ?');
    arguments.add(_milliseconds(query.fromInclusiveUtc!));
  }
  if (query.toExclusiveUtc != null) {
    clauses.add('p.captured_at_utc_ms < ?');
    arguments.add(_milliseconds(query.toExclusiveUtc!));
  }
  return _TechnicalPhotoFilter(
    sql: clauses.join(' AND '),
    arguments: arguments,
  );
}

void _addValuesFilter(
  List<String> clauses,
  List<Object?> arguments,
  String column,
  Iterable<String> source,
) {
  final values = source.toSet().toList()..sort();
  if (values.isEmpty) return;
  clauses.add('$column IN (${_placeholders(values.length)})');
  arguments.addAll(values);
}

const String _photoFrom =
    '''
  FROM ${AppDatabase.technicalPhotosTable} p
  INNER JOIN ${AppDatabase.costAttachmentsTable} a
    ON a.project_id = p.project_id AND a.id = p.attachment_id
''';

const String _photoSelect =
    '''
  SELECT
    p.*,
    a.display_name,
    a.media_type,
    a.preview_storage_key,
    a.imported_at_utc_ms
  $_photoFrom
''';

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

String _linkTypeToStorage(TechnicalPhotoLinkType value) => switch (value) {
  TechnicalPhotoLinkType.cost => 'cost',
  TechnicalPhotoLinkType.decision => 'decision',
  TechnicalPhotoLinkType.defect => 'defect',
  TechnicalPhotoLinkType.acceptanceProtocol => 'acceptance_protocol',
};

TechnicalPhotoLinkType _linkTypeFromStorage(String value) => switch (value) {
  'cost' => TechnicalPhotoLinkType.cost,
  'decision' => TechnicalPhotoLinkType.decision,
  'defect' => TechnicalPhotoLinkType.defect,
  'acceptance_protocol' => TechnicalPhotoLinkType.acceptanceProtocol,
  _ => throw StateError('Unknown technical photo link type'),
};

final class _TechnicalPhotoFilter {
  const _TechnicalPhotoFilter({required this.sql, required this.arguments});

  final String sql;
  final List<Object?> arguments;
}
