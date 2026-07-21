import 'dart:math';

import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_attachment_picker.dart';
import 'local_attachment_stager.dart';
import 'local_document_preview_generator.dart';
import 'sqlite_document_repository.dart';

final documentRepositoryProvider = FutureProvider<DocumentRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteDocumentRepository(database: database, utcNow: DateTime.now);
});

final localAttachmentStagerProvider = FutureProvider<LocalAttachmentStager>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final fileStore = await ref.watch(projectFileStoreProvider.future);
  final stager = LocalAttachmentStager(
    database: database,
    fileStore: fileStore,
    idGenerator: _secureId,
    utcNow: DateTime.now,
    previewGenerator: LocalDocumentPreviewGenerator(fileStore: fileStore),
  );
  await stager.recoverInterruptedImports();
  await stager.recoverInterruptedDeletions();
  await stager.recoverUnlinkedAttachments();
  return stager;
});

final localAttachmentPickerProvider = Provider<LocalAttachmentPicker>((ref) {
  return FilePickerLocalAttachmentPicker();
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
