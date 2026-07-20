import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_summary.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CostBudgetScreen extends ConsumerWidget {
  const CostBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsControllerProvider);
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: projects.when(
          loading: () => AppLoadingState(label: localizations.projectsLoading),
          error: (error, stackTrace) => AppErrorState(
            title: localizations.projectsLoadError,
            retryLabel: localizations.retryAction,
            onRetry: () =>
                ref.read(projectsControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            final project = state.selectedProject;
            if (project == null) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        localizations.budgetTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: localizations.costBudgetNoProjectTitle,
                      message: localizations.costBudgetNoProjectMessage,
                    ),
                  ),
                ],
              );
            }
            return _ProjectBudget(project: project);
          },
        ),
      ),
    );
  }
}

class _ProjectBudget extends ConsumerWidget {
  const _ProjectBudget({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(costRepositoryProvider);
    final localizations = AppLocalizations.of(context);
    return repository.when(
      loading: () => AppLoadingState(label: localizations.projectsLoading),
      error: (error, stackTrace) => AppErrorState(
        title: localizations.costBudgetLoadError,
        retryLabel: localizations.retryAction,
        onRetry: () => ref.invalidate(costRepositoryProvider),
      ),
      data: (value) => FutureBuilder<_BudgetData>(
        future: _loadBudget(value, project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: localizations.projectsLoading);
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return AppErrorState(
              title: localizations.costBudgetLoadError,
              retryLabel: localizations.retryAction,
              onRetry: () => ref.invalidate(costRepositoryProvider),
            );
          }
          return _BudgetContent(
            project: project,
            data: snapshot.data!,
            onChanged: () => ref.invalidate(costRepositoryProvider),
          );
        },
      ),
    );
  }
}

class _BudgetContent extends StatelessWidget {
  const _BudgetContent({
    required this.project,
    required this.data,
    required this.onChanged,
  });

  final Project project;
  final _BudgetData data;
  final VoidCallback onChanged;

  Future<void> _openNewCost(BuildContext context) async {
    await context.push(
      '/projects/${Uri.encodeComponent(project.id)}/costs/new',
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.budgetTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('costBudgetAdd'),
                    tooltip: localizations.costBudgetAddTooltip,
                    onPressed: () => _openNewCost(context),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _BudgetSummary(project: project, summary: data.summary),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('costBudgetCreate'),
                onPressed: () => _openNewCost(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(localizations.costBudgetAddTooltip),
              ),
              const SizedBox(height: 20),
              if (data.entries.isEmpty)
                AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: localizations.costBudgetEmptyTitle,
                  message: localizations.costBudgetEmptyMessage,
                )
              else
                ...data.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BudgetEntry(
                      project: project,
                      entry: entry,
                      onChanged: onChanged,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.project, required this.summary});

  final Project project;
  final CostSummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final values = [
              _SummaryValue(
                label: localizations.costBudgetPlannedLabel,
                value: _money(summary.planned, project.currencyCode),
              ),
              _SummaryValue(
                label: localizations.costBudgetActualLabel,
                value: _money(summary.actual, project.currencyCode),
              ),
              _SummaryValue(
                label: localizations.costBudgetDifferenceLabel,
                value: _money(summary.difference, project.currencyCode),
              ),
            ];
            if (constraints.maxWidth < 520) {
              return Column(
                children: values
                    .map(
                      (value) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: value,
                      ),
                    )
                    .toList(growable: false),
              );
            }
            return Row(
              children: values
                  .map((value) => Expanded(child: value))
                  .toList(growable: false),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 2),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

class _BudgetEntry extends StatelessWidget {
  const _BudgetEntry({
    required this.project,
    required this.entry,
    required this.onChanged,
  });

  final Project project;
  final CostEntry entry;
  final VoidCallback onChanged;

  Future<void> _openDetails(BuildContext context) async {
    await context.push(
      '/projects/${Uri.encodeComponent(project.id)}/costs/${Uri.encodeComponent(entry.id)}',
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(_entryIcon(entry.type), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.lifecycle == CostLifecycle.draft ? localizations.costDraftLabel : _budgetStatus(localizations, entry.status)} · ${_date(entry.entryDate.toLocal())}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _money(entry.amount.gross, project.currencyCode),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetData {
  const _BudgetData({required this.entries, required this.summary});

  final List<CostEntry> entries;
  final CostSummary summary;
}

Future<_BudgetData> _loadBudget(
  CostRepository repository,
  String projectId,
) async {
  final entries = await repository.list(
    CostQuery(projectId: projectId, includeDrafts: true),
    PageRequest(limit: PageRequest.maximumLimit),
  );
  final summary = await repository.summarize(
    CostSummaryQuery(projectId: projectId),
  );
  return _BudgetData(entries: entries.items, summary: summary);
}

String _money(Money value, String currencyCode) =>
    formatMoneyForDisplay(value, currencyCode);

String _date(DateTime value) => DateFormat('dd.MM.yyyy', 'pl_PL').format(value);

IconData _entryIcon(CostEntryType type) => switch (type) {
  CostEntryType.cost => Icons.receipt_long_outlined,
  CostEntryType.offer => Icons.request_quote_outlined,
  CostEntryType.planned => Icons.event_note_outlined,
};

String _budgetStatus(AppLocalizations l10n, CostStatus value) =>
    switch (value) {
      CostStatus.planned => l10n.costStatusPlanned,
      CostStatus.ordered => l10n.costStatusOrdered,
      CostStatus.due => l10n.costStatusDue,
      CostStatus.paid => l10n.costStatusPaid,
      CostStatus.returned => l10n.costStatusReturned,
      CostStatus.disputed => l10n.costStatusDisputed,
    };
