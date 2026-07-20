import 'dart:collection';

import 'money.dart';
import 'vat_breakdown.dart';

enum CostEntryType { cost, offer, planned }

enum CostStatus { planned, ordered, due, paid, returned, disputed }

enum CostLifecycle { draft, confirmed }

enum CostPaymentMethod { cash, card, bankTransfer, blik, other }

enum CostSource { manual, receiptOcr, invoiceOcr, imported, offerConversion }

enum CostCorrectionReason {
  returnedGoods,
  priceCorrection,
  vatCorrection,
  reversal,
}

enum DecisionCostImpactStatus { proposed, approved, rejected }

enum CostHistoryAction {
  created,
  draftSaved,
  draftReplaced,
  confirmed,
  detailsUpdated,
  statusChanged,
  correctionAdded,
}

final class DecimalQuantity {
  factory DecimalQuantity({required int unscaledValue, required int scale}) {
    if (unscaledValue < 1) {
      throw RangeError.value(
        unscaledValue,
        'unscaledValue',
        'must be greater than zero',
      );
    }
    if (scale < 0 || scale > 6) {
      throw RangeError.range(scale, 0, 6, 'scale');
    }
    return DecimalQuantity._(unscaledValue: unscaledValue, scale: scale);
  }

  const DecimalQuantity._({required this.unscaledValue, required this.scale});

  final int unscaledValue;
  final int scale;
}

final class CostEntryInput {
  factory CostEntryInput({
    required String projectId,
    required String name,
    required CostEntryType type,
    required CostStatus status,
    required VatBreakdown amount,
    required DateTime entryDate,
    String? stageId,
    String? categoryId,
    String? supplierId,
    DecimalQuantity? quantity,
    String? unit,
    CostPaymentMethod? paymentMethod,
    CostSource source = CostSource.manual,
    Iterable<String> attachmentIds = const <String>[],
    String? note,
  }) {
    if (amount.net.isNegative ||
        amount.vat.isNegative ||
        amount.gross.isNegative) {
      throw RangeError('Regular financial entry amounts must not be negative');
    }
    if ((quantity == null) != (unit == null || unit.trim().isEmpty)) {
      throw ArgumentError('quantity and unit must be provided together');
    }
    return CostEntryInput._(
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      name: _requiredText(name, 'name', maximumLength: 120),
      type: type,
      status: status,
      amount: amount,
      entryDate: entryDate.toUtc(),
      stageId: _optionalText(stageId, 'stageId', maximumLength: 64),
      categoryId: _optionalText(categoryId, 'categoryId', maximumLength: 64),
      supplierId: _optionalText(supplierId, 'supplierId', maximumLength: 64),
      quantity: quantity,
      unit: _optionalText(unit, 'unit', maximumLength: 24),
      paymentMethod: paymentMethod,
      source: source,
      attachmentIds: _normalizedIds(attachmentIds, 'attachmentIds'),
      note: _optionalText(note, 'note', maximumLength: 2000),
    );
  }

  const CostEntryInput._({
    required this.projectId,
    required this.name,
    required this.type,
    required this.status,
    required this.amount,
    required this.entryDate,
    required this.stageId,
    required this.categoryId,
    required this.supplierId,
    required this.quantity,
    required this.unit,
    required this.paymentMethod,
    required this.source,
    required this.attachmentIds,
    required this.note,
  });

  final String projectId;
  final String name;
  final CostEntryType type;
  final CostStatus status;
  final VatBreakdown amount;
  final DateTime entryDate;
  final String? stageId;
  final String? categoryId;
  final String? supplierId;
  final DecimalQuantity? quantity;
  final String? unit;
  final CostPaymentMethod? paymentMethod;
  final CostSource source;
  final UnmodifiableListView<String> attachmentIds;
  final String? note;
}

final class CostDraftInput {
  factory CostDraftInput(CostEntryInput input) {
    _validateEntryState(input, CostLifecycle.draft);
    return CostDraftInput._(input);
  }

  const CostDraftInput._(this.input);

  final CostEntryInput input;
}

final class ConfirmedCostEntryInput {
  factory ConfirmedCostEntryInput(CostEntryInput input) {
    if (input.source == CostSource.receiptOcr ||
        input.source == CostSource.invoiceOcr) {
      throw ArgumentError.value(
        input.source,
        'input',
        'OCR entries must be reviewed through the draft workflow',
      );
    }
    return ConfirmedCostEntryInput._(input);
  }

  const ConfirmedCostEntryInput._(this.input);

  final CostEntryInput input;
}

final class ConfirmedCostDetailsInput {
  factory ConfirmedCostDetailsInput({
    required String name,
    required DateTime entryDate,
    String? stageId,
    String? categoryId,
    String? supplierId,
    DecimalQuantity? quantity,
    String? unit,
    CostPaymentMethod? paymentMethod,
    Iterable<String> attachmentIds = const <String>[],
    String? note,
  }) {
    if ((quantity == null) != (unit == null || unit.trim().isEmpty)) {
      throw ArgumentError('quantity and unit must be provided together');
    }
    return ConfirmedCostDetailsInput._(
      name: _requiredText(name, 'name', maximumLength: 120),
      entryDate: entryDate.toUtc(),
      stageId: _optionalText(stageId, 'stageId', maximumLength: 64),
      categoryId: _optionalText(categoryId, 'categoryId', maximumLength: 64),
      supplierId: _optionalText(supplierId, 'supplierId', maximumLength: 64),
      quantity: quantity,
      unit: _optionalText(unit, 'unit', maximumLength: 24),
      paymentMethod: paymentMethod,
      attachmentIds: _normalizedIds(attachmentIds, 'attachmentIds'),
      note: _optionalText(note, 'note', maximumLength: 2000),
    );
  }

  const ConfirmedCostDetailsInput._({
    required this.name,
    required this.entryDate,
    required this.stageId,
    required this.categoryId,
    required this.supplierId,
    required this.quantity,
    required this.unit,
    required this.paymentMethod,
    required this.attachmentIds,
    required this.note,
  });

  final String name;
  final DateTime entryDate;
  final String? stageId;
  final String? categoryId;
  final String? supplierId;
  final DecimalQuantity? quantity;
  final String? unit;
  final CostPaymentMethod? paymentMethod;
  final UnmodifiableListView<String> attachmentIds;
  final String? note;
}

final class CostEntry {
  factory CostEntry({
    required String id,
    required CostEntryInput input,
    required CostLifecycle lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    int revision = 1,
  }) {
    _validateEntryState(input, lifecycle);
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(
        updatedAt,
        'updatedAt',
        'must not be before createdAt',
      );
    }
    if (revision < 1) {
      throw RangeError.value(revision, 'revision', 'must be greater than zero');
    }
    return CostEntry._(
      id: _requiredText(id, 'id', maximumLength: 64),
      input: input,
      lifecycle: lifecycle,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
      revision: revision,
    );
  }

  const CostEntry._({
    required this.id,
    required this.input,
    required this.lifecycle,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.revision,
  });

  final String id;
  final CostEntryInput input;
  final CostLifecycle lifecycle;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final int revision;

  String get projectId => input.projectId;
  String get name => input.name;
  CostEntryType get type => input.type;
  CostStatus get status => input.status;
  VatBreakdown get amount => input.amount;
  DateTime get entryDate => input.entryDate;

  bool get isIncludedInSummaries {
    return lifecycle == CostLifecycle.confirmed && type != CostEntryType.offer;
  }
}

final class CostHistoryEntry {
  factory CostHistoryEntry({
    required String id,
    required String projectId,
    required String costEntryId,
    required int revision,
    required CostHistoryAction action,
    required DateTime createdAt,
  }) {
    if (revision < 1) {
      throw RangeError.value(revision, 'revision', 'must be greater than zero');
    }
    return CostHistoryEntry._(
      id: _requiredText(id, 'id', maximumLength: 64),
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      costEntryId: _requiredText(costEntryId, 'costEntryId', maximumLength: 64),
      revision: revision,
      action: action,
      createdAtUtc: createdAt.toUtc(),
    );
  }

  const CostHistoryEntry._({
    required this.id,
    required this.projectId,
    required this.costEntryId,
    required this.revision,
    required this.action,
    required this.createdAtUtc,
  });

  final String id;
  final String projectId;
  final String costEntryId;
  final int revision;
  final CostHistoryAction action;
  final DateTime createdAtUtc;
}

final class CostCorrection {
  factory CostCorrection({
    required String id,
    required String projectId,
    required String costEntryId,
    required CostCorrectionReason reason,
    required VatBreakdown delta,
    required DateTime createdAt,
    String? note,
  }) {
    if (delta.gross.isZero) {
      throw ArgumentError.value(delta, 'delta', 'must not be zero');
    }
    if ((reason == CostCorrectionReason.returnedGoods ||
            reason == CostCorrectionReason.reversal) &&
        !delta.gross.isNegative) {
      throw ArgumentError.value(
        delta,
        'delta',
        'must be negative for returns and reversals',
      );
    }
    return CostCorrection._(
      id: _requiredText(id, 'id', maximumLength: 64),
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      costEntryId: _requiredText(costEntryId, 'costEntryId', maximumLength: 64),
      reason: reason,
      delta: delta,
      createdAtUtc: createdAt.toUtc(),
      note: _optionalText(note, 'note', maximumLength: 2000),
    );
  }

  const CostCorrection._({
    required this.id,
    required this.projectId,
    required this.costEntryId,
    required this.reason,
    required this.delta,
    required this.createdAtUtc,
    required this.note,
  });

  final String id;
  final String projectId;
  final String costEntryId;
  final CostCorrectionReason reason;
  final VatBreakdown delta;
  final DateTime createdAtUtc;
  final String? note;
}

final class CostCorrectionInput {
  factory CostCorrectionInput({
    required String projectId,
    required String costEntryId,
    required CostCorrectionReason reason,
    required VatBreakdown delta,
    String? note,
  }) {
    if (delta.gross.isZero) {
      throw ArgumentError.value(delta, 'delta', 'must not be zero');
    }
    if ((reason == CostCorrectionReason.returnedGoods ||
            reason == CostCorrectionReason.reversal) &&
        !delta.gross.isNegative) {
      throw ArgumentError.value(
        delta,
        'delta',
        'must be negative for returns and reversals',
      );
    }
    return CostCorrectionInput._(
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      costEntryId: _requiredText(costEntryId, 'costEntryId', maximumLength: 64),
      reason: reason,
      delta: delta,
      note: _optionalText(note, 'note', maximumLength: 2000),
    );
  }

  const CostCorrectionInput._({
    required this.projectId,
    required this.costEntryId,
    required this.reason,
    required this.delta,
    required this.note,
  });

  final String projectId;
  final String costEntryId;
  final CostCorrectionReason reason;
  final VatBreakdown delta;
  final String? note;
}

final class DecisionCostImpact {
  factory DecisionCostImpact({
    required String id,
    required String projectId,
    required String decisionId,
    required Money delta,
    required DecisionCostImpactStatus status,
    required DateTime createdAt,
  }) {
    if (delta.isZero) {
      throw ArgumentError.value(delta, 'delta', 'must not be zero');
    }
    return DecisionCostImpact._(
      id: _requiredText(id, 'id', maximumLength: 64),
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      decisionId: _requiredText(decisionId, 'decisionId', maximumLength: 64),
      delta: delta,
      status: status,
      createdAtUtc: createdAt.toUtc(),
    );
  }

  const DecisionCostImpact._({
    required this.id,
    required this.projectId,
    required this.decisionId,
    required this.delta,
    required this.status,
    required this.createdAtUtc,
  });

  final String id;
  final String projectId;
  final String decisionId;
  final Money delta;
  final DecisionCostImpactStatus status;
  final DateTime createdAtUtc;
}

void _validateEntryState(CostEntryInput input, CostLifecycle lifecycle) {
  if (lifecycle == CostLifecycle.draft && input.status == CostStatus.planned) {
    return;
  }

  final isValid = switch (input.type) {
    CostEntryType.offer => input.status == CostStatus.planned,
    CostEntryType.planned =>
      input.status == CostStatus.planned ||
          input.status == CostStatus.ordered ||
          input.status == CostStatus.disputed,
    CostEntryType.cost =>
      input.status == CostStatus.ordered ||
          input.status == CostStatus.due ||
          input.status == CostStatus.paid ||
          input.status == CostStatus.returned ||
          input.status == CostStatus.disputed,
  };
  if (!isValid) {
    throw ArgumentError.value(
      input.status,
      'status',
      'is not valid for ${input.type.name}',
    );
  }
}

UnmodifiableListView<String> _normalizedIds(
  Iterable<String> values,
  String argumentName,
) {
  final normalized = <String>[];
  final seen = <String>{};
  for (final value in values) {
    final id = _requiredText(value, argumentName, maximumLength: 64);
    if (!seen.add(id)) {
      throw ArgumentError.value(value, argumentName, 'contains a duplicate id');
    }
    normalized.add(id);
  }
  return UnmodifiableListView<String>(normalized);
}

String _requiredText(
  String value,
  String argumentName, {
  required int maximumLength,
}) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(
      value,
      argumentName,
      'must contain between 1 and $maximumLength characters',
    );
  }
  return normalized;
}

String? _optionalText(
  String? value,
  String argumentName, {
  required int maximumLength,
}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return _requiredText(value, argumentName, maximumLength: maximumLength);
}
