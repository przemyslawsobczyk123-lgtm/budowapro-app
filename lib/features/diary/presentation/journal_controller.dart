import 'package:budowapro/features/diary/data/journal_providers.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/punch_list/data/punch_providers.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/presentation/punch_controller.dart';
import 'package:budowapro/features/reports/data/report_providers.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final journalControllerProvider =
    AsyncNotifierProvider<JournalController, JournalState>(
      JournalController.new,
    );

final journalEntryProvider = FutureProvider.autoDispose
    .family<JournalEntry?, ({String projectId, String entryId})>((
      ref,
      target,
    ) async {
      final repository = await ref.watch(journalRepositoryProvider.future);
      return repository.findById(
        projectId: target.projectId,
        entryId: target.entryId,
      );
    });

final journalRevisionsProvider = FutureProvider.autoDispose
    .family<List<JournalEntryRevision>, ({String projectId, String entryId})>((
      ref,
      target,
    ) async {
      final repository = await ref.watch(journalRepositoryProvider.future);
      return repository.revisions(
        projectId: target.projectId,
        entryId: target.entryId,
      );
    });

final class JournalState {
  JournalState({
    required this.project,
    required Iterable<JournalEntry> entries,
    required this.typeFilter,
    required this.searchTerm,
    required this.nextPage,
    required this.totalCount,
    this.isMutating = false,
    this.isLoadingMore = false,
  }) : entries = List<JournalEntry>.unmodifiable(entries);

  factory JournalState.noProject() => JournalState(
    project: null,
    entries: const <JournalEntry>[],
    typeFilter: null,
    searchTerm: '',
    nextPage: null,
    totalCount: 0,
  );

  final Project? project;
  final List<JournalEntry> entries;
  final JournalEntryType? typeFilter;
  final String searchTerm;
  final PageRequest? nextPage;
  final int totalCount;
  final bool isMutating;
  final bool isLoadingMore;

  JournalState copyWith({
    Iterable<JournalEntry>? entries,
    PageRequest? nextPage,
    bool clearNextPage = false,
    bool? isMutating,
    bool? isLoadingMore,
  }) => JournalState(
    project: project,
    entries: entries ?? this.entries,
    typeFilter: typeFilter,
    searchTerm: searchTerm,
    nextPage: clearNextPage ? null : nextPage ?? this.nextPage,
    totalCount: totalCount,
    isMutating: isMutating ?? this.isMutating,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

final class JournalController extends AsyncNotifier<JournalState> {
  static const int pageSize = PageRequest.maximumLimit;
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<JournalState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return JournalState.noProject();
    return _load(project: project, type: null, searchTerm: '');
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current?.project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<JournalState>();
    state = await AsyncValue.guard(
      () => _load(
        project: current!.project!,
        type: current.typeFilter,
        searchTerm: current.searchTerm,
      ),
    );
  }

  Future<void> setTypeFilter(JournalEntryType? type) async {
    final current = state.requireValue;
    if (current.project == null) return;
    state = const AsyncLoading<JournalState>();
    state = await AsyncValue.guard(
      () => _load(
        project: current.project!,
        type: type,
        searchTerm: current.searchTerm,
      ),
    );
  }

  Future<void> setSearchTerm(String searchTerm) async {
    final current = state.requireValue;
    if (current.project == null) return;
    state = const AsyncLoading<JournalState>();
    state = await AsyncValue.guard(
      () => _load(
        project: current.project!,
        type: current.typeFilter,
        searchTerm: searchTerm,
      ),
    );
  }

  Future<void> loadNext() async {
    final current = state.requireValue;
    final project = current.project;
    final request = current.nextPage;
    if (project == null || request == null || current.isLoadingMore) return;
    state = AsyncData<JournalState>(current.copyWith(isLoadingMore: true));
    try {
      final repository = await ref.read(journalRepositoryProvider.future);
      final page = await repository.list(
        JournalEntryQuery(
          projectId: project.id,
          types: current.typeFilter == null
              ? const <JournalEntryType>[]
              : <JournalEntryType>[current.typeFilter!],
          searchTerm: current.searchTerm,
        ),
        request,
      );
      state = AsyncData<JournalState>(
        current.copyWith(
          entries: <JournalEntry>[...current.entries, ...page.items],
          nextPage: page.nextRequest,
          clearNextPage: page.nextRequest == null,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError<JournalState>(error, stackTrace);
    }
  }

  Future<JournalEntry?> save(JournalEntryInput input, {String? entryId}) {
    return _mutate<JournalEntry?>(() async {
      final project = state.requireValue.project;
      if (project == null || project.id != input.projectId) return null;
      final JournalEntry result;
      if (input.type == JournalEntryType.defect) {
        final repository = await ref.read(punchRepositoryProvider.future);
        final existing = entryId == null
            ? null
            : await repository.findDefectById(
                projectId: project.id,
                defectId: entryId,
              );
        final defectInput = DefectInput(
          projectId: input.projectId,
          title: input.title,
          occurredAt: input.occurredAt,
          severity:
              input.defectSeverity ??
              existing?.severity ??
              DefectSeverity.medium,
          status: input.status,
          description: input.body,
          stageId: input.stageId,
          roomLabel: input.roomLabel ?? existing?.roomLabel,
          responsibleContactId: input.responsibleContactId,
          dueAt: input.dueAt,
          requiresResolutionPhoto: input.requiresResolutionPhoto,
          requiresSignedProtocol: input.requiresSignedProtocol,
          attachmentIds: input.attachmentIds,
          resolutionAttachmentIds:
              existing?.resolutionAttachmentIds ?? const <String>[],
        );
        final saved = entryId == null
            ? await repository.createDefect(defectInput)
            : await repository.updateDefect(
                projectId: project.id,
                defectId: entryId,
                input: defectInput,
              );
        result = saved.entry;
        ref.invalidate(
          defectProvider((projectId: project.id, defectId: result.id)),
        );
        ref.invalidate(punchControllerProvider);
      } else {
        final repository = await ref.read(journalRepositoryProvider.future);
        result = entryId == null
            ? await repository.create(input)
            : await repository.update(
                projectId: project.id,
                entryId: entryId,
                input: input,
              );
      }
      ref.invalidate(
        journalEntryProvider((projectId: project.id, entryId: result.id)),
      );
      ref.invalidate(
        journalRevisionsProvider((projectId: project.id, entryId: result.id)),
      );
      ref.invalidate(budgetReportProvider(project.id));
      return result;
    });
  }

  Future<JournalEntry?> setStatus(String entryId, JournalEntryStatus status) {
    return _mutate<JournalEntry?>(() async {
      final project = state.requireValue.project;
      if (project == null) return null;
      final journalRepository = await ref.read(
        journalRepositoryProvider.future,
      );
      final current = await journalRepository.findById(
        projectId: project.id,
        entryId: entryId,
      );
      if (current == null) return null;
      final JournalEntry result;
      if (current.type == JournalEntryType.defect) {
        final saved = await (await ref.read(punchRepositoryProvider.future))
            .setDefectStatus(
              projectId: project.id,
              defectId: entryId,
              status: status,
            );
        result = saved.entry;
        ref.invalidate(
          defectProvider((projectId: project.id, defectId: entryId)),
        );
        ref.invalidate(punchControllerProvider);
      } else {
        result = await journalRepository.setStatus(
          projectId: project.id,
          entryId: entryId,
          status: status,
        );
      }
      ref.invalidate(
        journalEntryProvider((projectId: project.id, entryId: entryId)),
      );
      ref.invalidate(
        journalRevisionsProvider((projectId: project.id, entryId: entryId)),
      );
      ref.invalidate(budgetReportProvider(project.id));
      return result;
    });
  }

  Future<JournalEntry?> approveDecision(
    String entryId,
    String approvedByContactId,
  ) {
    return _mutate<JournalEntry?>(() async {
      final project = state.requireValue.project;
      if (project == null) return null;
      final result = await (await ref.read(journalRepositoryProvider.future))
          .approveDecision(
            projectId: project.id,
            entryId: entryId,
            approvedByContactId: approvedByContactId,
          );
      ref.invalidate(
        journalEntryProvider((projectId: project.id, entryId: entryId)),
      );
      ref.invalidate(
        journalRevisionsProvider((projectId: project.id, entryId: entryId)),
      );
      ref.invalidate(budgetReportProvider(project.id));
      return result;
    });
  }

  Future<T> _mutate<T>(Future<T> Function() action) {
    late T result;
    final mutation = _mutationQueue.then<void>((_) async {
      final current = state.requireValue;
      state = AsyncData<JournalState>(current.copyWith(isMutating: true));
      try {
        result = await action();
        final project = current.project;
        state = AsyncData<JournalState>(
          project == null
              ? JournalState.noProject()
              : await _load(
                  project: project,
                  type: current.typeFilter,
                  searchTerm: current.searchTerm,
                ),
        );
      } on Object catch (error, stackTrace) {
        state = AsyncData<JournalState>(current);
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _mutationQueue = mutation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return mutation.then<T>((_) => result);
  }

  Future<JournalState> _load({
    required Project project,
    required JournalEntryType? type,
    required String searchTerm,
  }) async {
    final repository = await ref.read(journalRepositoryProvider.future);
    final page = await repository.list(
      JournalEntryQuery(
        projectId: project.id,
        types: type == null
            ? const <JournalEntryType>[]
            : <JournalEntryType>[type],
        searchTerm: searchTerm,
      ),
      PageRequest(limit: pageSize),
    );
    return JournalState(
      project: project,
      entries: page.items,
      typeFilter: type,
      searchTerm: searchTerm.trim(),
      nextPage: page.nextRequest,
      totalCount: page.totalCount,
    );
  }
}
