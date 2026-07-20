import 'dart:collection';

import 'package:budowapro/shared/models/page.dart';

import 'cost_entry.dart';
import 'cost_summary.dart';

abstract interface class CostRepository {
  Future<CostEntry> create(ConfirmedCostEntryInput input);

  Future<CostEntry> saveDraft(CostDraftInput input);

  Future<CostEntry> replaceDraft({
    required String projectId,
    required String costEntryId,
    required CostDraftInput input,
  });

  Future<CostEntry> confirmDraft({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
    CostDraftInput? replacement,
  });

  Future<CostEntry> changeStatus({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
  });

  Future<CostEntry> updateDetails({
    required String projectId,
    required String costEntryId,
    required ConfirmedCostDetailsInput input,
  });

  Future<CostCorrection> addCorrection(CostCorrectionInput input);

  Future<CostEntry?> findById({
    required String projectId,
    required String costEntryId,
  });

  Future<Page<CostEntry>> list(CostQuery query, PageRequest page);

  Future<CostSummary> summarize(CostSummaryQuery query);

  Future<CostFilterOptions> filterOptions({required String projectId});

  Future<Page<CostHistoryEntry>> history({
    required String projectId,
    required String costEntryId,
    required PageRequest page,
  });

  Future<void> delete({required String projectId, required String costEntryId});
}

enum CostSort {
  newest,
  oldest,
  amountDescending,
  amountAscending,
  nameAscending,
}

enum CostWarning { missingDocument, missingDescription, vatToReview }

final class CostQuery {
  factory CostQuery({
    required String projectId,
    String? searchText,
    Set<CostEntryType> types = const <CostEntryType>{},
    Set<CostStatus> statuses = const <CostStatus>{},
    Set<String> stageIds = const <String>{},
    Set<String> categoryIds = const <String>{},
    Set<String> supplierIds = const <String>{},
    Set<CostPaymentMethod> paymentMethods = const <CostPaymentMethod>{},
    Set<CostSource> sources = const <CostSource>{},
    Set<CostWarning> warnings = const <CostWarning>{},
    DateTime? fromInclusive,
    DateTime? toExclusive,
    bool includeDrafts = false,
    CostSort sort = CostSort.newest,
  }) {
    final normalizedFrom = fromInclusive?.toUtc();
    final normalizedTo = toExclusive?.toUtc();
    if (normalizedFrom != null &&
        normalizedTo != null &&
        !normalizedFrom.isBefore(normalizedTo)) {
      throw ArgumentError.value(
        toExclusive,
        'toExclusive',
        'must be after fromInclusive',
      );
    }
    return CostQuery._(
      projectId: _requiredProjectId(projectId),
      searchText: _optionalSearchText(searchText),
      types: UnmodifiableSetView<CostEntryType>(Set<CostEntryType>.of(types)),
      statuses: UnmodifiableSetView<CostStatus>(Set<CostStatus>.of(statuses)),
      stageIds: _normalizedIds(stageIds, 'stageIds'),
      categoryIds: _normalizedIds(categoryIds, 'categoryIds'),
      supplierIds: _normalizedIds(supplierIds, 'supplierIds'),
      paymentMethods: UnmodifiableSetView<CostPaymentMethod>(
        Set<CostPaymentMethod>.of(paymentMethods),
      ),
      sources: UnmodifiableSetView<CostSource>(Set<CostSource>.of(sources)),
      warnings: UnmodifiableSetView<CostWarning>(Set<CostWarning>.of(warnings)),
      fromInclusive: normalizedFrom,
      toExclusive: normalizedTo,
      includeDrafts: includeDrafts,
      sort: sort,
    );
  }

  const CostQuery._({
    required this.projectId,
    required this.searchText,
    required this.types,
    required this.statuses,
    required this.stageIds,
    required this.categoryIds,
    required this.supplierIds,
    required this.paymentMethods,
    required this.sources,
    required this.warnings,
    required this.fromInclusive,
    required this.toExclusive,
    required this.includeDrafts,
    required this.sort,
  });

  final String projectId;
  final String? searchText;
  final UnmodifiableSetView<CostEntryType> types;
  final UnmodifiableSetView<CostStatus> statuses;
  final UnmodifiableSetView<String> stageIds;
  final UnmodifiableSetView<String> categoryIds;
  final UnmodifiableSetView<String> supplierIds;
  final UnmodifiableSetView<CostPaymentMethod> paymentMethods;
  final UnmodifiableSetView<CostSource> sources;
  final UnmodifiableSetView<CostWarning> warnings;
  final DateTime? fromInclusive;
  final DateTime? toExclusive;
  final bool includeDrafts;
  final CostSort sort;

  int get activeFilterCount {
    var count = 0;
    if (searchText != null) count++;
    if (types.isNotEmpty) count++;
    if (statuses.isNotEmpty) count++;
    if (stageIds.isNotEmpty) count++;
    if (categoryIds.isNotEmpty) count++;
    if (supplierIds.isNotEmpty) count++;
    if (paymentMethods.isNotEmpty) count++;
    if (sources.isNotEmpty) count++;
    if (warnings.isNotEmpty) count++;
    if (fromInclusive != null || toExclusive != null) count++;
    return count;
  }

  CostQuery withoutDrafts() => CostQuery(
    projectId: projectId,
    searchText: searchText,
    types: types,
    statuses: statuses,
    stageIds: stageIds,
    categoryIds: categoryIds,
    supplierIds: supplierIds,
    paymentMethods: paymentMethods,
    sources: sources,
    warnings: warnings,
    fromInclusive: fromInclusive,
    toExclusive: toExclusive,
    sort: sort,
  );
}

final class CostSummaryQuery {
  factory CostSummaryQuery({required String projectId}) {
    return CostSummaryQuery._(filters: CostQuery(projectId: projectId));
  }

  factory CostSummaryQuery.fromCostQuery(CostQuery query) {
    return CostSummaryQuery._(filters: query.withoutDrafts());
  }

  const CostSummaryQuery._({required this.filters});

  final CostQuery filters;

  String get projectId => filters.projectId;
}

final class CostFilterOptions {
  CostFilterOptions({
    Iterable<String> stageIds = const <String>[],
    Iterable<String> categoryIds = const <String>[],
    Iterable<String> supplierIds = const <String>[],
  }) : stageIds = UnmodifiableListView<String>(stageIds),
       categoryIds = UnmodifiableListView<String>(categoryIds),
       supplierIds = UnmodifiableListView<String>(supplierIds);

  final UnmodifiableListView<String> stageIds;
  final UnmodifiableListView<String> categoryIds;
  final UnmodifiableListView<String> supplierIds;
}

final class CostNotFoundException implements Exception {
  const CostNotFoundException();
}

String _requiredProjectId(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > 64) {
    throw ArgumentError.value(
      value,
      'projectId',
      'must contain between 1 and 64 characters',
    );
  }
  return normalized;
}

String? _optionalSearchText(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized.length > 120) {
    throw ArgumentError.value(
      value,
      'searchText',
      'must not exceed 120 characters',
    );
  }
  return normalized;
}

UnmodifiableSetView<String> _normalizedIds(
  Iterable<String> values,
  String fieldName,
) {
  final normalized = <String>{};
  for (final value in values) {
    final id = value.trim();
    if (id.isEmpty || id.length > 120) {
      throw ArgumentError.value(
        value,
        fieldName,
        'values must contain between 1 and 120 characters',
      );
    }
    normalized.add(id);
  }
  if (normalized.length > 50) {
    throw ArgumentError.value(values, fieldName, 'must not exceed 50 values');
  }
  return UnmodifiableSetView<String>(normalized);
}
