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
      seller: _firstFieldWhere(lines, _isSellerCandidate),
      dateText: _firstMatch(lines, _datePattern),
      documentNumber: _documentNumber(lines),
      totalText: _total(lines),
      vatLines: lines
          .where((line) => _isVatLine(line.text))
          .map(_wholeLineField),
      itemLines: lines
          .where((line) => _isItemLine(line.text))
          .map(_wholeLineField),
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
];

ReceiptOcrField? _firstFieldWhere(
  List<RecognizedReceiptLine> lines,
  bool Function(String value) predicate,
) {
  for (final line in lines) {
    if (predicate(line.text)) return _wholeLineField(line);
  }
  return null;
}

ReceiptOcrField _wholeLineField(RecognizedReceiptLine line) {
  return ReceiptOcrField(value: line.text, confidence: line.confidence);
}

ReceiptOcrField? _firstMatch(
  List<RecognizedReceiptLine> lines,
  RegExp pattern,
) {
  for (final line in lines) {
    final match = pattern.firstMatch(line.text);
    final value = match?.group(0);
    if (value != null) {
      return ReceiptOcrField(value: value, confidence: line.confidence);
    }
  }
  return null;
}

ReceiptOcrField? _documentNumber(List<RecognizedReceiptLine> lines) {
  for (final line in lines) {
    final match = _documentNumberPattern.firstMatch(line.text);
    final value = match?.group(1)?.trim();
    if (value != null && value.isNotEmpty) {
      return ReceiptOcrField(value: value, confidence: line.confidence);
    }
  }
  return null;
}

ReceiptOcrField? _total(List<RecognizedReceiptLine> lines) {
  for (final line in lines.reversed) {
    final upper = line.text.toUpperCase();
    if (!_totalMarkers.any(upper.contains)) continue;
    final matches = _moneyPattern.allMatches(line.text).toList(growable: false);
    final value = matches.lastOrNull?.group(0);
    if (value != null) {
      return ReceiptOcrField(value: value, confidence: line.confidence);
    }
  }
  return null;
}

const List<String> _totalMarkers = <String>[
  'DO ZAPŁATY',
  'DO ZAPLATY',
  'RAZEM',
  'TOTAL',
  'SUMA',
];

bool _isVatLine(String line) {
  final upper = line.toUpperCase();
  return upper.contains('VAT') || upper.contains('PTU');
}

bool _isItemLine(String line) {
  if (!_letter.hasMatch(line) || !_moneyPattern.hasMatch(line)) return false;
  final upper = line.toUpperCase();
  return !_itemExcludedMarkers.any(upper.contains);
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
];
