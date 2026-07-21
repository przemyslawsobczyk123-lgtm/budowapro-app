import 'dart:collection';

import 'package:budowapro/features/costs/domain/money.dart';

enum BudgetBreakdownDimension { stage, category, supplier, month }

final class BudgetReportSlice {
  factory BudgetReportSlice({
    required String? key,
    required Money committed,
    required Money paid,
    required int recordCount,
  }) {
    final normalizedKey = key?.trim();
    if (normalizedKey != null &&
        (normalizedKey.isEmpty || normalizedKey.length > 120)) {
      throw ArgumentError.value(key, 'key', 'must contain 1 to 120 characters');
    }
    if (committed.isNegative || paid.isNegative) {
      throw RangeError('Report slice amounts must not be negative');
    }
    if (committed.currencyCode != paid.currencyCode ||
        paid.compareTo(committed) > 0) {
      throw ArgumentError(
        'Paid amount must use the same currency and fit total',
      );
    }
    if (recordCount < 1) {
      throw RangeError.value(recordCount, 'recordCount', 'must be positive');
    }
    return BudgetReportSlice._(
      key: normalizedKey,
      committed: committed,
      paid: paid,
      recordCount: recordCount,
    );
  }

  const BudgetReportSlice._({
    required this.key,
    required this.committed,
    required this.paid,
    required this.recordCount,
  });

  final String? key;
  final Money committed;
  final Money paid;
  final int recordCount;
}

final class BudgetReport {
  factory BudgetReport({
    required String projectId,
    required String currencyCode,
    required Money committed,
    required Money paid,
    required int costRecordCount,
    Money? plan,
    Map<BudgetBreakdownDimension, Iterable<BudgetReportSlice>> breakdowns =
        const <BudgetBreakdownDimension, Iterable<BudgetReportSlice>>{},
  }) {
    final normalizedProjectId = projectId.trim();
    if (normalizedProjectId.isEmpty || normalizedProjectId.length > 64) {
      throw ArgumentError.value(projectId, 'projectId', 'must be valid');
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw ArgumentError.value(currencyCode, 'currencyCode', 'must be valid');
    }
    if (committed.currencyCode != currencyCode ||
        paid.currencyCode != currencyCode ||
        (plan != null && plan.currencyCode != currencyCode)) {
      throw ArgumentError('All report amounts must use $currencyCode');
    }
    if (committed.isNegative || paid.isNegative || plan?.isNegative == true) {
      throw RangeError('Report totals must not be negative');
    }
    if (paid.compareTo(committed) > 0) {
      throw ArgumentError('Paid amount must not exceed committed amount');
    }
    if (costRecordCount < 0) {
      throw RangeError.value(costRecordCount, 'costRecordCount');
    }
    if (costRecordCount == 0 && (!committed.isZero || !paid.isZero)) {
      throw ArgumentError('An empty report must have zero totals');
    }

    final normalizedBreakdowns =
        <BudgetBreakdownDimension, UnmodifiableListView<BudgetReportSlice>>{};
    for (final entry in breakdowns.entries) {
      final slices = List<BudgetReportSlice>.of(entry.value);
      for (final slice in slices) {
        if (slice.committed.currencyCode != currencyCode) {
          throw ArgumentError('Every slice must use $currencyCode');
        }
      }
      normalizedBreakdowns[entry.key] = UnmodifiableListView(slices);
    }
    return BudgetReport._(
      projectId: normalizedProjectId,
      currencyCode: currencyCode,
      plan: plan,
      committed: committed,
      paid: paid,
      costRecordCount: costRecordCount,
      breakdowns: UnmodifiableMapView(normalizedBreakdowns),
    );
  }

  const BudgetReport._({
    required this.projectId,
    required this.currencyCode,
    required this.plan,
    required this.committed,
    required this.paid,
    required this.costRecordCount,
    required this.breakdowns,
  });

  final String projectId;
  final String currencyCode;
  final Money? plan;
  final Money committed;
  final Money paid;
  final int costRecordCount;
  final UnmodifiableMapView<
    BudgetBreakdownDimension,
    UnmodifiableListView<BudgetReportSlice>
  >
  breakdowns;

  bool get hasCosts => costRecordCount > 0;

  Money? get remaining => plan == null ? null : plan! - committed;

  List<BudgetReportSlice> slicesFor(BudgetBreakdownDimension dimension) =>
      breakdowns[dimension] ?? const <BudgetReportSlice>[];
}
