import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Polish gross amount and quantity without double', () {
    final input = parseCostForm(
      _submission(grossAmount: '12 345,67', quantity: '18,500', unit: 'm3'),
      projectId: 'project-1',
      currencyCode: 'PLN',
      asDraft: false,
    );

    expect(input.amount.gross.minorUnits, 1234567);
    expect(input.amount.net.minorUnits, 1003713);
    expect(input.amount.vat.minorUnits, 230854);
    expect(input.component, CostComponent.material);
    expect(input.quantity?.unscaledValue, 18500);
    expect(input.quantity?.scale, 3);
    expect(input.unit, 'm3');
  });

  test(
    'draft preserves the selected status without changing submitted values',
    () {
      final submission = _submission(
        status: CostStatus.paid,
        grossAmount: '100,00',
      );

      final input = parseCostForm(
        submission,
        projectId: 'project-1',
        currencyCode: 'PLN',
        asDraft: true,
      );

      expect(input.status, CostStatus.paid);
      expect(submission.status, CostStatus.paid);
    },
  );

  test('reports field errors for invalid amount and quantity pair', () {
    expect(
      () => parseCostForm(
        _submission(grossAmount: '-10', quantity: '2', unit: ''),
        projectId: 'project-1',
        currencyCode: 'PLN',
        asDraft: false,
      ),
      throwsA(
        isA<CostFormValidationException>()
            .having(
              (error) => error.errors[CostFormField.grossAmount],
              'amount error',
              CostFormError.invalidAmount,
            )
            .having(
              (error) => error.errors[CostFormField.unit],
              'unit error',
              CostFormError.quantityAndUnitRequired,
            ),
      ),
    );
  });

  test('exposes only valid statuses for each type', () {
    expect(validStatusesFor(CostEntryType.offer), <CostStatus>[
      CostStatus.planned,
    ]);
    expect(validStatusesFor(CostEntryType.planned), <CostStatus>[
      CostStatus.planned,
      CostStatus.ordered,
      CostStatus.disputed,
    ]);
    expect(validStatusesFor(CostEntryType.cost), <CostStatus>[
      CostStatus.ordered,
      CostStatus.due,
      CostStatus.paid,
      CostStatus.returned,
      CostStatus.disputed,
    ]);
  });

  test('formats SQLite int64 money exactly without double precision loss', () {
    expect(
      formatMoneyForDisplay(
        Money(minorUnits: Money.maximumMinorUnits, currencyCode: 'PLN'),
        'PLN',
      ),
      '92\u00A0233\u00A0720\u00A0368\u00A0547\u00A0758,07 PLN',
    );
  });
}

CostFormSubmission _submission({
  String grossAmount = '123,00',
  String quantity = '',
  String unit = '',
  CostStatus status = CostStatus.paid,
}) {
  return CostFormSubmission(
    name: 'Beton',
    type: CostEntryType.cost,
    component: CostComponent.material,
    status: status,
    grossAmount: grossAmount,
    vatRate: VatRate.standard23,
    entryDate: DateTime.utc(2026, 7, 15),
    stageId: 'state_zero',
    categoryId: 'materialy',
    supplierId: 'betoniarnia',
    quantity: quantity,
    unit: unit,
    paymentMethod: CostPaymentMethod.bankTransfer,
    note: 'Dostawa rano',
  );
}
