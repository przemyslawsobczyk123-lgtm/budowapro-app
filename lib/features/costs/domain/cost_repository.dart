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

  Future<Page<CostHistoryEntry>> history({
    required String projectId,
    required String costEntryId,
    required PageRequest page,
  });

  Future<void> delete({required String projectId, required String costEntryId});
}

final class CostQuery {
  factory CostQuery({required String projectId, bool includeDrafts = false}) {
    return CostQuery._(
      projectId: _requiredProjectId(projectId),
      includeDrafts: includeDrafts,
    );
  }

  const CostQuery._({required this.projectId, required this.includeDrafts});

  final String projectId;
  final bool includeDrafts;
}

final class CostSummaryQuery {
  factory CostSummaryQuery({required String projectId}) {
    return CostSummaryQuery._(projectId: _requiredProjectId(projectId));
  }

  const CostSummaryQuery._({required this.projectId});

  final String projectId;
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
