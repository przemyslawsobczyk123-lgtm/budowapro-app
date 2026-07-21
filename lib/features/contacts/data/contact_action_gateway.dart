import 'package:url_launcher/url_launcher.dart';

abstract interface class ContactActionGateway {
  Future<void> call(String phone);

  Future<void> email(String address);
}

final class UrlLauncherContactActionGateway implements ContactActionGateway {
  UrlLauncherContactActionGateway({Future<bool> Function(Uri uri)? launcher})
    : _launcher = launcher ?? launchUrl;

  final Future<bool> Function(Uri uri) _launcher;

  @override
  Future<void> call(String phone) {
    final normalized = _requiredValue(
      phone,
      'phone',
    ).replaceAll(RegExp(r'\s+'), '');
    return _launch(Uri(scheme: 'tel', path: normalized));
  }

  @override
  Future<void> email(String address) {
    return _launch(
      Uri(scheme: 'mailto', path: _requiredValue(address, 'address')),
    );
  }

  Future<void> _launch(Uri uri) async {
    if (!await _launcher(uri)) {
      throw const ContactActionUnavailableException();
    }
  }
}

final class ContactActionUnavailableException implements Exception {
  const ContactActionUnavailableException();
}

String _requiredValue(String value, String name) {
  final normalized = value.trim();
  if (normalized.isEmpty) throw ArgumentError.value(value, name);
  return normalized;
}
