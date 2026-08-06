import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/punch_list/data/punch_providers.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final punchControllerProvider =
    AsyncNotifierProvider<PunchController, PunchState>(PunchController.new);

final class PunchFilters {
  const PunchFilters({
    this.searchText = '',
    this.statuses = const <JournalEntryStatus>{},
    this.severities = const <DefectSeverity>{},
    this.stageId,
    this.responsibleContactId,
    this.roomLabel = '',
    this.overdueOnly = false,
  });

  final String searchText;
  final Set<JournalEntryStatus> statuses;
  final Set<DefectSeverity> severities;
  final String? stageId;
  final String? responsibleContactId;
  final String roomLabel;
  final bool overdueOnly;

  int get activeFilterCount {
    var count = statuses.length + severities.length;
    if (stageId != null) count++;
    if (responsibleContactId != null) count++;
    if (roomLabel.trim().isNotEmpty) count++;
    if (overdueOnly) count++;
    return count;
  }

  DefectQuery defectQuery(String projectId) => DefectQuery(
    projectId: projectId,
    searchText: searchText,
    statuses: statuses,
    severities: severities,
    stageId: stageId,
    responsibleContactId: responsibleContactId,
    roomLabel: roomLabel,
    overdueOnly: overdueOnly,
  );

  AcceptanceProtocolQuery protocolQuery(String projectId) =>
      AcceptanceProtocolQuery(projectId: projectId, searchText: searchText);

  PunchFilters copyWith({
    String? searchText,
    Set<JournalEntryStatus>? statuses,
    Set<DefectSeverity>? severities,
    String? stageId,
    bool clearStage = false,
    String? responsibleContactId,
    bool clearResponsibleContact = false,
    String? roomLabel,
    bool? overdueOnly,
  }) => PunchFilters(
    searchText: searchText ?? this.searchText,
    statuses: statuses ?? this.statuses,
    severities: severities ?? this.severities,
    stageId: clearStage ? null : stageId ?? this.stageId,
    responsibleContactId: clearResponsibleContact
        ? null
        : responsibleContactId ?? this.responsibleContactId,
    roomLabel: roomLabel ?? this.roomLabel,
    overdueOnly: overdueOnly ?? this.overdueOnly,
  );
}

final class PunchState {
  PunchState({
    required this.project,
    required Iterable<ProjectStage> stages,
    required Iterable<Contact> contacts,
    required Iterable<DefectRecord> defects,
    required Iterable<AcceptanceProtocol> protocols,
    required this.summary,
    required this.filters,
    required this.defectTotalCount,
    required this.protocolTotalCount,
    this.nextDefectPage,
    this.nextProtocolPage,
    this.isLoadingMoreDefects = false,
    this.isLoadingMoreProtocols = false,
  }) : stages = List<ProjectStage>.unmodifiable(stages),
       contacts = List<Contact>.unmodifiable(contacts),
       defects = List<DefectRecord>.unmodifiable(defects),
       protocols = List<AcceptanceProtocol>.unmodifiable(protocols);

  factory PunchState.noProject() => PunchState(
    project: null,
    stages: const <ProjectStage>[],
    contacts: const <Contact>[],
    defects: const <DefectRecord>[],
    protocols: const <AcceptanceProtocol>[],
    summary: PunchSummary(openCount: 0, criticalCount: 0, overdueCount: 0),
    filters: const PunchFilters(),
    defectTotalCount: 0,
    protocolTotalCount: 0,
  );

  final Project? project;
  final List<ProjectStage> stages;
  final List<Contact> contacts;
  final List<DefectRecord> defects;
  final List<AcceptanceProtocol> protocols;
  final PunchSummary summary;
  final PunchFilters filters;
  final int defectTotalCount;
  final int protocolTotalCount;
  final PageRequest? nextDefectPage;
  final PageRequest? nextProtocolPage;
  final bool isLoadingMoreDefects;
  final bool isLoadingMoreProtocols;

  PunchState copyWith({
    Iterable<DefectRecord>? defects,
    Iterable<AcceptanceProtocol>? protocols,
    PunchSummary? summary,
    PunchFilters? filters,
    int? defectTotalCount,
    int? protocolTotalCount,
    PageRequest? nextDefectPage,
    bool clearNextDefectPage = false,
    PageRequest? nextProtocolPage,
    bool clearNextProtocolPage = false,
    bool? isLoadingMoreDefects,
    bool? isLoadingMoreProtocols,
  }) => PunchState(
    project: project,
    stages: stages,
    contacts: contacts,
    defects: defects ?? this.defects,
    protocols: protocols ?? this.protocols,
    summary: summary ?? this.summary,
    filters: filters ?? this.filters,
    defectTotalCount: defectTotalCount ?? this.defectTotalCount,
    protocolTotalCount: protocolTotalCount ?? this.protocolTotalCount,
    nextDefectPage: clearNextDefectPage
        ? null
        : nextDefectPage ?? this.nextDefectPage,
    nextProtocolPage: clearNextProtocolPage
        ? null
        : nextProtocolPage ?? this.nextProtocolPage,
    isLoadingMoreDefects: isLoadingMoreDefects ?? this.isLoadingMoreDefects,
    isLoadingMoreProtocols:
        isLoadingMoreProtocols ?? this.isLoadingMoreProtocols,
  );
}

final class PunchController extends AsyncNotifier<PunchState> {
  static const int pageSize = 30;

  @override
  Future<PunchState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return PunchState.noProject();
    return _load(project, const PunchFilters());
  }

  Future<void> refresh() async {
    final current = state.value;
    final project = current?.project;
    if (project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<PunchState>();
    final refreshed = await AsyncValue.guard(
      () => _load(project, current!.filters),
    );
    if (!ref.mounted) return;
    state = refreshed;
  }

  Future<void> applyFilters(PunchFilters filters) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null) return;
    state = const AsyncLoading<PunchState>();
    final filtered = await AsyncValue.guard(() => _load(project, filters));
    if (!ref.mounted) return;
    state = filtered;
  }

  Future<DefectRecord> saveDefect(DefectInput input, {String? defectId}) async {
    final repository = await ref.read(punchRepositoryProvider.future);
    final saved = defectId == null
        ? await repository.createDefect(input)
        : await repository.updateDefect(
            projectId: input.projectId,
            defectId: defectId,
            input: input,
          );
    if (!ref.mounted) return saved;
    ref.invalidate(
      defectProvider((projectId: input.projectId, defectId: saved.id)),
    );
    await refresh();
    return saved;
  }

  Future<DefectRecord> setDefectStatus({
    required String projectId,
    required String defectId,
    required JournalEntryStatus status,
  }) async {
    final saved = await (await ref.read(punchRepositoryProvider.future))
        .setDefectStatus(
          projectId: projectId,
          defectId: defectId,
          status: status,
        );
    if (!ref.mounted) return saved;
    ref.invalidate(defectProvider((projectId: projectId, defectId: defectId)));
    await refresh();
    return saved;
  }

  Future<AcceptanceProtocol> saveProtocol(
    AcceptanceProtocolInput input, {
    String? protocolId,
  }) async {
    final repository = await ref.read(punchRepositoryProvider.future);
    final saved = protocolId == null
        ? await repository.createProtocol(input)
        : await repository.updateProtocol(
            projectId: input.projectId,
            protocolId: protocolId,
            input: input,
          );
    if (!ref.mounted) return saved;
    ref.invalidate(
      acceptanceProtocolProvider((
        projectId: input.projectId,
        protocolId: saved.id,
      )),
    );
    for (final defectId in saved.defectIds) {
      ref.invalidate(
        defectProvider((projectId: input.projectId, defectId: defectId)),
      );
    }
    await refresh();
    return saved;
  }

  Future<void> loadMoreDefects() async {
    final current = state.requireValue;
    final project = current.project;
    final request = current.nextDefectPage;
    if (project == null || request == null || current.isLoadingMoreDefects) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMoreDefects: true));
    try {
      final page = await (await ref.read(
        punchRepositoryProvider.future,
      )).listDefects(current.filters.defectQuery(project.id), request);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          defects: <DefectRecord>[...current.defects, ...page.items],
          defectTotalCount: page.totalCount,
          nextDefectPage: page.nextRequest,
          clearNextDefectPage: page.nextRequest == null,
          isLoadingMoreDefects: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> loadMoreProtocols() async {
    final current = state.requireValue;
    final project = current.project;
    final request = current.nextProtocolPage;
    if (project == null || request == null || current.isLoadingMoreProtocols) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMoreProtocols: true));
    try {
      final page = await (await ref.read(
        punchRepositoryProvider.future,
      )).listProtocols(current.filters.protocolQuery(project.id), request);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          protocols: <AcceptanceProtocol>[...current.protocols, ...page.items],
          protocolTotalCount: page.totalCount,
          nextProtocolPage: page.nextRequest,
          clearNextProtocolPage: page.nextRequest == null,
          isLoadingMoreProtocols: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<PunchState> _load(Project project, PunchFilters filters) async {
    final repository = await ref.read(punchRepositoryProvider.future);
    final defects = await repository.listDefects(
      filters.defectQuery(project.id),
      PageRequest(limit: pageSize),
    );
    final protocols = await repository.listProtocols(
      filters.protocolQuery(project.id),
      PageRequest(limit: pageSize),
    );
    return PunchState(
      project: project,
      stages: await (await ref.read(
        stageRepositoryProvider.future,
      )).listStages(projectId: project.id, template: project.template),
      contacts: await _contacts(project.id),
      defects: defects.items,
      protocols: protocols.items,
      summary: await repository.summarizeDefects(
        projectId: project.id,
        now: DateTime.now(),
      ),
      filters: filters,
      defectTotalCount: defects.totalCount,
      protocolTotalCount: protocols.totalCount,
      nextDefectPage: defects.nextRequest,
      nextProtocolPage: protocols.nextRequest,
    );
  }

  Future<List<Contact>> _contacts(String projectId) async {
    final repository = await ref.read(contactRepositoryProvider.future);
    final contacts = <Contact>[];
    var request = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await repository.list(
        ContactQuery(projectId: projectId),
        request,
      );
      contacts.addAll(page.items.where((contact) => !contact.isArchived));
      final next = page.nextRequest;
      if (next == null) return contacts;
      request = next;
    }
  }
}
