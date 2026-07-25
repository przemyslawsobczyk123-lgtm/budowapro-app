import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:sqflite/sqflite.dart';

typedef ReceiptFinancialIdGenerator = String Function();
typedef ReceiptFinancialUtcNow = DateTime Function();

final class SqliteReceiptFinancialRepository
    implements ReceiptFinancialRepository {
  factory SqliteReceiptFinancialRepository({
    required AppDatabase database,
    required SqliteCostRepository costRepository,
    required ReceiptFinancialIdGenerator idGenerator,
    required ReceiptFinancialUtcNow utcNow,
  }) {
    return SqliteReceiptFinancialRepository._(
      database,
      costRepository,
      idGenerator,
      utcNow,
    );
  }

  const SqliteReceiptFinancialRepository._(
    this._database,
    this._costRepository,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final SqliteCostRepository _costRepository;
  final ReceiptFinancialIdGenerator _idGenerator;
  final ReceiptFinancialUtcNow _utcNow;

  @override
  Future<ReceiptDuplicateCheck> checkDuplicates(
    ReviewedReceiptBatch batch,
  ) async {
    final database = await _database.open();
    return _checkDuplicates(database, batch);
  }

  @override
  Future<ReceiptDraftBatchResult> saveReviewedDrafts(
    ReviewedReceiptBatch batch, {
    bool duplicateAcknowledged = false,
  }) {
    return _database.transaction<ReceiptDraftBatchResult>((transaction) async {
      final duplicate = await _checkDuplicates(transaction, batch);
      if (duplicate.isDuplicate && !duplicateAcknowledged) {
        throw ReceiptDuplicateException(duplicate);
      }
      final recordedDuplicateAcknowledgement =
          duplicate.isDuplicate && duplicateAcknowledged;
      final now = _utcNow().toUtc();
      await transaction.insert(
        AppDatabase.receiptImportsTable,
        <String, Object?>{
          'id': _idGenerator(),
          'project_id': batch.projectId,
          'attachment_id': batch.attachmentId,
          'seller_name': batch.sellerName,
          'seller_key': batch.sellerKey,
          'purchase_date_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
            batch.purchaseDate,
          ),
          'document_number': batch.documentNumber,
          'total_gross_minor_units': batch.totalGrossMinorUnits,
          'currency_code': batch.currencyCode,
          'duplicate_acknowledged': recordedDuplicateAcknowledgement ? 1 : 0,
          'total_mismatch_acknowledged': batch.totalMismatchAcknowledged
              ? 1
              : 0,
          'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
            now,
          ),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _upsertReceiptDocument(transaction, batch, now);

      final drafts = <CostEntry>[];
      for (final line in batch.lines) {
        drafts.add(
          await _costRepository.insertDraftInTransaction(
            transaction,
            CostDraftInput(
              CostEntryInput(
                projectId: batch.projectId,
                name: line.name,
                type: CostEntryType.cost,
                status: CostStatus.planned,
                amount: VatBreakdown.fromGross(
                  Money(
                    minorUnits: line.grossMinorUnits,
                    currencyCode: batch.currencyCode,
                  ),
                  line.vatRate,
                ),
                entryDate: batch.purchaseDate,
                source: CostSource.receiptOcr,
                attachmentIds: <String>[batch.attachmentId],
              ),
            ),
          ),
        );
      }
      return ReceiptDraftBatchResult(
        drafts: drafts,
        duplicateAcknowledged: recordedDuplicateAcknowledgement,
      );
    });
  }

  Future<ReceiptDuplicateCheck> _checkDuplicates(
    DatabaseExecutor executor,
    ReviewedReceiptBatch batch,
  ) async {
    final attachmentRows = await executor.query(
      AppDatabase.costAttachmentsTable,
      columns: const <String>['sha256'],
      where: 'project_id = ? AND id = ? AND availability = ?',
      whereArgs: <Object?>[batch.projectId, batch.attachmentId, 'available'],
      limit: 1,
    );
    if (attachmentRows.isEmpty) {
      throw StateError('Receipt attachment is unavailable');
    }

    final reasons = <ReceiptDuplicateReason>{};
    final sameAttachment = await executor.query(
      AppDatabase.receiptImportsTable,
      columns: const <String>['attachment_id'],
      where: 'project_id = ? AND attachment_id = ?',
      whereArgs: <Object?>[batch.projectId, batch.attachmentId],
      limit: 1,
    );
    if (sameAttachment.isNotEmpty) {
      reasons.add(ReceiptDuplicateReason.sameAttachment);
    }

    final hash = attachmentRows.single['sha256'] as String?;
    if (hash != null && hash.isNotEmpty) {
      final sameHash = await executor.rawQuery(
        '''
          SELECT receipt.attachment_id
          FROM ${AppDatabase.receiptImportsTable} receipt
          INNER JOIN ${AppDatabase.costAttachmentsTable} attachment
            ON attachment.project_id = receipt.project_id
            AND attachment.id = receipt.attachment_id
          WHERE receipt.project_id = ?
            AND receipt.attachment_id != ?
            AND attachment.sha256 = ?
            AND attachment.availability = 'available'
          LIMIT 1
        ''',
        <Object?>[batch.projectId, batch.attachmentId, hash],
      );
      if (sameHash.isNotEmpty) {
        reasons.add(ReceiptDuplicateReason.fileHash);
      }
    }

    final sameSignature = await executor.query(
      AppDatabase.receiptImportsTable,
      columns: const <String>['attachment_id'],
      where:
          'project_id = ? AND attachment_id != ? AND seller_key = ? '
          'AND purchase_date_utc_ms = ? AND total_gross_minor_units = ? '
          'AND currency_code = ?',
      whereArgs: <Object?>[
        batch.projectId,
        batch.attachmentId,
        batch.sellerKey,
        DatabaseValueCodec.dateTimeToUtcMilliseconds(batch.purchaseDate),
        batch.totalGrossMinorUnits,
        batch.currencyCode,
      ],
      limit: 1,
    );
    if (sameSignature.isNotEmpty) {
      reasons.add(ReceiptDuplicateReason.receiptSignature);
    }
    return ReceiptDuplicateCheck(reasons);
  }

  static Future<void> _upsertReceiptDocument(
    DatabaseExecutor executor,
    ReviewedReceiptBatch batch,
    DateTime updatedAt,
  ) async {
    final date =
        '${batch.purchaseDate.year.toString().padLeft(4, '0')}-'
        '${batch.purchaseDate.month.toString().padLeft(2, '0')}-'
        '${batch.purchaseDate.day.toString().padLeft(2, '0')}';
    var title = '${batch.sellerName} - $date';
    if (title.length > 160) title = title.substring(0, 160);
    await executor.rawInsert(
      '''
        INSERT INTO ${AppDatabase.documentMetadataTable} (
          project_id,
          attachment_id,
          title,
          document_type,
          description,
          document_date_utc_ms,
          warranty_starts_at_utc_ms,
          warranty_ends_at_utc_ms,
          warranty_reminder_at_utc_ms,
          updated_at_utc_ms
        ) VALUES (?, ?, ?, 'receipt', ?, ?, NULL, NULL, NULL, ?)
        ON CONFLICT(project_id, attachment_id) DO UPDATE SET
          title = excluded.title,
          document_type = excluded.document_type,
          description = excluded.description,
          document_date_utc_ms = excluded.document_date_utc_ms,
          updated_at_utc_ms = excluded.updated_at_utc_ms
      ''',
      <Object?>[
        batch.projectId,
        batch.attachmentId,
        title,
        batch.documentNumber,
        DatabaseValueCodec.dateTimeToUtcMilliseconds(batch.purchaseDate),
        DatabaseValueCodec.dateTimeToUtcMilliseconds(updatedAt),
      ],
    );
  }
}
