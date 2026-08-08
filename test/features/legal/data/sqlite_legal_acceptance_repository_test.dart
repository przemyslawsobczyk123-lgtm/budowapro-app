import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/features/legal/data/sqlite_legal_acceptance_repository.dart';
import 'package:budowapro/features/legal/domain/legal_acceptance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory root;
  late AppDatabase database;
  late SqliteLegalAcceptanceRepository repository;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_legal_acceptance_');
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(root.path, AppDatabase.databaseFileName),
    );
    await database.open();
    repository = SqliteLegalAcceptanceRepository(
      database,
      utcNow: () => DateTime.utc(2026, 8, 8, 12, 30),
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  test('requires acceptance until the current terms are confirmed', () async {
    expect(await repository.hasAcceptedCurrentTerms(), isFalse);

    await repository.acceptCurrentTerms();

    expect(await repository.hasAcceptedCurrentTerms(), isTrue);
    final sql = await database.open();
    final rows = await sql.query(
      AppDatabase.metadataTable,
      where: 'key = ?',
      whereArgs: const ['legal_terms_accepted_version'],
    );
    expect(rows.single['value'], LegalDocumentRevision.current);
    expect(rows.single['updated_at_utc_ms'], 1786192200000);
  });

  test('an older accepted revision does not unlock new terms', () async {
    final sql = await database.open();
    await sql.insert(AppDatabase.metadataTable, <String, Object?>{
      'key': 'legal_terms_accepted_version',
      'value': '1.2',
      'updated_at_utc_ms': 0,
    });

    expect(await repository.hasAcceptedCurrentTerms(), isFalse);
  });
}
