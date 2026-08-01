import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_relation_reader.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_relation.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/materials/data/sqlite_material_repository.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/rooms/data/sqlite_room_repository.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory root;
  late String databasePath;
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 1, 12);
  var nextId = 0;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_cost_relation_');
    databasePath = p.join(root.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(root.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: () => now,
    ).create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test('loads current room and materials linked to a cost', () async {
    final cost =
        await SqliteCostRepository(
          database: database,
          idGenerator: () => 'cost-1',
          utcNow: () => now,
        ).create(
          ConfirmedCostEntryInput(
            CostEntryInput(
              projectId: 'project-1',
              name: 'Płytki łazienkowe',
              type: CostEntryType.cost,
              component: CostComponent.material,
              status: CostStatus.paid,
              amount: VatBreakdown.fromGross(
                Money(minorUnits: 120000, currencyCode: 'PLN'),
                VatRate.standard23,
              ),
              entryDate: now,
            ),
          ),
        );
    final rooms = SqliteRoomRepository(
      database: database,
      idGenerator: () => 'room-${++nextId}',
      utcNow: () => now,
    );
    final room = await rooms.createRoom(
      RoomInput(
        projectId: 'project-1',
        name: 'Łazienka',
        standard: RoomStandard.standard,
      ),
    );
    await rooms.assignRecord(
      projectId: 'project-1',
      roomId: room.id,
      type: RoomRecordType.cost,
      recordId: cost.id,
    );
    final materials = SqliteMaterialRepository(
      database: database,
      idGenerator: () => 'material-${++nextId}',
      utcNow: () => now,
    );
    final material = await materials.create(
      MaterialInput(
        projectId: 'project-1',
        name: 'Gres 60x60',
        orderedQuantity: MaterialQuantity(unscaledValue: 24, scale: 0),
        unit: 'm²',
        costEntryId: cost.id,
      ),
    );

    final relations = await SqliteCostRelationReader(
      database,
    ).load(projectId: 'project-1', costEntryId: cost.id);

    expect(
      relations.items,
      contains(
        CostRelationReference(
          type: CostRelationType.room,
          recordId: room.id,
          label: 'Łazienka',
        ),
      ),
    );
    expect(
      relations.items,
      contains(
        CostRelationReference(
          type: CostRelationType.material,
          recordId: material.id,
          label: 'Gres 60x60',
        ),
      ),
    );
  });
}
