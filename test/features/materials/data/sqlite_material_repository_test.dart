import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/materials/data/sqlite_material_repository.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteMaterialRepository repository;
  var nextId = 0;
  final now = DateTime.utc(2026, 8, 1, 12);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_material_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
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
    repository = SqliteMaterialRepository(
      database: database,
      idGenerator: () => 'record-${++nextId}',
      utcNow: () => now,
    );
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  MaterialInput materialInput() => MaterialInput(
    projectId: 'project-1',
    name: 'Bloczek silikatowy',
    orderedQuantity: _quantity(10),
    unit: 'pal.',
    stageId: 'state_zero',
    orderedAt: DateTime.utc(2026, 7, 20),
    orderedGross: Money(minorUnits: 125000, currencyCode: 'PLN'),
    storageLocation: 'Plac przy bramie',
  );

  MaterialDeliveryInput deliveryInput(
    String materialId, {
    required int delivered,
    required String suffix,
  }) {
    return MaterialDeliveryInput(
      projectId: 'project-1',
      materialId: materialId,
      expectedQuantity: _quantity(delivered),
      dueAt: DateTime.utc(2026, 7, 30),
      deliveredQuantity: _quantity(delivered),
      receivedAt: DateTime.utc(2026, 7, 30),
      shortageNote: suffix,
    );
  }

  test('creates and pages materials with stage and cost value', () async {
    final created = await repository.create(materialInput());

    final page = await repository.list(
      MaterialQuery(projectId: 'project-1'),
      PageRequest(limit: 30),
      now: now,
    );

    expect(page.totalCount, 1);
    expect(page.items.single.id, created.id);
    expect(page.items.single.input.stageId, 'state_zero');
    expect(page.items.single.input.orderedGross?.minorUnits, 125000);
    expect(page.items.single.statusAt(now), MaterialStatus.ordered);
  });

  test('requires explicit correction before accepting over-delivery', () async {
    final material = await repository.create(materialInput());
    await repository.saveDelivery(
      input: deliveryInput(material.id, delivered: 6, suffix: 'a'),
    );

    await expectLater(
      repository.saveDelivery(
        input: deliveryInput(material.id, delivered: 5, suffix: 'b'),
      ),
      throwsA(isA<MaterialOverDeliveryConfirmationRequired>()),
    );

    await repository.saveDelivery(
      input: deliveryInput(material.id, delivered: 5, suffix: 'b'),
      confirmOrderedQuantityCorrection: true,
    );
    final reloaded = await repository.findById(
      projectId: 'project-1',
      materialId: material.id,
    );

    expect(reloaded!.input.orderedQuantity, _quantity(11));
    expect(reloaded.deliveredQuantity, _quantity(11));
    expect(reloaded.statusAt(now), MaterialStatus.delivered);
  });

  test('reports delayed deliveries and overdue return value', () async {
    final material = await repository.create(materialInput());
    await repository.saveDelivery(
      input: MaterialDeliveryInput(
        projectId: 'project-1',
        materialId: material.id,
        expectedQuantity: _quantity(10),
        dueAt: DateTime.utc(2026, 7, 30),
      ),
    );
    await repository.saveReturn(
      input: MaterialReturnInput(
        projectId: 'project-1',
        materialId: material.id,
        quantity: _quantity(2),
        deadline: DateTime.utc(2026, 7, 31),
        expectedRefund: Money(minorUnits: 25000, currencyCode: 'PLN'),
        receiptRequired: true,
      ),
    );

    final summary = await repository.summarize(
      projectId: 'project-1',
      currencyCode: 'PLN',
      now: now,
    );
    final delayed = await repository.list(
      MaterialQuery(
        projectId: 'project-1',
        statuses: const <MaterialStatus>{MaterialStatus.delayed},
      ),
      PageRequest(),
      now: now,
    );

    expect(summary.orderedValue.minorUnits, 125000);
    expect(summary.expectedReturnValue.minorUnits, 25000);
    expect(summary.delayedCount, 1);
    expect(summary.overdueReturnCount, 1);
    expect(summary.openDeliveryCount, 1);
    expect(delayed.items, hasLength(1));
  });

  test('does not delete a material with an open delivery', () async {
    final material = await repository.create(materialInput());
    await repository.saveDelivery(
      input: MaterialDeliveryInput(
        projectId: 'project-1',
        materialId: material.id,
        expectedQuantity: _quantity(10),
        dueAt: DateTime.utc(2026, 8, 3),
      ),
    );

    await expectLater(
      repository.delete(projectId: 'project-1', materialId: material.id),
      throwsA(
        isA<MaterialInUseException>().having(
          (error) => error.deliveryCount,
          'deliveryCount',
          1,
        ),
      ),
    );
    expect(
      await repository.findById(
        projectId: 'project-1',
        materialId: material.id,
      ),
      isNotNull,
    );
  });

  test('does not delete a material with completed delivery history', () async {
    final material = await repository.create(materialInput());
    await repository.saveDelivery(
      input: deliveryInput(material.id, delivered: 10, suffix: 'odebrana'),
    );

    await expectLater(
      repository.delete(projectId: 'project-1', materialId: material.id),
      throwsA(
        isA<MaterialInUseException>().having(
          (error) => error.deliveryCount,
          'deliveryCount',
          1,
        ),
      ),
    );
    expect(
      await repository.findById(
        projectId: 'project-1',
        materialId: material.id,
      ),
      isNotNull,
    );
  });

  test('deleting a material removes its room choice output', () async {
    final material = await repository.create(materialInput());
    final executor = await database.open();
    await executor.insert(AppDatabase.roomsTable, <String, Object?>{
      'id': 'room-1',
      'project_id': 'project-1',
      'name': 'Kuchnia',
      'floor_label': '',
      'standard': 'standard',
      'created_at_utc_ms': 0,
      'updated_at_utc_ms': 0,
    });
    await executor.insert(AppDatabase.roomChoicesTable, <String, Object?>{
      'id': 'choice-1',
      'project_id': 'project-1',
      'room_id': 'room-1',
      'title': 'Płytki',
      'status': 'selected',
      'created_at_utc_ms': 0,
      'updated_at_utc_ms': 0,
    });
    await executor.insert(AppDatabase.roomChoiceOutputsTable, <String, Object?>{
      'project_id': 'project-1',
      'choice_id': 'choice-1',
      'output_type': 'material',
      'record_id': material.id,
      'created_at_utc_ms': 0,
    });

    await repository.delete(projectId: 'project-1', materialId: material.id);

    expect(
      await executor.query(
        AppDatabase.roomChoiceOutputsTable,
        where: 'project_id = ? AND output_type = ? AND record_id = ?',
        whereArgs: <Object?>['project-1', 'material', material.id],
      ),
      isEmpty,
    );
  });

  test(
    'stores a completed return with only the actual refund entered',
    () async {
      final material = await repository.create(materialInput());
      await repository.saveDelivery(
        input: deliveryInput(material.id, delivered: 10, suffix: 'pełna'),
      );

      final saved = await repository.saveReturn(
        input: MaterialReturnInput(
          projectId: 'project-1',
          materialId: material.id,
          quantity: _quantity(1),
          deadline: DateTime.utc(2026, 8, 2),
          receiptRequired: false,
          completedAt: now,
          actualRefund: Money(minorUnits: 15000, currencyCode: 'PLN'),
        ),
      );
      final reloaded = await repository.findById(
        projectId: 'project-1',
        materialId: material.id,
      );

      expect(saved.input.expectedRefund?.minorUnits, 15000);
      expect(reloaded!.returns.single.input.actualRefund?.minorUnits, 15000);
    },
  );
}

MaterialQuantity _quantity(int value) =>
    MaterialQuantity(unscaledValue: value, scale: 0);
