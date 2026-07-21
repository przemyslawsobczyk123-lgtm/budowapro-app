import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactsControllerProvider =
    AsyncNotifierProvider<ContactsController, ContactsState>(
      ContactsController.new,
    );

final class ContactsState {
  ContactsState({
    required this.project,
    required Iterable<Contact> contacts,
    required Iterable<ProjectStage> stages,
    required this.searchTerm,
    required this.roleFilter,
    required this.stageFilter,
    this.isSaving = false,
  }) : contacts = List<Contact>.unmodifiable(contacts),
       stages = List<ProjectStage>.unmodifiable(stages);

  factory ContactsState.noProject() => ContactsState(
    project: null,
    contacts: const <Contact>[],
    stages: const <ProjectStage>[],
    searchTerm: '',
    roleFilter: null,
    stageFilter: null,
  );

  final Project? project;
  final List<Contact> contacts;
  final List<ProjectStage> stages;
  final String searchTerm;
  final ContactRole? roleFilter;
  final String? stageFilter;
  final bool isSaving;

  ContactsState copyWith({bool? isSaving}) => ContactsState(
    project: project,
    contacts: contacts,
    stages: stages,
    searchTerm: searchTerm,
    roleFilter: roleFilter,
    stageFilter: stageFilter,
    isSaving: isSaving ?? this.isSaving,
  );
}

final class ContactsController extends AsyncNotifier<ContactsState> {
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<ContactsState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return ContactsState.noProject();
    return _load(project: project, searchTerm: '', role: null, stageId: null);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current?.project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<ContactsState>();
    state = await AsyncValue.guard(
      () => _load(
        project: current!.project!,
        searchTerm: current.searchTerm,
        role: current.roleFilter,
        stageId: current.stageFilter,
      ),
    );
  }

  Future<void> setSearchTerm(String value) {
    final current = state.requireValue;
    return _replaceFilter(
      searchTerm: value,
      role: current.roleFilter,
      stageId: current.stageFilter,
    );
  }

  Future<void> setRoleFilter(ContactRole? value) {
    final current = state.requireValue;
    return _replaceFilter(
      searchTerm: current.searchTerm,
      role: value,
      stageId: current.stageFilter,
    );
  }

  Future<void> setStageFilter(String? value) {
    final current = state.requireValue;
    return _replaceFilter(
      searchTerm: current.searchTerm,
      role: current.roleFilter,
      stageId: value,
    );
  }

  Future<void> saveContact(ContactDraft draft, {String? contactId}) {
    return _mutate((repository, projectId) {
      return contactId == null
          ? repository.create(projectId: projectId, draft: draft)
          : repository.update(
              projectId: projectId,
              contactId: contactId,
              draft: draft,
            );
    });
  }

  Future<void> setArchived(String contactId, {required bool isArchived}) {
    return _mutate(
      (repository, projectId) => repository.setArchived(
        projectId: projectId,
        contactId: contactId,
        isArchived: isArchived,
      ),
    );
  }

  Future<void> delete(String contactId) {
    return _mutate(
      (repository, projectId) =>
          repository.delete(projectId: projectId, contactId: contactId),
    );
  }

  Future<void> _replaceFilter({
    required String searchTerm,
    required ContactRole? role,
    required String? stageId,
  }) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null) return;
    state = const AsyncLoading<ContactsState>();
    state = await AsyncValue.guard(
      () => _load(
        project: project,
        searchTerm: searchTerm,
        role: role,
        stageId: stageId,
      ),
    );
  }

  Future<void> _mutate(
    Future<Object?> Function(ContactRepository repository, String projectId)
    action,
  ) {
    final mutation = _mutationQueue.then<void>((_) async {
      final current = state.requireValue;
      final project = current.project;
      if (project == null) return;
      state = AsyncData<ContactsState>(current.copyWith(isSaving: true));
      try {
        final repository = await ref.read(contactRepositoryProvider.future);
        await action(repository, project.id);
        state = AsyncData<ContactsState>(
          await _load(
            project: project,
            searchTerm: current.searchTerm,
            role: current.roleFilter,
            stageId: current.stageFilter,
          ),
        );
      } on Object catch (error, stackTrace) {
        state = AsyncData<ContactsState>(current);
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _mutationQueue = mutation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return mutation;
  }

  Future<ContactsState> _load({
    required Project project,
    required String searchTerm,
    required ContactRole? role,
    required String? stageId,
  }) async {
    final repository = await ref.read(contactRepositoryProvider.future);
    final stageRepository = await ref.read(stageRepositoryProvider.future);
    final page = await repository.list(
      ContactQuery(
        projectId: project.id,
        searchTerm: searchTerm,
        role: role,
        stageId: stageId,
      ),
      PageRequest(limit: PageRequest.maximumLimit),
    );
    return ContactsState(
      project: project,
      contacts: page.items,
      stages: await stageRepository.listStages(
        projectId: project.id,
        template: project.template,
      ),
      searchTerm: searchTerm.trim(),
      roleFilter: role,
      stageFilter: stageId,
    );
  }
}
