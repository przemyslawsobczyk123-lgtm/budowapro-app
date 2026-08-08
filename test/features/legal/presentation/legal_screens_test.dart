import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/legal/data/legal_link_gateway.dart';
import 'package:budowapro/features/legal/data/legal_providers.dart';
import 'package:budowapro/features/legal/data/local_data_deletion_service.dart';
import 'package:budowapro/features/legal/domain/app_build_info.dart';
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
    final scrollable = find.descendant(
      of: find.byKey(const ValueKey('legalCenterContent')),
      matching: find.byType(Scrollable),
    );
    await tester.dragUntilVisible(
      find.text('0.1.0 (1)'),
      scrollable,
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
    expect(find.text('0.1.0 (1)'), findsOneWidget);
    expect(find.text('pl.budowapro'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('kontakt@budowaproapp.pl'),
      scrollable,
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
    expect(find.text('Przemysław Sobczyk'), findsNothing);
    expect(find.textContaining('6443558164'), findsNothing);
    expect(find.text('kontakt@budowaproapp.pl'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact tile opens a pre-addressed support email', (
    tester,
  ) async {
    _compactView(tester);
    final links = _FakeLegalLinkGateway();
    await tester.pumpWidget(
      _testApp(
        const LegalCenterScreen(),
        config: _configuredRelease,
        linkGateway: links,
      ),
    );
    await tester.pumpAndSettle();

    final contactTile = find.byKey(const ValueKey('legalContactTile'));
    await tester.dragUntilVisible(
      contactTile,
      find.descendant(
        of: find.byKey(const ValueKey('legalCenterContent')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -240),
    );
    await tester.tap(contactTile);
    await tester.pumpAndSettle();

    expect(links.opened, hasLength(1));
    expect(links.opened.single.scheme, 'mailto');
    expect(links.opened.single.path, 'kontakt@budowaproapp.pl');
    expect(
      links.opened.single.queryParameters['subject'],
      'BudowaPRO - kontakt',
    );
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
          supportUrl: '',
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
      privacyPolicyUrl: 'https://budowaproapp.pl/privacy/',
      supportUrl: 'https://budowaproapp.pl/support/',
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
      find.text(email),
      find.descendant(
        of: find.byKey(const ValueKey('legalCenterContent')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -240),
    );

    expect(config.hasCompleteLegalMetadata, isTrue);
    expect(find.text(publisher), findsNothing);
    expect(find.text(email), findsOneWidget);
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

  testWidgets('privacy policy identifies the controller only in the document', (
    tester,
  ) async {
    _compactView(tester);
    await tester.pumpWidget(
      _testApp(
        const LegalDocumentScreen(kind: LegalDocumentKind.privacyPolicy),
        config: _configuredRelease,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Przemysław Sobczyk'), findsOneWidget);
    expect(find.textContaining('NIP 6443558164'), findsOneWidget);
    expect(find.textContaining('kontakt@budowaproapp.pl'), findsOneWidget);
    expect(find.textContaining('@gmail.com'), findsNothing);
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

    await tester.dragUntilVisible(
      find.text('3. Informacje budowlane i bezpieczeństwo'),
      find.descendant(
        of: find.byKey(const ValueKey('legalDocument-termsOfUse')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -160),
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('3. Informacje budowlane i bezpieczeństwo')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('3. Informacje budowlane i bezpieczeństwo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nie są projektem budowlanym'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('terms identify the provider only in the legal document', (
    tester,
  ) async {
    _compactView(tester);
    await tester.pumpWidget(
      _testApp(
        const LegalDocumentScreen(kind: LegalDocumentKind.termsOfUse),
        config: _configuredRelease,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Przemysław Sobczyk'), findsOneWidget);
    expect(find.textContaining('NIP 6443558164'), findsOneWidget);
    expect(find.textContaining('kontakt@budowaproapp.pl'), findsOneWidget);
    expect(find.textContaining('@gmail.com'), findsNothing);
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
      find.text('Kopie systemowe urządzenia'),
      find.descendant(
        of: find.byKey(const ValueKey('privacySettingsContent')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -240),
    );
    expect(find.text('Kopie systemowe urządzenia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('requires an exact phrase before deleting all local data', (
    tester,
  ) async {
    _compactView(tester);
    final deletion = _FakeLocalDataDeletion();
    await tester.pumpWidget(
      _testApp(
        const PrivacySettingsScreen(),
        config: _configuredRelease,
        deletion: deletion,
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.descendant(
      of: find.byKey(const ValueKey('privacySettingsContent')),
      matching: find.byType(Scrollable),
    );
    await tester.dragUntilVisible(
      find.byKey(const ValueKey('privacyDeleteAllDataTile')),
      scrollable,
      const Offset(0, -240),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('privacyDeleteAllDataTile')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('privacyDeleteAllDataTile')));
    await tester.pumpAndSettle();

    final confirmButton = find.byKey(
      const ValueKey('privacyDeleteAllConfirmButton'),
    );
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);
    final phraseField = find.byKey(
      const ValueKey('privacyDeleteAllPhraseField'),
    );
    final phrase = AppLocalizations.of(
      tester.element(phraseField),
    ).privacyDeleteAllConfirmationPhrase;
    await tester.enterText(phraseField, phrase);
    await tester.pump();
    expect(tester.widget<TextField>(phraseField).controller!.text, phrase);
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNotNull);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(deletion.calls, 1);
    expect(tester.takeException(), isNull);
  });
}

const _configuredRelease = LegalReleaseConfig(
  publisherName: 'Przemysław Sobczyk',
  contactEmail: 'kontakt@budowaproapp.pl',
  privacyPolicyUrl: 'https://budowaproapp.pl/privacy/',
  supportUrl: 'https://budowaproapp.pl/support/',
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
  LocalDataDeletion? deletion,
  LegalLinkGateway? linkGateway,
}) {
  return ProviderScope(
    overrides: [
      legalReleaseConfigProvider.overrideWithValue(config),
      legalLinkGatewayProvider.overrideWithValue(
        linkGateway ?? _FakeLegalLinkGateway(),
      ),
      localDataDeletionProvider.overrideWith(
        (ref) async => deletion ?? _FakeLocalDataDeletion(),
      ),
      appBuildInfoProvider.overrideWith((ref) async => _buildInfo),
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

const _buildInfo = AppBuildInfo(
  version: '0.1.0',
  buildNumber: '1',
  packageName: 'pl.budowapro',
);

final class _FakeLegalLinkGateway implements LegalLinkGateway {
  final opened = <Uri>[];

  @override
  Future<bool> openExternal(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

final class _FakeLocalDataDeletion implements LocalDataDeletion {
  var calls = 0;

  @override
  Future<void> deleteAll() async {
    calls += 1;
  }
}
