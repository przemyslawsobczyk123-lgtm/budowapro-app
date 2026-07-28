import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:budowapro/core/storage/local_restore_journal.dart';
import 'package:crypto/crypto.dart';
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

  static const int schemaVersion = 11;
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
  static const String scheduleEventsTable = 'schedule_events';
  static const String scheduleDependenciesTable = 'schedule_dependencies';
  static const String scheduleDateChangesTable = 'schedule_date_changes';
  static const String reminderPreferencesTable = 'reminder_preferences';
  static const String contactsTable = 'contacts';
  static const String contactRolesTable = 'contact_roles';
  static const String contactStageAssignmentsTable =
      'contact_stage_assignments';
  static const String siteVisitsTable = 'site_visits';
  static const String contractorQuotesTable = 'contractor_quotes';
  static const String quoteScopeLinesTable = 'quote_scope_lines';
  static const String quoteAttachmentsTable = 'quote_attachments';
  static const String documentMetadataTable = 'document_metadata';
  static const String documentContextLinksTable = 'document_context_links';
  static const String receiptImportsTable = 'receipt_imports';
  static const String captureDraftsTable = 'capture_drafts';
  static const String captureDraftAttachmentsTable =
      'capture_draft_attachments';
  static const String schemaVersionKey = 'schema_version';
  static const Set<String> requiredTableNames = <String>{
    metadataTable,
    projectsTable,
    costEntriesTable,
    costAttachmentsTable,
    costEntryAttachmentsTable,
    costEntryRevisionsTable,
    costCorrectionsTable,
    projectStagesTable,
    checklistItemsTable,
    checklistItemAttachmentsTable,
    scheduleEventsTable,
    scheduleDependenciesTable,
    scheduleDateChangesTable,
    reminderPreferencesTable,
    contactsTable,
    contactRolesTable,
    contactStageAssignmentsTable,
    siteVisitsTable,
    contractorQuotesTable,
    quoteScopeLinesTable,
    quoteAttachmentsTable,
    documentMetadataTable,
    documentContextLinksTable,
    receiptImportsTable,
    captureDraftsTable,
    captureDraftAttachmentsTable,
  };

  final DatabaseFactory _factory;
  final String _path;
  Completer<void>? _maintenanceRelease;

  Database? _database;
  Future<Database>? _opening;
  Future<void>? _closing;

  static Future<AppDatabase> onDevice() async {
    final supportDirectory = await getApplicationSupportDirectory();
    await supportDirectory.create(recursive: true);
    await LocalRestoreJournal.recover(
      rootDirectory: supportDirectory,
      databaseFileName: databaseFileName,
      validateCommitted: _validateRecoveredDatabase,
    );
    return AppDatabase(
      factory: databaseFactory,
      path: p.join(supportDirectory.path, databaseFileName),
    );
  }

  Future<Database> open() async {
    await _waitForMaintenance();
    return _openWithoutMaintenanceWait();
  }

  Future<Database> _openWithoutMaintenanceWait() async {
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
        onConfigure: _configureConnection,
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

  Future<DatabaseRestoreInspection> inspectRestoreCandidate({
    required File databaseFile,
    required int expectedSchemaVersion,
    required int expectedProjectCount,
  }) async {
    if (expectedSchemaVersion != schemaVersion ||
        expectedProjectCount < 0 ||
        expectedProjectCount > 10000) {
      throw const FormatException('Unsupported backup database version');
    }
    return _inspectRestoreCandidateExact(
      databaseFile: databaseFile,
      expectedSchemaVersion: expectedSchemaVersion,
      expectedProjectCount: expectedProjectCount,
    );
  }

  Future<DatabaseRestoreInspection> prepareRestoreCandidate({
    required File databaseFile,
    required int sourceSchemaVersion,
    required int expectedProjectCount,
  }) async {
    if (sourceSchemaVersion < 1 ||
        sourceSchemaVersion > schemaVersion ||
        expectedProjectCount < 0 ||
        expectedProjectCount > 10000) {
      throw const FormatException('Unsupported backup database version');
    }
    final sourceInspection = await _inspectRestoreCandidateExact(
      databaseFile: databaseFile,
      expectedSchemaVersion: sourceSchemaVersion,
      expectedProjectCount: expectedProjectCount,
    );
    if (sourceSchemaVersion == schemaVersion) return sourceInspection;

    Database? migrationDatabase;
    try {
      migrationDatabase = await _factory.openDatabase(
        databaseFile.path,
        options: OpenDatabaseOptions(
          version: schemaVersion,
          singleInstance: false,
          onConfigure: _configureConnection,
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
    } on Object {
      throw const FormatException('Backup database migration failed');
    } finally {
      await migrationDatabase?.close();
    }

    final migratedInspection = await _inspectRestoreCandidateExact(
      databaseFile: databaseFile,
      expectedSchemaVersion: schemaVersion,
      expectedProjectCount: expectedProjectCount,
    );
    if (migratedInspection.projectIds.length !=
            sourceInspection.projectIds.length ||
        !migratedInspection.projectIds.containsAll(
          sourceInspection.projectIds,
        )) {
      throw const FormatException('Backup migration changed project identity');
    }
    return migratedInspection;
  }

  Future<DatabaseRestoreInspection> _inspectRestoreCandidateExact({
    required File databaseFile,
    required int expectedSchemaVersion,
    required int expectedProjectCount,
  }) async {
    final candidate = await _factory.openDatabase(
      databaseFile.path,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    try {
      final actualVersion = await candidate.getVersion();
      if (actualVersion != expectedSchemaVersion) {
        throw const FormatException('Backup database version does not match');
      }

      final integrityRows = await candidate.rawQuery('PRAGMA integrity_check');
      if (integrityRows.isEmpty ||
          integrityRows.any(
            (row) => row.values.length != 1 || row.values.single != 'ok',
          )) {
        throw const FormatException('Backup database integrity check failed');
      }
      if ((await candidate.rawQuery('PRAGMA foreign_key_check')).isNotEmpty) {
        throw const FormatException('Backup database has broken references');
      }

      final expectedFingerprint = await _createExpectedSchemaFingerprint(
        databaseFile,
        expectedSchemaVersion: expectedSchemaVersion,
      );
      final candidateFingerprint = await _schemaFingerprint(candidate);
      if (candidateFingerprint != expectedFingerprint) {
        throw const FormatException('Backup database schema does not match');
      }

      final metadataRows = await candidate.query(
        metadataTable,
        columns: const <String>['value'],
        where: 'key = ?',
        whereArgs: const <Object?>[schemaVersionKey],
        limit: 1,
      );
      if (metadataRows.length != 1 ||
          metadataRows.single['value'] != expectedSchemaVersion.toString()) {
        throw const FormatException('Backup schema metadata does not match');
      }

      final projectCountRows = await candidate.rawQuery(
        'SELECT COUNT(*) AS total FROM $projectsTable',
      );
      final actualProjectCount = projectCountRows.single['total'];
      if (actualProjectCount is! int ||
          actualProjectCount != expectedProjectCount) {
        throw const FormatException('Backup project count does not match');
      }
      final projectRows = await candidate.query(
        projectsTable,
        columns: const <String>['id'],
        orderBy: 'id ASC',
      );
      final projectIds = <String>{};
      for (final row in projectRows) {
        final projectId = row['id'];
        if (projectId is! String || !_isSafePathSegment(projectId)) {
          throw const FormatException('Backup contains an invalid project id');
        }
        projectIds.add(projectId);
      }

      final attachmentCountRows = await candidate.rawQuery(
        'SELECT COUNT(*) AS total FROM $costAttachmentsTable',
      );
      final attachmentCount = attachmentCountRows.single['total'];
      if (attachmentCount is! int || attachmentCount > 50000) {
        throw const FormatException('Backup contains too many attachments');
      }
      final attachments = <DatabaseRestoreAttachment>[];
      const pageSize = 1000;
      for (var offset = 0; offset < attachmentCount; offset += pageSize) {
        final attachmentRows = await candidate.query(
          costAttachmentsTable,
          columns: const <String>[
            'project_id',
            'original_storage_key',
            'preview_storage_key',
            'byte_size',
            'sha256',
            'availability',
          ],
          orderBy: 'project_id ASC, id ASC',
          limit: pageSize,
          offset: offset,
        );
        for (final row in attachmentRows) {
          final projectId = row['project_id'];
          final originalStorageKey = row['original_storage_key'];
          final previewStorageKey = row['preview_storage_key'];
          final byteSize = row['byte_size'];
          final checksum = row['sha256'];
          final availability = row['availability'];
          if (projectId is! String ||
              !projectIds.contains(projectId) ||
              originalStorageKey is! String ||
              !_isSafePathSegment(originalStorageKey) ||
              (previewStorageKey != null &&
                  (previewStorageKey is! String ||
                      !_isSafePathSegment(previewStorageKey))) ||
              byteSize is! int ||
              byteSize < 0 ||
              (checksum != null &&
                  (checksum is! String ||
                      !RegExp(r'^[a-f0-9]{64}$').hasMatch(checksum))) ||
              availability is! String) {
            throw const FormatException(
              'Backup contains invalid attachment metadata',
            );
          }
          attachments.add(
            DatabaseRestoreAttachment(
              projectId: projectId,
              originalStorageKey: originalStorageKey,
              previewStorageKey: previewStorageKey as String?,
              byteSize: byteSize,
              sha256: checksum as String?,
              isAvailable: availability == 'available',
            ),
          );
        }
      }

      return DatabaseRestoreInspection(
        schemaVersion: actualVersion,
        projectIds: projectIds,
        attachments: attachments,
      );
    } finally {
      await candidate.close();
    }
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
    await _waitForMaintenance();
    return _closeWithoutMaintenanceWait();
  }

  Future<void> _closeWithoutMaintenanceWait() async {
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

  Future<T> runMaintenance<T>(
    Future<T> Function(AppDatabaseMaintenance maintenance) action,
  ) async {
    while (true) {
      final current = _maintenanceRelease;
      if (current == null) break;
      await current.future;
    }

    final release = Completer<void>();
    _maintenanceRelease = release;
    try {
      await _closeWithoutMaintenanceWait();
      return await action(_AppDatabaseMaintenance(this));
    } finally {
      try {
        final current = _database;
        if (current == null || !current.isOpen) {
          await _openWithoutMaintenanceWait();
        }
      } finally {
        if (identical(_maintenanceRelease, release)) {
          _maintenanceRelease = null;
        }
        release.complete();
      }
    }
  }

  Future<void> _waitForMaintenance() async {
    while (true) {
      final maintenance = _maintenanceRelease;
      if (maintenance == null) return;
      await maintenance.future;
    }
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

    if (fromVersion < 5 && toVersion >= 5) {
      await database.execute('''
        CREATE TABLE $scheduleEventsTable (
          project_id TEXT NOT NULL,
          id TEXT NOT NULL,
          title TEXT NOT NULL,
          kind TEXT NOT NULL CHECK (
            kind IN ('task', 'visit', 'delivery', 'acceptance', 'payment')
          ),
          status TEXT NOT NULL CHECK (
            status IN ('planned', 'in_progress', 'blocked', 'completed', 'cancelled')
          ),
          starts_at_utc_ms INTEGER NOT NULL,
          ends_at_utc_ms INTEGER,
          time_zone_id TEXT NOT NULL,
          is_all_day INTEGER NOT NULL CHECK (is_all_day IN (0, 1)),
          stage_id TEXT,
          assignee TEXT,
          note TEXT,
          reminder_enabled INTEGER NOT NULL CHECK (reminder_enabled IN (0, 1)),
          reminder_lead_minutes INTEGER NOT NULL CHECK (
            reminder_lead_minutes BETWEEN 0 AND 10080
          ),
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          PRIMARY KEY (project_id, id),
          CHECK (
            ends_at_utc_ms IS NULL OR ends_at_utc_ms >= starts_at_utc_ms
          ),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX schedule_events_project_start_idx
        ON $scheduleEventsTable (project_id, starts_at_utc_ms, id)
      ''');
      await database.execute('''
        CREATE INDEX schedule_events_project_status_idx
        ON $scheduleEventsTable (project_id, status, starts_at_utc_ms, id)
      ''');

      await database.execute('''
        CREATE TABLE $scheduleDependenciesTable (
          project_id TEXT NOT NULL,
          event_id TEXT NOT NULL,
          blocking_event_id TEXT NOT NULL,
          decision_due_at_utc_ms INTEGER,
          created_at_utc_ms INTEGER NOT NULL,
          PRIMARY KEY (project_id, event_id, blocking_event_id),
          CHECK (event_id != blocking_event_id),
          FOREIGN KEY (project_id, event_id)
            REFERENCES $scheduleEventsTable(project_id, id) ON DELETE CASCADE,
          FOREIGN KEY (project_id, blocking_event_id)
            REFERENCES $scheduleEventsTable(project_id, id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX schedule_dependencies_blocker_idx
        ON $scheduleDependenciesTable (project_id, blocking_event_id, event_id)
      ''');

      await database.execute('''
        CREATE TABLE $scheduleDateChangesTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          event_id TEXT NOT NULL,
          previous_starts_at_utc_ms INTEGER NOT NULL,
          new_starts_at_utc_ms INTEGER NOT NULL,
          previous_ends_at_utc_ms INTEGER,
          new_ends_at_utc_ms INTEGER,
          previous_time_zone_id TEXT NOT NULL,
          new_time_zone_id TEXT NOT NULL,
          reason TEXT,
          changed_at_utc_ms INTEGER NOT NULL,
          FOREIGN KEY (project_id, event_id)
            REFERENCES $scheduleEventsTable(project_id, id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX schedule_date_changes_event_idx
        ON $scheduleDateChangesTable (
          project_id,
          event_id,
          changed_at_utc_ms DESC,
          id DESC
        )
      ''');

      await database.execute('''
        CREATE TABLE $reminderPreferencesTable (
          id TEXT PRIMARY KEY NOT NULL CHECK (id = 'app'),
          task_enabled INTEGER NOT NULL CHECK (task_enabled IN (0, 1)),
          visit_enabled INTEGER NOT NULL CHECK (visit_enabled IN (0, 1)),
          delivery_enabled INTEGER NOT NULL CHECK (delivery_enabled IN (0, 1)),
          acceptance_enabled INTEGER NOT NULL CHECK (acceptance_enabled IN (0, 1)),
          payment_enabled INTEGER NOT NULL CHECK (payment_enabled IN (0, 1)),
          default_lead_minutes INTEGER NOT NULL CHECK (
            default_lead_minutes BETWEEN 0 AND 10080
          ),
          all_day_reminder_minute INTEGER NOT NULL CHECK (
            all_day_reminder_minute BETWEEN 0 AND 1439
          ),
          updated_at_utc_ms INTEGER NOT NULL
        )
      ''');
    }

    if (fromVersion < 6 && toVersion >= 6) {
      await database.execute('''
        CREATE TABLE $contactsTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          display_name TEXT NOT NULL,
          kind TEXT NOT NULL CHECK (kind IN ('person', 'company')),
          phone TEXT,
          email TEXT,
          tax_id TEXT,
          note TEXT,
          rating INTEGER CHECK (rating BETWEEN 1 AND 5),
          is_archived INTEGER NOT NULL DEFAULT 0 CHECK (
            is_archived IN (0, 1)
          ),
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          UNIQUE (project_id, id),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX contacts_project_name_idx
        ON $contactsTable (project_id, is_archived, display_name, id)
      ''');

      await database.execute('''
        CREATE TABLE $contactRolesTable (
          project_id TEXT NOT NULL,
          contact_id TEXT NOT NULL,
          role TEXT NOT NULL CHECK (
            role IN (
              'general_contractor',
              'site_manager',
              'architect',
              'electrician',
              'plumber',
              'heating_and_ventilation',
              'surveyor',
              'roofer',
              'carpenter',
              'plasterer',
              'tiler',
              'painter',
              'supplier',
              'inspector',
              'other'
            )
          ),
          PRIMARY KEY (project_id, contact_id, role),
          FOREIGN KEY (project_id, contact_id)
            REFERENCES $contactsTable(project_id, id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX contact_roles_project_role_idx
        ON $contactRolesTable (project_id, role, contact_id)
      ''');

      await database.execute('''
        CREATE TABLE $contactStageAssignmentsTable (
          project_id TEXT NOT NULL,
          contact_id TEXT NOT NULL,
          stage_id TEXT NOT NULL,
          PRIMARY KEY (project_id, contact_id, stage_id),
          FOREIGN KEY (project_id, contact_id)
            REFERENCES $contactsTable(project_id, id) ON DELETE CASCADE,
          FOREIGN KEY (project_id, stage_id)
            REFERENCES $projectStagesTable(project_id, id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX contact_stages_project_stage_idx
        ON $contactStageAssignmentsTable (project_id, stage_id, contact_id)
      ''');

      await database.execute('''
        CREATE TABLE $siteVisitsTable (
          project_id TEXT NOT NULL,
          event_id TEXT NOT NULL,
          contact_id TEXT NOT NULL,
          expected_result TEXT NOT NULL,
          status TEXT NOT NULL CHECK (
            status IN ('planned', 'completed', 'cancelled', 'no_show')
          ),
          result TEXT,
          agreements TEXT,
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          PRIMARY KEY (project_id, event_id),
          FOREIGN KEY (project_id, event_id)
            REFERENCES $scheduleEventsTable(project_id, id) ON DELETE CASCADE,
          FOREIGN KEY (project_id, contact_id)
            REFERENCES $contactsTable(project_id, id) ON DELETE RESTRICT,
          CHECK (
            status != 'completed'
            OR (result IS NOT NULL AND length(trim(result)) > 0)
          )
        )
      ''');
      await database.execute('''
        CREATE INDEX site_visits_contact_start_idx
        ON $siteVisitsTable (project_id, contact_id, status, event_id)
      ''');
    }

    if (fromVersion < 7 && toVersion >= 7) {
      await database.execute('''
        CREATE TABLE $contractorQuotesTable (
          project_id TEXT NOT NULL,
          id TEXT NOT NULL,
          contact_id TEXT NOT NULL,
          stage_id TEXT,
          title TEXT NOT NULL,
          variant_name TEXT NOT NULL,
          status TEXT NOT NULL CHECK (
            status IN ('received', 'accepted', 'rejected')
          ),
          received_at_utc_ms INTEGER NOT NULL,
          valid_until_utc_ms INTEGER NOT NULL,
          net_minor_units INTEGER NOT NULL CHECK (net_minor_units >= 0),
          vat_rate_basis_points INTEGER NOT NULL CHECK (
            vat_rate_basis_points IN (0, 800, 2300)
          ),
          vat_minor_units INTEGER NOT NULL CHECK (vat_minor_units >= 0),
          gross_minor_units INTEGER NOT NULL CHECK (gross_minor_units > 0),
          currency_code TEXT NOT NULL CHECK (
            length(currency_code) = 3 AND
            currency_code GLOB '[A-Z][A-Z][A-Z]'
          ),
          note TEXT,
          accepted_cost_entry_id TEXT,
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          PRIMARY KEY (project_id, id),
          UNIQUE (project_id, accepted_cost_entry_id),
          CHECK (valid_until_utc_ms >= received_at_utc_ms),
          CHECK (gross_minor_units = net_minor_units + vat_minor_units),
          CHECK (
            (status = 'accepted' AND accepted_cost_entry_id IS NOT NULL)
            OR
            (status != 'accepted' AND accepted_cost_entry_id IS NULL)
          ),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id) ON DELETE CASCADE,
          FOREIGN KEY (project_id, contact_id)
            REFERENCES $contactsTable(project_id, id) ON DELETE RESTRICT,
          FOREIGN KEY (project_id, stage_id)
            REFERENCES $projectStagesTable(project_id, id) ON DELETE RESTRICT,
          FOREIGN KEY (accepted_cost_entry_id, project_id)
            REFERENCES $costEntriesTable(id, project_id) ON DELETE RESTRICT
        )
      ''');
      await database.execute('''
        CREATE INDEX contractor_quotes_project_status_idx
        ON $contractorQuotesTable (
          project_id,
          status,
          valid_until_utc_ms,
          id
        )
      ''');
      await database.execute('''
        CREATE INDEX contractor_quotes_contact_idx
        ON $contractorQuotesTable (
          project_id,
          contact_id,
          received_at_utc_ms DESC,
          id
        )
      ''');

      await database.execute('''
        CREATE TABLE $quoteScopeLinesTable (
          project_id TEXT NOT NULL,
          quote_id TEXT NOT NULL,
          kind TEXT NOT NULL CHECK (kind IN ('included', 'excluded')),
          comparison_key TEXT NOT NULL,
          label TEXT NOT NULL,
          details TEXT,
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          PRIMARY KEY (project_id, quote_id, kind, comparison_key),
          UNIQUE (project_id, quote_id, kind, sort_order),
          FOREIGN KEY (project_id, quote_id)
            REFERENCES $contractorQuotesTable(project_id, id) ON DELETE CASCADE
        )
      ''');

      await database.execute('''
        CREATE TABLE $quoteAttachmentsTable (
          project_id TEXT NOT NULL,
          quote_id TEXT NOT NULL,
          attachment_id TEXT NOT NULL,
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          PRIMARY KEY (project_id, quote_id, attachment_id),
          UNIQUE (project_id, quote_id, sort_order),
          FOREIGN KEY (project_id, quote_id)
            REFERENCES $contractorQuotesTable(project_id, id) ON DELETE CASCADE,
          FOREIGN KEY (attachment_id, project_id)
            REFERENCES $costAttachmentsTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX quote_attachments_attachment_idx
        ON $quoteAttachmentsTable (project_id, attachment_id)
      ''');
    }

    if (fromVersion < 8 && toVersion >= 8) {
      await database.execute('''
        CREATE TABLE $documentMetadataTable (
          project_id TEXT NOT NULL,
          attachment_id TEXT NOT NULL,
          title TEXT NOT NULL,
          document_type TEXT NOT NULL CHECK (
            document_type IN (
              'receipt',
              'invoice',
              'quote',
              'contract',
              'deliveryNote',
              'protocol',
              'warranty',
              'instruction',
              'map',
              'photo',
              'other'
            )
          ),
          description TEXT,
          document_date_utc_ms INTEGER,
          warranty_starts_at_utc_ms INTEGER,
          warranty_ends_at_utc_ms INTEGER,
          warranty_reminder_at_utc_ms INTEGER,
          updated_at_utc_ms INTEGER NOT NULL,
          PRIMARY KEY (project_id, attachment_id),
          CHECK (
            (warranty_starts_at_utc_ms IS NULL AND warranty_ends_at_utc_ms IS NULL)
            OR
            (
              warranty_starts_at_utc_ms IS NOT NULL
              AND warranty_ends_at_utc_ms IS NOT NULL
              AND warranty_ends_at_utc_ms >= warranty_starts_at_utc_ms
            )
          ),
          CHECK (
            warranty_reminder_at_utc_ms IS NULL
            OR
            (
              warranty_ends_at_utc_ms IS NOT NULL
              AND warranty_reminder_at_utc_ms <= warranty_ends_at_utc_ms
            )
          ),
          FOREIGN KEY (attachment_id, project_id)
            REFERENCES $costAttachmentsTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX document_metadata_project_type_date_idx
        ON $documentMetadataTable (
          project_id,
          document_type,
          document_date_utc_ms DESC,
          attachment_id
        )
      ''');
      await database.execute('''
        CREATE INDEX document_metadata_project_warranty_idx
        ON $documentMetadataTable (
          project_id,
          warranty_ends_at_utc_ms,
          attachment_id
        )
      ''');

      await database.execute('''
        CREATE TABLE $documentContextLinksTable (
          project_id TEXT NOT NULL,
          attachment_id TEXT NOT NULL,
          relation_type TEXT NOT NULL CHECK (
            relation_type IN (
              'stage',
              'contact',
              'room',
              'decision',
              'defect',
              'device'
            )
          ),
          target_id TEXT NOT NULL,
          label TEXT NOT NULL,
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          PRIMARY KEY (
            project_id,
            attachment_id,
            relation_type,
            target_id
          ),
          UNIQUE (project_id, attachment_id, sort_order),
          FOREIGN KEY (attachment_id, project_id)
            REFERENCES $costAttachmentsTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX document_context_links_target_idx
        ON $documentContextLinksTable (
          project_id,
          relation_type,
          target_id,
          attachment_id
        )
      ''');
    }

    if (fromVersion < 9 && toVersion >= 9) {
      await database.execute('''
        CREATE TABLE $receiptImportsTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          attachment_id TEXT NOT NULL,
          seller_name TEXT NOT NULL,
          seller_key TEXT NOT NULL,
          purchase_date_utc_ms INTEGER NOT NULL,
          document_number TEXT,
          total_gross_minor_units INTEGER NOT NULL CHECK (
            total_gross_minor_units > 0
          ),
          currency_code TEXT NOT NULL CHECK (
            length(currency_code) = 3 AND
            currency_code GLOB '[A-Z][A-Z][A-Z]'
          ),
          duplicate_acknowledged INTEGER NOT NULL DEFAULT 0 CHECK (
            duplicate_acknowledged IN (0, 1)
          ),
          total_mismatch_acknowledged INTEGER NOT NULL DEFAULT 0 CHECK (
            total_mismatch_acknowledged IN (0, 1)
          ),
          created_at_utc_ms INTEGER NOT NULL,
          UNIQUE (id, project_id),
          UNIQUE (project_id, attachment_id),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id)
            ON DELETE CASCADE,
          FOREIGN KEY (attachment_id, project_id)
            REFERENCES $costAttachmentsTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX receipt_imports_project_signature_idx
        ON $receiptImportsTable (
          project_id,
          seller_key,
          purchase_date_utc_ms,
          total_gross_minor_units,
          currency_code
        )
      ''');
    }

    if (fromVersion < 10 && toVersion >= 10) {
      final projectColumns = (await database.rawQuery(
        'PRAGMA table_info($projectsTable)',
      )).map((row) => row['name']).whereType<String>().toSet();
      if (projectColumns.contains('current_stage_key')) {
        if (!projectColumns.contains('current_stage_key_v2')) {
          await database.execute(
            'ALTER TABLE $projectsTable ADD COLUMN current_stage_key_v2 TEXT',
          );
        }
        await database.execute('''
          UPDATE $projectsTable
          SET current_stage_key_v2 = current_stage_key
          WHERE current_stage_key_v2 IS NULL
        ''');
      }
    }

    if (fromVersion < 11 && toVersion >= 11) {
      await database.execute('''
        CREATE TABLE IF NOT EXISTS $captureDraftsTable (
          id TEXT PRIMARY KEY NOT NULL,
          project_id TEXT NOT NULL,
          capture_type TEXT NOT NULL CHECK (
            capture_type IN (
              'photo',
              'document',
              'note',
              'voice',
              'cost',
              'task',
              'decision',
              'defect'
            )
          ),
          status TEXT NOT NULL CHECK (
            status IN ('needs_review', 'ready', 'classified')
          ),
          title TEXT,
          content TEXT,
          gross_amount_minor_units INTEGER CHECK (
            gross_amount_minor_units > 0
          ),
          vat_rate_basis_points INTEGER CHECK (
            vat_rate_basis_points IN (0, 800, 2300)
          ),
          scheduled_at_utc_ms INTEGER,
          time_zone_id TEXT,
          target_type TEXT CHECK (
            target_type IN (
              'document',
              'cost_draft',
              'schedule_task',
              'note',
              'decision',
              'defect'
            )
          ),
          target_id TEXT,
          created_at_utc_ms INTEGER NOT NULL,
          updated_at_utc_ms INTEGER NOT NULL,
          UNIQUE (id, project_id),
          CHECK (
            (scheduled_at_utc_ms IS NULL AND time_zone_id IS NULL)
            OR
            (scheduled_at_utc_ms IS NOT NULL AND time_zone_id IS NOT NULL)
          ),
          CHECK (
            (
              status = 'classified'
              AND target_type IS NOT NULL
              AND target_id IS NOT NULL
            )
            OR
            (
              status != 'classified'
              AND target_type IS NULL
              AND target_id IS NULL
            )
          ),
          FOREIGN KEY (project_id) REFERENCES $projectsTable(id)
            ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX IF NOT EXISTS capture_drafts_project_status_date_idx
        ON $captureDraftsTable (
          project_id,
          status,
          created_at_utc_ms DESC,
          id DESC
        )
      ''');
      await database.execute('''
        CREATE INDEX IF NOT EXISTS capture_drafts_project_type_date_idx
        ON $captureDraftsTable (
          project_id,
          capture_type,
          created_at_utc_ms DESC,
          id DESC
        )
      ''');

      await database.execute('''
        CREATE TABLE IF NOT EXISTS $captureDraftAttachmentsTable (
          project_id TEXT NOT NULL,
          capture_id TEXT NOT NULL,
          attachment_id TEXT NOT NULL,
          sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
          PRIMARY KEY (project_id, capture_id, attachment_id),
          UNIQUE (project_id, capture_id, sort_order),
          FOREIGN KEY (capture_id, project_id)
            REFERENCES $captureDraftsTable(id, project_id) ON DELETE CASCADE,
          FOREIGN KEY (attachment_id, project_id)
            REFERENCES $costAttachmentsTable(id, project_id) ON DELETE CASCADE
        )
      ''');
      await database.execute('''
        CREATE INDEX IF NOT EXISTS capture_draft_attachments_attachment_idx
        ON $captureDraftAttachmentsTable (project_id, attachment_id)
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

  static bool _isSafePathSegment(String value) {
    return value.isNotEmpty &&
        value != '.' &&
        value != '..' &&
        !value.contains('/') &&
        !value.contains(r'\') &&
        !value.contains('\u0000') &&
        !p.posix.isAbsolute(value) &&
        !p.windows.isAbsolute(value);
  }

  static Future<bool> _validateRecoveredDatabase(
    File databaseFile,
    Directory projects,
  ) async {
    Database? candidate;
    try {
      candidate = await databaseFactory.openDatabase(
        databaseFile.path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      if (await candidate.getVersion() != schemaVersion) return false;
      final quickCheck = await candidate.rawQuery('PRAGMA quick_check');
      if (quickCheck.isEmpty ||
          quickCheck.any(
            (row) => row.values.length != 1 || row.values.single != 'ok',
          )) {
        return false;
      }
      return (await candidate.rawQuery('PRAGMA foreign_key_check')).isEmpty;
    } on Object {
      return false;
    } finally {
      await candidate?.close();
    }
  }

  Future<String> _createExpectedSchemaFingerprint(
    File candidateFile, {
    required int expectedSchemaVersion,
  }) async {
    final referencePath = '${candidateFile.path}.schema-reference';
    Database? reference;
    try {
      reference = await _factory.openDatabase(
        referencePath,
        options: OpenDatabaseOptions(
          version: expectedSchemaVersion,
          singleInstance: false,
          onConfigure: _configureConnection,
          onCreate: (database, version) {
            return _migrate(database, fromVersion: 0, toVersion: version);
          },
        ),
      );
      return await _schemaFingerprint(reference);
    } finally {
      await reference?.close();
      await _factory.deleteDatabase(referencePath);
    }
  }

  static Future<String> _schemaFingerprint(Database database) async {
    final rows = await database.rawQuery('''
      SELECT type, name, tbl_name, sql
      FROM sqlite_master
      WHERE type IN ('table', 'index', 'trigger', 'view')
        AND name NOT LIKE 'sqlite_%'
      ORDER BY type ASC, name ASC
    ''');
    return sha256.convert(utf8.encode(jsonEncode(rows))).toString();
  }

  static Future<void> _configureConnection(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
    await database.execute('PRAGMA secure_delete = ON');
  }
}

abstract interface class AppDatabaseMaintenance {
  File get databaseFile;

  Future<void> createSnapshot(File destination);

  Future<void> deleteSidecarFiles();

  Future<void> close();

  Future<Database> reopen();
}

final class _AppDatabaseMaintenance implements AppDatabaseMaintenance {
  const _AppDatabaseMaintenance(this._owner);

  final AppDatabase _owner;

  @override
  File get databaseFile => File(_owner._path);

  @override
  Future<void> createSnapshot(File destination) async {
    final destinationType = await FileSystemEntity.type(
      destination.path,
      followLinks: false,
    );
    if (destinationType != FileSystemEntityType.notFound) {
      throw const FileSystemException('Snapshot destination already exists');
    }
    await destination.parent.create(recursive: true);
    final database = await _owner._openWithoutMaintenanceWait();
    await database.rawQuery('VACUUM INTO ?', <Object?>[destination.path]);
    if (!await destination.exists() || await destination.length() == 0) {
      throw const FileSystemException('Database snapshot was not created');
    }
  }

  @override
  Future<void> deleteSidecarFiles() async {
    for (final suffix in const <String>['-wal', '-shm', '-journal']) {
      final sidecar = File('${databaseFile.path}$suffix');
      final type = await FileSystemEntity.type(
        sidecar.path,
        followLinks: false,
      );
      if (type == FileSystemEntityType.notFound) continue;
      if (type != FileSystemEntityType.file) {
        throw const FileSystemException(
          'Database sidecar path is not a regular file',
        );
      }
      await sidecar.delete();
    }
  }

  @override
  Future<void> close() => _owner._closeWithoutMaintenanceWait();

  @override
  Future<Database> reopen() => _owner._openWithoutMaintenanceWait();
}

final class DatabaseRestoreInspection {
  DatabaseRestoreInspection({
    required this.schemaVersion,
    required Set<String> projectIds,
    required List<DatabaseRestoreAttachment> attachments,
  }) : projectIds = Set<String>.unmodifiable(projectIds),
       attachments = List<DatabaseRestoreAttachment>.unmodifiable(attachments);

  final int schemaVersion;
  final Set<String> projectIds;
  final List<DatabaseRestoreAttachment> attachments;
}

final class DatabaseRestoreAttachment {
  const DatabaseRestoreAttachment({
    required this.projectId,
    required this.originalStorageKey,
    required this.previewStorageKey,
    required this.byteSize,
    required this.sha256,
    required this.isAvailable,
  });

  final String projectId;
  final String originalStorageKey;
  final String? previewStorageKey;
  final int byteSize;
  final String? sha256;
  final bool isAvailable;
}
