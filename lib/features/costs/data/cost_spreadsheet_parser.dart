import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:csv/csv.dart';
import 'package:excel_community/excel_community.dart';
import 'package:path/path.dart' as p;

final class CostSpreadsheetParser {
  const CostSpreadsheetParser();

  static const maximumDataRows = 1000;
  static const maximumColumns = 50;
  static const maximumCsvBytes = 5 * 1024 * 1024;
  static const maximumXlsxBytes = 10 * 1024 * 1024;
  static const maximumWorkbookBytes = 50 * 1024 * 1024;
  static const maximumWorkbookEntries = 1000;

  Future<CostSpreadsheetTable> parse({
    required String fileName,
    required Uint8List bytes,
  }) {
    return Isolate.run(() => _parse(fileName, bytes));
  }
}

CostSpreadsheetTable _parse(String fileName, Uint8List bytes) {
  if (bytes.isEmpty) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.emptyFile,
    );
  }
  return switch (p.extension(fileName).toLowerCase()) {
    '.csv' => _parseCsv(fileName, bytes),
    '.xlsx' => _parseXlsx(fileName, bytes),
    _ => throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.unsupportedFormat,
    ),
  };
}

CostSpreadsheetTable _parseCsv(String fileName, Uint8List bytes) {
  if (bytes.length > CostSpreadsheetParser.maximumCsvBytes) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.fileTooLarge,
    );
  }
  try {
    var contents = utf8.decode(bytes);
    if (contents.startsWith('\uFEFF')) {
      contents = contents.substring(1);
    }
    final decoded = Csv().decode(contents);
    return _buildTable(
      fileName: fileName,
      rows: decoded
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList(),
    );
  } on CostSpreadsheetImportException {
    rethrow;
  } on Object {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.unreadableFile,
    );
  }
}

CostSpreadsheetTable _parseXlsx(String fileName, Uint8List bytes) {
  if (bytes.length > CostSpreadsheetParser.maximumXlsxBytes) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.fileTooLarge,
    );
  }
  try {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    if (archive.length > CostSpreadsheetParser.maximumWorkbookEntries ||
        archive.fold<int>(0, (total, file) => total + file.size) >
            CostSpreadsheetParser.maximumWorkbookBytes) {
      throw const CostSpreadsheetImportException(
        CostSpreadsheetImportError.workbookTooLarge,
      );
    }

    final workbook = Excel.decodeBytes(bytes);
    for (final entry in workbook.tables.entries) {
      final sheet = entry.value;
      if (sheet.maxRows == 0 || sheet.maxColumns == 0) continue;
      if (sheet.maxRows > CostSpreadsheetParser.maximumDataRows + 1) {
        throw const CostSpreadsheetImportException(
          CostSpreadsheetImportError.tooManyRows,
        );
      }
      if (sheet.maxColumns > CostSpreadsheetParser.maximumColumns) {
        throw const CostSpreadsheetImportException(
          CostSpreadsheetImportError.tooManyColumns,
        );
      }
      final rows = <List<String>>[];
      final formulas = <Set<int>>[];
      for (final row in sheet.rows) {
        final values = <String>[];
        final formulaIndexes = <int>{};
        for (var column = 0; column < row.length; column++) {
          final value = row[column]?.value;
          if (value is FormulaCellValue) {
            formulaIndexes.add(column);
          }
          values.add(value?.toString() ?? '');
        }
        rows.add(values);
        formulas.add(formulaIndexes);
      }
      if (rows.any(_hasContent)) {
        return _buildTable(
          fileName: fileName,
          sheetName: entry.key,
          rows: rows,
          formulaColumnsByRow: formulas,
        );
      }
    }
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.emptyFile,
    );
  } on CostSpreadsheetImportException {
    rethrow;
  } on Object {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.unreadableFile,
    );
  }
}

CostSpreadsheetTable _buildTable({
  required String fileName,
  String? sheetName,
  required List<List<String>> rows,
  List<Set<int>>? formulaColumnsByRow,
}) {
  final firstContent = rows.indexWhere(_hasContent);
  if (firstContent < 0) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.emptyFile,
    );
  }
  var lastContent = rows.length - 1;
  while (lastContent >= firstContent && !_hasContent(rows[lastContent])) {
    lastContent--;
  }
  final contentRows = rows.sublist(firstContent, lastContent + 1);
  final columnCount = contentRows.fold<int>(
    0,
    (maximum, row) => row.length > maximum ? row.length : maximum,
  );
  if (columnCount < 2) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.notEnoughColumns,
    );
  }
  if (columnCount > CostSpreadsheetParser.maximumColumns) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.tooManyColumns,
    );
  }

  final headerDetected = _isHeader(contentRows.first);
  final dataStart = headerDetected ? 1 : 0;
  final resultRows = <CostSpreadsheetRow>[];
  for (var index = dataStart; index < contentRows.length; index++) {
    final row = contentRows[index];
    if (!_hasContent(row)) continue;
    resultRows.add(
      CostSpreadsheetRow(
        sourceRowNumber: firstContent + index + 1,
        cells: List<String>.generate(
          columnCount,
          (column) => column < row.length ? row[column].trim() : '',
          growable: false,
        ),
        formulaColumnIndexes:
            formulaColumnsByRow?[firstContent + index] ?? const <int>{},
      ),
    );
  }
  if (resultRows.isEmpty) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.emptyFile,
    );
  }
  if (resultRows.length > CostSpreadsheetParser.maximumDataRows) {
    throw const CostSpreadsheetImportException(
      CostSpreadsheetImportError.tooManyRows,
    );
  }

  final columns = headerDetected
      ? List<String>.generate(columnCount, (index) {
          final value = index < contentRows.first.length
              ? contentRows.first[index].trim()
              : '';
          return value;
        }, growable: false)
      : List<String>.filled(columnCount, '', growable: false);
  return CostSpreadsheetTable(
    fileName: fileName,
    sheetName: sheetName,
    columns: columns,
    rows: resultRows,
    headerDetected: headerDetected,
  );
}

bool _hasContent(List<String> row) => row.any((cell) => cell.trim().isNotEmpty);

bool _isHeader(List<String> row) {
  const names = <String>{
    'nazwa',
    'nazwa materialu',
    'material',
    'produkt',
    'pozycja',
    'opis',
    'name',
  };
  const amounts = <String>{
    'koszt',
    'kwota',
    'cena',
    'wartosc',
    'wartosc brutto',
    'koszt brutto',
    'brutto',
    'price',
    'amount',
  };
  final normalized = row.map(_normalizeHeader).toSet();
  return normalized.any(names.contains) && normalized.any(amounts.contains);
}

String _normalizeHeader(String value) {
  if (value.length > 80) return '';
  var normalized = value.trim().toLowerCase();
  const replacements = <String, String>{
    'ą': 'a',
    'ć': 'c',
    'ę': 'e',
    'ł': 'l',
    'ń': 'n',
    'ó': 'o',
    'ś': 's',
    'ź': 'z',
    'ż': 'z',
  };
  for (final entry in replacements.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  return normalized.replaceAll(RegExp(r'\s+'), ' ');
}
