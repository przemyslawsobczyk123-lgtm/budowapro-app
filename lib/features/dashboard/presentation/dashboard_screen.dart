import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/presentation/schedule_ui_text.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardControllerProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: dashboard.when(
          loading: () => AppLoadingState(label: l10n.dashboardLoading),
          error: (error, stackTrace) => AppErrorState(
            title: l10n.dashboardLoadError,
            retryLabel: l10n.retryAction,
            onRetry: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            final project = state.project;
            final snapshot = state.snapshot;
            if (project == null || snapshot == null) {
              return AppEmptyState(
                key: const ValueKey('dashboardNoProject'),
                icon: Icons.home_work_outlined,
                title: l10n.projectOverviewEmptyTitle,
                message: l10n.projectOverviewEmptyMessage,
                actionLabel: l10n.projectCreateAction,
                onAction: () => context.push('/projects/new'),
              );
            }
            if (snapshot.isEmptyProject) {
              return _EmptyProjectDashboard(
                key: const ValueKey('dashboardEmptyProject'),
                snapshot: snapshot,
              );
            }
            return _DashboardContent(
              key: const ValueKey('dashboardContent'),
              snapshot: snapshot,
            );
          },
        ),
      ),
    );
  }
}

class _EmptyProjectDashboard extends ConsumerWidget {
  const _EmptyProjectDashboard({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            sliver: SliverList.list(
              children: [
                _DashboardHeader(project: snapshot.project),
                const SizedBox(height: 54),
                Icon(
                  Icons.space_dashboard_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.dashboardEmptyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 7),
                Text(
                  l10n.dashboardEmptyMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Align(
                  child: FilledButton.icon(
                    onPressed: () => _openCost(context, ref, snapshot.project),
                    icon: const Icon(Icons.add_card_outlined),
                    label: Text(l10n.dashboardStartWithCost),
                  ),
                ),
                const SizedBox(height: 52),
                _QuickActions(project: snapshot.project),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            sliver: SliverList.list(
              children: [
                _DashboardHeader(project: snapshot.project),
                const SizedBox(height: 14),
                _BudgetOverview(snapshot: snapshot),
                const SizedBox(height: 10),
                _MetricStrip(snapshot: snapshot),
                const SizedBox(height: 22),
                _QuickActions(project: snapshot.project),
                const SizedBox(height: 18),
                _CaptureInboxRow(snapshot: snapshot),
                const SizedBox(height: 24),
                _CriticalSection(snapshot: snapshot),
                const SizedBox(height: 24),
                _StageTimeline(snapshot: snapshot),
                const SizedBox(height: 24),
                _UpcomingVisits(snapshot: snapshot),
                const SizedBox(height: 24),
                _TodayAgenda(snapshot: snapshot),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.startTitle,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 2),
              Text(
                project.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<_ProjectAction>(
          tooltip: l10n.dashboardProjectActionsTooltip,
          onSelected: (action) {
            switch (action) {
              case _ProjectAction.edit:
                context.push(
                  '/projects/${Uri.encodeComponent(project.id)}/edit',
                );
              case _ProjectAction.delete:
                _confirmProjectDeletion(context, ref, project);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<_ProjectAction>(
              value: _ProjectAction.edit,
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined),
                  const SizedBox(width: 10),
                  Text(l10n.projectEditAction),
                ],
              ),
            ),
            PopupMenuItem<_ProjectAction>(
              value: _ProjectAction.delete,
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded),
                  const SizedBox(width: 10),
                  Text(l10n.deleteAction),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }
}

class _BudgetOverview extends StatelessWidget {
  const _BudgetOverview({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final budget = snapshot.plannedBudget;
    final remaining = snapshot.remainingBudget;
    final isOverBudget = remaining?.isNegative ?? false;
    final utilization = snapshot.budgetUtilization;
    final percent = utilization == null ? null : (utilization * 100).round();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardCurrentStage,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentStageName(l10n, snapshot),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (percent != null)
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isOverBudget ? colors.error : colors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: l10n.dashboardBudgetTitle,
            value: percent == null ? null : '$percent%',
            child: LinearProgressIndicator(
              minHeight: 7,
              borderRadius: BorderRadius.circular(4),
              value: utilization?.clamp(0, 1).toDouble() ?? 0,
              color: isOverBudget ? colors.error : colors.primary,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  budget == null
                      ? l10n.dashboardBudgetNotSet
                      : l10n.dashboardSpentOfBudget(
                          _money(snapshot.spent),
                          _money(budget),
                        ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (remaining != null) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOverBudget
                          ? l10n.dashboardOverBudget
                          : l10n.dashboardRemaining,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      _money(isOverBudget ? -remaining : remaining),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isOverBudget ? colors.error : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Metric(
                label: l10n.dashboardSpent,
                value: _money(snapshot.spent),
              ),
            ),
            VerticalDivider(width: 1, color: colors.outlineVariant),
            Expanded(
              child: _Metric(
                label: l10n.dashboardPlan30,
                value: _money(snapshot.plannedNext30Days),
              ),
            ),
            VerticalDivider(width: 1, color: colors.outlineVariant),
            Expanded(
              child: _Metric(
                label: l10n.dashboardUnpaid,
                value: _money(snapshot.unpaid),
                detail: l10n.dashboardUnpaidItems(snapshot.unpaidCount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureInboxRow extends StatelessWidget {
  const _CaptureInboxRow({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      key: const ValueKey('dashboardCaptureInbox'),
      onTap: () => context.push('/captures'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Badge(
              isLabelVisible: snapshot.openCaptureCount > 0,
              label: Text('${snapshot.openCaptureCount}'),
              child: const Icon(Icons.inbox_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.captureInboxTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(l10n.captureInboxOpenTab(snapshot.openCaptureCount)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.detail});

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardQuickActions,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 9),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.15,
          children: [
            OutlinedButton.icon(
              onPressed: () => _openCost(context, ref, project),
              icon: const Icon(Icons.add_card_outlined),
              label: Text(l10n.dashboardAddCost, textAlign: TextAlign.center),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/projects/${Uri.encodeComponent(project.id)}'
                '/receipt-scans/new',
              ),
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text(
                l10n.dashboardScanReceipt,
                textAlign: TextAlign.center,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/plan?tab=stages'),
              icon: const Icon(Icons.checklist_outlined),
              label: Text(
                l10n.dashboardOpenChecklists,
                textAlign: TextAlign.center,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _openSchedule(context, ref, project),
              icon: const Icon(Icons.event_available_outlined),
              label: Text(
                l10n.dashboardAddSchedule,
                textAlign: TextAlign.center,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/projects/${Uri.encodeComponent(project.id)}'
                '/punch/defects/new',
              ),
              icon: const Icon(Icons.add_task_rounded),
              label: Text(l10n.dashboardAddDefect, textAlign: TextAlign.center),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/technical'),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                l10n.dashboardOpenTechnicalPhotos,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CriticalSection extends StatelessWidget {
  const _CriticalSection({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final records = snapshot.criticalChecklistItems.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.dashboardCritical,
          trailing: l10n.dashboardCriticalCount(
            snapshot.criticalChecklistItems.length,
          ),
        ),
        const SizedBox(height: 7),
        if (records.isEmpty)
          _SectionEmpty(
            icon: Icons.task_alt_rounded,
            text: l10n.dashboardCriticalEmpty,
          )
        else
          ...records.map((record) => _CriticalRow(record: record)),
      ],
    );
  }
}

class _CriticalRow extends StatelessWidget {
  const _CriticalRow({required this.record});

  final DashboardChecklistRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final risk = checklistRisk(l10n, record.item);
    return InkWell(
      onTap: () => context.go('/plan?tab=stages'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checklistTitle(l10n, record.item),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    risk.isEmpty ? stageName(l10n, record.stage) : risk,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _StageTimeline extends StatelessWidget {
  const _StageTimeline({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.dashboardStages),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.stages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final stage = snapshot.stages[index];
              return _StagePoint(
                stage: stage,
                isCurrent: stage.id == snapshot.currentStage?.id,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StagePoint extends StatelessWidget {
  const _StagePoint({required this.stage, required this.isCurrent});

  final ProjectStage stage;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isDone = stage.status == StageStatus.completed;
    final color = isCurrent || isDone ? colors.primary : colors.outline;
    return Semantics(
      button: true,
      label:
          '${stageName(l10n, stage)}, ${stageStatusLabel(l10n, stage.status)}',
      value: l10n.dashboardStageProgress(stage.progress.percent),
      child: InkWell(
        onTap: () => context.go('/plan?tab=stages'),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 82,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCurrent ? colors.primaryContainer : colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: isDone
                    ? Icon(Icons.check_rounded, size: 16, color: color)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                stageName(l10n, stage),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: isCurrent ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingVisits extends StatelessWidget {
  const _UpcomingVisits({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.dashboardUpcomingVisits,
          trailing: l10n.dashboardUpcomingVisitsCount(
            snapshot.upcomingVisits.length,
          ),
        ),
        const SizedBox(height: 7),
        if (snapshot.upcomingVisits.isEmpty)
          _SectionEmpty(
            icon: Icons.groups_outlined,
            text: l10n.dashboardUpcomingVisitsEmpty,
          )
        else
          ...snapshot.upcomingVisits.map((event) => _AgendaRow(event: event)),
      ],
    );
  }
}

class _TodayAgenda extends StatelessWidget {
  const _TodayAgenda({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.dashboardAgenda,
          trailing: l10n.dashboardAgendaCount(snapshot.todayAgenda.length),
        ),
        const SizedBox(height: 7),
        if (snapshot.todayAgenda.isEmpty)
          _SectionEmpty(
            icon: Icons.event_available_outlined,
            text: l10n.dashboardAgendaEmpty,
          )
        else
          ...snapshot.todayAgenda.map((event) => _AgendaRow(event: event)),
      ],
    );
  }
}

class _AgendaRow extends ConsumerWidget {
  const _AgendaRow({required this.event});

  final ScheduleEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localTime = _eventLocalTime(ref, event);
    final time = event.isAllDay
        ? l10n.scheduleAllDayLabel
        : DateFormat('HH:mm', 'pl_PL').format(localTime);
    final details = <String>[
      scheduleKindLabel(l10n, event.kind),
      scheduleStatusLabel(l10n, event.status),
      ?event.assignee,
    ].join(' · ');
    return InkWell(
      onTap: () async {
        await context.push(
          '/projects/${Uri.encodeComponent(event.projectId)}'
          '/schedule/${Uri.encodeComponent(event.id)}',
        );
        if (context.mounted) {
          await ref.read(dashboardControllerProvider.notifier).refresh();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(scheduleKindIcon(event.kind), size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (trailing != null)
          Text(trailing!, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

enum _ProjectAction { edit, delete }

Future<void> _openCost(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final changed = await context.push<bool>(
    '/projects/${Uri.encodeComponent(project.id)}/costs/new',
  );
  if (changed == true && context.mounted) {
    await ref.read(dashboardControllerProvider.notifier).refresh();
  }
}

Future<void> _openSchedule(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final changed = await context.push<bool>(
    '/projects/${Uri.encodeComponent(project.id)}/schedule/new',
  );
  if (changed == true && context.mounted) {
    await ref.read(dashboardControllerProvider.notifier).refresh();
  }
}

Future<void> _confirmProjectDeletion(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final l10n = AppLocalizations.of(context);
  ProjectDeletionImpact impact;
  try {
    impact = await ref
        .read(projectsControllerProvider.notifier)
        .deletionImpact(project.id);
  } on Object {
    if (context.mounted) {
      _showMessage(context, l10n.projectDeletionImpactError);
    }
    return;
  }
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.projectDeleteDialogTitle(project.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.projectDeleteWarning),
          const SizedBox(height: 14),
          Text(l10n.projectLinkedFilesCount(impact.linkedFileCount)),
          const SizedBox(height: 4),
          Text(l10n.projectLinkedRecordsCount(impact.linkedRecordCount)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.deleteAction),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(projectsControllerProvider.notifier).delete(project.id);
  } on Object {
    if (context.mounted) _showMessage(context, l10n.projectDeleteError);
  }
}

DateTime _eventLocalTime(WidgetRef ref, ScheduleEvent event) {
  try {
    return ref
        .read(scheduleNotificationGatewayProvider)
        .toTimeZone(event.startsAtUtc, event.timeZoneId);
  } on Object {
    return event.startsAtUtc.toLocal();
  }
}

String _currentStageName(AppLocalizations l10n, DashboardSnapshot snapshot) {
  final stage = snapshot.currentStage;
  return stage == null ? l10n.projectValueNotProvided : stageName(l10n, stage);
}

String _money(Money value) {
  final absolute = BigInt.from(value.minorUnits).abs();
  final whole = (absolute ~/ BigInt.from(100)).toString();
  final fraction = (absolute % BigInt.from(100)).toString().padLeft(2, '0');
  final groups = <String>[];
  for (var end = whole.length; end > 0; end -= 3) {
    groups.add(whole.substring((end - 3).clamp(0, end), end));
  }
  final symbol = value.currencyCode == 'PLN' ? 'zł' : value.currencyCode;
  return '${value.isNegative ? '-' : ''}'
      '${groups.reversed.join('\u00A0')},$fraction\u00A0$symbol';
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
