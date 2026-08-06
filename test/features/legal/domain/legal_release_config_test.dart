import 'package:budowapro/features/legal/domain/legal_release_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ships complete BudowaPRO production legal defaults', () {
    const config = LegalReleaseConfig.fromEnvironment();

    expect(config.hasCompleteLegalMetadata, isTrue);
    expect(config.publisherName, LegalReleaseConfig.productionPublisherName);
    expect(config.contactEmail, 'kontakt@budowaproapp.pl');
    expect(
      config.publicPrivacyPolicyUri,
      Uri.parse('https://budowaproapp.pl/privacy/'),
    );
    expect(
      config.publicSupportUri,
      Uri.parse('https://budowaproapp.pl/support/'),
    );
  });

  test('accepts a complete Google Play legal configuration', () {
    const config = LegalReleaseConfig(
      publisherName: 'Przemysław Sobczyk',
      contactEmail: 'kontakt@budowaproapp.pl',
      privacyPolicyUrl: 'https://budowaproapp.pl/privacy/',
      supportUrl: 'https://budowaproapp.pl/support/',
    );

    expect(config.hasCompleteLegalMetadata, isTrue);
    expect(config.missingRequirements, isEmpty);
    expect(
      config.publicPrivacyPolicyUri,
      Uri.parse('https://budowaproapp.pl/privacy/'),
    );
    expect(
      config.publicSupportUri,
      Uri.parse('https://budowaproapp.pl/support/'),
    );
  });

  test('reports every missing release requirement', () {
    const config = LegalReleaseConfig(
      publisherName: ' ',
      contactEmail: 'invalid',
      privacyPolicyUrl: 'http://localhost/privacy.pdf',
      supportUrl: '',
    );

    expect(config.hasCompleteLegalMetadata, isFalse);
    expect(config.missingRequirements, <LegalReleaseRequirement>[
      LegalReleaseRequirement.publisherName,
      LegalReleaseRequirement.contactEmail,
      LegalReleaseRequirement.publicPrivacyPolicyUrl,
      LegalReleaseRequirement.supportUrl,
    ]);
  });

  test('rejects a PDF even when it uses HTTPS', () {
    const config = LegalReleaseConfig(
      publisherName: 'BudowaPRO',
      contactEmail: 'privacy@example.pl',
      privacyPolicyUrl: 'https://example.pl/polityka.PDF?version=1',
      supportUrl: 'https://example.pl/support',
    );

    expect(config.publicPrivacyPolicyUri, isNull);
    expect(config.hasCompleteLegalMetadata, isFalse);
  });

  test('rejects local and IP-only policy hosts', () {
    const local = LegalReleaseConfig(
      publisherName: 'BudowaPRO',
      contactEmail: 'privacy@example.pl',
      privacyPolicyUrl: 'https://localhost/privacy',
      supportUrl: 'https://example.pl/support',
    );
    const privateIp = LegalReleaseConfig(
      publisherName: 'BudowaPRO',
      contactEmail: 'privacy@example.pl',
      privacyPolicyUrl: 'https://192.168.1.10/privacy',
      supportUrl: 'https://example.pl/support',
    );

    expect(local.publicPrivacyPolicyUri, isNull);
    expect(privateIp.publicPrivacyPolicyUri, isNull);
  });
}
