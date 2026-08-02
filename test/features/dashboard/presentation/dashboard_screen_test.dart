import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/dashboard/data/dashboard_providers.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_reader.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:budowapro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../helpers/fake_project_repository.dart';
import '../../../helpers/fake_schedule_services.dart';

void main() {
  testWidgets('shows a dedicated no-project state', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dashboardNoProject')), findsOneWidget);
    expect(find.text('Brak aktywnego projektu'), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboardContent')), findsNothing);
  });

  testWidgets('shows a dedicated fresh-project state', (tester) async {
    final project = _project();
    await tester.pumpWidget(
      _testApp(project: project, snapshot: _emptySnapshot(project)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dashboardEmptyProject')), findsOneWidget);
    expect(find.text('Projekt gotowy do uzupełnienia'), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboardContent')), findsNothing);
  });

  testWidgets('keeps populated dashboard stable without a project budget', (
    tester,
  ) async {
    final project = _project(withBudget: false);
    await tester.pumpWidget(
      _testApp(project: project, snapshot: _populatedSnapshot(project)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Uzupełnij budżet projektu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens receipt scanning from project quick actions', (
    tester,
  ) async {
    final project = _project();
    await tester.pumpWidget(
      _testApp(project: project, snapshot: _emptySnapshot(project)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Skanuj paragon'));
    await tester.tap(find.text('Skanuj paragon'));
    await tester.pumpAndSettle();

    expect(find.text('receipt-scan:project-1'), findsOneWidget);
  });

  testWidgets('opens technical stage photos from project quick actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final project = _project();
    await tester.pumpWidget(
      _testApp(project: project, snapshot: _emptySnapshot(project)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zdjęcia etapów'));
    await tester.pumpAndSettle();

    expect(find.text('technical-photos'), findsOneWidget);
  });

  testWidgets('opens the separate stages section from quick actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final project = _project();
    await tester.pumpWidget(
      _testApp(project: project, snapshot: _emptySnapshot(project)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Checklisty etapów'));
    await tester.tap(find.text('Checklisty etapów'));
    await tester.pumpAndSettle();

    expect(find.text('stages'), findsOneWidget);
  });

  testWidgets('uses matching line icons for project quick actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final project = _project();
    await tester.pumpWidget(
      _testApp(project: project, snapshot: _emptySnapshot(project)),
    );
    await tester.pumpAndSettle();

    const expected = <String, IconData>{
      'quickActionAddCost': LucideIcons.walletCards300,
      'quickActionScanReceipt': LucideIcons.receiptText300,
      'quickActionStages': LucideIcons.listChecks300,
      'quickActionSchedule': LucideIcons.calendarPlus300,
      'quickActionDefect': LucideIcons.wrench300,
      'quickActionPhotos': LucideIcons.images300,
    };

    for (final entry in expected.entries) {
      final action = find.byKey(ValueKey(entry.key));
      expect(action, findsOneWidget);
      final baseIcon = tester.widget<Icon>(
        find.descendant(of: action, matching: find.byType(Icon)).first,
      );
      expect(baseIcon.icon, entry.value, reason: entry.key);
    }
  });

  testWidgets('fits populated dashboard at 320 px and opens agenda source', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final project = _project();
    await tester.pumpWidget(
      _testApp(project: project, snapshot: _populatedSnapshot(project)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dashboardContent')), findsOneWidget);
    expect(find.text('86 420,00 zł'), findsWidgets);
    expect(find.text('Plan 30 dni'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('dashboardCaptureInbox')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Otwarte (2)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bednarka fundamentowa'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Bednarka fundamentowa'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Odbiór zbrojenia'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Odbiór zbrojenia'));
    await tester.pumpAndSettle();

    expect(find.text('source:event-1'), findsOneWidget);
  });
}

Widget _testApp({Project? project, DashboardSnapshot? snapshot}) {
  final projects = FakeProjectRepository(
    projects: project == null ? const [] : [project],
    selectedProjectId: project?.id,
  );
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(
        path: '/projects/new',
        builder: (context, state) => const Scaffold(body: Text('new-project')),
      ),
      GoRoute(
        path: '/projects/:projectId/edit',
        builder: (context, state) => const Scaffold(body: Text('edit-project')),
      ),
      GoRoute(
        path: '/projects/:projectId/costs/new',
        builder: (context, state) => const Scaffold(body: Text('new-cost')),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/new',
        builder: (context, state) => const Scaffold(body: Text('new-event')),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/:eventId',
        builder: (context, state) =>
            Scaffold(body: Text('source:${state.pathParameters['eventId']}')),
      ),
      GoRoute(
        path: '/projects/:projectId/receipt-scans/new',
        builder: (context, state) => Scaffold(
          body: Text('receipt-scan:${state.pathParameters['projectId']}'),
        ),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => const Scaffold(body: Text('budget')),
      ),
      GoRoute(
        path: '/plan',
        builder: (context, state) => const Scaffold(body: Text('plan')),
      ),
      GoRoute(
        path: '/stages',
        builder: (context, state) => const Scaffold(body: Text('stages')),
      ),
      GoRoute(
        path: '/technical',
        builder: (context, state) =>
            const Scaffold(body: Text('technical-photos')),
      ),
    ],
  );
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith((ref) async => projects),
      dashboardReaderProvider.overrideWith(
        (ref) async => _FakeDashboardReader(snapshot),
      ),
      scheduleNotificationGatewayProvider.overrideWithValue(
        FakeScheduleNotificationGateway(),
      ),
      scheduleUtcNowProvider.overrideWithValue(
        () => DateTime.utc(2026, 7, 21, 10),
      ),
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

final class _FakeDashboardReader implements DashboardReader {
  const _FakeDashboardReader(this.snapshot);

  final DashboardSnapshot? snapshot;

  @override
  Future<DashboardSnapshot> load({
    required Project project,
    required DashboardWindow window,
  }) async => snapshot!;
}

Project _project({bool withBudget = true}) => Project(
  id: 'project-1',
  draft: ProjectDraft(
    name: 'Dom testowy',
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
    currentStage: ProjectStageKey.stateZero,
    plannedBudgetMinorUnits: withBudget ? 42000000 : null,
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

DashboardSnapshot _emptySnapshot(Project project) {
  final zero = Money.zero(project.currencyCode);
  return DashboardSnapshot(
    project: project,
    stages: [_stage()],
    checklistItems: const [],
    todayAgenda: const [],
    spent: zero,
    plannedNext30Days: zero,
    unpaid: zero,
    unpaidCount: 0,
    costRecordCount: 0,
    openScheduleCount: 0,
  );
}

DashboardSnapshot _populatedSnapshot(Project project) {
  final stage = _stage(status: StageStatus.inProgress);
  final checklist = ChecklistItem(
    id: 'grounding',
    projectId: project.id,
    stageId: stage.id,
    customTitle: 'Bednarka fundamentowa',
    status: ChecklistStatus.inProgress,
    importance: ChecklistImportance.critical,
    evidenceRequirement: EvidenceRequirement.photo,
    evidenceIds: const [],
    sortOrder: 0,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    riskIfSkipped: 'Brak pewnego uziemienia po zalaniu fundamentu.',
  );
  final event = ScheduleEvent(
    id: 'event-1',
    projectId: project.id,
    title: 'Odbiór zbrojenia',
    kind: ScheduleEventKind.acceptance,
    status: ScheduleEventStatus.planned,
    startsAt: DateTime.utc(2026, 7, 21, 8),
    timeZoneId: 'Europe/Warsaw',
    isAllDay: false,
    reminderEnabled: false,
    reminderLeadMinutes: 60,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  return DashboardSnapshot(
    project: project,
    stages: [stage],
    checklistItems: [DashboardChecklistRecord(stage: stage, item: checklist)],
    todayAgenda: [event],
    spent: Money(minorUnits: 8642000, currencyCode: 'PLN'),
    plannedNext30Days: Money(minorUnits: 4870000, currencyCode: 'PLN'),
    unpaid: Money(minorUnits: 475000, currencyCode: 'PLN'),
    unpaidCount: 3,
    costRecordCount: 4,
    openScheduleCount: 1,
    openCaptureCount: 2,
  );
}

ProjectStage _stage({StageStatus status = StageStatus.planned}) => ProjectStage(
  id: 'state_zero',
  projectId: 'project-1',
  templateKey: ProjectStageKey.stateZero,
  status: status,
  sortOrder: 0,
  progress: StageProgress.fromCounts(
    totalItems: 1,
    completedItems: 0,
    skippedItems: 0,
    blockedItems: 0,
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
