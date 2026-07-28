final class LegalReleaseConfig {
  const LegalReleaseConfig({
    required this.publisherName,
    required this.contactEmail,
    required this.privacyPolicyUrl,
  });

  const LegalReleaseConfig.fromEnvironment()
    : publisherName = const String.fromEnvironment('BUDOWAPRO_PUBLISHER_NAME'),
      contactEmail = const String.fromEnvironment(
        'BUDOWAPRO_PRIVACY_CONTACT_EMAIL',
      ),
      privacyPolicyUrl = const String.fromEnvironment(
        'BUDOWAPRO_PRIVACY_POLICY_URL',
      );

  final String publisherName;
  final String contactEmail;
  final String privacyPolicyUrl;

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
    final uri = Uri.tryParse(privacyPolicyUrl.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        !_isPublicDomainHost(uri.host) ||
        uri.path.toLowerCase().endsWith('.pdf')) {
      return null;
    }
    return uri;
  }

  bool get hasCompleteLegalMetadata =>
      hasPublisherName &&
      hasValidContactEmail &&
      publicPrivacyPolicyUri != null;

  List<LegalReleaseRequirement> get missingRequirements =>
      <LegalReleaseRequirement>[
        if (!hasPublisherName) LegalReleaseRequirement.publisherName,
        if (!hasValidContactEmail) LegalReleaseRequirement.contactEmail,
        if (publicPrivacyPolicyUri == null)
          LegalReleaseRequirement.publicPrivacyPolicyUrl,
      ];
}

enum LegalReleaseRequirement {
  publisherName,
  contactEmail,
  publicPrivacyPolicyUrl,
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
