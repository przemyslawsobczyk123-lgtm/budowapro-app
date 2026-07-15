final class Money implements Comparable<Money> {
  factory Money({required int minorUnits, required String currencyCode}) {
    if (minorUnits < minimumMinorUnits || minorUnits > maximumMinorUnits) {
      throw RangeError.range(
        minorUnits,
        minimumMinorUnits,
        maximumMinorUnits,
        'minorUnits',
      );
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'must be a three-letter uppercase code',
      );
    }
    return Money._(minorUnits: minorUnits, currencyCode: currencyCode);
  }

  factory Money.fromBigInt({
    required BigInt minorUnits,
    required String currencyCode,
  }) {
    return Money(
      minorUnits: _checkedInt64(minorUnits),
      currencyCode: currencyCode,
    );
  }

  const Money._({required this.minorUnits, required this.currencyCode});

  static const int minimumMinorUnits = -9223372036854775808;
  static const int maximumMinorUnits = 9223372036854775807;

  final int minorUnits;
  final String currencyCode;

  bool get isNegative => minorUnits < 0;
  bool get isZero => minorUnits == 0;

  static Money zero(String currencyCode) {
    return Money(minorUnits: 0, currencyCode: currencyCode);
  }

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(
      minorUnits: _checkedInt64(
        BigInt.from(minorUnits) + BigInt.from(other.minorUnits),
      ),
      currencyCode: currencyCode,
    );
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(
      minorUnits: _checkedInt64(
        BigInt.from(minorUnits) - BigInt.from(other.minorUnits),
      ),
      currencyCode: currencyCode,
    );
  }

  Money operator -() {
    return Money(
      minorUnits: _checkedInt64(-BigInt.from(minorUnits)),
      currencyCode: currencyCode,
    );
  }

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _requireSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError.value(
        other.currencyCode,
        'other',
        'must use currency $currencyCode',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Money &&
        other.minorUnits == minorUnits &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => Object.hash(minorUnits, currencyCode);

  @override
  String toString() => 'Money($minorUnits $currencyCode)';

  static int _checkedInt64(BigInt value) {
    final minimum = BigInt.from(minimumMinorUnits);
    final maximum = BigInt.from(maximumMinorUnits);
    if (value < minimum || value > maximum) {
      throw RangeError('minorUnits must fit SQLite int64: $value');
    }
    return value.toInt();
  }
}
