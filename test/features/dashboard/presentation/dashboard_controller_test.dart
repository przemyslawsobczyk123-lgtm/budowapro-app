import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/dashboard/data/dashboard_providers.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_reader.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:budowapro/features/dashboard/presentation/dashboard_controller.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';
import '../../../helpers/fake_schedule_services.dart';

void main() {
  test('returns no-project state without querying dashboard records', () async {
    final reader = _FakeDashboardReader();
    final container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith(
          (ref) async => FakeProjectRepository(),
        ),
        dashboardReaderProvider.overrideWith((ref) async => reader),
        scheduleNotificationGatewayProvider.overrideWith(
          (ref) => FakeScheduleNotificationGateway(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(dashboardControllerProvider.future);

    expect(state.project, isNull);
    expect(state.snapshot, isNull);
    expect(reader.loadCount, 0);
  });

  test(
    'loads selected project with DST-safe local calendar boundaries',
    () async {
      final project = _project();
      final reader = _FakeDashboardReader();
      final container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWith(
            (ref) async => FakeProjectRepository(
              projects: [project],
              selectedProjectId: project.id,
            ),
          ),
          dashboardReaderProvider.overrideWith((ref) async => reader),
          scheduleNotificationGatewayProvider.overrideWith(
            (ref) => FakeScheduleNotificationGateway(),
          ),
          scheduleUtcNowProvider.overrideWith(
            (ref) =>
                () => DateTime.utc(2026, 10, 25, 10),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(dashboardControllerProvider.future);

      expect(state.project, same(project));
      expect(state.snapshot?.project, same(project));
      expect(
        reader.lastWindow!.todayEndExclusiveUtc.difference(
          reader.lastWindow!.todayStartUtc,
        ),
        const Duration(hours: 25),
      );
    },
  );

  test('refresh reloads repository projection', () async {
    final project = _project();
    final reader = _FakeDashboardReader();
    final container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith(
          (ref) async => FakeProjectRepository(
            projects: [project],
            selectedProjectId: project.id,
          ),
        ),
        dashboardReaderProvider.overrideWith((ref) async => reader),
        scheduleNotificationGatewayProvider.overrideWith(
          (ref) => FakeScheduleNotificationGateway(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(dashboardControllerProvider.future);

    await container.read(dashboardControllerProvider.notifier).refresh();

    expect(reader.loadCount, 2);
  });
}

final class _FakeDashboardReader implements DashboardReader {
  int loadCount = 0;
  DashboardWindow? lastWindow;

  @override
  Future<DashboardSnapshot> load({
    required Project project,
    required DashboardWindow window,
  }) async {
    loadCount++;
    lastWindow = window;
    final zero = Money.zero(project.currencyCode);
    return DashboardSnapshot(
      project: project,
      stages: const [],
      checklistItems: const [],
      todayAgenda: const [],
      spent: zero,
      plannedNext30Days: zero,
      unpaid: zero,
      unpaidCount: 0,
      costRecordCount: 0,
      openScheduleCount: 0,
    );
  }
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
