import 'dart:collection';

import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';

enum CostCsvColumn {
  entryDate,
  name,
  type,
  status,
  lifecycle,
  effectiveGross,
  originalGross,
  net,
  vat,
  vatRate,
  currency,
  stage,
  category,
  supplier,
  quantity,
  paymentMethod,
  source,
  attachmentCount,
  note,
}

final class CostCsvLabels {
  CostCsvLabels({
    required Map<CostCsvColumn, String> headers,
    required Map<CostEntryType, String> types,
    required Map<CostStatus, String> statuses,
    required Map<CostLifecycle, String> lifecycles,
    required Map<CostPaymentMethod, String> paymentMethods,
    required Map<CostSource, String> sources,
    Map<String, String> stageLabels = const <String, String>{},
    required this.emptyValue,
  }) : headers = UnmodifiableMapView<CostCsvColumn, String>(
         Map<CostCsvColumn, String>.of(headers),
       ),
       types = UnmodifiableMapView<CostEntryType, String>(
         Map<CostEntryType, String>.of(types),
       ),
       statuses = UnmodifiableMapView<CostStatus, String>(
         Map<CostStatus, String>.of(statuses),
       ),
       lifecycles = UnmodifiableMapView<CostLifecycle, String>(
         Map<CostLifecycle, String>.of(lifecycles),
       ),
       paymentMethods = UnmodifiableMapView<CostPaymentMethod, String>(
         Map<CostPaymentMethod, String>.of(paymentMethods),
       ),
       sources = UnmodifiableMapView<CostSource, String>(
         Map<CostSource, String>.of(sources),
       ),
       stageLabels = UnmodifiableMapView<String, String>(
         Map<String, String>.of(stageLabels),
       ) {
    if (!this.headers.keys.toSet().containsAll(CostCsvColumn.values)) {
      throw ArgumentError.value(headers, 'headers', 'must cover every column');
    }
    if (emptyValue.contains('\r') || emptyValue.contains('\n')) {
      throw ArgumentError.value(
        emptyValue,
        'emptyValue',
        'must fit one CSV cell',
      );
    }
  }

  final UnmodifiableMapView<CostCsvColumn, String> headers;
  final UnmodifiableMapView<CostEntryType, String> types;
  final UnmodifiableMapView<CostStatus, String> statuses;
  final UnmodifiableMapView<CostLifecycle, String> lifecycles;
  final UnmodifiableMapView<CostPaymentMethod, String> paymentMethods;
  final UnmodifiableMapView<CostSource, String> sources;
  final UnmodifiableMapView<String, String> stageLabels;
  final String emptyValue;
}

final class CostCsvExportRequest {
  CostCsvExportRequest({
    required this.query,
    required Iterable<CostCsvColumn> columns,
    required this.labels,
  }) : columns = UnmodifiableListView<CostCsvColumn>(
         List<CostCsvColumn>.of(columns),
       ) {
    if (this.columns.isEmpty) {
      throw ArgumentError.value(columns, 'columns', 'must not be empty');
    }
    if (this.columns.toSet().length != this.columns.length) {
      throw ArgumentError.value(columns, 'columns', 'must not contain repeats');
    }
  }

  final CostQuery query;
  final UnmodifiableListView<CostCsvColumn> columns;
  final CostCsvLabels labels;
}

final class CostCsvExportResult {
  const CostCsvExportResult({required this.recordCount});

  final int recordCount;
}

abstract interface class CostCsvExportGateway {
  Future<CostCsvExportResult> exportAndShare(CostCsvExportRequest request);
}
