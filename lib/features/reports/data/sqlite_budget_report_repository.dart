import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/reports/domain/budget_report.dart';
import 'package:budowapro/features/reports/domain/budget_report_repository.dart';

final class SqliteBudgetReportRepository implements BudgetReportRepository {
  const SqliteBudgetReportRepository({required this._database});

  final AppDatabase _database;

  @override
  Future<BudgetReport> load({required String projectId}) {
    final normalizedProjectId = projectId.trim();
    if (normalizedProjectId.isEmpty || normalizedProjectId.length > 64) {
      throw ArgumentError.value(projectId, 'projectId', 'must be valid');
    }
    return _database.transaction((transaction) async {
      final projects = await transaction.query(
        AppDatabase.projectsTable,
        columns: const <String>['currency_code', 'planned_budget_minor_units'],
        where: 'id = ? AND deletion_pending = 0',
        whereArgs: <Object?>[normalizedProjectId],
        limit: 1,
      );
      if (projects.isEmpty) {
        throw const BudgetReportProjectNotFoundException();
      }
      final project = projects.single;
      final currencyCode = project['currency_code']! as String;
      final planMinorUnits = project['planned_budget_minor_units'] as int?;

      final totals = await transaction.rawQuery(
        '''
          WITH corrected_costs AS (
            $_correctedCostsSelect
          )
          SELECT
            COALESCE(SUM(corrected_gross), 0) AS committed_minor_units,
            COALESCE(
              SUM(CASE WHEN financial_status = 'paid'
                THEN corrected_gross ELSE 0 END),
              0
            ) AS paid_minor_units,
            COUNT(*) AS record_count
          FROM corrected_costs
        ''',
        <Object?>[normalizedProjectId],
      );
      final breakdownRows = await transaction.rawQuery(
        '''
          WITH corrected_costs AS (
            $_correctedCostsSelect
          ), breakdown AS (
            SELECT 'stage' AS dimension, stage_id AS group_key,
              SUM(corrected_gross) AS committed_minor_units,
              SUM(CASE WHEN financial_status = 'paid'
                THEN corrected_gross ELSE 0 END) AS paid_minor_units,
              COUNT(*) AS record_count
            FROM corrected_costs GROUP BY stage_id
            UNION ALL
            SELECT 'category', category_id,
              SUM(corrected_gross),
              SUM(CASE WHEN financial_status = 'paid'
                THEN corrected_gross ELSE 0 END),
              COUNT(*)
            FROM corrected_costs GROUP BY category_id
            UNION ALL
            SELECT 'supplier', supplier_id,
              SUM(corrected_gross),
              SUM(CASE WHEN financial_status = 'paid'
                THEN corrected_gross ELSE 0 END),
              COUNT(*)
            FROM corrected_costs GROUP BY supplier_id
            UNION ALL
            SELECT 'month',
              strftime(
                '%Y-%m', entry_date_utc_ms / 1000, 'unixepoch', 'localtime'
              ),
              SUM(corrected_gross),
              SUM(CASE WHEN financial_status = 'paid'
                THEN corrected_gross ELSE 0 END),
              COUNT(*)
            FROM corrected_costs
            GROUP BY strftime(
              '%Y-%m', entry_date_utc_ms / 1000, 'unixepoch', 'localtime'
            )
          )
          SELECT * FROM breakdown
          ORDER BY dimension, committed_minor_units DESC, group_key
        ''',
        <Object?>[normalizedProjectId],
      );

      final breakdowns = <BudgetBreakdownDimension, List<BudgetReportSlice>>{};
      for (final row in breakdownRows) {
        final dimension = _dimensionFromDatabase(row['dimension']! as String);
        breakdowns
            .putIfAbsent(dimension, () => <BudgetReportSlice>[])
            .add(
              BudgetReportSlice(
                key: row['group_key'] as String?,
                committed: _money(row['committed_minor_units']!, currencyCode),
                paid: _money(row['paid_minor_units']!, currencyCode),
                recordCount: row['record_count']! as int,
              ),
            );
      }

      final total = totals.single;
      return BudgetReport(
        projectId: normalizedProjectId,
        currencyCode: currencyCode,
        plan: planMinorUnits == null
            ? null
            : Money(minorUnits: planMinorUnits, currencyCode: currencyCode),
        committed: _money(total['committed_minor_units']!, currencyCode),
        paid: _money(total['paid_minor_units']!, currencyCode),
        costRecordCount: total['record_count']! as int,
        breakdowns: breakdowns,
      );
    });
  }
}

const _correctedCostsSelect =
    '''
  SELECT
    entry.stage_id,
    entry.category_id,
    entry.supplier_id,
    entry.financial_status,
    entry.entry_date_utc_ms,
    entry.gross_minor_units + COALESCE((
      SELECT SUM(correction.gross_delta_minor_units)
      FROM ${AppDatabase.costCorrectionsTable} correction
      WHERE correction.project_id = entry.project_id
        AND correction.cost_entry_id = entry.id
    ), 0) AS corrected_gross
  FROM ${AppDatabase.costEntriesTable} entry
  WHERE entry.project_id = ?
    AND entry.lifecycle = 'confirmed'
    AND entry.entry_type = 'cost'
''';

Money _money(Object value, String currencyCode) =>
    Money(minorUnits: value as int, currencyCode: currencyCode);

BudgetBreakdownDimension _dimensionFromDatabase(String value) =>
    switch (value) {
      'stage' => BudgetBreakdownDimension.stage,
      'category' => BudgetBreakdownDimension.category,
      'supplier' => BudgetBreakdownDimension.supplier,
      'month' => BudgetBreakdownDimension.month,
      _ => throw FormatException('Unsupported report dimension: $value'),
    };
