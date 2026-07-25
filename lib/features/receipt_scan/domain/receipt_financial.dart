import 'dart:collection';

import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';

const int reviewedReceiptSellerMaximumLength = 160;
const int reviewedReceiptDocumentNumberMaximumLength = 120;
const int reviewedReceiptLineNameMaximumLength = 120;

final class ReviewedReceiptLine {
  factory ReviewedReceiptLine({
    required String name,
    required int grossMinorUnits,
    required VatRate vatRate,
  }) {
    if (grossMinorUnits < 1 || grossMinorUnits > Money.maximumMinorUnits) {
      throw RangeError.range(
        grossMinorUnits,
        1,
        Money.maximumMinorUnits,
        'grossMinorUnits',
      );
    }
    return ReviewedReceiptLine._(
      name: _requiredText(
        name,
        'name',
        maximumLength: reviewedReceiptLineNameMaximumLength,
      ),
      grossMinorUnits: grossMinorUnits,
      vatRate: vatRate,
    );
  }

  const ReviewedReceiptLine._({
    required this.name,
    required this.grossMinorUnits,
    required this.vatRate,
  });

  final String name;
  final int grossMinorUnits;
  final VatRate vatRate;
}

final class ReviewedReceiptBatch {
  factory ReviewedReceiptBatch({
    required String projectId,
    required String attachmentId,
    required String sellerName,
    required DateTime purchaseDate,
    required int totalGrossMinorUnits,
    required String currencyCode,
    String? documentNumber,
    Iterable<ReviewedReceiptLine> lines = const <ReviewedReceiptLine>[],
    bool totalMismatchAcknowledged = false,
  }) {
    final normalizedLines = List<ReviewedReceiptLine>.of(lines);
    if (normalizedLines.isEmpty || normalizedLines.length > maximumLines) {
      throw ArgumentError.value(
        lines,
        'lines',
        'must contain between 1 and $maximumLines positions',
      );
    }
    if (totalGrossMinorUnits < 1) {
      throw RangeError.value(
        totalGrossMinorUnits,
        'totalGrossMinorUnits',
        'must be greater than zero',
      );
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw ArgumentError.value(currencyCode, 'currencyCode');
    }
    final lineTotal = normalizedLines.fold<BigInt>(
      BigInt.zero,
      (sum, line) => sum + BigInt.from(line.grossMinorUnits),
    );
    if (lineTotal > BigInt.from(Money.maximumMinorUnits)) {
      throw ArgumentError.value(lines, 'lines', 'total is too large');
    }
    if (lineTotal.toInt() != totalGrossMinorUnits &&
        !totalMismatchAcknowledged) {
      throw ArgumentError.value(
        totalGrossMinorUnits,
        'totalGrossMinorUnits',
        'must equal the reviewed line total unless acknowledged',
      );
    }
    final normalizedSeller = _requiredText(
      sellerName,
      'sellerName',
      maximumLength: reviewedReceiptSellerMaximumLength,
    );
    return ReviewedReceiptBatch._(
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      attachmentId: _requiredText(
        attachmentId,
        'attachmentId',
        maximumLength: 64,
      ),
      sellerName: normalizedSeller,
      sellerKey: normalizeReceiptSellerKey(normalizedSeller),
      purchaseDate: DateTime.utc(
        purchaseDate.year,
        purchaseDate.month,
        purchaseDate.day,
      ),
      documentNumber: _optionalText(
        documentNumber,
        'documentNumber',
        maximumLength: reviewedReceiptDocumentNumberMaximumLength,
      ),
      totalGrossMinorUnits: totalGrossMinorUnits,
      currencyCode: currencyCode,
      lines: normalizedLines,
      totalMismatchAcknowledged: totalMismatchAcknowledged,
    );
  }

  ReviewedReceiptBatch._({
    required this.projectId,
    required this.attachmentId,
    required this.sellerName,
    required this.sellerKey,
    required this.purchaseDate,
    required this.documentNumber,
    required this.totalGrossMinorUnits,
    required this.currencyCode,
    required Iterable<ReviewedReceiptLine> lines,
    required this.totalMismatchAcknowledged,
  }) : lines = UnmodifiableListView<ReviewedReceiptLine>(
         List<ReviewedReceiptLine>.of(lines),
       );

  static const int maximumLines = 240;

  final String projectId;
  final String attachmentId;
  final String sellerName;
  final String sellerKey;
  final DateTime purchaseDate;
  final String? documentNumber;
  final int totalGrossMinorUnits;
  final String currencyCode;
  final UnmodifiableListView<ReviewedReceiptLine> lines;
  final bool totalMismatchAcknowledged;
}

enum ReceiptDuplicateReason { sameAttachment, fileHash, receiptSignature }

final class ReceiptDuplicateCheck {
  ReceiptDuplicateCheck(Iterable<ReceiptDuplicateReason> reasons)
    : reasons = UnmodifiableSetView<ReceiptDuplicateReason>(
        Set<ReceiptDuplicateReason>.of(reasons),
      );

  final UnmodifiableSetView<ReceiptDuplicateReason> reasons;

  bool get isDuplicate => reasons.isNotEmpty;
}

final class ReceiptDuplicateException implements Exception {
  const ReceiptDuplicateException(this.check);

  final ReceiptDuplicateCheck check;

  @override
  String toString() => 'Receipt duplicate requires explicit acknowledgement';
}

final class ReceiptDraftBatchResult {
  ReceiptDraftBatchResult({
    required Iterable<CostEntry> drafts,
    required this.duplicateAcknowledged,
  }) : drafts = UnmodifiableListView<CostEntry>(List<CostEntry>.of(drafts));

  final UnmodifiableListView<CostEntry> drafts;
  final bool duplicateAcknowledged;
}

abstract interface class ReceiptFinancialRepository {
  Future<ReceiptDuplicateCheck> checkDuplicates(ReviewedReceiptBatch batch);

  Future<ReceiptDraftBatchResult> saveReviewedDrafts(
    ReviewedReceiptBatch batch, {
    bool duplicateAcknowledged = false,
  });
}

String normalizeReceiptSellerKey(String sellerName) {
  final lower = sellerName.trim().toLowerCase();
  final buffer = StringBuffer();
  var previousWasSpace = false;
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    final mapped = _polishAscii[character] ?? character;
    if (RegExp(r'[a-z0-9]').hasMatch(mapped)) {
      buffer.write(mapped);
      previousWasSpace = false;
    } else if (!previousWasSpace && buffer.isNotEmpty) {
      buffer.write(' ');
      previousWasSpace = true;
    }
  }
  final result = buffer.toString().trim();
  if (result.isEmpty) {
    throw ArgumentError.value(sellerName, 'sellerName');
  }
  return result;
}

bool isValidReviewedReceiptSellerName(String value) {
  try {
    final normalized = _requiredText(
      value,
      'sellerName',
      maximumLength: reviewedReceiptSellerMaximumLength,
    );
    normalizeReceiptSellerKey(normalized);
    return true;
  } on ArgumentError {
    return false;
  }
}

bool isValidReviewedReceiptDocumentNumber(String value) {
  try {
    _optionalText(
      value,
      'documentNumber',
      maximumLength: reviewedReceiptDocumentNumberMaximumLength,
    );
    return true;
  } on ArgumentError {
    return false;
  }
}

bool isValidReviewedReceiptLineName(String value) {
  try {
    _requiredText(
      value,
      'name',
      maximumLength: reviewedReceiptLineNameMaximumLength,
    );
    return true;
  } on ArgumentError {
    return false;
  }
}

const Map<String, String> _polishAscii = <String, String>{
  'ą': 'a',
  'ć': 'c',
  'ę': 'e',
  'ł': 'l',
  'ń': 'n',
  'ó': 'o',
  'ś': 's',
  'ź': 'z',
  'ż': 'z',
};

String _requiredText(
  String value,
  String argumentName, {
  required int maximumLength,
}) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, argumentName);
  }
  return normalized;
}

String? _optionalText(
  String? value,
  String argumentName, {
  required int maximumLength,
}) {
  if (value == null || value.trim().isEmpty) return null;
  return _requiredText(value, argumentName, maximumLength: maximumLength);
}
