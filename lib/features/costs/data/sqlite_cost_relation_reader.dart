import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/features/costs/domain/cost_relation.dart';

final class SqliteCostRelationReader implements CostRelationReader {
  const SqliteCostRelationReader(this._database);

  final AppDatabase _database;

  @override
  Future<CostRelations> load({
    required String projectId,
    required String costEntryId,
  }) async {
    final database = await _database.open();
    final roomRows = await database.rawQuery(
      '''
      SELECT room.id, room.name
      FROM ${AppDatabase.roomRecordLinksTable} link
      JOIN ${AppDatabase.roomsTable} room
        ON room.project_id = link.project_id AND room.id = link.room_id
      WHERE link.project_id = ?
        AND link.record_type = 'cost'
        AND link.record_id = ?
      LIMIT 1
      ''',
      <Object?>[projectId, costEntryId],
    );
    final materialRows = await database.rawQuery(
      '''
      SELECT id, name
      FROM ${AppDatabase.materialsTable}
      WHERE project_id = ? AND cost_entry_id = ?
      ORDER BY name COLLATE NOCASE ASC, id ASC
      LIMIT 100
      ''',
      <Object?>[projectId, costEntryId],
    );
    return CostRelations(<CostRelationReference>[
      for (final row in roomRows)
        CostRelationReference(
          type: CostRelationType.room,
          recordId: row['id']! as String,
          label: row['name']! as String,
        ),
      for (final row in materialRows)
        CostRelationReference(
          type: CostRelationType.material,
          recordId: row['id']! as String,
          label: row['name']! as String,
        ),
    ]);
  }
}
