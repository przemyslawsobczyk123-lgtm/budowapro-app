import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptReviewDraft', () {
    test('requires classification and applies one component to all lines', () {
      final draft = ReceiptReviewDraft.fromCandidates(
        _candidates(),
        initialStageId: 'state_zero',
      );

      expect(draft.stageId, 'state_zero');
      expect(
        draft.validationIssues,
        contains(ReceiptReviewIssue.componentRequired),
      );

      final classified = draft.applyComponentToAll(CostComponent.mixed);

      expect(
        classified.items.every((item) => item.component == CostComponent.mixed),
        isTrue,
      );
      expect(
        classified.validationIssues,
        isNot(contains(ReceiptReviewIssue.componentRequired)),
      );
    });

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
        expect(draft.items[0].requiresConfidenceReview, isFalse);
        expect(draft.items[0].requiresVatReview, isTrue);
        expect(draft.items[0].requiresReview, isTrue);
        expect(draft.items[1].requiresReview, isTrue);
        expect(draft.canSubmit, isFalse);

        final reviewed = draft
            .confirmField(ReceiptReviewFieldKey.date)
            .applyComponentToAll(CostComponent.material)
            .confirmItem(draft.items[0].id)
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
      final unreviewed = ReceiptReviewDraft.fromCandidates(
        _candidates(
          total: '70,00',
          itemLines: const <String>['Klej 30,00', 'Grunt 20,00'],
        ),
      );
      final draft = _confirmAllItems(unreviewed);

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

    test(
      'uses the verified item sum as the document total on explicit action',
      () {
        final draft = ReceiptReviewDraft.fromCandidates(
          ReceiptOcrCandidates(
            recognizedText: RecognizedReceiptText.fromRaw('PARAGON'),
            seller: ReceiptOcrField(value: 'Market', confidence: 0.95),
            dateText: ReceiptOcrField(value: '25.07.2026', confidence: 0.95),
            itemLines: <ReceiptOcrField>[
              ReceiptOcrField(value: 'Klej 5,99', confidence: 0.95),
              ReceiptOcrField(value: 'Grunt 13,41', confidence: 0.95),
            ],
          ),
        );

        final updated = draft.useItemTotalAsDocumentTotal();

        expect(updated.total.value, '19,40');
        expect(updated.total.reviewed, isTrue);
        expect(updated.hasTotalMismatch, isFalse);
      },
    );

    test('replaces unreliable OCR rows with one reviewed document cost', () {
      final draft = ReceiptReviewDraft.fromCandidates(
        _candidates(
          total: '19,40',
          itemLines: const <String>['1 x5,99 5,99', '0,516 x25,99 13,41'],
        ),
      );

      final updated = draft.replaceItemsWithDocumentTotal(
        name: 'Zakup z dokumentu',
      );

      expect(updated.items, hasLength(1));
      expect(updated.items.single.name, 'Zakup z dokumentu');
      expect(updated.items.single.grossAmountText, '19,40');
      expect(updated.items.single.requiresConfidenceReview, isFalse);
      expect(updated.items.single.requiresVatReview, isTrue);
      expect(updated.hasTotalMismatch, isFalse);
    });

    test('requires explicit VAT review even for high-confidence OCR lines', () {
      final draft = ReceiptReviewDraft.fromCandidates(_candidates());

      expect(draft.hasUnreviewedConfidence, isFalse);
      expect(draft.hasUnreviewedVat, isTrue);
      expect(
        draft.validationIssues,
        contains(ReceiptReviewIssue.vatReviewRequired),
      );
      expect(draft.canSubmit, isFalse);

      final reviewed = _confirmAllItems(draft);

      expect(reviewed.hasUnreviewedVat, isFalse);
      expect(reviewed.canSubmit, isTrue);
    });

    test('matches financial text and item count constraints', () {
      var draft = ReceiptReviewDraft.fromCandidates(_candidates())
          .updateField(ReceiptReviewFieldKey.seller, '###')
          .updateField(ReceiptReviewFieldKey.documentNumber, 'D' * 121)
          .updateItem(
            'ocr-item-1',
            name: 'P' * 121,
            vatRate: VatRate.standard23,
          )
          .confirmItem('ocr-item-2');
      for (var index = draft.items.length; index <= 240; index += 1) {
        draft = draft.addItem(
          name: 'Pozycja $index',
          grossAmountText: '1,00',
          vatRate: VatRate.standard23,
        );
      }

      expect(
        draft.validationIssues,
        containsAll(<ReceiptReviewIssue>{
          ReceiptReviewIssue.invalidSeller,
          ReceiptReviewIssue.invalidDocumentNumber,
          ReceiptReviewIssue.invalidItemName,
          ReceiptReviewIssue.tooManyItems,
        }),
      );
    });

    test('rejects a combined item sum outside the Money range', () {
      final amount = formatReceiptMinorUnits(Money.maximumMinorUnits);
      final draft = _confirmAllItems(
        ReceiptReviewDraft.fromCandidates(
          _candidates(
            total: amount,
            itemLines: <String>['Pierwsza $amount', 'Druga 0,01'],
          ),
        ),
      );

      expect(
        draft.validationIssues,
        contains(ReceiptReviewIssue.itemTotalTooLarge),
      );
      expect(draft.canSubmit, isFalse);
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

ReceiptReviewDraft _confirmAllItems(ReceiptReviewDraft draft) {
  var reviewed = draft.applyComponentToAll(CostComponent.material);
  for (final item in draft.items) {
    reviewed = reviewed.confirmItem(item.id);
  }
  return reviewed;
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
