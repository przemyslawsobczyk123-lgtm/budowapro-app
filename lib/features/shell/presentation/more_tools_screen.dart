import 'package:budowapro/features/captures/presentation/captures_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              child: const Icon(Icons.inbox_outlined),
            ),
            title: Text(l10n.captureInboxTitle),
            subtitle: Text(l10n.captureInboxOpenTab(captureCount)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/captures'),
          ),
          ListTile(
            key: const ValueKey('moreContactsTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.groups_outlined),
            title: Text(l10n.contactsTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/contacts'),
          ),
          ListTile(
            key: const ValueKey('moreQuotesTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.request_quote_outlined),
            title: Text(l10n.quotesTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/quotes'),
          ),
          ListTile(
            key: const ValueKey('moreDocumentsTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.folder_copy_outlined),
            title: Text(l10n.documentsTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go('/build'),
          ),
          ListTile(
            key: const ValueKey('moreBudgetReportTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.query_stats_outlined),
            title: Text(l10n.budgetReportTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/reports'),
          ),
          ListTile(
            key: const ValueKey('moreBackupTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.shield_outlined),
            title: Text(l10n.backupTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/backup'),
          ),
          ListTile(
            key: const ValueKey('moreLegalTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.legalCenterTitle),
            subtitle: Text(l10n.legalCenterTileSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/legal'),
          ),
        ],
      ),
    );
  }
}
