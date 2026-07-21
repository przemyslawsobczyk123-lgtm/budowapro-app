import 'package:budowapro/features/dashboard/data/dashboard_providers.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_reader.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardState>(
      DashboardController.new,
    );

final class DashboardState {
  const DashboardState({required this.project, required this.snapshot});

  const DashboardState.noProject() : project = null, snapshot = null;

  final Project? project;
  final DashboardSnapshot? snapshot;
}

final class DashboardController extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return const DashboardState.noProject();
    return _load(project);
  }

  Future<void> refresh() async {
    final project = state.value?.project;
    if (project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<DashboardState>();
    state = await AsyncValue.guard(() => _load(project));
  }

  Future<DashboardState> _load(Project project) async {
    final reader = await ref.read(dashboardReaderProvider.future);
    final notifications = ref.read(scheduleNotificationGatewayProvider);
    final now = ref.read(scheduleUtcNowProvider)().toUtc();
    final window = await _dashboardWindow(notifications, now);
    return DashboardState(
      project: project,
      snapshot: await reader.load(project: project, window: window),
    );
  }
}

Future<DashboardWindow> _dashboardWindow(
  ScheduleNotificationGateway notifications,
  DateTime instant,
) async {
  String timeZoneId;
  try {
    timeZoneId = await notifications.currentTimeZoneId();
  } on Object {
    timeZoneId = 'Etc/UTC';
  }
  final local = notifications.toTimeZone(instant, timeZoneId);
  final wallDay = DateTime(local.year, local.month, local.day);
  return DashboardWindow(
    todayStart: notifications.fromWallTime(wallDay, timeZoneId),
    todayEndExclusive: notifications.fromWallTime(
      DateTime(wallDay.year, wallDay.month, wallDay.day + 1),
      timeZoneId,
    ),
    forecastEndExclusive: notifications.fromWallTime(
      DateTime(wallDay.year, wallDay.month, wallDay.day + 30),
      timeZoneId,
    ),
  );
}
