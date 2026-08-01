import 'dart:math';

import 'package:budowapro/features/captures/domain/capture_repository.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/diary/data/sqlite_journal_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/schedule/data/sqlite_schedule_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'capture_attachment_picker.dart';
import 'sqlite_capture_repository.dart';

final captureRepositoryProvider = FutureProvider<CaptureRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteCaptureRepository(
    database: database,
    costRepository: SqliteCostRepository(
      database: database,
      idGenerator: _secureId,
      utcNow: DateTime.now,
    ),
    documentRepository: SqliteDocumentRepository(
      database: database,
      utcNow: DateTime.now,
    ),
    scheduleRepository: SqliteScheduleRepository(
      database: database,
      idGenerator: _secureId,
      utcNow: DateTime.now,
    ),
    diaryRepository: SqliteJournalRepository(
      database: database,
      idGenerator: _secureId,
      utcNow: DateTime.now,
    ),
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final captureAttachmentPickerProvider = Provider<CaptureAttachmentPicker>((
  ref,
) {
  return FilePickerCaptureAttachmentPicker();
});

final captureAttachmentStagerProvider = localAttachmentStagerProvider;

String _secureId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
