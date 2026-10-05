import 'dart:async';
import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late AppDatabase database;
  late SqliteProjectRepository repository;
  late ProviderContainer container;
  var identifier = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_projects_controller_test_',
    );
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(temporaryDirectory.path, 'budowapro.db'),
    );
    repository = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(rootDirectory: temporaryDirectory),
      idGenerator: () => 'project-${++identifier}',
      utcNow: () => DateTime.utc(2026, 7, 15, 10),
    );
    container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('starts empty and selects a newly created project', () async {
    final initial = await container.read(projectsControllerProvider.future);

    expect(initial.projects, isEmpty);
    expect(initial.selectedProject, isNull);

    await container
        .read(projectsControllerProvider.notifier)
        .create(_houseDraft('Dom'));
    final state = container.read(projectsControllerProvider).requireValue;

    expect(state.projects, hasLength(1));
    expect(state.selectedProject?.name, 'Dom');
  });

  test(
    'switches, updates and deletes while keeping state consistent',
    () async {
      final controller = container.read(projectsControllerProvider.notifier);
      await container.read(projectsControllerProvider.future);
      await controller.create(_houseDraft('Dom'));
      final houseId = container
          .read(projectsControllerProvider)
          .requireValue
          .selectedProject!
          .id;
      await controller.create(_renovationDraft('Mieszkanie'));

      await controller.select(houseId);
      await controller.updateProject(
        houseId,
        ProjectDraft(
          name: 'Dom po zmianie',
          type: ProjectType.houseBuild,
          template: ProjectTemplate.houseConstruction,
          currentStage: ProjectStageKey.stateZero,
        ),
      );
      final updated = container.read(projectsControllerProvider).requireValue;
      expect(updated.selectedProject?.name, 'Dom po zmianie');

      final impact = await controller.deletionImpact(houseId);
      expect(impact.linkedFileCount, 0);
      await controller.delete(houseId);
      final afterDelete = container
          .read(projectsControllerProvider)
          .requireValue;

      expect(afterDelete.projects, hasLength(1));
      expect(afterDelete.selectedProject?.name, 'Mieszkanie');
    },
  );

  test('persists the current stage selected from the stage plan', () async {
    final controller = container.read(projectsControllerProvider.notifier);
    await container.read(projectsControllerProvider.future);
    await controller.create(_houseDraft('Dom'));
    final project = container
        .read(projectsControllerProvider)
        .requireValue
        .selectedProject!;

    await controller.setCurrentStage(project, ProjectStageKey.shellClosed);

    expect(
      container
          .read(projectsControllerProvider)
          .requireValue
          .selectedProject
          ?.currentStage,
      ProjectStageKey.shellClosed,
    );
  });

  test('keeps loaded projects visible when a mutation fails', () async {
    final house = _project('house', _houseDraft('Dom'), 1);
    final apartment = _project('apartment', _renovationDraft('Mieszkanie'), 2);
    final fakeRepository = FakeProjectRepository(
      projects: <Project>[house, apartment],
      selectedProjectId: house.id,
    );
    final fakeContainer = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith((ref) async => fakeRepository),
      ],
    );
    addTearDown(fakeContainer.dispose);
    await fakeContainer.read(projectsControllerProvider.future);
    fakeRepository.selectError = StateError('simulated selection failure');

    await expectLater(
      fakeContainer
          .read(projectsControllerProvider.notifier)
          .select(apartment.id),
      throwsStateError,
    );

    final asyncState = fakeContainer.read(projectsControllerProvider);
    expect(asyncState.hasError, isFalse);
    expect(asyncState.isLoading, isFalse);
    final state = asyncState.requireValue;
    expect(state.projects.map((project) => project.id), <String>[
      apartment.id,
      house.id,
    ]);
    expect(state.selectedProject?.id, house.id);
  });

  test('serializes rapid project mutations in call order', () async {
    final house = _project('house', _houseDraft('Dom'), 1);
    final apartment = _project('apartment', _renovationDraft('Mieszkanie'), 2);
    final fakeRepository = FakeProjectRepository(
      projects: <Project>[house, apartment],
      selectedProjectId: house.id,
    );
    final fakeContainer = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith((ref) async => fakeRepository),
      ],
    );
    addTearDown(fakeContainer.dispose);
    await fakeContainer.read(projectsControllerProvider.future);
    final firstMutationGate = Completer<void>();
    fakeRepository.selectGate = firstMutationGate;
    final controller = fakeContainer.read(projectsControllerProvider.notifier);

    final firstSelection = controller.select(apartment.id);
    final secondSelection = controller.select(house.id);
    await Future<void>.delayed(Duration.zero);

    expect(fakeRepository.selectCalls, <String>[apartment.id]);
    fakeRepository.selectGate = null;
    firstMutationGate.complete();
    await Future.wait(<Future<void>>[firstSelection, secondSelection]);

    expect(fakeRepository.selectCalls, <String>[apartment.id, house.id]);
    expect(
      fakeContainer
          .read(projectsControllerProvider)
          .requireValue
          .selectedProject
          ?.id,
      house.id,
    );
  });

  test('starts selected project read while the list is pending', () async {
    final house = _project('house', _houseDraft('Dom'), 1);
    final listGate = Completer<void>();
    final fakeRepository = FakeProjectRepository(
      projects: <Project>[house],
      selectedProjectId: house.id,
    )..listGate = listGate;
    final fakeContainer = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith((ref) async => fakeRepository),
      ],
    );
    addTearDown(() {
      if (!listGate.isCompleted) listGate.complete();
      fakeContainer.dispose();
    });

    final loading = fakeContainer.read(projectsControllerProvider.future);
    await _waitUntil(() => fakeRepository.listCallCount == 1);

    expect(fakeRepository.selectedCallCount, 1);

    listGate.complete();
    final state = await loading;
    expect(state.selectedProject?.id, house.id);
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 20 && !condition(); attempt++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(condition(), isTrue, reason: 'Asynchronous operation did not start');
}

Project _project(String id, ProjectDraft draft, int minute) {
  final timestamp = DateTime.utc(2026, 7, 15, 10, minute);
  return Project(
    id: id,
    draft: draft,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

ProjectDraft _houseDraft(String name) {
  return ProjectDraft(
    name: name,
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
  );
}

ProjectDraft _renovationDraft(String name) {
  return ProjectDraft(
    name: name,
    type: ProjectType.apartmentRenovation,
    template: ProjectTemplate.renovation,
  );
}
