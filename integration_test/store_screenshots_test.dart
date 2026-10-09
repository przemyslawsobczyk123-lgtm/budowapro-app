import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdfrx/pdfrx.dart';

import 'store_demo_seed.dart';
import 'support/app_test_support.dart';
import 'support/host_capture_bridge.dart';

/// Captures the Google Play screenshots from the real app on an emulator.
///
/// Run it only through the host driver, which takes the device screenshots:
///
///   STORE_SHOTS_DEVICE=emulator-5560 STORE_SHOTS_OUT=build/store_screenshots \
///   flutter drive -d emulator-5560 \
///     --driver=test_driver/store_screenshots_driver.dart \
///     --target=integration_test/store_screenshots_test.dart
///
/// The app must be freshly installed: the test seeds one fictional project
/// through the app repositories, then accepts the legal gate in the UI.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  final host = HostCaptureBridge.register();

  testWidgets('captures Google Play screenshots with fictional data', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('pl'));
    await host.request(tester, HostCaptureBridge.setupRequest);

    await pdfrxFlutterInitialize();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final demo = await seedStoreDemoProject(container);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await acceptLegalTermsThroughUi(tester, l10n);

    // Start: project overview.
    await waitForFinder(tester, find.byKey(const ValueKey('dashboardContent')));
    await _capture(tester, host, 'start');

    final dashboardScroll = find.descendant(
      of: find.byKey(const ValueKey('dashboardContent')),
      matching: find.byType(Scrollable),
    );
    await _revealInScrollable(
      tester,
      find.text(l10n.dashboardCritical),
      dashboardScroll.first,
    );
    await _capture(tester, host, 'start-sekcje');

    // Budget register with the material / labour split.
    await _openSection(tester, l10n.navBudget);
    await waitForFinder(
      tester,
      find.byKey(const ValueKey('costRegisterScroll')),
    );
    await waitForFinder(tester, find.text(l10n.costRegisterComponentSection));
    await waitForAbsence(
      tester,
      find.byKey(const ValueKey('costRegisterReloadProgress')),
    );
    await _capture(tester, host, 'budzet');
    await _revealInScrollable(
      tester,
      find.text(l10n.costRegisterComponentSection),
      find
          .descendant(
            of: find.byKey(const ValueKey('costRegisterScroll')),
            matching: find.byType(Scrollable),
          )
          .first,
      alignment: 0.05,
    );
    await _capture(tester, host, 'budzet-lista');

    // Project tools (pushed routes). They come before Plan and Etapy: once
    // both of those branches exist, the shell holds two FloatingActionButtons
    // with the default hero tag and every push trips the debug-only
    // duplicate-hero assertion.
    await _openSection(tester, l10n.navMore);
    await _openTool(tester, const ValueKey('moreBudgetReportTile'));
    await waitForFinder(
      tester,
      find.byKey(const ValueKey('budgetReportContent')),
    );
    await _capture(tester, host, 'raport');
    await _back(tester);

    await _openTool(tester, const ValueKey('moreDocumentsTile'));
    await waitForFinder(
      tester,
      find.text('Notatka z wizyty kierownika budowy'),
    );
    await _capture(tester, host, 'dokumenty');
    await _back(tester);

    await _openTool(tester, const ValueKey('moreContactsTile'));
    await waitForFinder(tester, find.byKey(const ValueKey('contactsContent')));
    await waitForFinder(tester, find.text('Betoniarnia Kłodnica'));
    await _capture(tester, host, 'kontakty');
    await _back(tester);

    // Seven-day plan.
    await _openSection(tester, l10n.navPlan);
    await waitForFinder(tester, find.byKey(const ValueKey('scheduleAgenda')));
    await waitForFinder(tester, find.text('Dostawa stropu Teriva'));
    await _capture(tester, host, 'plan');

    // Stages with checklist progress.
    await _openSection(tester, l10n.navStages);
    // The chip is built in the list's cache area but still off screen.
    final currentStageChip = find.byKey(
      ValueKey<String>('stage-tab-${demo.currentStageId}'),
      skipOffstage: false,
    );
    await waitForFinder(tester, currentStageChip);
    await waitForFinder(
      tester,
      find.text('Odbierz konstrukcję i elementy przed zakryciem'),
    );
    await Scrollable.ensureVisible(
      tester.element(currentStageChip),
      alignment: 0.5,
    );
    await _capture(tester, host, 'etapy');
    final stageAppBar = find.descendant(
      of: find.byType(SliverAppBar),
      matching: find.byType(AppBar),
    );
    await _placeAt(
      tester,
      target: find.text(l10n.checklistHeading),
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey<String>('stage-plan-screen')),
            matching: find.byType(Scrollable),
          )
          .first,
      top: tester.getBottomLeft(stageAppBar.first).dy + 4,
    );
    await _capture(tester, host, 'etapy-lista');

    await host.request(tester, HostCaptureBridge.finishRequest);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _settle(WidgetTester tester, {int frames = 12}) async {
  for (var frame = 0; frame < frames; frame++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> _capture(
  WidgetTester tester,
  HostCaptureBridge host,
  String name,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await _settle(tester);
  expect(tester.takeException(), isNull);
  await host.request(tester, name);
}

Future<void> _openSection(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await _settle(tester, frames: 6);
}

Future<void> _openTool(WidgetTester tester, Key key) async {
  // The tile may be built but scrolled out of view by a previous visit.
  final tile = find.byKey(key, skipOffstage: false);
  await waitForFinder(tester, tile);
  await tester.ensureVisible(tile);
  await _settle(tester, frames: 2);
  await tester.tap(find.byKey(key));
  await _settle(tester, frames: 6);
}

Future<void> _back(WidgetTester tester) async {
  // pageBack() looks for the English "Back" tooltip; the app is Polish-only.
  await tester.tap(find.byType(BackButton));
  await _settle(tester, frames: 6);
}

/// Scrolls [scrollable] until [finder] is built, then aligns it at
/// [alignment] of the viewport without animation.
Future<void> _revealInScrollable(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double alignment = 0.02,
}) async {
  await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
  await _settle(tester, frames: 4);
  await Scrollable.ensureVisible(tester.element(finder), alignment: alignment);
  await _settle(tester, frames: 4);
}

/// Scrolls [scrollable] so that the top of [target] lands at global [top].
Future<void> _placeAt(
  WidgetTester tester, {
  required Finder target,
  required Finder scrollable,
  required double top,
}) async {
  final position = tester.state<ScrollableState>(scrollable).position;
  final delta = tester.getTopLeft(target).dy - top;
  position.jumpTo(
    (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ),
  );
  await _settle(tester, frames: 4);
}
