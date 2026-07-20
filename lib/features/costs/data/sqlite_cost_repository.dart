import 'dart:convert';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_summary.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

typedef CostIdGenerator = String Function();
typedef CostUtcNow = DateTime Function();

final class SqliteCostRepository implements CostRepository {
  factory SqliteCostRepository({
    required AppDatabase database,
    required CostIdGenerator idGenerator,
    required CostUtcNow utcNow,
  }) {
    return SqliteCostRepository._(database, idGenerator, utcNow);
  }

  const SqliteCostRepository._(this._database, this._idGenerator, this._utcNow);

  final AppDatabase _database;
  final CostIdGenerator _idGenerator;
  final CostUtcNow _utcNow;

  @override
  Future<CostEntry> create(ConfirmedCostEntryInput input) {
    return _database.transaction<CostEntry>((transaction) {
      return _insert(
        transaction,
        input.input,
        lifecycle: CostLifecycle.confirmed,
      );
    });
  }

  @override
  Future<CostEntry> saveDraft(CostDraftInput input) {
    return _database.transaction<CostEntry>((transaction) {
      return _insert(transaction, input.input, lifecycle: CostLifecycle.draft);
    });
  }

  @override
  Future<CostEntry> replaceDraft({
    required String projectId,
    required String costEntryId,
    required CostDraftInput input,
  }) {
    return _database.transaction<CostEntry>((transaction) async {
      final existing = await _requiredEntry(
        transaction,
        projectId: projectId,
        costEntryId: costEntryId,
      );
      if (existing.lifecycle != CostLifecycle.draft) {
        throw StateError('Only a draft cost can be replaced');
      }
      _requireSameProject(projectId, input.input.projectId);
      _requireExistingAttachmentsPreserved(existing, input.input);
      await _requireProjectCurrency(transaction, input.input);
      await _validateAttachments(
        transaction,
        projectId: projectId,
        attachmentIds: input.input.attachmentIds,
      );
      final updated = CostEntry(
        id: existing.id,
        input: input.input,
        lifecycle: CostLifecycle.draft,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
        revision: existing.revision + 1,
      );
      await transaction.update(
        AppDatabase.costEntriesTable,
        _entryToRow(updated),
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[costEntryId, projectId],
      );
      await _linkAttachments(transaction, updated);
      await _appendRevision(
        transaction,
        updated,
        CostHistoryAction.draftReplaced,
      );
      return updated;
    });
  }

  @override
  Future<CostEntry> confirmDraft({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
    CostDraftInput? replacement,
  }) {
    return _database.transaction<CostEntry>((transaction) async {
      final existing = await _requiredEntry(
        transaction,
        projectId: projectId,
        costEntryId: costEntryId,
      );
      if (existing.lifecycle != CostLifecycle.draft) {
        throw StateError('Only a draft cost can be confirmed');
      }
      final sourceInput = replacement?.input ?? existing.input;
      _requireSameProject(projectId, sourceInput.projectId);
      _requireExistingAttachmentsPreserved(existing, sourceInput);
      await _requireProjectCurrency(transaction, sourceInput);
      await _validateAttachments(
        transaction,
        projectId: projectId,
        attachmentIds: sourceInput.attachmentIds,
      );
      final confirmed = CostEntry(
        id: existing.id,
        input: _copyInput(sourceInput, status: status),
        lifecycle: CostLifecycle.confirmed,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
        revision: existing.revision + 1,
      );
      await transaction.update(
        AppDatabase.costEntriesTable,
        _entryToRow(confirmed),
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[costEntryId, projectId],
      );
      await _linkAttachments(transaction, confirmed);
      await _appendRevision(
        transaction,
        confirmed,
        CostHistoryAction.confirmed,
      );
      return confirmed;
    });
  }

  @override
  Future<CostEntry> changeStatus({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
  }) {
    return _database.transaction<CostEntry>((transaction) async {
      final existing = await _requiredEntry(
        transaction,
        projectId: projectId,
        costEntryId: costEntryId,
      );
      if (existing.lifecycle != CostLifecycle.confirmed) {
        throw StateError('A draft has no financial status transition');
      }
      final updated = CostEntry(
        id: existing.id,
        input: _copyInput(existing.input, status: status),
        lifecycle: CostLifecycle.confirmed,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
        revision: existing.revision + 1,
      );
      await transaction.update(
        AppDatabase.costEntriesTable,
        _entryToRow(updated),
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[costEntryId, projectId],
      );
      await _appendRevision(
        transaction,
        updated,
        CostHistoryAction.statusChanged,
      );
      return updated;
    });
  }

  @override
  Future<CostEntry> updateDetails({
    required String projectId,
    required String costEntryId,
    required ConfirmedCostDetailsInput input,
  }) {
    return _database.transaction<CostEntry>((transaction) async {
      final existing = await _requiredEntry(
        transaction,
        projectId: projectId,
        costEntryId: costEntryId,
      );
      if (existing.lifecycle != CostLifecycle.confirmed) {
        throw StateError('Draft details must be changed with replaceDraft');
      }
      final updated = CostEntry(
        id: existing.id,
        input: _copyDetails(existing.input, input),
        lifecycle: CostLifecycle.confirmed,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
        revision: existing.revision + 1,
      );
      _requireExistingAttachmentsPreserved(existing, updated.input);
      await _validateAttachments(
        transaction,
        projectId: projectId,
        attachmentIds: updated.input.attachmentIds,
      );
      await transaction.update(
        AppDatabase.costEntriesTable,
        _entryToRow(updated),
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[costEntryId, projectId],
      );
      await _linkAttachments(transaction, updated);
      await _appendRevision(
        transaction,
        updated,
        CostHistoryAction.detailsUpdated,
      );
      return updated;
    });
  }

  @override
  Future<CostCorrection> addCorrection(CostCorrectionInput input) {
    return _database.transaction<CostCorrection>((transaction) async {
      final target = await _requiredEntry(
        transaction,
        projectId: input.projectId,
        costEntryId: input.costEntryId,
      );
      if (target.lifecycle != CostLifecycle.confirmed ||
          target.type != CostEntryType.cost) {
        throw StateError('A correction must target a confirmed cost');
      }
      if (target.amount.gross.currencyCode != input.delta.gross.currencyCode) {
        throw ArgumentError.value(
          input.delta.gross.currencyCode,
          'input',
          'must use currency ${target.amount.gross.currencyCode}',
        );
      }
      final totals = await transaction.rawQuery(
        '''
          SELECT COALESCE(SUM(gross_delta_minor_units), 0) AS gross_delta
          FROM ${AppDatabase.costCorrectionsTable}
          WHERE project_id = ? AND cost_entry_id = ?
        ''',
        <Object?>[input.projectId, input.costEntryId],
      );
      final currentDelta = totals.single['gross_delta']! as int;
      final correctedGross =
          BigInt.from(target.amount.gross.minorUnits) +
          BigInt.from(currentDelta) +
          BigInt.from(input.delta.gross.minorUnits);
      if (correctedGross.isNegative) {
        throw StateError('Cost corrections exceed the original gross amount');
      }

      final correction = CostCorrection(
        id: _idGenerator(),
        projectId: input.projectId,
        costEntryId: input.costEntryId,
        reason: input.reason,
        delta: input.delta,
        createdAt: _utcNow(),
        note: input.note,
      );
      await transaction.insert(
        AppDatabase.costCorrectionsTable,
        _correctionToRow(correction),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      final updatedTarget = CostEntry(
        id: target.id,
        input: target.input,
        lifecycle: target.lifecycle,
        createdAt: target.createdAtUtc,
        updatedAt: correction.createdAtUtc,
        revision: target.revision + 1,
      );
      await transaction.update(
        AppDatabase.costEntriesTable,
        _entryToRow(updatedTarget),
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[target.id, target.projectId],
      );
      await _appendRevision(
        transaction,
        updatedTarget,
        CostHistoryAction.correctionAdded,
      );
      return correction;
    });
  }

  @override
  Future<CostEntry?> findById({
    required String projectId,
    required String costEntryId,
  }) async {
    final database = await _database.open();
    return _findById(database, projectId: projectId, costEntryId: costEntryId);
  }

  @override
  Future<Page<CostEntry>> list(CostQuery query, PageRequest page) async {
    final database = await _database.open();
    final predicate = _costPredicate(query, tableAlias: 'e');
    final countRows = await database.rawQuery('''
        SELECT COUNT(*) AS total
        FROM ${AppDatabase.costEntriesTable} e
        WHERE ${predicate.sql}
      ''', predicate.arguments);
    final rows = await database.rawQuery(
      '''
        SELECT e.*
        FROM ${AppDatabase.costEntriesTable} e
        WHERE ${predicate.sql}
        ORDER BY ${_costOrderBy(query.sort, tableAlias: 'e')}
        LIMIT ? OFFSET ?
      ''',
      <Object?>[...predicate.arguments, page.limit, page.offset],
    );
    return Page<CostEntry>(
      items: await _entriesFromRows(database, rows),
      totalCount: countRows.single['total']! as int,
      request: page,
    );
  }

  @override
  Future<CostSummary> summarize(CostSummaryQuery query) async {
    final database = await _database.open();
    final currencyCode = await _projectCurrency(database, query.projectId);
    final predicate = _costPredicate(query.filters, tableAlias: 'e');
    final entryTotals = await database.rawQuery('''
        SELECT
          COALESCE(SUM(
            CASE
              WHEN e.entry_type = 'planned' THEN e.gross_minor_units
              ELSE 0
            END
          ), 0) AS planned,
          COALESCE(SUM(
            CASE
              WHEN e.entry_type = 'cost' THEN e.gross_minor_units
              ELSE 0
            END
          ), 0) AS actual
        FROM ${AppDatabase.costEntriesTable} e
        WHERE ${predicate.sql}
      ''', predicate.arguments);
    final correctionTotals = await database.rawQuery('''
        SELECT COALESCE(SUM(c.gross_delta_minor_units), 0) AS corrections
        FROM ${AppDatabase.costCorrectionsTable} c
        INNER JOIN ${AppDatabase.costEntriesTable} e
          ON e.id = c.cost_entry_id AND e.project_id = c.project_id
        WHERE ${predicate.sql}
          AND e.entry_type = 'cost'
      ''', predicate.arguments);
    final plannedMinorUnits = entryTotals.single['planned']! as int;
    final actualMinorUnits =
        BigInt.from(entryTotals.single['actual']! as int) +
        BigInt.from(correctionTotals.single['corrections']! as int);
    return CostSummary.fromTotals(
      planned: Money(minorUnits: plannedMinorUnits, currencyCode: currencyCode),
      actual: Money.fromBigInt(
        minorUnits: actualMinorUnits,
        currencyCode: currencyCode,
      ),
    );
  }

  @override
  Future<CostFilterOptions> filterOptions({required String projectId}) async {
    final normalizedProjectId = CostQuery(projectId: projectId).projectId;
    final database = await _database.open();
    final rows = await database.rawQuery(
      '''
        SELECT 'stage' AS option_type, stage_id AS option_value
        FROM ${AppDatabase.costEntriesTable}
        WHERE project_id = ? AND stage_id IS NOT NULL
        GROUP BY stage_id
        UNION ALL
        SELECT 'category' AS option_type, category_id AS option_value
        FROM ${AppDatabase.costEntriesTable}
        WHERE project_id = ? AND category_id IS NOT NULL
        GROUP BY category_id
        UNION ALL
        SELECT 'supplier' AS option_type, supplier_id AS option_value
        FROM ${AppDatabase.costEntriesTable}
        WHERE project_id = ? AND supplier_id IS NOT NULL
        GROUP BY supplier_id
        ORDER BY option_type ASC, option_value COLLATE NOCASE ASC
      ''',
      <Object?>[normalizedProjectId, normalizedProjectId, normalizedProjectId],
    );
    final stageIds = <String>[];
    final categoryIds = <String>[];
    final supplierIds = <String>[];
    for (final row in rows) {
      final value = row['option_value']! as String;
      switch (row['option_type']! as String) {
        case 'stage':
          stageIds.add(value);
          break;
        case 'category':
          categoryIds.add(value);
          break;
        case 'supplier':
          supplierIds.add(value);
          break;
      }
    }
    return CostFilterOptions(
      stageIds: stageIds,
      categoryIds: categoryIds,
      supplierIds: supplierIds,
    );
  }

  @override
  Future<Page<CostHistoryEntry>> history({
    required String projectId,
    required String costEntryId,
    required PageRequest page,
  }) async {
    final database = await _database.open();
    await _requiredEntry(
      database,
      projectId: projectId,
      costEntryId: costEntryId,
    );
    final countRows = await database.rawQuery(
      '''
        SELECT COUNT(*) AS total
        FROM ${AppDatabase.costEntryRevisionsTable}
        WHERE project_id = ? AND cost_entry_id = ?
      ''',
      <Object?>[projectId, costEntryId],
    );
    final rows = await database.query(
      AppDatabase.costEntryRevisionsTable,
      columns: const <String>[
        'id',
        'project_id',
        'cost_entry_id',
        'revision',
        'action',
        'created_at_utc_ms',
      ],
      where: 'project_id = ? AND cost_entry_id = ?',
      whereArgs: <Object?>[projectId, costEntryId],
      orderBy: 'revision DESC',
      limit: page.limit,
      offset: page.offset,
    );
    return Page<CostHistoryEntry>(
      items: rows.map(_historyFromRow),
      totalCount: countRows.single['total']! as int,
      request: page,
    );
  }

  @override
  Future<void> delete({
    required String projectId,
    required String costEntryId,
  }) {
    return _database.transaction<void>((transaction) async {
      await _requiredEntry(
        transaction,
        projectId: projectId,
        costEntryId: costEntryId,
      );
      await transaction.delete(
        AppDatabase.costEntriesTable,
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[costEntryId, projectId],
      );
    });
  }

  Future<CostEntry> _insert(
    DatabaseExecutor executor,
    CostEntryInput input, {
    required CostLifecycle lifecycle,
  }) async {
    await _requireProjectCurrency(executor, input);
    await _validateAttachments(
      executor,
      projectId: input.projectId,
      attachmentIds: input.attachmentIds,
    );
    final timestamp = _utcNow();
    final entry = CostEntry(
      id: _idGenerator(),
      input: input,
      lifecycle: lifecycle,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    await executor.insert(
      AppDatabase.costEntriesTable,
      _entryToRow(entry),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    await _linkAttachments(executor, entry);
    await _appendRevision(
      executor,
      entry,
      lifecycle == CostLifecycle.draft
          ? CostHistoryAction.draftSaved
          : CostHistoryAction.created,
    );
    return entry;
  }

  Future<void> _appendRevision(
    DatabaseExecutor executor,
    CostEntry entry,
    CostHistoryAction action,
  ) async {
    await executor.insert(
      AppDatabase.costEntryRevisionsTable,
      <String, Object?>{
        'id': _idGenerator(),
        'project_id': entry.projectId,
        'cost_entry_id': entry.id,
        'revision': entry.revision,
        'action': _historyActionToStorage(action),
        'snapshot_json': jsonEncode(<String, Object?>{
          ..._entryToRow(entry),
          'attachment_ids': entry.input.attachmentIds.toList(growable: false),
        }),
        'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
          entry.updatedAtUtc,
        ),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<void> _requireProjectCurrency(
    DatabaseExecutor executor,
    CostEntryInput input,
  ) async {
    final currencyCode = await _projectCurrency(executor, input.projectId);
    if (input.amount.gross.currencyCode != currencyCode) {
      throw ArgumentError.value(
        input.amount.gross.currencyCode,
        'input',
        'must use project currency $currencyCode',
      );
    }
  }

  static Future<String> _projectCurrency(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    final rows = await executor.query(
      AppDatabase.projectsTable,
      columns: const <String>['currency_code'],
      where: 'id = ?',
      whereArgs: <Object?>[projectId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw ArgumentError.value(projectId, 'projectId', 'does not exist');
    }
    return rows.single['currency_code']! as String;
  }

  static Future<void> _validateAttachments(
    DatabaseExecutor executor, {
    required String projectId,
    required Iterable<String> attachmentIds,
  }) async {
    final ids = attachmentIds.toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    final placeholders = List<String>.filled(ids.length, '?').join(', ');
    final rows = await executor.query(
      AppDatabase.costAttachmentsTable,
      columns: const <String>['id', 'project_id', 'availability'],
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    if (rows.length != ids.length) {
      throw StateError('Every attachment must exist before saving a cost');
    }
    for (final row in rows) {
      final isAvailable =
          row['project_id'] == projectId && row['availability'] == 'available';
      if (!isAvailable) {
        throw StateError('Attachment is unavailable for this cost');
      }
    }
  }

  static Future<void> _linkAttachments(
    DatabaseExecutor executor,
    CostEntry entry,
  ) async {
    await executor.delete(
      AppDatabase.costEntryAttachmentsTable,
      where: 'project_id = ? AND cost_entry_id = ?',
      whereArgs: <Object?>[entry.projectId, entry.id],
    );
    for (var index = 0; index < entry.input.attachmentIds.length; index += 1) {
      await executor.insert(
        AppDatabase.costEntryAttachmentsTable,
        <String, Object?>{
          'project_id': entry.projectId,
          'cost_entry_id': entry.id,
          'attachment_id': entry.input.attachmentIds[index],
          'sort_order': index,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  static void _requireExistingAttachmentsPreserved(
    CostEntry existing,
    CostEntryInput replacement,
  ) {
    final replacementIds = replacement.attachmentIds.toSet();
    if (!replacementIds.containsAll(existing.input.attachmentIds)) {
      throw StateError('Existing attachments must be preserved while editing');
    }
  }

  static Future<CostEntry> _requiredEntry(
    DatabaseExecutor executor, {
    required String projectId,
    required String costEntryId,
  }) async {
    final entry = await _findById(
      executor,
      projectId: projectId,
      costEntryId: costEntryId,
    );
    if (entry == null) {
      throw const CostNotFoundException();
    }
    return entry;
  }

  static Future<CostEntry?> _findById(
    DatabaseExecutor executor, {
    required String projectId,
    required String costEntryId,
  }) async {
    final rows = await executor.query(
      AppDatabase.costEntriesTable,
      where: 'id = ? AND project_id = ?',
      whereArgs: <Object?>[costEntryId, projectId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return (await _entriesFromRows(executor, rows)).single;
  }

  static Future<List<CostEntry>> _entriesFromRows(
    DatabaseExecutor executor,
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) {
      return const <CostEntry>[];
    }
    final ids = rows.map((row) => row['id']! as String).toList(growable: false);
    final placeholders = List<String>.filled(ids.length, '?').join(', ');
    final attachmentRows = await executor.query(
      AppDatabase.costEntryAttachmentsTable,
      columns: const <String>['attachment_id', 'cost_entry_id'],
      where: 'cost_entry_id IN ($placeholders)',
      whereArgs: ids,
      orderBy: 'cost_entry_id ASC, sort_order ASC',
    );
    final attachmentIdsByEntry = <String, List<String>>{};
    for (final row in attachmentRows) {
      attachmentIdsByEntry
          .putIfAbsent(row['cost_entry_id']! as String, () => <String>[])
          .add(row['attachment_id']! as String);
    }
    return rows
        .map(
          (row) => _entryFromRow(
            row,
            attachmentIdsByEntry[row['id']! as String] ?? const <String>[],
          ),
        )
        .toList(growable: false);
  }

  static Map<String, Object?> _entryToRow(CostEntry entry) {
    final input = entry.input;
    return <String, Object?>{
      'id': entry.id,
      'project_id': input.projectId,
      'name': input.name,
      'entry_type': _typeToStorage(input.type),
      'financial_status': _statusToStorage(input.status),
      'lifecycle': _lifecycleToStorage(entry.lifecycle),
      'entry_date_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        input.entryDate,
      ),
      'stage_id': input.stageId,
      'category_id': input.categoryId,
      'supplier_id': input.supplierId,
      'quantity_unscaled': input.quantity?.unscaledValue,
      'quantity_scale': input.quantity?.scale,
      'unit': input.unit,
      'net_minor_units': input.amount.net.minorUnits,
      'vat_rate_basis_points': input.amount.rate.basisPoints,
      'vat_minor_units': input.amount.vat.minorUnits,
      'gross_minor_units': input.amount.gross.minorUnits,
      'currency_code': input.amount.gross.currencyCode,
      'payment_method': _paymentMethodToStorage(input.paymentMethod),
      'source': _sourceToStorage(input.source),
      'note': input.note,
      'revision': entry.revision,
      'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        entry.createdAtUtc,
      ),
      'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        entry.updatedAtUtc,
      ),
    };
  }

  static CostEntry _entryFromRow(
    Map<String, Object?> row,
    Iterable<String> attachmentIds,
  ) {
    final currencyCode = row['currency_code']! as String;
    final rate = _vatRateFromStorage(row['vat_rate_basis_points']! as int);
    final amount = VatBreakdown.fromNet(
      Money(
        minorUnits: row['net_minor_units']! as int,
        currencyCode: currencyCode,
      ),
      rate,
    );
    if (amount.vat.minorUnits != row['vat_minor_units'] ||
        amount.gross.minorUnits != row['gross_minor_units']) {
      throw const FormatException('Stored cost amount is inconsistent');
    }
    final quantityUnscaled = row['quantity_unscaled'] as int?;
    final quantityScale = row['quantity_scale'] as int?;
    return CostEntry(
      id: row['id']! as String,
      input: CostEntryInput(
        projectId: row['project_id']! as String,
        name: row['name']! as String,
        type: _typeFromStorage(row['entry_type']! as String),
        status: _statusFromStorage(row['financial_status']! as String),
        amount: amount,
        entryDate: DatabaseValueCodec.utcMillisecondsToDateTime(
          row['entry_date_utc_ms']! as int,
        ),
        stageId: row['stage_id'] as String?,
        categoryId: row['category_id'] as String?,
        supplierId: row['supplier_id'] as String?,
        quantity: quantityUnscaled == null || quantityScale == null
            ? null
            : DecimalQuantity(
                unscaledValue: quantityUnscaled,
                scale: quantityScale,
              ),
        unit: row['unit'] as String?,
        paymentMethod: _paymentMethodFromStorage(
          row['payment_method'] as String?,
        ),
        source: _sourceFromStorage(row['source']! as String),
        attachmentIds: attachmentIds,
        note: row['note'] as String?,
      ),
      lifecycle: _lifecycleFromStorage(row['lifecycle']! as String),
      createdAt: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['created_at_utc_ms']! as int,
      ),
      updatedAt: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['updated_at_utc_ms']! as int,
      ),
      revision: row['revision']! as int,
    );
  }

  static Map<String, Object?> _correctionToRow(CostCorrection correction) {
    return <String, Object?>{
      'id': correction.id,
      'project_id': correction.projectId,
      'cost_entry_id': correction.costEntryId,
      'reason': _correctionReasonToStorage(correction.reason),
      'net_delta_minor_units': correction.delta.net.minorUnits,
      'vat_delta_minor_units': correction.delta.vat.minorUnits,
      'gross_delta_minor_units': correction.delta.gross.minorUnits,
      'vat_rate_basis_points': correction.delta.rate.basisPoints,
      'currency_code': correction.delta.gross.currencyCode,
      'note': correction.note,
      'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        correction.createdAtUtc,
      ),
    };
  }
}

CostHistoryEntry _historyFromRow(Map<String, Object?> row) {
  return CostHistoryEntry(
    id: row['id']! as String,
    projectId: row['project_id']! as String,
    costEntryId: row['cost_entry_id']! as String,
    revision: row['revision']! as int,
    action: _historyActionFromStorage(row['action']! as String),
    createdAt: DatabaseValueCodec.utcMillisecondsToDateTime(
      row['created_at_utc_ms']! as int,
    ),
  );
}

CostEntryInput _copyInput(CostEntryInput input, {required CostStatus status}) {
  return CostEntryInput(
    projectId: input.projectId,
    name: input.name,
    type: input.type,
    status: status,
    amount: input.amount,
    entryDate: input.entryDate,
    stageId: input.stageId,
    categoryId: input.categoryId,
    supplierId: input.supplierId,
    quantity: input.quantity,
    unit: input.unit,
    paymentMethod: input.paymentMethod,
    source: input.source,
    attachmentIds: input.attachmentIds,
    note: input.note,
  );
}

CostEntryInput _copyDetails(
  CostEntryInput original,
  ConfirmedCostDetailsInput details,
) {
  return CostEntryInput(
    projectId: original.projectId,
    name: details.name,
    type: original.type,
    status: original.status,
    amount: original.amount,
    entryDate: details.entryDate,
    stageId: details.stageId,
    categoryId: details.categoryId,
    supplierId: details.supplierId,
    quantity: details.quantity,
    unit: details.unit,
    paymentMethod: details.paymentMethod,
    source: original.source,
    attachmentIds: details.attachmentIds,
    note: details.note,
  );
}

void _requireSameProject(String expected, String actual) {
  if (expected != actual) {
    throw ArgumentError.value(actual, 'projectId', 'must match $expected');
  }
}

_SqlPredicate _costPredicate(CostQuery query, {required String tableAlias}) {
  String column(String name) => '$tableAlias.$name';

  final clauses = <String>['${column('project_id')} = ?'];
  final arguments = <Object?>[query.projectId];
  if (!query.includeDrafts) {
    clauses.add("${column('lifecycle')} = 'confirmed'");
  }
  final searchText = query.searchText;
  if (searchText != null) {
    final pattern = _likePattern(searchText);
    clauses.add('''
      (
        LOWER(${column('name')}) LIKE ? ESCAPE '\\'
        OR LOWER(COALESCE(${column('supplier_id')}, '')) LIKE ? ESCAPE '\\'
        OR LOWER(COALESCE(${column('note')}, '')) LIKE ? ESCAPE '\\'
        OR LOWER(COALESCE(${column('category_id')}, '')) LIKE ? ESCAPE '\\'
        OR LOWER(COALESCE(${column('stage_id')}, '')) LIKE ? ESCAPE '\\'
      )
    ''');
    arguments.addAll(List<Object?>.filled(5, pattern));
  }
  _addInClause(
    clauses,
    arguments,
    column('entry_type'),
    query.types.map(_typeToStorage),
  );
  _addInClause(
    clauses,
    arguments,
    column('financial_status'),
    query.statuses.map(_statusToStorage),
  );
  _addInClause(clauses, arguments, column('stage_id'), query.stageIds);
  _addInClause(clauses, arguments, column('category_id'), query.categoryIds);
  _addInClause(clauses, arguments, column('supplier_id'), query.supplierIds);
  _addInClause(
    clauses,
    arguments,
    column('payment_method'),
    query.paymentMethods.map(_paymentMethodToStorage).whereType<String>(),
  );
  _addInClause(
    clauses,
    arguments,
    column('source'),
    query.sources.map(_sourceToStorage),
  );
  final fromInclusive = query.fromInclusive;
  if (fromInclusive != null) {
    clauses.add('${column('entry_date_utc_ms')} >= ?');
    arguments.add(DatabaseValueCodec.dateTimeToUtcMilliseconds(fromInclusive));
  }
  final toExclusive = query.toExclusive;
  if (toExclusive != null) {
    clauses.add('${column('entry_date_utc_ms')} < ?');
    arguments.add(DatabaseValueCodec.dateTimeToUtcMilliseconds(toExclusive));
  }
  if (query.warnings.isNotEmpty) {
    final warnings = <String>[];
    for (final warning in query.warnings) {
      warnings.add(switch (warning) {
        CostWarning.missingDocument =>
          '''
            ${column('lifecycle')} = 'confirmed'
            AND ${column('entry_type')} = 'cost'
            AND NOT EXISTS (
                SELECT 1
                FROM ${AppDatabase.costEntryAttachmentsTable} warning_link
                WHERE warning_link.project_id = ${column('project_id')}
                  AND warning_link.cost_entry_id = ${column('id')}
            )
          ''',
        CostWarning.missingDescription =>
          "(${column('lifecycle')} = 'confirmed' "
              "AND ${column('entry_type')} = 'cost' "
              "AND TRIM(COALESCE(${column('note')}, '')) = '')",
        CostWarning.vatToReview =>
          "(${column('lifecycle')} = 'confirmed' "
              "AND ${column('entry_type')} = 'cost' "
              "AND ${column('gross_minor_units')} > 0 "
              "AND ${column('vat_rate_basis_points')} = 0)",
      });
    }
    clauses.add('(${warnings.join(' OR ')})');
  }
  return _SqlPredicate(
    sql: clauses.map((clause) => '($clause)').join(' AND '),
    arguments: arguments,
  );
}

String _costOrderBy(CostSort sort, {required String tableAlias}) {
  String column(String name) => '$tableAlias.$name';

  return switch (sort) {
    CostSort.newest =>
      '${column('entry_date_utc_ms')} DESC, ${column('id')} ASC',
    CostSort.oldest =>
      '${column('entry_date_utc_ms')} ASC, ${column('id')} ASC',
    CostSort.amountDescending =>
      '${column('gross_minor_units')} DESC, '
          '${column('entry_date_utc_ms')} DESC, ${column('id')} ASC',
    CostSort.amountAscending =>
      '${column('gross_minor_units')} ASC, '
          '${column('entry_date_utc_ms')} DESC, ${column('id')} ASC',
    CostSort.nameAscending =>
      '${column('name')} COLLATE NOCASE ASC, ${column('id')} ASC',
  };
}

void _addInClause(
  List<String> clauses,
  List<Object?> arguments,
  String column,
  Iterable<String> values,
) {
  final materialized = values.toList(growable: false)..sort();
  if (materialized.isEmpty) return;
  clauses.add(
    '$column IN (${List.filled(materialized.length, '?').join(', ')})',
  );
  arguments.addAll(materialized);
}

String _likePattern(String value) {
  final escaped = value
      .toLowerCase()
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
  return '%$escaped%';
}

final class _SqlPredicate {
  const _SqlPredicate({required this.sql, required this.arguments});

  final String sql;
  final List<Object?> arguments;
}

String _typeToStorage(CostEntryType value) => value.name;

CostEntryType _typeFromStorage(String value) => switch (value) {
  'cost' => CostEntryType.cost,
  'offer' => CostEntryType.offer,
  'planned' => CostEntryType.planned,
  _ => throw const FormatException('Unsupported cost entry type'),
};

String _statusToStorage(CostStatus value) => value.name;

CostStatus _statusFromStorage(String value) => switch (value) {
  'planned' => CostStatus.planned,
  'ordered' => CostStatus.ordered,
  'due' => CostStatus.due,
  'paid' => CostStatus.paid,
  'returned' => CostStatus.returned,
  'disputed' => CostStatus.disputed,
  _ => throw const FormatException('Unsupported cost status'),
};

String _lifecycleToStorage(CostLifecycle value) => value.name;

CostLifecycle _lifecycleFromStorage(String value) => switch (value) {
  'draft' => CostLifecycle.draft,
  'confirmed' => CostLifecycle.confirmed,
  _ => throw const FormatException('Unsupported cost lifecycle'),
};

String? _paymentMethodToStorage(CostPaymentMethod? value) => switch (value) {
  null => null,
  CostPaymentMethod.cash => 'cash',
  CostPaymentMethod.card => 'card',
  CostPaymentMethod.bankTransfer => 'bank_transfer',
  CostPaymentMethod.blik => 'blik',
  CostPaymentMethod.other => 'other',
};

CostPaymentMethod? _paymentMethodFromStorage(String? value) => switch (value) {
  null => null,
  'cash' => CostPaymentMethod.cash,
  'card' => CostPaymentMethod.card,
  'bank_transfer' => CostPaymentMethod.bankTransfer,
  'blik' => CostPaymentMethod.blik,
  'other' => CostPaymentMethod.other,
  _ => throw const FormatException('Unsupported cost payment method'),
};

String _sourceToStorage(CostSource value) => switch (value) {
  CostSource.manual => 'manual',
  CostSource.receiptOcr => 'receipt_ocr',
  CostSource.invoiceOcr => 'invoice_ocr',
  CostSource.imported => 'imported',
  CostSource.offerConversion => 'offer_conversion',
};

CostSource _sourceFromStorage(String value) => switch (value) {
  'manual' => CostSource.manual,
  'receipt_ocr' => CostSource.receiptOcr,
  'invoice_ocr' => CostSource.invoiceOcr,
  'imported' => CostSource.imported,
  'offer_conversion' => CostSource.offerConversion,
  _ => throw const FormatException('Unsupported cost source'),
};

VatRate _vatRateFromStorage(int value) => switch (value) {
  0 => VatRate.zero,
  800 => VatRate.reduced8,
  2300 => VatRate.standard23,
  _ => throw const FormatException('Unsupported VAT rate'),
};

String _correctionReasonToStorage(CostCorrectionReason value) =>
    switch (value) {
      CostCorrectionReason.returnedGoods => 'returned_goods',
      CostCorrectionReason.priceCorrection => 'price_correction',
      CostCorrectionReason.vatCorrection => 'vat_correction',
      CostCorrectionReason.reversal => 'reversal',
    };

String _historyActionToStorage(CostHistoryAction value) => switch (value) {
  CostHistoryAction.created => 'created',
  CostHistoryAction.draftSaved => 'draft_saved',
  CostHistoryAction.draftReplaced => 'draft_replaced',
  CostHistoryAction.confirmed => 'confirmed',
  CostHistoryAction.detailsUpdated => 'details_updated',
  CostHistoryAction.statusChanged => 'status_changed',
  CostHistoryAction.correctionAdded => 'correction_added',
};

CostHistoryAction _historyActionFromStorage(String value) => switch (value) {
  'created' => CostHistoryAction.created,
  'draft_saved' => CostHistoryAction.draftSaved,
  'draft_replaced' => CostHistoryAction.draftReplaced,
  'confirmed' => CostHistoryAction.confirmed,
  'details_updated' => CostHistoryAction.detailsUpdated,
  'status_changed' => CostHistoryAction.statusChanged,
  'correction_added' => CostHistoryAction.correctionAdded,
  _ => throw const FormatException('Unsupported cost history action'),
};
