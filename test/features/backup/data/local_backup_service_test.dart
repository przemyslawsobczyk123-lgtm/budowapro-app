import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/core/storage/local_restore_journal.dart';
import 'package:budowapro/core/storage/storage_capacity_probe.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/backup/data/backup_archive_reader.dart';
import 'package:budowapro/features/backup/data/backup_archive_format.dart';
import 'package:budowapro/features/backup/data/local_backup_service.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
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
      storageCapacityProbe: const _FixedCapacityProbe(1 << 40),
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

  test('inspects and extracts a verified backup into staging', () async {
    final original = await _sourceFile(
      source,
      'installation.jpg',
      'installation-photo',
    );
    await files.importFile(
      projectId: 'project-1',
      area: ProjectFileArea.originals,
      source: original,
      fileName: 'installation.jpg',
    );
    final artifact = await service.createBackup();
    final stage = Directory(p.join(root.path, 'restore-stage'));

    final inspection = await inspectBackupArchive(artifact.file);
    final extracted = await extractBackupArchive(
      archiveFile: artifact.file,
      stageDirectory: stage,
    );

    expect(inspection.signature, extracted.signature);
    expect(inspection.manifest.projectCount, 1);
    expect(inspection.projectIds, <String>{'project-1'});
    expect(
      await File(
        p.join(
          stage.path,
          'projects',
          'project-1',
          'originals',
          'installation.jpg',
        ),
      ).readAsString(),
      'installation-photo',
    );
    expect(
      await File(
        p.join(stage.path, 'database', AppDatabase.databaseFileName),
      ).exists(),
      isTrue,
    );
  });

  test('removes staging when a payload checksum is invalid', () async {
    final original = await _sourceFile(source, 'receipt.jpg', 'receipt-data');
    await files.importFile(
      projectId: 'project-1',
      area: ProjectFileArea.originals,
      source: original,
      fileName: 'receipt.jpg',
    );
    final artifact = await service.createBackup();
    final input = InputFileStream(artifact.file.path);
    final validArchive = ZipDecoder().decodeStream(input);
    final corruptedArchive = Archive();
    for (final entry in validArchive) {
      final bytes = entry.readBytes()!.toList();
      if (entry.name.endsWith('/receipt.jpg')) {
        bytes[0] ^= 0xff;
      }
      corruptedArchive.addFile(ArchiveFile.bytes(entry.name, bytes));
    }
    await input.close();
    final corrupted = File(p.join(output.path, 'corrupted.zip'));
    await corrupted.writeAsBytes(ZipEncoder().encode(corruptedArchive));
    final stage = Directory(p.join(root.path, 'restore-stage'));

    await expectLater(
      extractBackupArchive(archiveFile: corrupted, stageDirectory: stage),
      throwsA(isA<FormatException>()),
    );

    expect(await stage.exists(), isFalse);
  });

  test('rejects duplicate and traversal ZIP paths before extraction', () async {
    final first = await _sourceFile(source, 'first.json', '{}');
    final second = await _sourceFile(source, 'second.json', '{}');
    final duplicate = File(p.join(output.path, 'duplicate.zip'));
    final duplicateEncoder = ZipFileEncoder();
    duplicateEncoder.create(duplicate.path);
    await duplicateEncoder.addFile(first, backupManifestPath);
    await duplicateEncoder.addFile(second, backupManifestPath);
    await duplicateEncoder.close();

    await expectLater(
      inspectBackupArchive(duplicate),
      throwsA(isA<FormatException>()),
    );

    final traversal = File(p.join(output.path, 'traversal.zip'));
    final traversalArchive = Archive()
      ..addFile(ArchiveFile.string('../escape.txt', 'unsafe'));
    await traversal.writeAsBytes(ZipEncoder().encode(traversalArchive));

    await expectLater(
      inspectBackupArchive(traversal),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects encrypted flags and oversized central entry counts', () async {
    final baseArchive = Archive()
      ..addFile(ArchiveFile.string('manifest.json', '{}'));
    final baseBytes = Uint8List.fromList(ZipEncoder().encode(baseArchive));

    final encryptedBytes = Uint8List.fromList(baseBytes);
    final encryptedData = ByteData.sublistView(encryptedBytes);
    final localHeader = _findZipSignature(encryptedBytes, 0x04034b50);
    final centralHeader = _findZipSignature(encryptedBytes, 0x02014b50);
    encryptedData.setUint16(
      localHeader + 6,
      encryptedData.getUint16(localHeader + 6, Endian.little) | 1,
      Endian.little,
    );
    encryptedData.setUint16(
      centralHeader + 8,
      encryptedData.getUint16(centralHeader + 8, Endian.little) | 1,
      Endian.little,
    );
    final encrypted = File(p.join(output.path, 'encrypted.zip'));
    await encrypted.writeAsBytes(encryptedBytes);
    await expectLater(
      inspectBackupArchive(encrypted),
      throwsA(isA<FormatException>()),
    );

    final excessiveCountBytes = Uint8List.fromList(baseBytes);
    final excessiveCountData = ByteData.sublistView(excessiveCountBytes);
    final endRecord = _findZipSignature(
      excessiveCountBytes,
      0x06054b50,
      backwards: true,
    );
    excessiveCountData.setUint16(endRecord + 8, 50001, Endian.little);
    excessiveCountData.setUint16(endRecord + 10, 50001, Endian.little);
    final excessiveCount = File(p.join(output.path, 'excessive-count.zip'));
    await excessiveCount.writeAsBytes(excessiveCountBytes);
    await expectLater(
      inspectBackupArchive(excessiveCount),
      throwsA(isA<FormatException>()),
    );
  });

  test('restores database and project files end to end', () async {
    final original = await _sourceFile(
      source,
      'foundation.jpg',
      'foundation-before-mutation',
    );
    final attachmentStager = LocalAttachmentStager(
      database: database,
      fileStore: files,
      idGenerator: () => 'attachment-1',
      utcNow: () => DateTime.utc(2026, 7, 25, 9),
    );
    final attachment = await attachmentStager.stage(
      projectId: 'project-1',
      pickedFile: PickedLocalAttachment(
        sourceUri: original.uri,
        displayName: 'foundation.jpg',
        reportedByteSize: await original.length(),
        mediaType: 'image/jpeg',
      ),
    );
    var generatedCostId = 0;
    final costs = SqliteCostRepository(
      database: database,
      idGenerator: () => 'backup-cost-${++generatedCostId}',
      utcNow: () => DateTime.utc(2026, 7, 25, 9, generatedCostId),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        CostEntryInput(
          projectId: 'project-1',
          name: 'Beton na fundament',
          type: CostEntryType.cost,
          status: CostStatus.paid,
          amount: VatBreakdown.fromNet(
            Money(minorUnits: 100000, currencyCode: 'PLN'),
            VatRate.standard23,
          ),
          entryDate: DateTime.utc(2026, 7, 25),
          attachmentIds: <String>[attachment.id],
        ),
      ),
    );
    final stored = files.fileFor(
      projectId: 'project-1',
      area: ProjectFileArea.originals,
      fileName: 'attachment-1.jpg',
    );
    final artifact = await service.createBackup();
    final candidate = await service.inspectBackup(artifact.file);
    await artifact.file.writeAsString('replaced external archive');

    final activeDatabase = await database.open();
    await activeDatabase.update(
      AppDatabase.projectsTable,
      <String, Object?>{'name': 'Mutated project'},
      where: 'id = ?',
      whereArgs: const <Object?>['project-1'],
    );
    await activeDatabase.delete(
      AppDatabase.costEntriesTable,
      where: 'project_id = ?',
      whereArgs: const <Object?>['project-1'],
    );
    await stored.writeAsString('mutated-file');

    final restored = await service.restoreBackup(candidate);

    final reopened = await database.open();
    final projects = await reopened.query(
      AppDatabase.projectsTable,
      columns: const <String>['name'],
      where: 'id = ?',
      whereArgs: const <Object?>['project-1'],
    );
    expect(projects.single['name'], 'Dom testowy');
    expect(await stored.readAsString(), 'foundation-before-mutation');
    final restoredSummary = await costs.summarize(
      CostSummaryQuery(projectId: 'project-1'),
    );
    expect(restoredSummary.actual.minorUnits, 123000);
    expect(
      await reopened.query(AppDatabase.costEntryAttachmentsTable),
      hasLength(1),
    );
    expect(restored.candidateToken, candidate.preview.candidateToken);
    expect(
      await File(
        p.join(root.path, LocalRestoreJournal.journalFileName),
      ).exists(),
      isFalse,
    );
  });

  test('migrates a previous-schema backup before restoring it', () async {
    const previousSchemaVersion = AppDatabase.schemaVersion - 1;
    final artifact = await service.createBackup();
    final previousSchemaArchive = await _rewriteAsPreviousSchemaBackup(
      sourceArchive: artifact.file,
      outputDirectory: output,
      schemaVersion: previousSchemaVersion,
    );
    final candidate = await service.inspectBackup(previousSchemaArchive);
    expect(candidate.preview.schemaVersion, previousSchemaVersion);

    final active = await database.open();
    await active.update(
      AppDatabase.projectsTable,
      <String, Object?>{'name': 'Projekt po aktualizacji'},
      where: 'id = ?',
      whereArgs: const <Object?>['project-1'],
    );

    await service.restoreBackup(candidate);

    final restored = await database.open();
    expect(await restored.getVersion(), AppDatabase.schemaVersion);
    expect(
      (await restored.query(
        AppDatabase.projectsTable,
        columns: const <String>['name'],
        where: 'id = ?',
        whereArgs: const <Object?>['project-1'],
      )).single['name'],
      'Dom testowy',
    );
    expect(
      await restored.query(
        AppDatabase.metadataTable,
        columns: const <String>['value'],
        where: 'key = ?',
        whereArgs: const <Object?>[AppDatabase.schemaVersionKey],
      ),
      <Map<String, Object?>>[
        <String, Object?>{'value': AppDatabase.schemaVersion.toString()},
      ],
    );
    final restoredTables = (await restored.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    )).map((row) => row['name']).toSet();
    expect(restoredTables, contains(AppDatabase.captureDraftsTable));
    expect(restoredTables, contains(AppDatabase.captureDraftAttachmentsTable));
  });

  test('migrates an exact-schema v8 backup through every step', () async {
    const oldestBackupSchemaVersion = 8;
    final artifact = await service.createBackup();
    final oldestSchemaArchive = await _rewriteAsPreviousSchemaBackup(
      sourceArchive: artifact.file,
      outputDirectory: output,
      schemaVersion: oldestBackupSchemaVersion,
    );

    final candidate = await service.inspectBackup(oldestSchemaArchive);
    expect(candidate.preview.schemaVersion, oldestBackupSchemaVersion);

    await service.restoreBackup(candidate);

    final restored = await database.open();
    expect(await restored.getVersion(), AppDatabase.schemaVersion);
    final restoredTables = (await restored.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    )).map((row) => row['name']).toSet();
    expect(restoredTables, contains(AppDatabase.receiptImportsTable));
    expect(restoredTables, contains(AppDatabase.captureDraftsTable));
    final projectColumns = (await restored.rawQuery(
      'PRAGMA table_info(${AppDatabase.projectsTable})',
    )).map((row) => row['name']).toSet();
    expect(projectColumns, contains('current_stage_key_v2'));
  });

  test(
    'does not change active data when free storage is insufficient',
    () async {
      final artifact = await service.createBackup();
      final candidate = await service.inspectBackup(artifact.file);
      final limitedService = LocalBackupService(
        database: database,
        fileStore: files,
        outputDirectoryProvider: () async => output,
        utcNow: () => DateTime.utc(2026, 7, 25, 9, 30),
        idGenerator: () => 'backup-limited',
        storageCapacityProbe: const _FixedCapacityProbe(0),
      );

      await expectLater(
        limitedService.restoreBackup(candidate),
        throwsA(isA<FileSystemException>()),
      );

      final active = await database.open();
      expect(
        (await active.query(AppDatabase.projectsTable)).single['name'],
        'Dom testowy',
      );
      expect(
        await Directory(
          p.join(root.path, LocalRestoreJournal.stageDirectoryName),
        ).exists(),
        isFalse,
      );
    },
  );
}

Future<File> _rewriteAsPreviousSchemaBackup({
  required File sourceArchive,
  required Directory outputDirectory,
  required int schemaVersion,
}) async {
  final input = InputFileStream(sourceArchive.path);
  final source = ZipDecoder().decodeStream(input);
  final sourceManifest = BackupManifest.fromJson(
    _jsonObject(source.find(backupManifestPath)!.readBytes()!),
  );
  final payload = <String, List<int>>{};
  for (final entry in source) {
    if (entry.name == backupManifestPath || entry.name == backupChecksumsPath) {
      continue;
    }
    payload[entry.name] = entry.readBytes()!.toList(growable: false);
  }
  await input.close();

  final databaseFile = File(p.join(outputDirectory.path, 'previous-schema.db'));
  await databaseFile.writeAsBytes(payload[backupDatabasePath]!, flush: true);
  final previousDatabase = await databaseFactoryFfi.openDatabase(
    databaseFile.path,
    options: OpenDatabaseOptions(singleInstance: false),
  );
  try {
    if (schemaVersion < 11) {
      await previousDatabase.execute(
        'DROP TABLE ${AppDatabase.captureDraftAttachmentsTable}',
      );
      await previousDatabase.execute(
        'DROP TABLE ${AppDatabase.captureDraftsTable}',
      );
    }
    if (schemaVersion < 10) {
      await previousDatabase.execute(
        'ALTER TABLE ${AppDatabase.projectsTable} '
        'DROP COLUMN current_stage_key_v2',
      );
    }
    if (schemaVersion < 9) {
      await previousDatabase.execute(
        'DROP TABLE ${AppDatabase.receiptImportsTable}',
      );
    }
    await previousDatabase.update(
      AppDatabase.metadataTable,
      <String, Object?>{'value': schemaVersion.toString()},
      where: 'key = ?',
      whereArgs: const <Object?>[AppDatabase.schemaVersionKey],
    );
    await previousDatabase.setVersion(schemaVersion);
  } finally {
    await previousDatabase.close();
  }
  payload[backupDatabasePath] = await databaseFile.readAsBytes();
  await databaseFile.delete();

  final paths = payload.keys.toList(growable: false)..sort();
  final checksums = BackupChecksumCatalog(
    paths.map((path) {
      final bytes = payload[path]!;
      return BackupChecksumEntry(
        path: path,
        byteSize: bytes.length,
        sha256: sha256.convert(bytes).toString(),
      );
    }),
  );
  final manifest = BackupManifest(
    createdAtUtc: sourceManifest.createdAtUtc,
    schemaVersion: schemaVersion,
    projectCount: sourceManifest.projectCount,
    payloadFileCount: payload.length,
    payloadBytes: payload.values.fold<int>(
      0,
      (total, bytes) => total + bytes.length,
    ),
  );
  final archive = Archive()
    ..addFile(
      ArchiveFile.bytes(
        backupManifestPath,
        utf8.encode(jsonEncode(manifest.toJson())),
      ),
    )
    ..addFile(
      ArchiveFile.bytes(
        backupChecksumsPath,
        utf8.encode(jsonEncode(checksums.toJson())),
      ),
    );
  for (final path in paths) {
    archive.addFile(ArchiveFile.bytes(path, payload[path]!));
  }

  final output = File(
    p.join(outputDirectory.path, 'previous-schema-backup.zip'),
  );
  await output.writeAsBytes(ZipEncoder().encode(archive), flush: true);
  return output;
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

final class _FixedCapacityProbe implements StorageCapacityProbe {
  const _FixedCapacityProbe(this.bytes);

  final int bytes;

  @override
  Future<int> availableBytes(Directory directory) async => bytes;
}

int _findZipSignature(
  Uint8List bytes,
  int signature, {
  bool backwards = false,
}) {
  final data = ByteData.sublistView(bytes);
  if (backwards) {
    for (var offset = bytes.length - 4; offset >= 0; offset -= 1) {
      if (data.getUint32(offset, Endian.little) == signature) return offset;
    }
  } else {
    for (var offset = 0; offset <= bytes.length - 4; offset += 1) {
      if (data.getUint32(offset, Endian.little) == signature) return offset;
    }
  }
  throw StateError('ZIP signature not found');
}
