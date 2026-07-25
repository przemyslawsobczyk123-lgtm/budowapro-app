import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewedReceiptBatch', () {
    test('normalizes metadata and keeps reviewed financial lines', () {
      final batch = _batch();

      expect(batch.sellerName, 'Skład Budowlany');
      expect(batch.sellerKey, 'sklad budowlany');
      expect(batch.purchaseDate, DateTime.utc(2026, 7, 25));
      expect(batch.lines, hasLength(3));
      expect(
        batch.lines.fold(0, (sum, line) => sum + line.grossMinorUnits),
        6248,
      );
    });

    test('rejects an empty batch and a silent total mismatch', () {
      expect(
        () => ReviewedReceiptBatch(
          projectId: 'project-1',
          attachmentId: 'attachment-1',
          sellerName: 'Market',
          purchaseDate: DateTime.utc(2026, 7, 25),
          totalGrossMinorUnits: 1000,
          currencyCode: 'PLN',
        ),
        throwsArgumentError,
      );

      expect(
        () => _batch(totalGrossMinorUnits: 7000),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        _batch(
          totalGrossMinorUnits: 7000,
          totalMismatchAcknowledged: true,
        ).totalMismatchAcknowledged,
        isTrue,
      );
    });

    test('rejects non-positive lines and invalid project currency', () {
      expect(
        () => ReviewedReceiptLine(
          name: 'Klej',
          grossMinorUnits: 0,
          vatRate: VatRate.standard23,
        ),
        throwsRangeError,
      );
      expect(() => _batch(currencyCode: 'pln'), throwsArgumentError);
    });
  });
}

ReviewedReceiptBatch _batch({
  int totalGrossMinorUnits = 6248,
  String currencyCode = 'PLN',
  bool totalMismatchAcknowledged = false,
}) {
  return ReviewedReceiptBatch(
    projectId: 'project-1',
    attachmentId: 'attachment-1',
    sellerName: '  Skład   Budowlany ',
    purchaseDate: DateTime(2026, 7, 25, 18, 30),
    documentNumber: '004521/2026',
    totalGrossMinorUnits: totalGrossMinorUnits,
    currencyCode: currencyCode,
    totalMismatchAcknowledged: totalMismatchAcknowledged,
    lines: <ReviewedReceiptLine>[
      ReviewedReceiptLine(
        name: 'Zaprawa murarska',
        grossMinorUnits: 2499,
        vatRate: VatRate.standard23,
      ),
      ReviewedReceiptLine(
        name: 'Klej elastyczny',
        grossMinorUnits: 2499,
        vatRate: VatRate.standard23,
      ),
      ReviewedReceiptLine(
        name: 'Kołki montażowe',
        grossMinorUnits: 1250,
        vatRate: VatRate.standard23,
      ),
    ],
  );
}
