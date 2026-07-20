import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 7, 20, 10);

  test('normalizes event instants to UTC and keeps its IANA timezone', () {
    final event = ScheduleEvent(
      id: 'event-1',
      projectId: 'project-1',
      title: 'Odbior zbrojenia',
      kind: ScheduleEventKind.acceptance,
      status: ScheduleEventStatus.planned,
      startsAt: DateTime.parse('2026-07-21T08:30:00+02:00'),
      timeZoneId: 'Europe/Warsaw',
      isAllDay: false,
      reminderEnabled: true,
      reminderLeadMinutes: 60,
      createdAt: now,
      updatedAt: now,
    );

    expect(event.startsAtUtc, DateTime.utc(2026, 7, 21, 6, 30));
    expect(event.timeZoneId, 'Europe/Warsaw');
    expect(event.reminderAtUtc, DateTime.utc(2026, 7, 21, 5, 30));
  });

  test('rejects invalid ranges and excessive reminder lead', () {
    expect(
      () => _input(
        startsAt: DateTime.utc(2026, 7, 21, 10),
        endsAt: DateTime.utc(2026, 7, 21, 9),
      ),
      throwsArgumentError,
    );
    expect(() => _input(reminderLeadMinutes: 10081), throwsRangeError);
  });

  test('seven day window is inclusive at start and exclusive at end', () {
    final window = ScheduleWindow.sevenDaysFrom(DateTime.utc(2026, 7, 20, 17));

    expect(window.startUtc, DateTime.utc(2026, 7, 20));
    expect(window.endExclusiveUtc, DateTime.utc(2026, 7, 27));
    expect(window.contains(DateTime.utc(2026, 7, 20)), isTrue);
    expect(window.contains(DateTime.utc(2026, 7, 26, 23, 59)), isTrue);
    expect(window.contains(DateTime.utc(2026, 7, 27)), isFalse);
  });

  test('dependency cannot point at the blocked event itself', () {
    expect(
      () => ScheduleDependency(
        eventId: 'same',
        blockingEventId: 'same',
        createdAt: now,
      ),
      throwsArgumentError,
    );
  });

  test('date change keeps old and new instants with timezone history', () {
    final change = ScheduleDateChange(
      id: 'change-1',
      projectId: 'project-1',
      eventId: 'event-1',
      previousStartsAt: DateTime.parse('2026-10-24T08:00:00+02:00'),
      newStartsAt: DateTime.parse('2026-10-26T08:00:00+01:00'),
      previousTimeZoneId: 'Europe/Warsaw',
      newTimeZoneId: 'Europe/Warsaw',
      reason: 'Przesuniety odbior',
      changedAt: now,
    );

    expect(change.previousStartsAtUtc, DateTime.utc(2026, 10, 24, 6));
    expect(change.newStartsAtUtc, DateTime.utc(2026, 10, 26, 7));
  });

  test('reminder preferences can disable one event type', () {
    final preferences = ReminderPreferences.defaults().copyWith(
      enabledKinds: ScheduleEventKind.values.where(
        (kind) => kind != ScheduleEventKind.payment,
      ),
      defaultLeadMinutes: 120,
      allDayReminderMinute: 7 * 60 + 30,
    );

    expect(preferences.isEnabledFor(ScheduleEventKind.task), isTrue);
    expect(preferences.isEnabledFor(ScheduleEventKind.payment), isFalse);
    expect(preferences.defaultLeadMinutes, 120);
    expect(preferences.allDayReminderMinute, 450);
  });
}

ScheduleEventInput _input({
  DateTime? startsAt,
  DateTime? endsAt,
  int reminderLeadMinutes = 60,
}) {
  return ScheduleEventInput(
    title: 'Dostawa bloczkow',
    kind: ScheduleEventKind.delivery,
    status: ScheduleEventStatus.planned,
    startsAt: startsAt ?? DateTime.utc(2026, 7, 21, 8),
    endsAt: endsAt,
    timeZoneId: 'Europe/Warsaw',
    isAllDay: false,
    reminderEnabled: true,
    reminderLeadMinutes: reminderLeadMinutes,
  );
}
