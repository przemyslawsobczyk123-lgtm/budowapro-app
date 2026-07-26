import 'dart:io';

import 'package:budowapro/features/contacts/data/device_contact_picker.dart';
import 'package:budowapro/features/contacts/domain/device_contact.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('does not request broad Android contacts permission', () async {
    final manifest = await File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsString();

    expect(manifest, isNot(contains('android.permission.READ_CONTACTS')));
    expect(manifest, isNot(contains('android.permission.WRITE_CONTACTS')));
  });

  test('maps one user-selected phone contact', () async {
    final picker = MethodChannelDeviceContactPicker(
      pickContact: () async => <Object?, Object?>{
        'displayName': 'Jan Kowalski',
        'phone': '+48 500 600 700',
      },
    );

    final selection = await picker.pick();

    expect(selection?.displayName, 'Jan Kowalski');
    expect(selection?.phone, '+48 500 600 700');
  });

  test('returns no selection when the system picker is cancelled', () async {
    final picker = MethodChannelDeviceContactPicker(
      pickContact: () async => null,
    );

    expect(await picker.pick(), isNull);
  });

  test('rejects malformed native contact data', () async {
    final picker = MethodChannelDeviceContactPicker(
      pickContact: () async => <Object?, Object?>{
        'displayName': '',
        'phone': '+48 500 600 700',
      },
    );

    await expectLater(
      picker.pick(),
      throwsA(
        isA<DeviceContactPickerException>().having(
          (error) => error.kind,
          'kind',
          DeviceContactPickerFailure.invalidSelection,
        ),
      ),
    );
  });

  test('maps an unavailable native picker to a stable failure', () async {
    final picker = MethodChannelDeviceContactPicker(
      pickContact: () =>
          throw PlatformException(code: 'contact_picker_unavailable'),
    );

    await expectLater(
      picker.pick(),
      throwsA(
        isA<DeviceContactPickerException>().having(
          (error) => error.kind,
          'kind',
          DeviceContactPickerFailure.unavailable,
        ),
      ),
    );
  });
}
