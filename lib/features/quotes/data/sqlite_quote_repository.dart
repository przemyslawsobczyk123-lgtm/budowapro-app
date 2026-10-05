import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/quotes/domain/quote_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

typedef QuoteIdGenerator = String Function();
typedef QuoteUtcNow = DateTime Function();

final class SqliteQuoteRepository implements QuoteRepository {
  factory SqliteQuoteRepository({
    required AppDatabase database,
    required SqliteCostRepository costRepository,
    required QuoteIdGenerator idGenerator,
    required QuoteUtcNow utcNow,
  }) => SqliteQuoteRepository._(database, costRepository, idGenerator, utcNow);

  const SqliteQuoteRepository._(
    this._database,
    this._costRepository,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final SqliteCostRepository _costRepository;
  final QuoteIdGenerator _idGenerator;
  final QuoteUtcNow _utcNow;

  @override
  Future<ContractorQuote> create({
    required String projectId,
    required ContractorQuoteDraft draft,
  }) {
    return _database.transaction<ContractorQuote>((transaction) async {
      await _validateDraft(transaction, projectId: projectId, draft: draft);
      final now = _utcNow().toUtc();
      final quote = ContractorQuote(
        id: _idGenerator(),
        projectId: projectId,
        draft: draft,
        status: ContractorQuoteStatus.received,
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        AppDatabase.contractorQuotesTable,
        _quoteToRow(quote),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _replaceRelations(transaction, quote);
      return quote;
    });
  }

  @override
  Future<ContractorQuote> update({
    required String projectId,
    required String quoteId,
    required ContractorQuoteDraft draft,
  }) {
    return _database.transaction<ContractorQuote>((transaction) async {
      final existing = await _requiredQuote(
        transaction,
        projectId: projectId,
        quoteId: quoteId,
      );
      if (existing.status != ContractorQuoteStatus.received) {
        throw const QuoteLockedException();
      }
      await _validateDraft(transaction, projectId: projectId, draft: draft);
      final updated = ContractorQuote(
        id: existing.id,
        projectId: existing.projectId,
        draft: draft,
        status: existing.status,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
      );
      final changed = await transaction.update(
        AppDatabase.contractorQuotesTable,
        _quoteToRow(updated),
        where: 'project_id = ? AND id = ? AND status = ?',
        whereArgs: <Object?>[projectId, quoteId, 'received'],
      );
      if (changed != 1) throw const QuoteLockedException();
      await _replaceRelations(transaction, updated);
      return updated;
    });
  }

  @override
  Future<ContractorQuote?> findById({
    required String projectId,
    required String quoteId,
  }) async {
    return _findQuote(
      await _database.open(),
      projectId: projectId,
      quoteId: quoteId,
    );
  }

  @override
  Future<Page<ContractorQuote>> list(
    QuoteQuery query,
    PageRequest request,
  ) async {
    final database = await _database.open();
    final filter = _buildFilter(query);
    final from =
        '${AppDatabase.contractorQuotesTable} q '
        'INNER JOIN ${AppDatabase.contactsTable} c '
        'ON c.project_id = q.project_id AND c.id = q.contact_id';
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM $from WHERE ${filter.sql}',
      filter.arguments,
    );
    final rows = await database.rawQuery(
      'SELECT q.* FROM $from WHERE ${filter.sql} '
      'ORDER BY q.received_at_utc_ms DESC, q.id ASC LIMIT ? OFFSET ?',
      <Object?>[...filter.arguments, request.limit, request.offset],
    );
    return Page<ContractorQuote>(
      items: await _quotesFromRows(database, rows),
      totalCount: countRows.single['total']! as int,
      request: request,
    );
  }

  @override
  Future<ContractorQuote> reject({
    required String projectId,
    required String quoteId,
  }) {
    return _database.transaction<ContractorQuote>((transaction) async {
      final quote = await _requiredQuote(
        transaction,
        projectId: projectId,
        quoteId: quoteId,
      );
      if (quote.status != ContractorQuoteStatus.received) {
        throw const QuoteLockedException();
      }
      final changed = await transaction.update(
        AppDatabase.contractorQuotesTable,
        <String, Object?>{
          'status': 'rejected',
          'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
            _utcNow(),
          ),
        },
        where: 'project_id = ? AND id = ? AND status = ?',
        whereArgs: <Object?>[projectId, quoteId, 'received'],
      );
      if (changed != 1) throw const QuoteLockedException();
      return (await _findQuote(
        transaction,
        projectId: projectId,
        quoteId: quoteId,
      ))!;
    });
  }

  @override
  Future<QuoteAcceptanceResult> accept({
    required String projectId,
    required String quoteId,
    required QuoteCostTarget target,
  }) {
    return _database.transaction<QuoteAcceptanceResult>((transaction) async {
      final quote = await _requiredQuote(
        transaction,
        projectId: projectId,
        quoteId: quoteId,
      );
      final existingCostId = quote.acceptedCostEntryId;
      if (existingCostId != null) {
        return QuoteAcceptanceResult(
          quote: quote,
          costEntryId: existingCostId,
          createdCost: false,
        );
      }
      if (quote.status != ContractorQuoteStatus.received) {
        throw const QuoteLockedException();
      }
      final draft = quote.draft;
      final cost = await _costRepository.insertConfirmedInTransaction(
        transaction,
        ConfirmedCostEntryInput(
          CostEntryInput(
            projectId: projectId,
            name: draft.title,
            type: CostEntryType.planned,
            status: switch (target) {
              QuoteCostTarget.planned => CostStatus.planned,
              QuoteCostTarget.ordered => CostStatus.ordered,
            },
            amount: draft.amount,
            entryDate: _utcNow(),
            stageId: draft.stageId,
            contactId: draft.contactId,
            source: CostSource.offerConversion,
            attachmentIds: draft.attachmentIds,
            note: draft.note,
          ),
        ),
      );
      final changed = await transaction.update(
        AppDatabase.contractorQuotesTable,
        <String, Object?>{
          'status': 'accepted',
          'accepted_cost_entry_id': cost.id,
          'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
            _utcNow(),
          ),
        },
        where:
            'project_id = ? AND id = ? AND status = ? '
            'AND accepted_cost_entry_id IS NULL',
        whereArgs: <Object?>[projectId, quoteId, 'received'],
      );
      if (changed != 1) throw const QuoteLockedException();
      final accepted = (await _findQuote(
        transaction,
        projectId: projectId,
        quoteId: quoteId,
      ))!;
      return QuoteAcceptanceResult(
        quote: accepted,
        costEntryId: cost.id,
        createdCost: true,
      );
    });
  }

  @override
  Future<void> delete({required String projectId, required String quoteId}) {
    return _database.transaction<void>((transaction) async {
      final quote = await _requiredQuote(
        transaction,
        projectId: projectId,
        quoteId: quoteId,
      );
      if (quote.status == ContractorQuoteStatus.accepted) {
        throw const QuoteLockedException();
      }
      await transaction.delete(
        AppDatabase.contractorQuotesTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, quoteId],
      );
    });
  }

  static Future<void> _validateDraft(
    DatabaseExecutor executor, {
    required String projectId,
    required ContractorQuoteDraft draft,
  }) async {
    final projects = await executor.query(
      AppDatabase.projectsTable,
      columns: const <String>['currency_code'],
      where: 'id = ?',
      whereArgs: <Object?>[projectId],
      limit: 1,
    );
    if (projects.isEmpty) {
      throw ArgumentError.value(projectId, 'projectId', 'does not exist');
    }
    if (projects.single['currency_code'] != draft.amount.gross.currencyCode) {
      throw ArgumentError.value(
        draft.amount.gross.currencyCode,
        'draft',
        'must use project currency',
      );
    }
    final contacts = await executor.query(
      AppDatabase.contactsTable,
      columns: const <String>['id'],
      where: 'project_id = ? AND id = ? AND is_archived = 0',
      whereArgs: <Object?>[projectId, draft.contactId],
      limit: 1,
    );
    if (contacts.isEmpty) {
      throw ArgumentError.value(draft.contactId, 'draft.contactId');
    }
    final stageId = draft.stageId;
    if (stageId != null) {
      final stages = await executor.query(
        AppDatabase.projectStagesTable,
        columns: const <String>['id'],
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, stageId],
        limit: 1,
      );
      if (stages.isEmpty) {
        throw ArgumentError.value(stageId, 'draft.stageId');
      }
    }
    final attachmentIds = draft.attachmentIds;
    if (attachmentIds.isEmpty) return;
    final placeholders = List<String>.filled(
      attachmentIds.length,
      '?',
    ).join(', ');
    final attachments = await executor.query(
      AppDatabase.costAttachmentsTable,
      columns: const <String>['id'],
      where:
          'project_id = ? AND availability = ? '
          'AND id IN ($placeholders)',
      whereArgs: <Object?>[projectId, 'available', ...attachmentIds],
    );
    if (attachments.length != attachmentIds.length) {
      throw StateError('Every quote attachment must be available');
    }
  }

  static Future<void> _replaceRelations(
    DatabaseExecutor executor,
    ContractorQuote quote,
  ) async {
    await executor.delete(
      AppDatabase.quoteScopeLinesTable,
      where: 'project_id = ? AND quote_id = ?',
      whereArgs: <Object?>[quote.projectId, quote.id],
    );
    await _insertScopeLines(
      executor,
      quote,
      quote.draft.includedScope,
      kind: 'included',
    );
    await _insertScopeLines(
      executor,
      quote,
      quote.draft.excludedScope,
      kind: 'excluded',
    );
    await executor.delete(
      AppDatabase.quoteAttachmentsTable,
      where: 'project_id = ? AND quote_id = ?',
      whereArgs: <Object?>[quote.projectId, quote.id],
    );
    for (var index = 0; index < quote.draft.attachmentIds.length; index += 1) {
      await executor.insert(
        AppDatabase.quoteAttachmentsTable,
        <String, Object?>{
          'project_id': quote.projectId,
          'quote_id': quote.id,
          'attachment_id': quote.draft.attachmentIds[index],
          'sort_order': index,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  static Future<void> _insertScopeLines(
    DatabaseExecutor executor,
    ContractorQuote quote,
    List<QuoteScopeLine> lines, {
    required String kind,
  }) async {
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      await executor.insert(
        AppDatabase.quoteScopeLinesTable,
        <String, Object?>{
          'project_id': quote.projectId,
          'quote_id': quote.id,
          'kind': kind,
          'comparison_key': line.comparisonKey,
          'label': line.label,
          'details': line.details,
          'sort_order': index,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  static Future<ContractorQuote> _requiredQuote(
    DatabaseExecutor executor, {
    required String projectId,
    required String quoteId,
  }) async {
    final quote = await _findQuote(
      executor,
      projectId: projectId,
      quoteId: quoteId,
    );
    if (quote == null) throw const QuoteNotFoundException();
    return quote;
  }

  static Future<ContractorQuote?> _findQuote(
    DatabaseExecutor executor, {
    required String projectId,
    required String quoteId,
  }) async {
    final rows = await executor.query(
      AppDatabase.contractorQuotesTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, quoteId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (await _quotesFromRows(executor, rows)).single;
  }

  static Future<List<ContractorQuote>> _quotesFromRows(
    DatabaseExecutor executor,
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) return const <ContractorQuote>[];
    final projectId = rows.first['project_id']! as String;
    final quoteIds = rows.map((row) => row['id']! as String).toList();
    final placeholders = List<String>.filled(quoteIds.length, '?').join(', ');
    final scopeRows = await executor.query(
      AppDatabase.quoteScopeLinesTable,
      where: 'project_id = ? AND quote_id IN ($placeholders)',
      whereArgs: <Object?>[projectId, ...quoteIds],
      orderBy: 'quote_id ASC, kind ASC, sort_order ASC',
    );
    final attachmentRows = await executor.query(
      AppDatabase.quoteAttachmentsTable,
      columns: const <String>['quote_id', 'attachment_id'],
      where: 'project_id = ? AND quote_id IN ($placeholders)',
      whereArgs: <Object?>[projectId, ...quoteIds],
      orderBy: 'quote_id ASC, sort_order ASC',
    );
    final includedByQuote = <String, List<QuoteScopeLine>>{};
    final excludedByQuote = <String, List<QuoteScopeLine>>{};
    for (final row in scopeRows) {
      final target = row['kind'] == 'included'
          ? includedByQuote
          : excludedByQuote;
      target
          .putIfAbsent(row['quote_id']! as String, () => <QuoteScopeLine>[])
          .add(
            QuoteScopeLine(
              label: row['label']! as String,
              details: row['details'] as String?,
            ),
          );
    }
    final attachmentsByQuote = <String, List<String>>{};
    for (final row in attachmentRows) {
      attachmentsByQuote
          .putIfAbsent(row['quote_id']! as String, () => <String>[])
          .add(row['attachment_id']! as String);
    }
    return rows
        .map((row) {
          final quoteId = row['id']! as String;
          final amount = VatBreakdown.fromStoredValues(
            net: Money(
              minorUnits: row['net_minor_units']! as int,
              currencyCode: row['currency_code']! as String,
            ),
            vat: Money(
              minorUnits: row['vat_minor_units']! as int,
              currencyCode: row['currency_code']! as String,
            ),
            gross: Money(
              minorUnits: row['gross_minor_units']! as int,
              currencyCode: row['currency_code']! as String,
            ),
            rate: _vatRateFromStorage(row['vat_rate_basis_points']! as int),
          );
          return ContractorQuote(
            id: quoteId,
            projectId: row['project_id']! as String,
            draft: ContractorQuoteDraft(
              contactId: row['contact_id']! as String,
              title: row['title']! as String,
              variantName: row['variant_name']! as String,
              amount: amount,
              receivedAt: DatabaseValueCodec.utcMillisecondsToDateTime(
                row['received_at_utc_ms']! as int,
              ),
              validUntil: DatabaseValueCodec.utcMillisecondsToDateTime(
                row['valid_until_utc_ms']! as int,
              ),
              includedScope:
                  includedByQuote[quoteId] ?? const <QuoteScopeLine>[],
              excludedScope:
                  excludedByQuote[quoteId] ?? const <QuoteScopeLine>[],
              attachmentIds: attachmentsByQuote[quoteId] ?? const <String>[],
              stageId: row['stage_id'] as String?,
              note: row['note'] as String?,
            ),
            status: _statusFromStorage(row['status']! as String),
            acceptedCostEntryId: row['accepted_cost_entry_id'] as String?,
            createdAt: DatabaseValueCodec.utcMillisecondsToDateTime(
              row['created_at_utc_ms']! as int,
            ),
            updatedAt: DatabaseValueCodec.utcMillisecondsToDateTime(
              row['updated_at_utc_ms']! as int,
            ),
          );
        })
        .toList(growable: false);
  }
}

Map<String, Object?> _quoteToRow(ContractorQuote quote) {
  final draft = quote.draft;
  return <String, Object?>{
    'project_id': quote.projectId,
    'id': quote.id,
    'contact_id': draft.contactId,
    'stage_id': draft.stageId,
    'title': draft.title,
    'variant_name': draft.variantName,
    'status': quote.status.name,
    'received_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
      draft.receivedAtUtc,
    ),
    'valid_until_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
      draft.validUntilUtc,
    ),
    'net_minor_units': draft.amount.net.minorUnits,
    'vat_rate_basis_points': draft.amount.rate.basisPoints,
    'vat_minor_units': draft.amount.vat.minorUnits,
    'gross_minor_units': draft.amount.gross.minorUnits,
    'currency_code': draft.amount.gross.currencyCode,
    'note': draft.note,
    'accepted_cost_entry_id': quote.acceptedCostEntryId,
    'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
      quote.createdAtUtc,
    ),
    'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
      quote.updatedAtUtc,
    ),
  };
}

_QuoteFilter _buildFilter(QuoteQuery query) {
  final clauses = <String>['q.project_id = ?'];
  final arguments = <Object?>[query.projectId];
  final search = query.searchTerm;
  if (search != null) {
    clauses.add(
      "(LOWER(q.title) LIKE ? ESCAPE '\\' "
      "OR LOWER(q.variant_name) LIKE ? ESCAPE '\\' "
      "OR LOWER(c.display_name) LIKE ? ESCAPE '\\')",
    );
    final pattern = _likePattern(search);
    arguments.addAll(<Object?>[pattern, pattern, pattern]);
  }
  if (query.contactId != null) {
    clauses.add('q.contact_id = ?');
    arguments.add(query.contactId);
  }
  if (query.stageId != null) {
    clauses.add('q.stage_id = ?');
    arguments.add(query.stageId);
  }
  if (query.statuses.isNotEmpty) {
    final statuses = query.statuses.map((status) => status.name).toList()
      ..sort();
    clauses.add(
      'q.status IN (${List<String>.filled(statuses.length, '?').join(', ')})',
    );
    arguments.addAll(statuses);
  }
  return _QuoteFilter(sql: clauses.join(' AND '), arguments: arguments);
}

String _likePattern(String value) {
  final escaped = value
      .toLowerCase()
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
  return '%$escaped%';
}

VatRate _vatRateFromStorage(int value) => switch (value) {
  0 => VatRate.zero,
  800 => VatRate.reduced8,
  2300 => VatRate.standard23,
  _ => throw const FormatException('Unsupported VAT rate'),
};

ContractorQuoteStatus _statusFromStorage(String value) => switch (value) {
  'received' => ContractorQuoteStatus.received,
  'accepted' => ContractorQuoteStatus.accepted,
  'rejected' => ContractorQuoteStatus.rejected,
  _ => throw const FormatException('Unsupported quote status'),
};

final class _QuoteFilter {
  const _QuoteFilter({required this.sql, required this.arguments});

  final String sql;
  final List<Object?> arguments;
}
