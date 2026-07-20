import 'package:budowapro/features/costs/presentation/cost_budget_screen.dart';
import 'package:budowapro/features/projects/presentation/project_selector.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ProjectSelector(),
              ),
            ),
          ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: AppSection.values
            .map(
              (section) => NavigationDestination(
                icon: Icon(section.icon),
                selectedIcon: Icon(section.selectedIcon),
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
  start('/', Icons.home_outlined, Icons.home_rounded),
  plan('/plan', Icons.checklist_outlined, Icons.checklist_rounded),
  budget(
    '/budget',
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet,
  ),
  build('/build', Icons.construction_outlined, Icons.construction_rounded),
  more('/more', Icons.more_horiz_rounded, Icons.more_horiz_rounded);

  const AppSection(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  String navigationLabel(AppLocalizations localizations) => switch (this) {
    AppSection.start => localizations.navStart,
    AppSection.plan => localizations.navPlan,
    AppSection.budget => localizations.navBudget,
    AppSection.build => localizations.navBuild,
    AppSection.more => localizations.navMore,
  };

  String title(AppLocalizations localizations) => switch (this) {
    AppSection.start => localizations.startTitle,
    AppSection.plan => localizations.planTitle,
    AppSection.budget => localizations.budgetTitle,
    AppSection.build => localizations.buildTitle,
    AppSection.more => localizations.moreTitle,
  };

  String subtitle(AppLocalizations localizations) => switch (this) {
    AppSection.start => localizations.startSubtitle,
    AppSection.plan => localizations.planSubtitle,
    AppSection.budget => localizations.budgetSubtitle,
    AppSection.build => localizations.buildSubtitle,
    AppSection.more => localizations.moreSubtitle,
  };
}
