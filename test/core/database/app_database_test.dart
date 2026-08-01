import 'dart:io';
import 'dart:async';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
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
    final secureDelete = await database.rawQuery('PRAGMA secure_delete');
    expect(secureDelete.single.values.single, 1);
    expect(
      await appDatabase!.readMetadata(AppDatabase.schemaVersionKey),
      AppDatabase.schemaVersion.toString(),
    );
    for (final tableName in <String>[
      AppDatabase.projectsTable,
      AppDatabase.costEntriesTable,
      AppDatabase.costAttachmentsTable,
      AppDatabase.costEntryAttachmentsTable,
      AppDatabase.costEntryRevisionsTable,
      AppDatabase.costCorrectionsTable,
      AppDatabase.projectStagesTable,
      AppDatabase.checklistItemsTable,
      AppDatabase.checklistItemAttachmentsTable,
      AppDatabase.scheduleEventsTable,
      AppDatabase.scheduleDependenciesTable,
      AppDatabase.scheduleDateChangesTable,
      AppDatabase.reminderPreferencesTable,
      AppDatabase.contactsTable,
      AppDatabase.contactRolesTable,
      AppDatabase.contactStageAssignmentsTable,
      AppDatabase.siteVisitsTable,
      AppDatabase.contractorQuotesTable,
      AppDatabase.quoteScopeLinesTable,
      AppDatabase.quoteAttachmentsTable,
      AppDatabase.documentMetadataTable,
      AppDatabase.documentContextLinksTable,
      AppDatabase.receiptImportsTable,
      AppDatabase.captureDraftsTable,
      AppDatabase.captureDraftAttachmentsTable,
      AppDatabase.journalEntriesTable,
      AppDatabase.journalEntryAttachmentsTable,
      AppDatabase.journalEntryLinksTable,
      AppDatabase.journalEntryRevisionsTable,
      AppDatabase.technicalAlbumsTable,
      AppDatabase.technicalPhotosTable,
      AppDatabase.technicalPhotoTagsTable,
      AppDatabase.technicalPhotoLinksTable,
      AppDatabase.defectResolutionAttachmentsTable,
      AppDatabase.acceptanceProtocolsTable,
      AppDatabase.acceptanceProtocolDefectsTable,
      AppDatabase.acceptanceProtocolAttachmentsTable,
      AppDatabase.materialsTable,
      AppDatabase.materialDeliveriesTable,
      AppDatabase.materialReturnsTable,
    ]) {
      final table = await database.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: <Object?>['table', tableName],
      );
      expect(table, hasLength(1), reason: 'missing table $tableName');
    }
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

  test('migrates version 2 and preserves existing projects', () async {
    final versionTwoDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE app_metadata (
              key TEXT PRIMARY KEY NOT NULL,
              value TEXT NOT NULL,
              updated_at_utc_ms INTEGER NOT NULL
            )
          ''');
          await database.execute('''
            CREATE TABLE projects (
              id TEXT PRIMARY KEY NOT NULL,
              name TEXT NOT NULL
            )
          ''');
          await database.insert('projects', <String, Object?>{
            'id': 'project-v2',
            'name': 'Existing project',
          });
        },
      ),
    );
    await versionTwoDatabase.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final database = await appDatabase!.open();

    expect(await database.getVersion(), AppDatabase.schemaVersion);
    expect(await database.query(AppDatabase.projectsTable), <Object?>[
      <String, Object?>{'id': 'project-v2', 'name': 'Existing project'},
    ]);
    expect(
      await database.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: <Object?>['table', AppDatabase.costEntriesTable],
      ),
      hasLength(1),
    );
  });

  test('migrates version 8 and preserves existing metadata', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.writeMetadata(
      key: 'preserved-v8-setting',
      value: 'keep-me',
      updatedAt: DateTime.utc(2026, 7, 25),
    );
    final versionEightDatabase = await appDatabase!.open();
    await versionEightDatabase.execute(
      'DROP TABLE ${AppDatabase.receiptImportsTable}',
    );
    await versionEightDatabase.setVersion(8);
    await appDatabase!.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final migrated = await appDatabase!.open();

    expect(await migrated.getVersion(), AppDatabase.schemaVersion);
    expect(await appDatabase!.readMetadata('preserved-v8-setting'), 'keep-me');
    expect(
      await migrated.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: <Object?>['table', AppDatabase.receiptImportsTable],
      ),
      hasLength(1),
    );
  });

  test('migrates version 17 to material tracking without data loss', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.writeMetadata(
      key: 'preserved-v17-setting',
      value: 'keep-me',
      updatedAt: DateTime.utc(2026, 8, 1),
    );
    final versionSeventeen = await appDatabase!.open();
    await versionSeventeen.execute(
      'DROP TABLE ${AppDatabase.materialReturnsTable}',
    );
    await versionSeventeen.execute(
      'DROP TABLE ${AppDatabase.materialDeliveriesTable}',
    );
    await versionSeventeen.execute('DROP TABLE ${AppDatabase.materialsTable}');
    await versionSeventeen.setVersion(17);
    await appDatabase!.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final migrated = await appDatabase!.open();

    expect(await migrated.getVersion(), AppDatabase.schemaVersion);
    expect(await appDatabase!.readMetadata('preserved-v17-setting'), 'keep-me');
    for (final table in <String>[
      AppDatabase.materialsTable,
      AppDatabase.materialDeliveriesTable,
      AppDatabase.materialReturnsTable,
    ]) {
      expect(
        await migrated.query(
          'sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: <Object?>['table', table],
        ),
        hasLength(1),
      );
    }
  });

  test('migrates version 10 and adds the project capture inbox', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.writeMetadata(
      key: 'preserved-v10-setting',
      value: 'keep-me',
      updatedAt: DateTime.utc(2026, 7, 27),
    );
    final versionTenDatabase = await appDatabase!.open();
    await versionTenDatabase.execute(
      'DROP TABLE ${AppDatabase.captureDraftAttachmentsTable}',
    );
    await versionTenDatabase.execute(
      'DROP TABLE ${AppDatabase.captureDraftsTable}',
    );
    await versionTenDatabase.setVersion(10);
    await appDatabase!.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final migrated = await appDatabase!.open();

    expect(await migrated.getVersion(), AppDatabase.schemaVersion);
    expect(await appDatabase!.readMetadata('preserved-v10-setting'), 'keep-me');
    for (final tableName in <String>[
      AppDatabase.captureDraftsTable,
      AppDatabase.captureDraftAttachmentsTable,
    ]) {
      expect(
        await migrated.query(
          'sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: <Object?>['table', tableName],
        ),
        hasLength(1),
      );
    }
    expect(await migrated.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test('migrates version 12 and requires audited decision approval', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projects = SqliteProjectRepository(
      database: appDatabase!,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-v12',
      utcNow: () => DateTime.utc(2026, 7, 30),
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    final versionTwelveDatabase = await appDatabase!.open();
    await versionTwelveDatabase
        .insert(AppDatabase.journalEntriesTable, <String, Object?>{
          'id': 'decision-v12',
          'project_id': 'project-v12',
          'entry_type': 'decision',
          'status': 'approved',
          'title': 'Stara decyzja bez audytu',
          'selected_option': 'Wariant A',
          'occurred_at_utc_ms': 1,
          'created_at_utc_ms': 1,
          'updated_at_utc_ms': 1,
          'revision': 1,
        });
    await versionTwelveDatabase.execute(
      'DROP INDEX journal_entries_project_approval_idx',
    );
    await versionTwelveDatabase.execute(
      'ALTER TABLE ${AppDatabase.journalEntriesTable} '
      'DROP COLUMN approved_by_contact_id',
    );
    await versionTwelveDatabase.execute(
      'ALTER TABLE ${AppDatabase.journalEntriesTable} '
      'DROP COLUMN approved_at_utc_ms',
    );
    await versionTwelveDatabase.execute(
      'ALTER TABLE ${AppDatabase.journalEntryLinksTable} '
      'DROP COLUMN relation_purpose',
    );
    await versionTwelveDatabase.update(
      AppDatabase.metadataTable,
      const <String, Object?>{'value': '12'},
      where: 'key = ?',
      whereArgs: const <Object?>[AppDatabase.schemaVersionKey],
    );
    await versionTwelveDatabase.setVersion(12);
    await appDatabase!.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final migrated = await appDatabase!.open();
    final journalColumns = await migrated.rawQuery(
      'PRAGMA table_info(${AppDatabase.journalEntriesTable})',
    );
    final linkColumns = await migrated.rawQuery(
      'PRAGMA table_info(${AppDatabase.journalEntryLinksTable})',
    );

    expect(await migrated.getVersion(), AppDatabase.schemaVersion);
    expect(
      journalColumns.map((column) => column['name']),
      containsAll(<String>['approved_by_contact_id', 'approved_at_utc_ms']),
    );
    expect(
      linkColumns.map((column) => column['name']),
      contains('relation_purpose'),
    );
    expect(
      await migrated.query(
        AppDatabase.journalEntriesTable,
        columns: const <String>['status'],
        where: 'id = ?',
        whereArgs: const <Object?>['decision-v12'],
      ),
      <Map<String, Object?>>[
        <String, Object?>{'status': 'pending'},
      ],
    );
    expect(await migrated.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test('migrates version 13 and adds technical photo albums', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.writeMetadata(
      key: 'preserved-v13-setting',
      value: 'keep-me',
      updatedAt: DateTime.utc(2026, 7, 31),
    );
    final versionThirteenDatabase = await appDatabase!.open();
    await versionThirteenDatabase.execute(
      'DROP TABLE ${AppDatabase.technicalPhotoTagsTable}',
    );
    await versionThirteenDatabase.execute(
      'DROP TABLE ${AppDatabase.technicalPhotosTable}',
    );
    await versionThirteenDatabase.execute(
      'DROP TABLE ${AppDatabase.technicalAlbumsTable}',
    );
    await versionThirteenDatabase.update(
      AppDatabase.metadataTable,
      const <String, Object?>{'value': '13'},
      where: 'key = ?',
      whereArgs: const <Object?>[AppDatabase.schemaVersionKey],
    );
    await versionThirteenDatabase.setVersion(13);
    await appDatabase!.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final migrated = await appDatabase!.open();

    expect(await migrated.getVersion(), AppDatabase.schemaVersion);
    expect(await appDatabase!.readMetadata('preserved-v13-setting'), 'keep-me');
    for (final tableName in <String>[
      AppDatabase.technicalAlbumsTable,
      AppDatabase.technicalPhotosTable,
      AppDatabase.technicalPhotoTagsTable,
    ]) {
      expect(
        await migrated.query(
          'sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: <Object?>['table', tableName],
        ),
        hasLength(1),
      );
    }
    expect(await migrated.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test(
    'migrates version 14 and preserves defects while adding PUNCH',
    () async {
      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      final projects = SqliteProjectRepository(
        database: appDatabase!,
        fileStore: ProjectFileStore(
          rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
        ),
        idGenerator: () => 'project-v14',
        utcNow: () => DateTime.utc(2026, 7, 31),
      );
      await projects.create(
        ProjectDraft(
          name: 'Dom',
          type: ProjectType.houseBuild,
          template: ProjectTemplate.houseConstruction,
        ),
      );
      final versionFourteenDatabase = await appDatabase!.open();
      await versionFourteenDatabase
          .insert(AppDatabase.journalEntriesTable, <String, Object?>{
            'id': 'legacy-defect',
            'project_id': 'project-v14',
            'entry_type': 'defect',
            'status': 'open',
            'title': 'Stara usterka',
            'occurred_at_utc_ms': 0,
            'created_at_utc_ms': 0,
            'updated_at_utc_ms': 0,
            'revision': 1,
          });
      await versionFourteenDatabase.setVersion(14);
      await versionFourteenDatabase.update(
        AppDatabase.metadataTable,
        const <String, Object?>{'value': '14'},
        where: 'key = ?',
        whereArgs: const <Object?>[AppDatabase.schemaVersionKey],
      );
      await appDatabase!.close();

      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      final migrated = await appDatabase!.open();

      expect(await migrated.getVersion(), AppDatabase.schemaVersion);
      final defect = (await migrated.query(
        AppDatabase.journalEntriesTable,
        where: 'id = ?',
        whereArgs: const <Object?>['legacy-defect'],
      )).single;
      expect(defect['defect_severity'], 'medium');
      expect(defect['requires_resolution_photo'], 0);
      expect(defect['requires_signed_protocol'], 0);
      expect(await migrated.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test('migrates version 15 and marks existing costs as unassigned', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projects = SqliteProjectRepository(
      database: appDatabase!,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-v15',
      utcNow: () => DateTime.utc(2026, 7, 31),
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    final costs = SqliteCostRepository(
      database: appDatabase!,
      idGenerator: () => 'legacy-cost-v15',
      utcNow: () => DateTime.utc(2026, 7, 31),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        CostEntryInput(
          projectId: 'project-v15',
          name: 'Stary koszt',
          type: CostEntryType.cost,
          component: CostComponent.labor,
          status: CostStatus.paid,
          amount: VatBreakdown.fromGross(
            Money(minorUnits: 12345, currencyCode: 'PLN'),
            VatRate.standard23,
          ),
          entryDate: DateTime.utc(2026, 7, 31),
        ),
      ),
    );
    final versionFifteenDatabase = await appDatabase!.open();
    await versionFifteenDatabase.execute(
      'DROP INDEX cost_entries_project_component_idx',
    );
    await versionFifteenDatabase.execute(
      'ALTER TABLE ${AppDatabase.costEntriesTable} '
      'DROP COLUMN cost_component',
    );
    await versionFifteenDatabase.update(
      AppDatabase.metadataTable,
      const <String, Object?>{'value': '15'},
      where: 'key = ?',
      whereArgs: const <Object?>[AppDatabase.schemaVersionKey],
    );
    await versionFifteenDatabase.setVersion(15);
    await appDatabase!.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final migrated = await appDatabase!.open();
    final row = (await migrated.query(
      AppDatabase.costEntriesTable,
      where: 'id = ?',
      whereArgs: const <Object?>['legacy-cost-v15'],
    )).single;

    expect(await migrated.getVersion(), AppDatabase.schemaVersion);
    expect(row['cost_component'], 'unassigned');
    expect(row['gross_minor_units'], 12345);
    expect(await migrated.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test('migrates version 16 by adding room planning tables', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final current = await appDatabase!.open();
    await current.execute('DROP TABLE ${AppDatabase.roomContactLinksTable}');
    await current.execute('DROP TABLE ${AppDatabase.roomRecordLinksTable}');
    await current.execute('DROP TABLE ${AppDatabase.roomChoiceOutputsTable}');
    await current.execute('DROP TABLE ${AppDatabase.roomChoiceVariantsTable}');
    await current.execute('DROP TABLE ${AppDatabase.roomChoicesTable}');
    await current.execute('DROP TABLE ${AppDatabase.roomsTable}');
    await current.update(
      AppDatabase.metadataTable,
      const <String, Object?>{'value': '16'},
      where: 'key = ?',
      whereArgs: const <Object?>[AppDatabase.schemaVersionKey],
    );
    await current.setVersion(16);
    await appDatabase!.close();

    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final migrated = await appDatabase!.open();
    final tableRows = await migrated.query(
      'sqlite_master',
      columns: const <String>['name'],
      where: "type = 'table' AND name IN (?, ?, ?, ?, ?, ?)",
      whereArgs: const <Object?>[
        AppDatabase.roomsTable,
        AppDatabase.roomChoicesTable,
        AppDatabase.roomChoiceVariantsTable,
        AppDatabase.roomChoiceOutputsTable,
        AppDatabase.roomRecordLinksTable,
        AppDatabase.roomContactLinksTable,
      ],
    );

    expect(await migrated.getVersion(), AppDatabase.schemaVersion);
    expect(tableRows.map((row) => row['name']).toSet(), <String>{
      AppDatabase.roomsTable,
      AppDatabase.roomChoicesTable,
      AppDatabase.roomChoiceVariantsTable,
      AppDatabase.roomChoiceOutputsTable,
      AppDatabase.roomRecordLinksTable,
      AppDatabase.roomContactLinksTable,
    });
    expect(await migrated.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test(
    'migrates version 9 for site preparation without losing child rows',
    () async {
      final versionNineDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 9,
          onConfigure: (database) =>
              database.execute('PRAGMA foreign_keys = ON'),
          onCreate: (database, version) async {
            await database.execute('''
              CREATE TABLE app_metadata (
                key TEXT PRIMARY KEY NOT NULL,
                value TEXT NOT NULL,
                updated_at_utc_ms INTEGER NOT NULL
              )
            ''');
            await database.execute('''
        CREATE TABLE projects (
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
              ON projects (
                deletion_pending,
                is_archived,
                updated_at_utc_ms DESC,
                id ASC
              )
            ''');
            await database.execute('''
              CREATE TABLE project_stages (
                project_id TEXT NOT NULL,
                id TEXT NOT NULL,
                PRIMARY KEY (project_id, id),
                FOREIGN KEY (project_id) REFERENCES projects(id)
                  ON DELETE CASCADE
              )
            ''');
            await database.insert('projects', <String, Object?>{
              'id': 'project-v9',
              'name': 'Existing house',
              'location_label': null,
              'project_type': 'house_build',
              'template_key': 'build_house',
              'template_version': 1,
              'currency_code': 'PLN',
              'area_square_meters': null,
              'planned_budget_minor_units': null,
              'planned_start_utc_ms': null,
              'planned_end_utc_ms': null,
              'date_format': 'day_month_year',
              'current_stage_key': 'state_zero',
              'is_archived': 0,
              'deletion_pending': 0,
              'created_at_utc_ms': 1,
              'updated_at_utc_ms': 1,
            });
            await database.insert('project_stages', <String, Object?>{
              'project_id': 'project-v9',
              'id': 'state_zero',
            });
          },
        ),
      );
      await versionNineDatabase.close();

      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      final migrated = await appDatabase!.open();

      expect(await migrated.getVersion(), AppDatabase.schemaVersion);
      expect(
        await migrated.query(
          AppDatabase.projectsTable,
          columns: const <String>['id'],
        ),
        <Map<String, Object?>>[
          <String, Object?>{'id': 'project-v9'},
        ],
      );
      expect(
        await migrated.query(
          AppDatabase.projectStagesTable,
          columns: const <String>['project_id', 'id'],
        ),
        <Map<String, Object?>>[
          <String, Object?>{'project_id': 'project-v9', 'id': 'state_zero'},
        ],
      );
      expect(
        await migrated.update(
          AppDatabase.projectsTable,
          const <String, Object?>{
            'current_stage_key': 'formalities',
            'current_stage_key_v2': 'site_preparation',
          },
          where: 'id = ?',
          whereArgs: const <Object?>['project-v9'],
        ),
        1,
      );
      expect(
        await migrated.query(
          AppDatabase.projectsTable,
          columns: const <String>['current_stage_key', 'current_stage_key_v2'],
        ),
        <Map<String, Object?>>[
          <String, Object?>{
            'current_stage_key': 'formalities',
            'current_stage_key_v2': 'site_preparation',
          },
        ],
      );
      expect(await migrated.rawQuery('PRAGMA foreign_key_check'), isEmpty);

      final migratedProjectSchema =
          (await migrated.query(
                'sqlite_master',
                columns: const <String>['sql'],
                where: 'type = ? AND name = ?',
                whereArgs: const <Object?>['table', AppDatabase.projectsTable],
              )).single['sql']
              as String;
      final freshPath = p.join(temporaryDirectory.path, 'fresh-v10.db');
      final freshDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: freshPath,
      );
      try {
        final fresh = await freshDatabase.open();
        final freshProjectSchema =
            (await fresh.query(
                  'sqlite_master',
                  columns: const <String>['sql'],
                  where: 'type = ? AND name = ?',
                  whereArgs: const <Object?>[
                    'table',
                    AppDatabase.projectsTable,
                  ],
                )).single['sql']
                as String;
        expect(migratedProjectSchema, freshProjectSchema);
      } finally {
        await freshDatabase.close();
        await databaseFactoryFfi.deleteDatabase(freshPath);
      }
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

  test('creates a consistent snapshot while new opens are blocked', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.writeMetadata(
      key: 'snapshot-marker',
      value: 'preserved',
      updatedAt: DateTime.utc(2026, 7, 15),
    );
    final snapshot = File(
      p.join(temporaryDirectory.path, 'snapshot', 'budowapro.db'),
    );
    final entered = Completer<void>();
    final release = Completer<void>();
    final maintenance = appDatabase!.runMaintenance<void>((access) async {
      await access.createSnapshot(snapshot);
      entered.complete();
      await release.future;
    });
    await entered.future;

    var reopened = false;
    final opening = appDatabase!.open().then((database) {
      reopened = database.isOpen;
    });
    await Future<void>.delayed(Duration.zero);
    expect(reopened, isFalse);

    release.complete();
    await Future.wait<void>(<Future<void>>[maintenance, opening]);
    final snapshotDatabase = await databaseFactoryFfi.openDatabase(
      snapshot.path,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    final rows = await snapshotDatabase.query(
      AppDatabase.metadataTable,
      where: 'key = ?',
      whereArgs: <Object?>['snapshot-marker'],
    );
    await snapshotDatabase.close();

    expect(rows.single['value'], 'preserved');
    expect(reopened, isTrue);
  });

  test('removes closed SQLite sidecars before a database swap', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.open();

    await appDatabase!.runMaintenance<void>((maintenance) async {
      for (final suffix in const <String>['-wal', '-shm', '-journal']) {
        await File(
          '${maintenance.databaseFile.path}$suffix',
        ).writeAsString('stale');
      }
      await maintenance.deleteSidecarFiles();
    });

    for (final suffix in const <String>['-wal', '-shm', '-journal']) {
      expect(await File('$databasePath$suffix').exists(), isFalse);
    }
  });

  test('validates a complete read-only restore candidate', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.open();
    final candidate = File(
      p.join(temporaryDirectory.path, 'candidate', 'budowapro.db'),
    );
    await appDatabase!.runMaintenance<void>(
      (maintenance) => maintenance.createSnapshot(candidate),
    );

    final inspection = await appDatabase!.inspectRestoreCandidate(
      databaseFile: candidate,
      expectedSchemaVersion: AppDatabase.schemaVersion,
      expectedProjectCount: 0,
    );

    expect(inspection.schemaVersion, AppDatabase.schemaVersion);
    expect(inspection.projectIds, isEmpty);
    expect(inspection.attachments, isEmpty);
  });

  test('rejects a candidate with mismatched schema metadata', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.open();
    final candidate = File(
      p.join(temporaryDirectory.path, 'candidate', 'budowapro.db'),
    );
    await appDatabase!.runMaintenance<void>(
      (maintenance) => maintenance.createSnapshot(candidate),
    );

    await expectLater(
      appDatabase!.inspectRestoreCandidate(
        databaseFile: candidate,
        expectedSchemaVersion: AppDatabase.schemaVersion - 1,
        expectedProjectCount: 0,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a candidate with an unexpected schema object', () async {
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await appDatabase!.open();
    final candidate = File(
      p.join(temporaryDirectory.path, 'candidate', 'budowapro.db'),
    );
    await appDatabase!.runMaintenance<void>(
      (maintenance) => maintenance.createSnapshot(candidate),
    );
    final modified = await databaseFactoryFfi.openDatabase(
      candidate.path,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    await modified.execute('CREATE TABLE injected_table (value TEXT NOT NULL)');
    await modified.close();

    await expectLater(
      appDatabase!.inspectRestoreCandidate(
        databaseFile: candidate,
        expectedSchemaVersion: AppDatabase.schemaVersion,
        expectedProjectCount: 0,
      ),
      throwsA(isA<FormatException>()),
    );
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
