import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/project_overview_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('shows selected project details in a compact overview', (
    tester,
  ) async {
    final project = _project();
    final fake = FakeProjectRepository(
      projects: [project],
      selectedProjectId: project.id,
    );

    await tester.pumpWidget(_testApp(fake));
    await tester.pumpAndSettle();

    expect(find.text('Dom przy lesie'), findsOneWidget);
    expect(find.text('Stan zero'), findsOneWidget);
    expect(find.text('Budowa domu'), findsOneWidget);
    expect(find.text('Wrocław'), findsOneWidget);
    expect(find.text('850 000,00 PLN'), findsOneWidget);
    expect(find.text('15.07.2026 – 31.12.2026'), findsOneWidget);
  });

  testWidgets('loads deletion impact and deletes only after confirmation', (
    tester,
  ) async {
    final project = _project();
    final fake = FakeProjectRepository(
      projects: [project],
      selectedProjectId: project.id,
      linkedFileCounts: {project.id: 3},
      linkedRecordCounts: {project.id: 7},
    );

    await tester.pumpWidget(_testApp(fake));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('projectDelete')));
    await tester.pumpAndSettle();

    expect(find.text('Usunąć projekt „Dom przy lesie”?'), findsOneWidget);
    expect(find.text('Powiązane pliki: 3'), findsOneWidget);
    expect(find.text('Powiązane rekordy: 7'), findsOneWidget);
    expect(fake.deleteCallCount, 0);

    await tester.tap(find.byKey(const ValueKey('projectDeleteCancel')));
    await tester.pumpAndSettle();
    expect(fake.deleteCallCount, 0);

    await tester.tap(find.byKey(const ValueKey('projectDelete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('projectDeleteConfirm')));
    await tester.pumpAndSettle();

    expect(fake.deleteCallCount, 1);
    expect(find.text('Utwórz projekt'), findsOneWidget);
  });
}

Widget _testApp(FakeProjectRepository fake) {
  return ProviderScope(
    overrides: [projectRepositoryProvider.overrideWith((ref) async => fake)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: const ProjectOverviewScreen(),
    ),
  );
}

Project _project() {
  return Project(
    id: 'house-1',
    draft: ProjectDraft(
      name: 'Dom przy lesie',
      locationLabel: 'Wrocław',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currencyCode: 'PLN',
      areaSquareMeters: 132,
      plannedBudgetMinorUnits: 85000000,
      plannedStart: DateTime.utc(2026, 7, 15),
      plannedEnd: DateTime.utc(2026, 12, 31),
      currentStage: ProjectStageKey.stateZero,
    ),
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 15),
  );
}
