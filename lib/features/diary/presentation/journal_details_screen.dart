import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/presentation/contacts_controller.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/diary/presentation/journal_controller.dart';
import 'package:budowapro/features/diary/presentation/journal_ui_text.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class JournalDetailsScreen extends ConsumerWidget {
  const JournalDetailsScreen({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsControllerProvider);
    final project = projects.value?.selectedProject;
    final l10n = AppLocalizations.of(context);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.journalDetailsTitle)),
        body: AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: l10n.journalNoProjectTitle,
          message: l10n.journalNoProjectMessage,
        ),
      );
    }
    final entry = ref.watch(
      journalEntryProvider((projectId: project.id, entryId: entryId)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.journalDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.journalEditTooltip,
            onPressed: () => context.push('/diary/$entryId/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: entry.when(
        loading: () => AppLoadingState(label: l10n.journalDetailsTitle),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.journalLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(
            journalEntryProvider((projectId: project.id, entryId: entryId)),
          ),
        ),
        data: (value) => value == null
            ? AppEmptyState(
                icon: Icons.find_in_page_outlined,
                title: l10n.journalEmptyTitle,
                message: l10n.journalNoContent,
              )
            : _JournalDetailsBody(
                projectId: project.id,
                currencyCode: project.currencyCode,
                entry: value,
              ),
      ),
    );
  }
}

class _JournalDetailsBody extends ConsumerWidget {
  const _JournalDetailsBody({
    required this.projectId,
    required this.currencyCode,
    required this.entry,
  });

  final String projectId;
  final String currencyCode;
  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final input = entry.input;
    final journalReady = ref.watch(journalControllerProvider).hasValue;
    final contacts =
        ref.watch(contactsControllerProvider).value?.contacts ??
        const <Contact>[];
    final contactsById = <String, Contact>{
      for (final contact in contacts) contact.id: contact,
    };
    final isDecision =
        entry.type == JournalEntryType.decision ||
        entry.type == JournalEntryType.scopeChange;
    final revisions = ref.watch(
      journalRevisionsProvider((projectId: projectId, entryId: entry.id)),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 24, child: Icon(journalTypeIcon(entry.type))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(journalTypeLabel(l10n, entry.type)),
                  Text(
                    DateFormat(
                      'dd.MM.yyyy, HH:mm',
                      'pl_PL',
                    ).format(entry.occurredAtUtc.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isDecision) ...[
          _approvalSection(
            context,
            ref,
            contacts,
            contactsById,
            journalReady: journalReady,
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<JournalEntryStatus>(
          initialValue: entry.status,
          decoration: InputDecoration(labelText: l10n.journalStatusLabel),
          items: allowedStatusesFor(entry.type)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  enabled:
                      !isDecision ||
                      (value != JournalEntryStatus.approved &&
                          (value != JournalEntryStatus.implemented ||
                              entry.approval != null)),
                  child: Text(journalStatusLabel(l10n, value)),
                ),
              )
              .toList(growable: false),
          onChanged: journalReady
              ? (status) async {
                  if (status == null || status == entry.status) return;
                  try {
                    await ref
                        .read(journalControllerProvider.notifier)
                        .setStatus(entry.id, status);
                  } on Object {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.journalSaveError)),
                      );
                    }
                  }
                }
              : null,
        ),
        const SizedBox(height: 18),
        if (input.body != null)
          _section(context, l10n.journalBodyLabel, input.body!),
        if (entry.type == JournalEntryType.daily) ...[
          _optionalSection(context, l10n.journalWeatherLabel, input.weather),
          _optionalSection(context, l10n.journalPeopleLabel, input.people),
          _optionalSection(context, l10n.journalWorkLabel, input.workPerformed),
          _optionalSection(
            context,
            l10n.journalDeliveriesLabel,
            input.deliveries,
          ),
          _optionalSection(context, l10n.journalDelaysLabel, input.delays),
          _optionalSection(
            context,
            l10n.journalNextStepsLabel,
            input.nextSteps,
          ),
        ],
        if (entry.type == JournalEntryType.decision ||
            entry.type == JournalEntryType.scopeChange) ...[
          _optionalSection(context, l10n.journalProblemLabel, input.problem),
          _optionalSection(context, l10n.journalVariantsLabel, input.variants),
          _optionalSection(
            context,
            l10n.journalSelectedOptionLabel,
            input.selectedOption,
          ),
          _optionalSection(
            context,
            l10n.journalRationaleLabel,
            input.rationale,
          ),
        ],
        if (input.dueAt != null)
          _section(
            context,
            l10n.journalDueDateLabel,
            DateFormat('dd.MM.yyyy', 'pl_PL').format(input.dueAt!.toLocal()),
          ),
        if (input.costDeltaMinorUnits != null)
          _section(
            context,
            l10n.journalCostImpactLabel,
            formatMoneyForDisplay(
              Money(
                minorUnits: input.costDeltaMinorUnits!,
                currencyCode: currencyCode,
              ),
              currencyCode,
            ),
          ),
        if (input.scheduleDeltaDays != null)
          _section(
            context,
            l10n.journalScheduleImpactLabel,
            '${input.scheduleDeltaDays} ${l10n.journalDaysSuffix}',
          ),
        _blockedRecords(context, input),
        _relatedRecords(context, input),
        _attachments(context, ref, input.attachmentIds),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l10n.journalHistoryTitle),
          subtitle: Text(
            revisions.when(
              loading: () => l10n.journalHistoryCount(0),
              error: (error, stackTrace) => l10n.journalHistoryCount(0),
              data: (items) => l10n.journalHistoryCount(items.length),
            ),
          ),
          children: revisions.when(
            loading: () => const [LinearProgressIndicator(minHeight: 2)],
            error: (error, stackTrace) => const <Widget>[],
            data: (items) => items
                .map(
                  (revision) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_rounded),
                    title: Text(
                      journalRevisionActionLabel(l10n, revision.action),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd.MM.yyyy, HH:mm',
                        'pl_PL',
                      ).format(revision.createdAtUtc.toLocal()),
                    ),
                    trailing: Text('v${revision.revision}'),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _approvalSection(
    BuildContext context,
    WidgetRef ref,
    List<Contact> contacts,
    Map<String, Contact> contactsById, {
    required bool journalReady,
  }) {
    final l10n = AppLocalizations.of(context);
    final approval = entry.approval;
    if (approval != null) {
      final approver = contactsById[approval.approvedByContactId];
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_outlined),
                  const SizedBox(width: 8),
                  Text(
                    l10n.journalApprovalTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${l10n.journalApprovalPersonLabel}: '
                '${approver?.displayName ?? approval.approvedByContactId}',
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.journalApprovalDateLabel}: '
                '${DateFormat('dd.MM.yyyy, HH:mm', 'pl_PL').format(approval.approvedAtUtc.toLocal())}',
              ),
            ],
          ),
        ),
      );
    }
    final hasSelectedOption = entry.input.selectedOption != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: hasSelectedOption && contacts.isNotEmpty && journalReady
              ? () => _approveDecision(context, ref, contacts)
              : null,
          icon: const Icon(Icons.verified_outlined),
          label: Text(l10n.journalApproveAction),
        ),
        if (!hasSelectedOption)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.journalApprovalOptionRequired,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else if (contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.journalApprovalContactRequired,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Future<void> _approveDecision(
    BuildContext context,
    WidgetRef ref,
    List<Contact> contacts,
  ) async {
    final preferredId =
        <String?>[
          entry.input.decisionMakerContactId,
          entry.input.responsibleContactId,
          contacts.firstOrNull?.id,
        ].firstWhere(
          (id) => id != null && contacts.any((contact) => contact.id == id),
          orElse: () => null,
        );
    var selectedId = preferredId;
    final approvedByContactId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.journalApprovalDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.journalApprovalDialogMessage),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedId,
                  decoration: InputDecoration(
                    labelText: l10n.journalApprovalPersonLabel,
                  ),
                  items: contacts
                      .map(
                        (contact) => DropdownMenuItem(
                          value: contact.id,
                          child: Text(contact.displayName),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) =>
                      setDialogState(() => selectedId = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancelAction),
              ),
              FilledButton(
                onPressed: selectedId == null
                    ? null
                    : () => Navigator.of(dialogContext).pop(selectedId),
                child: Text(l10n.journalApproveAction),
              ),
            ],
          ),
        );
      },
    );
    if (approvedByContactId == null || !context.mounted) return;
    try {
      await ref
          .read(journalControllerProvider.notifier)
          .approveDecision(entry.id, approvedByContactId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).journalApprovalSuccess),
          ),
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).journalApprovalError),
          ),
        );
      }
    }
  }

  Widget _blockedRecords(BuildContext context, JournalEntryInput input) {
    final blocked = input.relations
        .where((relation) => relation.purpose == JournalRelationPurpose.blocks)
        .toList(growable: false);
    if (blocked.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.journalBlockedRecordsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ...blocked.map(
          (link) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.block_outlined),
            title: Text(link.label ?? link.targetId),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: link.type == JournalRelationType.schedule
                ? () => context.push(
                    '/projects/${Uri.encodeComponent(projectId)}'
                    '/schedule/${Uri.encodeComponent(link.targetId)}',
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _relatedRecords(BuildContext context, JournalEntryInput input) {
    final l10n = AppLocalizations.of(context);
    final links = <JournalRelation>[
      if (input.stageId != null)
        JournalRelation(
          type: JournalRelationType.stage,
          targetId: input.stageId!,
        ),
      if (input.responsibleContactId != null)
        JournalRelation(
          type: JournalRelationType.contact,
          targetId: input.responsibleContactId!,
        ),
      ...input.relations.where(
        (relation) => relation.purpose == JournalRelationPurpose.context,
      ),
    ];
    final unique = <String, JournalRelation>{};
    for (final link in links) {
      unique['${link.type.name}:${link.targetId}'] = link;
    }
    if (unique.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.journalRelatedRecordsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ...unique.values.map(
          (link) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              link.type == JournalRelationType.contact
                  ? Icons.person_outline
                  : Icons.layers_outlined,
            ),
            title: Text(
              link.type == JournalRelationType.contact
                  ? l10n.journalContactLink
                  : l10n.journalStageLink,
            ),
            subtitle: Text(link.targetId),
            onTap: () {
              if (link.type == JournalRelationType.contact) {
                context.push(
                  '/projects/${Uri.encodeComponent(projectId)}'
                  '/contacts/${Uri.encodeComponent(link.targetId)}',
                );
              } else if (link.type == JournalRelationType.stage) {
                context.go('/plan?tab=stages');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _attachments(
    BuildContext context,
    WidgetRef ref,
    List<String> attachmentIds,
  ) {
    if (attachmentIds.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<StagedLocalAttachment>>(
      future: _loadAttachments(ref),
      builder: (context, snapshot) {
        final attachments = snapshot.data ?? const <StagedLocalAttachment>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              l10n.journalAttachmentsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (snapshot.connectionState != ConnectionState.done)
              const LinearProgressIndicator(minHeight: 2),
            ...attachments.map(
              (attachment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attach_file_rounded),
                title: Text(attachment.displayName),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<StagedLocalAttachment>> _loadAttachments(WidgetRef ref) async {
    final stager = await ref.read(localAttachmentStagerProvider.future);
    final items = <StagedLocalAttachment>[];
    for (final attachmentId in entry.input.attachmentIds) {
      final item = await stager.findById(
        projectId: projectId,
        attachmentId: attachmentId,
      );
      if (item != null) items.add(item);
    }
    return items;
  }

  static Widget _optionalSection(
    BuildContext context,
    String label,
    String? value,
  ) =>
      value == null ? const SizedBox.shrink() : _section(context, label, value);

  static Widget _section(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
