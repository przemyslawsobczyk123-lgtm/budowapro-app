import 'package:budowapro/features/schedule/data/local_schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/data/schedule_notification_payload.dart';
import 'package:budowapro/features/schedule/data/schedule_reminder_time.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('payload contains only validated source identifiers', () {
    const target = ScheduleNotificationTarget(
      projectId: 'project-1',
      eventId: 'event-1',
    );

    final encoded = ScheduleNotificationPayload.encode(target);
    final decoded = ScheduleNotificationPayload.decode(encoded);

    expect(decoded?.projectId, target.projectId);
    expect(decoded?.eventId, target.eventId);
    expect(encoded, isNot(contains('Odbior')));
    expect(ScheduleNotificationPayload.decode('{broken'), isNull);
  });

  test('timed reminder keeps the Warsaw wall time across DST', () {
    final event = _event(
      startsAt: DateTime.utc(2026, 10, 26, 7),
      leadMinutes: 60,
    );

    final reminder = ScheduleReminderTime.resolve(
      event: event,
      preferences: ReminderPreferences.defaults(),
      location: tz.getLocation('Europe/Warsaw'),
    );

    expect(reminder.hour, 7);
    expect(reminder.toUtc(), DateTime.utc(2026, 10, 26, 6));
  });

  test('all-day reminder uses preferred wall clock before applying lead', () {
    final event = _event(
      startsAt: DateTime.utc(2026, 7, 21, 22),
      leadMinutes: 24 * 60,
      isAllDay: true,
    );
    final preferences = ReminderPreferences.defaults().copyWith(
      allDayReminderMinute: 8 * 60 + 30,
    );

    final reminder = ScheduleReminderTime.resolve(
      event: event,
      preferences: preferences,
      location: tz.getLocation('Europe/Warsaw'),
    );

    expect(
      reminder,
      tz.TZDateTime(tz.getLocation('Europe/Warsaw'), 2026, 7, 21, 8, 30),
    );
  });

  test('notification ID is positive, stable and source-specific', () {
    expect(scheduleNotificationId('project', 'event'), greaterThanOrEqualTo(0));
    expect(
      scheduleNotificationId('project', 'event'),
      scheduleNotificationId('project', 'event'),
    );
    expect(
      scheduleNotificationId('project', 'event'),
      isNot(scheduleNotificationId('project', 'other')),
    );
  });

  test('notification content stays hidden on a secure lock screen', () {
    expect(
      scheduleNotificationDetails.android?.visibility,
      NotificationVisibility.secret,
    );
  });
}

ScheduleEvent _event({
  required DateTime startsAt,
  required int leadMinutes,
  bool isAllDay = false,
}) {
  return ScheduleEvent(
    id: 'event-1',
    projectId: 'project-1',
    title: 'Termin',
    kind: ScheduleEventKind.task,
    status: ScheduleEventStatus.planned,
    startsAt: startsAt,
    timeZoneId: 'Europe/Warsaw',
    isAllDay: isAllDay,
    reminderEnabled: true,
    reminderLeadMinutes: leadMinutes,
    createdAt: DateTime.utc(2026, 7, 20),
    updatedAt: DateTime.utc(2026, 7, 20),
  );
}
