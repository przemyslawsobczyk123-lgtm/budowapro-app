import 'dart:collection';

import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';

import 'receipt_ocr.dart';

enum ReceiptReviewFieldKey { seller, date, documentNumber, total }

enum ReceiptReviewIssue {
  sellerRequired,
  dateRequired,
  invalidDate,
  totalRequired,
  invalidTotal,
  itemRequired,
  itemNameRequired,
  invalidItemAmount,
  lowConfidenceReviewRequired,
  totalMismatchReviewRequired,
}

final class ReceiptReviewField {
  factory ReceiptReviewField.fromCandidate(ReceiptOcrField? candidate) {
    return ReceiptReviewField._(
      value: candidate?.value ?? '',
      confidence: candidate?.confidence ?? ReceiptOcrField.unknownConfidence,
      reviewed: false,
    );
  }

  const ReceiptReviewField._({
    required this.value,
    required this.confidence,
    required this.reviewed,
  });

  final String value;
  final double confidence;
  final bool reviewed;

  bool get requiresReview =>
      value.trim().isNotEmpty &&
      confidence < ReceiptOcrField.reviewThreshold &&
      !reviewed;

  ReceiptReviewField update(String nextValue) {
    return ReceiptReviewField._(
      value: nextValue,
      confidence: 1,
      reviewed: true,
    );
  }

  ReceiptReviewField confirm() {
    return ReceiptReviewField._(
      value: value,
      confidence: confidence,
      reviewed: true,
    );
  }
}

final class ReceiptReviewItem {
  const ReceiptReviewItem._({
    required this.id,
    required this.name,
    required this.grossAmountText,
    required this.vatRate,
    required this.confidence,
    required this.reviewed,
  });

  final String id;
  final String name;
  final String grossAmountText;
  final VatRate vatRate;
  final double confidence;
  final bool reviewed;

  bool get requiresReview =>
      confidence < ReceiptOcrField.reviewThreshold && !reviewed;

  ReceiptReviewItem update({
    String? name,
    String? grossAmountText,
    VatRate? vatRate,
  }) {
    return ReceiptReviewItem._(
      id: id,
      name: name ?? this.name,
      grossAmountText: grossAmountText ?? this.grossAmountText,
      vatRate: vatRate ?? this.vatRate,
      confidence: 1,
      reviewed: true,
    );
  }

  ReceiptReviewItem confirm() {
    return ReceiptReviewItem._(
      id: id,
      name: name,
      grossAmountText: grossAmountText,
      vatRate: vatRate,
      confidence: confidence,
      reviewed: true,
    );
  }
}

final class ReceiptReviewDraft {
  factory ReceiptReviewDraft.fromCandidates(ReceiptOcrCandidates candidates) {
    final items = <ReceiptReviewItem>[];
    var itemNumber = 0;
    for (final candidate in candidates.itemLines) {
      itemNumber += 1;
      final parsed = _parseItemLine(candidate.value);
      items.add(
        ReceiptReviewItem._(
          id: 'ocr-item-$itemNumber',
          name: parsed.name,
          grossAmountText: parsed.grossAmountText,
          vatRate: VatRate.standard23,
          confidence: candidate.confidence,
          reviewed: false,
        ),
      );
    }
    return ReceiptReviewDraft._(
      seller: ReceiptReviewField.fromCandidate(candidates.seller),
      date: ReceiptReviewField.fromCandidate(candidates.dateText),
      documentNumber: ReceiptReviewField.fromCandidate(
        candidates.documentNumber,
      ),
      total: ReceiptReviewField.fromCandidate(candidates.totalText),
      items: items,
      totalMismatchAccepted: false,
      nextItemNumber: itemNumber + 1,
    );
  }

  ReceiptReviewDraft._({
    required this.seller,
    required this.date,
    required this.documentNumber,
    required this.total,
    required Iterable<ReceiptReviewItem> items,
    required this.totalMismatchAccepted,
    required this._nextItemNumber,
  }) : items = UnmodifiableListView<ReceiptReviewItem>(
         List<ReceiptReviewItem>.of(items),
       );

  final ReceiptReviewField seller;
  final ReceiptReviewField date;
  final ReceiptReviewField documentNumber;
  final ReceiptReviewField total;
  final UnmodifiableListView<ReceiptReviewItem> items;
  final bool totalMismatchAccepted;
  final int _nextItemNumber;

  bool get hasUnreviewedConfidence {
    return seller.requiresReview ||
        date.requiresReview ||
        documentNumber.requiresReview ||
        total.requiresReview ||
        items.any((item) => item.requiresReview);
  }

  DateTime? get receiptDate => parseReceiptDate(date.value);

  int? get receiptTotalMinorUnits => parseReceiptMinorUnits(total.value);

  int? get itemTotalMinorUnits {
    var value = BigInt.zero;
    for (final item in items) {
      final amount = parseReceiptMinorUnits(item.grossAmountText);
      if (amount == null || amount <= 0) return null;
      value += BigInt.from(amount);
      if (value > BigInt.from(Money.maximumMinorUnits)) return null;
    }
    return value.toInt();
  }

  bool get hasTotalMismatch {
    final receiptTotal = receiptTotalMinorUnits;
    final itemTotal = itemTotalMinorUnits;
    return receiptTotal != null &&
        itemTotal != null &&
        items.isNotEmpty &&
        receiptTotal != itemTotal;
  }

  Set<ReceiptReviewIssue> get validationIssues {
    final issues = <ReceiptReviewIssue>{};
    if (seller.value.trim().isEmpty) {
      issues.add(ReceiptReviewIssue.sellerRequired);
    }
    if (date.value.trim().isEmpty) {
      issues.add(ReceiptReviewIssue.dateRequired);
    } else if (receiptDate == null) {
      issues.add(ReceiptReviewIssue.invalidDate);
    }
    if (total.value.trim().isEmpty) {
      issues.add(ReceiptReviewIssue.totalRequired);
    } else if ((receiptTotalMinorUnits ?? 0) <= 0) {
      issues.add(ReceiptReviewIssue.invalidTotal);
    }
    if (items.isEmpty) {
      issues.add(ReceiptReviewIssue.itemRequired);
    }
    for (final item in items) {
      if (item.name.trim().isEmpty) {
        issues.add(ReceiptReviewIssue.itemNameRequired);
      }
      if ((parseReceiptMinorUnits(item.grossAmountText) ?? 0) <= 0) {
        issues.add(ReceiptReviewIssue.invalidItemAmount);
      }
    }
    if (hasUnreviewedConfidence) {
      issues.add(ReceiptReviewIssue.lowConfidenceReviewRequired);
    }
    if (hasTotalMismatch && !totalMismatchAccepted) {
      issues.add(ReceiptReviewIssue.totalMismatchReviewRequired);
    }
    return Set<ReceiptReviewIssue>.unmodifiable(issues);
  }

  bool get canSubmit => validationIssues.isEmpty;

  ReceiptReviewDraft updateField(ReceiptReviewFieldKey key, String value) {
    return _copyWith(
      seller: key == ReceiptReviewFieldKey.seller ? seller.update(value) : null,
      date: key == ReceiptReviewFieldKey.date ? date.update(value) : null,
      documentNumber: key == ReceiptReviewFieldKey.documentNumber
          ? documentNumber.update(value)
          : null,
      total: key == ReceiptReviewFieldKey.total ? total.update(value) : null,
      resetTotalMismatch: key == ReceiptReviewFieldKey.total,
    );
  }

  ReceiptReviewDraft confirmField(ReceiptReviewFieldKey key) {
    return _copyWith(
      seller: key == ReceiptReviewFieldKey.seller ? seller.confirm() : null,
      date: key == ReceiptReviewFieldKey.date ? date.confirm() : null,
      documentNumber: key == ReceiptReviewFieldKey.documentNumber
          ? documentNumber.confirm()
          : null,
      total: key == ReceiptReviewFieldKey.total ? total.confirm() : null,
    );
  }

  ReceiptReviewDraft updateItem(
    String itemId, {
    String? name,
    String? grossAmountText,
    VatRate? vatRate,
  }) {
    var found = false;
    final updated = items
        .map((item) {
          if (item.id != itemId) return item;
          found = true;
          return item.update(
            name: name,
            grossAmountText: grossAmountText,
            vatRate: vatRate,
          );
        })
        .toList(growable: false);
    if (!found) throw ArgumentError.value(itemId, 'itemId');
    return _copyWith(items: updated, resetTotalMismatch: true);
  }

  ReceiptReviewDraft confirmItem(String itemId) {
    var found = false;
    final updated = items
        .map((item) {
          if (item.id != itemId) return item;
          found = true;
          return item.confirm();
        })
        .toList(growable: false);
    if (!found) throw ArgumentError.value(itemId, 'itemId');
    return _copyWith(items: updated);
  }

  ReceiptReviewDraft addItem({
    required String name,
    required String grossAmountText,
    required VatRate vatRate,
  }) {
    final item = ReceiptReviewItem._(
      id: 'review-item-$_nextItemNumber',
      name: name,
      grossAmountText: grossAmountText,
      vatRate: vatRate,
      confidence: 1,
      reviewed: true,
    );
    return _copyWith(
      items: <ReceiptReviewItem>[...items, item],
      nextItemNumber: _nextItemNumber + 1,
      resetTotalMismatch: true,
    );
  }

  ReceiptReviewDraft removeItem(String itemId) {
    final updated = items
        .where((item) => item.id != itemId)
        .toList(growable: false);
    if (updated.length == items.length) {
      throw ArgumentError.value(itemId, 'itemId');
    }
    return _copyWith(items: updated, resetTotalMismatch: true);
  }

  ReceiptReviewDraft mergeWithNext(int index) {
    if (index < 0 || index >= items.length - 1) {
      throw RangeError.index(index, items, 'index');
    }
    final first = items[index];
    final second = items[index + 1];
    final firstAmount = parseReceiptMinorUnits(first.grossAmountText);
    final secondAmount = parseReceiptMinorUnits(second.grossAmountText);
    final mergedAmount = firstAmount == null || secondAmount == null
        ? ''
        : formatReceiptMinorUnits(firstAmount + secondAmount);
    final merged = ReceiptReviewItem._(
      id: first.id,
      name: '${first.name.trim()} + ${second.name.trim()}'.trim(),
      grossAmountText: mergedAmount,
      vatRate: first.vatRate,
      confidence: 1,
      reviewed: true,
    );
    final updated = <ReceiptReviewItem>[
      ...items.take(index),
      merged,
      ...items.skip(index + 2),
    ];
    return _copyWith(items: updated, resetTotalMismatch: true);
  }

  ReceiptReviewDraft splitItem(
    int index, {
    required String firstName,
    required String firstGrossAmountText,
    required String secondName,
    required String secondGrossAmountText,
  }) {
    if (index < 0 || index >= items.length) {
      throw RangeError.index(index, items, 'index');
    }
    final source = items[index];
    final first = ReceiptReviewItem._(
      id: source.id,
      name: firstName,
      grossAmountText: firstGrossAmountText,
      vatRate: source.vatRate,
      confidence: 1,
      reviewed: true,
    );
    final second = ReceiptReviewItem._(
      id: 'review-item-$_nextItemNumber',
      name: secondName,
      grossAmountText: secondGrossAmountText,
      vatRate: source.vatRate,
      confidence: 1,
      reviewed: true,
    );
    return _copyWith(
      items: <ReceiptReviewItem>[
        ...items.take(index),
        first,
        second,
        ...items.skip(index + 1),
      ],
      nextItemNumber: _nextItemNumber + 1,
      resetTotalMismatch: true,
    );
  }

  ReceiptReviewDraft acceptTotalMismatch() {
    return _copyWith(totalMismatchAccepted: true);
  }

  ReceiptReviewDraft _copyWith({
    ReceiptReviewField? seller,
    ReceiptReviewField? date,
    ReceiptReviewField? documentNumber,
    ReceiptReviewField? total,
    Iterable<ReceiptReviewItem>? items,
    bool? totalMismatchAccepted,
    int? nextItemNumber,
    bool resetTotalMismatch = false,
  }) {
    return ReceiptReviewDraft._(
      seller: seller ?? this.seller,
      date: date ?? this.date,
      documentNumber: documentNumber ?? this.documentNumber,
      total: total ?? this.total,
      items: items ?? this.items,
      totalMismatchAccepted: resetTotalMismatch
          ? false
          : totalMismatchAccepted ?? this.totalMismatchAccepted,
      nextItemNumber: nextItemNumber ?? _nextItemNumber,
    );
  }
}

int? parseReceiptMinorUnits(String rawValue) {
  final normalized = rawValue.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) {
    return null;
  }
  final parts = normalized.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final value =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  if (value > BigInt.from(Money.maximumMinorUnits)) return null;
  return value.toInt();
}

String formatReceiptMinorUnits(int minorUnits) {
  if (minorUnits < 0) {
    throw RangeError.value(minorUnits, 'minorUnits');
  }
  final whole = minorUnits ~/ 100;
  final fraction = (minorUnits % 100).toString().padLeft(2, '0');
  return '$whole,$fraction';
}

DateTime? parseReceiptDate(String rawValue) {
  final value = rawValue.trim();
  final yearFirst = RegExp(
    r'^(\d{4})[-./](\d{2})[-./](\d{2})$',
  ).firstMatch(value);
  final dayFirst = RegExp(
    r'^(\d{2})[-./](\d{2})[-./](\d{4})$',
  ).firstMatch(value);
  final match = yearFirst ?? dayFirst;
  if (match == null) return null;
  final year = int.parse(yearFirst == null ? match.group(3)! : match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(yearFirst == null ? match.group(1)! : match.group(3)!);
  final result = DateTime.utc(year, month, day);
  if (result.year != year || result.month != month || result.day != day) {
    return null;
  }
  return result;
}

_ParsedItemLine _parseItemLine(String line) {
  final matches = _receiptMoneyPattern.allMatches(line).toList(growable: false);
  if (matches.isEmpty) {
    return _ParsedItemLine(name: line.trim(), grossAmountText: '');
  }
  final amount = matches.last;
  final name = line
      .substring(0, amount.start)
      .trim()
      .replaceFirst(RegExp(r'[-:;]+$'), '')
      .trim();
  return _ParsedItemLine(
    name: name,
    grossAmountText: amount.group(0)!.replaceAll(' ', ''),
  );
}

final RegExp _receiptMoneyPattern = RegExp(
  r'(?<!\d)(?:\d{1,3}(?:[ .]\d{3})*|\d+)[,.]\d{2}(?!\d)',
);

final class _ParsedItemLine {
  const _ParsedItemLine({required this.name, required this.grossAmountText});

  final String name;
  final String grossAmountText;
}
