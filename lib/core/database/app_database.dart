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

  static const int schemaVersion = 2;
  static const String databaseFileName = 'budowapro.db';
  static const String metadataTable = 'app_metadata';
  static const String projectsTable = 'projects';
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
        onDowngrade: (database, oldVersion, newVersion) {
          throw StateError(
            'Database downgrade from $oldVersion to $newVersion is unsupported',
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
    }

    if (fromVersion < 2 && toVersion >= 2) {
      await database.execute('''
        CREATE TABLE $projectsTable (
          id TEXT PRIMARY KEY NOT NULL,
          name TEXT NOT NULL,
          location_label TEXT,
          project_type TEXT NOT NULL CHECK (
            project_type IN (
              'house_build',
              'house_renovation',
              'apartment_renovation'
            )
          ),
          template_key TEXT NOT NULL CHECK (
            template_key IN ('build_house', 'renovation')
          ),
          template_version INTEGER NOT NULL CHECK (template_version > 0),
          currency_code TEXT NOT NULL,
          area_square_meters INTEGER CHECK (area_square_meters > 0),
          planned_budget_minor_units INTEGER CHECK (
            planned_budget_minor_units >= 0
          ),
          planned_start_utc_ms INTEGER,
          planned_end_utc_ms INTEGER,
          date_format TEXT NOT NULL CHECK (
            date_format IN ('day_month_year', 'year_month_day')
          ),
          current_stage_key TEXT NOT NULL CHECK (
            current_stage_key IN (
              'planning',
              'formalities',
              'state_zero',
              'shell_open',
              'shell_closed',
              'demolition',
              'installations',
              'plaster',
              'finishing',
              'handover'
            )
          ),
          is_archived INTEGER NOT NULL DEFAULT 0 CHECK (
            is_archived IN (0, 1)
          ),
          deletion_pending INTEGER NOT NULL DEFAULT 0 CHECK (
            deletion_pending IN (0, 1)
          ),
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL
        )
      ''');
      await database.execute('''
        CREATE INDEX projects_active_updated_idx
        ON $projectsTable (
          deletion_pending,
          is_archived,
          updated_at_utc_ms DESC,
          id ASC
        )
      ''');
    }

    if (fromVersion < toVersion) {
      await database.insert(metadataTable, <String, Object?>{
        'key': schemaVersionKey,
        'value': toVersion.toString(),
        'updated_at_utc_ms': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
