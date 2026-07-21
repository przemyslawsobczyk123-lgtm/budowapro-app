import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/contacts/data/contact_action_gateway.dart';
import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/contacts/domain/site_visit_repository.dart';
import 'package:budowapro/features/contacts/presentation/contact_details_screen.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets(
    'launches phone only after confirmation and shows no-show history',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final actions = _ContactActions();

      await tester.pumpWidget(_testApp(actions));
      await tester.pumpAndSettle();

      expect(find.text('Instal-Pro'), findsOneWidget);
      expect(find.textContaining('Wykonawca nie przyjechał'), findsOneWidget);
      expect(actions.callCount, 0);

      await tester.tap(find.byKey(const ValueKey('contactCallButton')));
      await tester.pumpAndSettle();
      expect(actions.callCount, 0);
      expect(find.text('Zadzwonić do kontaktu?'), findsOneWidget);

      await tester.tap(find.text('Otwórz telefon'));
      await tester.pumpAndSettle();
      expect(actions.callCount, 1);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _testApp(ContactActionGateway actions) {
  final project = _project();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const ContactDetailsScreen(
          projectId: 'project-1',
          contactId: 'contact-1',
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId/edit',
        builder: (_, _) => const Scaffold(body: Text('edit-contact')),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId/visits/new',
        builder: (_, _) => const Scaffold(body: Text('new-visit')),
      ),
      GoRoute(
        path: '/projects/:projectId/contacts/:contactId/visits/:visitId/edit',
        builder: (_, _) => const Scaffold(body: Text('edit-visit')),
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
      contactRepositoryProvider.overrideWith(
        (ref) async => _ContactRepository(),
      ),
      siteVisitRepositoryProvider.overrideWith(
        (ref) async => _VisitRepository(),
      ),
      contactActionGatewayProvider.overrideWithValue(actions),
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

final class _ContactActions implements ContactActionGateway {
  int callCount = 0;

  @override
  Future<void> call(String phone) async => callCount++;

  @override
  Future<void> email(String address) async {}
}

final class _ContactRepository implements ContactRepository {
  @override
  Future<Contact?> findById({
    required String projectId,
    required String contactId,
  }) async => _contact();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _VisitRepository implements SiteVisitRepository {
  @override
  Future<List<SiteVisit>> listForContact({
    required String projectId,
    required String contactId,
  }) async => [
    SiteVisit(
      id: 'visit-1',
      projectId: projectId,
      draft: SiteVisitDraft(
        contactId: contactId,
        purpose: 'Odbiór instalacji',
        expectedResult: 'Lista ustaleń',
        status: SiteVisitStatus.noShow,
        startsAt: DateTime.utc(2026, 7, 20, 8),
        timeZoneId: 'Europe/Warsaw',
        isAllDay: false,
        reminderEnabled: false,
        reminderLeadMinutes: 60,
      ),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

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

Contact _contact() => Contact(
  id: 'contact-1',
  projectId: 'project-1',
  draft: ContactDraft(
    displayName: 'Instal-Pro',
    kind: ContactKind.company,
    roles: const <ContactRole>{ContactRole.electrician},
    phone: '+48 500 600 700',
    email: 'biuro@instal-pro.pl',
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

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
