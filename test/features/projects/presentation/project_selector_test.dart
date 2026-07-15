import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/project_selector.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('selects a project by id from the bottom sheet', (tester) async {
    final house = _project('house-1', 'Dom');
    final flat = _project(
      'flat-1',
      'Mieszkanie',
      type: ProjectType.apartmentRenovation,
      template: ProjectTemplate.renovation,
    );
    final fake = FakeProjectRepository(
      projects: [house, flat],
      selectedProjectId: house.id,
    );

    await tester.pumpWidget(_testApp(fake));
    await tester.pumpAndSettle();

    expect(find.text('Dom'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('projectSelectorButton')));
    await tester.pumpAndSettle();

    expect(find.text('Wybierz projekt'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('projectSelectorItem-flat-1')));
    await tester.pumpAndSettle();

    expect((await fake.selected())?.id, 'flat-1');
    expect(find.text('Mieszkanie'), findsOneWidget);
  });

  testWidgets(
    'empty selector opens the new project route on a small viewport',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final fake = FakeProjectRepository();

      await tester.pumpWidget(_testApp(fake));
      await tester.pumpAndSettle();

      expect(find.text('Nowy projekt'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('projectSelectorNew')));
      await tester.pumpAndSettle();

      expect(find.text('FORM_ROUTE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('new action in the project sheet opens the form route', (
    tester,
  ) async {
    final house = _project('house-1', 'Dom');
    final fake = FakeProjectRepository(
      projects: [house],
      selectedProjectId: house.id,
    );

    await tester.pumpWidget(_testApp(fake));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('projectSelectorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('projectSelectorNew')));
    await tester.pumpAndSettle();

    expect(find.text('FORM_ROUTE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(FakeProjectRepository fake) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ProjectSelector(),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/projects/new',
        builder: (context, state) => const Scaffold(body: Text('FORM_ROUTE')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [projectRepositoryProvider.overrideWith((ref) async => fake)],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

Project _project(
  String id,
  String name, {
  ProjectType type = ProjectType.houseBuild,
  ProjectTemplate template = ProjectTemplate.houseConstruction,
}) {
  return Project(
    id: id,
    draft: ProjectDraft(name: name, type: type, template: template),
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 15),
  );
}
