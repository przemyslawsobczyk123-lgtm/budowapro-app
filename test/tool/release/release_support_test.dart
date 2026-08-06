import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/release/release_support.dart';

void main() {
  group('parseReleaseOptions', () {
    test('defaults to a clean-worktree release', () {
      final options = parseReleaseOptions(const <String>[]);

      expect(options.allowDirty, isFalse);
      expect(options.showHelp, isFalse);
      expect(options.validationOnly, isFalse);
    });

    test('accepts allow-dirty and help', () {
      expect(
        parseReleaseOptions(const <String>['--allow-dirty']).allowDirty,
        isTrue,
      );
      expect(parseReleaseOptions(const <String>['--help']).showHelp, isTrue);
      expect(
        parseReleaseOptions(const <String>['--validation']).validationOnly,
        isTrue,
      );
    });

    test('rejects unknown arguments', () {
      expect(
        () => parseReleaseOptions(const <String>['--skip-tests']),
        throwsA(
          isA<ReleaseFailure>().having(
            (error) => error.message,
            'message',
            contains('--skip-tests'),
          ),
        ),
      );
    });
  });

  group('validateReleaseEnvironment', () {
    test('reports every missing required variable', () {
      expect(
        () => validateReleaseEnvironment(const <String, String>{}),
        throwsA(
          isA<ReleaseFailure>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('BUDOWAPRO_UPLOAD_STORE_FILE'),
              contains('BUDOWAPRO_UPLOAD_STORE_PASSWORD'),
              contains('BUDOWAPRO_UPLOAD_KEY_ALIAS'),
              contains('BUDOWAPRO_UPLOAD_KEY_PASSWORD'),
              allOf(
                contains('BUDOWAPRO_UPLOAD_CERT_SHA256'),
                contains('BUDOWAPRO_PUBLISHER_NAME'),
              ),
              allOf(
                contains('BUDOWAPRO_PRIVACY_CONTACT_EMAIL'),
                contains('BUDOWAPRO_PRIVACY_POLICY_URL'),
                contains('BUDOWAPRO_SUPPORT_URL'),
              ),
            ),
          ),
        ),
      );
    });

    test('accepts production-shaped values and trims legal metadata', () {
      final environment = validateReleaseEnvironment(
        _validEnvironment(
          publisherName: '  BudowaPRO sp. z o.o.  ',
          privacyEmail: '  kontakt@budowaproapp.pl  ',
          privacyUrl: '  https://budowaproapp.pl/privacy/  ',
        ),
      );

      expect(environment.publisherName, 'BudowaPRO sp. z o.o.');
      expect(environment.privacyContactEmail, 'kontakt@budowaproapp.pl');
      expect(environment.privacyPolicyUrl, 'https://budowaproapp.pl/privacy/');
      expect(environment.supportUrl, 'https://budowaproapp.pl/support/');
    });

    test('rejects non-public or PDF privacy policy URLs', () {
      for (final url in <String>[
        'http://budowaproapp.pl/privacy',
        'https://localhost/privacy',
        'https://192.168.1.2/privacy',
        'https://budowaproapp.pl/privacy.pdf',
      ]) {
        expect(
          () => validateReleaseEnvironment(_validEnvironment(privacyUrl: url)),
          throwsA(isA<ReleaseFailure>()),
          reason: url,
        );
      }
    });

    test('rejects malformed email and placeholder publisher', () {
      expect(
        () => validateReleaseEnvironment(
          _validEnvironment(privacyEmail: 'privacy@localhost'),
        ),
        throwsA(isA<ReleaseFailure>()),
      );
      expect(
        () => validateReleaseEnvironment(
          _validEnvironment(publisherName: 'CHANGE_ME'),
        ),
        throwsA(isA<ReleaseFailure>()),
      );
    });

    test('rejects reserved validation data for a production release', () {
      expect(
        () => validateReleaseEnvironment(
          _validEnvironment(
            publisherName: 'BudowaPRO Validation Build',
            privacyEmail: 'validation@example.com',
            privacyUrl: 'https://example.com/privacy',
          ),
        ),
        throwsA(isA<ReleaseFailure>()),
      );

      expect(
        () => validateReleaseEnvironment(
          _validEnvironment(
            publisherName: 'BudowaPRO Validation Build',
            privacyEmail: 'validation@example.com',
            privacyUrl: 'https://example.com/privacy',
          ),
          validationOnly: true,
        ),
        returnsNormally,
      );
      for (final email in <String>[
        'privacy@sub.example.com',
        'privacy@foo.test',
      ]) {
        expect(
          () => validateReleaseEnvironment(
            _validEnvironment(privacyEmail: email),
          ),
          throwsA(isA<ReleaseFailure>()),
          reason: email,
        );
      }
      expect(
        () => validateReleaseEnvironment(
          _validEnvironment(supportUrl: 'http://budowaproapp.pl/support'),
        ),
        throwsA(isA<ReleaseFailure>()),
      );
    });

    test('normalizes and validates the expected upload certificate', () {
      final environment = validateReleaseEnvironment(_validEnvironment());

      expect(
        environment.uploadCertificateSha256,
        '0123456789ABCDEF0123456789ABCDEF'
        '0123456789ABCDEF0123456789ABCDEF',
      );
      expect(
        () => validateReleaseEnvironment(<String, String>{
          ..._validEnvironment(),
          'BUDOWAPRO_UPLOAD_CERT_SHA256': 'not-a-fingerprint',
        }),
        throwsA(isA<ReleaseFailure>()),
      );
    });
  });

  group('release helpers', () {
    test('parses and sanitizes the application version', () {
      final version = parsePubspecVersion(
        'name: budowapro\nversion: 1.24.3+57\n',
      );

      expect(version, '1.24.3+57');
      expect(sanitizePathSegment(version), '1.24.3+57');
      expect(sanitizePathSegment('release / test'), 'release___test');
    });

    test('rejects missing or malformed versions', () {
      expect(
        () => parsePubspecVersion('name: budowapro\n'),
        throwsA(isA<ReleaseFailure>()),
      );
      expect(
        () => parsePubspecVersion('version: next\n'),
        throwsA(isA<ReleaseFailure>()),
      );
    });

    test('build arguments contain legal defines but no signing secrets', () {
      final environment = validateReleaseEnvironment(_validEnvironment());
      final arguments = buildAppBundleArguments(
        environment: environment,
        dartSymbolsDirectory: r'C:\build\symbols',
        obfuscationMapFile: r'C:\build\obfuscation-map.json',
      );
      final joined = arguments.join(' ');

      expect(arguments, contains('appbundle'));
      expect(arguments, contains('--release'));
      expect(arguments, contains('--obfuscate'));
      expect(arguments, contains(r'--split-debug-info=C:\build\symbols'));
      expect(
        arguments,
        contains(
          r'--extra-gen-snapshot-options=--save-obfuscation-map=C:\build\obfuscation-map.json',
        ),
      );
      expect(joined, contains('BUDOWAPRO_PUBLISHER_NAME=BudowaPRO'));
      expect(joined, contains('BUDOWAPRO_PRIVACY_CONTACT_EMAIL='));
      expect(joined, contains('BUDOWAPRO_PRIVACY_POLICY_URL='));
      expect(joined, contains('BUDOWAPRO_SUPPORT_URL='));
      expect(joined, isNot(contains('store-secret')));
      expect(joined, isNot(contains('key-secret')));
      expect(joined, isNot(contains('upload-alias')));
      expect(joined, isNot(contains('upload.jks')));
    });

    test('requires 16 KB page alignment in bundle config', () {
      expect(
        () => require16KbPageAlignment(
          'optimizations { page_alignment: PAGE_ALIGNMENT_16K }',
        ),
        returnsNormally,
      );
      expect(
        () => require16KbPageAlignment(
          'optimizations { page_alignment: PAGE_ALIGNMENT_4K }',
        ),
        throwsA(isA<ReleaseFailure>()),
      );
    });

    test('requires an explicit jarsigner verification result', () {
      expect(
        () => requireJarsignerVerification('jar verified.'),
        returnsNormally,
      );
      expect(
        () => requireJarsignerVerification(
          'jar verified, with signer errors.\njar is unsigned.',
        ),
        throwsA(isA<ReleaseFailure>()),
      );
      expect(
        () => requireJarsignerVerification('jar is unsigned.'),
        throwsA(isA<ReleaseFailure>()),
      );
    });

    test('requires the exact Android permission allowlist', () {
      const manifest = '''
        <manifest>
          <uses-permission android:name="android.permission.INTERNET"/>
          <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
          <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
          <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
          <uses-permission android:name="android.permission.VIBRATE"/>
          <uses-permission android:name="pl.budowapro.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"/>
          <service android:permission="android.permission.BIND_JOB_SERVICE"/>
          <provider android:readPermission="android.permission.DUMP"/>
        </manifest>
      ''';

      expect(permissionsInManifest(manifest), expectedManifestPermissions);
      expect(unexpectedPermissionsInManifest(manifest), isEmpty);
      expect(() => requireSafeManifest(manifest), returnsNormally);
      expect(
        () => requireSafeManifest(
          '$manifest'
          '<uses-permission android:name="android.permission.CAMERA"/>',
        ),
        throwsA(
          isA<ReleaseFailure>().having(
            (error) => error.message,
            'message',
            contains('android.permission.CAMERA'),
          ),
        ),
      );
      expect(
        () => requireSafeManifest(
          '<uses-permission android:name="android.permission.INTERNET"/>',
        ),
        throwsA(isA<ReleaseFailure>()),
      );
    });

    test('reads and compares SHA-256 certificate fingerprints', () {
      const fingerprint =
          '01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:'
          '01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF';
      final parsed = certificateSha256FromKeytool('SHA256: $fingerprint');

      expect(
        parsed,
        '0123456789ABCDEF0123456789ABCDEF'
        '0123456789ABCDEF0123456789ABCDEF',
      );
      expect(
        () => requireExpectedCertificateSha256(
          expected: fingerprint,
          actual: parsed,
        ),
        returnsNormally,
      );
      expect(
        () => requireExpectedCertificateSha256(
          expected:
              'F123456789ABCDEF0123456789ABCDEF'
              '0123456789ABCDEF0123456789ABCDEF',
          actual: parsed,
        ),
        throwsA(isA<ReleaseFailure>()),
      );
    });

    test('requires 16 KB alignment for 64-bit ELF LOAD segments', () {
      final aligned = _elf64WithLoadAlignment(0x4000);
      final unaligned = _elf64WithLoadAlignment(0x1000);

      expect(
        () => require64BitElfLoadAlignment(
          name: 'lib/arm64-v8a/libapp.so',
          bytes: aligned,
        ),
        returnsNormally,
      );
      expect(
        () => require64BitElfLoadAlignment(
          name: 'lib/arm64-v8a/libapp.so',
          bytes: unaligned,
        ),
        throwsA(isA<ReleaseFailure>()),
      );
      expect(is64BitAndroidNativeLibrary('base/lib/x86_64/libapp.so'), isTrue);
      expect(
        is64BitAndroidNativeLibrary('base/lib/armeabi-v7a/libapp.so'),
        isFalse,
      );
    });

    test('requires release shrinking and optional ML Kit rules', () {
      const buildGradle = '''
        getByName("release") {
          isMinifyEnabled = true
          isShrinkResources = true
          proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro",
          )
        }
      ''';
      final rules = requiredMlKitR8Rules.join('\n');

      expect(
        () => requireAndroidReleaseShrinkerConfiguration(
          buildGradle: buildGradle,
          proguardRules: rules,
        ),
        returnsNormally,
      );
      expect(
        () => requireAndroidReleaseShrinkerConfiguration(
          buildGradle: buildGradle,
          proguardRules: rules.replaceFirst(requiredMlKitR8Rules.first, ''),
        ),
        throwsA(isA<ReleaseFailure>()),
      );
      expect(
        () => requireAndroidReleaseShrinkerConfiguration(
          buildGradle: buildGradle.replaceFirst(
            'isMinifyEnabled = true',
            'isMinifyEnabled = false',
          ),
          proguardRules: rules,
        ),
        throwsA(isA<ReleaseFailure>()),
      );
    });
  });
}

Map<String, String> _validEnvironment({
  String publisherName = 'BudowaPRO',
  String privacyEmail = 'kontakt@budowaproapp.pl',
  String privacyUrl = 'https://budowaproapp.pl/privacy/',
  String supportUrl = 'https://budowaproapp.pl/support/',
}) {
  return <String, String>{
    'BUDOWAPRO_UPLOAD_STORE_FILE': 'upload.jks',
    'BUDOWAPRO_UPLOAD_STORE_PASSWORD': 'store-secret',
    'BUDOWAPRO_UPLOAD_KEY_ALIAS': 'upload-alias',
    'BUDOWAPRO_UPLOAD_KEY_PASSWORD': 'key-secret',
    'BUDOWAPRO_UPLOAD_CERT_SHA256':
        '01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:'
        '01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF',
    'BUDOWAPRO_PUBLISHER_NAME': publisherName,
    'BUDOWAPRO_PRIVACY_CONTACT_EMAIL': privacyEmail,
    'BUDOWAPRO_PRIVACY_POLICY_URL': privacyUrl,
    'BUDOWAPRO_SUPPORT_URL': supportUrl,
  };
}

List<int> _elf64WithLoadAlignment(int alignment) {
  final bytes = Uint8List(64 + 56);
  bytes.setAll(0, const <int>[0x7F, 0x45, 0x4C, 0x46, 2, 1]);
  final data = ByteData.sublistView(bytes);
  data.setUint64(32, 64, Endian.little);
  data.setUint16(54, 56, Endian.little);
  data.setUint16(56, 1, Endian.little);
  data.setUint32(64, 1, Endian.little);
  data.setUint64(64 + 48, alignment, Endian.little);
  return bytes;
}
