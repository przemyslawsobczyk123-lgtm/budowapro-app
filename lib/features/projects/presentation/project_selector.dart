import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProjectSelector extends ConsumerWidget {
  const ProjectSelector({super.key});

  static const _newProjectSelection = '__new_project__';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsControllerProvider);
    final localizations = AppLocalizations.of(context);

    return SizedBox(
      height: 52,
      child: projects.when(
        loading: () => const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, stackTrace) => Row(
          children: [
            Expanded(
              child: Text(
                localizations.projectSelectorError,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: localizations.retryAction,
              onPressed: () {
                ref.read(projectsControllerProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        data: (state) {
          final selected = state.selectedProject;
          if (selected == null) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const ValueKey('projectSelectorNew'),
                onPressed: () => context.push('/projects/new'),
                icon: const Icon(Icons.add_home_work_outlined),
                label: Text(localizations.projectSelectorNewAction),
              ),
            );
          }
          return _SelectedProjectButton(
            project: selected,
            onPressed: () => _showProjects(context, ref, state),
          );
        },
      ),
    );
  }

  Future<void> _showProjects(
    BuildContext context,
    WidgetRef ref,
    ProjectsState state,
  ) async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _ProjectSelectionSheet(state: state),
    );
    if (selectedId == null || !context.mounted) {
      return;
    }
    if (selectedId == _newProjectSelection) {
      context.push('/projects/new');
      return;
    }
    try {
      await ref.read(projectsControllerProvider.notifier).select(selectedId);
    } on Object {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.projectSelectorSelectError)),
        );
      }
    }
  }
}

class _SelectedProjectButton extends StatelessWidget {
  const _SelectedProjectButton({
    required this.project,
    required this.onPressed,
  });

  final Project project;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('projectSelectorButton'),
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.construction_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.projectSelectorLabel,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectSelectionSheet extends StatelessWidget {
  const _ProjectSelectionSheet({required this.state});

  final ProjectsState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.projectSelectorChoose,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('projectSelectorNew'),
                    tooltip: localizations.projectSelectorNewAction,
                    onPressed: () => Navigator.pop(
                      context,
                      ProjectSelector._newProjectSelection,
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.projects.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  final selected = project.id == state.selectedProject?.id;
                  final subtitle = <String>[
                    projectStageLabel(localizations, project.currentStage),
                    ?project.locationLabel,
                  ].join(' · ');
                  return ListTile(
                    key: ValueKey('projectSelectorItem-${project.id}'),
                    leading: Icon(
                      project.type == ProjectType.apartmentRenovation
                          ? Icons.apartment_outlined
                          : Icons.home_work_outlined,
                    ),
                    title: Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: selected
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, project.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
