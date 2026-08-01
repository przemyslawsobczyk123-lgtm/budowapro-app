import 'dart:math';

import 'package:budowapro/features/diary/domain/journal_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_journal_repository.dart';

final journalRepositoryProvider = FutureProvider<JournalRepository>((
  ref,
) async {
  return SqliteJournalRepository(
    database: await ref.watch(appDatabaseProvider.future),
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
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
