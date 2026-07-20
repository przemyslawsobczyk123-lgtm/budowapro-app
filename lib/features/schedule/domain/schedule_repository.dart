import 'schedule_event.dart';

abstract interface class ScheduleRepository {
  Future<ScheduleEvent> create({
    required String projectId,
    required ScheduleEventInput input,
  });

  Future<ScheduleEvent> update({
    required String projectId,
    required String eventId,
    required ScheduleEventInput input,
    String? rescheduleReason,
  });

  Future<ScheduleEvent?> findById({
    required String projectId,
    required String eventId,
  });

  Future<List<ScheduleEvent>> list({
    required String projectId,
    required ScheduleWindow window,
  });

  Future<List<ScheduleEvent>> listOpen({required String projectId});

  Future<void> replaceDependencies({
    required String projectId,
    required String eventId,
    required Iterable<ScheduleDependencyInput> dependencies,
  });

  Future<List<ScheduleDependency>> listDependencies({
    required String projectId,
    required String eventId,
  });

  Future<List<ScheduleDateChange>> listDateChanges({
    required String projectId,
    required String eventId,
  });

  Future<ReminderPreferences> getReminderPreferences();

  Future<void> saveReminderPreferences(ReminderPreferences preferences);
}

final class ScheduleDependencyInput {
  const ScheduleDependencyInput({
    required this.blockingEventId,
    this.decisionDueAt,
  });

  final String blockingEventId;
  final DateTime? decisionDueAt;
}

final class ScheduleEventNotFoundException implements Exception {
  const ScheduleEventNotFoundException();
}

final class ScheduleDependencyCycleException implements Exception {
  const ScheduleDependencyCycleException();
}
