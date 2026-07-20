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

  static const int schemaVersion = 4;
  static const String databaseFileName = 'budowapro.db';
  static const String metadataTable = 'app_metadata';
  static const String projectsTable = 'projects';
  static const String costEntriesTable = 'cost_entries';
  static const String costAttachmentsTable = 'attachments';
  static const String costEntryAttachmentsTable = 'cost_entry_attachments';
  static const String costEntryRevisionsTable = 'cost_entry_revisions';
  static const String costCorrectionsTable = 'cost_corrections';
  static const String projectStagesTable = 'project_stages';
  static const String checklistItemsTable = 'checklist_items';
  static const String checklistItemAttachmentsTable =
      'checklist_item_attachments';
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

    if (fromVersion < 3 && toVersion >= 3) {
      await database.execute('''
        CREATE TABLE $costEntriesTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          name TEXT NOT NULL,
          entry_type TEXT NOT NULL CHECK (
            entry_type IN ('cost', 'offer', 'planned')
          ),
          financial_status TEXT NOT NULL CHECK (
            financial_status IN (
              'planned',
              'ordered',
              'due',
              'paid',
              'returned',
              'disputed'
            )
          ),
          lifecycle TEXT NOT NULL CHECK (lifecycle IN ('draft', 'confirmed')),
          entry_date_utc_ms INTEGER NOT NULL,
          stage_id TEXT,
          category_id TEXT,
          supplier_id TEXT,
          quantity_unscaled INTEGER CHECK (quantity_unscaled > 0),
          quantity_scale INTEGER CHECK (quantity_scale BETWEEN 0 AND 6),
          unit TEXT,
          net_minor_units INTEGER NOT NULL CHECK (net_minor_units >= 0),
          vat_rate_basis_points INTEGER NOT NULL CHECK (
            vat_rate_basis_points IN (0, 800, 2300)
          ),
          vat_minor_units INTEGER NOT NULL CHECK (vat_minor_units >= 0),
          gross_minor_units INTEGER NOT NULL CHECK (gross_minor_units >= 0),
          currency_code TEXT NOT NULL CHECK (
            length(currency_code) = 3 AND
            currency_code GLOB '[A-Z][A-Z][A-Z]'
          ),
          payment_method TEXT CHECK (
            payment_method IN ('cash', 'card', 'bank_transfer', 'blik', 'other')
          ),
          source TEXT NOT NULL CHECK (
            source IN (
              'manual',
              'receipt_ocr',
              'invoice_ocr',
              'imported',
              'offer_conversion'
            )
          ),
          note TEXT,
          revision INTEGER NOT NULL DEFAULT 1 CHECK (revision > 0),
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          CHECK (gross_minor_units = net_minor_units + vat_minor_units),
          CHECK (
            (quantity_unscaled IS NULL AND quantity_scale IS NULL AND unit IS NULL)
            OR
            (quantity_unscaled IS NOT NULL AND quantity_scale IS NOT NULL AND unit IS NOT NULL)
          ),
          CHECK (
            (lifecycle = 'draft' AND financial_status = 'planned')
            OR
            (
              (entry_type = 'offer' AND financial_status = 'planned')
              OR
              (
                entry_type = 'planned'
                AND financial_status IN ('planned', 'ordered', 'disputed')
              )
              OR
              (
                entry_type = 'cost'
                AND financial_status IN (
                  'ordered', 'due', 'paid', 'returned', 'disputed'
                )
              )
            )
          ),
          UNIQUE (id, project_id),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX cost_entries_project_date_idx
        ON $costEntriesTable (project_id, entry_date_utc_ms DESC, id ASC)
      ''');
      await database.execute('''
        CREATE INDEX cost_entries_project_lifecycle_idx
        ON $costEntriesTable (
          project_id,
          lifecycle,
          entry_type,
          financial_status
        )
      ''');
      await database.execute('''
        CREATE INDEX cost_entries_project_stage_idx
        ON $costEntriesTable (project_id, stage_id, entry_date_utc_ms DESC, id)
      ''');
      await database.execute('''
        CREATE INDEX cost_entries_project_category_idx
        ON $costEntriesTable (
          project_id,
          category_id,
          entry_date_utc_ms DESC,
          id
        )
      ''');
      await database.execute('''
        CREATE INDEX cost_entries_project_supplier_idx
        ON $costEntriesTable (
          project_id,
          supplier_id,
          entry_date_utc_ms DESC,
          id
        )
      ''');
      await database.execute('''
        CREATE INDEX cost_entries_project_status_idx
        ON $costEntriesTable (
          project_id,
          financial_status,
          entry_date_utc_ms DESC,
          id
        )
      ''');

      await database.execute('''
        CREATE TABLE $costAttachmentsTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          display_name TEXT NOT NULL,
          original_storage_key TEXT NOT NULL,
          preview_storage_key TEXT,
          media_type TEXT,
          byte_size INTEGER NOT NULL CHECK (byte_size >= 0),
          sha256 TEXT,
          source TEXT NOT NULL CHECK (source IN ('file_picker', 'camera', 'scanner')),
          availability TEXT NOT NULL CHECK (
            availability IN ('importing', 'available', 'missing', 'deleting')
          ),
          imported_at_utc_ms INTEGER NOT NULL,
          UNIQUE (id, project_id),
          UNIQUE (project_id, original_storage_key),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX attachments_project_imported_idx
        ON $costAttachmentsTable (project_id, imported_at_utc_ms DESC, id)
      ''');
      await database.execute('''
        CREATE INDEX attachments_project_hash_idx
        ON $costAttachmentsTable (project_id, sha256)
      ''');

      await database.execute('''
        CREATE TABLE $costEntryAttachmentsTable (
          project_id TEXT NOT NULL,
          cost_entry_id TEXT NOT NULL,
          attachment_id TEXT NOT NULL,
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          PRIMARY KEY (project_id, cost_entry_id, attachment_id),
          UNIQUE (project_id, cost_entry_id, sort_order),
          FOREIGN KEY (cost_entry_id, project_id)
            REFERENCES $costEntriesTable(id, project_id) ON DELETE CASCADE,
          FOREIGN KEY (attachment_id, project_id)
            REFERENCES $costAttachmentsTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX cost_entry_attachments_attachment_idx
        ON $costEntryAttachmentsTable (project_id, attachment_id)
      ''');

      await database.execute('''
        CREATE TABLE $costEntryRevisionsTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          cost_entry_id TEXT NOT NULL,
          revision INTEGER NOT NULL CHECK (revision > 0),
          action TEXT NOT NULL CHECK (
            action IN (
              'created',
              'draft_saved',
              'draft_replaced',
              'confirmed',
              'details_updated',
              'status_changed',
              'correction_added'
            )
          ),
          snapshot_json TEXT NOT NULL,
          created_at_utc_ms INTEGER NOT NULL,
          UNIQUE (project_id, cost_entry_id, revision),
          FOREIGN KEY (cost_entry_id, project_id)
            REFERENCES $costEntriesTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX cost_entry_revisions_entry_idx
        ON $costEntryRevisionsTable (
          project_id,
          cost_entry_id,
          revision DESC
        )
      ''');

      await database.execute('''
        CREATE TABLE $costCorrectionsTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          cost_entry_id TEXT NOT NULL,
          reason TEXT NOT NULL CHECK (
            reason IN (
              'returned_goods',
              'price_correction',
              'vat_correction',
              'reversal'
            )
          ),
          net_delta_minor_units INTEGER NOT NULL,
          vat_delta_minor_units INTEGER NOT NULL,
          gross_delta_minor_units INTEGER NOT NULL,
          vat_rate_basis_points INTEGER NOT NULL CHECK (
            vat_rate_basis_points IN (0, 800, 2300)
          ),
          currency_code TEXT NOT NULL CHECK (
            length(currency_code) = 3 AND
            currency_code GLOB '[A-Z][A-Z][A-Z]'
          ),
          note TEXT,
          created_at_utc_ms INTEGER NOT NULL,
          CHECK (gross_delta_minor_units != 0),
          CHECK (
            gross_delta_minor_units =
              net_delta_minor_units + vat_delta_minor_units
          ),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id) ON DELETE CASCADE,
          FOREIGN KEY (cost_entry_id, project_id)
            REFERENCES $costEntriesTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX cost_corrections_entry_created_idx
        ON $costCorrectionsTable (cost_entry_id, created_at_utc_ms, id)
      ''');
    }

    if (fromVersion < 4 && toVersion >= 4) {
      await database.execute('''
        CREATE TABLE $projectStagesTable (
          project_id TEXT NOT NULL,
          id TEXT NOT NULL,
          template_stage_key TEXT,
          custom_name TEXT,
          status TEXT NOT NULL CHECK (
            status IN ('planned', 'in_progress', 'blocked', 'completed')
          ),
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          planned_start_utc_ms INTEGER,
          planned_end_utc_ms INTEGER,
          planned_budget_minor_units INTEGER CHECK (
            planned_budget_minor_units >= 0
          ),
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          PRIMARY KEY (project_id, id),
          UNIQUE (project_id, template_stage_key),
          CHECK (
            (template_stage_key IS NOT NULL AND custom_name IS NULL)
            OR
            (template_stage_key IS NULL AND custom_name IS NOT NULL)
          ),
          CHECK (
            planned_start_utc_ms IS NULL
            OR planned_end_utc_ms IS NULL
            OR planned_end_utc_ms >= planned_start_utc_ms
          ),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX project_stages_project_order_idx
        ON $projectStagesTable (project_id, sort_order, id)
      ''');
      await database.execute('''
        CREATE INDEX project_stages_project_status_idx
        ON $projectStagesTable (project_id, status, sort_order)
      ''');

      await database.execute('''
        CREATE TABLE $checklistItemsTable (
          project_id TEXT NOT NULL,
          id TEXT NOT NULL,
          stage_id TEXT NOT NULL,
          template_item_key TEXT,
          custom_title TEXT,
          status TEXT NOT NULL CHECK (
            status IN ('todo', 'in_progress', 'blocked', 'completed', 'skipped')
          ),
          importance TEXT NOT NULL CHECK (
            importance IN ('low', 'normal', 'high', 'critical')
          ),
          due_at_utc_ms INTEGER,
          assignee_label TEXT,
          note TEXT,
          risk_if_skipped TEXT,
          status_reason TEXT,
          evidence_requirement TEXT NOT NULL CHECK (
            evidence_requirement IN ('none', 'any_attachment', 'photo')
          ),
          evidence_waiver_comment TEXT,
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          PRIMARY KEY (project_id, id),
          UNIQUE (project_id, stage_id, template_item_key),
          CHECK (
            (template_item_key IS NOT NULL AND custom_title IS NULL)
            OR
            (template_item_key IS NULL AND custom_title IS NOT NULL)
          ),
          CHECK (
            status != 'skipped'
            OR (status_reason IS NOT NULL AND length(trim(status_reason)) > 0)
          ),
          FOREIGN KEY (project_id, stage_id)
            REFERENCES $projectStagesTable(project_id, id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX checklist_items_stage_order_idx
        ON $checklistItemsTable (project_id, stage_id, sort_order, id)
      ''');
      await database.execute('''
        CREATE INDEX checklist_items_project_due_idx
        ON $checklistItemsTable (project_id, due_at_utc_ms, status)
      ''');

      await database.execute('''
        CREATE TABLE $checklistItemAttachmentsTable (
          project_id TEXT NOT NULL,
          checklist_item_id TEXT NOT NULL,
          attachment_id TEXT NOT NULL,
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          PRIMARY KEY (project_id, checklist_item_id, attachment_id),
          UNIQUE (project_id, checklist_item_id, sort_order),
          FOREIGN KEY (project_id, checklist_item_id)
            REFERENCES $checklistItemsTable(project_id, id) ON DELETE CASCADE,
          FOREIGN KEY (attachment_id, project_id)
            REFERENCES $costAttachmentsTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX checklist_item_attachments_attachment_idx
        ON $checklistItemAttachmentsTable (project_id, attachment_id)
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
