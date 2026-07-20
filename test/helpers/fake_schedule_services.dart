import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final class FakeScheduleRepository implements ScheduleRepository {
  FakeScheduleRepository({
    Iterable<ScheduleEvent> events = const <ScheduleEvent>[],
    Map<String, List<ScheduleDependency>> dependencies =
        const <String, List<ScheduleDependency>>{},
    Map<String, List<ScheduleDateChange>> history =
        const <String, List<ScheduleDateChange>>{},
    ReminderPreferences? preferences,
  }) : events = List<ScheduleEvent>.of(events),
       dependencies = dependencies.map(
         (key, value) => MapEntry(key, List<ScheduleDependency>.of(value)),
       ),
       history = history.map(
         (key, value) => MapEntry(key, List<ScheduleDateChange>.of(value)),
       ),
       preferences = preferences ?? ReminderPreferences.defaults();

  final List<ScheduleEvent> events;
  final Map<String, List<ScheduleDependency>> dependencies;
  final Map<String, List<ScheduleDateChange>> history;
  ReminderPreferences preferences;
  var _id = 0;

  @override
  Future<ScheduleEvent> create({
    required String projectId,
    required ScheduleEventInput input,
  }) async {
    final now = DateTime.utc(2026, 7, 20, 5);
    final event = _fromInput(
      id: 'created-${++_id}',
      projectId: projectId,
      input: input,
      createdAt: now,
      updatedAt: now,
    );
    events.add(event);
    return event;
  }

  @override
  Future<ScheduleEvent> update({
    required String projectId,
    required String eventId,
    required ScheduleEventInput input,
    String? rescheduleReason,
  }) async {
    final index = events.indexWhere(
      (event) => event.projectId == projectId && event.id == eventId,
    );
    if (index < 0) throw const ScheduleEventNotFoundException();
    final existing = events[index];
    final updated = _fromInput(
      id: eventId,
      projectId: projectId,
      input: input,
      createdAt: existing.createdAtUtc,
      updatedAt: DateTime.utc(2026, 7, 20, 6),
    );
    events[index] = updated;
    return updated;
  }

  @override
  Future<ScheduleEvent?> findById({
    required String projectId,
    required String eventId,
  }) async => events
      .where((event) => event.projectId == projectId && event.id == eventId)
      .firstOrNull;

  @override
  Future<List<ScheduleEvent>> list({
    required String projectId,
    required ScheduleWindow window,
  }) async => events
      .where(
        (event) =>
            event.projectId == projectId && window.contains(event.startsAtUtc),
      )
      .toList(growable: false);

  @override
  Future<List<ScheduleEvent>> listOpen({required String projectId}) async =>
      events
          .where((event) => event.projectId == projectId && !event.isResolved)
          .toList(growable: false);

  @override
  Future<void> replaceDependencies({
    required String projectId,
    required String eventId,
    required Iterable<ScheduleDependencyInput> dependencies,
  }) async {
    this.dependencies[eventId] = dependencies
        .map(
          (input) => ScheduleDependency(
            eventId: eventId,
            blockingEventId: input.blockingEventId,
            decisionDueAt: input.decisionDueAt,
            createdAt: DateTime.utc(2026, 7, 20),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ScheduleDependency>> listDependencies({
    required String projectId,
    required String eventId,
  }) async => dependencies[eventId] ?? const <ScheduleDependency>[];

  @override
  Future<List<ScheduleDateChange>> listDateChanges({
    required String projectId,
    required String eventId,
  }) async => history[eventId] ?? const <ScheduleDateChange>[];

  @override
  Future<ReminderPreferences> getReminderPreferences() async => preferences;

  @override
  Future<void> saveReminderPreferences(ReminderPreferences preferences) async {
    this.preferences = preferences;
  }
}

final class FakeScheduleNotificationGateway
    implements ScheduleNotificationGateway {
  FakeScheduleNotificationGateway({
    this.permission = NotificationPermissionState.denied,
    this.failScheduling = false,
    this.timeZoneId = 'Europe/Warsaw',
  }) {
    tz_data.initializeTimeZones();
  }

  NotificationPermissionState permission;
  final bool failScheduling;
  final String timeZoneId;
  final List<ScheduleNotificationRequest> scheduled =
      <ScheduleNotificationRequest>[];
  void Function(ScheduleNotificationTarget target)? onOpen;

  @override
  Future<void> initialize(
    void Function(ScheduleNotificationTarget target) onOpen,
  ) async {
    this.onOpen = onOpen;
  }

  @override
  Future<NotificationPermissionState> permissionState() async => permission;

  @override
  Future<NotificationPermissionState> requestPermission() async {
    permission = NotificationPermissionState.granted;
    return permission;
  }

  @override
  Future<void> schedule(ScheduleNotificationRequest request) async {
    if (failScheduling) throw StateError('simulated adapter failure');
    scheduled.add(request);
  }

  @override
  Future<void> cancel(ScheduleEvent event) async {}

  @override
  Future<String> currentTimeZoneId() async => timeZoneId;

  @override
  DateTime toTimeZone(DateTime instant, String timeZoneId) {
    return tz.TZDateTime.from(instant.toUtc(), tz.getLocation(timeZoneId));
  }

  @override
  DateTime fromWallTime(DateTime wallTime, String timeZoneId) {
    return tz.TZDateTime(
      tz.getLocation(timeZoneId),
      wallTime.year,
      wallTime.month,
      wallTime.day,
      wallTime.hour,
      wallTime.minute,
    ).toUtc();
  }
}

ScheduleEvent _fromInput({
  required String id,
  required String projectId,
  required ScheduleEventInput input,
  required DateTime createdAt,
  required DateTime updatedAt,
}) => ScheduleEvent(
  id: id,
  projectId: projectId,
  title: input.title,
  kind: input.kind,
  status: input.status,
  startsAt: input.startsAtUtc,
  endsAt: input.endsAtUtc,
  timeZoneId: input.timeZoneId,
  isAllDay: input.isAllDay,
  stageId: input.stageId,
  assignee: input.assignee,
  note: input.note,
  reminderEnabled: input.reminderEnabled,
  reminderLeadMinutes: input.reminderLeadMinutes,
  createdAt: createdAt,
  updatedAt: updatedAt,
);
