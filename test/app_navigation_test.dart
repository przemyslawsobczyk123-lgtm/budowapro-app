import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_project_repository.dart';

void main() {
  testWidgets('shows five primary destinations and changes branch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Budżet'), findsOneWidget);
    expect(find.text('Budowa'), findsOneWidget);
    expect(find.text('Więcej'), findsOneWidget);
    expect(find.text('Brak aktywnego projektu'), findsOneWidget);

    const destinations = <String, String>{
      'Plan': 'Plan budowy',
      'Budżet': 'Budżet inwestycji',
      'Budowa': 'Dokumentacja budowy',
      'Więcej': 'Narzędzia projektu',
      'Start': 'Brak aktywnego projektu',
    };

    for (final entry in destinations.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('fits navigation on a compact Android viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('opens the new project form from the empty start screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Utwórz projekt'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy projekt'), findsOneWidget);
    expect(find.text('Podstawowe dane'), findsOneWidget);
  });
}

Widget _testApp() {
  final repository = FakeProjectRepository();
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith((ref) async => repository),
    ],
    child: const MainApp(),
  );
}
