import 'dart:collection';

import 'package:budowapro/features/costs/domain/money.dart';

enum MaterialStatus {
  planned,
  ordered,
  partiallyDelivered,
  delivered,
  delayed,
  returned,
}

abstract final class MaterialFieldLimits {
  static const int id = 64;
  static const int name = 160;
  static const int unit = 24;
  static const int location = 160;
  static const int note = 2000;
}

final class MaterialQuantity implements Comparable<MaterialQuantity> {
  factory MaterialQuantity({required int unscaledValue, required int scale}) {
    if (unscaledValue < 1) {
      throw RangeError.value(unscaledValue, 'unscaledValue');
    }
    if (scale < 0 || scale > 6) {
      throw RangeError.range(scale, 0, 6, 'scale');
    }
    return MaterialQuantity._(unscaledValue, scale);
  }

  const MaterialQuantity._(this.unscaledValue, this.scale);

  final int unscaledValue;
  final int scale;

  MaterialQuantity operator +(MaterialQuantity other) {
    final resultScale = scale > other.scale ? scale : other.scale;
    final left = BigInt.from(unscaledValue) * _pow10(resultScale - scale);
    final right =
        BigInt.from(other.unscaledValue) * _pow10(resultScale - other.scale);
    final sum = left + right;
    if (sum > BigInt.from(9223372036854775807)) {
      throw RangeError('Quantity must fit SQLite int64');
    }
    return MaterialQuantity(
      unscaledValue: sum.toInt(),
      scale: resultScale,
    ).normalized();
  }

  @override
  int compareTo(MaterialQuantity other) {
    final comparisonScale = scale > other.scale ? scale : other.scale;
    final left = BigInt.from(unscaledValue) * _pow10(comparisonScale - scale);
    final right =
        BigInt.from(other.unscaledValue) *
        _pow10(comparisonScale - other.scale);
    return left.compareTo(right);
  }

  MaterialQuantity normalized() {
    var value = unscaledValue;
    var currentScale = scale;
    while (currentScale > 0 && value % 10 == 0) {
      value ~/= 10;
      currentScale--;
    }
    return value == unscaledValue && currentScale == scale
        ? this
        : MaterialQuantity(unscaledValue: value, scale: currentScale);
  }

  @override
  bool operator ==(Object other) {
    return other is MaterialQuantity && compareTo(other) == 0;
  }

  @override
  int get hashCode {
    final value = normalized();
    return Object.hash(value.unscaledValue, value.scale);
  }
}

final class MaterialInput {
  factory MaterialInput({
    required String projectId,
    required String name,
    required MaterialQuantity orderedQuantity,
    required String unit,
    String? stageId,
    String? roomId,
    String? supplierContactId,
    String? costEntryId,
    String? receiptDocumentId,
    Money? orderedGross,
    String? storageLocation,
    DateTime? orderedAt,
    DateTime? expectedDeliveryAt,
    bool deliveryReminderEnabled = false,
    String? note,
  }) {
    if (orderedGross?.isNegative ?? false) {
      throw RangeError.value(orderedGross!.minorUnits, 'orderedGross');
    }
    return MaterialInput._(
      projectId: _requiredText(projectId, 'projectId', MaterialFieldLimits.id),
      name: _requiredText(name, 'name', MaterialFieldLimits.name),
      orderedQuantity: orderedQuantity.normalized(),
      unit: _requiredText(unit, 'unit', MaterialFieldLimits.unit),
      stageId: _optionalText(stageId, 'stageId', MaterialFieldLimits.id),
      roomId: _optionalText(roomId, 'roomId', MaterialFieldLimits.id),
      supplierContactId: _optionalText(
        supplierContactId,
        'supplierContactId',
        MaterialFieldLimits.id,
      ),
      costEntryId: _optionalText(
        costEntryId,
        'costEntryId',
        MaterialFieldLimits.id,
      ),
      receiptDocumentId: _optionalText(
        receiptDocumentId,
        'receiptDocumentId',
        MaterialFieldLimits.id,
      ),
      orderedGross: orderedGross,
      storageLocation: _optionalText(
        storageLocation,
        'storageLocation',
        MaterialFieldLimits.location,
      ),
      orderedAtUtc: orderedAt?.toUtc(),
      expectedDeliveryAtUtc: expectedDeliveryAt?.toUtc(),
      deliveryReminderEnabled: deliveryReminderEnabled,
      note: _optionalText(note, 'note', MaterialFieldLimits.note),
    );
  }

  const MaterialInput._({
    required this.projectId,
    required this.name,
    required this.orderedQuantity,
    required this.unit,
    required this.stageId,
    required this.roomId,
    required this.supplierContactId,
    required this.costEntryId,
    required this.receiptDocumentId,
    required this.orderedGross,
    required this.storageLocation,
    required this.orderedAtUtc,
    required this.expectedDeliveryAtUtc,
    required this.deliveryReminderEnabled,
    required this.note,
  });

  final String projectId;
  final String name;
  final MaterialQuantity orderedQuantity;
  final String unit;
  final String? stageId;
  final String? roomId;
  final String? supplierContactId;
  final String? costEntryId;
  final String? receiptDocumentId;
  final Money? orderedGross;
  final String? storageLocation;
  final DateTime? orderedAtUtc;
  final DateTime? expectedDeliveryAtUtc;
  final bool deliveryReminderEnabled;
  final String? note;
}

final class MaterialDeliveryInput {
  factory MaterialDeliveryInput({
    required String projectId,
    required String materialId,
    required MaterialQuantity expectedQuantity,
    required DateTime dueAt,
    MaterialQuantity? deliveredQuantity,
    DateTime? receivedAt,
    String? documentId,
    String? contactId,
    String? shortageNote,
    String? damageNote,
    bool overDeliveryConfirmed = false,
    bool reminderEnabled = false,
  }) {
    if ((deliveredQuantity == null) != (receivedAt == null)) {
      throw ArgumentError(
        'deliveredQuantity and receivedAt must be provided together',
      );
    }
    return MaterialDeliveryInput._(
      projectId: _requiredText(projectId, 'projectId', MaterialFieldLimits.id),
      materialId: _requiredText(
        materialId,
        'materialId',
        MaterialFieldLimits.id,
      ),
      expectedQuantity: expectedQuantity.normalized(),
      dueAtUtc: dueAt.toUtc(),
      deliveredQuantity: deliveredQuantity?.normalized(),
      receivedAtUtc: receivedAt?.toUtc(),
      documentId: _optionalText(
        documentId,
        'documentId',
        MaterialFieldLimits.id,
      ),
      contactId: _optionalText(contactId, 'contactId', MaterialFieldLimits.id),
      shortageNote: _optionalText(
        shortageNote,
        'shortageNote',
        MaterialFieldLimits.note,
      ),
      damageNote: _optionalText(
        damageNote,
        'damageNote',
        MaterialFieldLimits.note,
      ),
      overDeliveryConfirmed: overDeliveryConfirmed,
      reminderEnabled: reminderEnabled,
    );
  }

  const MaterialDeliveryInput._({
    required this.projectId,
    required this.materialId,
    required this.expectedQuantity,
    required this.dueAtUtc,
    required this.deliveredQuantity,
    required this.receivedAtUtc,
    required this.documentId,
    required this.contactId,
    required this.shortageNote,
    required this.damageNote,
    required this.overDeliveryConfirmed,
    required this.reminderEnabled,
  });

  final String projectId;
  final String materialId;
  final MaterialQuantity expectedQuantity;
  final DateTime dueAtUtc;
  final MaterialQuantity? deliveredQuantity;
  final DateTime? receivedAtUtc;
  final String? documentId;
  final String? contactId;
  final String? shortageNote;
  final String? damageNote;
  final bool overDeliveryConfirmed;
  final bool reminderEnabled;
}

final class MaterialDelivery {
  MaterialDelivery({
    required String id,
    required this.input,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = _requiredText(id, 'id', MaterialFieldLimits.id),
       createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
  }

  final String id;
  final MaterialDeliveryInput input;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  bool get isReceived => input.receivedAtUtc != null;

  bool isDelayedAt(DateTime now) {
    return !isReceived && input.dueAtUtc.isBefore(now.toUtc());
  }
}

final class MaterialReturnInput {
  factory MaterialReturnInput({
    required String projectId,
    required String materialId,
    required MaterialQuantity quantity,
    required DateTime deadline,
    required bool receiptRequired,
    Money? expectedRefund,
    String? receiptDocumentId,
    DateTime? completedAt,
    Money? actualRefund,
    bool reminderEnabled = false,
    String? note,
  }) {
    if (expectedRefund?.isNegative ?? false) {
      throw RangeError.value(expectedRefund!.minorUnits, 'expectedRefund');
    }
    if (actualRefund?.isNegative ?? false) {
      throw RangeError.value(actualRefund!.minorUnits, 'actualRefund');
    }
    if (actualRefund != null && completedAt == null) {
      throw ArgumentError('actualRefund requires completedAt');
    }
    final effectiveExpectedRefund = expectedRefund ?? actualRefund;
    if (effectiveExpectedRefund != null &&
        actualRefund != null &&
        effectiveExpectedRefund.currencyCode != actualRefund.currencyCode) {
      throw ArgumentError.value(actualRefund.currencyCode, 'actualRefund');
    }
    return MaterialReturnInput._(
      projectId: _requiredText(projectId, 'projectId', MaterialFieldLimits.id),
      materialId: _requiredText(
        materialId,
        'materialId',
        MaterialFieldLimits.id,
      ),
      quantity: quantity.normalized(),
      deadlineUtc: deadline.toUtc(),
      expectedRefund: effectiveExpectedRefund,
      receiptRequired: receiptRequired,
      receiptDocumentId: _optionalText(
        receiptDocumentId,
        'receiptDocumentId',
        MaterialFieldLimits.id,
      ),
      completedAtUtc: completedAt?.toUtc(),
      actualRefund: actualRefund,
      reminderEnabled: reminderEnabled,
      note: _optionalText(note, 'note', MaterialFieldLimits.note),
    );
  }

  const MaterialReturnInput._({
    required this.projectId,
    required this.materialId,
    required this.quantity,
    required this.deadlineUtc,
    required this.expectedRefund,
    required this.receiptRequired,
    required this.receiptDocumentId,
    required this.completedAtUtc,
    required this.actualRefund,
    required this.reminderEnabled,
    required this.note,
  });

  final String projectId;
  final String materialId;
  final MaterialQuantity quantity;
  final DateTime deadlineUtc;
  final Money? expectedRefund;
  final bool receiptRequired;
  final String? receiptDocumentId;
  final DateTime? completedAtUtc;
  final Money? actualRefund;
  final bool reminderEnabled;
  final String? note;
}

final class MaterialReturn {
  MaterialReturn({
    required String id,
    required this.input,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = _requiredText(id, 'id', MaterialFieldLimits.id),
       createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
  }

  final String id;
  final MaterialReturnInput input;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  bool get isCompleted => input.completedAtUtc != null;

  bool isOverdueAt(DateTime now) {
    return !isCompleted && input.deadlineUtc.isBefore(now.toUtc());
  }
}

final class MaterialItem {
  MaterialItem({
    required String id,
    required this.input,
    required Iterable<MaterialDelivery> deliveries,
    required Iterable<MaterialReturn> returns,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = _requiredText(id, 'id', MaterialFieldLimits.id),
       deliveries = UnmodifiableListView<MaterialDelivery>(deliveries),
       returns = UnmodifiableListView<MaterialReturn>(returns),
       createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    if (this.deliveries.any(
          (value) =>
              value.input.materialId != this.id ||
              value.input.projectId != input.projectId,
        ) ||
        this.returns.any(
          (value) =>
              value.input.materialId != this.id ||
              value.input.projectId != input.projectId,
        )) {
      throw ArgumentError('Child record belongs to another material');
    }
  }

  final String id;
  final MaterialInput input;
  final UnmodifiableListView<MaterialDelivery> deliveries;
  final UnmodifiableListView<MaterialReturn> returns;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  MaterialQuantity? get deliveredQuantity => _sumQuantities(
    deliveries.map((value) => value.input.deliveredQuantity).whereType(),
  );

  MaterialQuantity? get returnedQuantity => _sumQuantities(
    returns
        .where((value) => value.isCompleted)
        .map((value) => value.input.quantity),
  );

  MaterialStatus statusAt(DateTime now) {
    final delivered = deliveredQuantity;
    final returned = returnedQuantity;
    if (delivered != null &&
        returned != null &&
        returned.compareTo(delivered) >= 0) {
      return MaterialStatus.returned;
    }
    if (delivered != null && delivered.compareTo(input.orderedQuantity) >= 0) {
      return MaterialStatus.delivered;
    }
    if (delivered != null) return MaterialStatus.partiallyDelivered;
    if (deliveries.any((delivery) => delivery.isDelayedAt(now)) ||
        (input.orderedAtUtc != null &&
            input.expectedDeliveryAtUtc?.isBefore(now.toUtc()) == true)) {
      return MaterialStatus.delayed;
    }
    return input.orderedAtUtc == null
        ? MaterialStatus.planned
        : MaterialStatus.ordered;
  }

  DateTime? get nextReturnDeadlineUtc {
    DateTime? earliest;
    for (final value in returns.where((value) => !value.isCompleted)) {
      final deadline = value.input.deadlineUtc;
      if (earliest == null || deadline.isBefore(earliest)) earliest = deadline;
    }
    return earliest;
  }
}

final class MaterialDashboardSummary {
  MaterialDashboardSummary({
    required String projectId,
    required this.orderedValue,
    required this.expectedReturnValue,
    required this.delayedCount,
    required this.overdueReturnCount,
    required this.openDeliveryCount,
  }) : projectId = _requiredText(
         projectId,
         'projectId',
         MaterialFieldLimits.id,
       ) {
    if (orderedValue.currencyCode != expectedReturnValue.currencyCode) {
      throw ArgumentError.value(expectedReturnValue.currencyCode);
    }
    if (delayedCount < 0 || overdueReturnCount < 0 || openDeliveryCount < 0) {
      throw RangeError('Dashboard counters must not be negative');
    }
  }

  final String projectId;
  final Money orderedValue;
  final Money expectedReturnValue;
  final int delayedCount;
  final int overdueReturnCount;
  final int openDeliveryCount;
}

MaterialQuantity? _sumQuantities(Iterable<MaterialQuantity> values) {
  MaterialQuantity? total;
  for (final value in values) {
    total = total == null ? value : total + value;
  }
  return total;
}

BigInt _pow10(int exponent) {
  var value = BigInt.one;
  for (var index = 0; index < exponent; index++) {
    value *= BigInt.from(10);
  }
  return value;
}

String _requiredText(String value, String name, int maximumLength) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}

String? _optionalText(String? value, String name, int maximumLength) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return _requiredText(normalized, name, maximumLength);
}
