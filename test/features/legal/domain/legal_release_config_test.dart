import 'package:budowapro/features/legal/domain/legal_release_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a complete Google Play legal configuration', () {
    const config = LegalReleaseConfig(
      publisherName: 'BudowaPRO Sp. z o.o.',
      contactEmail: 'privacy@budowapro.pl',
      privacyPolicyUrl: 'https://budowapro.pl/privacy',
    );

    expect(config.hasCompleteLegalMetadata, isTrue);
    expect(config.missingRequirements, isEmpty);
    expect(
      config.publicPrivacyPolicyUri,
      Uri.parse('https://budowapro.pl/privacy'),
    );
  });

  test('reports every missing release requirement', () {
    const config = LegalReleaseConfig(
      publisherName: ' ',
      contactEmail: 'invalid',
      privacyPolicyUrl: 'http://localhost/privacy.pdf',
    );

    expect(config.hasCompleteLegalMetadata, isFalse);
    expect(config.missingRequirements, <LegalReleaseRequirement>[
      LegalReleaseRequirement.publisherName,
      LegalReleaseRequirement.contactEmail,
      LegalReleaseRequirement.publicPrivacyPolicyUrl,
    ]);
  });

  test('rejects a PDF even when it uses HTTPS', () {
    const config = LegalReleaseConfig(
      publisherName: 'BudowaPRO',
      contactEmail: 'privacy@example.pl',
      privacyPolicyUrl: 'https://example.pl/polityka.PDF?version=1',
    );

    expect(config.publicPrivacyPolicyUri, isNull);
    expect(config.hasCompleteLegalMetadata, isFalse);
  });

  test('rejects local and IP-only policy hosts', () {
    const local = LegalReleaseConfig(
      publisherName: 'BudowaPRO',
      contactEmail: 'privacy@example.pl',
      privacyPolicyUrl: 'https://localhost/privacy',
    );
    const privateIp = LegalReleaseConfig(
      publisherName: 'BudowaPRO',
      contactEmail: 'privacy@example.pl',
      privacyPolicyUrl: 'https://192.168.1.10/privacy',
    );

    expect(local.publicPrivacyPolicyUri, isNull);
    expect(privateIp.publicPrivacyPolicyUri, isNull);
  });
}
