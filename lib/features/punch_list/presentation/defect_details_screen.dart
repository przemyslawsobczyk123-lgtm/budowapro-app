import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/punch_list/data/punch_providers.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/domain/punch_repository.dart';
import 'package:budowapro/features/punch_list/presentation/punch_controller.dart';
import 'package:budowapro/features/punch_list/presentation/punch_ui_text.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DefectDetailsScreen extends ConsumerWidget {
  const DefectDetailsScreen({
    required this.projectId,
    required this.defectId,
    super.key,
  });

  final String projectId;
  final String defectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final target = (projectId: projectId, defectId: defectId);
    final defect = ref.watch(defectProvider(target));
    return Scaffold(
      key: const ValueKey('defectDetailsScreen'),
      appBar: AppBar(
        title: Text(l10n.defectDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.defectEditTooltip,
            onPressed: defect.value == null
                ? null
                : () async {
                    final saved = await context.push<bool>(
                      '/projects/${Uri.encodeComponent(projectId)}'
                      '/punch/defects/${Uri.encodeComponent(defectId)}/edit',
                    );
                    if (saved == true) ref.invalidate(defectProvider(target));
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: defect.when(
        loading: () => AppLoadingState(label: l10n.punchLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.punchLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(defectProvider(target)),
        ),
        data: (value) => value == null
            ? AppEmptyState(
                icon: Icons.find_in_page_outlined,
                title: l10n.defectNotFound,
                message: l10n.defectNotFound,
              )
            : _DefectDetailsBody(defect: value),
      ),
    );
  }
}

class _DefectDetailsBody extends ConsumerStatefulWidget {
  const _DefectDetailsBody({required this.defect});

  final DefectRecord defect;

  @override
  ConsumerState<_DefectDetailsBody> createState() => _DefectDetailsBodyState();
}

class _DefectDetailsBodyState extends ConsumerState<_DefectDetailsBody> {
  var _changingStatus = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final punch = ref.watch(punchControllerProvider).value;
    final stage = punch?.stages
        .where((item) => item.id == widget.defect.stageId)
        .firstOrNull;
    final contact = punch?.contacts
        .where((item) => item.id == widget.defect.responsibleContactId)
        .firstOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          widget.defect.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.sync_alt_rounded, size: 18),
              label: Text(defectStatusLabel(l10n, widget.defect.status)),
            ),
            Chip(
              avatar: const Icon(Icons.priority_high_rounded, size: 18),
              label: Text(defectSeverityLabel(l10n, widget.defect.severity)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.event_outlined,
          label: l10n.defectOccurredAtLabel,
          value: DateFormat(
            'dd.MM.yyyy',
            'pl_PL',
          ).format(widget.defect.entry.input.occurredAt.toLocal()),
        ),
        if (widget.defect.dueAtUtc != null)
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: l10n.defectDueAtLabel,
            value: DateFormat(
              'dd.MM.yyyy',
              'pl_PL',
            ).format(widget.defect.dueAtUtc!.toLocal()),
          ),
        if (stage != null)
          _InfoRow(
            icon: Icons.account_tree_outlined,
            label: l10n.defectStageLabel,
            value: stageName(l10n, stage),
          ),
        if (widget.defect.roomLabel != null)
          _InfoRow(
            icon: Icons.meeting_room_outlined,
            label: l10n.defectRoomLabel,
            value: widget.defect.roomLabel!,
          ),
        if (contact != null)
          _InfoRow(
            icon: Icons.person_outline,
            label: l10n.defectResponsibleLabel,
            value: contact.displayName,
          ),
        if (widget.defect.description != null) ...[
          const SizedBox(height: 16),
          Text(
            l10n.defectDescriptionLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(widget.defect.description!),
        ],
        const SizedBox(height: 18),
        _closureStatus(context),
        const SizedBox(height: 18),
        _evidence(
          context,
          l10n.defectReportEvidenceTitle,
          widget.defect.entry.input.attachmentIds,
        ),
        const SizedBox(height: 12),
        _evidence(
          context,
          l10n.defectResolutionEvidenceTitle,
          widget.defect.resolutionAttachmentIds,
        ),
        const SizedBox(height: 20),
        if (widget.defect.requiresSignedProtocol &&
            !widget.defect.hasSignedProtocol)
          OutlinedButton.icon(
            onPressed: () => context.push(
              '/projects/${Uri.encodeComponent(widget.defect.projectId)}'
              '/punch/protocols/new?defectId=${Uri.encodeQueryComponent(widget.defect.id)}',
            ),
            icon: const Icon(Icons.note_add_outlined),
            label: Text(l10n.protocolNewTitle),
          ),
        const SizedBox(height: 8),
        PopupMenuButton<JournalEntryStatus>(
          enabled: !_changingStatus,
          onSelected: _setStatus,
          itemBuilder: (context) => allowedStatusesFor(JournalEntryType.defect)
              .where((status) => status != JournalEntryStatus.draft)
              .map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      if (status == widget.defect.status)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.check_rounded, size: 18),
                        ),
                      Expanded(child: Text(defectStatusLabel(l10n, status))),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
          child: FilledButton.icon(
            onPressed: null,
            icon: _changingStatus
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.change_circle_outlined),
            label: Text(l10n.defectSetStatusAction),
          ),
        ),
      ],
    );
  }

  Widget _closureStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missing = <String>[
      if (widget.defect.requiresResolutionPhoto &&
          widget.defect.resolutionAttachmentIds.isEmpty)
        l10n.defectClosureMissingPhoto,
      if (widget.defect.requiresSignedProtocol &&
          !widget.defect.hasSignedProtocol)
        l10n.defectClosureMissingProtocol,
    ];
    final color = missing.isEmpty
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              missing.isEmpty
                  ? Icons.verified_outlined
                  : Icons.warning_amber_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                missing.isEmpty ? l10n.defectClosureReady : missing.join('\n'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _evidence(
    BuildContext context,
    String title,
    Iterable<String> attachmentIds,
  ) {
    final ids = attachmentIds.toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (ids.isEmpty)
          Text(
            AppLocalizations.of(context).defectNoEvidence,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...ids.map(
            (id) => _EvidenceTile(
              projectId: widget.defect.projectId,
              attachmentId: id,
            ),
          ),
      ],
    );
  }

  Future<void> _setStatus(JournalEntryStatus status) async {
    if (status == widget.defect.status) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _changingStatus = true);
    try {
      await ref
          .read(punchControllerProvider.notifier)
          .setDefectStatus(
            projectId: widget.defect.projectId,
            defectId: widget.defect.id,
            status: status,
          );
    } on DefectClosureEvidenceRequiredException {
      if (mounted) _message(l10n.defectClosureMissingPhoto);
    } on DefectClosureProtocolRequiredException {
      if (mounted) _message(l10n.defectClosureMissingProtocol);
    } on Object {
      if (mounted) _message(l10n.defectStatusChangeError);
    } finally {
      if (mounted) setState(() => _changingStatus = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('$label: $value')),
        ],
      ),
    );
  }
}

class _EvidenceTile extends ConsumerWidget {
  const _EvidenceTile({required this.projectId, required this.attachmentId});

  final String projectId;
  final String attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachment = ref.watch(
      punchAttachmentProvider((
        projectId: projectId,
        attachmentId: attachmentId,
      )),
    );
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.image_outlined),
      title: Text(
        attachment.value?.displayName ?? attachmentId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
