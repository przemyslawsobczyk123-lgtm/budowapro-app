import 'package:budowapro/shared/models/page.dart';

import 'journal_entry.dart';

abstract interface class JournalRepository {
  Future<JournalEntry> create(JournalEntryInput input);

  Future<JournalEntry> update({
    required String projectId,
    required String entryId,
    required JournalEntryInput input,
  });

  Future<JournalEntry?> findById({
    required String projectId,
    required String entryId,
  });

  Future<void> delete({required String projectId, required String entryId});

  Future<Page<JournalEntry>> list(JournalEntryQuery query, PageRequest request);

  Future<JournalEntry> setStatus({
    required String projectId,
    required String entryId,
    required JournalEntryStatus status,
  });

  Future<JournalEntry> approveDecision({
    required String projectId,
    required String entryId,
    required String approvedByContactId,
  });

  Future<DecisionImpactSummary> decisionImpactSummary({
    required String projectId,
  });

  Future<List<JournalEntryRevision>> revisions({
    required String projectId,
    required String entryId,
  });
}

final class JournalEntryNotFoundException implements Exception {
  const JournalEntryNotFoundException();
}

final class JournalEntryRelationNotFoundException implements Exception {
  const JournalEntryRelationNotFoundException();
}

final class JournalDecisionApprovalRequiredException implements Exception {
  const JournalDecisionApprovalRequiredException();
}

final class JournalDecisionIncompleteException implements Exception {
  const JournalDecisionIncompleteException();
}
