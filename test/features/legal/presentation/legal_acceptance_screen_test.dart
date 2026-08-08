import 'package:budowapro/features/legal/data/legal_providers.dart';
import 'package:budowapro/features/legal/presentation/legal_acceptance_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MainApp blocks project navigation before acceptance', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          legalTermsAcceptedProvider.overrideWith((ref) async => false),
        ],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zanim zaczniesz'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('requires explicit terms confirmation before continuing', (
    tester,
  ) async {
    var accepted = 0;
    var termsOpened = 0;
    var privacyOpened = 0;
    await tester.pumpWidget(
      _testApp(
        onAccept: () async => accepted++,
        onOpenTerms: () async {
          termsOpened++;
          return true;
        },
        onOpenPrivacy: () async {
          privacyOpened++;
          return true;
        },
      ),
    );

    expect(find.text('Zanim zaczniesz'), findsOneWidget);
    final continueButton = find.widgetWithText(
      FilledButton,
      'Rozpocznij korzystanie',
    );
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    await tester.tap(find.text('Otwórz regulamin'));
    await tester.tap(find.text('Polityka prywatności'));
    expect(termsOpened, 1);
    expect(privacyOpened, 1);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(accepted, 1);
  });

  testWidgets('fits the legal gate on a compact phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(
        onAccept: () async {},
        onOpenTerms: () async => true,
        onOpenPrivacy: () async => true,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
  });
}

Widget _testApp({
  required Future<void> Function() onAccept,
  required Future<bool> Function() onOpenTerms,
  required Future<bool> Function() onOpenPrivacy,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LegalAcceptanceScreen(
      onAccept: onAccept,
      onOpenTerms: onOpenTerms,
      onOpenPrivacy: onOpenPrivacy,
    ),
  );
}
