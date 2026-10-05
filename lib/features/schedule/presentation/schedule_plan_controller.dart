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
    final refreshed = await AsyncValue.guard(
      () => _load(current!.project!, current.window, current.timeZoneId),
    );
    if (!ref.mounted) return;
    state = refreshed;
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
    final moved = await AsyncValue.guard(
      () => _load(project, window, current.timeZoneId),
    );
    if (!ref.mounted) return;
    state = moved;
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
      if (!ref.mounted) return;
      final current = state.requireValue;
      state = AsyncData<SchedulePlanState>(current.copyWith(isSaving: true));
      try {
        final changed = await action(current);
        if (!ref.mounted) return;
        final refreshed = reload && changed.project != null
            ? await _load(changed.project!, changed.window, changed.timeZoneId)
            : changed.copyWith(isSaving: false);
        if (!ref.mounted) return;
        state = AsyncData<SchedulePlanState>(refreshed);
      } on Object catch (error, stackTrace) {
        if (ref.mounted) {
          state = AsyncData<SchedulePlanState>(current);
        }
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
    final eventDataFuture = _loadScheduleEventData(
      repository: repository,
      projectId: project.id,
      window: window,
    );
    final openEventsFuture = repository.listOpen(projectId: project.id);
    final preferencesFuture = repository.getReminderPreferences();
    final permissionFuture = _permission(notifications);
    final results = await Future.wait<Object>(<Future<Object>>[
      eventDataFuture,
      openEventsFuture,
      preferencesFuture,
      permissionFuture,
    ]);
    final eventData = results[0] as _ScheduleEventData;
    return SchedulePlanState(
      project: project,
      window: window,
      timeZoneId: timeZoneId,
      events: eventData.events,
      blockersByEventId: eventData.blockersByEventId,
      openEvents: results[1] as List<ScheduleEvent>,
      preferences: results[2] as ReminderPreferences,
      permission: results[3] as NotificationPermissionState,
    );
  }
}

const _maxConcurrentScheduleReads = 8;

final class _ScheduleEventData {
  const _ScheduleEventData({
    required this.events,
    required this.blockersByEventId,
  });

  final List<ScheduleEvent> events;
  final Map<String, List<ScheduleBlocker>> blockersByEventId;
}

Future<_ScheduleEventData> _loadScheduleEventData({
  required ScheduleRepository repository,
  required String projectId,
  required ScheduleWindow window,
}) async {
  final events = await repository.list(projectId: projectId, window: window);
  final dependenciesByEvent = await _mapConcurrently(
    events,
    (event) =>
        repository.listDependencies(projectId: projectId, eventId: event.id),
  );
  final blockingEventIds = <String>{};
  for (final dependencies in dependenciesByEvent) {
    blockingEventIds.addAll(
      dependencies.map((dependency) => dependency.blockingEventId),
    );
  }
  final uniqueBlockingEventIds = blockingEventIds.toList(growable: false);
  final blockingEvents = await _mapConcurrently(
    uniqueBlockingEventIds,
    (eventId) => repository.findById(projectId: projectId, eventId: eventId),
  );
  final blockingEventsById = <String, ScheduleEvent>{};
  for (var index = 0; index < uniqueBlockingEventIds.length; index += 1) {
    final event = blockingEvents[index];
    if (event != null) {
      blockingEventsById[uniqueBlockingEventIds[index]] = event;
    }
  }
  final blockersByEventId = <String, List<ScheduleBlocker>>{};
  for (var index = 0; index < events.length; index += 1) {
    final eventBlockers = <ScheduleBlocker>[];
    for (final dependency in dependenciesByEvent[index]) {
      final blockingEvent = blockingEventsById[dependency.blockingEventId];
      if (blockingEvent != null) {
        eventBlockers.add(
          ScheduleBlocker(dependency: dependency, event: blockingEvent),
        );
      }
    }
    blockersByEventId[events[index].id] = eventBlockers;
  }
  return _ScheduleEventData(
    events: events,
    blockersByEventId: blockersByEventId,
  );
}

Future<List<Result>> _mapConcurrently<Value, Result>(
  List<Value> values,
  Future<Result> Function(Value value) read,
) async {
  if (values.isEmpty) return <Result>[];
  final results = List<Result?>.filled(values.length, null);
  var nextIndex = 0;

  Future<void> worker() async {
    while (nextIndex < values.length) {
      final index = nextIndex;
      nextIndex += 1;
      results[index] = await read(values[index]);
    }
  }

  final workerCount = values.length.clamp(1, _maxConcurrentScheduleReads);
  await Future.wait(List<Future<void>>.generate(workerCount, (_) => worker()));
  return List<Result>.generate(
    results.length,
    (index) => results[index] as Result,
    growable: false,
  );
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
