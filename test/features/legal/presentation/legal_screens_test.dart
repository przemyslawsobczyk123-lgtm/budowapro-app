import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/legal/data/legal_link_gateway.dart';
import 'package:budowapro/features/legal/data/legal_providers.dart';
import 'package:budowapro/features/legal/domain/legal_release_config.dart';
import 'package:budowapro/features/legal/presentation/legal_center_screen.dart';
import 'package:budowapro/features/legal/presentation/legal_document_screen.dart';
import 'package:budowapro/features/legal/presentation/privacy_settings_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows complete legal center at 320 px', (tester) async {
    _compactView(tester);
    await tester.pumpWidget(
      _testApp(const LegalCenterScreen(), config: _configuredRelease),
    );
    await tester.pumpAndSettle();

    expect(find.text('Polityka prywatności'), findsOneWidget);
    expect(find.text('Warunki użytkowania'), findsOneWidget);
    expect(find.text('Ustawienia prywatności'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('legalCenterContent')),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();
    expect(find.text('BudowaPRO Sp. z o.o.'), findsOneWidget);
    expect(find.text('privacy@budowapro.pl'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps missing release warning readable at 200 percent', (
    tester,
  ) async {
    _compactView(tester);
    await tester.pumpWidget(
      _testApp(
        const LegalCenterScreen(),
        config: const LegalReleaseConfig(
          publisherName: '',
          contactEmail: '',
          privacyPolicyUrl: '',
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wydanie wymaga uzupełnienia'), findsOneWidget);
    expect(find.textContaining('nazwa wydawcy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits maximum legal metadata at 200 percent', (tester) async {
    _compactView(tester);
    final publisher = List<String>.filled(160, 'W').join();
    final email =
        '${List<String>.filled(64, 'a').join()}@'
        '${List<String>.filled(63, 'b').join()}.'
        '${List<String>.filled(63, 'c').join()}.'
        '${List<String>.filled(48, 'd').join()}.pl';
    final config = LegalReleaseConfig(
      publisherName: publisher,
      contactEmail: email,
      privacyPolicyUrl: 'https://budowapro.pl/privacy',
    );

    await tester.pumpWidget(
      _testApp(
        const LegalCenterScreen(),
        config: config,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text(publisher),
      find.descendant(
        of: find.byKey(const ValueKey('legalCenterContent')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -240),
    );

    expect(config.hasCompleteLegalMetadata, isTrue);
    expect(find.text(publisher), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy policy discloses ML Kit metrics at 200 percent', (
    tester,
  ) async {
    _compactView(tester);
    await tester.pumpWidget(
      _testApp(
        const LegalDocumentScreen(kind: LegalDocumentKind.privacyPolicy),
        config: _configuredRelease,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('4. Skaner i Google ML Kit'),
      find.descendant(
        of: find.byKey(const ValueKey('legalDocument-privacyPolicy')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -240),
    );
    await tester.ensureVisible(find.text('4. Skaner i Google ML Kit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4. Skaner i Google ML Kit'));
    await tester.pumpAndSettle();

    expect(find.textContaining('obrazy, tekst wejściowy'), findsOneWidget);
    expect(find.textContaining('metryki techniczne'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('terms expose the construction safety boundary', (tester) async {
    _compactView(tester);
    await tester.pumpWidget(
      _testApp(
        const LegalDocumentScreen(kind: LegalDocumentKind.termsOfUse),
        config: _configuredRelease,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.text('3. Informacje budowlane i bezpieczeństwo'),
    );
    await tester.tap(find.text('3. Informacje budowlane i bezpieczeństwo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nie są projektem budowlanym'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy settings show real local controls at 200 percent', (
    tester,
  ) async {
    _compactView(tester);
    await tester.pumpWidget(
      _testApp(
        const PrivacySettingsScreen(),
        config: _configuredRelease,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('privacySettingsContent')),
      const Offset(0, -340),
    );
    await tester.pumpAndSettle();
    expect(find.text('Treści projektu pozostają lokalnie'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Automatyczny backup Androida wyłączony'),
      find.descendant(
        of: find.byKey(const ValueKey('privacySettingsContent')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -240),
    );
    expect(find.text('Automatyczny backup Androida wyłączony'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _configuredRelease = LegalReleaseConfig(
  publisherName: 'BudowaPRO Sp. z o.o.',
  contactEmail: 'privacy@budowapro.pl',
  privacyPolicyUrl: 'https://budowapro.pl/privacy',
);

void _compactView(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _testApp(
  Widget home, {
  required LegalReleaseConfig config,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [
      legalReleaseConfigProvider.overrideWithValue(config),
      legalLinkGatewayProvider.overrideWithValue(_FakeLegalLinkGateway()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: home,
    ),
  );
}

final class _FakeLegalLinkGateway implements LegalLinkGateway {
  @override
  Future<bool> openExternal(Uri uri) async => true;
}
