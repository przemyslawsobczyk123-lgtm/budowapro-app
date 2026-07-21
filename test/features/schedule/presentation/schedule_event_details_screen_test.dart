import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/contacts/domain/site_visit_repository.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_details_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_schedule_services.dart';

void main() {
  testWidgets('contact visit edits through the specialized visit route', (
    tester,
  ) async {
    final visit = _visit();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const ScheduleEventDetailsScreen(
            projectId: 'project-1',
            eventId: 'visit-1',
          ),
        ),
        GoRoute(
          path: '/projects/:projectId/schedule/:eventId/edit',
          builder: (_, _) => const Scaffold(body: Text('generic-editor')),
        ),
        GoRoute(
          path: '/projects/:projectId/contacts/:contactId/visits/:visitId/edit',
          builder: (_, _) => const Scaffold(body: Text('site-visit-editor')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleRepositoryProvider.overrideWith(
            (ref) async => _ScheduleRepository(visit.scheduleEvent),
          ),
          siteVisitRepositoryProvider.overrideWith(
            (ref) async => _SiteVisitRepository(visit),
          ),
          scheduleNotificationGatewayProvider.overrideWithValue(
            FakeScheduleNotificationGateway(
              permission: NotificationPermissionState.denied,
            ),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('site-visit-editor'), findsOneWidget);
    expect(find.text('generic-editor'), findsNothing);
  });
}

final class _ScheduleRepository implements ScheduleRepository {
  const _ScheduleRepository(this.event);

  final ScheduleEvent event;

  @override
  Future<ScheduleEvent?> findById({
    required String projectId,
    required String eventId,
  }) async => event;

  @override
  Future<List<ScheduleDependency>> listDependencies({
    required String projectId,
    required String eventId,
  }) async => const <ScheduleDependency>[];

  @override
  Future<List<ScheduleDateChange>> listDateChanges({
    required String projectId,
    required String eventId,
  }) async => const <ScheduleDateChange>[];

  @override
  Future<List<ScheduleEvent>> listOpen({required String projectId}) async => [
    event,
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _SiteVisitRepository implements SiteVisitRepository {
  const _SiteVisitRepository(this.visit);

  final SiteVisit visit;

  @override
  Future<SiteVisit?> findById({
    required String projectId,
    required String visitId,
  }) async => visit;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SiteVisit _visit() => SiteVisit(
  id: 'visit-1',
  projectId: 'project-1',
  draft: SiteVisitDraft(
    contactId: 'contact-1',
    purpose: 'Odbiór instalacji',
    expectedResult: 'Lista ustaleń',
    status: SiteVisitStatus.planned,
    startsAt: DateTime.utc(2026, 7, 24, 8),
    timeZoneId: 'Europe/Warsaw',
    isAllDay: false,
    reminderEnabled: true,
    reminderLeadMinutes: 60,
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
