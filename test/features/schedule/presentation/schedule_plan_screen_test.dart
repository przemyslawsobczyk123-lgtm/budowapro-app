import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_screen.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_project_repository.dart';
import '../../../helpers/fake_schedule_services.dart';

void main() {
  testWidgets('shows a blocked seven-day event and opens its source route', (
    tester,
  ) async {
    final services = _services();
    await tester.pumpWidget(_testApp(services));
    await tester.pumpAndSettle();

    expect(find.text('7 dni'), findsOneWidget);
    expect(find.text('Odbiór zbrojenia'), findsOneWidget);
    expect(find.text('Blokuje: Decyzja o przepuście'), findsOneWidget);
    expect(find.text('Przypomnienia są wyłączone'), findsOneWidget);

    await tester.tap(find.text('Odbiór zbrojenia'));
    await tester.pumpAndSettle();

    expect(find.text('source:event-1'), findsOneWidget);
  });

  testWidgets('fits the complete agenda on a 320 px viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_services()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('scheduleAgenda')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('scheduleAddEventButton')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Ustawienia przypomnień'));
    await tester.pumpAndSettle();

    expect(find.text('Typy terminów'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

({
  Project project,
  FakeScheduleRepository repository,
  FakeScheduleNotificationGateway notifications,
})
_services() {
  final project = Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currentStage: ProjectStageKey.stateZero,
    ),
    createdAt: DateTime.utc(2026, 7, 20),
    updatedAt: DateTime.utc(2026, 7, 20),
  );
  final blocker = _event(
    id: 'blocker-1',
    title: 'Decyzja o przepuście',
    startsAt: DateTime.utc(2026, 7, 19, 8),
  );
  final event = _event(
    id: 'event-1',
    title: 'Odbiór zbrojenia',
    startsAt: DateTime.utc(2026, 7, 20, 6, 30),
    kind: ScheduleEventKind.acceptance,
  );
  return (
    project: project,
    repository: FakeScheduleRepository(
      events: <ScheduleEvent>[blocker, event],
      dependencies: <String, List<ScheduleDependency>>{
        event.id: <ScheduleDependency>[
          ScheduleDependency(
            eventId: event.id,
            blockingEventId: blocker.id,
            decisionDueAt: DateTime.utc(2026, 7, 20, 10),
            createdAt: DateTime.utc(2026, 7, 18),
          ),
        ],
      },
    ),
    notifications: FakeScheduleNotificationGateway(
      permission: NotificationPermissionState.denied,
    ),
  );
}

Widget _testApp(
  ({
    Project project,
    FakeScheduleRepository repository,
    FakeScheduleNotificationGateway notifications,
  })
  services,
) {
  final projects = FakeProjectRepository(
    projects: <Project>[services.project],
    selectedProjectId: services.project.id,
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SchedulePlanScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/:eventId',
        builder: (context, state) =>
            Scaffold(body: Text('source:${state.pathParameters['eventId']}')),
      ),
    ],
  );
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith((ref) async => projects),
      scheduleRepositoryProvider.overrideWith(
        (ref) async => services.repository,
      ),
      scheduleNotificationGatewayProvider.overrideWithValue(
        services.notifications,
      ),
      scheduleUtcNowProvider.overrideWithValue(
        () => DateTime.utc(2026, 7, 20, 5),
      ),
      stageRepositoryProvider.overrideWith((ref) async => _EmptyStages()),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

ScheduleEvent _event({
  required String id,
  required String title,
  required DateTime startsAt,
  ScheduleEventKind kind = ScheduleEventKind.task,
}) => ScheduleEvent(
  id: id,
  projectId: 'project-1',
  title: title,
  kind: kind,
  status: ScheduleEventStatus.planned,
  startsAt: startsAt,
  timeZoneId: 'Europe/Warsaw',
  isAllDay: false,
  reminderEnabled: true,
  reminderLeadMinutes: 60,
  createdAt: DateTime.utc(2026, 7, 18),
  updatedAt: DateTime.utc(2026, 7, 18),
);

final class _EmptyStages implements StageRepository {
  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) async => const <ProjectStage>[];

  @override
  Future<List<ChecklistItem>> listChecklistItems({
    required String projectId,
    required String stageId,
  }) async => const <ChecklistItem>[];

  @override
  Future<ProjectStage> addCustomStage({
    required String projectId,
    required String name,
  }) => throw UnimplementedError();
  @override
  Future<ChecklistItem> addChecklistItem({
    required String projectId,
    required String stageId,
    required String title,
    required ChecklistItemDetailsInput input,
  }) => throw UnimplementedError();
  @override
  Future<ChecklistItem> attachEvidence({
    required String projectId,
    required String checklistItemId,
    required String attachmentId,
  }) => throw UnimplementedError();
  @override
  Future<ChecklistItem> detachEvidence({
    required String projectId,
    required String checklistItemId,
    required String attachmentId,
  }) => throw UnimplementedError();
  @override
  Future<void> reorderStages({
    required String projectId,
    required List<String> stageIds,
  }) => throw UnimplementedError();
  @override
  Future<ProjectStage> renameStage({
    required String projectId,
    required String stageId,
    required String name,
  }) => throw UnimplementedError();
  @override
  Future<ProjectStage> updateStage({
    required String projectId,
    required String stageId,
    required StageDetailsInput input,
  }) => throw UnimplementedError();
  @override
  Future<ChecklistItem> updateChecklistItem({
    required String projectId,
    required String checklistItemId,
    required ChecklistItemDetailsInput input,
  }) => throw UnimplementedError();
}
