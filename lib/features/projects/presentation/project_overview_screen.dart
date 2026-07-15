import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProjectOverviewScreen extends ConsumerWidget {
  const ProjectOverviewScreen({super.key});

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
            onRetry: () {
              ref.read(projectsControllerProvider.notifier).refresh();
            },
          ),
          data: (state) {
            final project = state.selectedProject;
            if (project == null) {
              return AppEmptyState(
                icon: Icons.home_work_outlined,
                title: localizations.projectOverviewEmptyTitle,
                message: localizations.projectOverviewEmptyMessage,
                actionLabel: localizations.projectCreateAction,
                onAction: () => context.push('/projects/new'),
              );
            }
            return _ProjectOverview(project: project);
          },
        ),
      ),
    );
  }
}

class _ProjectOverview extends ConsumerWidget {
  const _ProjectOverview({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final start = project.plannedStart;
    final end = project.plannedEnd;
    final dateValue = start == null && end == null
        ? localizations.projectValueNotProvided
        : localizations.projectDateRangeValue(
            start == null
                ? localizations.projectValueNotProvided
                : formatProjectDate(start, project.dateFormat),
            end == null
                ? localizations.projectValueNotProvided
                : formatProjectDate(end, project.dateFormat),
          );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          sliver: SliverList.list(
            children: [
              Text(
                localizations.projectOverviewTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: const ValueKey('projectDelete'),
                    tooltip: localizations.deleteAction,
                    onPressed: () => _confirmDeletion(context, ref),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProjectChip(
                    icon: Icons.flag_outlined,
                    label: projectStageLabel(
                      localizations,
                      project.currentStage,
                    ),
                    emphasized: true,
                  ),
                  _ProjectChip(
                    icon: Icons.home_work_outlined,
                    label: projectTypeLabel(localizations, project.type),
                  ),
                  if (project.areaSquareMeters case final area?)
                    _ProjectChip(
                      icon: Icons.square_foot_outlined,
                      label: localizations.projectAreaValue(area),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _ProjectDetailRow(
                      icon: Icons.location_on_outlined,
                      label: localizations.projectLocationOverviewLabel,
                      value:
                          project.locationLabel ??
                          localizations.projectValueNotProvided,
                    ),
                    const Divider(height: 1),
                    _ProjectDetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: localizations.projectBudgetOverviewLabel,
                      value: formatProjectBudget(
                        localizations,
                        project.plannedBudgetMinorUnits,
                        project.currencyCode,
                      ),
                    ),
                    const Divider(height: 1),
                    _ProjectDetailRow(
                      icon: Icons.date_range_outlined,
                      label: localizations.projectDatesOverviewLabel,
                      value: dateValue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/projects/${Uri.encodeComponent(project.id)}/edit',
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(localizations.projectEditAction),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeletion(BuildContext context, WidgetRef ref) async {
    final localizations = AppLocalizations.of(context);
    ProjectDeletionImpact impact;
    try {
      impact = await ref
          .read(projectsControllerProvider.notifier)
          .deletionImpact(project.id);
    } on Object {
      if (context.mounted) {
        _showMessage(context, localizations.projectDeletionImpactError);
      }
      return;
    }
    if (!context.mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          localizations.projectDeleteDialogTitle(impact.project.name),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.projectDeleteWarning),
            const SizedBox(height: 16),
            Text(localizations.projectLinkedFilesCount(impact.linkedFileCount)),
            const SizedBox(height: 6),
            Text(
              localizations.projectLinkedRecordsCount(impact.linkedRecordCount),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const ValueKey('projectDeleteCancel'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancelAction),
          ),
          FilledButton(
            key: const ValueKey('projectDeleteConfirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(localizations.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(projectsControllerProvider.notifier).delete(project.id);
    } on Object {
      if (context.mounted) {
        _showMessage(context, localizations.projectDeleteError);
      }
    }
  }
}

class _ProjectChip extends StatelessWidget {
  const _ProjectChip({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _ProjectDetailRow extends StatelessWidget {
  const _ProjectDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
