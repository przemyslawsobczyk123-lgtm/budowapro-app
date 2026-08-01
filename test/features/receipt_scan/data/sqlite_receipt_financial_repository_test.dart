import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/receipt_scan/data/sqlite_receipt_financial_repository.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteCostRepository costs;
  late SqliteReceiptFinancialRepository receipts;
  var nextId = 0;

  String generateId() => 'generated-${++nextId}';
  final now = DateTime.utc(2026, 7, 25, 12);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_receipt_financial_test_',
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
    costs = SqliteCostRepository(
      database: database,
      idGenerator: generateId,
      utcNow: () => now,
    );
    receipts = SqliteReceiptFinancialRepository(
      database: database,
      costRepository: costs,
      idGenerator: generateId,
      utcNow: () => now,
    );
    await _insertAttachment(database, id: 'attachment-1', hash: 'a' * 64);
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'posts three drafts, one receipt document and shared links atomically',
    () async {
      final result = await receipts.saveReviewedDrafts(_batch('attachment-1'));

      expect(result.drafts, hasLength(3));
      expect(
        result.drafts.every((entry) => entry.input.stageId == 'state_zero'),
        isTrue,
      );
      expect(result.drafts.map((entry) => entry.component), <CostComponent>[
        CostComponent.material,
        CostComponent.labor,
        CostComponent.material,
      ]);
      expect(
        result.drafts.every(
          (entry) =>
              entry.lifecycle == CostLifecycle.draft &&
              entry.input.source == CostSource.receiptOcr &&
              entry.input.attachmentIds.single == 'attachment-1',
        ),
        isTrue,
      );

      final handle = await database.open();
      expect(await handle.query(AppDatabase.receiptImportsTable), hasLength(1));
      expect(await handle.query(AppDatabase.costEntriesTable), hasLength(3));
      expect(
        await handle.query(AppDatabase.costEntryAttachmentsTable),
        hasLength(3),
      );
      expect(
        await handle.query(AppDatabase.costEntryRevisionsTable),
        hasLength(3),
      );
      final metadata = await handle.query(AppDatabase.documentMetadataTable);
      expect(metadata, hasLength(1));
      expect(metadata.single['document_type'], 'receipt');

      final summary = await costs.summarize(
        CostSummaryQuery(projectId: 'project-1'),
      );
      expect(summary.actual.minorUnits, 0);
      expect(summary.planned.minorUnits, 0);
    },
  );

  test(
    'detects hash and receipt signature before allowing an override',
    () async {
      await receipts.saveReviewedDrafts(_batch('attachment-1'));
      await _insertAttachment(database, id: 'attachment-2', hash: 'a' * 64);
      final duplicateBatch = _batch('attachment-2');

      final duplicate = await receipts.checkDuplicates(duplicateBatch);

      expect(
        duplicate.reasons,
        containsAll(<ReceiptDuplicateReason>{
          ReceiptDuplicateReason.fileHash,
          ReceiptDuplicateReason.receiptSignature,
        }),
      );
      await expectLater(
        receipts.saveReviewedDrafts(duplicateBatch),
        throwsA(isA<ReceiptDuplicateException>()),
      );
      final handle = await database.open();
      expect(await handle.query(AppDatabase.receiptImportsTable), hasLength(1));
      expect(await handle.query(AppDatabase.costEntriesTable), hasLength(3));

      final saved = await receipts.saveReviewedDrafts(
        duplicateBatch,
        duplicateAcknowledged: true,
      );

      expect(saved.duplicateAcknowledged, isTrue);
      expect(await handle.query(AppDatabase.receiptImportsTable), hasLength(2));
      expect(await handle.query(AppDatabase.costEntriesTable), hasLength(6));
    },
  );

  test('never allows the same attachment to be posted twice', () async {
    await receipts.saveReviewedDrafts(_batch('attachment-1'));

    final duplicate = await receipts.checkDuplicates(_batch('attachment-1'));

    expect(duplicate.reasons, contains(ReceiptDuplicateReason.sameAttachment));
    await expectLater(
      receipts.saveReviewedDrafts(
        _batch('attachment-1'),
        duplicateAcknowledged: true,
      ),
      throwsA(isA<ReceiptDuplicateException>()),
    );
    final handle = await database.open();
    expect(await handle.query(AppDatabase.receiptImportsTable), hasLength(1));
    expect(await handle.query(AppDatabase.costEntriesTable), hasLength(3));
  });

  test(
    'rolls back header, document and every cost after a line failure',
    () async {
      var costIdCalls = 0;
      final brokenCosts = SqliteCostRepository(
        database: database,
        idGenerator: () {
          costIdCalls += 1;
          return costIdCalls == 5 ? 'cost-1' : 'cost-$costIdCalls';
        },
        utcNow: () => now,
      );
      final brokenReceipts = SqliteReceiptFinancialRepository(
        database: database,
        costRepository: brokenCosts,
        idGenerator: () => 'receipt-1',
        utcNow: () => now,
      );

      await expectLater(
        brokenReceipts.saveReviewedDrafts(_batch('attachment-1')),
        throwsA(isA<Object>()),
      );

      final handle = await database.open();
      expect(await handle.query(AppDatabase.receiptImportsTable), isEmpty);
      expect(await handle.query(AppDatabase.documentMetadataTable), isEmpty);
      expect(await handle.query(AppDatabase.costEntriesTable), isEmpty);
      expect(
        await handle.query(AppDatabase.costEntryAttachmentsTable),
        isEmpty,
      );
      expect(await handle.query(AppDatabase.costEntryRevisionsTable), isEmpty);
    },
  );
}

ReviewedReceiptBatch _batch(String attachmentId) {
  return ReviewedReceiptBatch(
    projectId: 'project-1',
    attachmentId: attachmentId,
    sellerName: 'Skład Budowlany',
    purchaseDate: DateTime.utc(2026, 7, 25),
    documentNumber: '004521/2026',
    totalGrossMinorUnits: 6248,
    currencyCode: 'PLN',
    stageId: 'state_zero',
    lines: <ReviewedReceiptLine>[
      ReviewedReceiptLine(
        name: 'Zaprawa',
        grossMinorUnits: 2499,
        vatRate: VatRate.standard23,
      ),
      ReviewedReceiptLine(
        name: 'Klej',
        grossMinorUnits: 2499,
        vatRate: VatRate.standard23,
        component: CostComponent.labor,
      ),
      ReviewedReceiptLine(
        name: 'Kołki',
        grossMinorUnits: 1250,
        vatRate: VatRate.standard23,
      ),
    ],
  );
}

Future<void> _insertAttachment(
  AppDatabase database, {
  required String id,
  required String hash,
}) async {
  final handle = await database.open();
  await handle.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
    'id': id,
    'project_id': 'project-1',
    'display_name': '$id.jpg',
    'original_storage_key': '$id.jpg',
    'preview_storage_key': '$id-preview.jpg',
    'media_type': 'image/jpeg',
    'byte_size': 100,
    'sha256': hash,
    'source': 'scanner',
    'availability': 'available',
    'imported_at_utc_ms': DateTime.utc(2026, 7, 25).millisecondsSinceEpoch,
  });
}
