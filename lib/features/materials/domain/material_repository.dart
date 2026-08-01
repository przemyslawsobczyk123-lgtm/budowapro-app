import 'dart:collection';

import 'package:budowapro/shared/models/page.dart';

import 'material.dart';

abstract interface class MaterialRepository {
  Future<Page<MaterialItem>> list(
    MaterialQuery query,
    PageRequest request, {
    required DateTime now,
  });

  Future<MaterialItem?> findById({
    required String projectId,
    required String materialId,
  });

  Future<MaterialItem> create(MaterialInput input);

  Future<MaterialItem> update({
    required String projectId,
    required String materialId,
    required MaterialInput input,
  });

  Future<void> delete({required String projectId, required String materialId});

  Future<MaterialDelivery> saveDelivery({
    String? deliveryId,
    required MaterialDeliveryInput input,
    bool confirmOrderedQuantityCorrection = false,
  });

  Future<void> deleteDelivery({
    required String projectId,
    required String materialId,
    required String deliveryId,
  });

  Future<MaterialReturn> saveReturn({
    String? returnId,
    required MaterialReturnInput input,
  });

  Future<void> deleteReturn({
    required String projectId,
    required String materialId,
    required String returnId,
  });

  Future<MaterialDashboardSummary> summarize({
    required String projectId,
    required String currencyCode,
    required DateTime now,
  });
}

final class MaterialQuery {
  factory MaterialQuery({
    required String projectId,
    String? searchText,
    Set<MaterialStatus> statuses = const <MaterialStatus>{},
    String? stageId,
    String? roomId,
  }) {
    return MaterialQuery._(
      projectId: _requiredId(projectId, 'projectId'),
      searchText: _optionalText(searchText, 120)?.toLowerCase(),
      statuses: UnmodifiableSetView<MaterialStatus>(
        Set<MaterialStatus>.of(statuses),
      ),
      stageId: _optionalId(stageId, 'stageId'),
      roomId: _optionalId(roomId, 'roomId'),
    );
  }

  const MaterialQuery._({
    required this.projectId,
    required this.searchText,
    required this.statuses,
    required this.stageId,
    required this.roomId,
  });

  final String projectId;
  final String? searchText;
  final UnmodifiableSetView<MaterialStatus> statuses;
  final String? stageId;
  final String? roomId;
}

final class MaterialNotFoundException implements Exception {
  const MaterialNotFoundException();
}

final class MaterialDeliveryNotFoundException implements Exception {
  const MaterialDeliveryNotFoundException();
}

final class MaterialReturnNotFoundException implements Exception {
  const MaterialReturnNotFoundException();
}

final class MaterialRelationNotFoundException implements Exception {
  const MaterialRelationNotFoundException(this.kind);

  final String kind;
}

final class MaterialOverDeliveryConfirmationRequired implements Exception {
  const MaterialOverDeliveryConfirmationRequired();
}

String _requiredId(String value, String name) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > MaterialFieldLimits.id) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}

String? _optionalId(String? value, String name) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return _requiredId(normalized, name);
}

String? _optionalText(String? value, int maximumLength) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized.length > maximumLength) {
    throw ArgumentError.value(value, 'value');
  }
  return normalized;
}
