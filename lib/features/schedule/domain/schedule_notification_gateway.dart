import 'schedule_event.dart';

enum NotificationPermissionState { granted, denied, unavailable }

final class ScheduleNotificationTarget {
  const ScheduleNotificationTarget({
    required this.projectId,
    required this.eventId,
  });

  final String projectId;
  final String eventId;
}

final class ScheduleNotificationRequest {
  const ScheduleNotificationRequest({
    required this.event,
    required this.preferences,
    required this.title,
    required this.body,
  });

  final ScheduleEvent event;
  final ReminderPreferences preferences;
  final String title;
  final String body;
}

abstract interface class ScheduleNotificationGateway {
  Future<void> initialize(
    void Function(ScheduleNotificationTarget target) onOpen,
  );

  Future<NotificationPermissionState> permissionState();

  Future<NotificationPermissionState> requestPermission();

  Future<void> schedule(ScheduleNotificationRequest request);

  Future<void> cancel(ScheduleEvent event);

  Future<String> currentTimeZoneId();

  DateTime toTimeZone(DateTime instant, String timeZoneId);

  DateTime fromWallTime(DateTime wallTime, String timeZoneId);
}
