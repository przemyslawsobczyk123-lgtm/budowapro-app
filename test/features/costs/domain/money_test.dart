import 'package:budowapro/features/costs/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores signed minor units without floating point values', () {
    final amount = Money(minorUnits: -12345, currencyCode: 'PLN');

    expect(amount.minorUnits, -12345);
    expect(amount.currencyCode, 'PLN');
    expect(amount.isNegative, isTrue);
  });

  test('rejects invalid currency codes and accepts SQLite int64 bounds', () {
    expect(
      () => Money(minorUnits: 1, currencyCode: 'pln'),
      throwsArgumentError,
    );
    expect(
      Money(
        minorUnits: Money.minimumMinorUnits,
        currencyCode: 'PLN',
      ).minorUnits,
      Money.minimumMinorUnits,
    );
  });

  test('adds and subtracts amounts in the same currency', () {
    final planned = Money(minorUnits: 10000, currencyCode: 'PLN');
    final correction = Money(minorUnits: -1250, currencyCode: 'PLN');

    expect(planned + correction, Money(minorUnits: 8750, currencyCode: 'PLN'));
    expect(planned - correction, Money(minorUnits: 11250, currencyCode: 'PLN'));
  });

  test('rejects arithmetic across currencies and int64 overflow', () {
    final pln = Money(minorUnits: 1, currencyCode: 'PLN');
    final eur = Money(minorUnits: 1, currencyCode: 'EUR');
    final maximum = Money(
      minorUnits: Money.maximumMinorUnits,
      currencyCode: 'PLN',
    );

    expect(() => pln + eur, throwsArgumentError);
    expect(() => maximum + pln, throwsRangeError);
  });

  test('rejects int64 underflow and negating the minimum value', () {
    final minimum = Money(
      minorUnits: Money.minimumMinorUnits,
      currencyCode: 'PLN',
    );
    final one = Money(minorUnits: 1, currencyCode: 'PLN');

    expect(() => minimum - one, throwsRangeError);
    expect(() => -minimum, throwsRangeError);
  });
}
