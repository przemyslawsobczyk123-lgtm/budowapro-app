import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:timezone/timezone.dart' as tz;

abstract final class ScheduleReminderTime {
  static tz.TZDateTime resolve({
    required ScheduleEvent event,
    required ReminderPreferences preferences,
    required tz.Location location,
  }) {
    final eventTime = tz.TZDateTime.from(event.startsAtUtc, location);
    final base = event.isAllDay
        ? tz.TZDateTime(
            location,
            eventTime.year,
            eventTime.month,
            eventTime.day,
            preferences.allDayReminderMinute ~/ 60,
            preferences.allDayReminderMinute % 60,
          )
        : eventTime;
    return base.subtract(Duration(minutes: event.reminderLeadMinutes));
  }
}
