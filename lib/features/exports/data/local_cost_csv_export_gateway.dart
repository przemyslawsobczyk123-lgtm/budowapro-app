import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_export_record.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/exports/domain/cost_csv_export.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:budowapro/shared/services/local_private_cache_cleaner.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

typedef CsvDirectoryProvider = Future<Directory> Function();
typedef ShareCsvFile = Future<void> Function(File file, String title);

final class LocalCostCsvExportGateway implements CostCsvExportGateway {
  factory LocalCostCsvExportGateway.forDevice({
    required CostRepository repository,
  }) {
    return LocalCostCsvExportGateway(
      repository: repository,
      directoryProvider: getTemporaryDirectory,
      shareFile: _shareCsvFile,
      utcNow: DateTime.now,
    );
  }

  factory LocalCostCsvExportGateway({
    required CostRepository repository,
    required CsvDirectoryProvider directoryProvider,
    required ShareCsvFile shareFile,
    required DateTime Function() utcNow,
  }) {
    return LocalCostCsvExportGateway._(
      repository,
      directoryProvider,
      shareFile,
      utcNow,
    );
  }

  const LocalCostCsvExportGateway._(
    this._repository,
    this._directoryProvider,
    this._shareFile,
    this._utcNow,
  );

  static const _pageSize = PageRequest.maximumLimit;
  static const _retention = Duration(hours: 24);

  final CostRepository _repository;
  final CsvDirectoryProvider _directoryProvider;
  final ShareCsvFile _shareFile;
  final DateTime Function() _utcNow;

  @override
  Future<CostCsvExportResult> exportAndShare(
    CostCsvExportRequest request,
  ) async {
    final root = await _directoryProvider();
    final exportDirectory = Directory(p.join(root.path, 'budowapro-exports'));
    await exportDirectory.create(recursive: true);
    await _removeExpiredExports(exportDirectory, _utcNow().toUtc());

    final createdAt = _utcNow().toUtc();
    final file = File(p.join(exportDirectory.path, _fileNameFor(createdAt)));
    final sink = file.openWrite(mode: FileMode.writeOnly);
    var completed = false;
    var recordCount = 0;
    try {
      sink.add(const <int>[0xEF, 0xBB, 0xBF]);
      await _writeChunk(sink, <List<String>>[
        <String>[
          for (final column in request.columns) request.labels.headers[column]!,
        ],
      ], const <bool>[]);

      PageRequest? pageRequest = PageRequest(limit: _pageSize);
      while (pageRequest != null) {
        final page = await _repository.exportRows(request.query, pageRequest);
        final rows = <List<String>>[
          for (final record in page.items)
            <String>[
              for (final column in request.columns)
                _valueFor(record, column, request.labels),
            ],
        ];
        await _writeChunk(sink, rows, <bool>[
          for (final column in request.columns)
            _containsUserAuthoredText(column),
        ]);
        recordCount += page.items.length;
        pageRequest = page.nextRequest;
      }
      await sink.flush();
      await sink.close();
      completed = true;
      await _shareFile(file, request.labels.shareTitle);
      await _deleteIfPresent(file);
      return CostCsvExportResult(recordCount: recordCount);
    } on Object catch (error, stackTrace) {
      if (!completed) {
        await sink.close();
      }
      await _deleteIfPresent(file);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static Future<void> _writeChunk(
    IOSink sink,
    List<List<String>> rows,
    List<bool> untrustedColumns,
  ) async {
    if (rows.isEmpty) return;
    final encoded = await Isolate.run(
      () => utf8.encode(_encodeRows(rows, untrustedColumns)),
    );
    sink.add(encoded);
    await sink.flush();
  }

  static Future<void> _removeExpiredExports(
    Directory directory,
    DateTime nowUtc,
  ) async {
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File || !entity.path.toLowerCase().endsWith('.csv')) {
        continue;
      }
      final modifiedAt = (await entity.lastModified()).toUtc();
      if (nowUtc.difference(modifiedAt) > _retention) {
        await _deleteIfPresent(entity);
      }
    }
  }

  static Future<void> _deleteIfPresent(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // Best-effort cleanup must not replace the original export error.
    }
  }

  static String _fileNameFor(DateTime createdAtUtc) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'budowapro-koszty-'
        '${createdAtUtc.year}${two(createdAtUtc.month)}${two(createdAtUtc.day)}-'
        '${two(createdAtUtc.hour)}${two(createdAtUtc.minute)}'
        '${two(createdAtUtc.second)}-${createdAtUtc.microsecond}.csv';
  }
}

Future<void> _shareCsvFile(File file, String title) async {
  try {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'text/csv')],
        title: title,
      ),
    );
  } finally {
    LocalPrivateCacheCleaner.forDevice().scheduleShareCacheCleanup();
  }
}

String _encodeRows(List<List<String>> rows, List<bool> untrustedColumns) {
  final output = StringBuffer();
  for (final row in rows) {
    for (var index = 0; index < row.length; index++) {
      if (index > 0) output.write(';');
      output.write(
        _escapeCsvCell(
          row[index],
          untrusted: untrustedColumns.isNotEmpty && untrustedColumns[index],
        ),
      );
    }
    output.write('\r\n');
  }
  return output.toString();
}

String _escapeCsvCell(String value, {required bool untrusted}) {
  var safeValue = value;
  if (untrusted && RegExp(r'^[\t\r\n ]*[=+\-@]').hasMatch(safeValue)) {
    safeValue = "'$safeValue";
  }
  if (safeValue.contains(';') ||
      safeValue.contains('"') ||
      safeValue.contains('\r') ||
      safeValue.contains('\n') ||
      safeValue.trim() != safeValue) {
    return '"${safeValue.replaceAll('"', '""')}"';
  }
  return safeValue;
}

String _valueFor(
  CostExportRecord record,
  CostCsvColumn column,
  CostCsvLabels labels,
) {
  final entry = record.entry;
  final input = entry.input;
  return switch (column) {
    CostCsvColumn.entryDate => _dateValue(entry.entryDate.toLocal()),
    CostCsvColumn.name => entry.name,
    CostCsvColumn.type => labels.types[entry.type] ?? entry.type.name,
    CostCsvColumn.component =>
      labels.components[entry.component] ?? entry.component.name,
    CostCsvColumn.status => labels.statuses[entry.status] ?? entry.status.name,
    CostCsvColumn.lifecycle =>
      labels.lifecycles[entry.lifecycle] ?? entry.lifecycle.name,
    CostCsvColumn.effectiveGross => _moneyValue(
      record.effectiveGross.minorUnits,
    ),
    CostCsvColumn.originalGross => _moneyValue(entry.amount.gross.minorUnits),
    CostCsvColumn.net => _moneyValue(entry.amount.net.minorUnits),
    CostCsvColumn.vat => _moneyValue(entry.amount.vat.minorUnits),
    CostCsvColumn.vatRate => _rateValue(entry.amount.rate.basisPoints),
    CostCsvColumn.currency => entry.amount.gross.currencyCode,
    CostCsvColumn.stage =>
      input.stageId == null
          ? labels.emptyValue
          : labels.stageLabels[input.stageId!] ?? input.stageId!,
    CostCsvColumn.category => input.categoryId ?? labels.emptyValue,
    CostCsvColumn.supplier => input.supplierId ?? labels.emptyValue,
    CostCsvColumn.quantity => _quantityValue(
      input.quantity,
      input.unit,
      labels.emptyValue,
    ),
    CostCsvColumn.paymentMethod =>
      input.paymentMethod == null
          ? labels.emptyValue
          : labels.paymentMethods[input.paymentMethod!] ??
                input.paymentMethod!.name,
    CostCsvColumn.source => labels.sources[input.source] ?? input.source.name,
    CostCsvColumn.attachmentCount => input.attachmentIds.length.toString(),
    CostCsvColumn.note => input.note ?? labels.emptyValue,
  };
}

bool _containsUserAuthoredText(CostCsvColumn column) {
  return switch (column) {
    CostCsvColumn.name ||
    CostCsvColumn.stage ||
    CostCsvColumn.category ||
    CostCsvColumn.supplier ||
    CostCsvColumn.quantity ||
    CostCsvColumn.note => true,
    _ => false,
  };
}

String _dateValue(DateTime value) {
  String two(int part) => part.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}

String _moneyValue(int minorUnits) {
  final value = BigInt.from(minorUnits);
  final negative = value.isNegative;
  final absolute = value.abs().toString().padLeft(3, '0');
  final whole = absolute.substring(0, absolute.length - 2);
  final fraction = absolute.substring(absolute.length - 2);
  return '${negative ? '-' : ''}$whole,$fraction';
}

String _rateValue(int basisPoints) {
  final whole = basisPoints ~/ 100;
  final fraction = basisPoints.remainder(100);
  if (fraction == 0) return '$whole%';
  return '$whole,${fraction.toString().padLeft(2, '0')}%';
}

String _quantityValue(
  DecimalQuantity? quantity,
  String? unit,
  String emptyValue,
) {
  if (quantity == null || unit == null) return emptyValue;
  final digits = quantity.unscaledValue.toString();
  if (quantity.scale == 0) return '$digits $unit';
  final padded = digits.padLeft(quantity.scale + 1, '0');
  final split = padded.length - quantity.scale;
  return '${padded.substring(0, split)},${padded.substring(split)} $unit';
}
