import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_editor_dialogs.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates an own checklist position with practical details', (
    tester,
  ) async {
    NewChecklistItemInput? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showAddChecklistDialog(context);
              },
              child: const Text('Otwórz'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otwórz'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(0), 'Sprawdź przepust do ogrodu');
    await tester.enterText(fields.at(1), 'Elektryk');
    await tester.enterText(
      fields.at(2),
      'Potwierdzić średnicę i zakończenia z obu stron.',
    );
    await tester.enterText(
      fields.at(3),
      'Później trzeba będzie rozebrać podjazd.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Zapisz'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.title, 'Sprawdź przepust do ogrodu');
    expect(result!.details.status, ChecklistStatus.todo);
    expect(result!.details.assignee, 'Elektryk');
    expect(
      result!.details.note,
      'Potwierdzić średnicę i zakończenia z obu stron.',
    );
    expect(
      result!.details.riskIfSkipped,
      'Później trzeba będzie rozebrać podjazd.',
    );
  });

  testWidgets(
    'shows the complete template risk without persisting it as an override',
    (tester) async {
      ChecklistItemDetailsInput? result;
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await showChecklistEditorSheet(
                    context,
                    project: _project(),
                    item: _designMapItem(),
                  );
                },
                child: const Text('Otwórz'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Otwórz'));
      await tester.pumpAndSettle();

      const templateRisk =
          'Nieaktualna lub nieprawidłowa mapa może pominąć uzbrojenie '
          'i wymusić korektę projektu.';
      expect(find.text(templateRisk), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Zapisz'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Zapisz'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.riskIfSkipped, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preserves and clears an own template risk override', (
    tester,
  ) async {
    ChecklistItemDetailsInput? result;
    const customRisk = 'Własny opis ryzyka inwestora.';

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showChecklistEditorSheet(
                  context,
                  project: _project(),
                  item: _designMapItem(riskIfSkipped: customRisk),
                );
              },
              child: const Text('Otwórz'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otwórz'));
    await tester.pumpAndSettle();
    expect(find.text(customRisk), findsOneWidget);

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Zapisz'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Zapisz'));
    await tester.pumpAndSettle();
    expect(result?.riskIfSkipped, customRisk);

    result = null;
    await tester.tap(find.text('Otwórz'));
    await tester.pumpAndSettle();
    final ownRiskField = find.widgetWithText(
      TextFormField,
      'Własny opis ryzyka',
    );
    expect(ownRiskField, findsOneWidget);
    await tester.enterText(ownRiskField, '');
    expect(
      tester.widget<TextFormField>(ownRiskField).controller?.text,
      isEmpty,
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Zapisz'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Zapisz'));
    await tester.pumpAndSettle();
    expect(result?.riskIfSkipped, isNull);
  });

  testWidgets('keeps the stage save action above the keyboard', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showStageEditorSheet(
                context,
                project: _project(),
                stage: _stage(),
              ),
              child: const Text('Otwórz'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otwórz'));
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const ValueKey('editorSheetSaveButton'));
    expect(saveButton, findsOneWidget);
    expect(tester.getBottomLeft(saveButton).dy, lessThanOrEqualTo(440));
    expect(tester.takeException(), isNull);
  });
}

Project _project() {
  final now = DateTime.utc(2026, 7, 26);
  return Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currentStage: ProjectStageKey.formalities,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

ChecklistItem _designMapItem({String? riskIfSkipped}) {
  final now = DateTime.utc(2026, 7, 26);
  return ChecklistItem(
    id: 'item-design-map',
    projectId: 'project-1',
    stageId: 'stage-formalities',
    templateKey: ChecklistTemplateKey.designMap,
    status: ChecklistStatus.todo,
    importance: ChecklistImportance.high,
    evidenceRequirement: EvidenceRequirement.anyAttachment,
    riskIfSkipped: riskIfSkipped,
    evidenceIds: const <String>[],
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

ProjectStage _stage() {
  final now = DateTime.utc(2026, 7, 26);
  return ProjectStage(
    id: 'stage-formalities',
    projectId: 'project-1',
    templateKey: ProjectStageKey.formalities,
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
}
