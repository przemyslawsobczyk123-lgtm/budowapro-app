import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/quotes/data/quote_providers.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/quotes/domain/quote_repository.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quotesControllerProvider =
    AsyncNotifierProvider<QuotesController, QuotesState>(QuotesController.new);

final class QuotesState {
  QuotesState({
    required this.project,
    required Iterable<ContractorQuote> quotes,
    required Iterable<Contact> contacts,
    required Iterable<ProjectStage> stages,
    required this.searchTerm,
    required this.statusFilter,
    Iterable<String> selectedQuoteIds = const <String>[],
    this.isSaving = false,
  }) : quotes = List<ContractorQuote>.unmodifiable(quotes),
       contacts = List<Contact>.unmodifiable(contacts),
       stages = List<ProjectStage>.unmodifiable(stages),
       selectedQuoteIds = Set<String>.unmodifiable(selectedQuoteIds);

  factory QuotesState.noProject() => QuotesState(
    project: null,
    quotes: const <ContractorQuote>[],
    contacts: const <Contact>[],
    stages: const <ProjectStage>[],
    searchTerm: '',
    statusFilter: null,
  );

  final Project? project;
  final List<ContractorQuote> quotes;
  final List<Contact> contacts;
  final List<ProjectStage> stages;
  final String searchTerm;
  final ContractorQuoteStatus? statusFilter;
  final Set<String> selectedQuoteIds;
  final bool isSaving;

  Contact? contact(String id) {
    for (final contact in contacts) {
      if (contact.id == id) return contact;
    }
    return null;
  }

  QuotesState copyWith({Iterable<String>? selectedQuoteIds, bool? isSaving}) =>
      QuotesState(
        project: project,
        quotes: quotes,
        contacts: contacts,
        stages: stages,
        searchTerm: searchTerm,
        statusFilter: statusFilter,
        selectedQuoteIds: selectedQuoteIds ?? this.selectedQuoteIds,
        isSaving: isSaving ?? this.isSaving,
      );
}

final class QuotesController extends AsyncNotifier<QuotesState> {
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<QuotesState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return QuotesState.noProject();
    return _load(project: project, searchTerm: '', status: null);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current?.project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<QuotesState>();
    final refreshed = await AsyncValue.guard(
      () => _load(
        project: current!.project!,
        searchTerm: current.searchTerm,
        status: current.statusFilter,
      ),
    );
    if (!ref.mounted) return;
    state = refreshed;
  }

  Future<void> setFilters({
    required String searchTerm,
    required ContractorQuoteStatus? status,
  }) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null) return;
    state = const AsyncLoading<QuotesState>();
    final filtered = await AsyncValue.guard(
      () => _load(project: project, searchTerm: searchTerm, status: status),
    );
    if (!ref.mounted) return;
    state = filtered;
  }

  bool toggleComparison(String quoteId) {
    final current = state.requireValue;
    final selected = current.selectedQuoteIds.toSet();
    if (!selected.remove(quoteId)) {
      if (selected.length >= 4) return false;
      selected.add(quoteId);
    }
    state = AsyncData<QuotesState>(
      current.copyWith(selectedQuoteIds: selected),
    );
    return true;
  }

  Future<QuoteAcceptanceResult> accept(String quoteId, QuoteCostTarget target) {
    return _mutate<QuoteAcceptanceResult>(
      (repository, projectId) => repository.accept(
        projectId: projectId,
        quoteId: quoteId,
        target: target,
      ),
    );
  }

  Future<ContractorQuote> reject(String quoteId) {
    return _mutate<ContractorQuote>(
      (repository, projectId) =>
          repository.reject(projectId: projectId, quoteId: quoteId),
    );
  }

  Future<void> delete(String quoteId) {
    return _mutate<void>(
      (repository, projectId) =>
          repository.delete(projectId: projectId, quoteId: quoteId),
    );
  }

  Future<T> _mutate<T>(
    Future<T> Function(QuoteRepository repository, String projectId) action,
  ) {
    late T result;
    final mutation = _mutationQueue.then<void>((_) async {
      final current = state.requireValue;
      final project = current.project;
      if (project == null) throw StateError('No project selected');
      state = AsyncData<QuotesState>(current.copyWith(isSaving: true));
      try {
        final repository = await ref.read(quoteRepositoryProvider.future);
        result = await action(repository, project.id);
        if (!ref.mounted) return;
        final loaded = await _load(
          project: project,
          searchTerm: current.searchTerm,
          status: current.statusFilter,
        );
        if (!ref.mounted) return;
        state = AsyncData<QuotesState>(loaded);
      } on Object catch (error, stackTrace) {
        if (ref.mounted) {
          state = AsyncData<QuotesState>(current);
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _mutationQueue = mutation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return mutation.then((_) => result);
  }

  Future<QuotesState> _load({
    required Project project,
    required String searchTerm,
    required ContractorQuoteStatus? status,
  }) async {
    final quoteRepository = await ref.read(quoteRepositoryProvider.future);
    final contactRepository = await ref.read(contactRepositoryProvider.future);
    final stageRepository = await ref.read(stageRepositoryProvider.future);
    final quotes = <ContractorQuote>[];
    var request = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await quoteRepository.list(
        QuoteQuery(
          projectId: project.id,
          searchTerm: searchTerm,
          statuses: status == null
              ? const <ContractorQuoteStatus>{}
              : <ContractorQuoteStatus>{status},
        ),
        request,
      );
      quotes.addAll(page.items);
      final next = page.nextRequest;
      if (next == null) break;
      request = next;
    }
    final contacts = <Contact>[];
    request = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await contactRepository.list(
        ContactQuery(projectId: project.id, includeArchived: true),
        request,
      );
      contacts.addAll(page.items);
      final next = page.nextRequest;
      if (next == null) break;
      request = next;
    }
    return QuotesState(
      project: project,
      quotes: quotes,
      contacts: contacts,
      stages: await stageRepository.listStages(
        projectId: project.id,
        template: project.template,
      ),
      searchTerm: searchTerm.trim(),
      statusFilter: status,
    );
  }
}
