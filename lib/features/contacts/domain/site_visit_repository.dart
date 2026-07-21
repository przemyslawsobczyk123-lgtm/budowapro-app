import 'site_visit.dart';

abstract interface class SiteVisitRepository {
  Future<SiteVisit> create({
    required String projectId,
    required SiteVisitDraft draft,
  });

  Future<SiteVisit> update({
    required String projectId,
    required String visitId,
    required SiteVisitDraft draft,
    String? rescheduleReason,
  });

  Future<SiteVisit?> findById({
    required String projectId,
    required String visitId,
  });

  Future<List<SiteVisit>> listForContact({
    required String projectId,
    required String contactId,
  });
}

final class SiteVisitNotFoundException implements Exception {
  const SiteVisitNotFoundException();
}
