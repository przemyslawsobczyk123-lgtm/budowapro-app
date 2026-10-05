import 'dart:async';

import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/features/technical_photos/data/technical_photo_providers.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo_repository.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photos_controller.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  test(
    'starts album and stage reads while the first photo page is pending',
    () async {
      final project = _project();
      final photos = _ConcurrentTechnicalPhotoRepository();
      final stages = _ConcurrentStageRepository();
      final projects = FakeProjectRepository(
        projects: <Project>[project],
        selectedProjectId: project.id,
      );
      final container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWith((ref) async => projects),
          technicalPhotoRepositoryProvider.overrideWith((ref) async => photos),
          stageRepositoryProvider.overrideWith((ref) async => stages),
        ],
      );
      addTearDown(container.dispose);

      final loading = container.read(technicalPhotosControllerProvider.future);
      loading.ignore();
      try {
        await _waitUntil(() => photos.listPhotosStarted);

        expect(photos.listAlbumsStarted, isTrue);
        expect(stages.listStagesStarted, isTrue);
      } finally {
        if (!photos.photosCompleter.isCompleted) {
          photos.photosCompleter.completeError(const _StopLoading());
        }
        if (!photos.albumsCompleter.isCompleted) {
          photos.albumsCompleter.complete(const <TechnicalAlbumOverview>[]);
        }
        if (!stages.stagesCompleter.isCompleted) {
          stages.stagesCompleter.complete(const <ProjectStage>[]);
        }
      }
    },
  );

  test(
    'starts preview loading after the photo page while metadata is pending',
    () async {
      final project = _project();
      final photos = _ConcurrentTechnicalPhotoRepository();
      final stages = _ConcurrentStageRepository();
      final projects = FakeProjectRepository(
        projects: <Project>[project],
        selectedProjectId: project.id,
      );
      var previewLoadingStarted = false;
      final container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWith((ref) async => projects),
          technicalPhotoRepositoryProvider.overrideWith((ref) async => photos),
          stageRepositoryProvider.overrideWith((ref) async => stages),
          localAttachmentStagerProvider.overrideWith((ref) async {
            previewLoadingStarted = true;
            throw const _StopLoading();
          }),
        ],
      );
      addTearDown(container.dispose);

      final loading = container.read(technicalPhotosControllerProvider.future);
      loading.ignore();
      try {
        await _waitUntil(() => photos.listPhotosStarted);
        photos.photosCompleter.complete(_emptyPage());

        await _waitUntil(() => previewLoadingStarted);

        expect(photos.albumsCompleter.isCompleted, isFalse);
        expect(stages.stagesCompleter.isCompleted, isFalse);
      } finally {
        if (!photos.photosCompleter.isCompleted) {
          photos.photosCompleter.complete(_emptyPage());
        }
        if (!photos.albumsCompleter.isCompleted) {
          photos.albumsCompleter.complete(const <TechnicalAlbumOverview>[]);
        }
        if (!stages.stagesCompleter.isCompleted) {
          stages.stagesCompleter.complete(const <ProjectStage>[]);
        }
      }
    },
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 20 && !condition(); attempt++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(condition(), isTrue, reason: 'Asynchronous operation did not start');
}

Project _project() {
  final now = DateTime.utc(2026, 8, 11, 12);
  return Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currencyCode: 'PLN',
    ),
    createdAt: now,
    updatedAt: now,
  );
}

Page<TechnicalPhoto> _emptyPage() {
  return Page<TechnicalPhoto>(
    items: const <TechnicalPhoto>[],
    totalCount: 0,
    request: PageRequest(limit: TechnicalPhotosController.pageSize),
  );
}

final class _ConcurrentTechnicalPhotoRepository
    implements TechnicalPhotoRepository {
  final photosCompleter = Completer<Page<TechnicalPhoto>>();
  final albumsCompleter = Completer<List<TechnicalAlbumOverview>>();
  bool listPhotosStarted = false;
  bool listAlbumsStarted = false;

  @override
  Future<Page<TechnicalPhoto>> listPhotos(
    TechnicalPhotoQuery query,
    PageRequest page,
  ) {
    listPhotosStarted = true;
    return photosCompleter.future;
  }

  @override
  Future<List<TechnicalAlbumOverview>> listAlbums({required String projectId}) {
    listAlbumsStarted = true;
    return albumsCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ConcurrentStageRepository implements StageRepository {
  final stagesCompleter = Completer<List<ProjectStage>>();
  bool listStagesStarted = false;

  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) {
    listStagesStarted = true;
    return stagesCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _StopLoading implements Exception {
  const _StopLoading();
}
