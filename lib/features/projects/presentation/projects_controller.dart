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
    state = const AsyncLoading<ProjectsState>();
    state = await AsyncValue.guard(() => _load(repository));
  }

  Future<void> create(ProjectDraft draft) {
    return _mutate((repository) => repository.create(draft));
  }

  Future<void> updateProject(String projectId, ProjectDraft draft) {
    return _mutate((repository) => repository.update(projectId, draft));
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
      final previousState = state;
      try {
        final repository = await ref.read(projectRepositoryProvider.future);
        await action(repository);
        state = AsyncData<ProjectsState>(await _load(repository));
      } on Object catch (error, stackTrace) {
        state = previousState;
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
