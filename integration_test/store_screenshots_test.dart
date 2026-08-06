import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('captures Google Play screenshots with fictional data', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await _waitFor(tester, find.text('Utwórz projekt'));

    await tester.tap(find.text('Utwórz projekt'));
    await _waitFor(tester, find.byKey(const ValueKey('projectNameField')));
    await tester.enterText(
      find.byKey(const ValueKey('projectNameField')),
      'Dom rodzinny - projekt testowy',
    );
    await tester.enterText(
      find.byKey(const ValueKey('projectBudgetField')),
      '750000',
    );
    await _revealAndTap(tester, find.byKey(const ValueKey('projectFormSave')));
    await _waitFor(tester, find.byKey(const ValueKey('dashboardEmptyProject')));

    await tester.tap(find.text('Dodaj pierwszy koszt'));
    await _waitFor(tester, find.byKey(const ValueKey('costNameField')));
    await tester.enterText(
      find.byKey(const ValueKey('costNameField')),
      'Materiały fundamentowe',
    );
    await tester.enterText(
      find.byKey(const ValueKey('costGrossField')),
      '48500',
    );
    await _revealAndTap(tester, find.byKey(const ValueKey('costSave')));
    await _waitFor(tester, find.byType(NavigationDestination));

    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(seconds: 1));

    await _openSection(tester, 0);
    await _waitFor(tester, find.byKey(const ValueKey('dashboardContent')));
    await _capture(binding, tester, '01-dashboard');

    await _openSection(tester, 2);
    await _waitFor(tester, find.text('Materiały fundamentowe'));
    await _capture(binding, tester, '02-budget');

    await _openSection(tester, 3);
    await _waitFor(tester, find.byKey(const ValueKey('stage-plan-screen')));
    await _capture(binding, tester, '03-stages');

    await _openSection(tester, 4);
    await _waitFor(tester, find.byKey(const ValueKey('moreCapturesTile')));
    await _capture(binding, tester, '04-more');

    expect(tester.takeException(), isNull);
  });
}

Future<void> _openSection(WidgetTester tester, int index) async {
  final navigationBar = tester.getRect(find.byType(NavigationBar));
  final segmentWidth = navigationBar.width / 5;
  await tester.tapAt(
    Offset(
      navigationBar.left + segmentWidth * (index + 0.5),
      navigationBar.center.dy,
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 500));
  final bytes = await binding.takeScreenshot(name);
  expect(bytes, isNotEmpty);
}

Future<void> _revealAndTap(WidgetTester tester, Finder finder) async {
  await tester.pump(const Duration(seconds: 1));
  FocusManager.instance.primaryFocus?.unfocus();
  for (var attempt = 0; attempt < 4; attempt++) {
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await tester.pump(const Duration(milliseconds: 500));
  }
  await tester.pump(const Duration(seconds: 1));
  await tester.scrollUntilVisible(
    finder,
    280,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.ensureVisible(finder);
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
