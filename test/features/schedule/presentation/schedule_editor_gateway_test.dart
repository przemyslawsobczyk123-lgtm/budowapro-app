import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:budowapro/features/schedule/presentation/schedule_editor_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'notification denial or adapter failure never rolls back event save',
    () async {
      final repository = _Repository();
      final gateway = ScheduleEditorGateway(
        repository: repository,
        notifications: _FailingNotifications(),
      );

      final event = await gateway.save(
        projectId: 'project-1',
        input: _input(),
        preferences: ReminderPreferences.defaults(),
        notificationBody: 'Nadchodzi termin',
      );

      expect(event.id, 'saved-event');
      expect(repository.saved, isTrue);
    },
  );
}

ScheduleEventInput _input() => ScheduleEventInput(
  title: 'Odbior',
  kind: ScheduleEventKind.acceptance,
  status: ScheduleEventStatus.planned,
  startsAt: DateTime.utc(2026, 7, 21, 8),
  timeZoneId: 'Europe/Warsaw',
  isAllDay: false,
  reminderEnabled: true,
  reminderLeadMinutes: 60,
);

final class _Repository implements ScheduleRepository {
  bool saved = false;

  @override
  Future<ScheduleEvent> create({
    required String projectId,
    required ScheduleEventInput input,
  }) async {
    saved = true;
    return ScheduleEvent(
      id: 'saved-event',
      projectId: projectId,
      title: input.title,
      kind: input.kind,
      status: input.status,
      startsAt: input.startsAtUtc,
      timeZoneId: input.timeZoneId,
      isAllDay: input.isAllDay,
      reminderEnabled: input.reminderEnabled,
      reminderLeadMinutes: input.reminderLeadMinutes,
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 7, 20),
    );
  }

  @override
  Future<ReminderPreferences> getReminderPreferences() async =>
      ReminderPreferences.defaults();

  @override
  Future<ScheduleEvent?> findById({
    required String projectId,
    required String eventId,
  }) => throw UnimplementedError();

  @override
  Future<List<ScheduleDateChange>> listDateChanges({
    required String projectId,
    required String eventId,
  }) => throw UnimplementedError();

  @override
  Future<List<ScheduleDependency>> listDependencies({
    required String projectId,
    required String eventId,
  }) => throw UnimplementedError();

  @override
  Future<List<ScheduleEvent>> list({
    required String projectId,
    required ScheduleWindow window,
  }) => throw UnimplementedError();

  @override
  Future<List<ScheduleEvent>> listOpen({required String projectId}) async =>
      const <ScheduleEvent>[];

  @override
  Future<void> replaceDependencies({
    required String projectId,
    required String eventId,
    required Iterable<ScheduleDependencyInput> dependencies,
  }) => throw UnimplementedError();

  @override
  Future<void> saveReminderPreferences(ReminderPreferences preferences) =>
      throw UnimplementedError();

  @override
  Future<ScheduleEvent> update({
    required String projectId,
    required String eventId,
    required ScheduleEventInput input,
    String? rescheduleReason,
  }) => throw UnimplementedError();
}

final class _FailingNotifications implements ScheduleNotificationGateway {
  @override
  Future<void> schedule(ScheduleNotificationRequest request) {
    throw StateError('permission denied');
  }

  @override
  Future<void> cancel(ScheduleEvent event) => throw UnimplementedError();

  @override
  Future<String> currentTimeZoneId() => throw UnimplementedError();

  @override
  DateTime fromWallTime(DateTime wallTime, String timeZoneId) =>
      throw UnimplementedError();

  @override
  Future<void> initialize(
    void Function(ScheduleNotificationTarget target) onOpen,
  ) => throw UnimplementedError();

  @override
  Future<NotificationPermissionState> permissionState() =>
      throw UnimplementedError();

  @override
  Future<NotificationPermissionState> requestPermission() =>
      throw UnimplementedError();

  @override
  DateTime toTimeZone(DateTime instant, String timeZoneId) =>
      throw UnimplementedError();
}
