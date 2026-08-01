import 'dart:io';

import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/technical_photos/data/technical_photo_providers.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final technicalPhotosControllerProvider =
    AsyncNotifierProvider<TechnicalPhotosController, TechnicalPhotosState>(
      TechnicalPhotosController.new,
    );

final technicalPhotoProvider = FutureProvider.autoDispose
    .family<TechnicalPhoto?, ({String projectId, String attachmentId})>((
      ref,
      target,
    ) async {
      final repository = await ref.watch(
        technicalPhotoRepositoryProvider.future,
      );
      return repository.findPhotoById(
        projectId: target.projectId,
        attachmentId: target.attachmentId,
      );
    });

final class TechnicalPhotoFilters {
  const TechnicalPhotoFilters({
    this.searchText = '',
    this.albumId,
    this.stageId,
    this.installationType,
    this.tag,
  });

  final String searchText;
  final String? albumId;
  final String? stageId;
  final TechnicalInstallationType? installationType;
  final String? tag;

  TechnicalPhotoQuery query(String projectId) => TechnicalPhotoQuery(
    projectId: projectId,
    searchText: searchText,
    albumIds: albumId == null ? const <String>{} : <String>{albumId!},
    stageIds: stageId == null ? const <String>{} : <String>{stageId!},
    installationTypes: installationType == null
        ? const <TechnicalInstallationType>{}
        : <TechnicalInstallationType>{installationType!},
    tags: tag == null ? const <String>{} : <String>{tag!},
  );

  int get activeFilterCount {
    var count = 0;
    if (albumId != null) count++;
    if (stageId != null) count++;
    if (installationType != null) count++;
    if (tag != null) count++;
    return count;
  }

  TechnicalPhotoFilters copyWith({
    String? searchText,
    String? albumId,
    bool clearAlbum = false,
    String? stageId,
    bool clearStage = false,
    TechnicalInstallationType? installationType,
    bool clearInstallationType = false,
    String? tag,
    bool clearTag = false,
  }) => TechnicalPhotoFilters(
    searchText: searchText ?? this.searchText,
    albumId: clearAlbum ? null : albumId ?? this.albumId,
    stageId: clearStage ? null : stageId ?? this.stageId,
    installationType: clearInstallationType
        ? null
        : installationType ?? this.installationType,
    tag: clearTag ? null : tag ?? this.tag,
  );
}

final class TechnicalPhotosState {
  TechnicalPhotosState({
    required this.project,
    required Iterable<TechnicalAlbumOverview> albums,
    required Iterable<TechnicalPhoto> photos,
    required Iterable<ProjectStage> stages,
    required this.totalCount,
    required this.nextPage,
    required this.filters,
    Map<String, File> previewFiles = const <String, File>{},
    this.isLoadingMore = false,
    this.isImporting = false,
  }) : albums = List<TechnicalAlbumOverview>.unmodifiable(albums),
       photos = List<TechnicalPhoto>.unmodifiable(photos),
       stages = List<ProjectStage>.unmodifiable(stages),
       previewFiles = Map<String, File>.unmodifiable(previewFiles);

  factory TechnicalPhotosState.noProject() => TechnicalPhotosState(
    project: null,
    albums: const <TechnicalAlbumOverview>[],
    photos: const <TechnicalPhoto>[],
    stages: const <ProjectStage>[],
    totalCount: 0,
    nextPage: null,
    filters: const TechnicalPhotoFilters(),
  );

  final Project? project;
  final List<TechnicalAlbumOverview> albums;
  final List<TechnicalPhoto> photos;
  final List<ProjectStage> stages;
  final int totalCount;
  final PageRequest? nextPage;
  final TechnicalPhotoFilters filters;
  final Map<String, File> previewFiles;
  final bool isLoadingMore;
  final bool isImporting;

  Set<String> get availableTags => photos.expand((photo) => photo.tags).toSet();

  TechnicalPhotosState copyWith({
    Iterable<TechnicalAlbumOverview>? albums,
    Iterable<TechnicalPhoto>? photos,
    Iterable<ProjectStage>? stages,
    int? totalCount,
    PageRequest? nextPage,
    bool clearNextPage = false,
    TechnicalPhotoFilters? filters,
    Map<String, File>? previewFiles,
    bool? isLoadingMore,
    bool? isImporting,
  }) => TechnicalPhotosState(
    project: project,
    albums: albums ?? this.albums,
    photos: photos ?? this.photos,
    stages: stages ?? this.stages,
    totalCount: totalCount ?? this.totalCount,
    nextPage: clearNextPage ? null : nextPage ?? this.nextPage,
    filters: filters ?? this.filters,
    previewFiles: previewFiles ?? this.previewFiles,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isImporting: isImporting ?? this.isImporting,
  );
}

final class UnsupportedTechnicalPhotoException implements Exception {
  const UnsupportedTechnicalPhotoException();
}

final class TechnicalPhotosController
    extends AsyncNotifier<TechnicalPhotosState> {
  static const int pageSize = 30;

  @override
  Future<TechnicalPhotosState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return TechnicalPhotosState.noProject();
    return _load(project, const TechnicalPhotoFilters());
  }

  Future<void> refresh() async {
    final current = state.value;
    final project = current?.project;
    if (project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<TechnicalPhotosState>();
    state = await AsyncValue.guard(() => _load(project, current!.filters));
  }

  Future<void> applyFilters(TechnicalPhotoFilters filters) async {
    final project = state.requireValue.project;
    if (project == null) return;
    state = const AsyncLoading<TechnicalPhotosState>();
    state = await AsyncValue.guard(() => _load(project, filters));
  }

  Future<void> loadNext() async {
    final current = state.requireValue;
    final project = current.project;
    final request = current.nextPage;
    if (project == null || request == null || current.isLoadingMore) return;
    state = AsyncData<TechnicalPhotosState>(
      current.copyWith(isLoadingMore: true),
    );
    try {
      final repository = await ref.read(
        technicalPhotoRepositoryProvider.future,
      );
      final page = await repository.listPhotos(
        current.filters.query(project.id),
        request,
      );
      final previews = await _previews(project.id, page.items);
      state = AsyncData<TechnicalPhotosState>(
        current.copyWith(
          photos: <TechnicalPhoto>[...current.photos, ...page.items],
          totalCount: page.totalCount,
          nextPage: page.nextRequest,
          clearNextPage: page.nextRequest == null,
          previewFiles: <String, File>{...current.previewFiles, ...previews},
          isLoadingMore: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError<TechnicalPhotosState>(error, stackTrace);
    }
  }

  Future<TechnicalAlbum?> createAlbum(TechnicalAlbumInput input) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null || input.projectId != project.id) return null;
    final album = await (await ref.read(
      technicalPhotoRepositoryProvider.future,
    )).createAlbum(input);
    await refresh();
    return album;
  }

  Future<StagedLocalAttachment?> pickAndStageImage() async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null || current.isImporting) return null;
    state = AsyncData<TechnicalPhotosState>(
      current.copyWith(isImporting: true),
    );
    StagedLocalAttachment? attachment;
    try {
      final selected = await ref.read(localAttachmentPickerProvider).pick();
      if (selected == null) return null;
      final stager = await ref.read(localAttachmentStagerProvider.future);
      attachment = await stager.stage(
        projectId: project.id,
        pickedFile: selected,
      );
      if (!(attachment.mediaType?.startsWith('image/') ?? false)) {
        await stager.discard(
          projectId: project.id,
          attachmentId: attachment.id,
        );
        throw const UnsupportedTechnicalPhotoException();
      }
      return attachment;
    } finally {
      if (state.hasValue) {
        state = AsyncData<TechnicalPhotosState>(
          state.requireValue.copyWith(isImporting: false),
        );
      }
    }
  }

  Future<void> discardDraft(StagedLocalAttachment attachment) async {
    await (await ref.read(
      localAttachmentStagerProvider.future,
    )).discard(projectId: attachment.projectId, attachmentId: attachment.id);
  }

  Future<TechnicalPhotosState> _load(
    Project project,
    TechnicalPhotoFilters filters,
  ) async {
    final repository = await ref.read(technicalPhotoRepositoryProvider.future);
    final page = await repository.listPhotos(
      filters.query(project.id),
      PageRequest(limit: pageSize),
    );
    return TechnicalPhotosState(
      project: project,
      albums: await repository.listAlbums(projectId: project.id),
      photos: page.items,
      stages: await (await ref.read(
        stageRepositoryProvider.future,
      )).listStages(projectId: project.id, template: project.template),
      totalCount: page.totalCount,
      nextPage: page.nextRequest,
      filters: filters,
      previewFiles: await _previews(project.id, page.items),
    );
  }

  Future<Map<String, File>> _previews(
    String projectId,
    Iterable<TechnicalPhoto> photos,
  ) async {
    return (await ref.read(localAttachmentStagerProvider.future)).previewFiles(
      projectId: projectId,
      attachmentIds: photos.map((photo) => photo.attachmentId),
    );
  }
}
