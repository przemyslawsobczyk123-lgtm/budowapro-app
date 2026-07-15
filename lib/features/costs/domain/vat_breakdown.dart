import 'money.dart';

enum VatRate {
  zero(0),
  reduced8(800),
  standard23(2300);

  const VatRate(this.basisPoints);

  final int basisPoints;
}

final class VatBreakdown {
  factory VatBreakdown.fromNet(Money net, VatRate rate) {
    final vat = Money(
      minorUnits: _divideRoundedHalfAwayFromZero(
        BigInt.from(net.minorUnits) * BigInt.from(rate.basisPoints),
        BigInt.from(10000),
      ),
      currencyCode: net.currencyCode,
    );
    return VatBreakdown._(net: net, vat: vat, gross: net + vat, rate: rate);
  }

  factory VatBreakdown.fromGross(Money gross, VatRate rate) {
    final vat = Money(
      minorUnits: _divideRoundedHalfAwayFromZero(
        BigInt.from(gross.minorUnits) * BigInt.from(rate.basisPoints),
        BigInt.from(10000 + rate.basisPoints),
      ),
      currencyCode: gross.currencyCode,
    );
    return VatBreakdown._(net: gross - vat, vat: vat, gross: gross, rate: rate);
  }

  const VatBreakdown._({
    required this.net,
    required this.vat,
    required this.gross,
    required this.rate,
  });

  final Money net;
  final Money vat;
  final Money gross;
  final VatRate rate;
}

int _divideRoundedHalfAwayFromZero(BigInt numerator, BigInt denominator) {
  if (denominator <= BigInt.zero) {
    throw ArgumentError.value(denominator, 'denominator', 'must be positive');
  }
  final absoluteNumerator = numerator.abs();
  var quotient = absoluteNumerator ~/ denominator;
  final remainder = absoluteNumerator % denominator;
  if (remainder * BigInt.two >= denominator) {
    quotient += BigInt.one;
  }
  return (numerator < BigInt.zero ? -quotient : quotient).toInt();
}
