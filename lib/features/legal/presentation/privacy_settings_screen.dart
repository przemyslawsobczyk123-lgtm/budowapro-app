import 'package:budowapro/features/dashboard/presentation/dashboard_controller.dart';
import 'package:budowapro/features/legal/data/legal_providers.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  var _isDeleting = false;

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
          const Divider(height: 28),
          _SectionTitle(text: l10n.privacyDeleteDataSection),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(l10n.privacyDeleteDataHelp),
          ),
          ListTile(
            key: const ValueKey('privacyDeleteAllDataTile'),
            minTileHeight: 72,
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(l10n.privacyDeleteAllTitle),
            subtitle: Text(l10n.privacyDeleteAllSubtitle),
            trailing: _isDeleting
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: _isDeleting ? null : _deleteAllData,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              l10n.privacyDeleteAllWarning,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _DeleteAllDataDialog(l10n: l10n),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final deletion = await ref.read(localDataDeletionProvider.future);
      await deletion.deleteAll();
      ref.invalidate(appDatabaseProvider);
      ref.invalidate(projectFileStoreProvider);
      ref.invalidate(projectRepositoryProvider);
      ref.invalidate(projectsControllerProvider);
      ref.invalidate(dashboardControllerProvider);
      if (!mounted) return;
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        router.go('/');
      } else {
        setState(() => _isDeleting = false);
      }
    } on Object {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.privacyDeleteAllError)));
    }
  }
}

class _DeleteAllDataDialog extends StatefulWidget {
  const _DeleteAllDataDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_DeleteAllDataDialog> createState() => _DeleteAllDataDialogState();
}

class _DeleteAllDataDialogState extends State<_DeleteAllDataDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrase = widget.l10n.privacyDeleteAllConfirmationPhrase;
    return AlertDialog(
      title: Text(widget.l10n.privacyDeleteAllConfirmTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.l10n.privacyDeleteAllConfirmMessage),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('privacyDeleteAllPhraseField'),
              controller: _controller,
              autofocus: true,
              maxLength: phrase.length,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: widget.l10n.privacyDeleteAllPhraseLabel,
                helperText: phrase,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(widget.l10n.cancelAction),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) => FilledButton(
            key: const ValueKey('privacyDeleteAllConfirmButton'),
            onPressed: value.text.trim() == phrase
                ? () => Navigator.pop(context, true)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(widget.l10n.privacyDeleteAllConfirmAction),
          ),
        ),
      ],
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
