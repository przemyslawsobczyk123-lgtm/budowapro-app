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

  test('creates a new database at the current schema version', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    final database = await appDatabase!.open();

    expect(await database.getVersion(), AppDatabase.schemaVersion);
    final foreignKeys = await database.rawQuery('PRAGMA foreign_keys');
    expect(foreignKeys.single.values.single, 1);
    expect(
      await appDatabase!.readMetadata(AppDatabase.schemaVersionKey),
      AppDatabase.schemaVersion.toString(),
    );
    final projectTable = await database.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: <Object?>['table', 'projects'],
    );
    expect(projectTable, hasLength(1));
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

  test('migrates version 1 and preserves existing metadata', () async {
    final versionOneDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE app_metadata (
              key TEXT PRIMARY KEY NOT NULL,
              value TEXT NOT NULL,
              updated_at_utc_ms INTEGER NOT NULL
            )
          ''');
          await database.insert('app_metadata', <String, Object?>{
            'key': 'legacy_setting',
            'value': 'preserve-me',
            'updated_at_utc_ms': 0,
          });
        },
      ),
    );
    await versionOneDatabase.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final database = await appDatabase!.open();

    expect(await database.getVersion(), AppDatabase.schemaVersion);
    expect(await appDatabase!.readMetadata('legacy_setting'), 'preserve-me');
    final projectTable = await database.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: <Object?>['table', 'projects'],
    );
    expect(projectTable, hasLength(1));
  });

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

  test('rejects a future schema without deleting its data', () async {
    final futureDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.schemaVersion + 1,
        onCreate: (database, version) async {
          await database.execute(
            'CREATE TABLE future_marker (value TEXT NOT NULL)',
          );
          await database.insert('future_marker', <String, Object?>{
            'value': 'preserve-me',
          });
        },
      ),
    );
    await futureDatabase.close();
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    await expectLater(appDatabase!.open(), throwsStateError);

    final preserved = await databaseFactoryFfi.openDatabase(databasePath);
    expect(await preserved.query('future_marker'), <Map<String, Object?>>[
      <String, Object?>{'value': 'preserve-me'},
    ]);
    await preserved.close();
  });

  test('reports a corrupt database without replacing its file', () async {
    final corruptBytes = <int>[0, 1, 2, 3, 4, 5, 6, 7];
    await File(databasePath).writeAsBytes(corruptBytes, flush: true);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    await expectLater(appDatabase!.open(), throwsA(isA<DatabaseException>()));

    expect(await File(databasePath).readAsBytes(), corruptBytes);
  });
}
