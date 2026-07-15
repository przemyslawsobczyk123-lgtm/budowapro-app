import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  AppDatabase? appDatabase;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_database_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
  });

  tearDown(() async {
    await appDatabase?.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('creates a new database at schema version 1', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    final database = await appDatabase!.open();

    expect(await database.getVersion(), AppDatabase.schemaVersion);
    final foreignKeys = await database.rawQuery('PRAGMA foreign_keys');
    expect(foreignKeys.single.values.single, 1);
    expect(
      await appDatabase!.readMetadata(AppDatabase.schemaVersionKey),
      AppDatabase.schemaVersion.toString(),
    );
  });

  test(
    'migrates an existing unversioned database without losing data',
    () async {
      final legacyDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
      );
      await legacyDatabase.execute(
        'CREATE TABLE legacy_marker (value TEXT NOT NULL)',
      );
      await legacyDatabase.insert('legacy_marker', <String, Object?>{
        'value': 'preserve-me',
      });
      await legacyDatabase.close();

      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      final database = await appDatabase!.open();

      expect(await database.getVersion(), AppDatabase.schemaVersion);
      expect(await database.query('legacy_marker'), <Map<String, Object?>>[
        <String, Object?>{'value': 'preserve-me'},
      ]);
      expect(
        await appDatabase!.readMetadata(AppDatabase.schemaVersionKey),
        AppDatabase.schemaVersion.toString(),
      );
    },
  );

  test('uses bound arguments for metadata keys', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    const unusualKey = "owner' OR 1 = 1 --";

    await appDatabase!.writeMetadata(
      key: unusualKey,
      value: 'literal-value',
      updatedAt: DateTime.utc(2026, 7, 15),
    );

    expect(await appDatabase!.readMetadata(unusualKey), 'literal-value');
    expect(await appDatabase!.readMetadata('owner'), isNull);
  });

  test('rolls back every write when a transaction fails', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    await expectLater(
      appDatabase!.transaction<void>((transaction) async {
        await transaction.insert(AppDatabase.metadataTable, <String, Object?>{
          'key': 'temporary',
          'value': 'must-be-rolled-back',
          'updated_at_utc_ms': 0,
        });
        throw StateError('simulated interruption');
      }),
      throwsStateError,
    );

    expect(await appDatabase!.readMetadata('temporary'), isNull);
  });

  test('close waits for an in-flight open and closes its handle', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    final opening = appDatabase!.open();
    await appDatabase!.close();
    final database = await opening;

    expect(database.isOpen, isFalse);
  });
}
