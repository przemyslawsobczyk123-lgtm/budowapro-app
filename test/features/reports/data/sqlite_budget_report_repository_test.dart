import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/reports/data/sqlite_budget_report_repository.dart';
import 'package:budowapro/features/reports/domain/budget_report.dart';
import 'package:budowapro/features/reports/domain/budget_report_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late AppDatabase database;
  late String databasePath;
  late SqliteCostRepository costs;
  late SqliteBudgetReportRepository reports;
  var nextId = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_budget_report_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 1, 1),
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
        plannedBudgetMinorUnits: 200000,
      ),
    );
    costs = SqliteCostRepository(
      database: database,
      idGenerator: () => 'entry-${++nextId}',
      utcNow: () => DateTime.utc(2026, 7, 1, 12, nextId),
    );
    reports = SqliteBudgetReportRepository(database: database);
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('aggregates the financial fixture after corrections', () async {
    final paid = await costs.create(
      ConfirmedCostEntryInput(
        _entry(
          name: 'Beton',
          gross: 100000,
          status: CostStatus.paid,
          stageId: 'stage-zero',
          categoryId: 'materials',
          supplierId: 'supplier-a',
          date: DateTime.utc(2026, 1, 15, 12),
        ),
      ),
    );
    await costs.addCorrection(
      CostCorrectionInput(
        projectId: 'project-1',
        costEntryId: paid.id,
        reason: CostCorrectionReason.returnedGoods,
        delta: VatBreakdown.fromGross(_pln(-10000), VatRate.zero),
      ),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        _entry(
          name: 'Elektryk',
          gross: 50000,
          status: CostStatus.due,
          stageId: 'installations',
          categoryId: 'labour',
          supplierId: 'supplier-b',
          date: DateTime(2026, 2),
        ),
      ),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        _entry(
          name: 'Koszt bez przypisania',
          gross: 10000,
          status: CostStatus.ordered,
          stageId: null,
          categoryId: null,
          supplierId: null,
          date: DateTime.utc(2026, 2, 20, 12),
        ),
      ),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        _entry(
          name: 'Oferta okien',
          gross: 70000,
          type: CostEntryType.offer,
          status: CostStatus.planned,
        ),
      ),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        _entry(
          name: 'Plan ogrodu',
          gross: 40000,
          type: CostEntryType.planned,
          status: CostStatus.planned,
        ),
      ),
    );
    await costs.saveDraft(CostDraftInput(_entry(name: 'Szkic', gross: 99999)));

    final report = await reports.load(projectId: 'project-1');

    expect(report.plan, _pln(200000));
    expect(report.committed, _pln(150000));
    expect(report.paid, _pln(90000));
    expect(report.remaining, _pln(50000));
    expect(report.costRecordCount, 3);
    expect(
      report
          .slicesFor(BudgetBreakdownDimension.stage)
          .map((slice) => (slice.key, slice.committed.minorUnits)),
      [('stage-zero', 90000), ('installations', 50000), (null, 10000)],
    );
    expect(
      report
          .slicesFor(BudgetBreakdownDimension.month)
          .map((slice) => (slice.key, slice.committed.minorUnits)),
      [('2026-01', 90000), ('2026-02', 60000)],
    );
    final unassigned = await costs.list(
      CostQuery(
        projectId: 'project-1',
        types: const <CostEntryType>{CostEntryType.cost},
        missingAssignments: const <CostMissingAssignment>{
          CostMissingAssignment.stage,
        },
      ),
      PageRequest(),
    );
    expect(unassigned.items.single.name, 'Koszt bez przypisania');
    final february = await costs.list(
      CostQuery(
        projectId: 'project-1',
        types: const <CostEntryType>{CostEntryType.cost},
        fromInclusive: DateTime(2026, 2).toUtc(),
        toExclusive: DateTime(2026, 3).toUtc(),
      ),
      PageRequest(),
    );
    expect(february.items.map((entry) => entry.name), {
      'Elektryk',
      'Koszt bez przypisania',
    });
  });

  test('returns useful empty totals and rejects an unknown project', () async {
    final report = await reports.load(projectId: 'project-1');

    expect(report.committed, _pln(0));
    expect(report.paid, _pln(0));
    expect(report.costRecordCount, 0);
    expect(report.slicesFor(BudgetBreakdownDimension.stage), isEmpty);
    await expectLater(
      reports.load(projectId: 'missing'),
      throwsA(isA<BudgetReportProjectNotFoundException>()),
    );
  });
}

CostEntryInput _entry({
  required String name,
  required int gross,
  CostEntryType type = CostEntryType.cost,
  CostStatus status = CostStatus.planned,
  String? stageId = 'stage-zero',
  String? categoryId = 'materials',
  String? supplierId = 'supplier-a',
  DateTime? date,
}) {
  return CostEntryInput(
    projectId: 'project-1',
    name: name,
    type: type,
    status: status,
    amount: VatBreakdown.fromGross(_pln(gross), VatRate.zero),
    entryDate: date ?? DateTime.utc(2026, 1, 1, 12),
    stageId: stageId,
    categoryId: categoryId,
    supplierId: supplierId,
  );
}

Money _pln(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');
