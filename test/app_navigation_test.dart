import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.text('Budowa'), findsOneWidget);
    expect(find.text('Więcej'), findsOneWidget);
    expect(find.text('Brak aktywnego projektu'), findsOneWidget);

    const destinations = <String, String>{
      'Plan': 'Najpierw utwórz projekt',
      'Budżet': 'Budżet inwestycji',
      'Budowa': 'Dokumenty',
      'Więcej': 'Narzędzia projektu',
      'Start': 'Brak aktywnego projektu',
    };

    for (final entry in destinations.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    }
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

  testWidgets('opens the budget report from the More tools branch', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('moreBudgetReportTile')));
    await tester.pumpAndSettle();

    expect(find.text('Raport budżetowy'), findsOneWidget);
    expect(find.text('Wybierz projekt'), findsOneWidget);
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
