import 'cost_entry.dart';
import 'money.dart';

final class CostExportRecord {
  CostExportRecord({required this.entry, required this.effectiveGross}) {
    if (entry.amount.gross.currencyCode != effectiveGross.currencyCode) {
      throw ArgumentError.value(
        effectiveGross.currencyCode,
        'effectiveGross',
        'must use ${entry.amount.gross.currencyCode}',
      );
    }
  }

  final CostEntry entry;
  final Money effectiveGross;
}
