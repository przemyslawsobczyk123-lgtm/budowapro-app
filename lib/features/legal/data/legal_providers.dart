import 'package:budowapro/features/legal/data/legal_link_gateway.dart';
import 'package:budowapro/features/legal/domain/legal_release_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final legalReleaseConfigProvider = Provider<LegalReleaseConfig>(
  (ref) => const LegalReleaseConfig.fromEnvironment(),
);

final legalLinkGatewayProvider = Provider<LegalLinkGateway>(
  (ref) => const SystemLegalLinkGateway(),
);
