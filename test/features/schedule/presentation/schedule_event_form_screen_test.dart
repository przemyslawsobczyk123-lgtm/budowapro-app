import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_form_screen.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';
import '../../../helpers/fake_schedule_services.dart';

void main() {
  testWidgets('saves event even when system reminders fail', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final project = Project(
      id: 'project-1',
      draft: ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 7, 20),
    );
    final projects = FakeProjectRepository(
      projects: <Project>[project],
      selectedProjectId: project.id,
    );
    final schedule = FakeScheduleRepository();
    final notifications = FakeScheduleNotificationGateway(
      failScheduling: true,
      permission: NotificationPermissionState.denied,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectRepositoryProvider.overrideWith((ref) async => projects),
          scheduleRepositoryProvider.overrideWith((ref) async => schedule),
          scheduleNotificationGatewayProvider.overrideWithValue(notifications),
          projectStagesProvider(
            project,
          ).overrideWith((ref) async => const <ProjectStage>[]),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const ScheduleEventFormScreen(projectId: 'project-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('scheduleTitleField')),
      'Dostawa bloczków',
    );
    await tester.tap(find.byKey(const ValueKey('scheduleSaveButton')));
    await tester.pumpAndSettle();

    expect(schedule.events, hasLength(1));
    expect(schedule.events.single.title, 'Dostawa bloczków');
    expect(tester.takeException(), isNull);
  });
}
