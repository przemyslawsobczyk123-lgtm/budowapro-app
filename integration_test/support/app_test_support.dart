import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Polls the live app until [finder] matches or [timeout] expires.
Future<void> waitForFinder(
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
      'Timed out waiting for ${finder.describeMatch(Plurality.one)}. '
      'Visible text: ${_visibleTexts().join(' | ')}',
    );
  }
}

Iterable<String> _visibleTexts() => find
    .byType(Text)
    .evaluate()
    .map((element) => (element.widget as Text).data)
    .whereType<String>()
    .take(60);

/// Polls the live app until [finder] no longer matches.
Future<void> waitForAbsence(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isNotEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  if (finder.evaluate().isNotEmpty) {
    throw TestFailure(
      'Timed out waiting for ${finder.describeMatch(Plurality.one)} '
      'to disappear.',
    );
  }
}

/// Accepts the first-run legal gate exactly as a user does: tick the
/// confirmation and press the continue button.
Future<void> acceptLegalTermsThroughUi(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await waitForFinder(tester, find.text(l10n.legalAcceptanceTitle));
  final confirmation = find.text(l10n.legalAcceptanceCheckbox);
  await tester.ensureVisible(confirmation);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(confirmation);
  await tester.pump(const Duration(milliseconds: 300));

  final continueButton = find.text(l10n.legalAcceptanceContinue);
  await tester.ensureVisible(continueButton);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(continueButton);
  await waitForFinder(tester, find.byType(NavigationBar));
}
