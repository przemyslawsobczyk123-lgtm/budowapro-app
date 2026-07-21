import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/reports/data/report_providers.dart';
import 'package:budowapro/features/reports/domain/budget_report.dart';
import 'package:budowapro/features/reports/domain/budget_report_repository.dart';
import 'package:budowapro/features/reports/presentation/budget_report_screen.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('shows report totals at 320 px and drills into a stage', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final project = _project();
    final report = BudgetReport(
      projectId: project.id,
      currencyCode: 'PLN',
      plan: _pln(42000000),
      committed: _pln(15100000),
      paid: _pln(9000000),
      costRecordCount: 4,
      breakdowns: {
        BudgetBreakdownDimension.stage: [
          BudgetReportSlice(
            key: 'stage-zero',
            committed: _pln(14100000),
            paid: _pln(9000000),
            recordCount: 3,
          ),
          BudgetReportSlice(
            key: null,
            committed: _pln(1000000),
            paid: _pln(0),
            recordCount: 1,
          ),
        ],
      },
    );
    await tester.pumpWidget(_app(project: project, report: report));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('budgetReportContent')), findsOneWidget);
    expect(find.text('420\u00A0000,00 PLN'), findsOneWidget);
    expect(find.text('269\u00A0000,00 PLN'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('budgetReportSlice-stage-stage-zero')),
    );
    await tester.tap(
      find.byKey(const ValueKey('budgetReportSlice-stage-stage-zero')),
    );
    await tester.pumpAndSettle();

    expect(find.text('type=cost'), findsOneWidget);
    expect(find.text('stageId=stage-zero'), findsOneWidget);
  });

  testWidgets('does not render a zero chart for an empty project', (
    tester,
  ) async {
    final project = _project();
    final report = BudgetReport(
      projectId: project.id,
      currencyCode: 'PLN',
      plan: _pln(42000000),
      committed: _pln(0),
      paid: _pln(0),
      costRecordCount: 0,
    );
    await tester.pumpWidget(_app(project: project, report: report));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('budgetReportEmptyCosts')),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}

Widget _app({required Project project, required BudgetReport report}) {
  final projects = FakeProjectRepository(
    projects: [project],
    selectedProjectId: project.id,
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BudgetReportScreen(),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => Scaffold(
          body: Column(
            children: state.uri.queryParameters.entries
                .map((entry) => Text('${entry.key}=${entry.value}'))
                .toList(growable: false),
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith((ref) async => projects),
      budgetReportRepositoryProvider.overrideWith(
        (ref) async => _FakeBudgetReportRepository(report),
      ),
      projectStagesProvider(
        project,
      ).overrideWith((ref) async => <ProjectStage>[_stage()]),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

final class _FakeBudgetReportRepository implements BudgetReportRepository {
  const _FakeBudgetReportRepository(this.report);

  final BudgetReport report;

  @override
  Future<BudgetReport> load({required String projectId}) async => report;
}

Project _project() => Project(
  id: 'project-1',
  draft: ProjectDraft(
    name: 'Dom',
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
    plannedBudgetMinorUnits: 42000000,
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

ProjectStage _stage() => ProjectStage(
  id: 'stage-zero',
  projectId: 'project-1',
  templateKey: ProjectStageKey.stateZero,
  status: StageStatus.inProgress,
  sortOrder: 0,
  progress: StageProgress.fromStatuses(const <ChecklistStatus>[]),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

Money _pln(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');
