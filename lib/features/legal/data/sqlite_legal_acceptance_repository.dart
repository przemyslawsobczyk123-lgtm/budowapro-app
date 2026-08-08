import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/features/legal/domain/legal_acceptance.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteLegalAcceptanceRepository
    implements LegalAcceptanceRepository {
  SqliteLegalAcceptanceRepository(this._database, {DateTime Function()? utcNow})
    : _utcNow = utcNow ?? (() => DateTime.now().toUtc());

  static const _acceptedVersionKey = 'legal_terms_accepted_version';

  final AppDatabase _database;
  final DateTime Function() _utcNow;

  @override
  Future<bool> hasAcceptedCurrentTerms() async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.metadataTable,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: const [_acceptedVersionKey],
      limit: 1,
    );
    return rows.isNotEmpty &&
        rows.single['value'] == LegalDocumentRevision.current;
  }

  @override
  Future<void> acceptCurrentTerms() async {
    final database = await _database.open();
    await database.insert(AppDatabase.metadataTable, <String, Object?>{
      'key': _acceptedVersionKey,
      'value': LegalDocumentRevision.current,
      'updated_at_utc_ms': _utcNow().toUtc().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
