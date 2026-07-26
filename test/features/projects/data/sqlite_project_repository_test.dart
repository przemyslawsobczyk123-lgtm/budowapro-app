import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late ProjectFileStore fileStore;
  late AppDatabase appDatabase;
  late SqliteProjectRepository repository;
  late DateTime now;
  var nextIdentifier = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_project_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    fileStore = ProjectFileStore(rootDirectory: temporaryDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    now = DateTime.utc(2026, 7, 15, 10);
    repository = SqliteProjectRepository(
      database: appDatabase,
      fileStore: fileStore,
      idGenerator: () => 'project-${++nextIdentifier}',
      utcNow: () => now,
    );
  });

  tearDown(() async {
    await appDatabase.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'created and selected project survives reopening the database',
    () async {
      final created = await repository.create(
        ProjectDraft(
          name: "Dom O'Connor",
          locationLabel: 'Kraków',
          type: ProjectType.houseBuild,
          template: ProjectTemplate.houseConstruction,
          areaSquareMeters: 132,
          plannedBudgetMinorUnits: 42000000,
        ),
      );
      await appDatabase.close();

      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      repository = SqliteProjectRepository(
        database: appDatabase,
        fileStore: fileStore,
        idGenerator: () => 'unused',
        utcNow: () => now,
      );
      final selected = await repository.selected();

      expect(selected?.id, created.id);
      expect(selected?.name, "Dom O'Connor");
      expect(selected?.plannedBudgetMinorUnits, 42000000);
      expect(selected?.currentStage, ProjectStageKey.formalities);
    },
  );

  test('switching projects keeps each configuration isolated', () async {
    final house = await repository.create(_houseDraft('Dom'));
    final apartment = await repository.create(_renovationDraft('Mieszkanie'));

    await repository.select(house.id);

    expect((await repository.selected())?.id, house.id);
    expect(
      (await repository.findById(house.id))?.template,
      ProjectTemplate.houseConstruction,
    );
    expect(
      (await repository.findById(apartment.id))?.template,
      ProjectTemplate.renovation,
    );
  });

  test('updates fields without replacing project identity', () async {
    final created = await repository.create(_houseDraft('Dom'));
    final rawDatabase = await appDatabase.open();
    await rawDatabase.update(
      AppDatabase.projectsTable,
      <String, Object?>{'template_version': 3},
      where: 'id = ?',
      whereArgs: <Object?>[created.id],
    );
    now = DateTime.utc(2026, 7, 16, 12);

    final updated = await repository.update(
      created.id,
      ProjectDraft(
        name: 'Remont domu',
        type: ProjectType.houseRenovation,
        template: ProjectTemplate.renovation,
        currencyCode: 'EUR',
        areaSquareMeters: 140,
        plannedBudgetMinorUnits: 25000000,
        currentStage: ProjectStageKey.demolition,
        dateFormat: ProjectDateFormat.yearMonthDay,
      ),
    );

    expect(updated.id, created.id);
    expect(updated.createdAtUtc, created.createdAtUtc);
    expect(updated.updatedAtUtc, now);
    expect(updated.type, ProjectType.houseRenovation);
    expect(updated.currentStage, ProjectStageKey.demolition);
    expect(updated.currencyCode, 'EUR');
    expect(updated.templateVersion, 3);
  });

  test(
    'persists the site preparation stage with legacy compatibility',
    () async {
      final created = await repository.create(_houseDraft('Dom'));

      await repository.update(
        created.id,
        ProjectDraft(
          name: created.name,
          type: ProjectType.houseBuild,
          template: ProjectTemplate.houseConstruction,
          currentStage: ProjectStageKey.sitePreparation,
        ),
      );
      await appDatabase.close();
      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      repository = SqliteProjectRepository(
        database: appDatabase,
        fileStore: fileStore,
        idGenerator: () => 'unused',
        utcNow: () => now,
      );

      expect(
        (await repository.findById(created.id))?.currentStage,
        ProjectStageKey.sitePreparation,
      );
      final rawDatabase = await appDatabase.open();
      final row = (await rawDatabase.query(
        AppDatabase.projectsTable,
        columns: const <String>['current_stage_key', 'current_stage_key_v2'],
        where: 'id = ?',
        whereArgs: <Object?>[created.id],
      )).single;
      expect(row['current_stage_key'], 'formalities');
      expect(row['current_stage_key_v2'], 'site_preparation');
    },
  );

  test('rejects a currency change after a cost entry is recorded', () async {
    final created = await repository.create(_houseDraft('Dom'));
    await _insertCostEntry(appDatabase, projectId: created.id, id: 'cost-1');

    await expectLater(
      repository.update(
        created.id,
        ProjectDraft(
          name: 'Zmieniony dom',
          type: ProjectType.houseBuild,
          template: ProjectTemplate.houseConstruction,
          currencyCode: 'EUR',
        ),
      ),
      throwsA(isA<ProjectCurrencyLockedException>()),
    );

    final persisted = await repository.findById(created.id);
    expect(persisted?.currencyCode, 'PLN');
    expect(persisted?.name, 'Dom');
  });

  test('lists active projects with stable pagination', () async {
    final first = await repository.create(_houseDraft('Pierwszy'));
    now = now.add(const Duration(minutes: 1));
    await repository.create(_renovationDraft('Drugi'));
    now = now.add(const Duration(minutes: 1));
    await repository.create(_houseDraft('Trzeci'));
    await repository.setArchived(first.id, isArchived: true);

    final firstPage = await repository.list(PageRequest(limit: 1));
    final secondPage = await repository.list(firstPage.nextRequest!);

    expect(firstPage.totalCount, 2);
    expect(firstPage.items, hasLength(1));
    expect(secondPage.items, hasLength(1));
    expect(secondPage.items.single.id, isNot(firstPage.items.single.id));
  });

  test('delete reports files and selects a fallback project', () async {
    final fallback = await repository.create(_houseDraft('Zapasowy'));
    final removed = await repository.create(_renovationDraft('Usuwany'));
    final source = File(p.join(temporaryDirectory.path, 'receipt-source.pdf'));
    await source.writeAsString('receipt');
    await fileStore.importFile(
      projectId: removed.id,
      area: ProjectFileArea.originals,
      source: source,
      fileName: 'receipt.pdf',
    );

    final impact = await repository.deletionImpact(removed.id);
    expect(impact.project.id, removed.id);
    expect(impact.linkedFileCount, 1);

    await repository.delete(removed.id);

    expect(await repository.findById(removed.id), isNull);
    expect((await repository.selected())?.id, fallback.id);
    expect(
      await fileStore
          .directoryFor(projectId: removed.id, area: ProjectFileArea.originals)
          .parent
          .exists(),
      isFalse,
    );
  });

  test('deletion impact counts linked cost entries', () async {
    final project = await repository.create(_houseDraft('Koszty'));
    await _insertCostEntry(appDatabase, projectId: project.id, id: 'cost-1');

    final impact = await repository.deletionImpact(project.id);

    expect(impact.linkedRecordCount, 1);
  });

  test('deletion impact counts open capture drafts', () async {
    final project = await repository.create(_houseDraft('Skrzynka'));
    final database = await appDatabase.open();
    await database.insert(AppDatabase.captureDraftsTable, <String, Object?>{
      'id': 'capture-1',
      'project_id': project.id,
      'capture_type': 'note',
      'status': 'ready',
      'title': 'Ustalenia',
      'content': 'Przesunąć gniazdo.',
      'gross_amount_minor_units': null,
      'vat_rate_basis_points': null,
      'scheduled_at_utc_ms': null,
      'time_zone_id': null,
      'target_type': null,
      'target_id': null,
      'created_at_utc_ms': 0,
      'updated_at_utc_ms': 0,
    });

    final impact = await repository.deletionImpact(project.id);

    expect(impact.linkedRecordCount, 1);
  });

  test(
    'failed file deletion keeps the project selected and retryable',
    () async {
      final project = await repository.create(_houseDraft('Nie usuwaj'));
      final failingRepository = SqliteProjectRepository(
        database: appDatabase,
        fileStore: const _FailingProjectFileStorage(),
        idGenerator: () => 'unused',
        utcNow: () => now,
      );

      await expectLater(
        failingRepository.delete(project.id),
        throwsA(isA<FileSystemException>()),
      );

      expect((await failingRepository.findById(project.id))?.id, project.id);
      expect((await failingRepository.selected())?.id, project.id);
      final database = await appDatabase.open();
      final row = await database.query(
        AppDatabase.projectsTable,
        columns: const <String>['deletion_pending'],
        where: 'id = ?',
        whereArgs: <Object?>[project.id],
      );
      expect(row.single['deletion_pending'], 0);
    },
  );

  test('recovers a pending deletion left by an interrupted process', () async {
    final fallback = await repository.create(_houseDraft('Zapasowy'));
    final pending = await repository.create(_houseDraft('Do odzyskania'));
    final source = File(p.join(temporaryDirectory.path, 'pending-source.pdf'));
    await source.writeAsString('pending');
    await fileStore.importFile(
      projectId: pending.id,
      area: ProjectFileArea.originals,
      source: source,
      fileName: 'pending.pdf',
    );
    final database = await appDatabase.open();
    await database.update(
      AppDatabase.projectsTable,
      <String, Object?>{'deletion_pending': 1},
      where: 'id = ?',
      whereArgs: <Object?>[pending.id],
    );

    await repository.recoverPendingDeletions();

    expect(await repository.findById(pending.id), isNull);
    expect((await repository.selected())?.id, fallback.id);
    expect(await fileStore.countProjectFiles(pending.id), 0);
  });

  test('select rejects a missing or archived project', () async {
    await expectLater(
      repository.select('missing'),
      throwsA(isA<ProjectNotFoundException>()),
    );
    final archived = await repository.create(_houseDraft('Archiwalny'));
    await repository.setArchived(archived.id, isArchived: true);

    await expectLater(
      repository.select(archived.id),
      throwsA(isA<ProjectNotFoundException>()),
    );
  });
}

ProjectDraft _houseDraft(String name) {
  return ProjectDraft(
    name: name,
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
  );
}

ProjectDraft _renovationDraft(String name) {
  return ProjectDraft(
    name: name,
    type: ProjectType.apartmentRenovation,
    template: ProjectTemplate.renovation,
  );
}

Future<void> _insertCostEntry(
  AppDatabase database, {
  required String projectId,
  required String id,
}) async {
  final executor = await database.open();
  await executor.insert(AppDatabase.costEntriesTable, <String, Object?>{
    'id': id,
    'project_id': projectId,
    'name': 'Material',
    'entry_type': 'cost',
    'financial_status': 'paid',
    'lifecycle': 'confirmed',
    'entry_date_utc_ms': 0,
    'net_minor_units': 100,
    'vat_rate_basis_points': 2300,
    'vat_minor_units': 23,
    'gross_minor_units': 123,
    'currency_code': 'PLN',
    'source': 'manual',
    'created_at_utc_ms': 0,
    'updated_at_utc_ms': 0,
  });
}

final class _FailingProjectFileStorage implements ProjectFileStorage {
  const _FailingProjectFileStorage();

  @override
  Future<int> countProjectFiles(String projectId) async => 1;

  @override
  Future<void> deleteProjectFiles(String projectId) async {
    throw const FileSystemException('simulated deletion failure');
  }
}
