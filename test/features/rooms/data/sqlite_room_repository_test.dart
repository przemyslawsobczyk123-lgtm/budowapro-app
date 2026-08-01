import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/diary/data/sqlite_journal_repository.dart';
import 'package:budowapro/features/materials/data/sqlite_material_repository.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/rooms/data/sqlite_room_repository.dart';
import 'package:budowapro/features/rooms/data/room_choice_output_service.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteRoomRepository repository;
  final now = DateTime.utc(2026, 7, 31, 12);
  var sequence = 0;

  setUp(() async {
    sequence = 0;
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_room_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-${++sequence}',
      utcNow: () => now,
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
        currencyCode: 'PLN',
      ),
    );
    await projects.create(
      ProjectDraft(
        name: 'Mieszkanie',
        type: ProjectType.apartmentRenovation,
        template: ProjectTemplate.renovation,
        currencyCode: 'PLN',
      ),
    );
    repository = SqliteRoomRepository(
      database: database,
      idGenerator: () => 'room-${++sequence}',
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

  test('creates, pages and updates project-isolated rooms', () async {
    final room = await repository.createRoom(
      RoomInput(
        projectId: 'project-1',
        name: 'Kuchnia',
        floorLabel: 'Parter',
        standard: RoomStandard.elevated,
        plannedBudget: Money(minorUnits: 5000000, currencyCode: 'PLN'),
      ),
    );
    await repository.createRoom(
      RoomInput(
        projectId: 'project-2',
        name: 'Kuchnia',
        standard: RoomStandard.standard,
      ),
    );

    final page = await repository.listRooms(
      RoomQuery(projectId: 'project-1', searchText: 'kuch'),
      PageRequest(limit: 20),
    );
    final updated = await repository.updateRoom(
      projectId: 'project-1',
      roomId: room.id,
      input: RoomInput(
        projectId: 'project-1',
        name: 'Kuchnia i jadalnia',
        floorLabel: 'Parter',
        standard: RoomStandard.elevated,
      ),
    );

    expect(page.items.single.room.id, room.id);
    expect(page.totalCount, 1);
    expect(updated.name, 'Kuchnia i jadalnia');
    await expectLater(
      repository.createRoom(
        RoomInput(
          projectId: 'project-1',
          name: 'KUCHNIA I JADALNIA',
          floorLabel: 'parter',
          standard: RoomStandard.standard,
        ),
      ),
      throwsA(isA<RoomConflictException>()),
    );
  });

  test(
    'persists variants and changes selection only through explicit action',
    () async {
      final room = await _createRoom(repository);
      final choice = await repository.createChoice(
        input: RoomChoiceInput(
          projectId: 'project-1',
          roomId: room.id,
          title: 'Plytki',
          quantity: DecimalQuantity(unscaledValue: 120, scale: 1),
          unit: 'm2',
          wasteBasisPoints: 1000,
          orderDue: DateTime.utc(2026, 8, 20),
        ),
        variants: <RoomChoiceVariantInput>[
          RoomChoiceVariantInput(
            projectId: 'project-1',
            label: 'Gres A',
            unitGrossPrice: Money(minorUnits: 10000, currencyCode: 'PLN'),
          ),
          RoomChoiceVariantInput(
            projectId: 'project-1',
            label: 'Gres B',
            unitGrossPrice: Money(minorUnits: 12500, currencyCode: 'PLN'),
          ),
        ],
      );

      expect(choice.status, RoomChoiceStatus.open);
      expect(choice.selectedVariantId, isNull);
      final selected = await repository.selectVariant(
        projectId: 'project-1',
        choiceId: choice.id,
        variantId: choice.variants.last.id,
      );
      final reopened = await repository.reopenChoice(
        projectId: 'project-1',
        choiceId: choice.id,
      );

      expect(selected.status, RoomChoiceStatus.selected);
      expect(selected.selectedVariantId, choice.variants.last.id);
      expect(selected.estimatedGross?.minorUnits, 165000);
      expect(reopened.status, RoomChoiceStatus.open);
      expect(reopened.selectedVariantId, isNull);

      await repository.deleteChoice(
        projectId: 'project-1',
        choiceId: choice.id,
      );
      final details = await repository.findRoomDetails(
        projectId: 'project-1',
        roomId: room.id,
      );
      expect(details!.choices, isEmpty);
      await expectLater(
        repository.deleteChoice(projectId: 'project-1', choiceId: choice.id),
        throwsA(isA<RoomChoiceNotFoundException>()),
      );
    },
  );

  test(
    'summarizes linked costs, contacts, photos, decisions and defects',
    () async {
      final room = await _createRoom(repository);
      final handle = await database.open();
      await handle.insert(AppDatabase.contactsTable, <String, Object?>{
        'id': 'contact-1',
        'project_id': 'project-1',
        'display_name': 'Elektryk',
        'kind': 'person',
        'is_archived': 0,
        'created_at_utc_ms': now.millisecondsSinceEpoch,
        'updated_at_utc_ms': now.millisecondsSinceEpoch,
      });
      await handle.insert(AppDatabase.journalEntriesTable, <String, Object?>{
        'id': 'decision-1',
        'project_id': 'project-1',
        'entry_type': 'decision',
        'status': 'pending',
        'title': 'Kolor scian',
        'occurred_at_utc_ms': now.millisecondsSinceEpoch,
        'created_at_utc_ms': now.millisecondsSinceEpoch,
        'updated_at_utc_ms': now.millisecondsSinceEpoch,
        'revision': 1,
      });
      await handle.insert(AppDatabase.journalEntriesTable, <String, Object?>{
        'id': 'defect-1',
        'project_id': 'project-1',
        'entry_type': 'defect',
        'status': 'open',
        'title': 'Rysa na tynku',
        'defect_severity': 'medium',
        'requires_resolution_photo': 0,
        'requires_signed_protocol': 0,
        'occurred_at_utc_ms': now.millisecondsSinceEpoch,
        'created_at_utc_ms': now.millisecondsSinceEpoch,
        'updated_at_utc_ms': now.millisecondsSinceEpoch,
        'revision': 1,
      });
      await handle.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
        'id': 'photo-1',
        'project_id': 'project-1',
        'display_name': 'sciana.jpg',
        'original_storage_key': 'originals/sciana.jpg',
        'media_type': 'image/jpeg',
        'byte_size': 100,
        'source': 'camera',
        'availability': 'available',
        'imported_at_utc_ms': now.millisecondsSinceEpoch,
      });
      await handle.insert(AppDatabase.technicalAlbumsTable, <String, Object?>{
        'id': 'album-1',
        'project_id': 'project-1',
        'title': 'Powykonawcze',
        'album_kind': 'asBuilt',
        'created_at_utc_ms': now.millisecondsSinceEpoch,
        'updated_at_utc_ms': now.millisecondsSinceEpoch,
      });
      await handle.insert(AppDatabase.technicalPhotosTable, <String, Object?>{
        'project_id': 'project-1',
        'attachment_id': 'photo-1',
        'album_id': 'album-1',
        'title': 'Przewody przed tynkiem',
        'captured_at_utc_ms': now.millisecondsSinceEpoch,
        'installation_type': 'electrical',
        'created_at_utc_ms': now.millisecondsSinceEpoch,
        'updated_at_utc_ms': now.millisecondsSinceEpoch,
      });
      final costRepository = SqliteCostRepository(
        database: database,
        idGenerator: () => 'cost-1',
        utcNow: () => now,
      );
      final cost = await costRepository.create(
        ConfirmedCostEntryInput(
          CostEntryInput(
            projectId: 'project-1',
            name: 'Elektryka kuchni',
            type: CostEntryType.cost,
            component: CostComponent.labor,
            status: CostStatus.paid,
            amount: VatBreakdown.fromGross(
              Money(minorUnits: 250000, currencyCode: 'PLN'),
              VatRate.standard23,
            ),
            entryDate: now,
          ),
        ),
      );

      await repository.setContactLinked(
        projectId: 'project-1',
        roomId: room.id,
        contactId: 'contact-1',
        isLinked: true,
      );
      await repository.assignRecord(
        projectId: 'project-1',
        roomId: room.id,
        type: RoomRecordType.cost,
        recordId: cost.id,
      );
      await repository.assignRecord(
        projectId: 'project-1',
        roomId: room.id,
        type: RoomRecordType.journal,
        recordId: 'decision-1',
      );
      await repository.assignRecord(
        projectId: 'project-1',
        roomId: room.id,
        type: RoomRecordType.journal,
        recordId: 'defect-1',
      );
      await repository.assignRecord(
        projectId: 'project-1',
        roomId: room.id,
        type: RoomRecordType.technicalPhoto,
        recordId: 'photo-1',
      );

      final costCandidates = await repository.listRelationCandidates(
        projectId: 'project-1',
        roomId: room.id,
        kind: RoomRelationKind.cost,
        searchText: 'elektryka',
      );
      final decisionCandidates = await repository.listRelationCandidates(
        projectId: 'project-1',
        roomId: room.id,
        kind: RoomRelationKind.decision,
      );
      final defectCandidates = await repository.listRelationCandidates(
        projectId: 'project-1',
        roomId: room.id,
        kind: RoomRelationKind.defect,
      );
      final photoCandidates = await repository.listRelationCandidates(
        projectId: 'project-1',
        roomId: room.id,
        kind: RoomRelationKind.technicalPhoto,
      );
      final contactCandidates = await repository.listRelationCandidates(
        projectId: 'project-1',
        roomId: room.id,
        kind: RoomRelationKind.contact,
      );

      final details = await repository.findRoomDetails(
        projectId: 'project-1',
        roomId: room.id,
      );
      final portfolio = await repository.summarizeProject('project-1');

      expect(details, isNotNull);
      expect(details!.overview.actualCost.minorUnits, 250000);
      expect(details.overview.contactCount, 1);
      expect(details.overview.technicalPhotoCount, 1);
      expect(details.overview.openDecisionCount, 1);
      expect(details.overview.openDefectCount, 1);
      expect(costCandidates.single.isAssignedTo(room.id), isTrue);
      expect(decisionCandidates.single.id, 'decision-1');
      expect(defectCandidates.single.id, 'defect-1');
      expect(photoCandidates.single.id, 'photo-1');
      expect(contactCandidates.single.isAssignedTo(room.id), isTrue);
      expect(portfolio.roomCount, 1);
      expect(portfolio.actualCost.minorUnits, 250000);
    },
  );

  test(
    'creates planned cost and decision outputs once after selection',
    () async {
      final room = await _createRoom(repository);
      final openChoice = await repository.createChoice(
        input: RoomChoiceInput(
          projectId: 'project-1',
          roomId: room.id,
          title: 'Płytki podłogowe',
          quantity: DecimalQuantity(unscaledValue: 125, scale: 1),
          unit: 'm2',
          wasteBasisPoints: 1000,
        ),
        variants: <RoomChoiceVariantInput>[
          RoomChoiceVariantInput(
            projectId: 'project-1',
            label: 'Gres techniczny',
            unitGrossPrice: Money(minorUnits: 10000, currencyCode: 'PLN'),
          ),
        ],
      );
      final selected = await repository.selectVariant(
        projectId: 'project-1',
        choiceId: openChoice.id,
        variantId: openChoice.variants.single.id,
      );
      final costRepository = SqliteCostRepository(
        database: database,
        idGenerator: () => 'planned-cost-1',
        utcNow: () => now,
      );
      final journalRepository = SqliteJournalRepository(
        database: database,
        idGenerator: () => 'choice-decision-1',
        utcNow: () => now,
      );
      final materialRepository = SqliteMaterialRepository(
        database: database,
        idGenerator: () => 'choice-material-1',
        utcNow: () => now,
      );
      final service = RoomChoiceOutputService(
        repository,
        costRepository,
        journalRepository,
        materialRepository,
        () => now,
      );

      final cost = await service.createPlannedCost(
        room: room,
        choice: selected,
        vatRate: VatRate.standard23,
        name: 'Płytki podłogowe: Gres techniczny',
      );
      var refreshed = (await repository.findRoomDetails(
        projectId: 'project-1',
        roomId: room.id,
      ))!.choices.single;
      final decision = await service.createDecision(
        room: room,
        choice: refreshed,
        title: 'Wybór płytek w kuchni',
      );
      refreshed = (await repository.findRoomDetails(
        projectId: 'project-1',
        roomId: room.id,
      ))!.choices.single;
      final material = await service.createMaterial(
        room: room,
        choice: refreshed,
        name: 'Płytki podłogowe: Gres techniczny',
        unitWhenQuantityMissing: 'szt.',
      );
      final details = (await repository.findRoomDetails(
        projectId: 'project-1',
        roomId: room.id,
      ))!;
      refreshed = details.choices.single;

      expect(cost.lifecycle, CostLifecycle.draft);
      expect(cost.input.type, CostEntryType.planned);
      expect(cost.input.component, CostComponent.material);
      expect(cost.input.amount.gross.minorUnits, 137500);
      expect(cost.input.quantity!.unscaledValue, 1375);
      expect(cost.input.quantity!.scale, 2);
      expect(decision.status, isNotNull);
      expect(material.input.roomId, room.id);
      expect(material.input.costEntryId, cost.id);
      expect(material.input.orderedQuantity.unscaledValue, 1375);
      expect(material.input.orderedQuantity.scale, 2);
      expect(material.input.unit, 'm2');
      expect(material.input.orderedGross?.minorUnits, 137500);
      expect(details.overview.materialCount, 1);
      expect(
        refreshed.outputRecordId(RoomChoiceOutputType.plannedCost),
        cost.id,
      );
      expect(
        refreshed.outputRecordId(RoomChoiceOutputType.decision),
        decision.id,
      );
      expect(
        refreshed.outputRecordId(RoomChoiceOutputType.material),
        material.id,
      );
      await expectLater(
        service.createPlannedCost(
          room: room,
          choice: refreshed,
          vatRate: VatRate.standard23,
          name: 'Duplikat',
        ),
        throwsA(isA<RoomChoiceOutputExistsException>()),
      );
    },
  );

  test('rejects a cross-project record assignment', () async {
    final room = await _createRoom(repository);
    final otherRoom = await repository.createRoom(
      RoomInput(
        projectId: 'project-2',
        name: 'Salon',
        standard: RoomStandard.standard,
      ),
    );

    await expectLater(
      repository.assignRecord(
        projectId: 'project-1',
        roomId: room.id,
        type: RoomRecordType.cost,
        recordId: otherRoom.id,
      ),
      throwsA(isA<RoomRelationNotFoundException>()),
    );
  });
}

Future<Room> _createRoom(SqliteRoomRepository repository) {
  return repository.createRoom(
    RoomInput(
      projectId: 'project-1',
      name: 'Kuchnia',
      standard: RoomStandard.standard,
      plannedBudget: Money(minorUnits: 1000000, currencyCode: 'PLN'),
    ),
  );
}
