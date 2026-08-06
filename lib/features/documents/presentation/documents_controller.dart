import 'dart:io';

import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentsControllerProvider =
    AsyncNotifierProvider<DocumentsController, DocumentsState>(
      DocumentsController.new,
    );

final class DocumentLibraryFilters {
  const DocumentLibraryFilters({
    this.searchText = '',
    this.type,
    this.stageId,
    this.roomId,
    this.warrantyState,
    this.fromDate,
    this.toDateInclusive,
  });

  final String searchText;
  final ProjectDocumentType? type;
  final String? stageId;
  final String? roomId;
  final DocumentWarrantyState? warrantyState;
  final DateTime? fromDate;
  final DateTime? toDateInclusive;

  DocumentQuery query(String projectId) => DocumentQuery(
    projectId: projectId,
    searchText: searchText,
    types: type == null
        ? const <ProjectDocumentType>{}
        : <ProjectDocumentType>{type!},
    stageIds: stageId == null ? const <String>{} : <String>{stageId!},
    roomIds: roomId == null ? const <String>{} : <String>{roomId!},
    warrantyStates: warrantyState == null
        ? const <DocumentWarrantyState>{}
        : <DocumentWarrantyState>{warrantyState!},
    fromInclusive: fromDate,
    toExclusive: toDateInclusive == null
        ? null
        : DateTime(
            toDateInclusive!.year,
            toDateInclusive!.month,
            toDateInclusive!.day + 1,
          ),
  );

  int get activeFilterCount {
    var count = 0;
    if (type != null) count++;
    if (stageId != null) count++;
    if (roomId != null) count++;
    if (warrantyState != null) count++;
    if (fromDate != null || toDateInclusive != null) count++;
    return count;
  }

  bool get hasStructuredFilters => activeFilterCount > 0;
}

final class DocumentsState {
  DocumentsState({
    required this.project,
    required Iterable<ProjectDocument> documents,
    required this.totalCount,
    required this.nextPage,
    required this.filters,
    required this.filterOptions,
    Map<String, File> previewFiles = const <String, File>{},
    this.isLoadingMore = false,
    this.isImporting = false,
  }) : documents = List<ProjectDocument>.unmodifiable(documents),
       previewFiles = Map<String, File>.unmodifiable(previewFiles);

  factory DocumentsState.noProject() => DocumentsState(
    project: null,
    documents: const <ProjectDocument>[],
    totalCount: 0,
    nextPage: null,
    filters: const DocumentLibraryFilters(),
    filterOptions: DocumentFilterOptions(),
  );

  final Project? project;
  final List<ProjectDocument> documents;
  final int totalCount;
  final PageRequest? nextPage;
  final DocumentLibraryFilters filters;
  final DocumentFilterOptions filterOptions;
  final Map<String, File> previewFiles;
  final bool isLoadingMore;
  final bool isImporting;

  DocumentsState copyWith({
    Iterable<ProjectDocument>? documents,
    int? totalCount,
    PageRequest? nextPage,
    bool clearNextPage = false,
    bool? isLoadingMore,
    bool? isImporting,
    Map<String, File>? previewFiles,
  }) => DocumentsState(
    project: project,
    documents: documents ?? this.documents,
    totalCount: totalCount ?? this.totalCount,
    nextPage: clearNextPage ? null : nextPage ?? this.nextPage,
    filters: filters,
    filterOptions: filterOptions,
    previewFiles: previewFiles ?? this.previewFiles,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isImporting: isImporting ?? this.isImporting,
  );
}

final class DocumentsController extends AsyncNotifier<DocumentsState> {
  static const int pageSize = 30;

  @override
  Future<DocumentsState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return DocumentsState.noProject();
    return _load(project, const DocumentLibraryFilters());
  }

  Future<void> refresh() async {
    final current = state.value;
    final project = current?.project;
    if (project == null) {
      ref.invalidateSelf();
      return;
    }
    final refreshed = await AsyncValue.guard(
      () => _load(project, current!.filters),
    );
    if (!ref.mounted) return;
    state = refreshed;
  }

  Future<void> applyFilters(DocumentLibraryFilters filters) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null) return;
    state = const AsyncLoading<DocumentsState>();
    final filtered = await AsyncValue.guard(() => _load(project, filters));
    if (!ref.mounted) return;
    state = filtered;
  }

  Future<void> loadNext() async {
    final current = state.requireValue;
    final project = current.project;
    final request = current.nextPage;
    if (project == null || request == null || current.isLoadingMore) return;
    state = AsyncData<DocumentsState>(current.copyWith(isLoadingMore: true));
    try {
      final repository = await ref.read(documentRepositoryProvider.future);
      if (!ref.mounted) return;
      final page = await repository.list(
        current.filters.query(project.id),
        request,
      );
      if (!ref.mounted) return;
      final stager = await ref.read(localAttachmentStagerProvider.future);
      final newPreviews = await stager.previewFiles(
        projectId: project.id,
        attachmentIds: page.items.map((document) => document.id),
      );
      if (!ref.mounted) return;
      state = AsyncData<DocumentsState>(
        current.copyWith(
          documents: <ProjectDocument>[...current.documents, ...page.items],
          totalCount: page.totalCount,
          nextPage: page.nextRequest,
          clearNextPage: page.nextRequest == null,
          isLoadingMore: false,
          previewFiles: <String, File>{...current.previewFiles, ...newPreviews},
        ),
      );
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError<DocumentsState>(error, stackTrace);
    }
  }

  Future<StagedLocalAttachment?> pickAndStage() async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null || current.isImporting) return null;
    state = AsyncData<DocumentsState>(current.copyWith(isImporting: true));
    try {
      final selected = await ref.read(localAttachmentPickerProvider).pick();
      if (selected == null) return null;
      return await (await ref.read(
        localAttachmentStagerProvider.future,
      )).stage(projectId: project.id, pickedFile: selected);
    } finally {
      if (ref.mounted && state.hasValue) {
        state = AsyncData<DocumentsState>(
          state.requireValue.copyWith(isImporting: false),
        );
      }
    }
  }

  Future<List<ProjectDocument>> duplicatesOf(
    StagedLocalAttachment attachment,
  ) async {
    final hash = attachment.sha256;
    if (hash == null) return const <ProjectDocument>[];
    return (await ref.read(
      documentRepositoryProvider.future,
    )).findPotentialDuplicates(
      projectId: attachment.projectId,
      sha256: hash,
      excludingDocumentId: attachment.id,
    );
  }

  Future<void> discardDraft(StagedLocalAttachment attachment) async {
    await (await ref.read(
      localAttachmentStagerProvider.future,
    )).discard(projectId: attachment.projectId, attachmentId: attachment.id);
  }

  Future<DocumentsState> _load(
    Project project,
    DocumentLibraryFilters filters,
  ) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    final page = await repository.list(
      filters.query(project.id),
      PageRequest(limit: pageSize),
    );
    final previews =
        await (await ref.read(
          localAttachmentStagerProvider.future,
        )).previewFiles(
          projectId: project.id,
          attachmentIds: page.items.map((document) => document.id),
        );
    return DocumentsState(
      project: project,
      documents: page.items,
      totalCount: page.totalCount,
      nextPage: page.nextRequest,
      filters: filters,
      filterOptions: await repository.filterOptions(projectId: project.id),
      previewFiles: previews,
    );
  }
}
