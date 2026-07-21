import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';

VatBreakdown parseQuoteAmount({
  required String grossAmount,
  required String currencyCode,
  required VatRate vatRate,
}) {
  final normalized = grossAmount.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) {
    throw const QuoteAmountFormatException();
  }
  final parts = normalized.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final value =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  if (value <= BigInt.zero || value > BigInt.from(Money.maximumMinorUnits)) {
    throw const QuoteAmountFormatException();
  }
  return VatBreakdown.fromGross(
    Money(minorUnits: value.toInt(), currencyCode: currencyCode),
    vatRate,
  );
}

final class QuoteAmountFormatException implements Exception {
  const QuoteAmountFormatException();
}
