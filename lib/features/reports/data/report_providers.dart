import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/reports/data/sqlite_budget_report_repository.dart';
import 'package:budowapro/features/reports/domain/budget_report.dart';
import 'package:budowapro/features/reports/domain/budget_report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final budgetReportRepositoryProvider = FutureProvider<BudgetReportRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteBudgetReportRepository(database: database);
});

final budgetReportProvider = FutureProvider.autoDispose
    .family<BudgetReport, String>((ref, projectId) async {
      final repository = await ref.watch(budgetReportRepositoryProvider.future);
      return repository.load(projectId: projectId);
    });
