import 'dart:collection';

import 'money.dart';

enum CostSpreadsheetImportError {
  unsupportedFormat,
  emptyFile,
  fileTooLarge,
  workbookTooLarge,
  notEnoughColumns,
  tooManyRows,
  tooManyColumns,
  unreadableFile,
}

final class CostSpreadsheetImportException implements Exception {
  const CostSpreadsheetImportException(this.code);

  final CostSpreadsheetImportError code;
}

final class CostSpreadsheetRow {
  const CostSpreadsheetRow({
    required this.sourceRowNumber,
    required this.cells,
    this.formulaColumnIndexes = const <int>{},
  });

  final int sourceRowNumber;
  final List<String> cells;
  final Set<int> formulaColumnIndexes;
}

final class CostSpreadsheetTable {
  CostSpreadsheetTable({
    required this.fileName,
    this.sheetName,
    required Iterable<String> columns,
    required Iterable<CostSpreadsheetRow> rows,
    required this.headerDetected,
  }) : columns = UnmodifiableListView<String>(List<String>.of(columns)),
       rows = UnmodifiableListView<CostSpreadsheetRow>(
         List<CostSpreadsheetRow>.of(rows),
       );

  final String fileName;
  final String? sheetName;
  final UnmodifiableListView<String> columns;
  final UnmodifiableListView<CostSpreadsheetRow> rows;
  final bool headerDetected;
}

enum CostSpreadsheetRowError {
  missingName,
  nameTooLong,
  missingAmount,
  invalidAmount,
  amountTooLarge,
  formula,
}

final class CostSpreadsheetPreviewRow {
  const CostSpreadsheetPreviewRow({
    required this.sourceRowNumber,
    required this.name,
    required this.rawAmount,
    required this.grossMinorUnits,
    required this.error,
  });

  final int sourceRowNumber;
  final String name;
  final String rawAmount;
  final int? grossMinorUnits;
  final CostSpreadsheetRowError? error;

  bool get isValid => error == null;
}

final class CostSpreadsheetPreview {
  factory CostSpreadsheetPreview(
    Iterable<CostSpreadsheetPreviewRow> sourceRows,
  ) {
    final rows = List<CostSpreadsheetPreviewRow>.of(sourceRows);
    return CostSpreadsheetPreview._(
      UnmodifiableListView<CostSpreadsheetPreviewRow>(rows),
      UnmodifiableListView<CostSpreadsheetPreviewRow>(
        rows.where((row) => row.isValid).toList(growable: false),
      ),
      UnmodifiableListView<CostSpreadsheetPreviewRow>(
        rows.where((row) => !row.isValid).toList(growable: false),
      ),
    );
  }

  const CostSpreadsheetPreview._(this.rows, this.validRows, this.invalidRows);

  final UnmodifiableListView<CostSpreadsheetPreviewRow> rows;
  final UnmodifiableListView<CostSpreadsheetPreviewRow> validRows;
  final UnmodifiableListView<CostSpreadsheetPreviewRow> invalidRows;
}

CostSpreadsheetPreview buildCostSpreadsheetPreview(
  CostSpreadsheetTable table, {
  required int nameColumnIndex,
  required int amountColumnIndex,
}) {
  if (nameColumnIndex < 0 || nameColumnIndex >= table.columns.length) {
    throw RangeError.index(nameColumnIndex, table.columns, 'nameColumnIndex');
  }
  if (amountColumnIndex < 0 || amountColumnIndex >= table.columns.length) {
    throw RangeError.index(
      amountColumnIndex,
      table.columns,
      'amountColumnIndex',
    );
  }
  if (nameColumnIndex == amountColumnIndex) {
    throw ArgumentError('Name and amount must use different columns');
  }

  return CostSpreadsheetPreview(
    table.rows.map((row) {
      final name = row.cells[nameColumnIndex].trim();
      final rawAmount = row.cells[amountColumnIndex].trim();
      CostSpreadsheetRowError? error;
      int? grossMinorUnits;
      if (row.formulaColumnIndexes.contains(nameColumnIndex) ||
          row.formulaColumnIndexes.contains(amountColumnIndex)) {
        error = CostSpreadsheetRowError.formula;
      } else if (name.isEmpty) {
        error = CostSpreadsheetRowError.missingName;
      } else if (name.length > 120) {
        error = CostSpreadsheetRowError.nameTooLong;
      } else if (rawAmount.isEmpty) {
        error = CostSpreadsheetRowError.missingAmount;
      } else {
        final parsed = _parseGrossMinorUnits(rawAmount);
        grossMinorUnits = parsed.$1;
        error = parsed.$2;
      }
      return CostSpreadsheetPreviewRow(
        sourceRowNumber: row.sourceRowNumber,
        name: name,
        rawAmount: rawAmount,
        grossMinorUnits: grossMinorUnits,
        error: error,
      );
    }),
  );
}

(int?, CostSpreadsheetRowError?) _parseGrossMinorUnits(String rawValue) {
  if (rawValue.length > 64) {
    return (null, CostSpreadsheetRowError.amountTooLarge);
  }
  var value = rawValue
      .toLowerCase()
      .replaceAll('pln', '')
      .replaceAll('zł', '')
      .replaceAll(RegExp(r"[\s\u00A0']"), '')
      .trim();
  if (value.isEmpty) {
    return (null, CostSpreadsheetRowError.missingAmount);
  }
  if (!RegExp(r'^\d+(?:[,.]\d+)*$').hasMatch(value)) {
    return (null, CostSpreadsheetRowError.invalidAmount);
  }

  final comma = value.lastIndexOf(',');
  final dot = value.lastIndexOf('.');
  var whole = value;
  var fraction = '';
  if (comma >= 0 && dot >= 0) {
    final decimalSeparator = comma > dot ? ',' : '.';
    final groupingSeparator = decimalSeparator == ',' ? '.' : ',';
    final split = value.lastIndexOf(decimalSeparator);
    final rawWhole = value.substring(0, split);
    fraction = value.substring(split + 1);
    if (fraction.isEmpty ||
        fraction.length > 2 ||
        rawWhole.contains(decimalSeparator) ||
        !_isValidGroupedWhole(rawWhole, groupingSeparator)) {
      return (null, CostSpreadsheetRowError.invalidAmount);
    }
    whole = rawWhole.replaceAll(groupingSeparator, '');
  } else {
    final separator = comma >= 0 ? ',' : (dot >= 0 ? '.' : null);
    if (separator != null) {
      final parts = value.split(separator);
      if (parts.length == 2 && parts.last.length <= 2) {
        whole = parts.first;
        fraction = parts.last;
      } else if (_isValidThousandsGroups(parts)) {
        whole = parts.join();
      } else {
        return (null, CostSpreadsheetRowError.invalidAmount);
      }
    }
  }

  if (whole.isEmpty || fraction.length > 2) {
    return (null, CostSpreadsheetRowError.invalidAmount);
  }
  final minorUnits =
      BigInt.parse(whole) * BigInt.from(100) +
      BigInt.parse(fraction.isEmpty ? '0' : fraction.padRight(2, '0'));
  if (minorUnits < BigInt.one) {
    return (null, CostSpreadsheetRowError.invalidAmount);
  }
  if (minorUnits > BigInt.from(Money.maximumMinorUnits)) {
    return (null, CostSpreadsheetRowError.amountTooLarge);
  }
  return (minorUnits.toInt(), null);
}

bool _isValidGroupedWhole(String value, String separator) {
  if (!value.contains(separator)) return RegExp(r'^\d+$').hasMatch(value);
  return _isValidThousandsGroups(value.split(separator));
}

bool _isValidThousandsGroups(List<String> groups) {
  if (groups.length < 2 || groups.first.isEmpty || groups.first.length > 3) {
    return false;
  }
  return groups.skip(1).every((group) => group.length == 3);
}
