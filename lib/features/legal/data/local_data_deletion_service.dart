import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';

typedef CleanPrivateCaches = Future<void> Function();

abstract interface class LocalDataDeletion {
  Future<void> deleteAll();
}

final class LocalDataDeletionService implements LocalDataDeletion {
  const LocalDataDeletionService(
    this._database,
    this._fileStore,
    this._cleanPrivateCaches,
  );

  final AppDatabase _database;
  final ProjectFileStore _fileStore;
  final CleanPrivateCaches _cleanPrivateCaches;

  @override
  Future<void> deleteAll() async {
    // Remove attachments first. If storage is locked or malformed, keep the
    // database intact so the user can retry without additional data loss.
    await _fileStore.deleteAllProjectFiles();

    await _database.runMaintenance((maintenance) async {
      await maintenance.deleteSidecarFiles();
      final databaseFile = maintenance.databaseFile;
      final type = await FileSystemEntity.type(
        databaseFile.path,
        followLinks: false,
      );
      if (type == FileSystemEntityType.notFound) {
        return;
      }
      if (type != FileSystemEntityType.file) {
        throw const FileSystemException('Database path is not a regular file');
      }
      await databaseFile.delete();
    });

    // Temporary exports and picker/OCR caches are best-effort OS-owned data.
    // They must never turn a completed database reset into a visible error.
    try {
      await _cleanPrivateCaches();
    } on Object {
      // Startup cleanup will retry detached cache directories.
    }
  }
}
