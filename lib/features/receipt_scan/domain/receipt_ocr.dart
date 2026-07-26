import 'dart:collection';

final class RecognizedReceiptLine {
  const RecognizedReceiptLine({required this.text, required this.confidence});

  final String text;
  final double? confidence;
}

final class RecognizedReceiptText {
  factory RecognizedReceiptText.fromRaw(String rawText) {
    final normalizedNewlines = rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    return RecognizedReceiptText.fromLines(
      normalizedNewlines
          .split('\n')
          .map((line) => RecognizedReceiptLine(text: line, confidence: null)),
    );
  }

  factory RecognizedReceiptText.fromLines(
    Iterable<RecognizedReceiptLine> source,
  ) {
    final lines = <RecognizedReceiptLine>[];
    var remainingCharacters = maximumCharacters;

    for (final rawLine in source) {
      if (lines.length == maximumLines || remainingCharacters == 0) {
        break;
      }
      final confidence = rawLine.confidence;
      if (confidence != null &&
          (!confidence.isFinite || confidence < 0 || confidence > 1)) {
        throw RangeError.range(confidence, 0, 1, 'confidence');
      }
      var line = rawLine.text.trim().replaceAll(_whitespace, ' ');
      if (line.isEmpty) continue;
      if (line.length > maximumLineLength) {
        line = line.substring(0, maximumLineLength);
      }
      final separatorLength = lines.isEmpty ? 0 : 1;
      final availableForLine = remainingCharacters - separatorLength;
      if (availableForLine <= 0) break;
      if (line.length > availableForLine) {
        line = line.substring(0, availableForLine);
      }
      lines.add(RecognizedReceiptLine(text: line, confidence: confidence));
      remainingCharacters -= separatorLength + line.length;
    }

    return RecognizedReceiptText._(
      List<RecognizedReceiptLine>.unmodifiable(lines),
    );
  }

  const RecognizedReceiptText._(this.lineDetails);

  static const int maximumCharacters = 32000;
  static const int maximumLines = 240;
  static const int maximumLineLength = 240;

  final List<RecognizedReceiptLine> lineDetails;

  List<String> get lines =>
      List<String>.unmodifiable(lineDetails.map((line) => line.text));
  String get value => lines.join('\n');
  bool get isEmpty => lineDetails.isEmpty;
}

final class ReceiptOcrField {
  factory ReceiptOcrField({
    required String value,
    required double? confidence,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be empty');
    }
    final normalizedConfidence = confidence ?? unknownConfidence;
    if (!normalizedConfidence.isFinite ||
        normalizedConfidence < 0 ||
        normalizedConfidence > 1) {
      throw RangeError.range(normalizedConfidence, 0, 1, 'confidence');
    }
    return ReceiptOcrField._(
      value: normalized,
      confidence: normalizedConfidence,
    );
  }

  const ReceiptOcrField._({required this.value, required this.confidence});

  static const double unknownConfidence = 0.5;
  static const double reviewThreshold = 0.85;

  final String value;
  final double confidence;

  bool get requiresReview => confidence < reviewThreshold;
}

final class ReceiptOcrCandidates {
  ReceiptOcrCandidates({
    required this.recognizedText,
    this.seller,
    this.dateText,
    this.documentNumber,
    this.totalText,
    Iterable<ReceiptOcrField> vatLines = const <ReceiptOcrField>[],
    Iterable<ReceiptOcrField> itemLines = const <ReceiptOcrField>[],
  }) : vatLines = UnmodifiableListView<ReceiptOcrField>(
         List<ReceiptOcrField>.of(vatLines),
       ),
       itemLines = UnmodifiableListView<ReceiptOcrField>(
         List<ReceiptOcrField>.of(itemLines),
       );

  final RecognizedReceiptText recognizedText;
  final ReceiptOcrField? seller;
  final ReceiptOcrField? dateText;
  final ReceiptOcrField? documentNumber;
  final ReceiptOcrField? totalText;
  final UnmodifiableListView<ReceiptOcrField> vatLines;
  final UnmodifiableListView<ReceiptOcrField> itemLines;

  ReceiptOcrField? get date => dateText;
  ReceiptOcrField? get total => totalText;

  bool get isEmpty => recognizedText.isEmpty;
}

final class ReceiptOcrCandidateParser {
  const ReceiptOcrCandidateParser();

  ReceiptOcrCandidates parse(RecognizedReceiptText recognizedText) {
    final lines = recognizedText.lineDetails;
    if (lines.isEmpty) {
      return ReceiptOcrCandidates(recognizedText: recognizedText);
    }

    return ReceiptOcrCandidates(
      recognizedText: recognizedText,
      seller: _seller(lines),
      dateText: _date(lines),
      documentNumber: _documentNumber(lines),
      totalText: _total(lines),
      vatLines: lines
          .where((line) => _isVatLine(line.text))
          .map(_wholeLineField),
      itemLines: _itemLines(lines),
    );
  }
}

final RegExp _whitespace = RegExp(r'\s+');
final RegExp _letter = RegExp(r'[A-Za-zĄĆĘŁŃÓŚŹŻąćęłńóśźż]');
final RegExp _datePattern = RegExp(
  r'(?:\b\d{4}[-./]\d{2}[-./]\d{2}\b|\b\d{2}[-./]\d{2}[-./]\d{4}\b)',
);
final RegExp _documentNumberPattern = RegExp(
  r'^(?:NR|NO|NUMER(?:\s+DOKUMENTU)?)\s*[:.#-]?\s*(.+)$',
  caseSensitive: false,
);
final RegExp _invoiceNumberPattern = RegExp(
  r'^FAKTURA(?:\s+VAT)?\s*(?:NR|NO|NUMER)?\s*[:.#-]?\s*(.+)$',
  caseSensitive: false,
);
final RegExp _moneyPattern = RegExp(
  r'(?<!\d)(?:\d{1,3}(?:[ .]\d{3})*|\d+)[,.]\d{2}(?!\d)',
);

bool _isSellerCandidate(String line) {
  if (!_letter.hasMatch(line)) return false;
  final upper = line.toUpperCase();
  return !_sellerExcludedMarkers.any(upper.contains);
}

const List<String> _sellerExcludedMarkers = <String>[
  'PARAGON',
  'FAKTURA',
  'NIP',
  'DATA',
  'NUMER',
  'NR ',
  'PTU',
  'VAT',
  'SUMA',
  'RAZEM',
  'TOTAL',
  'DO ZAP',
  'KARTA',
  'GOTÓW',
  'SPRZEDAWCA',
  'NABYWCA',
  'KLIENT',
  'ADRES',
  'E-MAIL',
  'EMAIL',
  'WWW.',
  'TEL.',
];

ReceiptOcrField? _seller(List<RecognizedReceiptLine> lines) {
  RecognizedReceiptLine? best;
  var bestScore = -1000;
  final limit = lines.length < 24 ? lines.length : 24;
  for (var index = 0; index < limit; index += 1) {
    final line = lines[index];
    if (!_isSellerCandidate(line.text)) continue;
    final score = _sellerScore(line.text);
    if (score > bestScore) {
      best = line;
      bestScore = score;
    }
  }
  return best == null ? null : _wholeLineField(best);
}

int _sellerScore(String value) {
  final upper = value.toUpperCase();
  var score = 0;
  if (RegExp(r'\b(?:SP\.?\s*Z\s*O\.?O\.?|S\.?A\.?)\b').hasMatch(upper)) {
    score += 8;
  }
  if (value == upper && _letter.allMatches(value).length >= 4) {
    score += 3;
  }
  if (upper.contains('SKLEP') || upper.contains('MARKET')) score += 2;
  if (RegExp(r'\bUL\.|\bAL\.|\bOS\.').hasMatch(upper)) score -= 8;
  if (RegExp(r'\b\d{2}-\d{3}\b').hasMatch(value)) score -= 8;
  if (value.contains('@') || upper.contains('HTTP')) score -= 8;
  if (value.endsWith(':')) score -= 5;
  return score;
}

ReceiptOcrField _wholeLineField(RecognizedReceiptLine line) {
  return ReceiptOcrField(value: line.text, confidence: line.confidence);
}

ReceiptOcrField? _date(List<RecognizedReceiptLine> lines) {
  RecognizedReceiptLine? bestLine;
  String? bestValue;
  var bestScore = -1000;
  for (final line in lines) {
    for (final match in _datePattern.allMatches(line.text)) {
      final value = match.group(0);
      if (value == null || !_isPlausibleDate(value)) continue;
      final upper = line.text.toUpperCase();
      var score = 0;
      if (upper.contains('DATA WYSTAWIENIA')) {
        score += 12;
      } else if (upper.contains('DATA')) {
        score += 6;
      }
      if (upper.contains('FAKTURA NR') ||
          upper.contains('NUMER') ||
          upper.contains('NR SYS')) {
        score -= 10;
      }
      if (RegExp(r'^\d{4}').hasMatch(value)) score += 2;
      if (score > bestScore) {
        bestLine = line;
        bestValue = value;
        bestScore = score;
      }
    }
  }
  if (bestLine == null || bestValue == null) return null;
  return ReceiptOcrField(value: bestValue, confidence: bestLine.confidence);
}

bool _isPlausibleDate(String value) {
  final parts = value.split(RegExp(r'[-./]'));
  if (parts.length != 3) return false;
  final yearFirst = parts[0].length == 4;
  final year = int.tryParse(yearFirst ? parts[0] : parts[2]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(yearFirst ? parts[2] : parts[0]);
  if (year == null ||
      month == null ||
      day == null ||
      year < 1990 ||
      year > 2100) {
    return false;
  }
  final date = DateTime.utc(year, month, day);
  return date.year == year && date.month == month && date.day == day;
}

ReceiptOcrField? _documentNumber(List<RecognizedReceiptLine> lines) {
  for (final line in lines) {
    final match =
        _invoiceNumberPattern.firstMatch(line.text) ??
        _documentNumberPattern.firstMatch(line.text);
    final value = match?.group(1)?.trim();
    if (value != null &&
        value.isNotEmpty &&
        !value.toUpperCase().startsWith('SYS')) {
      return ReceiptOcrField(value: value, confidence: line.confidence);
    }
  }
  return null;
}

ReceiptOcrField? _total(List<RecognizedReceiptLine> lines) {
  ReceiptOcrField? best;
  var bestScore = -1;
  for (var index = 0; index < lines.length; index += 1) {
    final line = lines[index];
    final upper = line.text.toUpperCase();
    final score = _totalMarkerScore(upper);
    if (score == null || score < bestScore) continue;
    final matches = _moneyPattern.allMatches(line.text).toList(growable: false);
    final value = matches.lastOrNull?.group(0);
    if (value != null) {
      best = ReceiptOcrField(value: value, confidence: line.confidence);
      bestScore = score;
      continue;
    }
    final followingLimit = index + 3 < lines.length ? index + 3 : lines.length;
    for (
      var followingIndex = index + 1;
      followingIndex < followingLimit;
      followingIndex += 1
    ) {
      final following = lines[followingIndex];
      final followingMatches = _moneyPattern
          .allMatches(following.text)
          .toList(growable: false);
      final followingValue = followingMatches.lastOrNull?.group(0);
      if (followingValue != null) {
        best = ReceiptOcrField(
          value: followingValue,
          confidence: _minimumConfidence(line, following),
        );
        bestScore = score;
        break;
      }
    }
  }
  return best;
}

int? _totalMarkerScore(String upper) {
  if (upper.contains('SUMA PTU') || upper.contains('SUMA VAT')) return null;
  if (upper.contains('CAŁKOWITA WARTOŚĆ BRUTTO') ||
      upper.contains('CALKOWITA WARTOSC BRUTTO')) {
    return 100;
  }
  if (upper.contains('RAZEM') ||
      upper.contains('SUMA PLN') ||
      upper.contains('TOTAL')) {
    return 95;
  }
  if (upper.contains('WARTOŚĆ BRUTTO') || upper.contains('WARTOSC BRUTTO')) {
    return 90;
  }
  if (upper.contains('PODSUMA')) return 40;
  if (upper.contains('DO ZAPŁATY') || upper.contains('DO ZAPLATY')) {
    return 70;
  }
  if (upper.contains('SUMA')) return 80;
  return null;
}

bool _isVatLine(String line) {
  final upper = line.toUpperCase();
  return upper.contains('VAT') || upper.contains('PTU');
}

bool _isItemLine(String line) {
  if (!_letter.hasMatch(line) ||
      !_moneyPattern.hasMatch(line) ||
      _isStandaloneAmountLine(line)) {
    return false;
  }
  final upper = line.toUpperCase();
  return !_itemExcludedMarkers.any(upper.contains);
}

bool _isStandaloneAmountLine(String value) {
  final withoutAmounts = value.replaceAll(_moneyPattern, '').trim();
  return RegExp(
    r'^(?:PLN|ZŁ|ZL)?\s*[A-Z]?$',
    caseSensitive: false,
  ).hasMatch(withoutAmounts);
}

Iterable<ReceiptOcrField> _itemLines(List<RecognizedReceiptLine> lines) sync* {
  for (var index = 0; index < lines.length; index += 1) {
    final line = lines[index];
    if (index > 0 &&
        _looksLikeQuantityPriceLine(line.text) &&
        _isProductNameOnly(lines[index - 1].text)) {
      final amount = _moneyPattern
          .allMatches(line.text)
          .toList(growable: false)
          .lastOrNull
          ?.group(0);
      if (amount != null) {
        yield ReceiptOcrField(
          value: '${lines[index - 1].text} $amount',
          confidence: _minimumConfidence(lines[index - 1], line),
        );
        continue;
      }
    }
    if (_isItemLine(line.text) && !_looksLikeQuantityPriceLine(line.text)) {
      yield _wholeLineField(line);
    }
  }
}

bool _looksLikeQuantityPriceLine(String value) {
  final amounts = _moneyPattern.allMatches(value).length;
  return amounts >= 2 &&
      (RegExp(r'^\s*\d+(?:[,.]\d+)?\s*[xX]').hasMatch(value) ||
          !_letter.hasMatch(value.replaceAll(RegExp(r'[A-Za-z]$'), '')));
}

bool _isProductNameOnly(String value) {
  if (!_letter.hasMatch(value) || _moneyPattern.hasMatch(value)) return false;
  final upper = value.toUpperCase();
  return !_itemExcludedMarkers.any(upper.contains);
}

double? _minimumConfidence(
  RecognizedReceiptLine first,
  RecognizedReceiptLine second,
) {
  final firstConfidence = first.confidence;
  final secondConfidence = second.confidence;
  if (firstConfidence == null) return secondConfidence;
  if (secondConfidence == null) return firstConfidence;
  return firstConfidence < secondConfidence
      ? firstConfidence
      : secondConfidence;
}

const List<String> _itemExcludedMarkers = <String>[
  'PARAGON',
  'FAKTURA',
  'NIP',
  'DATA',
  'NUMER',
  'NR ',
  'PTU',
  'VAT',
  'SUMA',
  'RAZEM',
  'TOTAL',
  'DO ZAP',
  'KARTA',
  'GOTÓW',
  'PŁATNO',
  'PLATNO',
  'RABAT',
  'PODSUMA',
  'SPRZEDAŻ',
  'SPRZEDAZ',
  'SPRZEDAWCA',
  'NABYWCA',
];
