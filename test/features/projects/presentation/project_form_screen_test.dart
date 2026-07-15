import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/project_form_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('validates the name and parses budget text into minor units', (
    tester,
  ) async {
    final fake = FakeProjectRepository();
    await tester.pumpWidget(_testApp(fake, const ProjectFormScreen()));
    await tester.pumpAndSettle();

    await _tapSave(tester);
    await tester.pump();

    expect(find.text('Podaj nazwę projektu.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('projectNameField')),
      'Dom przy lesie',
    );
    await tester.enterText(
      find.byKey(const ValueKey('projectAreaField')),
      '132',
    );
    await tester.enterText(
      find.byKey(const ValueKey('projectBudgetField')),
      '12 345,67',
    );
    await _tapSave(tester);
    await tester.pumpAndSettle();

    final saved = await fake.selected();
    expect(saved?.name, 'Dom przy lesie');
    expect(saved?.areaSquareMeters, 132);
    expect(saved?.plannedBudgetMinorUnits, 1234567);
    expect(saved?.currencyCode, 'PLN');
    expect(saved?.template, ProjectTemplate.houseConstruction);
  });

  testWidgets('loads an existing project and updates it by project id', (
    tester,
  ) async {
    final project = _project(
      id: 'house-1',
      name: 'Dom testowy',
      location: 'Poznań',
      budgetMinorUnits: 85000000,
    );
    final fake = FakeProjectRepository(
      projects: [project],
      selectedProjectId: project.id,
    );

    await tester.pumpWidget(
      _testApp(fake, ProjectFormScreen(projectId: project.id)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edytuj projekt'), findsOneWidget);
    expect(find.text('Poznań'), findsOneWidget);
    expect(find.text('850 000,00'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('projectNameField')),
      'Dom po zmianie',
    );
    await _tapSave(tester);
    await tester.pumpAndSettle();

    final updated = await fake.findById(project.id);
    expect(updated?.name, 'Dom po zmianie');
    expect(updated?.locationLabel, 'Poznań');
    expect(updated?.plannedBudgetMinorUnits, 85000000);
  });

  testWidgets('confirms before discarding an edited form', (tester) async {
    final fake = FakeProjectRepository();
    await tester.pumpWidget(_testAppWithBackRoute(fake));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('projectNameField')),
      'Niezapisany dom',
    );
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Niezapisane zmiany'), findsOneWidget);
    await tester.tap(find.text('Anuluj'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Odrzuć zmiany'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormScreen), findsNothing);
    expect(find.text('Poprzedni ekran'), findsOneWidget);
  });
}

Future<void> _tapSave(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('projectFormSave'));
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
  await tester.pumpAndSettle();
  await tester.tap(button);
}

Widget _testApp(FakeProjectRepository fake, Widget home) {
  return ProviderScope(
    overrides: [projectRepositoryProvider.overrideWith((ref) async => fake)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: home,
    ),
  );
}

Widget _testAppWithBackRoute(FakeProjectRepository fake) {
  return ProviderScope(
    overrides: [projectRepositoryProvider.overrideWith((ref) async => fake)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      initialRoute: '/project/new',
      routes: {
        '/': (context) => const Scaffold(body: Text('Poprzedni ekran')),
        '/project/new': (context) => const ProjectFormScreen(),
      },
    ),
  );
}

Project _project({
  required String id,
  required String name,
  String? location,
  int? budgetMinorUnits,
}) {
  return Project(
    id: id,
    draft: ProjectDraft(
      name: name,
      locationLabel: location,
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      plannedBudgetMinorUnits: budgetMinorUnits,
      plannedStart: DateTime.utc(2026, 7, 15),
      plannedEnd: DateTime.utc(2026, 12, 31),
      currentStage: ProjectStageKey.stateZero,
    ),
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 15),
  );
}
