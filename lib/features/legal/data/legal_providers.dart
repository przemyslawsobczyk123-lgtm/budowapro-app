import 'package:budowapro/features/legal/data/legal_link_gateway.dart';
import 'package:budowapro/features/legal/data/local_data_deletion_service.dart';
import 'package:budowapro/features/legal/domain/app_build_info.dart';
import 'package:budowapro/features/legal/domain/legal_release_config.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/shared/services/local_private_cache_cleaner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final legalReleaseConfigProvider = Provider<LegalReleaseConfig>(
  (ref) => const LegalReleaseConfig.fromEnvironment(),
);

final legalLinkGatewayProvider = Provider<LegalLinkGateway>(
  (ref) => const SystemLegalLinkGateway(),
);

final localDataDeletionProvider = FutureProvider<LocalDataDeletion>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final fileStore = await ref.watch(projectFileStoreProvider.future);
  return LocalDataDeletionService(
    database,
    fileStore,
    LocalPrivateCacheCleaner.forDevice().clean,
  );
});

final appBuildInfoProvider = FutureProvider<AppBuildInfo>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return AppBuildInfo(
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
    packageName: packageInfo.packageName,
  );
});
