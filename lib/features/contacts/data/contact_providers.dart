import 'dart:math';

import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/contacts/domain/site_visit_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contact_action_gateway.dart';
import 'sqlite_contact_repository.dart';
import 'sqlite_site_visit_repository.dart';

final contactRepositoryProvider = FutureProvider<ContactRepository>((
  ref,
) async {
  return SqliteContactRepository(
    database: await ref.watch(appDatabaseProvider.future),
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final siteVisitRepositoryProvider = FutureProvider<SiteVisitRepository>((
  ref,
) async {
  return SqliteSiteVisitRepository(
    database: await ref.watch(appDatabaseProvider.future),
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final contactActionGatewayProvider = Provider<ContactActionGateway>((ref) {
  return UrlLauncherContactActionGateway();
});

String _secureId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
