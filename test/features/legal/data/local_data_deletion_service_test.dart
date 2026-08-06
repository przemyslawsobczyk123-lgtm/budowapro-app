import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/core/storage/local_data_wipe_journal.dart';
import 'package:budowapro/features/legal/data/local_data_deletion_service.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory root;
  late String databasePath;
  late AppDatabase database;
  late ProjectFileStore fileStore;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_data_delete_');
    databasePath = p.join(root.path, AppDatabase.databaseFileName);
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await database.open();
    fileStore = ProjectFileStore(rootDirectory: root);
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  test('removes the database, project files and private caches', () async {
    final repository = SqliteProjectRepository(
      database: database,
      fileStore: fileStore,
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 7, 29),
    );
    final project = await repository.create(
      ProjectDraft(
        name: 'Budowa testowa',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    final source = File(p.join(root.path, 'receipt.txt'))
      ..writeAsStringSync('receipt');
    await fileStore.importFile(
      projectId: project.id,
      area: ProjectFileArea.originals,
      source: source,
      fileName: 'receipt.txt',
    );
    var cachesCleaned = false;
    final service = LocalDataDeletionService(
      database,
      fileStore,
      () async => cachesCleaned = true,
    );

    await service.deleteAll();

    expect(await repository.findById(project.id), isNull);
    expect(await fileStore.countProjectFiles(project.id), 0);
    expect(await database.open(), isNotNull);
    expect(await File(databasePath).exists(), isTrue);
    expect(cachesCleaned, isTrue);
    expect(
      await LocalDataWipeJournal.markerFor(fileStore.rootDirectory).exists(),
      isFalse,
    );
  });

  test(
    'leaves a recovery marker when project storage cannot be cleared',
    () async {
      final repository = SqliteProjectRepository(
        database: database,
        fileStore: fileStore,
        idGenerator: () => 'project-1',
        utcNow: () => DateTime.utc(2026, 7, 29),
      );
      final project = await repository.create(
        ProjectDraft(
          name: 'Nie usuwaj',
          type: ProjectType.houseBuild,
          template: ProjectTemplate.houseConstruction,
        ),
      );
      final filesRoot = fileStore.rootDirectory;
      await filesRoot.create(recursive: true);
      await File(p.join(filesRoot.path, 'projects')).writeAsString('blocked');
      final service = LocalDataDeletionService(
        database,
        fileStore,
        () async {},
      );

      await expectLater(
        service.deleteAll(),
        throwsA(isA<FileSystemException>()),
      );

      expect(await repository.findById(project.id), isNull);
      expect(await File(databasePath).exists(), isTrue);
      final marker = LocalDataWipeJournal.markerFor(fileStore.rootDirectory);
      expect(await marker.exists(), isTrue);

      await database.close();
      await File(p.join(filesRoot.path, 'projects')).delete();
      expect(
        await LocalDataWipeJournal.recover(
          rootDirectory: fileStore.rootDirectory,
          databaseFileName: AppDatabase.databaseFileName,
        ),
        isTrue,
      );
      expect(await marker.exists(), isFalse);
    },
  );

  test(
    'recovers after database deletion fails before files are touched',
    () async {
      final repository = SqliteProjectRepository(
        database: database,
        fileStore: fileStore,
        idGenerator: () => 'project-1',
        utcNow: () => DateTime.utc(2026, 7, 29),
      );
      final project = await repository.create(
        ProjectDraft(
          name: 'Usuń po restarcie',
          type: ProjectType.houseBuild,
          template: ProjectTemplate.houseConstruction,
        ),
      );
      final source = File(p.join(root.path, 'receipt.txt'))
        ..writeAsStringSync('receipt');
      await fileStore.importFile(
        projectId: project.id,
        area: ProjectFileArea.originals,
        source: source,
        fileName: 'receipt.txt',
      );
      final service = LocalDataDeletionService(
        database,
        fileStore,
        () async {},
        deleteDatabase: () async {
          throw const FileSystemException('simulated database failure');
        },
      );

      await expectLater(
        service.deleteAll(),
        throwsA(isA<FileSystemException>()),
      );

      expect(await repository.findById(project.id), isNotNull);
      expect(await fileStore.countProjectFiles(project.id), 1);
      await database.close();
      expect(
        await LocalDataWipeJournal.recover(
          rootDirectory: fileStore.rootDirectory,
          databaseFileName: AppDatabase.databaseFileName,
        ),
        isTrue,
      );
      expect(await fileStore.countProjectFiles(project.id), 0);
      expect(await repository.findById(project.id), isNull);
    },
  );
}
