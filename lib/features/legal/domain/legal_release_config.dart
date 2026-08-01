final class LegalReleaseConfig {
  const LegalReleaseConfig({
    required this.publisherName,
    required this.contactEmail,
    required this.privacyPolicyUrl,
    required this.supportUrl,
  });

  const LegalReleaseConfig.fromEnvironment()
    : publisherName = const String.fromEnvironment('BUDOWAPRO_PUBLISHER_NAME'),
      contactEmail = const String.fromEnvironment(
        'BUDOWAPRO_PRIVACY_CONTACT_EMAIL',
      ),
      privacyPolicyUrl = const String.fromEnvironment(
        'BUDOWAPRO_PRIVACY_POLICY_URL',
      ),
      supportUrl = const String.fromEnvironment('BUDOWAPRO_SUPPORT_URL');

  final String publisherName;
  final String contactEmail;
  final String privacyPolicyUrl;
  final String supportUrl;

  bool get hasPublisherName {
    final value = publisherName.trim();
    return value.isNotEmpty && value.length <= 160;
  }

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
      hasValidContactEmail &&
      publicPrivacyPolicyUri != null &&
      publicSupportUri != null;

  List<LegalReleaseRequirement> get missingRequirements =>
      <LegalReleaseRequirement>[
        if (!hasPublisherName) LegalReleaseRequirement.publisherName,
        if (!hasValidContactEmail) LegalReleaseRequirement.contactEmail,
        if (publicPrivacyPolicyUri == null)
          LegalReleaseRequirement.publicPrivacyPolicyUrl,
        if (publicSupportUri == null) LegalReleaseRequirement.supportUrl,
      ];
}

enum LegalReleaseRequirement {
  publisherName,
  contactEmail,
  publicPrivacyPolicyUrl,
  supportUrl,
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
