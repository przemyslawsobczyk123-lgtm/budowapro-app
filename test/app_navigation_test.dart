import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows five primary destinations and changes branch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Budżet'), findsOneWidget);
    expect(find.text('Budowa'), findsOneWidget);
    expect(find.text('Więcej'), findsOneWidget);
    expect(find.text('Centrum budowy'), findsOneWidget);

    const destinations = <String, String>{
      'Plan': 'Plan budowy',
      'Budżet': 'Budżet inwestycji',
      'Budowa': 'Dokumentacja budowy',
      'Więcej': 'Narzędzia projektu',
      'Start': 'Centrum budowy',
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

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
