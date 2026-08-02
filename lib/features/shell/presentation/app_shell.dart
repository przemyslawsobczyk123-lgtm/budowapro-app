import 'package:budowapro/features/costs/presentation/cost_budget_screen.dart';
import 'package:budowapro/features/captures/presentation/captures_screen.dart';
import 'package:budowapro/features/dashboard/presentation/dashboard_controller.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/projects/presentation/project_selector.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final selectedProject = ref
        .watch(projectsControllerProvider)
        .value
        ?.selectedProject;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                child: Row(
                  children: [
                    const Expanded(child: ProjectSelector()),
                    if (selectedProject != null)
                      IconButton(
                        key: const ValueKey('globalCaptureButton'),
                        tooltip: localizations.captureAddTooltip,
                        onPressed: () => showCaptureComposer(context, ref),
                        icon: const Icon(LucideIcons.inbox300),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          if (index == AppSection.start.index) {
            ref.invalidate(dashboardControllerProvider);
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: AppSection.values
            .map(
              (section) => NavigationDestination(
                icon: Icon(section.icon, size: 24),
                selectedIcon: Icon(section.selectedIcon, size: 26),
                label: section.navigationLabel(localizations),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class ProjectSectionScreen extends StatelessWidget {
  const ProjectSectionScreen({required this.section, super.key});

  final AppSection section;

  @override
  Widget build(BuildContext context) {
    if (section == AppSection.budget) {
      return const CostBudgetScreen();
    }
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: section.selectedIcon,
                title: section.title(localizations),
                message: section.subtitle(localizations),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AppSection {
  start('/', LucideIcons.house300, LucideIcons.house300),
  plan('/plan', LucideIcons.listChecks300, LucideIcons.listChecks300),
  budget('/budget', LucideIcons.walletCards300, LucideIcons.walletCards300),
  stages('/stages', Icons.handyman_outlined, Icons.handyman_outlined),
  more('/more', LucideIcons.ellipsis300, LucideIcons.ellipsis300);

  const AppSection(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  String navigationLabel(AppLocalizations localizations) => switch (this) {
    AppSection.start => localizations.navStart,
    AppSection.plan => localizations.navPlan,
    AppSection.budget => localizations.navBudget,
    AppSection.stages => localizations.navStages,
    AppSection.more => localizations.navMore,
  };

  String title(AppLocalizations localizations) => switch (this) {
    AppSection.start => localizations.startTitle,
    AppSection.plan => localizations.planTitle,
    AppSection.budget => localizations.budgetTitle,
    AppSection.stages => localizations.stagesTitle,
    AppSection.more => localizations.moreTitle,
  };

  String subtitle(AppLocalizations localizations) => switch (this) {
    AppSection.start => localizations.startSubtitle,
    AppSection.plan => localizations.planSubtitle,
    AppSection.budget => localizations.budgetSubtitle,
    AppSection.stages => localizations.stagePlanNoProjectMessage,
    AppSection.more => localizations.moreSubtitle,
  };
}
