import 'dart:io';
import 'dart:typed_data';

import 'package:budowapro/features/costs/data/cost_spreadsheet_parser.dart';
import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

typedef PickCostSpreadsheetFile = Future<FilePickerResult?> Function();

final class PickedCostSpreadsheet {
  PickedCostSpreadsheet({required this.fileName, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes);

  final String fileName;
  final Uint8List bytes;
}

abstract interface class CostSpreadsheetPicker {
  Future<PickedCostSpreadsheet?> pick();
}

final class FilePickerCostSpreadsheetPicker implements CostSpreadsheetPicker {
  FilePickerCostSpreadsheetPicker({PickCostSpreadsheetFile? pickFile})
    : _pickFile = pickFile ?? _pickSingleFile;

  final PickCostSpreadsheetFile _pickFile;

  @override
  Future<PickedCostSpreadsheet?> pick() async {
    final result = await _pickFile();
    if (result == null) return null;
    final selected = result.files.single;
    final maximumBytes = switch (p.extension(selected.name).toLowerCase()) {
      '.csv' => CostSpreadsheetParser.maximumCsvBytes,
      '.xlsx' => CostSpreadsheetParser.maximumXlsxBytes,
      _ => throw const CostSpreadsheetImportException(
        CostSpreadsheetImportError.unsupportedFormat,
      ),
    };
    if (selected.size > maximumBytes) {
      throw const CostSpreadsheetImportException(
        CostSpreadsheetImportError.fileTooLarge,
      );
    }
    final selectedBytes = selected.bytes;
    if (selectedBytes != null) {
      return PickedCostSpreadsheet(
        fileName: selected.name,
        bytes: selectedBytes,
      );
    }
    final path = selected.path;
    if (path == null) {
      throw const FileSystemException('Selected spreadsheet has no local path');
    }
    return PickedCostSpreadsheet(
      fileName: selected.name,
      bytes: await File(path).readAsBytes(),
    );
  }

  static Future<FilePickerResult?> _pickSingleFile() {
    return FilePicker.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: const <String>['csv', 'xlsx'],
    );
  }
}
