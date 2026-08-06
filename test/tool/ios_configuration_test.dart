import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS keeps local data out of iCloud and scans multiple pages', () async {
    final appDelegate = await File(
      'ios/Runner/AppDelegate.swift',
    ).readAsString();

    expect(appDelegate, contains('values.isExcludedFromBackup = true'));
    expect(
      appDelegate,
      contains('guard excludeApplicationSupportFromBackup() else'),
    );
    expect(appDelegate, isNot(contains('assertionFailure(')));
    expect(appDelegate, contains('let pageCount = min(scan.pageCount, 20)'));
    expect(appDelegate, contains('let document = PDFDocument()'));
    expect(
      appDelegate,
      contains('.appendingPathComponent("budowapro-receipt-'),
    );
    expect(appDelegate, contains('.pdf")'));
  });

  test(
    'iOS plist does not declare a nonstandard notification usage key',
    () async {
      final infoPlist = await File('ios/Runner/Info.plist').readAsString();

      expect(infoPlist, isNot(contains('NSUserNotificationsUsageDescription')));
    },
  );
}
