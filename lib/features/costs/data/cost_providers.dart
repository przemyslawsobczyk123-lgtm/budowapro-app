import 'dart:math';

import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cost_attachment_picker.dart';
import 'cost_attachment_stager.dart';
import 'sqlite_cost_repository.dart';

final costRepositoryProvider = FutureProvider<CostRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteCostRepository(
    database: database,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final costAttachmentStagerProvider = FutureProvider<CostAttachmentStager>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final fileStore = await ref.watch(projectFileStoreProvider.future);
  final stager = CostAttachmentStager(
    database: database,
    fileStore: fileStore,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
  await stager.recoverInterruptedImports();
  await stager.recoverInterruptedDeletions();
  await stager.recoverUnlinkedAttachments();
  return stager;
});

final costAttachmentPickerProvider = Provider<CostAttachmentPicker>((ref) {
  return FilePickerCostAttachmentPicker();
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
