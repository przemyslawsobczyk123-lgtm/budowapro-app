import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/features/stages/domain/stage_template.dart';
import 'package:budowapro/features/stages/presentation/stage_plan_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('renders the complete Stan 0 checklist and derived progress', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('stage-tab-state_zero')), findsOneWidget);
    expect(find.text('Stan zero'), findsWidgets);
    expect(find.text('0 z 18'), findsOneWidget);
    expect(find.text('Badania gruntu i warunki wodne'), findsOneWidget);
    expect(find.text('Wskazówki dla tego etapu'), findsOneWidget);
    expect(find.text('Lista kontrolna'), findsOneWidget);
    await tester.tap(find.text('Wskazówki dla tego etapu'));
    await tester.pumpAndSettle();
    expect(
      find.text('Przepusty i instalacje przed betonowaniem'),
      findsOneWidget,
    );
  });

  testWidgets('opens a technical recommendation with a safety boundary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wskazówki dla tego etapu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Uziom fundamentowy bez zgadywania'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uziom fundamentowy bez zgadywania'));
    await tester.pumpAndSettle();

    expect(find.text('To nie jest projekt wykonawczy'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sprawdź przed pracą'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Sprawdź przed pracą'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Pytania do fachowca'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Pytania do fachowca'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Źródła i podstawa'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Źródła i podstawa'), findsOneWidget);
  });

  testWidgets('switches to shell open informational guidance', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('stage-tab-shell_open')));
    await tester.pumpAndSettle();

    expect(find.text('Stan surowy otwarty'), findsWidgets);
    await tester.ensureVisible(find.text('Ten etap nie ma jeszcze checklisty'));
    await tester.pumpAndSettle();
    expect(find.text('Ten etap nie ma jeszcze checklisty'), findsOneWidget);
    await tester.ensureVisible(find.text('Wskazówki dla tego etapu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wskazówki dla tego etapu'));
    await tester.pumpAndSettle();
    expect(find.text('Detal nadproża pod rolety lub żaluzje'), findsOneWidget);
  });

  testWidgets('opens an existing checklist item from related guidance', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wskazówki dla tego etapu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Uziom fundamentowy bez zgadywania'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uziom fundamentowy bez zgadywania'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Powiązane punkty checklisty'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Bednarka i uziom fundamentowy').last);
    await tester.pumpAndSettle();

    expect(find.text('Szczegóły punktu'), findsOneWidget);
    expect(find.text('Bednarka i uziom fundamentowy'), findsOneWidget);
  });

  testWidgets('fits the stage plan on a compact Android viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('stage-plan-screen')), findsOneWidget);
  });

  testWidgets('fits guidance at 320 px with 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Wskazówki dla tego etapu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wskazówki dla tego etapu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('Przepusty i instalacje przed betonowaniem'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Przepusty i instalacje przed betonowaniem'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('To nie jest projekt wykonawczy'), findsOneWidget);
  });

  testWidgets('offers evidence or waiver when a required item is completed', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Badania gruntu i warunki wodne'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ChecklistStatus>).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zakończone').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Zapisz').last);
    await tester.pumpAndSettle();

    expect(find.text('Brakuje wymaganego dowodu'), findsOneWidget);
    expect(find.text('Dodaj dowód'), findsOneWidget);
    expect(find.text('Zapisz odstępstwo'), findsOneWidget);
  });
}

Widget _testApp({double textScale = 1}) {
  final project = _project();
  final projects = FakeProjectRepository(
    projects: <Project>[project],
    selectedProjectId: project.id,
  );
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith((ref) async => projects),
      stageRepositoryProvider.overrideWith(
        (ref) async => _FakeStageRepository(project.id),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: const StagePlanScreen(),
    ),
  );
}

Project _project() {
  return Project(
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
}

final class _FakeStageRepository implements StageRepository {
  _FakeStageRepository(this.projectId) {
    final now = DateTime.utc(2026, 7, 20);
    final definitions = StageTemplateCatalog.forProject(
      ProjectTemplate.houseConstruction,
    );
    stages = definitions.indexed
        .map(
          (entry) => ProjectStage(
            id: _stageId(entry.$2.stageKey),
            projectId: projectId,
            templateKey: entry.$2.stageKey,
            status: entry.$2.stageKey == ProjectStageKey.formalities
                ? StageStatus.completed
                : StageStatus.planned,
            sortOrder: entry.$1,
            progress: StageProgress.fromStatuses(
              entry.$2.checklistItems.map((item) => ChecklistStatus.todo),
            ),
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);
    itemsByStage = <String, List<ChecklistItem>>{
      for (final definition in definitions)
        _stageId(definition.stageKey): definition.checklistItems.indexed
            .map(
              (entry) => ChecklistItem(
                id: 'item-${entry.$2.key.name}',
                projectId: projectId,
                stageId: _stageId(definition.stageKey),
                templateKey: entry.$2.key,
                status: ChecklistStatus.todo,
                importance: entry.$2.importance,
                evidenceRequirement: entry.$2.evidenceRequirement,
                evidenceIds: const <String>[],
                sortOrder: entry.$1,
                createdAt: now,
                updatedAt: now,
              ),
            )
            .toList(growable: false),
    };
  }

  final String projectId;
  late final List<ProjectStage> stages;
  late final Map<String, List<ChecklistItem>> itemsByStage;

  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) async => stages;

  @override
  Future<List<ChecklistItem>> listChecklistItems({
    required String projectId,
    required String stageId,
  }) async => itemsByStage[stageId] ?? const <ChecklistItem>[];

  @override
  Future<List<ChecklistItem>> listProjectChecklistItems({
    required String projectId,
  }) async => itemsByStage.values.expand((items) => items).toList();

  @override
  Future<ChecklistItem> updateChecklistItem({
    required String projectId,
    required String checklistItemId,
    required ChecklistItemDetailsInput input,
  }) async {
    final item = itemsByStage.values
        .expand((items) => items)
        .singleWhere((item) => item.id == checklistItemId);
    validateChecklistResolution(
      status: input.status,
      evidenceRequirement: input.evidenceRequirement,
      evidenceCount: item.evidenceIds.length,
      statusReason: input.statusReason,
      evidenceWaiverComment: input.evidenceWaiverComment,
    );
    return item;
  }

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
}

String _stageId(ProjectStageKey key) => switch (key) {
  ProjectStageKey.planning => 'planning',
  ProjectStageKey.formalities => 'formalities',
  ProjectStageKey.stateZero => 'state_zero',
  ProjectStageKey.shellOpen => 'shell_open',
  ProjectStageKey.shellClosed => 'shell_closed',
  ProjectStageKey.demolition => 'demolition',
  ProjectStageKey.installations => 'installations',
  ProjectStageKey.plaster => 'plaster',
  ProjectStageKey.finishing => 'finishing',
  ProjectStageKey.handover => 'handover',
};
