import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'cost query requires project context and excludes drafts by default',
    () {
      final query = CostQuery(projectId: ' project-1 ');

      expect(query.projectId, 'project-1');
      expect(query.includeDrafts, isFalse);
      expect(() => CostQuery(projectId: ' '), throwsArgumentError);
    },
  );

  test('summary query cannot request draft inclusion', () {
    final query = CostSummaryQuery(projectId: 'project-1');

    expect(query.projectId, 'project-1');
    expect(query.filters.includeDrafts, isFalse);
  });

  test('cost query normalizes combined filters and keeps stable sorting', () {
    final from = DateTime.utc(2026, 1, 1);
    final to = DateTime.utc(2026, 2, 1);

    final query = CostQuery(
      projectId: ' project-1 ',
      searchText: '  beton  ',
      types: const <CostEntryType>{CostEntryType.cost},
      statuses: const <CostStatus>{CostStatus.paid},
      stageIds: const <String>{' state_zero ', 'state_zero'},
      categoryIds: const <String>{' materialy '},
      supplierIds: const <String>{' hurtownia '},
      paymentMethods: const <CostPaymentMethod>{CostPaymentMethod.card},
      sources: const <CostSource>{CostSource.manual},
      warnings: const <CostWarning>{CostWarning.missingDocument},
      fromInclusive: from,
      toExclusive: to,
      includeDrafts: true,
      sort: CostSort.amountDescending,
    );

    expect(query.projectId, 'project-1');
    expect(query.searchText, 'beton');
    expect(query.stageIds, <String>{'state_zero'});
    expect(query.categoryIds, <String>{'materialy'});
    expect(query.supplierIds, <String>{'hurtownia'});
    expect(query.fromInclusive, from);
    expect(query.toExclusive, to);
    expect(query.includeDrafts, isTrue);
    expect(query.sort, CostSort.amountDescending);
    expect(query.activeFilterCount, 10);
  });

  test('cost query rejects an inverted date range', () {
    expect(
      () => CostQuery(
        projectId: 'project-1',
        fromInclusive: DateTime.utc(2026, 2, 1),
        toExclusive: DateTime.utc(2026, 1, 1),
      ),
      throwsArgumentError,
    );
  });

  test('summary query copies active filters but always excludes drafts', () {
    final listQuery = CostQuery(
      projectId: 'project-1',
      searchText: 'okna',
      statuses: const <CostStatus>{CostStatus.paid},
      includeDrafts: true,
    );

    final summary = CostSummaryQuery.fromCostQuery(listQuery);

    expect(summary.projectId, 'project-1');
    expect(summary.filters.searchText, 'okna');
    expect(summary.filters.statuses, <CostStatus>{CostStatus.paid});
    expect(summary.filters.includeDrafts, isFalse);
  });
}
