import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleEditorGatewayProvider = FutureProvider<ScheduleEditorGateway>((
  ref,
) async {
  return ScheduleEditorGateway(
    repository: await ref.watch(scheduleRepositoryProvider.future),
    notifications: ref.watch(scheduleNotificationGatewayProvider),
  );
});

final class ScheduleEditorGateway {
  const ScheduleEditorGateway({
    required ScheduleRepository repository,
    required ScheduleNotificationGateway notifications,
  }) : this._(repository, notifications);

  const ScheduleEditorGateway._(this.repository, this._notifications);

  final ScheduleRepository repository;
  final ScheduleNotificationGateway _notifications;

  Future<ScheduleEvent> save({
    required String projectId,
    required ScheduleEventInput input,
    required ReminderPreferences preferences,
    required String notificationBody,
    String? eventId,
    String? rescheduleReason,
  }) async {
    final event = eventId == null
        ? await repository.create(projectId: projectId, input: input)
        : await repository.update(
            projectId: projectId,
            eventId: eventId,
            input: input,
            rescheduleReason: rescheduleReason,
          );
    await _scheduleWithoutBlockingPlan(event, preferences, notificationBody);
    return event;
  }

  Future<void> rescheduleOpenEvents({
    required String projectId,
    required ReminderPreferences preferences,
    required String notificationBody,
  }) async {
    for (final event in await repository.listOpen(projectId: projectId)) {
      await _scheduleWithoutBlockingPlan(event, preferences, notificationBody);
    }
  }

  Future<void> _scheduleWithoutBlockingPlan(
    ScheduleEvent event,
    ReminderPreferences preferences,
    String notificationBody,
  ) async {
    try {
      await _notifications.schedule(
        ScheduleNotificationRequest(
          event: event,
          preferences: preferences,
          title: event.title,
          body: notificationBody,
        ),
      );
    } on Object {
      // The system reminder is optional and cannot roll back persisted plan data.
    }
  }
}
