import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/backup/data/backup_archive_format.dart';
import 'package:budowapro/features/backup/data/local_backup_service.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory root;
  late Directory source;
  late Directory output;
  late AppDatabase database;
  late ProjectFileStore files;
  late LocalBackupService service;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_backup_root_');
    source = await Directory.systemTemp.createTemp('budowapro_backup_source_');
    output = await Directory.systemTemp.createTemp('budowapro_backup_output_');
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(root.path, AppDatabase.databaseFileName),
    );
    files = ProjectFileStore(rootDirectory: root);
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: files,
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 7, 25, 8),
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom testowy',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    service = LocalBackupService(
      database: database,
      fileStore: files,
      outputDirectoryProvider: () async => output,
      utcNow: () => DateTime.utc(2026, 7, 25, 9, 30),
      idGenerator: () => 'backup-test',
    );
  });

  tearDown(() async {
    await database.close();
    for (final directory in <Directory>[root, source, output]) {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  });

  test(
    'creates a versioned archive with database, files and checksums',
    () async {
      final sourceFiles = <ProjectFileArea, File>{
        ProjectFileArea.originals: await _sourceFile(
          source,
          'original.pdf',
          'original-content',
        ),
        ProjectFileArea.previews: await _sourceFile(
          source,
          'preview.jpg',
          'preview-content',
        ),
        ProjectFileArea.exports: await _sourceFile(
          source,
          'export.txt',
          'export-content',
        ),
      };
      for (final item in sourceFiles.entries) {
        await files.importFile(
          projectId: 'project-1',
          area: item.key,
          source: item.value,
          fileName: item.value.uri.pathSegments.last,
        );
      }
      await File(
        p.join(
          files
              .directoryFor(
                projectId: 'project-1',
                area: ProjectFileArea.originals,
              )
              .path,
          'interrupted.part',
        ),
      ).writeAsString('partial');

      final artifact = await service.createBackup();
      final input = InputFileStream(artifact.file.path);
      final archive = ZipDecoder().decodeStream(input);

      expect(archive.map((entry) => entry.name).toSet(), <String>{
        backupManifestPath,
        backupChecksumsPath,
        backupDatabasePath,
        'projects/project-1/originals/original.pdf',
        'projects/project-1/previews/preview.jpg',
        'projects/project-1/exports/export.txt',
      });
      expect(archive.any((entry) => entry.name.endsWith('.part')), isFalse);
      final manifest = BackupManifest.fromJson(
        _jsonObject(archive.find(backupManifestPath)!.readBytes()!),
      );
      final catalog = BackupChecksumCatalog.fromJson(
        _jsonObject(archive.find(backupChecksumsPath)!.readBytes()!),
      );
      expect(manifest.schemaVersion, AppDatabase.schemaVersion);
      expect(manifest.projectCount, 1);
      expect(manifest.payloadFileCount, 4);
      expect(artifact.preview.payloadFileCount, 4);
      expect(catalog.entries, hasLength(4));

      for (final checksum in catalog.entries) {
        final bytes = archive.find(checksum.path)!.readBytes()!;
        expect(bytes.length, checksum.byteSize, reason: checksum.path);
        expect(sha256.convert(bytes).toString(), checksum.sha256);
      }

      final extractedDatabase = File(
        p.join(output.path, 'extracted-budowapro.db'),
      );
      final databaseOutput = OutputFileStream(extractedDatabase.path);
      archive
          .find(backupDatabasePath)!
          .writeContent(databaseOutput, freeMemory: false);
      await databaseOutput.close();
      final snapshot = await databaseFactoryFfi.openDatabase(
        extractedDatabase.path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      final projects = await snapshot.query(AppDatabase.projectsTable);
      await snapshot.close();
      await input.close();

      expect(projects.single['name'], 'Dom testowy');
      expect(
        Directory(p.join(root.path, '.budowapro-backup-work')).listSync(),
        isEmpty,
      );
    },
  );

  test('rejects an unsupported nested project file', () async {
    final nested = Directory(
      p.join(
        files
            .directoryFor(
              projectId: 'project-1',
              area: ProjectFileArea.originals,
            )
            .path,
        'nested',
      ),
    );
    await nested.create(recursive: true);
    await File(p.join(nested.path, 'file.pdf')).writeAsString('data');

    await expectLater(
      service.createBackup(),
      throwsA(isA<FileSystemException>()),
    );

    expect(output.listSync(), isEmpty);
  });
}

Future<File> _sourceFile(
  Directory directory,
  String name,
  String content,
) async {
  final file = File(p.join(directory.path, name));
  await file.writeAsString(content);
  return file;
}

Map<String, Object?> _jsonObject(List<int> bytes) {
  final value = jsonDecode(utf8.decode(bytes));
  if (value is! Map<String, Object?>) {
    throw const FormatException('Expected JSON object');
  }
  return value;
}
