import 'package:budowapro/features/costs/data/cost_spreadsheet_parser.dart';
import 'package:budowapro/features/costs/data/cost_spreadsheet_picker.dart';
import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rejects an oversized file before reading its path', () async {
    final picker = FilePickerCostSpreadsheetPicker(
      pickFile: () async => FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'kosztorys.csv',
          size: CostSpreadsheetParser.maximumCsvBytes + 1,
          path: 'missing.csv',
        ),
      ]),
    );

    await expectLater(
      picker.pick(),
      throwsA(
        isA<CostSpreadsheetImportException>().having(
          (error) => error.code,
          'code',
          CostSpreadsheetImportError.fileTooLarge,
        ),
      ),
    );
  });
}
