import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/exports/data/local_cost_csv_export_gateway.dart';
import 'package:budowapro/features/exports/domain/cost_csv_export.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late AppDatabase database;
  late SqliteCostRepository costs;
  late File sharedFile;
  late List<int> sharedBytes;
  var id = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_csv_export_test_',
    );
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(temporaryDirectory.path, 'budowapro.db'),
    );
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 7, 15),
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    costs = SqliteCostRepository(
      database: database,
      idGenerator: () => 'cost-${++id}',
      utcNow: () => DateTime.utc(2026, 7, 15, 12, id),
    );
  });

  tearDown(() async {
    await database.close();
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'writes selected columns for every filtered page and shares the file',
    () async {
      for (var index = 0; index < 105; index++) {
        await costs.create(
          ConfirmedCostEntryInput(
            _input(
              name: index == 0 ? '=2+2' : 'Koszt $index',
              supplierId: index.isEven ? 'wybrany' : 'pominięty',
              note: index == 0 ? 'A;"B"\nC' : null,
            ),
          ),
        );
      }
      final query = CostQuery(
        projectId: 'project-1',
        supplierIds: const <String>{'wybrany'},
        sort: CostSort.oldest,
      );
      final gateway = LocalCostCsvExportGateway(
        repository: costs,
        directoryProvider: () async => temporaryDirectory,
        shareFile: (file) async {
          sharedFile = file;
          sharedBytes = await file.readAsBytes();
        },
        utcNow: () => DateTime.utc(2026, 7, 20, 8, 30),
      );

      final result = await gateway.exportAndShare(
        CostCsvExportRequest(
          query: query,
          columns: const <CostCsvColumn>[
            CostCsvColumn.name,
            CostCsvColumn.effectiveGross,
            CostCsvColumn.note,
          ],
          labels: _labels(),
        ),
      );

      final bytes = sharedBytes;
      final csv = String.fromCharCodes(bytes.skip(3));
      expect(bytes.take(3), <int>[0xEF, 0xBB, 0xBF]);
      expect(result.recordCount, 53);
      expect(csv.split('\r\n').where((line) => line.isNotEmpty), hasLength(54));
      expect(csv, startsWith('Nazwa;Brutto po korektach;Notatka\r\n'));
      expect(csv, contains("'=2+2;123,00;\"A;\"\"B\"\"\nC\"\r\n"));
      expect(sharedFile.path, endsWith('.csv'));
      expect(await sharedFile.exists(), isFalse);
    },
  );

  test(
    'exports a corrected gross value without changing the original column',
    () async {
      final cost = await costs.create(
        ConfirmedCostEntryInput(_input(name: 'Zwrot', supplierId: 'wybrany')),
      );
      await costs.addCorrection(
        CostCorrectionInput(
          projectId: 'project-1',
          costEntryId: cost.id,
          reason: CostCorrectionReason.returnedGoods,
          delta: VatBreakdown.fromGross(_pln(-2300), VatRate.standard23),
        ),
      );
      final gateway = LocalCostCsvExportGateway(
        repository: costs,
        directoryProvider: () async => temporaryDirectory,
        shareFile: (file) async {
          sharedFile = file;
          sharedBytes = await file.readAsBytes();
        },
        utcNow: () => DateTime.utc(2026, 7, 20, 8, 30),
      );

      await gateway.exportAndShare(
        CostCsvExportRequest(
          query: CostQuery(projectId: 'project-1'),
          columns: const <CostCsvColumn>[
            CostCsvColumn.effectiveGross,
            CostCsvColumn.originalGross,
          ],
          labels: _labels(),
        ),
      );

      final csv = String.fromCharCodes(sharedBytes.skip(3));
      expect(csv, contains('Brutto po korektach;Brutto pierwotne\r\n'));
      expect(csv, contains('100,00;123,00\r\n'));
      expect(await sharedFile.exists(), isFalse);
    },
  );
}

CostEntryInput _input({
  required String name,
  required String supplierId,
  String? note,
}) {
  return CostEntryInput(
    projectId: 'project-1',
    name: name,
    type: CostEntryType.cost,
    status: CostStatus.paid,
    amount: VatBreakdown.fromNet(_pln(10000), VatRate.standard23),
    entryDate: DateTime.utc(2026, 7, 15),
    supplierId: supplierId,
    paymentMethod: CostPaymentMethod.bankTransfer,
    source: CostSource.manual,
    note: note,
  );
}

Money _pln(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');

CostCsvLabels _labels() {
  return CostCsvLabels(
    headers: <CostCsvColumn, String>{
      for (final column in CostCsvColumn.values) column: column.name,
      CostCsvColumn.name: 'Nazwa',
      CostCsvColumn.effectiveGross: 'Brutto po korektach',
      CostCsvColumn.originalGross: 'Brutto pierwotne',
      CostCsvColumn.note: 'Notatka',
    },
    types: const <CostEntryType, String>{
      CostEntryType.cost: 'Koszt',
      CostEntryType.offer: 'Oferta',
      CostEntryType.planned: 'Plan',
    },
    components: const <CostComponent, String>{
      CostComponent.material: 'Materiał',
      CostComponent.labor: 'Robocizna',
      CostComponent.mixed: 'Materiał + robocizna',
      CostComponent.unassigned: 'Nieprzypisane',
    },
    statuses: const <CostStatus, String>{
      CostStatus.planned: 'Planowany',
      CostStatus.ordered: 'Zamówiony',
      CostStatus.due: 'Do zapłaty',
      CostStatus.paid: 'Opłacony',
      CostStatus.returned: 'Zwrot',
      CostStatus.disputed: 'Sporne',
    },
    lifecycles: const <CostLifecycle, String>{
      CostLifecycle.draft: 'Szkic',
      CostLifecycle.confirmed: 'Zatwierdzony',
    },
    paymentMethods: const <CostPaymentMethod, String>{
      CostPaymentMethod.cash: 'Gotówka',
      CostPaymentMethod.card: 'Karta',
      CostPaymentMethod.bankTransfer: 'Przelew',
      CostPaymentMethod.blik: 'BLIK',
      CostPaymentMethod.other: 'Inna',
    },
    sources: const <CostSource, String>{
      CostSource.manual: 'Ręcznie',
      CostSource.receiptOcr: 'Paragon OCR',
      CostSource.invoiceOcr: 'Faktura OCR',
      CostSource.imported: 'Import',
      CostSource.offerConversion: 'Z oferty',
    },
    emptyValue: '',
  );
}
