import 'dart:async';

import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loads independent data concurrently and reuses unique blockers in dependency order',
    () async {
      final project = _project();
      final firstEvent = _event('event-1');
      final secondEvent = _event('event-2');
      final sharedBlocker = _event('blocker-shared');
      final laterBlocker = _event('blocker-later');
      final openEvent = _event('open-event');
      final preferences = ReminderPreferences(
        enabledKinds: const <ScheduleEventKind>{ScheduleEventKind.delivery},
        defaultLeadMinutes: 30,
        allDayReminderMinute: 9 * 60,
      );
      final repository = _ControlledScheduleRepository(
        eventsById: <String, ScheduleEvent>{
          sharedBlocker.id: sharedBlocker,
          laterBlocker.id: laterBlocker,
        },
      );
      final notifications = _ControlledNotificationGateway();
      final container = ProviderContainer(
        overrides: [
          projectsControllerProvider.overrideWithBuild(
            (ref, notifier) async => ProjectsState(
              projects: <Project>[project],
              selectedProject: project,
            ),
          ),
          scheduleRepositoryProvider.overrideWith((ref) async => repository),
          scheduleNotificationGatewayProvider.overrideWithValue(notifications),
          scheduleUtcNowProvider.overrideWithValue(
            () => DateTime.utc(2026, 8, 13, 8),
          ),
        ],
      );
      addTearDown(container.dispose);

      final stateFuture = container.read(schedulePlanControllerProvider.future);
      await _flushEvents();

      expect(repository.listStarted, isTrue);
      expect(repository.listOpenStarted, isTrue);
      expect(repository.preferencesStarted, isTrue);
      expect(notifications.permissionStarted, isTrue);
      expect(repository.listResult.isCompleted, isFalse);

      repository.listOpenResult.complete(<ScheduleEvent>[openEvent]);
      repository.preferencesResult.complete(preferences);
      notifications.permissionResult.completeError(StateError('unsupported'));
      repository.listResult.complete(<ScheduleEvent>[firstEvent, secondEvent]);
      await _flushEvents();

      expect(repository.startedDependencyEventIds, <String>[
        firstEvent.id,
        secondEvent.id,
      ]);
      expect(
        repository.dependencyResults.values.every(
          (result) => !result.isCompleted,
        ),
        isTrue,
      );

      final firstSharedDependency = _dependency(
        firstEvent.id,
        sharedBlocker.id,
        minute: 1,
      );
      final missingDependency = _dependency(
        firstEvent.id,
        'missing-blocker',
        minute: 2,
      );
      final laterDependency = _dependency(
        firstEvent.id,
        laterBlocker.id,
        minute: 3,
      );
      final secondSharedDependency = _dependency(
        secondEvent.id,
        sharedBlocker.id,
        minute: 4,
      );
      repository.dependencyResults[firstEvent.id]!.complete(
        <ScheduleDependency>[
          firstSharedDependency,
          missingDependency,
          laterDependency,
        ],
      );
      repository.dependencyResults[secondEvent.id]!.complete(
        <ScheduleDependency>[secondSharedDependency],
      );
      await _flushEvents();

      expect(repository.findCalls[sharedBlocker.id], 1);
      expect(repository.findCalls['missing-blocker'], 1);
      expect(repository.findCalls[laterBlocker.id], 1);
      expect(repository.findCalls.length, 3);
      expect(
        repository.findResults.values.every((result) => !result.isCompleted),
        isTrue,
      );

      for (final entry in repository.findResults.entries) {
        entry.value.complete(repository.eventsById[entry.key]);
      }

      final state = await stateFuture;
      expect(state.events, <ScheduleEvent>[firstEvent, secondEvent]);
      expect(state.openEvents, <ScheduleEvent>[openEvent]);
      expect(state.preferences, same(preferences));
      expect(state.permission, NotificationPermissionState.unavailable);
      expect(
        state.blockersByEventId[firstEvent.id]!.map(
          (blocker) => blocker.dependency,
        ),
        <ScheduleDependency>[firstSharedDependency, laterDependency],
      );
      expect(
        state.blockersByEventId[firstEvent.id]!.map((blocker) => blocker.event),
        <ScheduleEvent>[sharedBlocker, laterBlocker],
      );
      expect(
        state.blockersByEventId[secondEvent.id]!.single.dependency,
        same(secondSharedDependency),
      );
      expect(
        state.blockersByEventId[secondEvent.id]!.single.event,
        same(sharedBlocker),
      );
    },
  );

  test('limits concurrent dependency reads to eight', () async {
    final project = _project();
    final events = List<ScheduleEvent>.generate(
      9,
      (index) => _event('event-${index + 1}'),
      growable: false,
    );
    final repository = _ControlledScheduleRepository(
      eventsById: const <String, ScheduleEvent>{},
    );
    final notifications = _ControlledNotificationGateway();
    repository.listResult.complete(events);
    repository.listOpenResult.complete(const <ScheduleEvent>[]);
    repository.preferencesResult.complete(ReminderPreferences.defaults());
    notifications.permissionResult.complete(NotificationPermissionState.denied);
    final container = ProviderContainer(
      overrides: [
        projectsControllerProvider.overrideWithBuild(
          (ref, notifier) async => ProjectsState(
            projects: <Project>[project],
            selectedProject: project,
          ),
        ),
        scheduleRepositoryProvider.overrideWith((ref) async => repository),
        scheduleNotificationGatewayProvider.overrideWithValue(notifications),
        scheduleUtcNowProvider.overrideWithValue(
          () => DateTime.utc(2026, 8, 13, 8),
        ),
      ],
    );
    addTearDown(container.dispose);

    final stateFuture = container.read(schedulePlanControllerProvider.future);
    await _flushEvents();

    expect(
      repository.startedDependencyEventIds,
      events.take(8).map((event) => event.id),
    );
    expect(repository.startedDependencyEventIds, isNot(contains(events[8].id)));

    repository.dependencyResults[events.first.id]!.complete(
      const <ScheduleDependency>[],
    );
    await _flushEvents();

    expect(repository.startedDependencyEventIds, contains(events[8].id));

    for (final result in repository.dependencyResults.values) {
      if (!result.isCompleted) result.complete(const <ScheduleDependency>[]);
    }
    final state = await stateFuture;
    expect(state.events, events);
    expect(state.blockersByEventId.length, events.length);
  });

  test('propagates a dependency read error without partial state', () async {
    final project = _project();
    final event = _event('event-1');
    final repository = _ControlledScheduleRepository(
      eventsById: const <String, ScheduleEvent>{},
    );
    final notifications = _ControlledNotificationGateway();
    repository.listResult.complete(<ScheduleEvent>[event]);
    repository.listOpenResult.complete(const <ScheduleEvent>[]);
    repository.preferencesResult.complete(ReminderPreferences.defaults());
    notifications.permissionResult.complete(NotificationPermissionState.denied);
    final container = ProviderContainer(
      overrides: [
        projectsControllerProvider.overrideWithBuild(
          (ref, notifier) async => ProjectsState(
            projects: <Project>[project],
            selectedProject: project,
          ),
        ),
        scheduleRepositoryProvider.overrideWith((ref) async => repository),
        scheduleNotificationGatewayProvider.overrideWithValue(notifications),
        scheduleUtcNowProvider.overrideWithValue(
          () => DateTime.utc(2026, 8, 13, 8),
        ),
      ],
    );
    addTearDown(container.dispose);

    final loading = container.read(schedulePlanControllerProvider.future);
    final errorExpectation = expectLater(loading, throwsA(isA<StateError>()));
    await _flushEvents();

    repository.dependencyResults[event.id]!.completeError(
      StateError('dependency failed'),
    );
    await errorExpectation;
  });
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

Project _project() {
  final now = DateTime.utc(2026, 8, 13);
  return Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

ScheduleEvent _event(String id) => ScheduleEvent(
  id: id,
  projectId: 'project-1',
  title: id,
  kind: ScheduleEventKind.task,
  status: ScheduleEventStatus.planned,
  startsAt: DateTime.utc(2026, 8, 13, 10),
  timeZoneId: 'Etc/UTC',
  isAllDay: false,
  reminderEnabled: false,
  reminderLeadMinutes: 60,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

ScheduleDependency _dependency(
  String eventId,
  String blockingEventId, {
  required int minute,
}) => ScheduleDependency(
  eventId: eventId,
  blockingEventId: blockingEventId,
  createdAt: DateTime.utc(2026, 8, 1, 0, minute),
);

final class _ControlledScheduleRepository implements ScheduleRepository {
  _ControlledScheduleRepository({required this.eventsById});

  final Map<String, ScheduleEvent> eventsById;
  final Completer<List<ScheduleEvent>> listResult =
      Completer<List<ScheduleEvent>>();
  final Completer<List<ScheduleEvent>> listOpenResult =
      Completer<List<ScheduleEvent>>();
  final Completer<ReminderPreferences> preferencesResult =
      Completer<ReminderPreferences>();
  final Map<String, Completer<List<ScheduleDependency>>> dependencyResults =
      <String, Completer<List<ScheduleDependency>>>{};
  final Map<String, Completer<ScheduleEvent?>> findResults =
      <String, Completer<ScheduleEvent?>>{};
  final List<String> startedDependencyEventIds = <String>[];
  final Map<String, int> findCalls = <String, int>{};

  bool listStarted = false;
  bool listOpenStarted = false;
  bool preferencesStarted = false;

  @override
  Future<List<ScheduleEvent>> list({
    required String projectId,
    required ScheduleWindow window,
  }) {
    listStarted = true;
    return listResult.future;
  }

  @override
  Future<List<ScheduleEvent>> listOpen({required String projectId}) {
    listOpenStarted = true;
    return listOpenResult.future;
  }

  @override
  Future<ReminderPreferences> getReminderPreferences() {
    preferencesStarted = true;
    return preferencesResult.future;
  }

  @override
  Future<List<ScheduleDependency>> listDependencies({
    required String projectId,
    required String eventId,
  }) {
    startedDependencyEventIds.add(eventId);
    return (dependencyResults[eventId] ??=
            Completer<List<ScheduleDependency>>())
        .future;
  }

  @override
  Future<ScheduleEvent?> findById({
    required String projectId,
    required String eventId,
  }) {
    findCalls.update(eventId, (count) => count + 1, ifAbsent: () => 1);
    return (findResults[eventId] ??= Completer<ScheduleEvent?>()).future;
  }

  @override
  Future<ScheduleEvent> create({
    required String projectId,
    required ScheduleEventInput input,
  }) => throw UnimplementedError();

  @override
  Future<List<ScheduleDateChange>> listDateChanges({
    required String projectId,
    required String eventId,
  }) => throw UnimplementedError();

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

final class _ControlledNotificationGateway
    implements ScheduleNotificationGateway {
  final Completer<NotificationPermissionState> permissionResult =
      Completer<NotificationPermissionState>();

  bool permissionStarted = false;

  @override
  Future<NotificationPermissionState> permissionState() {
    permissionStarted = true;
    return permissionResult.future;
  }

  @override
  Future<String> currentTimeZoneId() async => 'Etc/UTC';

  @override
  DateTime fromWallTime(DateTime wallTime, String timeZoneId) => DateTime.utc(
    wallTime.year,
    wallTime.month,
    wallTime.day,
    wallTime.hour,
    wallTime.minute,
  );

  @override
  DateTime toTimeZone(DateTime instant, String timeZoneId) => instant.toUtc();

  @override
  Future<void> cancel(ScheduleEvent event) => throw UnimplementedError();

  @override
  Future<void> initialize(
    void Function(ScheduleNotificationTarget target) onOpen,
  ) => throw UnimplementedError();

  @override
  Future<NotificationPermissionState> requestPermission() =>
      throw UnimplementedError();

  @override
  Future<void> schedule(ScheduleNotificationRequest request) =>
      throw UnimplementedError();
}
