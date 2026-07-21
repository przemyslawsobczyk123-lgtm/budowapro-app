import 'dart:io';
import 'dart:isolate';

import 'package:budowapro/core/config/storage_policy.dart';
import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

typedef LocalAttachmentIdGenerator = String Function();
typedef LocalAttachmentUtcNow = DateTime Function();

final class PickedLocalAttachment {
  factory PickedLocalAttachment({
    required Uri sourceUri,
    required String displayName,
    required int reportedByteSize,
    String? mediaType,
  }) {
    if (!sourceUri.isScheme('file')) {
      throw ArgumentError.value(
        sourceUri,
        'sourceUri',
        'must identify a local file',
      );
    }
    if (reportedByteSize < 0) {
      throw RangeError.value(
        reportedByteSize,
        'reportedByteSize',
        'must be zero or greater',
      );
    }
    return PickedLocalAttachment._(
      sourceUri: sourceUri,
      displayName: _requiredText(
        displayName,
        'displayName',
        maximumLength: 255,
      ),
      reportedByteSize: reportedByteSize,
      mediaType: _optionalText(mediaType, 'mediaType', maximumLength: 120),
    );
  }

  const PickedLocalAttachment._({
    required this.sourceUri,
    required this.displayName,
    required this.reportedByteSize,
    required this.mediaType,
  });

  final Uri sourceUri;
  final String displayName;
  final int reportedByteSize;
  final String? mediaType;
}

final class StagedLocalAttachment {
  const StagedLocalAttachment({
    required this.id,
    required this.projectId,
    required this.displayName,
    required this.byteSize,
    required this.mediaType,
    required this.sha256,
    required this.hasPreview,
    required this.importedAtUtc,
  });

  final String id;
  final String projectId;
  final String displayName;
  final int byteSize;
  final String? mediaType;
  final String? sha256;
  final bool hasPreview;
  final DateTime importedAtUtc;
}

abstract interface class LocalAttachmentPreviewGenerator {
  Future<String?> generate({
    required String projectId,
    required String attachmentId,
    required String originalStorageKey,
    required String? mediaType,
  });
}

final class LocalAttachmentStager {
  factory LocalAttachmentStager({
    required AppDatabase database,
    required ProjectFileStore fileStore,
    required LocalAttachmentIdGenerator idGenerator,
    required LocalAttachmentUtcNow utcNow,
    LocalAttachmentPreviewGenerator? previewGenerator,
    int maximumByteSize = StoragePolicy.maximumAttachmentBytes,
    Set<String> allowedExtensions = StoragePolicy.supportedAttachmentExtensions,
  }) {
    return LocalAttachmentStager._(
      database,
      fileStore,
      idGenerator,
      utcNow,
      previewGenerator,
      maximumByteSize,
      allowedExtensions,
    );
  }

  const LocalAttachmentStager._(
    this._database,
    this._fileStore,
    this._idGenerator,
    this._utcNow,
    this._previewGenerator,
    this._maximumByteSize,
    this._allowedExtensions,
  );

  final AppDatabase _database;
  final ProjectFileStore _fileStore;
  final LocalAttachmentIdGenerator _idGenerator;
  final LocalAttachmentUtcNow _utcNow;
  final LocalAttachmentPreviewGenerator? _previewGenerator;
  final int _maximumByteSize;
  final Set<String> _allowedExtensions;

  Future<StagedLocalAttachment> stage({
    required String projectId,
    required PickedLocalAttachment pickedFile,
  }) async {
    final source = File.fromUri(pickedFile.sourceUri);
    final byteSize = await source.length();
    if (byteSize != pickedFile.reportedByteSize) {
      throw StateError('Selected file changed before import');
    }
    if (byteSize > _maximumByteSize) {
      throw RangeError.value(byteSize, 'pickedFile', 'file is too large');
    }
    final extension = p.extension(pickedFile.displayName).toLowerCase();
    if (extension.length < 2 ||
        !_allowedExtensions.contains(extension.substring(1))) {
      throw UnsupportedError('Selected file type is unsupported');
    }
    final attachmentId = _idGenerator();
    final storageKey = '$attachmentId$extension';
    final importedAt = _utcNow().toUtc();
    final fileHash = await Isolate.run<String>(
      () => _sha256File(source.absolute.path),
    );
    final row = <String, Object?>{
      'id': attachmentId,
      'project_id': projectId,
      'display_name': pickedFile.displayName,
      'original_storage_key': storageKey,
      'preview_storage_key': null,
      'media_type': pickedFile.mediaType,
      'byte_size': byteSize,
      'sha256': fileHash,
      'source': 'file_picker',
      'availability': 'importing',
      'imported_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        importedAt,
      ),
    };

    final database = await _database.open();
    await database.insert(
      AppDatabase.costAttachmentsTable,
      row,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    String? previewStorageKey;
    try {
      final importedFile = await _fileStore.importFile(
        projectId: projectId,
        area: ProjectFileArea.originals,
        source: source,
        fileName: storageKey,
        maximumBytes: _maximumByteSize,
      );
      if (await importedFile.length() != byteSize) {
        throw StateError('Imported attachment size differs from the source');
      }
      try {
        previewStorageKey = await _previewGenerator?.generate(
          projectId: projectId,
          attachmentId: attachmentId,
          originalStorageKey: storageKey,
          mediaType: pickedFile.mediaType,
        );
      } on Object {
        previewStorageKey = null;
      }
      await _database.transaction<void>((transaction) async {
        final changed = await transaction.update(
          AppDatabase.costAttachmentsTable,
          <String, Object?>{
            'availability': 'available',
            'preview_storage_key': previewStorageKey,
          },
          where: 'id = ? AND project_id = ? AND availability = ?',
          whereArgs: <Object?>[attachmentId, projectId, 'importing'],
        );
        if (changed != 1) {
          throw StateError('Attachment import placeholder is unavailable');
        }
      });
    } on Object catch (error, stackTrace) {
      await _deleteImportedFiles(
        projectId: projectId,
        originalStorageKey: storageKey,
        previewStorageKey: previewStorageKey,
      );
      await database.delete(
        AppDatabase.costAttachmentsTable,
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[attachmentId, projectId],
      );
      Error.throwWithStackTrace(error, stackTrace);
    }

    return StagedLocalAttachment(
      id: attachmentId,
      projectId: projectId,
      displayName: pickedFile.displayName,
      byteSize: byteSize,
      mediaType: pickedFile.mediaType,
      sha256: fileHash,
      hasPreview: (await findById(
        projectId: projectId,
        attachmentId: attachmentId,
      ))!.hasPreview,
      importedAtUtc: importedAt,
    );
  }

  Future<StagedLocalAttachment?> findById({
    required String projectId,
    required String attachmentId,
  }) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.costAttachmentsTable,
      where: 'id = ? AND project_id = ? AND availability = ?',
      whereArgs: <Object?>[attachmentId, projectId, 'available'],
      limit: 1,
    );
    return rows.isEmpty ? null : _attachmentFromRow(rows.single);
  }

  Future<List<StagedLocalAttachment>> listForCost({
    required String projectId,
    required String costEntryId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '''
        SELECT a.*
        FROM ${AppDatabase.costAttachmentsTable} a
        INNER JOIN ${AppDatabase.costEntryAttachmentsTable} l
          ON l.attachment_id = a.id AND l.project_id = a.project_id
        WHERE l.project_id = ?
          AND l.cost_entry_id = ?
          AND a.availability = 'available'
        ORDER BY l.sort_order ASC
      ''',
      <Object?>[projectId, costEntryId],
    );
    return rows.map(_attachmentFromRow).toList(growable: false);
  }

  Future<List<StagedLocalAttachment>> listForQuote({
    required String projectId,
    required String quoteId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '''
        SELECT a.*
        FROM ${AppDatabase.costAttachmentsTable} a
        INNER JOIN ${AppDatabase.quoteAttachmentsTable} l
          ON l.attachment_id = a.id AND l.project_id = a.project_id
        WHERE l.project_id = ?
          AND l.quote_id = ?
          AND a.availability = 'available'
        ORDER BY l.sort_order ASC
      ''',
      <Object?>[projectId, quoteId],
    );
    return rows.map(_attachmentFromRow).toList(growable: false);
  }

  Future<List<StagedLocalAttachment>> listForChecklistItem({
    required String projectId,
    required String checklistItemId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '''
        SELECT a.*
        FROM ${AppDatabase.costAttachmentsTable} a
        INNER JOIN ${AppDatabase.checklistItemAttachmentsTable} l
          ON l.attachment_id = a.id AND l.project_id = a.project_id
        WHERE l.project_id = ?
          AND l.checklist_item_id = ?
          AND a.availability = 'available'
        ORDER BY l.sort_order ASC
      ''',
      <Object?>[projectId, checklistItemId],
    );
    return rows.map(_attachmentFromRow).toList(growable: false);
  }

  Future<File?> originalFile({
    required String projectId,
    required String attachmentId,
  }) {
    return _storedFile(
      projectId: projectId,
      attachmentId: attachmentId,
      storageColumn: 'original_storage_key',
      area: ProjectFileArea.originals,
    );
  }

  Future<File?> previewFile({
    required String projectId,
    required String attachmentId,
  }) {
    return _storedFile(
      projectId: projectId,
      attachmentId: attachmentId,
      storageColumn: 'preview_storage_key',
      area: ProjectFileArea.previews,
    );
  }

  Future<File?> _storedFile({
    required String projectId,
    required String attachmentId,
    required String storageColumn,
    required ProjectFileArea area,
  }) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.costAttachmentsTable,
      columns: <String>[storageColumn],
      where: 'project_id = ? AND id = ? AND availability = ?',
      whereArgs: <Object?>[projectId, attachmentId, 'available'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final storageKey = rows.single[storageColumn] as String?;
    if (storageKey == null) return null;
    final file = _fileStore.fileFor(
      projectId: projectId,
      area: area,
      fileName: storageKey,
    );
    return await file.exists() ? file : null;
  }

  Future<void> discard({
    required String projectId,
    required String attachmentId,
  }) async {
    await _discard(
      projectId: projectId,
      attachmentId: attachmentId,
      rejectLinked: true,
    );
  }

  Future<bool> discardIfUnlinked({
    required String projectId,
    required String attachmentId,
  }) {
    return _discard(
      projectId: projectId,
      attachmentId: attachmentId,
      rejectLinked: false,
    );
  }

  Future<bool> _discard({
    required String projectId,
    required String attachmentId,
    required bool rejectLinked,
  }) async {
    final storageKeys = await _database.transaction<_StorageKeys?>((
      transaction,
    ) async {
      final rows = await transaction.query(
        AppDatabase.costAttachmentsTable,
        columns: const <String>['original_storage_key', 'preview_storage_key'],
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[attachmentId, projectId],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      final links = await transaction.rawQuery(
        '''
          SELECT attachment_id
          FROM ${AppDatabase.costEntryAttachmentsTable}
          WHERE project_id = ? AND attachment_id = ?
          UNION ALL
          SELECT attachment_id
          FROM ${AppDatabase.checklistItemAttachmentsTable}
          WHERE project_id = ? AND attachment_id = ?
          UNION ALL
          SELECT attachment_id
          FROM ${AppDatabase.quoteAttachmentsTable}
          WHERE project_id = ? AND attachment_id = ?
          UNION ALL
          SELECT attachment_id
          FROM ${AppDatabase.documentMetadataTable}
          WHERE project_id = ? AND attachment_id = ?
          UNION ALL
          SELECT attachment_id
          FROM ${AppDatabase.documentContextLinksTable}
          WHERE project_id = ? AND attachment_id = ?
          LIMIT 1
        ''',
        <Object?>[
          projectId,
          attachmentId,
          projectId,
          attachmentId,
          projectId,
          attachmentId,
          projectId,
          attachmentId,
          projectId,
          attachmentId,
        ],
      );
      if (links.isNotEmpty) {
        if (rejectLinked) {
          throw StateError('A linked attachment cannot be discarded');
        }
        return null;
      }
      final changed = await transaction.update(
        AppDatabase.costAttachmentsTable,
        const <String, Object?>{'availability': 'deleting'},
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[attachmentId, projectId],
      );
      if (changed != 1) {
        throw StateError('Attachment is unavailable for deletion');
      }
      return _StorageKeys(
        original: rows.single['original_storage_key']! as String,
        preview: rows.single['preview_storage_key'] as String?,
      );
    });
    if (storageKeys == null) {
      return false;
    }
    await _deleteImportedFiles(
      projectId: projectId,
      originalStorageKey: storageKeys.original,
      previewStorageKey: storageKeys.preview,
    );
    final database = await _database.open();
    await database.delete(
      AppDatabase.costAttachmentsTable,
      where: 'id = ? AND project_id = ? AND availability = ?',
      whereArgs: <Object?>[attachmentId, projectId, 'deleting'],
    );
    return true;
  }

  Future<void> recoverInterruptedImports() async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.costAttachmentsTable,
      columns: const <String>[
        'id',
        'project_id',
        'original_storage_key',
        'preview_storage_key',
      ],
      where: 'availability = ?',
      whereArgs: const <Object?>['importing'],
      orderBy: 'imported_at_utc_ms ASC, id ASC',
    );
    for (final row in rows) {
      final projectId = row['project_id']! as String;
      await _deleteImportedFiles(
        projectId: projectId,
        originalStorageKey: row['original_storage_key']! as String,
        previewStorageKey: row['preview_storage_key'] as String?,
      );
      await database.delete(
        AppDatabase.costAttachmentsTable,
        where: 'id = ? AND project_id = ? AND availability = ?',
        whereArgs: <Object?>[row['id'], projectId, 'importing'],
      );
    }
  }

  Future<void> recoverInterruptedDeletions() async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.costAttachmentsTable,
      columns: const <String>[
        'id',
        'project_id',
        'original_storage_key',
        'preview_storage_key',
      ],
      where: 'availability = ?',
      whereArgs: const <Object?>['deleting'],
      orderBy: 'imported_at_utc_ms ASC, id ASC',
    );
    for (final row in rows) {
      final projectId = row['project_id']! as String;
      await _deleteImportedFiles(
        projectId: projectId,
        originalStorageKey: row['original_storage_key']! as String,
        previewStorageKey: row['preview_storage_key'] as String?,
      );
      await database.delete(
        AppDatabase.costAttachmentsTable,
        where: 'id = ? AND project_id = ? AND availability = ?',
        whereArgs: <Object?>[row['id'], projectId, 'deleting'],
      );
    }
  }

  Future<void> recoverUnlinkedAttachments() async {
    final database = await _database.open();
    final rows = await database.rawQuery('''
      SELECT a.id, a.project_id
      FROM ${AppDatabase.costAttachmentsTable} a
      WHERE a.availability = 'available'
        AND NOT EXISTS (
          SELECT 1
          FROM ${AppDatabase.costEntryAttachmentsTable} l
          WHERE l.project_id = a.project_id AND l.attachment_id = a.id
        )
        AND NOT EXISTS (
          SELECT 1
          FROM ${AppDatabase.checklistItemAttachmentsTable} l
          WHERE l.project_id = a.project_id AND l.attachment_id = a.id
        )
        AND NOT EXISTS (
          SELECT 1
          FROM ${AppDatabase.quoteAttachmentsTable} l
          WHERE l.project_id = a.project_id AND l.attachment_id = a.id
        )
        AND NOT EXISTS (
          SELECT 1
          FROM ${AppDatabase.documentMetadataTable} m
          WHERE m.project_id = a.project_id AND m.attachment_id = a.id
        )
        AND NOT EXISTS (
          SELECT 1
          FROM ${AppDatabase.documentContextLinksTable} l
          WHERE l.project_id = a.project_id AND l.attachment_id = a.id
        )
      ORDER BY a.imported_at_utc_ms ASC, a.id ASC
    ''');
    for (final row in rows) {
      await discard(
        projectId: row['project_id']! as String,
        attachmentId: row['id']! as String,
      );
    }
  }

  Future<void> _deleteImportedFiles({
    required String projectId,
    required String originalStorageKey,
    String? previewStorageKey,
  }) async {
    await _fileStore.deleteFile(
      projectId: projectId,
      area: ProjectFileArea.originals,
      fileName: originalStorageKey,
    );
    await _fileStore.deleteFile(
      projectId: projectId,
      area: ProjectFileArea.originals,
      fileName: '$originalStorageKey.part',
    );
    if (previewStorageKey != null) {
      await _fileStore.deleteFile(
        projectId: projectId,
        area: ProjectFileArea.previews,
        fileName: previewStorageKey,
      );
      await _fileStore.deleteFile(
        projectId: projectId,
        area: ProjectFileArea.previews,
        fileName: '$previewStorageKey.part',
      );
    }
  }
}

final class _StorageKeys {
  const _StorageKeys({required this.original, required this.preview});

  final String original;
  final String? preview;
}

StagedLocalAttachment _attachmentFromRow(Map<String, Object?> row) {
  return StagedLocalAttachment(
    id: row['id']! as String,
    projectId: row['project_id']! as String,
    displayName: row['display_name']! as String,
    byteSize: row['byte_size']! as int,
    mediaType: row['media_type'] as String?,
    sha256: row['sha256'] as String?,
    hasPreview: row['preview_storage_key'] != null,
    importedAtUtc: DatabaseValueCodec.utcMillisecondsToDateTime(
      row['imported_at_utc_ms']! as int,
    ),
  );
}

Future<String> _sha256File(String path) async {
  return (await sha256.bind(File(path).openRead()).first).toString();
}

typedef CostAttachmentIdGenerator = LocalAttachmentIdGenerator;
typedef CostAttachmentUtcNow = LocalAttachmentUtcNow;
typedef PickedCostAttachment = PickedLocalAttachment;
typedef StagedCostAttachment = StagedLocalAttachment;
typedef CostAttachmentStager = LocalAttachmentStager;

String _requiredText(
  String value,
  String argumentName, {
  required int maximumLength,
}) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(
      value,
      argumentName,
      'must contain between 1 and $maximumLength characters',
    );
  }
  return normalized;
}

String? _optionalText(
  String? value,
  String argumentName, {
  required int maximumLength,
}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return _requiredText(value, argumentName, maximumLength: maximumLength);
}
