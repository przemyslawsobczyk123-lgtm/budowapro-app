import 'dart:async';

import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'schedule_editor_gateway.dart';

final schedulePlanControllerProvider =
    AsyncNotifierProvider<SchedulePlanController, SchedulePlanState>(
      SchedulePlanController.new,
    );

final class ScheduleBlocker {
  const ScheduleBlocker({required this.dependency, required this.event});

  final ScheduleDependency dependency;
  final ScheduleEvent event;
}

final class SchedulePlanState {
  SchedulePlanState({
    required this.project,
    required this.window,
    required this.timeZoneId,
    required Iterable<ScheduleEvent> events,
    required Map<String, List<ScheduleBlocker>> blockersByEventId,
    required Iterable<ScheduleEvent> openEvents,
    required this.preferences,
    required this.permission,
    this.isSaving = false,
  }) : events = List<ScheduleEvent>.unmodifiable(events),
       blockersByEventId = Map<String, List<ScheduleBlocker>>.unmodifiable(
         blockersByEventId.map(
           (key, value) =>
               MapEntry(key, List<ScheduleBlocker>.unmodifiable(value)),
         ),
       ),
       openEvents = List<ScheduleEvent>.unmodifiable(openEvents);

  factory SchedulePlanState.noProject() => SchedulePlanState(
    project: null,
    window: ScheduleWindow.sevenDaysFrom(DateTime.now().toUtc()),
    timeZoneId: 'Etc/UTC',
    events: const <ScheduleEvent>[],
    blockersByEventId: const <String, List<ScheduleBlocker>>{},
    openEvents: const <ScheduleEvent>[],
    preferences: ReminderPreferences.defaults(),
    permission: NotificationPermissionState.unavailable,
  );

  final Project? project;
  final ScheduleWindow window;
  final String timeZoneId;
  final List<ScheduleEvent> events;
  final Map<String, List<ScheduleBlocker>> blockersByEventId;
  final List<ScheduleEvent> openEvents;
  final ReminderPreferences preferences;
  final NotificationPermissionState permission;
  final bool isSaving;

  int get blockedCount => events.where((event) {
    final unresolved = blockersByEventId[event.id]?.any(
      (blocker) => !blocker.event.isResolved,
    );
    return event.status == ScheduleEventStatus.blocked || unresolved == true;
  }).length;

  SchedulePlanState copyWith({
    ReminderPreferences? preferences,
    NotificationPermissionState? permission,
    bool? isSaving,
  }) => SchedulePlanState(
    project: project,
    window: window,
    timeZoneId: timeZoneId,
    events: events,
    blockersByEventId: blockersByEventId,
    openEvents: openEvents,
    preferences: preferences ?? this.preferences,
    permission: permission ?? this.permission,
    isSaving: isSaving ?? this.isSaving,
  );
}

final class SchedulePlanController extends AsyncNotifier<SchedulePlanState> {
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<SchedulePlanState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return SchedulePlanState.noProject();
    final notifications = ref.watch(scheduleNotificationGatewayProvider);
    final timeZoneId = await _timeZoneId(notifications);
    final window = _windowForLocalDay(
      notifications: notifications,
      timeZoneId: timeZoneId,
      instant: ref.watch(scheduleUtcNowProvider)().toUtc(),
    );
    return _load(project, window, timeZoneId);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current?.project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<SchedulePlanState>();
    state = await AsyncValue.guard(
      () => _load(current!.project!, current.window, current.timeZoneId),
    );
  }

  Future<void> moveWindow(int calendarDays) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null || current.isSaving) return;
    final notifications = ref.read(scheduleNotificationGatewayProvider);
    final localStart = notifications.toTimeZone(
      current.window.startUtc,
      current.timeZoneId,
    );
    final nextWallDay = DateTime(
      localStart.year,
      localStart.month,
      localStart.day + calendarDays,
    );
    final window = _windowForWallDay(
      notifications,
      current.timeZoneId,
      nextWallDay,
    );
    state = const AsyncLoading<SchedulePlanState>();
    state = await AsyncValue.guard(
      () => _load(project, window, current.timeZoneId),
    );
  }

  Future<void> requestNotificationPermission({
    required String notificationBody,
  }) {
    return _mutate((current) async {
      final notifications = ref.read(scheduleNotificationGatewayProvider);
      try {
        final permission = await notifications.requestPermission();
        if (permission == NotificationPermissionState.granted &&
            current.project != null) {
          await (await ref.read(
            scheduleEditorGatewayProvider.future,
          )).rescheduleOpenEvents(
            projectId: current.project!.id,
            preferences: current.preferences,
            notificationBody: notificationBody,
          );
        }
        return current.copyWith(permission: permission);
      } on Object {
        return current.copyWith(
          permission: NotificationPermissionState.unavailable,
        );
      }
    }, reload: false);
  }

  Future<void> savePreferences(
    ReminderPreferences preferences, {
    required String notificationBody,
  }) {
    return _mutate((current) async {
      final repository = await ref.read(scheduleRepositoryProvider.future);
      await repository.saveReminderPreferences(preferences);
      final project = current.project;
      if (project != null) {
        await (await ref.read(
          scheduleEditorGatewayProvider.future,
        )).rescheduleOpenEvents(
          projectId: project.id,
          preferences: preferences,
          notificationBody: notificationBody,
        );
      }
      return current.copyWith(preferences: preferences);
    }, reload: false);
  }

  Future<void> replaceDependencies(
    String eventId,
    Iterable<ScheduleDependencyInput> dependencies,
  ) {
    return _mutate((current) async {
      final repository = await ref.read(scheduleRepositoryProvider.future);
      await repository.replaceDependencies(
        projectId: current.project!.id,
        eventId: eventId,
        dependencies: dependencies,
      );
      return current;
    });
  }

  Future<void> _mutate(
    Future<SchedulePlanState> Function(SchedulePlanState current) action, {
    bool reload = true,
  }) {
    final mutation = _mutationQueue.then<void>((_) async {
      final current = state.requireValue;
      state = AsyncData<SchedulePlanState>(current.copyWith(isSaving: true));
      try {
        final changed = await action(current);
        state = AsyncData<SchedulePlanState>(
          reload && changed.project != null
              ? await _load(
                  changed.project!,
                  changed.window,
                  changed.timeZoneId,
                )
              : changed.copyWith(isSaving: false),
        );
      } on Object catch (error, stackTrace) {
        state = AsyncData<SchedulePlanState>(current);
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _mutationQueue = mutation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return mutation;
  }

  Future<SchedulePlanState> _load(
    Project project,
    ScheduleWindow window,
    String timeZoneId,
  ) async {
    final repository = await ref.read(scheduleRepositoryProvider.future);
    final notifications = ref.read(scheduleNotificationGatewayProvider);
    final events = await repository.list(projectId: project.id, window: window);
    final openEvents = await repository.listOpen(projectId: project.id);
    final blockers = <String, List<ScheduleBlocker>>{};
    for (final event in events) {
      final dependencies = await repository.listDependencies(
        projectId: project.id,
        eventId: event.id,
      );
      final eventBlockers = <ScheduleBlocker>[];
      for (final dependency in dependencies) {
        final blockingEvent = await repository.findById(
          projectId: project.id,
          eventId: dependency.blockingEventId,
        );
        if (blockingEvent != null) {
          eventBlockers.add(
            ScheduleBlocker(dependency: dependency, event: blockingEvent),
          );
        }
      }
      blockers[event.id] = eventBlockers;
    }
    return SchedulePlanState(
      project: project,
      window: window,
      timeZoneId: timeZoneId,
      events: events,
      blockersByEventId: blockers,
      openEvents: openEvents,
      preferences: await repository.getReminderPreferences(),
      permission: await _permission(notifications),
    );
  }
}

Future<String> _timeZoneId(ScheduleNotificationGateway notifications) async {
  try {
    return await notifications.currentTimeZoneId();
  } on Object {
    return 'Etc/UTC';
  }
}

Future<NotificationPermissionState> _permission(
  ScheduleNotificationGateway notifications,
) async {
  try {
    return await notifications.permissionState();
  } on Object {
    return NotificationPermissionState.unavailable;
  }
}

ScheduleWindow _windowForLocalDay({
  required ScheduleNotificationGateway notifications,
  required String timeZoneId,
  required DateTime instant,
}) {
  final local = notifications.toTimeZone(instant, timeZoneId);
  return _windowForWallDay(
    notifications,
    timeZoneId,
    DateTime(local.year, local.month, local.day),
  );
}

ScheduleWindow _windowForWallDay(
  ScheduleNotificationGateway notifications,
  String timeZoneId,
  DateTime wallDay,
) {
  final start = notifications.fromWallTime(wallDay, timeZoneId);
  final end = notifications.fromWallTime(
    DateTime(wallDay.year, wallDay.month, wallDay.day + 7),
    timeZoneId,
  );
  return ScheduleWindow(start: start, endExclusive: end);
}
