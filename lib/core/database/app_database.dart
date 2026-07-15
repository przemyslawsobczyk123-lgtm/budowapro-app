import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_value_codec.dart';

final class AppDatabase {
  factory AppDatabase({
    required DatabaseFactory factory,
    required String path,
  }) => AppDatabase._(factory, path);

  AppDatabase._(this._factory, this._path);

  static const int schemaVersion = 1;
  static const String databaseFileName = 'budowapro.db';
  static const String metadataTable = 'app_metadata';
  static const String schemaVersionKey = 'schema_version';

  final DatabaseFactory _factory;
  final String _path;

  Database? _database;
  Future<Database>? _opening;
  Future<void>? _closing;

  static Future<AppDatabase> onDevice() async {
    final supportDirectory = await getApplicationSupportDirectory();
    await supportDirectory.create(recursive: true);
    return AppDatabase(
      factory: databaseFactory,
      path: p.join(supportDirectory.path, databaseFileName),
    );
  }

  Future<Database> open() async {
    final closing = _closing;
    if (closing != null) {
      await closing;
    }

    final currentDatabase = _database;
    if (currentDatabase != null && currentDatabase.isOpen) {
      return currentDatabase;
    }

    final currentOpening = _opening;
    if (currentOpening != null) {
      return currentOpening;
    }

    late final Future<Database> opening;
    opening = _openDatabase().whenComplete(() {
      if (identical(_opening, opening)) {
        _opening = null;
      }
    });
    _opening = opening;
    return opening;
  }

  Future<Database> _openDatabase() async {
    final openedDatabase = await _factory.openDatabase(
      _path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) {
          return _migrate(database, fromVersion: 0, toVersion: version);
        },
        onUpgrade: (database, oldVersion, newVersion) {
          return _migrate(
            database,
            fromVersion: oldVersion,
            toVersion: newVersion,
          );
        },
      ),
    );
    _database = openedDatabase;
    return openedDatabase;
  }

  Future<T> transaction<T>(
    Future<T> Function(DatabaseExecutor transaction) action,
  ) async {
    final database = await open();
    return database.transaction(action);
  }

  Future<String?> readMetadata(String key) async {
    final database = await open();
    final rows = await database.query(
      metadataTable,
      columns: const <String>['value'],
      where: 'key = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.single['value'] as String;
  }

  Future<void> writeMetadata({
    required String key,
    required String value,
    required DateTime updatedAt,
  }) async {
    final database = await open();
    await database.insert(metadataTable, <String, Object?>{
      'key': key,
      'value': value,
      'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        updatedAt,
      ),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    final currentClosing = _closing;
    if (currentClosing != null) {
      return currentClosing;
    }

    late final Future<void> closing;
    closing = _closeDatabase().whenComplete(() {
      if (identical(_closing, closing)) {
        _closing = null;
      }
    });
    _closing = closing;
    return closing;
  }

  Future<void> _closeDatabase() async {
    final opening = _opening;
    if (opening != null) {
      try {
        await opening;
      } on Object {
        return;
      }
    }

    final database = _database;
    _database = null;
    if (database != null && database.isOpen) {
      await database.close();
    }
  }

  static Future<void> _migrate(
    Database database, {
    required int fromVersion,
    required int toVersion,
  }) async {
    if (fromVersion < 1 && toVersion >= 1) {
      await database.execute('''
        CREATE TABLE IF NOT EXISTS $metadataTable (
          key TEXT PRIMARY KEY NOT NULL,
          value TEXT NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL
        )
      ''');
      await database.insert(metadataTable, <String, Object?>{
        'key': schemaVersionKey,
        'value': schemaVersion.toString(),
        'updated_at_utc_ms': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
