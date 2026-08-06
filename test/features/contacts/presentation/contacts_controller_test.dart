import 'dart:async';

import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/contacts/presentation/contacts_controller.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  test('loads selected project and applies role and stage filters', () async {
    final project = _project();
    final contacts = _ContactRepository();
    final container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith(
          (ref) async => FakeProjectRepository(
            projects: [project],
            selectedProjectId: project.id,
          ),
        ),
        contactRepositoryProvider.overrideWith((ref) async => contacts),
        stageRepositoryProvider.overrideWith((ref) async => _StageRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(contactsControllerProvider.future);
    await container
        .read(contactsControllerProvider.notifier)
        .setRoleFilter(ContactRole.electrician);
    await container
        .read(contactsControllerProvider.notifier)
        .setStageFilter('installations');

    final state = container.read(contactsControllerProvider).requireValue;
    expect(state.project, same(project));
    expect(state.roleFilter, ContactRole.electrician);
    expect(state.stageFilter, 'installations');
    expect(contacts.lastQuery?.role, ContactRole.electrician);
    expect(contacts.lastQuery?.stageId, 'installations');
  });

  test('does not query records when there is no selected project', () async {
    final contacts = _ContactRepository();
    final container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith(
          (ref) async => FakeProjectRepository(),
        ),
        contactRepositoryProvider.overrideWith((ref) async => contacts),
        stageRepositoryProvider.overrideWith((ref) async => _StageRepository()),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(contactsControllerProvider.future);

    expect(state.project, isNull);
    expect(contacts.loadCount, 0);
  });

  test('ignores a completed refresh after provider invalidation', () async {
    final project = _project();
    final contacts = _ContactRepository();
    final container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith(
          (ref) async => FakeProjectRepository(
            projects: [project],
            selectedProjectId: project.id,
          ),
        ),
        contactRepositoryProvider.overrideWith((ref) async => contacts),
        stageRepositoryProvider.overrideWith((ref) async => _StageRepository()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(contactsControllerProvider.future);
    final gate = Completer<void>();
    contacts.listGate = gate;

    final refresh = container
        .read(contactsControllerProvider.notifier)
        .refresh();
    await Future<void>.delayed(Duration.zero);
    container.invalidate(contactsControllerProvider);
    gate.complete();

    await expectLater(refresh, completes);
  });
}

final class _ContactRepository implements ContactRepository {
  int loadCount = 0;
  ContactQuery? lastQuery;
  Completer<void>? listGate;

  @override
  Future<Page<Contact>> list(ContactQuery query, PageRequest request) async {
    loadCount++;
    lastQuery = query;
    await listGate?.future;
    return Page<Contact>(items: const [], totalCount: 0, request: request);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _StageRepository implements StageRepository {
  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) async => const <ProjectStage>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Project _project() => Project(
  id: 'project-1',
  draft: ProjectDraft(
    name: 'Dom testowy',
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
