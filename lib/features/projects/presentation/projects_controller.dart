import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final projectsControllerProvider =
    AsyncNotifierProvider<ProjectsController, ProjectsState>(
      ProjectsController.new,
    );

final class ProjectsState {
  ProjectsState({
    required Iterable<Project> projects,
    required this.selectedProject,
  }) : projects = List<Project>.unmodifiable(projects);

  final List<Project> projects;
  final Project? selectedProject;
}

final class ProjectsController extends AsyncNotifier<ProjectsState> {
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<ProjectsState> build() async {
    final repository = await ref.watch(projectRepositoryProvider.future);
    return _load(repository);
  }

  Future<void> refresh() async {
    final repository = await ref.read(projectRepositoryProvider.future);
    if (!ref.mounted) return;
    state = const AsyncLoading<ProjectsState>();
    final refreshed = await AsyncValue.guard(() => _load(repository));
    if (!ref.mounted) return;
    state = refreshed;
  }

  Future<void> create(ProjectDraft draft) {
    return _mutate((repository) => repository.create(draft));
  }

  Future<void> updateProject(String projectId, ProjectDraft draft) {
    return _mutate((repository) => repository.update(projectId, draft));
  }

  Future<void> setCurrentStage(Project project, ProjectStageKey stage) {
    if (!project.template.definition.stages.contains(stage)) {
      throw ArgumentError.value(stage, 'stage');
    }
    return updateProject(
      project.id,
      ProjectDraft(
        name: project.name,
        type: project.type,
        template: project.template,
        locationLabel: project.locationLabel,
        currencyCode: project.currencyCode,
        areaSquareMeters: project.areaSquareMeters,
        plannedBudgetMinorUnits: project.plannedBudgetMinorUnits,
        plannedStart: project.plannedStart,
        plannedEnd: project.plannedEnd,
        dateFormat: project.dateFormat,
        currentStage: stage,
      ),
    );
  }

  Future<void> select(String projectId) {
    return _mutate((repository) => repository.select(projectId));
  }

  Future<void> setArchived(String projectId, {required bool isArchived}) {
    return _mutate(
      (repository) => repository.setArchived(projectId, isArchived: isArchived),
    );
  }

  Future<ProjectDeletionImpact> deletionImpact(String projectId) async {
    final repository = await ref.read(projectRepositoryProvider.future);
    return repository.deletionImpact(projectId);
  }

  Future<void> delete(String projectId) {
    return _mutate((repository) => repository.delete(projectId));
  }

  Future<void> _mutate(
    Future<Object?> Function(ProjectRepository repository) action,
  ) {
    final mutation = _mutationQueue.then<void>((_) async {
      if (!ref.mounted) return;
      final previousState = state;
      try {
        final repository = await ref.read(projectRepositoryProvider.future);
        if (!ref.mounted) return;
        await action(repository);
        if (!ref.mounted) return;
        final refreshed = await _load(repository);
        if (!ref.mounted) return;
        state = AsyncData<ProjectsState>(refreshed);
      } on Object catch (error, stackTrace) {
        if (ref.mounted) {
          state = previousState;
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _mutationQueue = mutation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return mutation;
  }

  static Future<ProjectsState> _load(ProjectRepository repository) async {
    final projects = <Project>[];
    var request = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await repository.list(request);
      projects.addAll(page.items);
      final nextRequest = page.nextRequest;
      if (nextRequest == null) {
        break;
      }
      request = nextRequest;
    }
    return ProjectsState(
      projects: projects,
      selectedProject: await repository.selected(),
    );
  }
}
