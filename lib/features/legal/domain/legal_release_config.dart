final class LegalReleaseConfig {
  static const productionPublisherName = 'Przemysław Sobczyk';
  static const productionPublisherTaxId = '6443558164';
  static const productionContactEmail = 'kontakt@budowaproapp.pl';
  static const productionPrivacyPolicyUrl = 'https://budowaproapp.pl/privacy/';
  static const productionSupportUrl = 'https://budowaproapp.pl/support/';

  const LegalReleaseConfig({
    required this.publisherName,
    this.publisherTaxId = productionPublisherTaxId,
    required this.contactEmail,
    required this.privacyPolicyUrl,
    required this.supportUrl,
  });

  const LegalReleaseConfig.fromEnvironment()
    : publisherName = const String.fromEnvironment(
        'BUDOWAPRO_PUBLISHER_NAME',
        defaultValue: productionPublisherName,
      ),
      contactEmail = const String.fromEnvironment(
        'BUDOWAPRO_PRIVACY_CONTACT_EMAIL',
        defaultValue: productionContactEmail,
      ),
      publisherTaxId = productionPublisherTaxId,
      privacyPolicyUrl = const String.fromEnvironment(
        'BUDOWAPRO_PRIVACY_POLICY_URL',
        defaultValue: productionPrivacyPolicyUrl,
      ),
      supportUrl = const String.fromEnvironment(
        'BUDOWAPRO_SUPPORT_URL',
        defaultValue: productionSupportUrl,
      );

  final String publisherName;
  final String publisherTaxId;
  final String contactEmail;
  final String privacyPolicyUrl;
  final String supportUrl;

  bool get hasPublisherName {
    final value = publisherName.trim();
    return value.isNotEmpty && value.length <= 160;
  }

  bool get hasValidPublisherTaxId => _isValidPolishTaxId(publisherTaxId);

  bool get hasValidContactEmail {
    final value = contactEmail.trim();
    return value.length <= 254 &&
        RegExp(
          r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
        ).hasMatch(value);
  }

  Uri? get publicPrivacyPolicyUri {
    return _publicHttpsUri(privacyPolicyUrl, rejectPdf: true);
  }

  Uri? get publicSupportUri {
    return _publicHttpsUri(supportUrl, rejectPdf: true);
  }

  Uri? _publicHttpsUri(String value, {required bool rejectPdf}) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        !_isPublicDomainHost(uri.host) ||
        (rejectPdf && uri.path.toLowerCase().endsWith('.pdf'))) {
      return null;
    }
    return uri;
  }

  bool get hasCompleteLegalMetadata =>
      hasPublisherName &&
      hasValidPublisherTaxId &&
      hasValidContactEmail &&
      publicPrivacyPolicyUri != null &&
      publicSupportUri != null;

  List<LegalReleaseRequirement> get missingRequirements =>
      <LegalReleaseRequirement>[
        if (!hasPublisherName) LegalReleaseRequirement.publisherName,
        if (!hasValidPublisherTaxId) LegalReleaseRequirement.publisherTaxId,
        if (!hasValidContactEmail) LegalReleaseRequirement.contactEmail,
        if (publicPrivacyPolicyUri == null)
          LegalReleaseRequirement.publicPrivacyPolicyUrl,
        if (publicSupportUri == null) LegalReleaseRequirement.supportUrl,
      ];
}

enum LegalReleaseRequirement {
  publisherName,
  publisherTaxId,
  contactEmail,
  publicPrivacyPolicyUrl,
  supportUrl,
}

bool _isValidPolishTaxId(String value) {
  final digits = value.replaceAll(RegExp(r'[-\s]'), '');
  if (!RegExp(r'^\d{10}$').hasMatch(digits)) {
    return false;
  }
  const weights = <int>[6, 5, 7, 2, 3, 4, 5, 6, 7];
  var checksum = 0;
  for (var index = 0; index < weights.length; index++) {
    checksum += int.parse(digits[index]) * weights[index];
  }
  return checksum % 11 == int.parse(digits[9]);
}

bool _isPublicDomainHost(String host) {
  final normalized = host.toLowerCase();
  if (!normalized.contains('.') ||
      normalized == 'localhost' ||
      normalized.endsWith('.localhost') ||
      normalized.endsWith('.local') ||
      normalized.endsWith('.internal')) {
    return false;
  }
  return !RegExp(r'^\d{1,3}(?:\.\d{1,3}){3}$').hasMatch(normalized);
}
