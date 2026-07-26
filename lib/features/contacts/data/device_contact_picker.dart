import 'package:budowapro/features/contacts/domain/device_contact.dart';
import 'package:flutter/services.dart';

typedef PickDeviceContact = Future<Map<Object?, Object?>?> Function();

final class MethodChannelDeviceContactPicker implements DeviceContactPicker {
  MethodChannelDeviceContactPicker({PickDeviceContact? pickContact})
    : _pickContact = pickContact ?? _pickNativeContact;

  static const MethodChannel _channel = MethodChannel(
    'pl.budowapro/device_contacts',
  );

  final PickDeviceContact _pickContact;

  @override
  Future<DeviceContactSelection?> pick() async {
    final Map<Object?, Object?>? response;
    try {
      response = await _pickContact();
    } on MissingPluginException {
      throw const DeviceContactPickerException(
        DeviceContactPickerFailure.unavailable,
      );
    } on PlatformException catch (error) {
      throw DeviceContactPickerException(
        error.code == 'contact_picker_unavailable'
            ? DeviceContactPickerFailure.unavailable
            : DeviceContactPickerFailure.invalidSelection,
      );
    } on DeviceContactPickerException {
      rethrow;
    } on Object {
      throw const DeviceContactPickerException(
        DeviceContactPickerFailure.invalidSelection,
      );
    }
    if (response == null) return null;
    final displayName = response['displayName'];
    final phone = response['phone'];
    if (displayName is! String || phone is! String) {
      throw const DeviceContactPickerException(
        DeviceContactPickerFailure.invalidSelection,
      );
    }
    try {
      return DeviceContactSelection(displayName: displayName, phone: phone);
    } on ArgumentError {
      throw const DeviceContactPickerException(
        DeviceContactPickerFailure.invalidSelection,
      );
    }
  }

  static Future<Map<Object?, Object?>?> _pickNativeContact() {
    return _channel.invokeMapMethod<Object?, Object?>('pickPhoneContact');
  }
}
