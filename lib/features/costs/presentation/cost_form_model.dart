import 'dart:collection';

import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';

enum CostFormField { name, grossAmount, quantity, unit, note, status }

enum CostFormError {
  requiredName,
  nameTooLong,
  requiredAmount,
  invalidAmount,
  amountTooLarge,
  quantityAndUnitRequired,
  invalidQuantity,
  noteTooLong,
  invalidStatus,
}

final class CostFormValidationException implements Exception {
  CostFormValidationException(Map<CostFormField, CostFormError> errors)
    : errors = UnmodifiableMapView<CostFormField, CostFormError>(errors);

  final UnmodifiableMapView<CostFormField, CostFormError> errors;
}

final class CostFormSubmission {
  CostFormSubmission({
    required this.name,
    required this.type,
    required this.component,
    required this.status,
    required this.grossAmount,
    required this.vatRate,
    required this.entryDate,
    required this.stageId,
    required this.categoryId,
    required this.supplierId,
    this.contactId,
    required this.quantity,
    required this.unit,
    required this.paymentMethod,
    required this.note,
    Iterable<String> attachmentIds = const <String>[],
  }) : attachmentIds = List<String>.unmodifiable(attachmentIds);

  final String name;
  final CostEntryType type;
  final CostComponent component;
  final CostStatus status;
  final String grossAmount;
  final VatRate vatRate;
  final DateTime entryDate;
  final String? stageId;
  final String? categoryId;
  final String? supplierId;
  final String? contactId;
  final String quantity;
  final String unit;
  final CostPaymentMethod? paymentMethod;
  final String note;
  final List<String> attachmentIds;
}

CostEntryInput parseCostForm(
  CostFormSubmission submission, {
  required String projectId,
  required String currencyCode,
  required bool asDraft,
}) {
  final errors = <CostFormField, CostFormError>{};
  final name = submission.name.trim();
  if (name.isEmpty) {
    errors[CostFormField.name] = CostFormError.requiredName;
  } else if (name.length > 120) {
    errors[CostFormField.name] = CostFormError.nameTooLong;
  }

  final grossMinorUnits = _parseMinorUnits(submission.grossAmount, errors);
  final quantity = _parseQuantity(submission, errors);
  if (submission.note.trim().length > 2000) {
    errors[CostFormField.note] = CostFormError.noteTooLong;
  }
  if (!validStatusesFor(submission.type).contains(submission.status)) {
    errors[CostFormField.status] = CostFormError.invalidStatus;
  }
  if (errors.isNotEmpty) {
    throw CostFormValidationException(errors);
  }

  final amount = VatBreakdown.fromGross(
    Money(minorUnits: grossMinorUnits!, currencyCode: currencyCode),
    submission.vatRate,
  );
  return CostEntryInput(
    projectId: projectId,
    name: name,
    type: submission.type,
    component: submission.component,
    status: submission.status,
    amount: amount,
    entryDate: submission.entryDate,
    stageId: submission.stageId,
    categoryId: submission.categoryId,
    supplierId: submission.supplierId,
    contactId: submission.contactId,
    quantity: quantity,
    unit: quantity == null ? null : submission.unit,
    paymentMethod: submission.paymentMethod,
    source: CostSource.manual,
    attachmentIds: submission.attachmentIds,
    note: submission.note,
  );
}

List<CostStatus> validStatusesFor(CostEntryType type) => switch (type) {
  CostEntryType.offer => const <CostStatus>[CostStatus.planned],
  CostEntryType.planned => const <CostStatus>[
    CostStatus.planned,
    CostStatus.ordered,
    CostStatus.disputed,
  ],
  CostEntryType.cost => const <CostStatus>[
    CostStatus.ordered,
    CostStatus.due,
    CostStatus.paid,
    CostStatus.returned,
    CostStatus.disputed,
  ],
};

CostStatus defaultStatusFor(CostEntryType type) => switch (type) {
  CostEntryType.offer || CostEntryType.planned => CostStatus.planned,
  CostEntryType.cost => CostStatus.paid,
};

String formatMinorUnitsForInput(int minorUnits) {
  final absolute = BigInt.from(minorUnits).abs();
  final whole = absolute ~/ BigInt.from(100);
  final fraction = (absolute % BigInt.from(100)).toString().padLeft(2, '0');
  return '${minorUnits < 0 ? '-' : ''}$whole,$fraction';
}

String formatMoneyForDisplay(Money value, String currencyCode) {
  final absolute = BigInt.from(value.minorUnits).abs();
  final whole = (absolute ~/ BigInt.from(100)).toString();
  final fraction = (absolute % BigInt.from(100)).toString().padLeft(2, '0');
  final groups = <String>[];
  for (var end = whole.length; end > 0; end -= 3) {
    groups.add(whole.substring((end - 3).clamp(0, end), end));
  }
  final groupedWhole = groups.reversed.join('\u00A0');
  return '${value.isNegative ? '-' : ''}$groupedWhole,$fraction $currencyCode';
}

String formatQuantityForInput(DecimalQuantity? quantity) {
  if (quantity == null) {
    return '';
  }
  if (quantity.scale == 0) {
    return quantity.unscaledValue.toString();
  }
  final digits = quantity.unscaledValue.toString().padLeft(
    quantity.scale + 1,
    '0',
  );
  final split = digits.length - quantity.scale;
  return '${digits.substring(0, split)},${digits.substring(split)}';
}

int? _parseMinorUnits(
  String rawValue,
  Map<CostFormField, CostFormError> errors,
) {
  final normalized = rawValue.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (normalized.isEmpty) {
    errors[CostFormField.grossAmount] = CostFormError.requiredAmount;
    return null;
  }
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) {
    errors[CostFormField.grossAmount] = CostFormError.invalidAmount;
    return null;
  }
  final parts = normalized.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final value =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  if (value > BigInt.from(Money.maximumMinorUnits)) {
    errors[CostFormField.grossAmount] = CostFormError.amountTooLarge;
    return null;
  }
  return value.toInt();
}

DecimalQuantity? _parseQuantity(
  CostFormSubmission submission,
  Map<CostFormField, CostFormError> errors,
) {
  final quantityText = submission.quantity.trim();
  final unitText = submission.unit.trim();
  if (quantityText.isEmpty && unitText.isEmpty) {
    return null;
  }
  if (quantityText.isEmpty || unitText.isEmpty) {
    errors[quantityText.isEmpty ? CostFormField.quantity : CostFormField.unit] =
        CostFormError.quantityAndUnitRequired;
    return null;
  }
  final normalized = quantityText.replaceAll(',', '.');
  if (!RegExp(r'^\d+(?:\.\d{1,6})?$').hasMatch(normalized)) {
    errors[CostFormField.quantity] = CostFormError.invalidQuantity;
    return null;
  }
  final parts = normalized.split('.');
  final scale = parts.length == 1 ? 0 : parts[1].length;
  final unscaled = BigInt.parse(parts.join());
  if (unscaled < BigInt.one ||
      unscaled > BigInt.from(Money.maximumMinorUnits)) {
    errors[CostFormField.quantity] = CostFormError.invalidQuantity;
    return null;
  }
  return DecimalQuantity(unscaledValue: unscaled.toInt(), scale: scale);
}
