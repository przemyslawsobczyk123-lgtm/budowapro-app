import 'budget_report.dart';

abstract interface class BudgetReportRepository {
  Future<BudgetReport> load({required String projectId});
}

final class BudgetReportProjectNotFoundException implements Exception {
  const BudgetReportProjectNotFoundException();
}
