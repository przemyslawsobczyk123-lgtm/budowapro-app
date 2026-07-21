import 'dart:math';

import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_cost_repository.dart';

final costRepositoryProvider = FutureProvider<CostRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteCostRepository(
    database: database,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final costAttachmentStagerProvider = localAttachmentStagerProvider;

final costAttachmentPickerProvider = localAttachmentPickerProvider;

String _secureId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
