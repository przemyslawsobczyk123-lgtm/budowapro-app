import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/core/storage/local_data_wipe_journal.dart';

typedef CleanPrivateCaches = Future<void> Function();
typedef DeleteLocalDatabase = Future<void> Function();

abstract interface class LocalDataDeletion {
  Future<void> deleteAll();
}

final class LocalDataDeletionService implements LocalDataDeletion {
  const LocalDataDeletionService(
    this._database,
    this._fileStore,
    this._cleanPrivateCaches, {
    DeleteLocalDatabase? deleteDatabase,
  }) : _deleteDatabaseOverride = deleteDatabase;

  final AppDatabase _database;
  final ProjectFileStore _fileStore;
  final CleanPrivateCaches _cleanPrivateCaches;
  final DeleteLocalDatabase? _deleteDatabaseOverride;

  @override
  Future<void> deleteAll() async {
    final marker = await LocalDataWipeJournal.prepare(_fileStore.rootDirectory);
    await (_deleteDatabaseOverride?.call() ?? _deleteDatabase());
    await _fileStore.deleteAllProjectFiles();

    // Temporary exports and picker/OCR caches are best-effort OS-owned data.
    // They must never turn a completed durable reset into a visible error.
    try {
      await _cleanPrivateCaches();
    } on Object {
      // Startup cleanup will retry detached cache directories.
    }
    await marker.delete();
  }

  Future<void> _deleteDatabase() {
    return _database.runMaintenance((maintenance) async {
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
  }
}
