import 'contact.dart';

final class DeviceContactSelection {
  factory DeviceContactSelection({
    required String displayName,
    required String phone,
  }) {
    final normalizedName = displayName.trim();
    final normalizedPhone = phone.trim();
    if (normalizedName.isEmpty ||
        normalizedName.length > ContactFieldLimits.displayName) {
      throw ArgumentError.value(displayName, 'displayName');
    }
    if (normalizedPhone.isEmpty ||
        normalizedPhone.length > ContactFieldLimits.phone) {
      throw ArgumentError.value(phone, 'phone');
    }
    return DeviceContactSelection._(
      displayName: normalizedName,
      phone: normalizedPhone,
    );
  }

  const DeviceContactSelection._({
    required this.displayName,
    required this.phone,
  });

  final String displayName;
  final String phone;
}

abstract interface class DeviceContactPicker {
  Future<DeviceContactSelection?> pick();
}

enum DeviceContactPickerFailure { unavailable, invalidSelection }

final class DeviceContactPickerException implements Exception {
  const DeviceContactPickerException(this.kind);

  final DeviceContactPickerFailure kind;
}
