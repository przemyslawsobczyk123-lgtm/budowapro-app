import 'package:budowapro/features/projects/presentation/project_form_screen.dart';
import 'package:budowapro/features/projects/presentation/project_overview_screen.dart';
import 'package:budowapro/features/shell/presentation/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: AppSection.values.map(_branchFor).toList(growable: false),
      ),
    ],
  );

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
          child: section == AppSection.start
              ? const ProjectOverviewScreen()
              : ProjectSectionScreen(section: section),
        ),
      ),
    ],
  );
}
