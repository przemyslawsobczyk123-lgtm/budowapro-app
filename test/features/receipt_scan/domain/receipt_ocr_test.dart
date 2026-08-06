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

    test('accepts a non-breaking space in a document total', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw('SKŁAD BUDOWLANY\nRAZEM 1\u00A0234,56'),
      );

      expect(result.totalText?.value, '1 234,56');
    });

    test('preserves a negative discount for explicit manual review', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw(
          'SKŁAD BUDOWLANY\nKlej 20,00\nRabat -5,00\nRAZEM 15,00',
        ),
      );

      expect(result.itemLines.map((line) => line.value), <String>[
        'Klej 20,00',
        'Rabat -5,00',
      ]);
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

    test(
      'parses split fiscal receipt rows and ignores a system number date',
      () {
        final result = parser.parse(
          RecognizedReceiptText.fromRaw('''
MARKET SPOŻYWCZY SP. Z O.O.
SKLEP NR 100
ul. Przykładowa 1, 00-001 Warszawa
NIP 0000000000
nr:123456
PARAGON FISKALNY
ZESTAW KISZONEK 150 G
1 x5,99 5,99C
FILET Z PIERSI LUZ
0,516 x25,99 13,41C
SPRZEDAŻ OPODATKOWANA C
19,40
PTU C 5%
0,92
SUMA PTU
0,92
SUMA PLN
19,40
KARTA PŁATNICZA
19,40 PLN
2026-07-25 21:56
Nr sys. 1420/26/07/25/1 /1014
'''),
        );

        expect(result.seller?.value, 'MARKET SPOŻYWCZY SP. Z O.O.');
        expect(result.dateText?.value, '2026-07-25');
        expect(result.documentNumber?.value, '123456');
        expect(result.totalText?.value, '19,40');
        expect(result.itemLines.map((line) => line.value), <String>[
          'ZESTAW KISZONEK 150 G 5,99',
          'FILET Z PIERSI LUZ 13,41',
        ]);
      },
    );

    test('parses a purchase invoice header and split gross total', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw('''
FAKTURA Nr 29/06/2026
Data dostawy/wykonania usługi: 24-06-2026
Data wystawienia: 25-06-2026
Sprzedawca:
USŁUGI DLA DOMU SP. Z O.O.
NIP: 0000000000
Nabywca:
KLIENT
1 OBSŁUGA TECHNICZNA 1,0 usługa 200,00 23% 200,00 46,00 246,00
2 DOKUMENTACJA 1,0 usługa 50,00 23% 50,00 11,50 61,50
Całkowita wartość brutto:
307,50 PLN
Zapłacono:
0,00 PLN
Pozostało do zapłaty:
307,50 PLN
'''),
      );

      expect(result.seller?.value, 'USŁUGI DLA DOMU SP. Z O.O.');
      expect(result.dateText?.value, '25-06-2026');
      expect(result.documentNumber?.value, '29/06/2026');
      expect(result.totalText?.value, '307,50');
      expect(result.itemLines, hasLength(2));
    });

    test('prefers invoice gross total over a zero remaining balance', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw('''
FAKTURA Nr 30/06/2026
Całkowita wartość brutto:
565,80 PLN
Zapłacono:
565,80 PLN
Pozostało do zapłaty:
0,00 PLN
'''),
      );

      expect(result.totalText?.value, '565,80');
    });

    test('keeps contractor service names as invoice items', () {
      final result = parser.parse(
        RecognizedReceiptText.fromRaw('''
FAKTURA Nr FV/10/2026
Usługi budowlane 1,00 23% 1 230,00
RAZEM 1 230,00
'''),
      );

      expect(result.itemLines.map((line) => line.value), <String>[
        'Usługi budowlane 1,00 23% 1 230,00',
      ]);
    });
  });
}
