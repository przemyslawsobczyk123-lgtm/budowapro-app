import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_summary.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty project returns zero plan, actual and difference', () {
    final summary = const CalculateCostSummary().call(
      projectId: 'project-1',
      currencyCode: 'PLN',
    );

    expect(summary.planned, _pln(0));
    expect(summary.actual, _pln(0));
    expect(summary.difference, _pln(0));
  });

  test('separates plan and actual while excluding offers and drafts', () {
    final entries = <CostEntry>[
      _entry('plan', CostEntryType.planned, 10000),
      _entry('cost', CostEntryType.cost, 8000, status: CostStatus.paid),
      _entry('offer', CostEntryType.offer, 5000),
      _entry('draft', CostEntryType.cost, 2000, lifecycle: CostLifecycle.draft),
    ];
    final corrections = <CostCorrection>[
      CostCorrection(
        id: 'correction-1',
        projectId: 'project-1',
        costEntryId: 'cost',
        reason: CostCorrectionReason.returnedGoods,
        delta: _amount(-1000),
        createdAt: DateTime.utc(2026, 7, 20),
      ),
    ];
    final impacts = <DecisionCostImpact>[
      DecisionCostImpact(
        id: 'impact-approved',
        projectId: 'project-1',
        decisionId: 'decision-1',
        delta: _pln(500),
        status: DecisionCostImpactStatus.approved,
        createdAt: DateTime.utc(2026, 7, 20),
      ),
      DecisionCostImpact(
        id: 'impact-proposed',
        projectId: 'project-1',
        decisionId: 'decision-2',
        delta: _pln(9000),
        status: DecisionCostImpactStatus.proposed,
        createdAt: DateTime.utc(2026, 7, 20),
      ),
    ];

    final summary = const CalculateCostSummary().call(
      projectId: 'project-1',
      currencyCode: 'PLN',
      entries: entries,
      corrections: corrections,
      decisionImpacts: impacts,
    );

    expect(summary.planned, _pln(10500));
    expect(summary.actual, _pln(7000));
    expect(summary.difference, _pln(-3500));
  });

  test('positive difference means actual cost is over plan', () {
    final summary = const CalculateCostSummary().call(
      projectId: 'project-1',
      currencyCode: 'PLN',
      entries: <CostEntry>[
        _entry('plan', CostEntryType.planned, 1000),
        _entry('cost', CostEntryType.cost, 1250),
      ],
    );

    expect(summary.difference, _pln(250));
  });

  test('rejects records from another project or currency', () {
    expect(
      () => const CalculateCostSummary().call(
        projectId: 'project-1',
        currencyCode: 'PLN',
        entries: <CostEntry>[
          _entry(
            'other-project',
            CostEntryType.cost,
            100,
            projectId: 'project-2',
          ),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => const CalculateCostSummary().call(
        projectId: 'project-1',
        currencyCode: 'PLN',
        entries: <CostEntry>[
          _entry('euro', CostEntryType.cost, 100, currencyCode: 'EUR'),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('rejects a correction without a confirmed cost target', () {
    final correction = CostCorrection(
      id: 'correction-1',
      projectId: 'project-1',
      costEntryId: 'missing',
      reason: CostCorrectionReason.returnedGoods,
      delta: _amount(-100),
      createdAt: DateTime.utc(2026, 7, 20),
    );

    expect(
      () => const CalculateCostSummary().call(
        projectId: 'project-1',
        currencyCode: 'PLN',
        corrections: <CostCorrection>[correction],
      ),
      throwsStateError,
    );
  });

  test('rejects a duplicate correction and a return above original cost', () {
    final entry = _entry('cost', CostEntryType.cost, 1000);
    final correction = CostCorrection(
      id: 'correction-1',
      projectId: 'project-1',
      costEntryId: entry.id,
      reason: CostCorrectionReason.returnedGoods,
      delta: _amount(-100),
      createdAt: DateTime.utc(2026, 7, 20),
    );
    expect(
      () => const CalculateCostSummary().call(
        projectId: 'project-1',
        currencyCode: 'PLN',
        entries: <CostEntry>[entry],
        corrections: <CostCorrection>[correction, correction],
      ),
      throwsStateError,
    );

    final excessiveReturn = CostCorrection(
      id: 'correction-2',
      projectId: 'project-1',
      costEntryId: entry.id,
      reason: CostCorrectionReason.returnedGoods,
      delta: _amount(-1001),
      createdAt: DateTime.utc(2026, 7, 20),
    );
    expect(
      () => const CalculateCostSummary().call(
        projectId: 'project-1',
        currencyCode: 'PLN',
        entries: <CostEntry>[entry],
        corrections: <CostCorrection>[excessiveReturn],
      ),
      throwsStateError,
    );
  });

  test('validates final correction total independently of input order', () {
    final entry = _entry('cost', CostEntryType.cost, 1000);
    final decrease = CostCorrection(
      id: 'decrease',
      projectId: 'project-1',
      costEntryId: entry.id,
      reason: CostCorrectionReason.priceCorrection,
      delta: _amount(-1100),
      createdAt: DateTime.utc(2026, 7, 20),
    );
    final increase = CostCorrection(
      id: 'increase',
      projectId: 'project-1',
      costEntryId: entry.id,
      reason: CostCorrectionReason.priceCorrection,
      delta: _amount(200),
      createdAt: DateTime.utc(2026, 7, 21),
    );

    final decreaseFirst = const CalculateCostSummary().call(
      projectId: 'project-1',
      currencyCode: 'PLN',
      entries: <CostEntry>[entry],
      corrections: <CostCorrection>[decrease, increase],
    );
    final increaseFirst = const CalculateCostSummary().call(
      projectId: 'project-1',
      currencyCode: 'PLN',
      entries: <CostEntry>[entry],
      corrections: <CostCorrection>[increase, decrease],
    );

    expect(decreaseFirst.actual, _pln(100));
    expect(increaseFirst.actual, decreaseFirst.actual);
  });
}

CostEntry _entry(
  String id,
  CostEntryType type,
  int amount, {
  CostStatus? status,
  CostLifecycle lifecycle = CostLifecycle.confirmed,
  String projectId = 'project-1',
  String currencyCode = 'PLN',
}) {
  return CostEntry(
    id: id,
    input: CostEntryInput(
      projectId: projectId,
      name: 'Pozycja $id',
      type: type,
      status:
          status ??
          switch (type) {
            CostEntryType.cost =>
              lifecycle == CostLifecycle.draft
                  ? CostStatus.planned
                  : CostStatus.due,
            CostEntryType.offer || CostEntryType.planned => CostStatus.planned,
          },
      amount: VatBreakdown.fromNet(
        Money(minorUnits: amount, currencyCode: currencyCode),
        VatRate.zero,
      ),
      entryDate: DateTime.utc(2026, 7, 15),
    ),
    lifecycle: lifecycle,
    createdAt: DateTime.utc(2026, 7, 15),
    updatedAt: DateTime.utc(2026, 7, 15),
  );
}

VatBreakdown _amount(int netMinorUnits) {
  return VatBreakdown.fromNet(_pln(netMinorUnits), VatRate.zero);
}

Money _pln(int minorUnits) {
  return Money(minorUnits: minorUnits, currencyCode: 'PLN');
}
