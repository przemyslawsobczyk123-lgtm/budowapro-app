import 'dart:math';

import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_material_repository.dart';

final materialRepositoryProvider = FutureProvider<MaterialRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteMaterialRepository(
    database: database,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final materialNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
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
