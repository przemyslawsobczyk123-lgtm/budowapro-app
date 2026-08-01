import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/presentation/cost_register_initial_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a report drill-down filter from query parameters', () {
    final filter = CostRegisterInitialFilter.fromQueryParameters({
      'type': 'cost',
      'status': 'paid',
      'component': 'labor',
      'stageId': 'stage-zero',
      'from': '2026-01-01',
      'to': '2026-01-31',
    });

    expect(filter.types, {CostEntryType.cost});
    expect(filter.statuses, {CostStatus.paid});
    expect(filter.components, {CostComponent.labor});
    expect(filter.stageId, 'stage-zero');
    expect(filter.fromDate, DateTime(2026));
    expect(filter.toDate, DateTime(2026, 1, 31));
    expect(filter.includeDrafts, isFalse);
  });

  test('parses an unassigned dimension used by report rows', () {
    final filter = CostRegisterInitialFilter.fromQueryParameters({
      'type': 'cost',
      'unassigned': 'supplier',
    });

    expect(filter.missingAssignments, {CostMissingAssignment.supplier});
  });

  test('ignores malformed and unsupported filter values', () {
    final filter = CostRegisterInitialFilter.fromQueryParameters({
      'type': 'unknown',
      'status': 'hacked',
      'supplierId': 'x' * 121,
      'from': '2026-02-31',
      'to': 'tomorrow',
      'drafts': 'yes',
      'unassigned': 'everything',
    });

    expect(filter.types, isEmpty);
    expect(filter.statuses, isEmpty);
    expect(filter.supplierId, isNull);
    expect(filter.fromDate, isNull);
    expect(filter.toDate, isNull);
    expect(filter.includeDrafts, isFalse);
    expect(filter.missingAssignments, isEmpty);
  });

  test('drops a reversed date range instead of widening it', () {
    final filter = CostRegisterInitialFilter.fromQueryParameters({
      'from': '2026-03-01',
      'to': '2026-02-01',
    });

    expect(filter.fromDate, isNull);
    expect(filter.toDate, isNull);
  });
}
