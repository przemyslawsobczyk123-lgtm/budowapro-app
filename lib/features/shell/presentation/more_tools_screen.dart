import 'package:budowapro/features/captures/presentation/captures_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_feature_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MoreToolsScreen extends ConsumerWidget {
  const MoreToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final captureCount =
        ref.watch(capturesControllerProvider).value?.openTotal ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            key: const ValueKey('moreCapturesTile'),
            minTileHeight: 64,
            leading: Badge(
              isLabelVisible: captureCount > 0,
              label: Text('$captureCount'),
              child: const AppMenuIcon(LucideIcons.inbox300),
            ),
            title: Text(l10n.captureInboxTitle),
            subtitle: Text(l10n.captureInboxOpenTab(captureCount)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/captures'),
          ),
          ListTile(
            key: const ValueKey('moreContactsTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.users300),
            title: Text(l10n.contactsTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/contacts'),
          ),
          ListTile(
            key: const ValueKey('moreRoomsTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.panelsTopLeft300),
            title: Text(l10n.roomsTitle),
            subtitle: Text(l10n.roomsSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/rooms'),
          ),
          ListTile(
            key: const ValueKey('moreMaterialsTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.package300),
            title: Text(l10n.materialsTitle),
            subtitle: Text(l10n.materialsSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/materials'),
          ),
          ListTile(
            key: const ValueKey('moreQuotesTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.fileCheck300),
            title: Text(l10n.quotesTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/quotes'),
          ),
          ListTile(
            key: const ValueKey('moreDocumentsTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.folder300),
            title: Text(l10n.documentsTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/documents'),
          ),
          ListTile(
            key: const ValueKey('moreBudgetReportTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.chartNoAxesCombined300),
            title: Text(l10n.budgetReportTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/reports'),
          ),
          ListTile(
            key: const ValueKey('moreBackupTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.shieldCheck300),
            title: Text(l10n.backupTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/backup'),
          ),
          ListTile(
            key: const ValueKey('moreLegalTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.shield300),
            title: Text(l10n.legalCenterTitle),
            subtitle: Text(l10n.legalCenterTileSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/legal'),
          ),
          ListTile(
            key: const ValueKey('moreJournalTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.notebookText300),
            title: Text(l10n.journalTitle),
            subtitle: Text(l10n.journalSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/diary'),
          ),
          ListTile(
            key: const ValueKey('moreTechnicalPhotosTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.images300),
            title: Text(l10n.technicalPhotosTitle),
            subtitle: Text(l10n.technicalPhotosSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/technical'),
          ),
          ListTile(
            key: const ValueKey('morePunchTile'),
            minTileHeight: 64,
            leading: const AppMenuIcon(LucideIcons.clipboardCheck300),
            title: Text(l10n.punchTitle),
            subtitle: Text(l10n.punchSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/punch'),
          ),
        ],
      ),
    );
  }
}
