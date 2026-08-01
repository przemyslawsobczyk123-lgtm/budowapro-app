import 'dart:collection';

import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';

enum RoomStandard { basic, standard, elevated, custom }

enum RoomChoiceStatus { open, selected, cancelled }

enum RoomRecordType { cost, journal, technicalPhoto }

enum RoomRelationKind { cost, decision, technicalPhoto, defect, contact }

enum RoomChoiceOutputType { plannedCost, decision, material }

abstract final class RoomFieldLimits {
  static const int id = 64;
  static const int name = 120;
  static const int floor = 80;
  static const int note = 2000;
  static const int choiceTitle = 160;
  static const int variantLabel = 160;
  static const int supplier = 160;
  static const int productCode = 80;
  static const int maximumVariants = 20;
}

final class RoomDimensions {
  factory RoomDimensions({
    int? lengthMillimeters,
    int? widthMillimeters,
    int? heightMillimeters,
  }) {
    if (lengthMillimeters == null &&
        widthMillimeters == null &&
        heightMillimeters == null) {
      throw ArgumentError('At least one dimension is required');
    }
    return RoomDimensions._(
      lengthMillimeters: _dimension(lengthMillimeters, 'lengthMillimeters'),
      widthMillimeters: _dimension(widthMillimeters, 'widthMillimeters'),
      heightMillimeters: _dimension(heightMillimeters, 'heightMillimeters'),
    );
  }

  const RoomDimensions._({
    required this.lengthMillimeters,
    required this.widthMillimeters,
    required this.heightMillimeters,
  });

  final int? lengthMillimeters;
  final int? widthMillimeters;
  final int? heightMillimeters;

  int? get areaSquareMillimeters {
    final length = lengthMillimeters;
    final width = widthMillimeters;
    if (length == null || width == null) return null;
    return length * width;
  }
}

final class RoomInput {
  factory RoomInput({
    required String projectId,
    required String name,
    required RoomStandard standard,
    String? floorLabel,
    RoomDimensions? dimensions,
    Money? plannedBudget,
    String? note,
  }) {
    if (plannedBudget?.isNegative ?? false) {
      throw RangeError.value(plannedBudget!.minorUnits, 'plannedBudget');
    }
    return RoomInput._(
      projectId: _requiredText(projectId, 'projectId', RoomFieldLimits.id),
      name: _requiredText(name, 'name', RoomFieldLimits.name),
      floorLabel: _optionalText(
        floorLabel,
        'floorLabel',
        RoomFieldLimits.floor,
      ),
      standard: standard,
      dimensions: dimensions,
      plannedBudget: plannedBudget,
      note: _optionalText(note, 'note', RoomFieldLimits.note),
    );
  }

  const RoomInput._({
    required this.projectId,
    required this.name,
    required this.floorLabel,
    required this.standard,
    required this.dimensions,
    required this.plannedBudget,
    required this.note,
  });

  final String projectId;
  final String name;
  final String? floorLabel;
  final RoomStandard standard;
  final RoomDimensions? dimensions;
  final Money? plannedBudget;
  final String? note;
}

final class Room {
  Room({
    required String id,
    required this.input,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = _requiredText(id, 'id', RoomFieldLimits.id),
       createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
  }

  final String id;
  final RoomInput input;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get projectId => input.projectId;
  String get name => input.name;
  String? get floorLabel => input.floorLabel;
  RoomStandard get standard => input.standard;
  RoomDimensions? get dimensions => input.dimensions;
  Money? get plannedBudget => input.plannedBudget;
  String? get note => input.note;
}

final class RoomChoiceInput {
  factory RoomChoiceInput({
    required String projectId,
    required String roomId,
    required String title,
    DecimalQuantity? quantity,
    String? unit,
    int wasteBasisPoints = 0,
    DateTime? orderDue,
    String? note,
  }) {
    if ((quantity == null) != (unit == null || unit.trim().isEmpty)) {
      throw ArgumentError('quantity and unit must be provided together');
    }
    if (wasteBasisPoints < 0 || wasteBasisPoints > 10000) {
      throw RangeError.range(wasteBasisPoints, 0, 10000, 'wasteBasisPoints');
    }
    return RoomChoiceInput._(
      projectId: _requiredText(projectId, 'projectId', RoomFieldLimits.id),
      roomId: _requiredText(roomId, 'roomId', RoomFieldLimits.id),
      title: _requiredText(title, 'title', RoomFieldLimits.choiceTitle),
      quantity: quantity,
      unit: _optionalText(unit, 'unit', 24),
      wasteBasisPoints: wasteBasisPoints,
      orderDueUtc: orderDue?.toUtc(),
      note: _optionalText(note, 'note', RoomFieldLimits.note),
    );
  }

  const RoomChoiceInput._({
    required this.projectId,
    required this.roomId,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.wasteBasisPoints,
    required this.orderDueUtc,
    required this.note,
  });

  final String projectId;
  final String roomId;
  final String title;
  final DecimalQuantity? quantity;
  final String? unit;
  final int wasteBasisPoints;
  final DateTime? orderDueUtc;
  final String? note;
}

final class RoomChoiceVariantInput {
  factory RoomChoiceVariantInput({
    required String projectId,
    required String label,
    required Money unitGrossPrice,
    String? supplier,
    String? productCode,
    String? note,
  }) {
    if (unitGrossPrice.isNegative) {
      throw RangeError.value(unitGrossPrice.minorUnits, 'unitGrossPrice');
    }
    return RoomChoiceVariantInput._(
      projectId: _requiredText(projectId, 'projectId', RoomFieldLimits.id),
      label: _requiredText(label, 'label', RoomFieldLimits.variantLabel),
      unitGrossPrice: unitGrossPrice,
      supplier: _optionalText(supplier, 'supplier', RoomFieldLimits.supplier),
      productCode: _optionalText(
        productCode,
        'productCode',
        RoomFieldLimits.productCode,
      ),
      note: _optionalText(note, 'note', RoomFieldLimits.note),
    );
  }

  const RoomChoiceVariantInput._({
    required this.projectId,
    required this.label,
    required this.unitGrossPrice,
    required this.supplier,
    required this.productCode,
    required this.note,
  });

  final String projectId;
  final String label;
  final Money unitGrossPrice;
  final String? supplier;
  final String? productCode;
  final String? note;
}

final class RoomChoiceVariant {
  RoomChoiceVariant({
    required String id,
    required String choiceId,
    required this.input,
    this.isSelected = false,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = _requiredText(id, 'id', RoomFieldLimits.id),
       choiceId = _requiredText(choiceId, 'choiceId', RoomFieldLimits.id),
       createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
  }

  final String id;
  final String choiceId;
  final RoomChoiceVariantInput input;
  final bool isSelected;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get projectId => input.projectId;
  String get label => input.label;
  Money get unitGrossPrice => input.unitGrossPrice;
  String? get supplier => input.supplier;
  String? get productCode => input.productCode;
  String? get note => input.note;
}

final class RoomChoice {
  RoomChoice({
    required String id,
    required this.input,
    required Iterable<RoomChoiceVariant> variants,
    required this.status,
    required String? selectedVariantId,
    Map<RoomChoiceOutputType, String> outputRecordIds = const {},
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = _requiredText(id, 'id', RoomFieldLimits.id),
       variants = UnmodifiableListView<RoomChoiceVariant>(variants),
       selectedVariantId = _optionalText(
         selectedVariantId,
         'selectedVariantId',
         RoomFieldLimits.id,
       ),
       outputRecordIds = UnmodifiableMapView<RoomChoiceOutputType, String>(
         outputRecordIds.map(
           (key, value) => MapEntry(
             key,
             _requiredText(value, 'outputRecordId', RoomFieldLimits.id),
           ),
         ),
       ),
       createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    if (this.variants.length > RoomFieldLimits.maximumVariants) {
      throw ArgumentError.value(variants, 'variants');
    }
    if (this.variants.any(
      (variant) =>
          variant.choiceId != this.id || variant.projectId != input.projectId,
    )) {
      throw ArgumentError.value(variants, 'variants');
    }
    if (status == RoomChoiceStatus.selected) {
      if (this.selectedVariantId == null ||
          this.variants.every(
            (variant) => variant.id != this.selectedVariantId,
          )) {
        throw ArgumentError.value(selectedVariantId, 'selectedVariantId');
      }
    } else if (this.selectedVariantId != null) {
      throw ArgumentError.value(selectedVariantId, 'selectedVariantId');
    }
  }

  final String id;
  final RoomChoiceInput input;
  final UnmodifiableListView<RoomChoiceVariant> variants;
  final RoomChoiceStatus status;
  final String? selectedVariantId;
  final UnmodifiableMapView<RoomChoiceOutputType, String> outputRecordIds;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  RoomChoiceVariant? get selectedVariant {
    final selectedId = selectedVariantId;
    if (selectedId == null) return null;
    for (final variant in variants) {
      if (variant.id == selectedId) return variant;
    }
    return null;
  }

  String? outputRecordId(RoomChoiceOutputType type) => outputRecordIds[type];

  Money? get estimatedGross {
    final variant = selectedVariant;
    if (variant == null) return null;
    final quantity = input.quantity;
    if (quantity == null) return variant.unitGrossPrice;
    final numerator =
        BigInt.from(variant.unitGrossPrice.minorUnits) *
        BigInt.from(quantity.unscaledValue) *
        BigInt.from(10000 + input.wasteBasisPoints);
    final denominator = _pow10(quantity.scale) * BigInt.from(10000);
    final rounded = _roundHalfUp(numerator, denominator);
    return Money.fromBigInt(
      minorUnits: rounded,
      currencyCode: variant.unitGrossPrice.currencyCode,
    );
  }

  BigInt? get estimatedQuantityUnscaled {
    final quantity = input.quantity;
    if (quantity == null) return null;
    var value =
        BigInt.from(quantity.unscaledValue) *
        BigInt.from(10000 + input.wasteBasisPoints);
    var scale = quantity.scale + 4;
    while (scale > 0 && value.remainder(BigInt.from(10)) == BigInt.zero) {
      value ~/= BigInt.from(10);
      scale--;
    }
    return value;
  }

  int? get estimatedQuantityScale {
    final quantity = input.quantity;
    if (quantity == null) return null;
    var value =
        BigInt.from(quantity.unscaledValue) *
        BigInt.from(10000 + input.wasteBasisPoints);
    var scale = quantity.scale + 4;
    while (scale > 0 && value.remainder(BigInt.from(10)) == BigInt.zero) {
      value ~/= BigInt.from(10);
      scale--;
    }
    return scale;
  }
}

final class RoomOverview {
  RoomOverview({
    required this.room,
    required this.actualCost,
    required this.openChoiceCount,
    required this.openDecisionCount,
    required this.materialCount,
    required this.contactCount,
    required this.technicalPhotoCount,
    required this.openDefectCount,
  }) {
    final budget = room.plannedBudget;
    if (budget != null && budget.currencyCode != actualCost.currencyCode) {
      throw ArgumentError.value(actualCost.currencyCode, 'actualCost');
    }
    for (final value in <int>[
      openChoiceCount,
      openDecisionCount,
      materialCount,
      contactCount,
      technicalPhotoCount,
      openDefectCount,
    ]) {
      if (value < 0) throw RangeError.value(value, 'count');
    }
  }

  final Room room;
  final Money actualCost;
  final int openChoiceCount;
  final int openDecisionCount;
  final int materialCount;
  final int contactCount;
  final int technicalPhotoCount;
  final int openDefectCount;
}

final class RoomDetails {
  RoomDetails({
    required this.overview,
    required Iterable<RoomChoice> choices,
    required Iterable<String> contactIds,
  }) : choices = UnmodifiableListView<RoomChoice>(choices),
       contactIds = UnmodifiableListView<String>(contactIds);

  final RoomOverview overview;
  final UnmodifiableListView<RoomChoice> choices;
  final UnmodifiableListView<String> contactIds;
}

final class RoomPortfolioSummary {
  RoomPortfolioSummary({
    required this.projectId,
    required this.roomCount,
    required this.plannedBudget,
    required this.actualCost,
    required this.openChoiceCount,
  }) {
    if (roomCount < 0 || openChoiceCount < 0) {
      throw RangeError('Summary counters must not be negative');
    }
    if (plannedBudget.currencyCode != actualCost.currencyCode) {
      throw ArgumentError.value(actualCost.currencyCode, 'actualCost');
    }
  }

  final String projectId;
  final int roomCount;
  final Money plannedBudget;
  final Money actualCost;
  final int openChoiceCount;
}

final class RoomRelationCandidate {
  RoomRelationCandidate({
    required this.kind,
    required String id,
    required String title,
    String? supportingLabel,
    String? assignedRoomId,
    String? assignedRoomName,
  }) : id = _requiredText(id, 'id', RoomFieldLimits.id),
       title = _requiredText(title, 'title', 200),
       supportingLabel = _optionalText(supportingLabel, 'supportingLabel', 200),
       assignedRoomId = _optionalText(
         assignedRoomId,
         'assignedRoomId',
         RoomFieldLimits.id,
       ),
       assignedRoomName = _optionalText(
         assignedRoomName,
         'assignedRoomName',
         RoomFieldLimits.name,
       ) {
    if ((this.assignedRoomId == null) != (this.assignedRoomName == null)) {
      throw ArgumentError('Assigned room id and name must be set together');
    }
  }

  final RoomRelationKind kind;
  final String id;
  final String title;
  final String? supportingLabel;
  final String? assignedRoomId;
  final String? assignedRoomName;

  bool isAssignedTo(String roomId) => assignedRoomId == roomId;
}

int? _dimension(int? value, String name) {
  if (value == null) return null;
  if (value < 1 || value > 1000000) {
    throw RangeError.range(value, 1, 1000000, name);
  }
  return value;
}

BigInt _pow10(int exponent) {
  var value = BigInt.one;
  for (var index = 0; index < exponent; index++) {
    value *= BigInt.from(10);
  }
  return value;
}

BigInt _roundHalfUp(BigInt numerator, BigInt denominator) {
  final quotient = numerator ~/ denominator;
  final remainder = numerator.remainder(denominator);
  return remainder * BigInt.from(2) >= denominator
      ? quotient + BigInt.one
      : quotient;
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
