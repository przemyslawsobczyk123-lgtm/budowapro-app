import 'dart:math';

import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/quotes/domain/quote_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_quote_repository.dart';

final quoteRepositoryProvider = FutureProvider<QuoteRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final costRepository = SqliteCostRepository(
    database: database,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
  return SqliteQuoteRepository(
    database: database,
    costRepository: costRepository,
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
