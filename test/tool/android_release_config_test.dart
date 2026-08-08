import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release validates every externally configured legal field', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    for (final field in <String>[
      'BUDOWAPRO_PUBLISHER_NAME',
      'BUDOWAPRO_PRIVACY_CONTACT_EMAIL',
      'BUDOWAPRO_PRIVACY_POLICY_URL',
      'BUDOWAPRO_SUPPORT_URL',
    ]) {
      expect(gradle, contains(field));
    }
    expect(gradle, contains('requiredLegalDefines'));
    expect(gradle, contains('publicLegalUrls'));
  });
}
