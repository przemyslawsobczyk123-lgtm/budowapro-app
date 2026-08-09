import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/data/cost_spreadsheet_parser.dart';
import 'package:budowapro/features/costs/data/cost_spreadsheet_picker.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final costSpreadsheetImportGatewayProvider =
    FutureProvider<CostSpreadsheetImportGateway>((ref) async {
      return LocalCostSpreadsheetImportGateway(
        repository: await ref.watch(costRepositoryProvider.future),
        picker: FilePickerCostSpreadsheetPicker(),
        parser: const CostSpreadsheetParser(),
        utcNow: DateTime.now,
      );
    });

abstract interface class CostSpreadsheetImportGateway {
  Future<CostSpreadsheetTable?> pickFile();

  CostSpreadsheetPreview preview(
    CostSpreadsheetTable table, {
    required int nameColumnIndex,
    required int amountColumnIndex,
  });

  Future<int> importRows({
    required String projectId,
    required String currencyCode,
    required CostSpreadsheetPreview preview,
    required CostEntryType type,
    required CostComponent component,
    required VatRate vatRate,
    String? stageId,
  });
}

final class LocalCostSpreadsheetImportGateway
    implements CostSpreadsheetImportGateway {
  factory LocalCostSpreadsheetImportGateway({
    required CostRepository repository,
    required CostSpreadsheetPicker picker,
    required CostSpreadsheetParser parser,
    required DateTime Function() utcNow,
  }) {
    return LocalCostSpreadsheetImportGateway._(
      repository,
      picker,
      parser,
      utcNow,
    );
  }

  const LocalCostSpreadsheetImportGateway._(
    this._repository,
    this._picker,
    this._parser,
    this._utcNow,
  );

  final CostRepository _repository;
  final CostSpreadsheetPicker _picker;
  final CostSpreadsheetParser _parser;
  final DateTime Function() _utcNow;

  @override
  Future<CostSpreadsheetTable?> pickFile() async {
    final selected = await _picker.pick();
    if (selected == null) return null;
    return _parser.parse(fileName: selected.fileName, bytes: selected.bytes);
  }

  @override
  CostSpreadsheetPreview preview(
    CostSpreadsheetTable table, {
    required int nameColumnIndex,
    required int amountColumnIndex,
  }) {
    return buildCostSpreadsheetPreview(
      table,
      nameColumnIndex: nameColumnIndex,
      amountColumnIndex: amountColumnIndex,
    );
  }

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
    if (preview.validRows.isEmpty) {
      throw StateError('The spreadsheet contains no valid rows');
    }
    final status = switch (type) {
      CostEntryType.cost => CostStatus.due,
      CostEntryType.offer || CostEntryType.planned => CostStatus.planned,
    };
    final entryDate = _utcNow();
    final created = await _repository.createAll(
      preview.validRows.map(
        (row) => ConfirmedCostEntryInput(
          CostEntryInput(
            projectId: projectId,
            name: row.name,
            type: type,
            component: component,
            status: status,
            amount: VatBreakdown.fromGross(
              Money(
                minorUnits: row.grossMinorUnits!,
                currencyCode: currencyCode,
              ),
              vatRate,
            ),
            entryDate: entryDate,
            stageId: stageId,
            source: CostSource.imported,
          ),
        ),
      ),
    );
    return created.length;
  }
}
