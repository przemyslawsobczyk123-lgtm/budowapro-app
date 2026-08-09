import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a preview with Polish and international money formats', () {
    final table = CostSpreadsheetTable(
      fileName: 'kosztorys.csv',
      columns: const <String>['Nazwa', 'Koszt'],
      rows: const <CostSpreadsheetRow>[
        CostSpreadsheetRow(
          sourceRowNumber: 2,
          cells: <String>['Beton', '1.234,56'],
        ),
        CostSpreadsheetRow(
          sourceRowNumber: 3,
          cells: <String>['Stal', '1,234.56'],
        ),
      ],
      headerDetected: true,
    );

    final preview = buildCostSpreadsheetPreview(
      table,
      nameColumnIndex: 0,
      amountColumnIndex: 1,
    );

    expect(preview.validRows.map((row) => row.grossMinorUnits), <int>[
      123456,
      123456,
    ]);
    expect(preview.invalidRows, isEmpty);
  });

  test('accepts repeated thousands groups and rejects malformed groups', () {
    final table = CostSpreadsheetTable(
      fileName: 'kosztorys.csv',
      columns: const <String>['Nazwa', 'Koszt'],
      rows: const <CostSpreadsheetRow>[
        CostSpreadsheetRow(
          sourceRowNumber: 2,
          cells: <String>['Dom', '1.234.567,89'],
        ),
        CostSpreadsheetRow(
          sourceRowNumber: 3,
          cells: <String>['Bledna pozycja', '1.23.456,78'],
        ),
      ],
      headerDetected: true,
    );

    final preview = buildCostSpreadsheetPreview(
      table,
      nameColumnIndex: 0,
      amountColumnIndex: 1,
    );

    expect(preview.validRows.single.grossMinorUnits, 123456789);
    expect(
      preview.invalidRows.single.error,
      CostSpreadsheetRowError.invalidAmount,
    );
  });

  test('reports row-specific name and amount errors before import', () {
    final table = CostSpreadsheetTable(
      fileName: 'kosztorys.csv',
      columns: const <String>['Nazwa', 'Koszt'],
      rows: const <CostSpreadsheetRow>[
        CostSpreadsheetRow(sourceRowNumber: 2, cells: <String>['', '100']),
        CostSpreadsheetRow(
          sourceRowNumber: 3,
          cells: <String>['Kabel', 'wartość'],
        ),
      ],
      headerDetected: true,
    );

    final preview = buildCostSpreadsheetPreview(
      table,
      nameColumnIndex: 0,
      amountColumnIndex: 1,
    );

    expect(preview.validRows, isEmpty);
    expect(preview.invalidRows[0].error, CostSpreadsheetRowError.missingName);
    expect(preview.invalidRows[1].error, CostSpreadsheetRowError.invalidAmount);
  });

  test('does not accept a formula as an imported value', () {
    final table = CostSpreadsheetTable(
      fileName: 'kosztorys.xlsx',
      columns: const <String>['Nazwa', 'Koszt'],
      rows: const <CostSpreadsheetRow>[
        CostSpreadsheetRow(
          sourceRowNumber: 2,
          cells: <String>['Beton', '=SUM(B3:B4)'],
          formulaColumnIndexes: <int>{1},
        ),
      ],
      headerDetected: true,
    );

    final preview = buildCostSpreadsheetPreview(
      table,
      nameColumnIndex: 0,
      amountColumnIndex: 1,
    );

    expect(preview.invalidRows.single.error, CostSpreadsheetRowError.formula);
  });
}
