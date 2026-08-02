import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/fake_project_repository.dart';
import 'helpers/fake_schedule_services.dart';

void main() {
  testWidgets('shows five primary destinations and changes branch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Budżet'), findsOneWidget);
    expect(find.text('Etapy'), findsOneWidget);
    expect(find.text('Więcej'), findsOneWidget);
    expect(find.text('Brak aktywnego projektu'), findsOneWidget);

    const destinations = <String, String>{
      'Plan': 'Plan budowy',
      'Budżet': 'Budżet inwestycji',
      'Więcej': 'Narzędzia projektu',
      'Start': 'Brak aktywnego projektu',
    };

    for (final entry in destinations.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    }

    await tester.tap(find.text('Etapy'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('stage-plan-screen')), findsOneWidget);
    expect(find.text('Dokumenty'), findsNothing);
  });

  testWidgets('fits navigation on a compact Android viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('opens contacts from the More tools branch', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('moreContactsTile')));
    await tester.pumpAndSettle();

    expect(find.text('Ekipy i kontakty'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
  });

  testWidgets('opens construction documents from the More tools branch', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('moreDocumentsTile')));
    await tester.tap(find.byKey(const ValueKey('moreDocumentsTile')));
    await tester.pumpAndSettle();

    expect(find.text('Dokumenty'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('keeps the legacy build route pointing to documents', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(NavigationBar))).go('/build');
    await tester.pumpAndSettle();

    expect(find.text('Dokumenty'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
  });

  testWidgets('opens the capture inbox from the More tools branch', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('moreCapturesTile')));
    await tester.pumpAndSettle();

    expect(find.text('Skrzynka szybkich zapisów'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens privacy policy from the More tools branch', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('moreLegalTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('moreLegalTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('privacyPolicyTile')));
    await tester.pumpAndSettle();

    expect(find.text('Polityka prywatności'), findsOneWidget);
    expect(find.textContaining('rzeczywiste działanie'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens terms, privacy settings and backup from legal center', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('moreLegalTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('moreLegalTile')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('termsOfUseTile')));
    await tester.pumpAndSettle();
    expect(find.textContaining('nie zastępuje projektu'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('privacySettingsTile')));
    await tester.pumpAndSettle();
    expect(find.text('Bieżący status'), findsOneWidget);

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('privacyBackupTile')),
      find.descendant(
        of: find.byKey(const ValueKey('privacySettingsContent')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -220),
    );
    await tester.tap(find.byKey(const ValueKey('privacyBackupTile')));
    await tester.pumpAndSettle();
    expect(find.text('Kopia zapasowa i dane'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the budget report from the More tools branch', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    final reportTile = find.byKey(const ValueKey('moreBudgetReportTile'));
    await tester.ensureVisible(reportTile);
    await tester.pumpAndSettle();
    await tester.tap(reportTile);
    await tester.pumpAndSettle();

    expect(find.text('Raport budżetowy'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
  });

  testWidgets('opens technical documentation from the More tools branch', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('moreTechnicalPhotosTile')));
    await tester.pumpAndSettle();

    expect(find.text('Dokumentacja techniczna'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens punch list from the More tools branch', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('morePunchTile')));
    await tester.pumpAndSettle();

    expect(find.text('Usterki i odbiory'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens rooms from the More tools branch', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('moreRoomsTile')));
    await tester.tap(find.byKey(const ValueKey('moreRoomsTile')));
    await tester.pumpAndSettle();

    expect(find.text('Pomieszczenia'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the new project form from the empty start screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Utwórz projekt'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy projekt'), findsOneWidget);
    expect(find.text('Podstawowe dane'), findsOneWidget);
  });

  testWidgets('notification target opens the exact schedule source record', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final event = ScheduleEvent(
      id: 'event-from-notification',
      projectId: 'project-1',
      title: 'Odbiór fundamentów',
      kind: ScheduleEventKind.acceptance,
      status: ScheduleEventStatus.planned,
      startsAt: DateTime.utc(2026, 7, 21, 6),
      timeZoneId: 'Europe/Warsaw',
      isAllDay: false,
      reminderEnabled: true,
      reminderLeadMinutes: 60,
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 7, 20),
    );
    final container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith(
          (ref) async => FakeProjectRepository(),
        ),
        scheduleRepositoryProvider.overrideWith(
          (ref) async => FakeScheduleRepository(events: <ScheduleEvent>[event]),
        ),
        scheduleNotificationGatewayProvider.overrideWithValue(
          FakeScheduleNotificationGateway(
            permission: NotificationPermissionState.denied,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();

    container
        .read(scheduleNotificationTargetProvider.notifier)
        .open(
          const ScheduleNotificationTarget(
            projectId: 'project-1',
            eventId: 'event-from-notification',
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Odbiór fundamentów'), findsOneWidget);
    expect(find.text('Szczegóły terminu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp() {
  final repository = FakeProjectRepository();
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith((ref) async => repository),
    ],
    child: const MainApp(),
  );
}
