import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
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
  late ProjectFileStore fileStore;
  late SqliteCostRepository repository;
  var nextId = 0;
  var nextMinute = 0;

  String generateId() => 'generated-${++nextId}';
  DateTime utcNow() => DateTime.utc(2026, 7, 15, 10, nextMinute++);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_cost_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    fileStore = ProjectFileStore(
      rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
    );
    final projectRepository = SqliteProjectRepository(
      database: database,
      fileStore: fileStore,
      idGenerator: () => 'project-1',
      utcNow: utcNow,
    );
    await projectRepository.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    repository = SqliteCostRepository(
      database: database,
      idGenerator: generateId,
      utcNow: utcNow,
    );
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'confirmed cost survives reopening with exact values and status',
    () async {
      final created = await repository.create(
        ConfirmedCostEntryInput(
          _input(
            name: 'Beton na lawy',
            component: CostComponent.material,
            status: CostStatus.paid,
            netMinorUnits: 123456,
            quantity: DecimalQuantity(unscaledValue: 185, scale: 1),
            unit: 'm3',
            paymentMethod: CostPaymentMethod.bankTransfer,
          ),
        ),
      );

      await database.close();
      database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
      repository = SqliteCostRepository(
        database: database,
        idGenerator: generateId,
        utcNow: utcNow,
      );
      final loaded = await repository.findById(
        projectId: 'project-1',
        costEntryId: created.id,
      );

      expect(loaded, isNotNull);
      expect(loaded!.name, 'Beton na lawy');
      expect(loaded.lifecycle, CostLifecycle.confirmed);
      expect(loaded.status, CostStatus.paid);
      expect(loaded.component, CostComponent.material);
      expect(loaded.amount.net.minorUnits, 123456);
      expect(loaded.amount.vat.minorUnits, 28395);
      expect(loaded.amount.gross.minorUnits, 151851);
      expect(loaded.input.quantity?.unscaledValue, 185);
      expect(loaded.input.quantity?.scale, 1);
      expect(loaded.input.unit, 'm3');
      expect(loaded.input.paymentMethod, CostPaymentMethod.bankTransfer);
    },
  );

  test('round trips a gross-originated VAT rounding boundary', () async {
    final input = CostEntryInput(
      projectId: 'project-1',
      name: 'Drobny koszt',
      type: CostEntryType.cost,
      status: CostStatus.paid,
      amount: VatBreakdown.fromGross(_pln(3), VatRate.standard23),
      entryDate: DateTime.utc(2026, 7, 15),
    );
    final created = await repository.create(ConfirmedCostEntryInput(input));

    final loaded = await repository.findById(
      projectId: 'project-1',
      costEntryId: created.id,
    );

    expect(loaded?.amount.net, _pln(2));
    expect(loaded?.amount.vat, _pln(1));
    expect(loaded?.amount.gross, _pln(3));
  });

  test('creates an imported cost batch in one transaction', () async {
    final created = await repository.createAll(<ConfirmedCostEntryInput>[
      ConfirmedCostEntryInput(
        _input(
          name: 'Beton',
          type: CostEntryType.planned,
          component: CostComponent.material,
          source: CostSource.imported,
        ),
      ),
      ConfirmedCostEntryInput(
        _input(
          name: 'Stal',
          type: CostEntryType.planned,
          component: CostComponent.material,
          source: CostSource.imported,
        ),
      ),
    ]);

    final listed = await repository.list(
      CostQuery(projectId: 'project-1'),
      PageRequest(),
    );

    expect(created.map((entry) => entry.name), <String>['Beton', 'Stal']);
    expect(listed.items.map((entry) => entry.name).toSet(), <String>{
      'Beton',
      'Stal',
    });
    expect(
      created.every((entry) => entry.input.source == CostSource.imported),
      isTrue,
    );
  });

  test('rolls back the complete imported batch when one row fails', () async {
    await expectLater(
      repository.createAll(<ConfirmedCostEntryInput>[
        ConfirmedCostEntryInput(
          _input(name: 'Beton', source: CostSource.imported),
        ),
        ConfirmedCostEntryInput(
          _input(
            name: 'Błędna waluta',
            currencyCode: 'EUR',
            source: CostSource.imported,
          ),
        ),
      ]),
      throwsArgumentError,
    );

    final listed = await repository.list(
      CostQuery(projectId: 'project-1'),
      PageRequest(),
    );
    expect(listed.items, isEmpty);
  });

  test('draft can be replaced, confirmed and changed to paid', () async {
    final draft = await repository.saveDraft(
      CostDraftInput(_input(name: 'Roboczy koszt')),
    );

    expect(
      (await repository.list(
        CostQuery(projectId: 'project-1'),
        PageRequest(),
      )).items,
      isEmpty,
    );
    expect(
      (await repository.list(
        CostQuery(projectId: 'project-1', includeDrafts: true),
        PageRequest(),
      )).items.single.id,
      draft.id,
    );

    final replaced = await repository.replaceDraft(
      projectId: 'project-1',
      costEntryId: draft.id,
      input: CostDraftInput(_input(name: 'Kabel zasilajacy')),
    );
    final confirmed = await repository.confirmDraft(
      projectId: 'project-1',
      costEntryId: replaced.id,
      status: CostStatus.due,
    );
    final paid = await repository.changeStatus(
      projectId: 'project-1',
      costEntryId: confirmed.id,
      status: CostStatus.paid,
    );

    expect(replaced.name, 'Kabel zasilajacy');
    expect(confirmed.lifecycle, CostLifecycle.confirmed);
    expect(paid.status, CostStatus.paid);
  });

  test('links every staged attachment in the cost transaction', () async {
    final rawDatabase = await database.open();
    await rawDatabase
        .insert(AppDatabase.costAttachmentsTable, <String, Object?>{
          'id': 'attachment-1',
          'project_id': 'project-1',
          'display_name': 'faktura.pdf',
          'original_storage_key': 'attachment-1.pdf',
          'preview_storage_key': null,
          'media_type': 'application/pdf',
          'byte_size': 42,
          'sha256': null,
          'source': 'file_picker',
          'availability': 'available',
          'imported_at_utc_ms': 0,
        });

    final entry = await repository.create(
      ConfirmedCostEntryInput(
        _input(
          status: CostStatus.paid,
          attachmentIds: const <String>['attachment-1'],
        ),
      ),
    );
    final link = (await rawDatabase.query(
      AppDatabase.costEntryAttachmentsTable,
      where: 'attachment_id = ?',
      whereArgs: const <Object?>['attachment-1'],
    )).single;

    expect(entry.input.attachmentIds, const <String>['attachment-1']);
    expect(link['cost_entry_id'], entry.id);
  });

  test('missing staged attachment rolls back the complete cost', () async {
    await expectLater(
      repository.create(
        ConfirmedCostEntryInput(
          _input(
            status: CostStatus.paid,
            attachmentIds: const <String>['missing-attachment'],
          ),
        ),
      ),
      throwsStateError,
    );

    final rawDatabase = await database.open();
    expect(await rawDatabase.query(AppDatabase.costEntriesTable), isEmpty);
  });

  test(
    'revision failure rolls back cost and link before file cleanup',
    () async {
      await repository.create(
        ConfirmedCostEntryInput(_input(status: CostStatus.paid)),
      );
      final rawDatabase = await database.open();
      final existingRevisionId =
          (await rawDatabase.query(
                AppDatabase.costEntryRevisionsTable,
                columns: const <String>['id'],
              )).single['id']!
              as String;
      final source = File(p.join(temporaryDirectory.path, 'rollback.pdf'));
      await source.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
      final stager = CostAttachmentStager(
        database: database,
        fileStore: fileStore,
        idGenerator: () => 'rollback-attachment',
        utcNow: utcNow,
      );
      final attachment = await stager.stage(
        projectId: 'project-1',
        pickedFile: PickedCostAttachment(
          sourceUri: source.uri,
          displayName: 'rollback.pdf',
          reportedByteSize: 4,
        ),
      );
      final injectedIds = <String>['failed-cost', existingRevisionId].iterator;
      final failingRepository = SqliteCostRepository(
        database: database,
        idGenerator: () {
          injectedIds.moveNext();
          return injectedIds.current;
        },
        utcNow: utcNow,
      );

      await expectLater(
        failingRepository.create(
          ConfirmedCostEntryInput(
            _input(
              status: CostStatus.paid,
              attachmentIds: <String>[attachment.id],
            ),
          ),
        ),
        throwsA(isA<DatabaseException>()),
      );

      expect(
        await rawDatabase.query(
          AppDatabase.costEntriesTable,
          where: 'id = ?',
          whereArgs: const <Object?>['failed-cost'],
        ),
        isEmpty,
      );
      expect(
        await rawDatabase.query(AppDatabase.costEntryAttachmentsTable),
        isEmpty,
      );
      expect(
        await rawDatabase.query(AppDatabase.costEntryRevisionsTable),
        hasLength(1),
      );

      await stager.recoverUnlinkedAttachments();
      expect(
        await stager.findById(
          projectId: 'project-1',
          attachmentId: attachment.id,
        ),
        isNull,
      );
      expect(
        await fileStore
            .fileFor(
              projectId: 'project-1',
              area: ProjectFileArea.originals,
              fileName: 'rollback-attachment.pdf',
            )
            .exists(),
        isFalse,
      );
    },
  );

  test('one attachment can be linked to more than one cost', () async {
    final rawDatabase = await database.open();
    await rawDatabase
        .insert(AppDatabase.costAttachmentsTable, <String, Object?>{
          'id': 'shared-document',
          'project_id': 'project-1',
          'display_name': 'paragon.pdf',
          'original_storage_key': 'shared-document.pdf',
          'preview_storage_key': null,
          'media_type': 'application/pdf',
          'byte_size': 42,
          'sha256': null,
          'source': 'file_picker',
          'availability': 'available',
          'imported_at_utc_ms': 0,
        });

    for (final name in <String>['Material A', 'Material B']) {
      await repository.create(
        ConfirmedCostEntryInput(
          _input(
            name: name,
            status: CostStatus.paid,
            attachmentIds: const <String>['shared-document'],
          ),
        ),
      );
    }

    expect(
      await rawDatabase.query(AppDatabase.costEntryAttachmentsTable),
      hasLength(2),
    );
  });

  test('corrections and SQL summary preserve plan and actual totals', () async {
    await repository.create(
      ConfirmedCostEntryInput(
        _input(
          name: 'Plan fundamentow',
          type: CostEntryType.planned,
          status: CostStatus.planned,
          netMinorUnits: 200000,
        ),
      ),
    );
    final cost = await repository.create(
      ConfirmedCostEntryInput(
        _input(name: 'Beton', status: CostStatus.paid, netMinorUnits: 100000),
      ),
    );
    await repository.addCorrection(
      CostCorrectionInput(
        projectId: 'project-1',
        costEntryId: cost.id,
        reason: CostCorrectionReason.returnedGoods,
        delta: VatBreakdown.fromNet(_pln(-10000), VatRate.standard23),
      ),
    );

    final summary = await repository.summarize(
      CostSummaryQuery(projectId: 'project-1'),
    );

    expect(summary.planned.minorUnits, 246000);
    expect(summary.actual.minorUnits, 110700);
    expect(summary.difference.minorUnits, -135300);
  });

  test(
    'export rows respect filters and include the amount after corrections',
    () async {
      final included = await repository.create(
        ConfirmedCostEntryInput(
          _input(
            name: 'Beton',
            status: CostStatus.paid,
            netMinorUnits: 100000,
            supplierId: 'included',
          ),
        ),
      );
      await repository.create(
        ConfirmedCostEntryInput(
          _input(name: 'Stal', status: CostStatus.paid, supplierId: 'excluded'),
        ),
      );
      await repository.addCorrection(
        CostCorrectionInput(
          projectId: 'project-1',
          costEntryId: included.id,
          reason: CostCorrectionReason.returnedGoods,
          delta: VatBreakdown.fromNet(_pln(-10000), VatRate.standard23),
        ),
      );

      final exported = await repository.exportRows(
        CostQuery(projectId: 'project-1', supplierIds: {'included'}),
        PageRequest(limit: 1),
      );

      expect(exported.totalCount, 1);
      expect(exported.items.single.entry.id, included.id);
      expect(exported.items.single.entry.amount.gross.minorUnits, 123000);
      expect(exported.items.single.effectiveGross.minorUnits, 110700);
    },
  );

  test(
    'combines register filters and summarizes the active SQL result',
    () async {
      await repository.create(
        ConfirmedCostEntryInput(
          _input(
            name: 'Plan fundamentow',
            type: CostEntryType.planned,
            status: CostStatus.planned,
            netMinorUnits: 200000,
            entryDate: DateTime.utc(2026, 1, 5),
          ),
        ),
      );
      final matching = await repository.create(
        ConfirmedCostEntryInput(
          _input(
            name: 'Beton C30/37',
            status: CostStatus.paid,
            netMinorUnits: 100000,
            entryDate: DateTime.utc(2026, 1, 15),
            paymentMethod: CostPaymentMethod.bankTransfer,
            note: 'Fundament i lawy',
          ),
        ),
      );
      await repository.create(
        ConfirmedCostEntryInput(
          _input(
            name: 'Okna',
            status: CostStatus.due,
            entryDate: DateTime.utc(2026, 2, 10),
            stageId: 'shell_closed',
            categoryId: 'windows',
            supplierId: 'supplier-2',
            paymentMethod: CostPaymentMethod.card,
          ),
        ),
      );
      final query = CostQuery(
        projectId: 'project-1',
        searchText: 'fundament',
        types: const <CostEntryType>{CostEntryType.cost},
        statuses: const <CostStatus>{CostStatus.paid},
        stageIds: const <String>{'state_zero'},
        categoryIds: const <String>{'materials'},
        supplierIds: const <String>{'supplier-1'},
        paymentMethods: const <CostPaymentMethod>{
          CostPaymentMethod.bankTransfer,
        },
        sources: const <CostSource>{CostSource.manual},
        warnings: const <CostWarning>{CostWarning.missingDocument},
        fromInclusive: DateTime.utc(2026, 1, 1),
        toExclusive: DateTime.utc(2026, 2, 1),
      );

      final page = await repository.list(query, PageRequest(limit: 30));
      final summary = await repository.summarize(
        CostSummaryQuery.fromCostQuery(query),
      );

      expect(page.totalCount, 1);
      expect(page.items.single.id, matching.id);
      expect(summary.planned.minorUnits, 0);
      expect(summary.actual.minorUnits, 123000);
      expect(summary.difference.minorUnits, 123000);
    },
  );

  test(
    'sorts amounts deterministically and treats search wildcards literally',
    () async {
      final lower = await repository.create(
        ConfirmedCostEntryInput(
          _input(name: 'Pozycja 10%', status: CostStatus.paid),
        ),
      );
      final higher = await repository.create(
        ConfirmedCostEntryInput(
          _input(
            name: 'Pozycja zwykla',
            status: CostStatus.paid,
            netMinorUnits: 20000,
          ),
        ),
      );

      final sorted = await repository.list(
        CostQuery(projectId: 'project-1', sort: CostSort.amountDescending),
        PageRequest(),
      );
      final literalPercent = await repository.list(
        CostQuery(projectId: 'project-1', searchText: '%'),
        PageRequest(),
      );

      expect(sorted.items.map((entry) => entry.id), <String>[
        higher.id,
        lower.id,
      ]);
      expect(literalPercent.items.map((entry) => entry.id), <String>[lower.id]);
    },
  );

  test('filters visible data-quality warnings independently', () async {
    final rawDatabase = await database.open();
    await rawDatabase
        .insert(AppDatabase.costAttachmentsTable, <String, Object?>{
          'id': 'document-1',
          'project_id': 'project-1',
          'display_name': 'faktura.pdf',
          'original_storage_key': 'document-1.pdf',
          'preview_storage_key': null,
          'media_type': 'application/pdf',
          'byte_size': 42,
          'sha256': null,
          'source': 'file_picker',
          'availability': 'available',
          'imported_at_utc_ms': 0,
        });
    final missingDocument = await repository.create(
      ConfirmedCostEntryInput(
        _input(name: 'Bez dokumentu', status: CostStatus.paid),
      ),
    );
    final missingDescription = await repository.create(
      ConfirmedCostEntryInput(
        _input(
          name: 'Bez opisu',
          status: CostStatus.paid,
          note: null,
          attachmentIds: const <String>['document-1'],
        ),
      ),
    );
    final vatToReview = await repository.create(
      ConfirmedCostEntryInput(
        _input(
          name: 'VAT zero',
          status: CostStatus.paid,
          vatRate: VatRate.zero,
          attachmentIds: const <String>['document-1'],
        ),
      ),
    );

    Future<List<String>> idsFor(CostWarning warning) async {
      final page = await repository.list(
        CostQuery(projectId: 'project-1', warnings: <CostWarning>{warning}),
        PageRequest(),
      );
      return page.items.map((entry) => entry.id).toList(growable: false);
    }

    expect(await idsFor(CostWarning.missingDocument), <String>[
      missingDocument.id,
    ]);
    expect(await idsFor(CostWarning.missingDescription), <String>[
      missingDescription.id,
    ]);
    expect(await idsFor(CostWarning.vatToReview), <String>[vatToReview.id]);
  });

  test('loads distinct filter options in display order', () async {
    await repository.create(
      ConfirmedCostEntryInput(
        _input(
          name: 'B',
          status: CostStatus.paid,
          stageId: 'shell_closed',
          categoryId: 'windows',
          supplierId: 'zeta',
        ),
      ),
    );
    await repository.create(
      ConfirmedCostEntryInput(
        _input(
          name: 'A',
          status: CostStatus.paid,
          stageId: 'state_zero',
          categoryId: 'materials',
          supplierId: 'alfa',
        ),
      ),
    );

    final options = await repository.filterOptions(projectId: 'project-1');

    expect(options.stageIds, <String>['shell_closed', 'state_zero']);
    expect(options.categoryIds, <String>['materials', 'windows']);
    expect(options.supplierIds, <String>['alfa', 'zeta']);
  });

  test(
    'pages a 10000-entry fixture without materializing the register',
    () async {
      final rawDatabase = await database.open();
      final batch = rawDatabase.batch();
      for (var index = 0; index < 10000; index++) {
        batch.insert(AppDatabase.costEntriesTable, <String, Object?>{
          'id': 'fixture-$index',
          'project_id': 'project-1',
          'name': 'Koszt $index',
          'entry_type': 'cost',
          'financial_status': 'paid',
          'lifecycle': 'confirmed',
          'entry_date_utc_ms': index,
          'stage_id': 'state_zero',
          'category_id': 'materials',
          'supplier_id': 'supplier-1',
          'quantity_unscaled': null,
          'quantity_scale': null,
          'unit': null,
          'net_minor_units': 100,
          'vat_rate_basis_points': 0,
          'vat_minor_units': 0,
          'gross_minor_units': 100,
          'currency_code': 'PLN',
          'payment_method': 'card',
          'source': 'manual',
          'note': 'fixture',
          'revision': 1,
          'created_at_utc_ms': index,
          'updated_at_utc_ms': index,
        });
      }
      await batch.commit(noResult: true);

      final first = await repository.list(
        CostQuery(projectId: 'project-1'),
        PageRequest(limit: 30),
      );
      final second = await repository.list(
        CostQuery(projectId: 'project-1'),
        first.nextRequest!,
      );

      expect(first.totalCount, 10000);
      expect(first.items, hasLength(30));
      expect(first.hasNext, isTrue);
      expect(first.items.first.id, 'fixture-9999');
      expect(second.items, hasLength(30));
      expect(second.items.first.id, 'fixture-9969');
    },
  );

  test('rejects a project currency mismatch', () async {
    await expectLater(
      repository.create(
        ConfirmedCostEntryInput(
          _input(currencyCode: 'EUR', status: CostStatus.paid),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('deletes draft and confirmed entries from their project', () async {
    final draft = await repository.saveDraft(CostDraftInput(_input()));
    final confirmed = await repository.create(
      ConfirmedCostEntryInput(_input(status: CostStatus.paid)),
    );

    await repository.delete(projectId: 'project-1', costEntryId: draft.id);
    await repository.delete(projectId: 'project-1', costEntryId: confirmed.id);

    expect(
      await repository.findById(projectId: 'project-1', costEntryId: draft.id),
      isNull,
    );
    expect(
      await repository.findById(
        projectId: 'project-1',
        costEntryId: confirmed.id,
      ),
      isNull,
    );
  });

  test('updates confirmed details without replacing financial truth', () async {
    final original = await repository.create(
      ConfirmedCostEntryInput(_input(name: 'Beton', status: CostStatus.paid)),
    );

    final updated = await repository.updateDetails(
      projectId: 'project-1',
      costEntryId: original.id,
      input: ConfirmedCostDetailsInput(
        name: 'Beton C30/37',
        component: CostComponent.mixed,
        entryDate: DateTime.utc(2026, 7, 16),
        stageId: 'state_zero',
        categoryId: 'concrete',
        supplierId: 'supplier-2',
        paymentMethod: CostPaymentMethod.card,
        note: 'Dostawa pompa',
      ),
    );

    expect(updated.name, 'Beton C30/37');
    expect(updated.amount.gross, original.amount.gross);
    expect(updated.status, original.status);
    expect(updated.type, original.type);
    expect(updated.component, CostComponent.mixed);
    expect(updated.revision, 2);
    final history = await repository.history(
      projectId: 'project-1',
      costEntryId: original.id,
      page: PageRequest(),
    );
    expect(history.items.map((entry) => entry.action), <CostHistoryAction>[
      CostHistoryAction.detailsUpdated,
      CostHistoryAction.created,
    ]);
  });

  test('filters and summarizes material and labor independently', () async {
    await repository.create(
      ConfirmedCostEntryInput(
        _input(
          name: 'Bloczek',
          component: CostComponent.material,
          status: CostStatus.paid,
          netMinorUnits: 10000,
        ),
      ),
    );
    await repository.create(
      ConfirmedCostEntryInput(
        _input(
          name: 'Murarz',
          component: CostComponent.labor,
          status: CostStatus.paid,
          netMinorUnits: 20000,
        ),
      ),
    );

    final labor = await repository.list(
      CostQuery(
        projectId: 'project-1',
        components: const <CostComponent>{CostComponent.labor},
      ),
      PageRequest(),
    );
    final summary = await repository.summarize(
      CostSummaryQuery(projectId: 'project-1'),
    );

    expect(labor.items.map((entry) => entry.name), <String>['Murarz']);
    expect(
      summary.componentTotals[CostComponent.material]?.actual.minorUnits,
      12300,
    );
    expect(
      summary.componentTotals[CostComponent.labor]?.actual.minorUnits,
      24600,
    );
  });
}

CostEntryInput _input({
  String name = 'Pozycja kosztowa',
  CostEntryType type = CostEntryType.cost,
  CostComponent component = CostComponent.unassigned,
  CostStatus status = CostStatus.planned,
  int netMinorUnits = 10000,
  String currencyCode = 'PLN',
  DecimalQuantity? quantity,
  String? unit,
  CostPaymentMethod? paymentMethod,
  Iterable<String> attachmentIds = const <String>[],
  DateTime? entryDate,
  String? stageId = 'state_zero',
  String? categoryId = 'materials',
  String? supplierId = 'supplier-1',
  VatRate vatRate = VatRate.standard23,
  CostSource source = CostSource.manual,
  String? note = 'Test note',
}) {
  return CostEntryInput(
    projectId: 'project-1',
    name: name,
    type: type,
    component: component,
    status: status,
    amount: VatBreakdown.fromNet(
      Money(minorUnits: netMinorUnits, currencyCode: currencyCode),
      vatRate,
    ),
    entryDate: entryDate ?? DateTime.utc(2026, 7, 15),
    stageId: stageId,
    categoryId: categoryId,
    supplierId: supplierId,
    quantity: quantity,
    unit: unit,
    paymentMethod: paymentMethod,
    attachmentIds: attachmentIds,
    source: source,
    note: note,
  );
}

Money _pln(int minorUnits) {
  return Money(minorUnits: minorUnits, currencyCode: 'PLN');
}
