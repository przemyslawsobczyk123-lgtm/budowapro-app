import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptReviewDraft', () {
    test(
      'requires explicit review for every retained low-confidence field',
      () {
        final draft = ReceiptReviewDraft.fromCandidates(
          _candidates(
            sellerConfidence: 0.96,
            dateConfidence: 0.62,
            totalConfidence: 0.93,
            itemConfidences: const <double>[0.91, 0.74],
          ),
        );

        expect(draft.seller.requiresReview, isFalse);
        expect(draft.date.requiresReview, isTrue);
        expect(draft.items[0].requiresReview, isFalse);
        expect(draft.items[1].requiresReview, isTrue);
        expect(draft.canSubmit, isFalse);

        final reviewed = draft
            .confirmField(ReceiptReviewFieldKey.date)
            .confirmItem(draft.items[1].id);

        expect(reviewed.hasUnreviewedConfidence, isFalse);
        expect(reviewed.canSubmit, isTrue);
      },
    );

    test('editing a field marks its OCR value as reviewed', () {
      final draft = ReceiptReviewDraft.fromCandidates(
        _candidates(dateConfidence: 0.4),
      );

      final corrected = draft.updateField(
        ReceiptReviewFieldKey.date,
        '26.07.2026',
      );

      expect(corrected.date.value, '26.07.2026');
      expect(corrected.date.reviewed, isTrue);
      expect(corrected.date.confidence, 1);
    });

    test('parses the last monetary value from each OCR item line', () {
      final draft = ReceiptReviewDraft.fromCandidates(
        _candidates(
          itemLines: const <String>[
            'Zaprawa murarska 2 x 24,99 49,98 A',
            'Kolki montazowe 12,50 A',
          ],
        ),
      );

      expect(draft.items[0].name, 'Zaprawa murarska 2 x 24,99');
      expect(draft.items[0].grossAmountText, '49,98');
      expect(draft.items[1].name, 'Kolki montazowe');
      expect(draft.items[1].grossAmountText, '12,50');
      expect(draft.itemTotalMinorUnits, 6248);
      expect(draft.receiptTotalMinorUnits, 6248);
    });

    test('merge, split and remove preserve an editable compact list', () {
      final draft = ReceiptReviewDraft.fromCandidates(
        _candidates(
          itemLines: const <String>['Klej 10,00', 'Grunt 20,00', 'Folia 32,48'],
        ),
      );

      final merged = draft.mergeWithNext(0);
      expect(merged.items, hasLength(2));
      expect(merged.items.first.name, 'Klej + Grunt');
      expect(merged.items.first.grossAmountText, '30,00');
      expect(merged.items.first.reviewed, isTrue);

      final split = merged.splitItem(
        0,
        firstName: 'Klej',
        firstGrossAmountText: '10,00',
        secondName: 'Grunt',
        secondGrossAmountText: '20,00',
      );
      expect(split.items, hasLength(3));
      expect(split.items[0].name, 'Klej');
      expect(split.items[1].name, 'Grunt');

      final removed = split.removeItem(split.items.last.id);
      expect(removed.items, hasLength(2));
    });

    test('total mismatch needs a separate explicit acceptance', () {
      final draft = ReceiptReviewDraft.fromCandidates(
        _candidates(
          total: '70,00',
          itemLines: const <String>['Klej 30,00', 'Grunt 20,00'],
        ),
      );

      expect(draft.hasTotalMismatch, isTrue);
      expect(draft.canSubmit, isFalse);

      final accepted = draft.acceptTotalMismatch();

      expect(accepted.canSubmit, isTrue);
      expect(
        accepted
            .updateItem(accepted.items.first.id, grossAmountText: '31,00')
            .totalMismatchAccepted,
        isFalse,
      );
    });

    test('validates required metadata and positive item amounts', () {
      final draft = ReceiptReviewDraft.fromCandidates(
        ReceiptOcrCandidates(
          recognizedText: RecognizedReceiptText.fromRaw('PARAGON'),
        ),
      );

      expect(
        draft.validationIssues,
        containsAll(<ReceiptReviewIssue>{
          ReceiptReviewIssue.sellerRequired,
          ReceiptReviewIssue.dateRequired,
          ReceiptReviewIssue.totalRequired,
          ReceiptReviewIssue.itemRequired,
        }),
      );

      final invalidItem = draft
          .updateField(ReceiptReviewFieldKey.seller, 'Market')
          .updateField(ReceiptReviewFieldKey.date, '31.02.2026')
          .updateField(ReceiptReviewFieldKey.total, 'abc')
          .addItem(
            name: 'Klej',
            grossAmountText: '0',
            vatRate: VatRate.standard23,
          );

      expect(
        invalidItem.validationIssues,
        containsAll(<ReceiptReviewIssue>{
          ReceiptReviewIssue.invalidDate,
          ReceiptReviewIssue.invalidTotal,
          ReceiptReviewIssue.invalidItemAmount,
        }),
      );
    });
  });
}

ReceiptOcrCandidates _candidates({
  String seller = 'SKLAD BUDOWLANY',
  double sellerConfidence = 0.95,
  String date = '25.07.2026',
  double dateConfidence = 0.95,
  String total = '62,48',
  double totalConfidence = 0.95,
  List<String> itemLines = const <String>[
    'Zaprawa murarska 49,98 A',
    'Kolki montazowe 12,50 A',
  ],
  List<double> itemConfidences = const <double>[0.95, 0.95],
}) {
  return ReceiptOcrCandidates(
    recognizedText: RecognizedReceiptText.fromRaw(
      <String>[seller, date, ...itemLines, 'RAZEM $total'].join('\n'),
    ),
    seller: ReceiptOcrField(value: seller, confidence: sellerConfidence),
    dateText: ReceiptOcrField(value: date, confidence: dateConfidence),
    totalText: ReceiptOcrField(value: total, confidence: totalConfidence),
    itemLines: <ReceiptOcrField>[
      for (var index = 0; index < itemLines.length; index += 1)
        ReceiptOcrField(
          value: itemLines[index],
          confidence: index < itemConfidences.length
              ? itemConfidences[index]
              : 0.95,
        ),
    ],
  );
}
