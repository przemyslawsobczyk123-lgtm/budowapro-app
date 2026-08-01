const int maximumJournalCostDeltaMinorUnits = 9000000000000;
const int maximumJournalScheduleDeltaDays = 36500;

int? parseJournalCostDelta(String rawValue) {
  final normalized = rawValue.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^[+-]?\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) {
    throw const FormatException('Invalid cost delta');
  }
  final negative = normalized.startsWith('-');
  final unsigned = normalized.replaceFirst(RegExp(r'^[+-]'), '');
  final parts = unsigned.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  var value =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  if (negative) value = -value;
  if (value.abs() > BigInt.from(maximumJournalCostDeltaMinorUnits)) {
    throw RangeError('Cost delta exceeds the supported range');
  }
  return value.toInt();
}

int? parseJournalScheduleDelta(String rawValue) {
  final normalized = rawValue.trim();
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^[+-]?\d+$').hasMatch(normalized)) {
    throw const FormatException('Invalid schedule delta');
  }
  final value = int.parse(normalized);
  if (value.abs() > maximumJournalScheduleDeltaDays) {
    throw RangeError('Schedule delta exceeds the supported range');
  }
  return value;
}

String formatJournalCostDelta(int? minorUnits) {
  if (minorUnits == null) return '';
  final absolute = BigInt.from(minorUnits).abs();
  final whole = absolute ~/ BigInt.from(100);
  final fraction = (absolute % BigInt.from(100)).toString().padLeft(2, '0');
  return '${minorUnits < 0 ? '-' : ''}$whole,$fraction';
}

String formatJournalScheduleDelta(int? days) => days?.toString() ?? '';
