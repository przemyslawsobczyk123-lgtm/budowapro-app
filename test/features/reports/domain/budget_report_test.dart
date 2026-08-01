import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/reports/domain/budget_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates remaining budget from plan and committed costs', () {
    final report = BudgetReport(
      projectId: 'project-1',
      currencyCode: 'PLN',
      plan: _pln(100000),
      committed: _pln(72000),
      paid: _pln(45000),
      costRecordCount: 3,
      breakdowns: {
        BudgetBreakdownDimension.stage: [
          BudgetReportSlice(
            key: 'stage-1',
            committed: _pln(72000),
            paid: _pln(45000),
            recordCount: 3,
          ),
        ],
      },
    );

    expect(report.remaining, _pln(28000));
    expect(report.hasCosts, isTrue);
    expect(report.slicesFor(BudgetBreakdownDimension.stage), hasLength(1));
    expect(report.slicesFor(BudgetBreakdownDimension.month), isEmpty);
  });

  test('supports a project without a plan and rejects inconsistent totals', () {
    final report = BudgetReport(
      projectId: 'project-1',
      currencyCode: 'PLN',
      committed: _pln(0),
      paid: _pln(0),
      costRecordCount: 0,
    );

    expect(report.remaining, isNull);
    expect(report.hasCosts, isFalse);
    expect(
      () => BudgetReport(
        projectId: 'project-1',
        currencyCode: 'PLN',
        committed: _pln(100),
        paid: _pln(101),
        costRecordCount: 1,
      ),
      throwsArgumentError,
    );
  });

  test('preserves a negative remaining amount as a budget overrun', () {
    final report = BudgetReport(
      projectId: 'project-1',
      currencyCode: 'PLN',
      plan: _pln(10000),
      committed: _pln(12500),
      paid: _pln(9000),
      costRecordCount: 2,
    );

    expect(report.remaining, _pln(-2500));
  });

  test('rejects decision deltas without an approved decision', () {
    expect(
      () => BudgetReport(
        projectId: 'project-1',
        currencyCode: 'PLN',
        plan: _pln(10000),
        committed: _pln(0),
        paid: _pln(0),
        costRecordCount: 0,
        approvedDecisionDelta: _pln(500),
      ),
      throwsArgumentError,
    );
    expect(
      () => BudgetReport(
        projectId: 'project-1',
        currencyCode: 'PLN',
        committed: _pln(0),
        paid: _pln(0),
        costRecordCount: 0,
        approvedScheduleDeltaDays: 2,
      ),
      throwsArgumentError,
    );
  });
}

Money _pln(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');
