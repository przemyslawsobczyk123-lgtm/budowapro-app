import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defines the required entry types and financial statuses', () {
    expect(CostEntryType.values, <CostEntryType>[
      CostEntryType.cost,
      CostEntryType.offer,
      CostEntryType.planned,
    ]);
    expect(CostStatus.values, <CostStatus>[
      CostStatus.planned,
      CostStatus.ordered,
      CostStatus.due,
      CostStatus.paid,
      CostStatus.returned,
      CostStatus.disputed,
    ]);
  });

  test('normalizes input and stores dates in UTC', () {
    final input = CostEntryInput(
      projectId: ' project-1 ',
      name: '  Przepusty pod instalacje  ',
      type: CostEntryType.cost,
      status: CostStatus.due,
      amount: _amount(10000),
      entryDate: DateTime(2026, 7, 15, 12),
      stageId: ' state-zero ',
      categoryId: ' installations ',
      supplierId: ' supplier-1 ',
      contactId: ' contact-1 ',
      quantity: DecimalQuantity(unscaledValue: 125, scale: 2),
      unit: ' m ',
      paymentMethod: CostPaymentMethod.bankTransfer,
      source: CostSource.manual,
      attachmentIds: const <String>[' receipt-1 ', 'invoice-1'],
      note: '  Platnosc po odbiorze  ',
    );

    expect(input.projectId, 'project-1');
    expect(input.name, 'Przepusty pod instalacje');
    expect(input.entryDate.isUtc, isTrue);
    expect(input.stageId, 'state-zero');
    expect(input.categoryId, 'installations');
    expect(input.supplierId, 'supplier-1');
    expect(input.contactId, 'contact-1');
    expect(input.quantity?.unscaledValue, 125);
    expect(input.quantity?.scale, 2);
    expect(input.unit, 'm');
    expect(input.paymentMethod, CostPaymentMethod.bankTransfer);
    expect(input.source, CostSource.manual);
    expect(input.attachmentIds, <String>['receipt-1', 'invoice-1']);
    expect(input.note, 'Platnosc po odbiorze');
  });

  test('requires quantity and unit together', () {
    expect(
      () => CostEntryInput(
        projectId: 'project-1',
        name: 'Material',
        type: CostEntryType.planned,
        status: CostStatus.planned,
        amount: _amount(100),
        entryDate: DateTime.utc(2026, 7, 15),
        quantity: DecimalQuantity(unscaledValue: 2, scale: 0),
      ),
      throwsArgumentError,
    );
  });

  test('regular entries reject negative monetary components', () {
    expect(
      () => CostEntryInput(
        projectId: 'project-1',
        name: 'Niepoprawny koszt',
        type: CostEntryType.cost,
        status: CostStatus.returned,
        amount: _amount(-10000),
        entryDate: DateTime.utc(2026, 7, 15),
      ),
      throwsRangeError,
    );
  });

  test('draft lifecycle remains separate from financial status', () {
    final entry = _entry(lifecycle: CostLifecycle.draft);

    expect(entry.status, CostStatus.planned);
    expect(entry.lifecycle, CostLifecycle.draft);
    expect(entry.isIncludedInSummaries, isFalse);
  });

  test('rejects invalid type and status combinations', () {
    expect(
      () => _customEntry(
        type: CostEntryType.cost,
        status: CostStatus.planned,
        lifecycle: CostLifecycle.draft,
      ),
      returnsNormally,
    );
    expect(
      () => _customEntry(
        type: CostEntryType.offer,
        status: CostStatus.paid,
        lifecycle: CostLifecycle.confirmed,
      ),
      throwsArgumentError,
    );
    expect(
      () => _customEntry(
        type: CostEntryType.planned,
        status: CostStatus.returned,
        lifecycle: CostLifecycle.confirmed,
      ),
      throwsArgumentError,
    );
    expect(
      () => _customEntry(
        type: CostEntryType.cost,
        status: CostStatus.planned,
        lifecycle: CostLifecycle.confirmed,
      ),
      throwsArgumentError,
    );
  });

  test('draft input preserves a preselected paid status', () {
    final paidInput = _input(type: CostEntryType.cost, status: CostStatus.paid);

    expect(CostDraftInput(paidInput).input.status, CostStatus.paid);
  });

  test('direct confirmed input rejects receipt and invoice OCR sources', () {
    for (final source in <CostSource>[
      CostSource.receiptOcr,
      CostSource.invoiceOcr,
    ]) {
      final input = _input(
        type: CostEntryType.cost,
        status: CostStatus.paid,
        source: source,
      );

      expect(() => ConfirmedCostEntryInput(input), throwsArgumentError);
    }
  });

  test('OCR input can enter the review workflow as a draft', () {
    final input = _input(
      type: CostEntryType.cost,
      status: CostStatus.planned,
      source: CostSource.receiptOcr,
    );

    expect(CostDraftInput(input).input.source, CostSource.receiptOcr);
  });

  test('confirmed entry keeps immutable identity and audit timestamps', () {
    final entry = _entry(lifecycle: CostLifecycle.confirmed);

    expect(entry.id, 'cost-1');
    expect(entry.projectId, 'project-1');
    expect(entry.createdAtUtc, DateTime.utc(2026, 7, 15, 10));
    expect(entry.updatedAtUtc, DateTime.utc(2026, 7, 15, 11));
    expect(entry.isIncludedInSummaries, isTrue);
    expect(entry.revision, 1);
  });

  test('confirmed details input contains no monetary or status fields', () {
    final details = ConfirmedCostDetailsInput(
      name: '  Zmieniona nazwa  ',
      component: CostComponent.labor,
      entryDate: DateTime(2026, 7, 20),
      stageId: ' state-zero ',
      quantity: DecimalQuantity(unscaledValue: 25, scale: 1),
      unit: ' m ',
      paymentMethod: CostPaymentMethod.card,
      note: '  Po korekcie opisu  ',
    );

    expect(details.name, 'Zmieniona nazwa');
    expect(details.component, CostComponent.labor);
    expect(details.entryDate.isUtc, isTrue);
    expect(details.stageId, 'state-zero');
    expect(details.unit, 'm');
    expect(details.note, 'Po korekcie opisu');
  });

  test('history entry validates a positive revision', () {
    expect(
      () => CostHistoryEntry(
        id: 'history-1',
        projectId: 'project-1',
        costEntryId: 'cost-1',
        revision: 0,
        action: CostHistoryAction.created,
        createdAt: DateTime.utc(2026, 7, 15),
      ),
      throwsRangeError,
    );
  });

  test('negative return is an append-only correction', () {
    final original = _entry(lifecycle: CostLifecycle.confirmed);
    final correction = CostCorrection(
      id: 'correction-1',
      projectId: original.projectId,
      costEntryId: original.id,
      reason: CostCorrectionReason.returnedGoods,
      delta: _amount(-2500),
      createdAt: DateTime.utc(2026, 7, 20),
      note: 'Zwrot nadmiaru materialu',
    );

    expect(correction.delta.gross.isNegative, isTrue);
    expect(original.amount.gross, _pln(12300));
  });

  test('return correction rejects a positive delta', () {
    expect(
      () => CostCorrection(
        id: 'correction-1',
        projectId: 'project-1',
        costEntryId: 'cost-1',
        reason: CostCorrectionReason.returnedGoods,
        delta: _amount(100),
        createdAt: DateTime.utc(2026, 7, 20),
      ),
      throwsArgumentError,
    );
  });

  test('decision cost impact is separate from the original plan', () {
    final impact = DecisionCostImpact(
      id: 'impact-1',
      projectId: 'project-1',
      decisionId: 'decision-1',
      delta: _pln(50000),
      status: DecisionCostImpactStatus.approved,
      createdAt: DateTime.utc(2026, 7, 20),
    );

    expect(impact.delta, _pln(50000));
    expect(impact.status, DecisionCostImpactStatus.approved);
  });
}

CostEntry _entry({required CostLifecycle lifecycle}) {
  return CostEntry(
    id: 'cost-1',
    input: CostEntryInput(
      projectId: 'project-1',
      name: 'Plan fundamentow',
      type: CostEntryType.planned,
      status: CostStatus.planned,
      amount: _amount(10000),
      entryDate: DateTime.utc(2026, 7, 15),
    ),
    lifecycle: lifecycle,
    createdAt: DateTime.utc(2026, 7, 15, 10),
    updatedAt: DateTime.utc(2026, 7, 15, 11),
  );
}

CostEntry _customEntry({
  required CostEntryType type,
  required CostStatus status,
  required CostLifecycle lifecycle,
}) {
  return CostEntry(
    id: 'custom-entry',
    input: _input(type: type, status: status),
    lifecycle: lifecycle,
    createdAt: DateTime.utc(2026, 7, 15),
    updatedAt: DateTime.utc(2026, 7, 15),
  );
}

CostEntryInput _input({
  required CostEntryType type,
  required CostStatus status,
  CostSource source = CostSource.manual,
}) {
  return CostEntryInput(
    projectId: 'project-1',
    name: 'Pozycja',
    type: type,
    status: status,
    amount: _amount(10000),
    entryDate: DateTime.utc(2026, 7, 15),
    source: source,
  );
}

VatBreakdown _amount(int netMinorUnits) {
  return VatBreakdown.fromNet(_pln(netMinorUnits), VatRate.standard23);
}

Money _pln(int minorUnits) {
  return Money(minorUnits: minorUnits, currencyCode: 'PLN');
}
