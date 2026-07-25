import 'package:budowapro/features/backup/data/backup_providers.dart';
import 'package:budowapro/features/backup/domain/backup_gateway.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  _BackupOperation _operation = _BackupOperation.idle;
  BackupSelection? _selection;
  _BackupNotice? _notice;

  bool get _isBusy => _operation != _BackupOperation.idle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_isBusy,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.backupTitle)),
        body: ListView(
          key: const ValueKey('backupScreenContent'),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _BackupScopeBand(),
            _BackupSection(
              heading: l10n.backupCreateHeading,
              description: l10n.backupCreateDescription,
              child: FilledButton.icon(
                key: const ValueKey('createBackupButton'),
                onPressed: _isBusy ? null : _createBackup,
                icon: const Icon(Icons.archive_outlined),
                label: Text(l10n.backupCreateAction),
              ),
            ),
            if (_operation == _BackupOperation.creating)
              _ProgressStatus(label: l10n.backupCreating),
            if (_notice case final notice?) _Notice(notice: notice),
            const Divider(height: 1),
            _BackupSection(
              heading: l10n.backupRestoreHeading,
              description: l10n.backupRestoreDescription,
              child: OutlinedButton.icon(
                key: const ValueKey('pickBackupButton'),
                onPressed: _isBusy ? null : _pickBackup,
                icon: const Icon(Icons.folder_open_outlined),
                label: Text(l10n.backupPickAction),
              ),
            ),
            if (_operation == _BackupOperation.inspecting)
              _ProgressStatus(label: l10n.backupInspecting),
            if (_selection case final selection?)
              _BackupCandidateCard(
                selection: selection,
                restoreEnabled: !_isBusy,
                onRestore: _confirmRestore,
              ),
            if (_operation == _BackupOperation.restoring)
              _ProgressStatus(label: l10n.backupRestoring),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _operation = _BackupOperation.creating;
      _notice = null;
    });
    try {
      final gateway = await ref.read(backupGatewayProvider.future);
      await gateway.createAndShare(shareTitle: l10n.backupTitle);
      if (!mounted) return;
      setState(() {
        _notice = _BackupNotice.success(l10n.backupCreateSuccess);
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _notice = _BackupNotice.error(l10n.backupCreateError);
      });
    } finally {
      if (mounted) setState(() => _operation = _BackupOperation.idle);
    }
  }

  Future<void> _pickBackup() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _operation = _BackupOperation.inspecting;
      _notice = null;
    });
    try {
      final gateway = await ref.read(backupGatewayProvider.future);
      final selection = await gateway.pickAndInspect();
      if (!mounted || selection == null) return;
      setState(() => _selection = selection);
    } on Object {
      if (!mounted) return;
      setState(() {
        _selection = null;
        _notice = _BackupNotice.error(l10n.backupInspectError);
      });
    } finally {
      if (mounted) setState(() => _operation = _BackupOperation.idle);
    }
  }

  Future<void> _confirmRestore() async {
    final selection = _selection;
    if (selection == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupRestoreConfirmTitle),
        content: Text(l10n.backupRestoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            key: const ValueKey('confirmRestoreButton'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: Text(l10n.backupRestoreConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _restore(selection);
  }

  Future<void> _restore(BackupSelection selection) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _operation = _BackupOperation.restoring;
      _notice = null;
    });
    try {
      final gateway = await ref.read(backupGatewayProvider.future);
      await gateway.restore(selection);
      ref.invalidate(appDatabaseProvider);
      if (!mounted) return;
      setState(() {
        _selection = null;
        _notice = _BackupNotice.success(l10n.backupRestoreSuccess);
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _notice = _BackupNotice.error(l10n.backupRestoreError);
      });
    } finally {
      if (mounted) setState(() => _operation = _BackupOperation.idle);
    }
  }
}

class _BackupScopeBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_outlined, color: colorScheme.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.backupScopeHeading,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.backupScopeDescription),
                  const SizedBox(height: 8),
                  Text(
                    l10n.backupLocalOnlyDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupSection extends StatelessWidget {
  const _BackupSection({
    required this.heading,
    required this.description,
    required this.child,
  });

  final String heading;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(heading, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProgressStatus extends StatelessWidget {
  const _ProgressStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.notice});

  final _BackupNotice notice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = notice.isError ? colorScheme.error : colorScheme.primary;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Row(
          key: ValueKey(notice.isError ? 'backupError' : 'backupSuccess'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              notice.isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(notice.message, style: TextStyle(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupCandidateCard extends StatelessWidget {
  const _BackupCandidateCard({
    required this.selection,
    required this.restoreEnabled,
    required this.onRestore,
  });

  final BackupSelection selection;
  final bool restoreEnabled;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = selection.preview;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(preview.createdAt.toLocal());
    return Card(
      key: const ValueKey('backupCandidateCard'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.backupCandidateHeading,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CandidateMetric(label: l10n.backupCreatedLabel, value: date),
            _CandidateMetric(
              label: l10n.backupSchemaLabel,
              value: preview.schemaVersion.toString(),
            ),
            _CandidateMetric(
              label: l10n.backupProjectsLabel,
              value: preview.projectCount.toString(),
            ),
            _CandidateMetric(
              label: l10n.backupFilesLabel,
              value: preview.payloadFileCount.toString(),
            ),
            _CandidateMetric(
              label: l10n.backupSizeLabel,
              value: _formatBytes(l10n, preview.payloadBytes),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('restoreBackupButton'),
              onPressed: restoreEnabled ? onRestore : null,
              icon: const Icon(Icons.restore_rounded),
              label: Text(l10n.backupRestoreAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateMetric extends StatelessWidget {
  const _CandidateMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(AppLocalizations l10n, int bytes) {
  final formatter = NumberFormat.decimalPatternDigits(
    locale: 'pl',
    decimalDigits: 1,
  );
  if (bytes < 1024) return l10n.backupBytesValue(bytes.toString());
  if (bytes < 1024 * 1024) {
    return l10n.backupKilobytesValue(formatter.format(bytes / 1024));
  }
  if (bytes < 1024 * 1024 * 1024) {
    return l10n.backupMegabytesValue(formatter.format(bytes / (1024 * 1024)));
  }
  return l10n.backupGigabytesValue(
    formatter.format(bytes / (1024 * 1024 * 1024)),
  );
}

enum _BackupOperation { idle, creating, inspecting, restoring }

final class _BackupNotice {
  const _BackupNotice._(this.message, this.isError);

  factory _BackupNotice.success(String message) =>
      _BackupNotice._(message, false);

  factory _BackupNotice.error(String message) => _BackupNotice._(message, true);

  final String message;
  final bool isError;
}
