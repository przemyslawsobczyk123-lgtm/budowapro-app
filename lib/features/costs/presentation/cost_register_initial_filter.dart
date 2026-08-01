import 'dart:collection';

import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';

final class CostRegisterInitialFilter {
  factory CostRegisterInitialFilter({
    Set<CostEntryType> types = const <CostEntryType>{},
    Set<CostComponent> components = const <CostComponent>{},
    Set<CostStatus> statuses = const <CostStatus>{},
    Set<CostMissingAssignment> missingAssignments =
        const <CostMissingAssignment>{},
    String? stageId,
    String? categoryId,
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDrafts = true,
  }) {
    final normalizedFrom = _calendarDate(fromDate);
    final normalizedTo = _calendarDate(toDate);
    if (normalizedFrom != null &&
        normalizedTo != null &&
        normalizedFrom.isAfter(normalizedTo)) {
      throw ArgumentError.value(toDate, 'toDate', 'must not precede fromDate');
    }
    return CostRegisterInitialFilter._(
      types: UnmodifiableSetView(Set<CostEntryType>.of(types)),
      components: UnmodifiableSetView(Set<CostComponent>.of(components)),
      statuses: UnmodifiableSetView(Set<CostStatus>.of(statuses)),
      missingAssignments: UnmodifiableSetView(
        Set<CostMissingAssignment>.of(missingAssignments),
      ),
      stageId: _validId(stageId),
      categoryId: _validId(categoryId),
      supplierId: _validId(supplierId),
      fromDate: normalizedFrom,
      toDate: normalizedTo,
      includeDrafts: includeDrafts,
    );
  }

  factory CostRegisterInitialFilter.fromQueryParameters(
    Map<String, String> parameters,
  ) {
    final fromDate = _parseDate(parameters['from']);
    final toDate = _parseDate(parameters['to']);
    final type = _enumValue(CostEntryType.values, parameters['type']);
    final component = _enumValue(CostComponent.values, parameters['component']);
    final status = _enumValue(CostStatus.values, parameters['status']);
    final missing = _enumValue(
      CostMissingAssignment.values,
      parameters['unassigned'],
    );
    final hasReversedRange =
        fromDate != null && toDate != null && fromDate.isAfter(toDate);
    return CostRegisterInitialFilter(
      types: type == null ? const <CostEntryType>{} : <CostEntryType>{type},
      components: component == null
          ? const <CostComponent>{}
          : <CostComponent>{component},
      statuses: status == null ? const <CostStatus>{} : <CostStatus>{status},
      missingAssignments: missing == null
          ? const <CostMissingAssignment>{}
          : <CostMissingAssignment>{missing},
      stageId: missing == CostMissingAssignment.stage
          ? null
          : parameters['stageId'],
      categoryId: missing == CostMissingAssignment.category
          ? null
          : parameters['categoryId'],
      supplierId: missing == CostMissingAssignment.supplier
          ? null
          : parameters['supplierId'],
      fromDate: hasReversedRange ? null : fromDate,
      toDate: hasReversedRange ? null : toDate,
      includeDrafts: parameters['drafts'] == '1',
    );
  }

  const CostRegisterInitialFilter._({
    required this.types,
    required this.components,
    required this.statuses,
    required this.missingAssignments,
    required this.stageId,
    required this.categoryId,
    required this.supplierId,
    required this.fromDate,
    required this.toDate,
    required this.includeDrafts,
  });

  final UnmodifiableSetView<CostEntryType> types;
  final UnmodifiableSetView<CostComponent> components;
  final UnmodifiableSetView<CostStatus> statuses;
  final UnmodifiableSetView<CostMissingAssignment> missingAssignments;
  final String? stageId;
  final String? categoryId;
  final String? supplierId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool includeDrafts;

  String get cacheKey => <Object?>[
    types.map((value) => value.name).join(','),
    components.map((value) => value.name).join(','),
    statuses.map((value) => value.name).join(','),
    missingAssignments.map((value) => value.name).join(','),
    stageId,
    categoryId,
    supplierId,
    fromDate?.toIso8601String(),
    toDate?.toIso8601String(),
    includeDrafts,
  ].join('|');
}

T? _enumValue<T extends Enum>(Iterable<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

String? _validId(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty || normalized.length > 120) {
    return null;
  }
  return normalized;
}

DateTime? _parseDate(String? value) {
  if (value == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    return null;
  }
  final parts = value.split('-').map(int.parse).toList(growable: false);
  final parsed = DateTime(parts[0], parts[1], parts[2]);
  if (parsed.year != parts[0] ||
      parsed.month != parts[1] ||
      parsed.day != parts[2]) {
    return null;
  }
  return parsed;
}

DateTime? _calendarDate(DateTime? value) =>
    value == null ? null : DateTime(value.year, value.month, value.day);
