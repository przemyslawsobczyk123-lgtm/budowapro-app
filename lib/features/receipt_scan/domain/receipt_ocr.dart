import 'dart:collection';

final class RecognizedReceiptText {
  factory RecognizedReceiptText.fromRaw(String rawText) {
    final lines = <String>[];
    var remainingCharacters = maximumCharacters;
    final normalizedNewlines = rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    for (final rawLine in normalizedNewlines.split('\n')) {
      if (lines.length == maximumLines || remainingCharacters == 0) {
        break;
      }
      var line = rawLine.trim().replaceAll(_whitespace, ' ');
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
      lines.add(line);
      remainingCharacters -= separatorLength + line.length;
    }

    return RecognizedReceiptText._(List<String>.unmodifiable(lines));
  }

  const RecognizedReceiptText._(this.lines);

  static const int maximumCharacters = 32000;
  static const int maximumLines = 240;
  static const int maximumLineLength = 240;

  final List<String> lines;

  String get value => lines.join('\n');
  bool get isEmpty => lines.isEmpty;
}

final class ReceiptOcrCandidates {
  ReceiptOcrCandidates({
    required this.recognizedText,
    this.seller,
    this.dateText,
    this.documentNumber,
    this.totalText,
    Iterable<String> vatLines = const <String>[],
    Iterable<String> itemLines = const <String>[],
  }) : vatLines = UnmodifiableListView<String>(List<String>.of(vatLines)),
       itemLines = UnmodifiableListView<String>(List<String>.of(itemLines));

  final RecognizedReceiptText recognizedText;
  final String? seller;
  final String? dateText;
  final String? documentNumber;
  final String? totalText;
  final UnmodifiableListView<String> vatLines;
  final UnmodifiableListView<String> itemLines;

  bool get isEmpty => recognizedText.isEmpty;
}

final class ReceiptOcrCandidateParser {
  const ReceiptOcrCandidateParser();

  ReceiptOcrCandidates parse(RecognizedReceiptText recognizedText) {
    final lines = recognizedText.lines;
    if (lines.isEmpty) {
      return ReceiptOcrCandidates(recognizedText: recognizedText);
    }

    return ReceiptOcrCandidates(
      recognizedText: recognizedText,
      seller: lines.where(_isSellerCandidate).firstOrNull,
      dateText: _firstMatch(lines, _datePattern),
      documentNumber: _documentNumber(lines),
      totalText: _total(lines),
      vatLines: lines.where(_isVatLine),
      itemLines: lines.where(_isItemLine),
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

String? _firstMatch(List<String> lines, RegExp pattern) {
  for (final line in lines) {
    final match = pattern.firstMatch(line);
    if (match != null) return match.group(0);
  }
  return null;
}

String? _documentNumber(List<String> lines) {
  for (final line in lines) {
    final match = _documentNumberPattern.firstMatch(line);
    final value = match?.group(1)?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

String? _total(List<String> lines) {
  for (final line in lines.reversed) {
    final upper = line.toUpperCase();
    if (!_totalMarkers.any(upper.contains)) continue;
    final matches = _moneyPattern.allMatches(line).toList(growable: false);
    if (matches.isNotEmpty) return matches.last.group(0);
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
