import 'package:url_launcher/url_launcher.dart';

abstract interface class LegalLinkGateway {
  Future<bool> openExternal(Uri uri);
}

final class SystemLegalLinkGateway implements LegalLinkGateway {
  const SystemLegalLinkGateway();

  @override
  Future<bool> openExternal(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
