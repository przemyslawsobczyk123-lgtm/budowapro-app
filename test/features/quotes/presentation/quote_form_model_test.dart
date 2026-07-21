import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/quotes/presentation/quote_form_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Polish gross amount without floating point', () {
    final amount = parseQuoteAmount(
      grossAmount: '12 300,50',
      currencyCode: 'PLN',
      vatRate: VatRate.standard23,
    );

    expect(amount.gross.minorUnits, 1230050);
    expect(amount.gross.currencyCode, 'PLN');
  });

  test('rejects zero, negative and over-precise amounts', () {
    for (final value in <String>['0', '-1', '12,345', 'abc']) {
      expect(
        () => parseQuoteAmount(
          grossAmount: value,
          currencyCode: 'PLN',
          vatRate: VatRate.standard23,
        ),
        throwsA(isA<QuoteAmountFormatException>()),
      );
    }
  });
}
