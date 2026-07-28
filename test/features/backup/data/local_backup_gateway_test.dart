import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/core/storage/storage_capacity_probe.dart';
import 'package:budowapro/features/backup/data/local_backup_gateway.dart';
import 'package:budowapro/features/backup/data/local_backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory root;
  late Directory output;
  late AppDatabase database;
  late LocalBackupService service;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_gateway_root_');
    output = await Directory.systemTemp.createTemp('budowapro_gateway_output_');
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(root.path, AppDatabase.databaseFileName),
    );
    service = LocalBackupService(
      database: database,
      fileStore: ProjectFileStore(rootDirectory: root),
      outputDirectoryProvider: () async => output,
      utcNow: () => DateTime.utc(2026, 7, 28),
      idGenerator: () => 'gateway-test',
      storageCapacityProbe: const _CapacityProbe(),
    );
  });

  tearDown(() async {
    await database.close();
    for (final directory in <Directory>[root, output]) {
      if (directory.existsSync()) await directory.delete(recursive: true);
    }
  });

  test('deletes the private backup artifact after sharing', () async {
    late File sharedFile;
    late List<int> sharedBytes;
    final gateway = LocalBackupGateway(
      service: service,
      pickArchive: () async => null,
      shareArchive: (file, _) async {
        sharedFile = file;
        sharedBytes = await file.readAsBytes();
      },
    );

    await gateway.createAndShare(shareTitle: 'Kopia BudowaPRO');

    expect(sharedBytes, isNotEmpty);
    expect(await sharedFile.exists(), isFalse);
  });

  test('deletes the private backup artifact when sharing fails', () async {
    late File sharedFile;
    final gateway = LocalBackupGateway(
      service: service,
      pickArchive: () async => null,
      shareArchive: (file, _) async {
        sharedFile = file;
        throw const FileSystemException('share failed');
      },
    );

    await expectLater(
      gateway.createAndShare(shareTitle: 'Kopia BudowaPRO'),
      throwsA(isA<FileSystemException>()),
    );
    expect(await sharedFile.exists(), isFalse);
  });
}

final class _CapacityProbe implements StorageCapacityProbe {
  const _CapacityProbe();

  @override
  Future<int> availableBytes(Directory directory) async => 1 << 40;
}
