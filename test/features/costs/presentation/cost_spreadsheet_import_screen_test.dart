import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_spreadsheet_import_gateway.dart';
import 'package:budowapro/features/costs/presentation/cost_spreadsheet_import_screen.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('previews and imports valid spreadsheet rows at 320 px', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gateway = _FakeImportGateway();
    int? importedCount;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          costSpreadsheetImportGatewayProvider.overrideWith(
            (ref) async => gateway,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                key: const ValueKey('openImport'),
                onPressed: () async {
                  importedCount = await Navigator.of(context).push<int>(
                    MaterialPageRoute<int>(
                      builder: (context) => CostSpreadsheetImportScreen(
                        project: _project(),
                        stages: const [],
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('openImport')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wybierz plik'));
    await tester.pumpAndSettle();

    expect(find.text('Poprawne: 1 · Odrzucone: 1'), findsOneWidget);
    expect(find.text('Beton'), findsOneWidget);
    expect(find.textContaining('Nieprawidłowa kwota'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('costSpreadsheetImportSubmit')),
    );
    await tester.tap(find.byKey(const ValueKey('costSpreadsheetImportSubmit')));
    await tester.pumpAndSettle();

    expect(importedCount, 1);
    expect(gateway.importedType, CostEntryType.planned);
    expect(gateway.importedComponent, CostComponent.material);
    expect(gateway.importedVatRate, VatRate.standard23);
  });
}

Project _project() => Project(
  id: 'project-1',
  draft: ProjectDraft(
    name: 'Dom',
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
  ),
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 9),
);

final class _FakeImportGateway implements CostSpreadsheetImportGateway {
  CostEntryType? importedType;
  CostComponent? importedComponent;
  VatRate? importedVatRate;

  @override
  Future<CostSpreadsheetTable?> pickFile() async => CostSpreadsheetTable(
    fileName: 'kosztorys.csv',
    columns: const <String>['Nazwa', 'Koszt'],
    rows: const <CostSpreadsheetRow>[
      CostSpreadsheetRow(
        sourceRowNumber: 2,
        cells: <String>['Beton', '1234,56'],
      ),
      CostSpreadsheetRow(sourceRowNumber: 3, cells: <String>['Stal', 'błąd']),
    ],
    headerDetected: true,
  );

  @override
  CostSpreadsheetPreview preview(
    CostSpreadsheetTable table, {
    required int nameColumnIndex,
    required int amountColumnIndex,
  }) => buildCostSpreadsheetPreview(
    table,
    nameColumnIndex: nameColumnIndex,
    amountColumnIndex: amountColumnIndex,
  );

  @override
  Future<int> importRows({
    required String projectId,
    required String currencyCode,
    required CostSpreadsheetPreview preview,
    required CostEntryType type,
    required CostComponent component,
    required VatRate vatRate,
    String? stageId,
  }) async {
    importedType = type;
    importedComponent = component;
    importedVatRate = vatRate;
    return preview.validRows.length;
  }
}
