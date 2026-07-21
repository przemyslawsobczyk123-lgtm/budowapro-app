import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/reports/data/report_providers.dart';
import 'package:budowapro/features/reports/domain/budget_report.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BudgetReportScreen extends ConsumerWidget {
  const BudgetReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgetReportTitle)),
      body: projects.when(
        loading: () => AppLoadingState(label: l10n.projectsLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.projectsLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () =>
              ref.read(projectsControllerProvider.notifier).refresh(),
        ),
        data: (state) {
          final project = state.selectedProject;
          if (project == null) {
            return AppEmptyState(
              icon: Icons.query_stats_outlined,
              title: l10n.budgetReportNoProjectTitle,
              message: l10n.budgetReportNoProjectMessage,
            );
          }
          return _ProjectReport(project: project);
        },
      ),
    );
  }
}

class _ProjectReport extends ConsumerWidget {
  const _ProjectReport({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reportProvider = budgetReportProvider(project.id);
    final report = ref.watch(reportProvider);
    final stages = ref.watch(projectStagesProvider(project));
    return report.when(
      loading: () => AppLoadingState(label: l10n.budgetReportLoading),
      error: (error, stackTrace) => AppErrorState(
        title: l10n.budgetReportLoadError,
        retryLabel: l10n.retryAction,
        onRetry: () => ref.invalidate(reportProvider),
      ),
      data: (value) => stages.when(
        loading: () => AppLoadingState(label: l10n.budgetReportLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.budgetReportLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(projectStagesProvider(project)),
        ),
        data: (projectStages) => _ReportContent(
          report: value,
          stages: projectStages,
          onRefresh: () async {
            ref.invalidate(reportProvider);
            ref.invalidate(projectStagesProvider(project));
            await Future.wait([
              ref.read(reportProvider.future),
              ref.read(projectStagesProvider(project).future),
            ]);
          },
        ),
      ),
    );
  }
}

class _ReportContent extends StatefulWidget {
  const _ReportContent({
    required this.report,
    required this.stages,
    required this.onRefresh,
  });

  final BudgetReport report;
  final List<ProjectStage> stages;
  final Future<void> Function() onRefresh;

  @override
  State<_ReportContent> createState() => _ReportContentState();
}

class _ReportContentState extends State<_ReportContent> {
  var _dimension = BudgetBreakdownDimension.stage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = widget.report;
    final stageLabels = <String, String>{
      for (final stage in widget.stages) stage.id: stageName(l10n, stage),
    };
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        key: const ValueKey('budgetReportContent'),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _BudgetSummary(report: report),
          if (!report.hasCosts)
            const _EmptyCosts()
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                l10n.budgetReportBreakdownHeading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<BudgetBreakdownDimension>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: BudgetBreakdownDimension.stage,
                    icon: const Icon(Icons.foundation_outlined),
                    label: Text(l10n.budgetReportDimensionStage),
                  ),
                  ButtonSegment(
                    value: BudgetBreakdownDimension.category,
                    icon: const Icon(Icons.category_outlined),
                    label: Text(l10n.budgetReportDimensionCategory),
                  ),
                  ButtonSegment(
                    value: BudgetBreakdownDimension.supplier,
                    icon: const Icon(Icons.handyman_outlined),
                    label: Text(l10n.budgetReportDimensionSupplier),
                  ),
                  ButtonSegment(
                    value: BudgetBreakdownDimension.month,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(l10n.budgetReportDimensionMonth),
                  ),
                ],
                selected: {_dimension},
                onSelectionChanged: (selection) {
                  setState(() => _dimension = selection.single);
                },
              ),
            ),
            const SizedBox(height: 12),
            _BreakdownList(
              dimension: _dimension,
              slices: report.slicesFor(_dimension),
              currencyCode: report.currencyCode,
              stageLabels: stageLabels,
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.report});

  final BudgetReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remaining = report.remaining;
    final isOverBudget = remaining?.isNegative == true;
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOverBudget
                  ? l10n.budgetReportOverBudgetHeading
                  : l10n.budgetReportRemainingHeading,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              remaining == null
                  ? l10n.budgetReportNoPlan
                  : _money(remaining, report.currencyCode),
              key: const ValueKey('budgetReportRemaining'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isOverBudget ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth / 2;
                return Wrap(
                  children: [
                    _Metric(
                      width: width,
                      label: l10n.budgetReportPlanLabel,
                      value: report.plan == null
                          ? l10n.budgetReportNoPlan
                          : _money(report.plan!, report.currencyCode),
                    ),
                    _Metric(
                      key: const ValueKey('budgetReportCommitted'),
                      width: width,
                      label: l10n.budgetReportCommittedLabel,
                      value: _money(report.committed, report.currencyCode),
                      onTap: () => _openCosts(context),
                    ),
                    _Metric(
                      key: const ValueKey('budgetReportPaid'),
                      width: width,
                      label: l10n.budgetReportPaidLabel,
                      value: _money(report.paid, report.currencyCode),
                      onTap: () => _openCosts(context, status: CostStatus.paid),
                    ),
                    _Metric(
                      width: width,
                      label: l10n.budgetReportRemainingLabel,
                      value: remaining == null
                          ? l10n.budgetReportNoPlan
                          : _money(remaining, report.currencyCode),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.width,
    required this.label,
    required this.value,
    this.onTap,
    super.key,
  });

  final double width;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 76,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BreakdownList extends StatelessWidget {
  const _BreakdownList({
    required this.dimension,
    required this.slices,
    required this.currencyCode,
    required this.stageLabels,
  });

  final BudgetBreakdownDimension dimension;
  final List<BudgetReportSlice> slices;
  final String currencyCode;
  final Map<String, String> stageLabels;

  @override
  Widget build(BuildContext context) {
    final maximum = slices.fold<int>(
      0,
      (value, slice) => value > slice.committed.minorUnits
          ? value
          : slice.committed.minorUnits,
    );
    return Column(
      children: [
        for (var index = 0; index < slices.length; index++) ...[
          _BreakdownRow(
            key: ValueKey(
              'budgetReportSlice-${dimension.name}-${slices[index].key ?? 'none'}',
            ),
            dimension: dimension,
            slice: slices[index],
            label: _sliceLabel(
              context,
              dimension,
              slices[index].key,
              stageLabels,
            ),
            currencyCode: currencyCode,
            progress: maximum == 0
                ? null
                : slices[index].committed.minorUnits / maximum,
          ),
          if (index < slices.length - 1)
            const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.dimension,
    required this.slice,
    required this.label,
    required this.currencyCode,
    required this.progress,
    super.key,
  });

  final BudgetBreakdownDimension dimension;
  final BudgetReportSlice slice;
  final String label;
  final String currencyCode;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: '$label, ${_money(slice.committed, currencyCode)}',
      child: InkWell(
        onTap: () => _openCosts(context, dimension: dimension, slice: slice),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${l10n.budgetReportPaidDetail(_money(slice.paid, currencyCode))} · '
                      '${l10n.budgetReportRecordCount(slice.recordCount)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (progress case final value?) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: value,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 112),
                child: Text(
                  _money(slice.committed, currencyCode),
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCosts extends StatelessWidget {
  const _EmptyCosts();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      key: const ValueKey('budgetReportEmptyCosts'),
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.budgetReportEmptyCostsTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.budgetReportEmptyCostsMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

void _openCosts(
  BuildContext context, {
  CostStatus? status,
  BudgetBreakdownDimension? dimension,
  BudgetReportSlice? slice,
}) {
  final parameters = <String, String>{'type': CostEntryType.cost.name};
  if (status != null) parameters['status'] = status.name;
  if (dimension != null && slice != null) {
    final key = slice.key;
    if (key == null) {
      parameters['unassigned'] = dimension.name;
    } else {
      switch (dimension) {
        case BudgetBreakdownDimension.stage:
          parameters['stageId'] = key;
          break;
        case BudgetBreakdownDimension.category:
          parameters['categoryId'] = key;
          break;
        case BudgetBreakdownDimension.supplier:
          parameters['supplierId'] = key;
          break;
        case BudgetBreakdownDimension.month:
          final month = _parseMonth(key);
          if (month != null) {
            final nextMonth = DateTime(month.year, month.month + 1);
            parameters['from'] = _dateParameter(month);
            parameters['to'] = _dateParameter(
              nextMonth.subtract(const Duration(days: 1)),
            );
          }
          break;
      }
    }
  }
  context.go(Uri(path: '/budget', queryParameters: parameters).toString());
}

String _sliceLabel(
  BuildContext context,
  BudgetBreakdownDimension dimension,
  String? key,
  Map<String, String> stageLabels,
) {
  final l10n = AppLocalizations.of(context);
  if (key == null) return l10n.budgetReportNoAssignment;
  if (dimension == BudgetBreakdownDimension.stage) {
    return stageLabels[key] ?? key;
  }
  if (dimension == BudgetBreakdownDimension.month) {
    final month = _parseMonth(key);
    if (month != null) {
      final label = DateFormat('LLLL yyyy', 'pl_PL').format(month);
      return '${label[0].toUpperCase()}${label.substring(1)}';
    }
  }
  return key;
}

DateTime? _parseMonth(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  if (month < 1 || month > 12) return null;
  return DateTime(year, month);
}

String _dateParameter(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

String _money(Money value, String currencyCode) =>
    formatMoneyForDisplay(value, currencyCode);
