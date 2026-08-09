import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/cost_spreadsheet_parser.dart';
import 'package:budowapro/features/costs/data/cost_spreadsheet_picker.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_spreadsheet_import_gateway.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('imports valid spreadsheet rows as confirmed planned costs', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'budowapro_cost_import_gateway_',
    );
    final database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(temporary.path, 'budowapro.db'),
    );
    addTearDown(() async {
      await database.close();
      await temporary.delete(recursive: true);
    });
    final projectRepository = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporary.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 8, 9),
    );
    await projectRepository.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    var nextId = 0;
    final repository = SqliteCostRepository(
      database: database,
      idGenerator: () => 'cost-${++nextId}',
      utcNow: () => DateTime.utc(2026, 8, 9, 12),
    );
    final gateway = LocalCostSpreadsheetImportGateway(
      repository: repository,
      picker: _FakePicker(
        PickedCostSpreadsheet(
          fileName: 'kosztorys.csv',
          bytes: Uint8List.fromList(
            utf8.encode('Nazwa;Koszt\nBeton;1234,56\nBłędny;abc\n'),
          ),
        ),
      ),
      parser: const CostSpreadsheetParser(),
      utcNow: () => DateTime.utc(2026, 8, 9, 12),
    );

    final table = await gateway.pickFile();
    final preview = gateway.preview(
      table!,
      nameColumnIndex: 0,
      amountColumnIndex: 1,
    );
    final count = await gateway.importRows(
      projectId: 'project-1',
      currencyCode: 'PLN',
      preview: preview,
      type: CostEntryType.planned,
      component: CostComponent.material,
      vatRate: VatRate.standard23,
      stageId: 'state_zero',
    );
    final entries = await repository.list(
      CostQuery(projectId: 'project-1'),
      PageRequest(),
    );

    expect(count, 1);
    expect(entries.items.single.name, 'Beton');
    expect(entries.items.single.type, CostEntryType.planned);
    expect(entries.items.single.status, CostStatus.planned);
    expect(entries.items.single.amount.gross.minorUnits, 123456);
    expect(entries.items.single.input.source, CostSource.imported);
    expect(entries.items.single.input.stageId, 'state_zero');
  });
}

final class _FakePicker implements CostSpreadsheetPicker {
  const _FakePicker(this.result);

  final PickedCostSpreadsheet result;

  @override
  Future<PickedCostSpreadsheet?> pick() async => result;
}
