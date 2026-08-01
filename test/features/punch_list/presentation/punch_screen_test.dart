import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/presentation/punch_controller.dart';
import 'package:budowapro/features/punch_list/presentation/punch_screen.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('punch list fits a 320 px phone and shows risk counters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(_state()));
    await tester.pumpAndSettle();

    expect(find.text('Usterki i odbiory'), findsOneWidget);
    expect(find.text('Otwarte'), findsOneWidget);
    expect(find.text('Krytyczne'), findsOneWidget);
    expect(find.text('Po terminie'), findsOneWidget);
    expect(find.text('Nieszczelne przejście instalacyjne'), findsOneWidget);
    expect(find.byKey(const ValueKey('punchAddButton')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('punch list remains usable at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(_state(), textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('punchSearchField')), findsOneWidget);
    expect(find.text('Nieszczelne przejście instalacyjne'), findsOneWidget);
    expect(find.byKey(const ValueKey('punchAddButton')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(PunchState state, {TextScaler textScaler = TextScaler.noScaling}) {
  return ProviderScope(
    overrides: [
      punchControllerProvider.overrideWithBuild((ref, notifier) async => state),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const PunchScreen(),
    ),
  );
}

PunchState _state() {
  final now = DateTime.utc(2026, 7, 31, 10);
  final project = Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    ),
    createdAt: now,
    updatedAt: now,
  );
  final stage = ProjectStage(
    id: 'state-zero',
    projectId: project.id,
    templateKey: ProjectStageKey.stateZero,
    status: StageStatus.inProgress,
    sortOrder: 0,
    progress: StageProgress.fromCounts(
      totalItems: 1,
      completedItems: 0,
      skippedItems: 0,
      blockedItems: 0,
    ),
    createdAt: now,
    updatedAt: now,
  );
  final defect = DefectRecord(
    entry: JournalEntry(
      id: 'defect-1',
      input: JournalEntryInput(
        projectId: project.id,
        type: JournalEntryType.defect,
        title: 'Nieszczelne przejście instalacyjne',
        occurredAt: now,
        status: JournalEntryStatus.open,
        stageId: stage.id,
        roomLabel: 'Kotłownia',
        defectSeverity: DefectSeverity.critical,
        dueAt: now.subtract(const Duration(days: 1)),
      ),
      createdAt: now,
      updatedAt: now,
      revision: 1,
    ),
  );
  final protocol = AcceptanceProtocol(
    id: 'protocol-1',
    input: AcceptanceProtocolInput(
      projectId: project.id,
      title: 'Odbiór poprawki instalacyjnej',
      inspectedAt: now,
      defectIds: const <String>['defect-1'],
    ),
    createdAt: now,
    updatedAt: now,
  );
  return PunchState(
    project: project,
    stages: <ProjectStage>[stage],
    contacts: const [],
    defects: <DefectRecord>[defect],
    protocols: <AcceptanceProtocol>[protocol],
    summary: PunchSummary(openCount: 1, criticalCount: 1, overdueCount: 1),
    filters: const PunchFilters(),
    defectTotalCount: 1,
    protocolTotalCount: 1,
  );
}
