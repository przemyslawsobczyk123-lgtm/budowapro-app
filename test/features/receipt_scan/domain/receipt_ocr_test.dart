import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecognizedReceiptText', () {
    test('normalizes whitespace and removes empty lines', () {
      final text = RecognizedReceiptText.fromRaw(
        '  DOM   I OGRÓD  \r\n\r\n  Zaprawa   murarska   29,99  ',
      );

      expect(text.lines, <String>['DOM I OGRÓD', 'Zaprawa murarska 29,99']);
      expect(text.value, 'DOM I OGRÓD\nZaprawa murarska 29,99');
    });

    test('bounds hostile OCR output before it reaches presentation', () {
      final oversizedLine = List<String>.filled(400, 'a').join();
      final raw = List<String>.filled(400, oversizedLine).join('\n');

      final text = RecognizedReceiptText.fromRaw(raw);

      expect(
        text.lines.length,
        lessThanOrEqualTo(RecognizedReceiptText.maximumLines),
      );
      expect(
        text.lines.every(
          (line) => line.length <= RecognizedReceiptText.maximumLineLength,
        ),
        isTrue,
      );
      expect(
        text.value.length,
        lessThanOrEqualTo(RecognizedReceiptText.maximumCharacters),
      );
    });

    test('preserves normalized line confidence from the OCR engine', () {
      final text = RecognizedReceiptText.fromLines(<RecognizedReceiptLine>[
        const RecognizedReceiptLine(
          text: '  SKLAD   BUDOWLANY ',
          confidence: 0.94,
        ),
        const RecognizedReceiptLine(text: ' RAZEM 42,50 ', confidence: 0.61),
      ]);

      expect(text.lines, <String>['SKLAD BUDOWLANY', 'RAZEM 42,50']);
      expect(text.lineDetails[0].confidence, 0.94);
      expect(text.lineDetails[1].confidence, 0.61);
    });
  });

  group('ReceiptOcrCandidateParser', () {
    const parser = ReceiptOcrCandidateParser();

    test('extracts provisional fields from a Polish fiscal receipt', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw('''
DOM I OGRÓD SP. Z O.O.
ul. Budowlana 7, 00-001 Warszawa
NIP 5250000000
PARAGON FISKALNY
Zaprawa murarska 2 x 24,99 49,98 A
Kołki montażowe 12,50 A
PTU A 23% 11,68
SUMA PTU 11,68
2026-07-25 12:41
NR 004521/2026
RAZEM PLN 62,48
KARTA 62,48
'''),
      );

      expect(result.seller?.value, 'DOM I OGRÓD SP. Z O.O.');
      expect(result.dateText?.value, '2026-07-25');
      expect(result.documentNumber?.value, '004521/2026');
      expect(result.totalText?.value, '62,48');
      expect(
        result.vatLines.map((line) => line.value),
        contains('PTU A 23% 11,68'),
      );
      expect(result.itemLines.map((line) => line.value), <String>[
        'Zaprawa murarska 2 x 24,99 49,98 A',
        'Kołki montażowe 12,50 A',
      ]);
    });

    test('prefers a final total marker over earlier amounts', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw('''
SKŁAD BUDOWLANY
Podsuma 120,00
Rabat 20,00
DO ZAPŁATY: 100,00 PLN
'''),
      );

      expect(result.totalText?.value, '100,00');
    });

    test('accepts dotted dates and common document number labels', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw('''
MARKET REMONT
PARAGON
Data: 25.07.2026
Numer dokumentu: FV/12/07/2026
TOTAL 15.99
'''),
      );

      expect(result.dateText?.value, '25.07.2026');
      expect(result.documentNumber?.value, 'FV/12/07/2026');
      expect(result.totalText?.value, '15.99');
    });

    test('returns an empty proposal when no text was recognized', () {
      final result = parser.parse(RecognizedReceiptText.fromRaw(' \n\t '));

      expect(result.isEmpty, isTrue);
      expect(result.seller, isNull);
      expect(result.vatLines, isEmpty);
      expect(result.itemLines, isEmpty);
    });

    test('carries field-level confidence and treats missing values as low', () {
      final result = parser.parse(
        RecognizedReceiptText.fromLines(<RecognizedReceiptLine>[
          const RecognizedReceiptLine(
            text: 'SKLAD BUDOWLANY',
            confidence: 0.97,
          ),
          const RecognizedReceiptLine(text: '2026-07-25', confidence: null),
          const RecognizedReceiptLine(
            text: 'Klej elastyczny 42,50 A',
            confidence: 0.72,
          ),
          const RecognizedReceiptLine(text: 'RAZEM 42,50', confidence: 0.91),
        ]),
      );

      expect(result.seller?.value, 'SKLAD BUDOWLANY');
      expect(result.seller?.confidence, 0.97);
      expect(result.seller?.requiresReview, isFalse);
      expect(result.date?.confidence, ReceiptOcrField.unknownConfidence);
      expect(result.date?.requiresReview, isTrue);
      expect(result.total?.confidence, 0.91);
      expect(result.itemLines.single.confidence, 0.72);
      expect(result.itemLines.single.requiresReview, isTrue);
    });
  });
}
