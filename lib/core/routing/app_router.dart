import 'package:budowapro/features/costs/presentation/cost_details_screen.dart';
import 'package:budowapro/features/costs/presentation/cost_form_screen.dart';
import 'package:budowapro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budowapro/features/projects/presentation/project_form_screen.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_details_screen.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_form_screen.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_screen.dart';
import 'package:budowapro/features/shell/presentation/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: AppSection.start.path,
    routes: [
      GoRoute(
        path: '/projects/new',
        builder: (context, state) => const ProjectFormScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId/edit',
        builder: (context, state) =>
            ProjectFormScreen(projectId: state.pathParameters['projectId']),
      ),
      GoRoute(
        path: '/projects/:projectId/costs/new',
        builder: (context, state) =>
            CostFormScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/costs/:costEntryId',
        builder: (context, state) => CostDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          costEntryId: state.pathParameters['costEntryId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/costs/:costEntryId/edit',
        builder: (context, state) => CostFormScreen(
          projectId: state.pathParameters['projectId']!,
          costEntryId: state.pathParameters['costEntryId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/new',
        builder: (context, state) => ScheduleEventFormScreen(
          projectId: state.pathParameters['projectId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/:eventId/edit',
        builder: (context, state) => ScheduleEventFormScreen(
          projectId: state.pathParameters['projectId']!,
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/schedule/:eventId',
        builder: (context, state) => ScheduleEventDetailsScreen(
          projectId: state.pathParameters['projectId']!,
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: AppSection.values.map(_branchFor).toList(growable: false),
      ),
    ],
  );

  ref.listen(scheduleNotificationTargetProvider, (previous, target) {
    if (target == null) return;
    router.go(
      '/projects/${Uri.encodeComponent(target.projectId)}'
      '/schedule/${Uri.encodeComponent(target.eventId)}',
    );
    ref.read(scheduleNotificationTargetProvider.notifier).clear();
  });

  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branchFor(AppSection section) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: section.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: switch (section) {
            AppSection.start => const DashboardScreen(),
            AppSection.plan => SchedulePlanScreen(
              initialTab: state.uri.queryParameters['tab'] == 'stages' ? 1 : 0,
            ),
            _ => ProjectSectionScreen(section: section),
          },
        ),
      ),
    ],
  );
}
