import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/contacts/domain/site_visit_repository.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final siteVisitEditorGatewayProvider = FutureProvider<SiteVisitEditorGateway>((
  ref,
) async {
  return SiteVisitEditorGateway(
    repository: await ref.watch(siteVisitRepositoryProvider.future),
    notifications: ref.watch(scheduleNotificationGatewayProvider),
  );
});

final class SiteVisitEditorGateway {
  factory SiteVisitEditorGateway({
    required SiteVisitRepository repository,
    required ScheduleNotificationGateway notifications,
  }) => SiteVisitEditorGateway._(repository, notifications);

  const SiteVisitEditorGateway._(this._repository, this._notifications);

  final SiteVisitRepository _repository;
  final ScheduleNotificationGateway _notifications;

  Future<SiteVisit> save({
    required String projectId,
    required SiteVisitDraft draft,
    required ReminderPreferences preferences,
    required String notificationBody,
    String? visitId,
    String? rescheduleReason,
  }) async {
    final visit = visitId == null
        ? await _repository.create(projectId: projectId, draft: draft)
        : await _repository.update(
            projectId: projectId,
            visitId: visitId,
            draft: draft,
            rescheduleReason: rescheduleReason,
          );
    try {
      await _notifications.schedule(
        ScheduleNotificationRequest(
          event: visit.scheduleEvent,
          preferences: preferences,
          title: visit.purpose,
          body: notificationBody,
        ),
      );
    } on Object {
      // A system reminder cannot roll back locally persisted visit data.
    }
    return visit;
  }
}
