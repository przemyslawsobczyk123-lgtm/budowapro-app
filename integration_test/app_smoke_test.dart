import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/app_test_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('creates a project and a cost in the real local app', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    // A fresh install opens on the first-run legal gate.
    await acceptLegalTermsThroughUi(
      tester,
      lookupAppLocalizations(const Locale('pl')),
    );
    await _waitFor(tester, find.text('Utwórz projekt'));

    await tester.tap(find.text('Utwórz projekt'));
    await _waitFor(tester, find.byKey(const ValueKey('projectNameField')));
    await tester.enterText(
      find.byKey(const ValueKey('projectNameField')),
      'Projekt smoke R1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('projectBudgetField')),
      '500000',
    );
    final projectSave = find.byKey(const ValueKey('projectFormSave'));
    await _revealAndTap(tester, projectSave);
    await _waitFor(tester, find.byKey(const ValueKey('dashboardEmptyProject')));

    expect(find.text('Projekt smoke R1'), findsWidgets);

    final addCost = find.text('Dodaj pierwszy koszt');
    await tester.ensureVisible(addCost);
    await tester.tap(addCost);
    await _waitFor(tester, find.byKey(const ValueKey('costNameField')));
    await tester.enterText(
      find.byKey(const ValueKey('costNameField')),
      'Przewod zasilajacy',
    );
    await tester.enterText(
      find.byKey(const ValueKey('costGrossField')),
      '349,90',
    );
    expect(
      find.byKey(const ValueKey('costComponent-material')),
      findsOneWidget,
    );
    final costSave = find.byKey(const ValueKey('costSave'));
    await _revealAndTap(tester, costSave);
    await _waitFor(tester, find.byType(NavigationDestination));

    await tester.tap(find.byType(NavigationDestination).at(2));
    await _waitFor(tester, find.text('Przewod zasilajacy'));

    expect(find.text('Przewod zasilajacy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _revealAndTap(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  await tester.pump(const Duration(seconds: 1));
  await tester.scrollUntilVisible(
    finder,
    280,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  if (finder.evaluate().isEmpty) {
    throw TestFailure(
      'Timed out waiting for ${finder.describeMatch(Plurality.one)}.',
    );
  }
}
