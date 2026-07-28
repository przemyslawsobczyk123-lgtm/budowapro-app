import 'dart:typed_data';

const String bundletoolVersion = '1.18.3';
const String bundletoolSha256 =
    'A099CFA1543F55593BC2ED16A70A7C67FE54B1747BB7301F37FDFD6D91028E29';
const String bundletoolDownloadUrl =
    'https://github.com/google/bundletool/releases/download/'
    '1.18.3/bundletool-all-1.18.3.jar';

const List<String> requiredReleaseEnvironmentVariables = <String>[
  'BUDOWAPRO_UPLOAD_STORE_FILE',
  'BUDOWAPRO_UPLOAD_STORE_PASSWORD',
  'BUDOWAPRO_UPLOAD_KEY_ALIAS',
  'BUDOWAPRO_UPLOAD_KEY_PASSWORD',
  'BUDOWAPRO_UPLOAD_CERT_SHA256',
  'BUDOWAPRO_PUBLISHER_NAME',
  'BUDOWAPRO_PRIVACY_CONTACT_EMAIL',
  'BUDOWAPRO_PRIVACY_POLICY_URL',
];

const Set<String> expectedManifestPermissions = <String>{
  'android.permission.ACCESS_NETWORK_STATE',
  'android.permission.INTERNET',
  'android.permission.POST_NOTIFICATIONS',
  'android.permission.RECEIVE_BOOT_COMPLETED',
  'android.permission.VIBRATE',
  'pl.budowapro.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION',
};

const Set<String> requiredMlKitR8Rules = <String>{
  '-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions'
      r'$Builder',
  '-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions',
  '-dontwarn com.google.mlkit.vision.text.devanagari.'
      'DevanagariTextRecognizerOptions'
      r'$Builder',
  '-dontwarn com.google.mlkit.vision.text.devanagari.'
      'DevanagariTextRecognizerOptions',
  '-dontwarn com.google.mlkit.vision.text.japanese.'
      'JapaneseTextRecognizerOptions'
      r'$Builder',
  '-dontwarn com.google.mlkit.vision.text.japanese.'
      'JapaneseTextRecognizerOptions',
  '-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions'
      r'$Builder',
  '-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions',
};

final class ReleaseFailure implements Exception {
  const ReleaseFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ReleaseOptions {
  const ReleaseOptions({
    required this.allowDirty,
    required this.showHelp,
    required this.validationOnly,
  });

  final bool allowDirty;
  final bool showHelp;
  final bool validationOnly;
}

final class ReleaseEnvironment {
  const ReleaseEnvironment({
    required this.uploadStoreFile,
    required this.uploadKeyAlias,
    required this.uploadCertificateSha256,
    required this.publisherName,
    required this.privacyContactEmail,
    required this.privacyPolicyUrl,
  });

  final String uploadStoreFile;
  final String uploadKeyAlias;
  final String uploadCertificateSha256;
  final String publisherName;
  final String privacyContactEmail;
  final String privacyPolicyUrl;
}

ReleaseOptions parseReleaseOptions(List<String> arguments) {
  var allowDirty = false;
  var showHelp = false;
  var validationOnly = false;

  for (final argument in arguments) {
    switch (argument) {
      case '--allow-dirty':
        allowDirty = true;
      case '--validation':
        validationOnly = true;
      case '--help':
      case '-h':
        showHelp = true;
      default:
        throw ReleaseFailure('Unknown release option: $argument');
    }
  }

  return ReleaseOptions(
    allowDirty: allowDirty,
    showHelp: showHelp,
    validationOnly: validationOnly,
  );
}

ReleaseEnvironment validateReleaseEnvironment(
  Map<String, String> environment, {
  bool validationOnly = false,
}) {
  final values = <String, String>{
    for (final name in requiredReleaseEnvironmentVariables)
      name: environment[name]?.trim() ?? '',
  };
  final missing = values.entries
      .where((entry) => entry.value.isEmpty)
      .map((entry) => entry.key)
      .toList(growable: false);
  if (missing.isNotEmpty) {
    throw ReleaseFailure(
      'Missing required release environment variables: ${missing.join(', ')}',
    );
  }

  final publisherName = values['BUDOWAPRO_PUBLISHER_NAME']!;
  if (publisherName.length > 160 ||
      _looksLikePlaceholder(publisherName) ||
      (!validationOnly && _looksLikeValidationValue(publisherName))) {
    throw const ReleaseFailure(
      'BUDOWAPRO_PUBLISHER_NAME must contain final publisher data.',
    );
  }

  final privacyContactEmail = values['BUDOWAPRO_PRIVACY_CONTACT_EMAIL']!;
  if (privacyContactEmail.length > 254 ||
      !_emailPattern.hasMatch(privacyContactEmail) ||
      (!validationOnly && _hasReservedDomain(privacyContactEmail))) {
    throw const ReleaseFailure(
      'BUDOWAPRO_PRIVACY_CONTACT_EMAIL must be a valid public email address.',
    );
  }

  final privacyPolicyUrl = values['BUDOWAPRO_PRIVACY_POLICY_URL']!;
  if (!_isPublicPrivacyPolicyUrl(privacyPolicyUrl) ||
      (!validationOnly && _hasReservedDomain(privacyPolicyUrl))) {
    throw const ReleaseFailure(
      'BUDOWAPRO_PRIVACY_POLICY_URL must be a public HTTPS, non-PDF URL.',
    );
  }

  final uploadCertificateSha256 = normalizeCertificateSha256(
    values['BUDOWAPRO_UPLOAD_CERT_SHA256']!,
  );

  return ReleaseEnvironment(
    uploadStoreFile: values['BUDOWAPRO_UPLOAD_STORE_FILE']!,
    uploadKeyAlias: values['BUDOWAPRO_UPLOAD_KEY_ALIAS']!,
    uploadCertificateSha256: uploadCertificateSha256,
    publisherName: publisherName,
    privacyContactEmail: privacyContactEmail,
    privacyPolicyUrl: privacyPolicyUrl,
  );
}

String parsePubspecVersion(String pubspecContents) {
  final match = RegExp(
    r'^version:\s*([^\s#]+)\s*(?:#.*)?$',
    multiLine: true,
  ).firstMatch(pubspecContents);
  final version = match?.group(1);
  if (version == null || !_versionPattern.hasMatch(version)) {
    throw const ReleaseFailure(
      'pubspec.yaml must contain a production version such as 1.2.3+45.',
    );
  }
  return version;
}

String sanitizePathSegment(String value) {
  final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9._+-]'), '_');
  if (sanitized.isEmpty || sanitized == '.' || sanitized == '..') {
    throw const ReleaseFailure('Release path segment is invalid.');
  }
  return sanitized;
}

List<String> buildAppBundleArguments({
  required ReleaseEnvironment environment,
  required String dartSymbolsDirectory,
  required String obfuscationMapFile,
}) {
  return <String>[
    'build',
    'appbundle',
    '--release',
    '--obfuscate',
    '--split-debug-info=$dartSymbolsDirectory',
    '--extra-gen-snapshot-options=--save-obfuscation-map=$obfuscationMapFile',
    '--dart-define=BUDOWAPRO_PUBLISHER_NAME=${environment.publisherName}',
    '--dart-define=BUDOWAPRO_PRIVACY_CONTACT_EMAIL='
        '${environment.privacyContactEmail}',
    '--dart-define=BUDOWAPRO_PRIVACY_POLICY_URL='
        '${environment.privacyPolicyUrl}',
  ];
}

void require16KbPageAlignment(String bundleConfig) {
  if (!RegExp(r'\bPAGE_ALIGNMENT_16K\b').hasMatch(bundleConfig)) {
    throw const ReleaseFailure(
      'The Android App Bundle does not declare PAGE_ALIGNMENT_16K.',
    );
  }
}

void requireJarsignerVerification(String output) {
  if (!RegExp(r'\bjar verified\.?', caseSensitive: false).hasMatch(output) ||
      RegExp(r'\bjar is unsigned\b', caseSensitive: false).hasMatch(output)) {
    throw const ReleaseFailure(
      'jarsigner did not confirm a valid AAB signature.',
    );
  }
}

String normalizeCertificateSha256(String value) {
  final normalized = value
      .replaceAll(':', '')
      .replaceAll(' ', '')
      .toUpperCase();
  if (!RegExp(r'^[0-9A-F]{64}$').hasMatch(normalized)) {
    throw const ReleaseFailure(
      'BUDOWAPRO_UPLOAD_CERT_SHA256 must be a 64-digit SHA-256 fingerprint.',
    );
  }
  return normalized;
}

String certificateSha256FromKeytool(String output) {
  final match = RegExp(
    r'SHA256:\s*((?:[0-9A-Fa-f]{2}:){31}[0-9A-Fa-f]{2})',
  ).firstMatch(output);
  if (match == null) {
    throw const ReleaseFailure(
      'keytool did not return a SHA-256 certificate fingerprint.',
    );
  }
  return normalizeCertificateSha256(match.group(1)!);
}

void requireExpectedCertificateSha256({
  required String expected,
  required String actual,
}) {
  if (normalizeCertificateSha256(expected) !=
      normalizeCertificateSha256(actual)) {
    throw const ReleaseFailure(
      'The release certificate does not match BUDOWAPRO_UPLOAD_CERT_SHA256.',
    );
  }
}

Set<String> permissionsInManifest(String manifest) {
  final tags = RegExp(
    r'<uses-permission(?:-sdk-\d+)?\b[^>]*\bandroid:name\s*=\s*'
    r'''["']([A-Za-z0-9._]+)["'][^>]*>''',
    caseSensitive: false,
    dotAll: true,
  );
  return tags.allMatches(manifest).map((match) => match.group(1)!).toSet();
}

List<String> unexpectedPermissionsInManifest(String manifest) {
  final unexpected = permissionsInManifest(
    manifest,
  ).difference(expectedManifestPermissions).toList(growable: false)..sort();
  return unexpected;
}

void requireSafeManifest(String manifest) {
  final declared = permissionsInManifest(manifest);
  final unexpected = declared.difference(expectedManifestPermissions).toList()
    ..sort();
  final missing = expectedManifestPermissions.difference(declared).toList()
    ..sort();
  if (unexpected.isNotEmpty || missing.isNotEmpty) {
    throw ReleaseFailure(
      'Release manifest permissions differ from the allowlist. '
      'Unexpected: ${unexpected.join(', ')}. Missing: ${missing.join(', ')}.',
    );
  }
}

bool is64BitAndroidNativeLibrary(String path) {
  final normalized = path.replaceAll(r'\', '/').toLowerCase();
  return normalized.endsWith('.so') &&
      (normalized.contains('/arm64-v8a/') || normalized.contains('/x86_64/'));
}

void require64BitElfLoadAlignment({
  required String name,
  required List<int> bytes,
}) {
  if (bytes.length < 64 ||
      bytes[0] != 0x7F ||
      bytes[1] != 0x45 ||
      bytes[2] != 0x4C ||
      bytes[3] != 0x46 ||
      bytes[4] != 2) {
    throw ReleaseFailure('$name is not a valid 64-bit ELF library.');
  }
  final endian = switch (bytes[5]) {
    1 => Endian.little,
    2 => Endian.big,
    _ => throw ReleaseFailure('$name has an unsupported ELF byte order.'),
  };
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  final programHeaderOffset = data.getUint64(32, endian);
  final programHeaderEntrySize = data.getUint16(54, endian);
  final programHeaderCount = data.getUint16(56, endian);
  if (programHeaderEntrySize < 56 ||
      programHeaderCount == 0 ||
      programHeaderOffset >
          bytes.length - (programHeaderEntrySize * programHeaderCount)) {
    throw ReleaseFailure('$name has an invalid ELF program header table.');
  }

  var loadSegmentCount = 0;
  for (var index = 0; index < programHeaderCount; index++) {
    final offset = programHeaderOffset + (index * programHeaderEntrySize);
    if (data.getUint32(offset, endian) != 1) continue;
    loadSegmentCount++;
    final alignment = data.getUint64(offset + 48, endian);
    if (alignment < 0x4000 || (alignment & (alignment - 1)) != 0) {
      throw ReleaseFailure(
        '$name contains a LOAD segment aligned below 16 KB.',
      );
    }
  }
  if (loadSegmentCount == 0) {
    throw ReleaseFailure('$name does not contain an ELF LOAD segment.');
  }
}

void requireAndroidReleaseShrinkerConfiguration({
  required String buildGradle,
  required String proguardRules,
}) {
  final normalizedGradle = buildGradle.replaceAll(RegExp(r'\s+'), '');
  if (!normalizedGradle.contains('isMinifyEnabled=true') ||
      !normalizedGradle.contains('isShrinkResources=true') ||
      !normalizedGradle.contains('"proguard-rules.pro"')) {
    throw const ReleaseFailure(
      'Android release must enable shrinking and load proguard-rules.pro.',
    );
  }

  final configuredRules = proguardRules
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toSet();
  final missingRules = requiredMlKitR8Rules.difference(configuredRules).toList()
    ..sort();
  if (missingRules.isNotEmpty) {
    throw ReleaseFailure(
      'Missing required ML Kit R8 rules: ${missingRules.join(', ')}',
    );
  }
}

final RegExp _emailPattern = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
  r'[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$',
);
final RegExp _versionPattern = RegExp(
  r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$',
);

bool _looksLikePlaceholder(String value) {
  final normalized = value.trim().toUpperCase().replaceAll(
    RegExp(r'[\s-]+'),
    '_',
  );
  return normalized.isEmpty ||
      normalized == 'TODO' ||
      normalized == 'TBD' ||
      normalized == 'CHANGE_ME' ||
      normalized == 'YOUR_COMPANY' ||
      normalized == 'TWOJA_FIRMA' ||
      (value.startsWith('<') && value.endsWith('>'));
}

bool _looksLikeValidationValue(String value) {
  final words = value
      .toUpperCase()
      .split(RegExp(r'[^A-Z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toSet();
  return words.intersection(const <String>{
    'DEMO',
    'EXAMPLE',
    'PLACEHOLDER',
    'TEST',
    'VALIDATION',
  }).isNotEmpty;
}

bool _hasReservedDomain(String value) {
  final uri = Uri.tryParse(value.contains('://') ? value : 'mailto:$value');
  final host = value.contains('://')
      ? uri?.host.toLowerCase()
      : value.split('@').lastOrNull?.toLowerCase();
  if (host == null || host.isEmpty) return true;
  const reserved = <String>{
    'example.com',
    'example.net',
    'example.org',
    'test',
    'invalid',
  };
  return reserved.any((domain) => host == domain || host.endsWith('.$domain'));
}

bool _isPublicPrivacyPolicyUrl(String value) {
  if (value.contains(RegExp(r'\s'))) {
    return false;
  }
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.path.toLowerCase().endsWith('.pdf')) {
    return false;
  }

  final host = uri.host.toLowerCase();
  final isIpv4 = RegExp(r'^\d{1,3}(?:\.\d{1,3}){3}$').hasMatch(host);
  final isIpv6 = host.contains(':');
  return host.contains('.') &&
      !isIpv4 &&
      !isIpv6 &&
      host != 'localhost' &&
      !host.endsWith('.localhost') &&
      !host.endsWith('.local') &&
      !host.endsWith('.internal');
}
