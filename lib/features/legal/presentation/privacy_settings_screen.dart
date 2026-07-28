import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacySettingsTitle)),
      body: ListView(
        key: const ValueKey('privacySettingsContent'),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline_rounded),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.privacySettingsIntro)),
                ],
              ),
            ),
          ),
          _SectionTitle(text: l10n.privacyStatusSection),
          _StatusTile(
            icon: Icons.phone_android_rounded,
            title: l10n.privacyStatusLocalTitle,
            subtitle: l10n.privacyStatusLocalSubtitle,
          ),
          _StatusTile(
            icon: Icons.person_off_outlined,
            title: l10n.privacyStatusAccountTitle,
            subtitle: l10n.privacyStatusAccountSubtitle,
          ),
          _StatusTile(
            icon: Icons.block_rounded,
            title: l10n.privacyStatusTrackingTitle,
            subtitle: l10n.privacyStatusTrackingSubtitle,
          ),
          _StatusTile(
            icon: Icons.document_scanner_outlined,
            title: l10n.privacyStatusMlKitTitle,
            subtitle: l10n.privacyStatusMlKitSubtitle,
          ),
          _SectionTitle(text: l10n.privacyPermissionsSection),
          _StatusTile(
            icon: Icons.notifications_none_rounded,
            title: l10n.privacyPermissionNotificationsTitle,
            subtitle: l10n.privacyPermissionNotificationsSubtitle,
          ),
          _StatusTile(
            icon: Icons.contacts_outlined,
            title: l10n.privacyPermissionContactsTitle,
            subtitle: l10n.privacyPermissionContactsSubtitle,
          ),
          _StatusTile(
            icon: Icons.photo_camera_outlined,
            title: l10n.privacyPermissionFilesTitle,
            subtitle: l10n.privacyPermissionFilesSubtitle,
          ),
          _StatusTile(
            icon: Icons.cloud_off_outlined,
            title: l10n.privacyAutomaticBackupTitle,
            subtitle: l10n.privacyAutomaticBackupSubtitle,
          ),
          _SectionTitle(text: l10n.privacyDataControlSection),
          ListTile(
            key: const ValueKey('privacyBackupTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.save_alt_rounded),
            title: Text(l10n.privacyCreateBackupTitle),
            subtitle: Text(l10n.privacyCreateBackupSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/backup'),
          ),
          ListTile(
            key: const ValueKey('privacyPolicyFromSettingsTile'),
            minTileHeight: 64,
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l10n.privacyPolicyTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/legal/privacy-policy'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              l10n.privacyDeleteDataHelp,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 68,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
