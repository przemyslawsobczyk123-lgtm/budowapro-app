import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/contacts/presentation/contacts_screen.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('shows contacts and keeps filters stable at 320 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _ContactRepository();

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Instal-Pro'), findsOneWidget);
    expect(find.textContaining('Elektryk'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('contactsSearchField')),
      'instal',
    );
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(repository.lastQuery?.searchTerm, 'instal');
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(ContactRepository repository) {
  final project = _project();
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const ContactsScreen()),
      GoRoute(
        path: '/projects/:projectId/contacts/new',
        builder: (_, _) => const Scaffold(body: Text('new-contact')),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId',
        builder: (_, state) => Scaffold(
          body: Text('contact:${state.pathParameters['contactId']}'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith(
        (ref) async => FakeProjectRepository(
          projects: [project],
          selectedProjectId: project.id,
        ),
      ),
      contactRepositoryProvider.overrideWith((ref) async => repository),
      stageRepositoryProvider.overrideWith((ref) async => _StageRepository()),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

final class _ContactRepository implements ContactRepository {
  ContactQuery? lastQuery;

  @override
  Future<Page<Contact>> list(ContactQuery query, PageRequest request) async {
    lastQuery = query;
    final contact = Contact(
      id: 'contact-1',
      projectId: 'project-1',
      draft: ContactDraft(
        displayName: 'Instal-Pro',
        kind: ContactKind.company,
        roles: const <ContactRole>{ContactRole.electrician},
        stageIds: const <String>{'installations'},
        phone: '+48 500 600 700',
      ),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    return Page<Contact>(items: [contact], totalCount: 1, request: request);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _StageRepository implements StageRepository {
  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) async => [
    ProjectStage(
      id: 'installations',
      projectId: projectId,
      templateKey: ProjectStageKey.installations,
      status: StageStatus.planned,
      sortOrder: 0,
      progress: StageProgress.fromCounts(
        totalItems: 0,
        completedItems: 0,
        skippedItems: 0,
        blockedItems: 0,
      ),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

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
