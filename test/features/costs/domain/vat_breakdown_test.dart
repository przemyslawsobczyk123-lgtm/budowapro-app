import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores VAT rates as integer basis points', () {
    expect(VatRate.values.map((rate) => rate.basisPoints), <int>[0, 800, 2300]);
  });

  group('VAT calculated from net', () {
    test('supports the configured 0, 8 and 23 percent rates', () {
      expect(VatBreakdown.fromNet(_pln(10000), VatRate.zero).vat, _pln(0));
      expect(
        VatBreakdown.fromNet(_pln(10000), VatRate.reduced8).vat,
        _pln(800),
      );
      expect(
        VatBreakdown.fromNet(_pln(10000), VatRate.standard23).vat,
        _pln(2300),
      );
    });

    test('rounds half a grosz up to a full grosz', () {
      final breakdown = VatBreakdown.fromNet(_pln(50), VatRate.standard23);

      expect(breakdown.vat, _pln(12));
      expect(breakdown.gross, _pln(62));
    });

    test('rounds values below half a grosz down', () {
      expect(VatBreakdown.fromNet(_pln(2), VatRate.standard23).vat, _pln(0));
    });

    test('rounds the 8 percent boundary around half a grosz', () {
      expect(VatBreakdown.fromNet(_pln(6), VatRate.reduced8).vat, _pln(0));
      expect(VatBreakdown.fromNet(_pln(7), VatRate.reduced8).vat, _pln(1));
    });

    test('mirrors rounding for a negative correction', () {
      final breakdown = VatBreakdown.fromNet(_pln(-50), VatRate.standard23);

      expect(breakdown.vat, _pln(-12));
      expect(breakdown.gross, _pln(-62));
    });
  });

  group('VAT calculated from gross', () {
    test('extracts net and VAT for 23 percent', () {
      final breakdown = VatBreakdown.fromGross(_pln(12300), VatRate.standard23);

      expect(breakdown.net, _pln(10000));
      expect(breakdown.vat, _pln(2300));
    });

    test('extracts net and VAT for 8 percent', () {
      final breakdown = VatBreakdown.fromGross(_pln(10800), VatRate.reduced8);

      expect(breakdown.net, _pln(10000));
      expect(breakdown.vat, _pln(800));
    });

    test('supports zero VAT and negative gross corrections', () {
      final zeroVat = VatBreakdown.fromGross(_pln(100), VatRate.zero);
      final correction = VatBreakdown.fromGross(
        _pln(-12300),
        VatRate.standard23,
      );

      expect(zeroVat.net, _pln(100));
      expect(zeroVat.vat, _pln(0));
      expect(correction.net, _pln(-10000));
      expect(correction.vat, _pln(-2300));
    });

    test('preserves a small gross when reverse rounding is not invertible', () {
      final fromGross = VatBreakdown.fromGross(_pln(3), VatRate.standard23);
      final recalculated = VatBreakdown.fromNet(
        fromGross.net,
        VatRate.standard23,
      );

      expect(fromGross.net, _pln(2));
      expect(fromGross.vat, _pln(1));
      expect(fromGross.net + fromGross.vat, fromGross.gross);
      expect(recalculated.gross, _pln(2));
    });
  });

  group('VAT restored from storage', () {
    test('preserves a valid gross-originated rounding boundary', () {
      final restored = VatBreakdown.fromStoredValues(
        net: _pln(2),
        vat: _pln(1),
        gross: _pln(3),
        rate: VatRate.standard23,
      );

      expect(restored.net, _pln(2));
      expect(restored.vat, _pln(1));
      expect(restored.gross, _pln(3));
    });

    test('rejects components not produced by either VAT direction', () {
      expect(
        () => VatBreakdown.fromStoredValues(
          net: _pln(100),
          vat: _pln(20),
          gross: _pln(120),
          rate: VatRate.standard23,
        ),
        throwsFormatException,
      );
    });
  });
}

Money _pln(int minorUnits) {
  return Money(minorUnits: minorUnits, currencyCode: 'PLN');
}
