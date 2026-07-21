import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/contacts/presentation/contact_details_provider.dart';
import 'package:budowapro/features/contacts/presentation/contact_ui_text.dart';
import 'package:budowapro/features/contacts/presentation/contacts_controller.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ContactDetailsScreen extends ConsumerWidget {
  const ContactDetailsScreen({
    required this.projectId,
    required this.contactId,
    super.key,
  });

  final String projectId;
  final String contactId;

  ContactRecordKey get _key => (projectId: projectId, contactId: contactId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final details = ref.watch(contactDetailsProvider(_key));
    final contact = details.value?.contact;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contactDetailsTitle),
        actions: contact == null
            ? null
            : [
                IconButton(
                  tooltip: l10n.contactEditTooltip,
                  onPressed: () => _edit(context, ref),
                  icon: const Icon(Icons.edit_outlined),
                ),
                PopupMenuButton<_ContactMenuAction>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ContactMenuAction.archive,
                      child: _MenuItem(
                        icon: contact.isArchived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        label: contact.isArchived
                            ? l10n.contactRestoreAction
                            : l10n.contactArchiveAction,
                      ),
                    ),
                    PopupMenuItem(
                      value: _ContactMenuAction.delete,
                      child: _MenuItem(
                        icon: Icons.delete_outline,
                        label: l10n.deleteAction,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  onSelected: (action) {
                    if (action == _ContactMenuAction.archive) {
                      _toggleArchive(context, ref, contact);
                    } else {
                      _delete(context, ref);
                    }
                  },
                ),
              ],
      ),
      body: details.when(
        loading: () => AppLoadingState(label: l10n.projectsLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.contactLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(contactDetailsProvider(_key)),
        ),
        data: (details) => _content(context, ref, details),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, ContactDetails details) {
    final l10n = AppLocalizations.of(context);
    final contact = details.contact;
    if (contact == null) {
      return AppEmptyState(
        icon: Icons.person_off_outlined,
        title: l10n.contactNotFoundTitle,
        message: l10n.contactNotFoundMessage,
      );
    }
    final project = _project(
      ref.watch(projectsControllerProvider).value?.projects,
    );
    final stages = project == null
        ? const <ProjectStage>[]
        : ref.watch(projectStagesProvider(project)).value ??
              const <ProjectStage>[];
    return _ContactDetailsBody(
      contact: contact,
      details: details,
      stages: stages,
      onCall: contact.phone == null
          ? null
          : () => _confirmAction(
              context,
              title: l10n.contactCallConfirmTitle,
              message: l10n.contactCallConfirmMessage(contact.phone!),
              actionLabel: l10n.contactCallAction,
              action: () =>
                  ref.read(contactActionGatewayProvider).call(contact.phone!),
            ),
      onEmail: contact.email == null
          ? null
          : () => _confirmAction(
              context,
              title: l10n.contactEmailConfirmTitle,
              message: l10n.contactEmailConfirmMessage(contact.email!),
              actionLabel: l10n.contactEmailAction,
              action: () =>
                  ref.read(contactActionGatewayProvider).email(contact.email!),
            ),
      onAddVisit: () => _addVisit(context, ref),
      onEditVisit: (visit) => _editVisit(context, ref, visit),
      onRefresh: () async {
        ref.invalidate(contactDetailsProvider(_key));
        await ref.read(contactDetailsProvider(_key).future);
      },
    );
  }

  Project? _project(List<Project>? projects) {
    if (projects == null) return null;
    for (final project in projects) {
      if (project.id == projectId) return project;
    }
    return null;
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(projectId)}'
      '/contacts/${Uri.encodeComponent(contactId)}/edit',
    );
    if (changed == true) _invalidate(ref);
  }

  Future<void> _addVisit(BuildContext context, WidgetRef ref) async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(projectId)}'
      '/contacts/${Uri.encodeComponent(contactId)}/visits/new',
    );
    if (changed == true) _invalidate(ref);
  }

  Future<void> _editVisit(
    BuildContext context,
    WidgetRef ref,
    SiteVisit visit,
  ) async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(projectId)}'
      '/contacts/${Uri.encodeComponent(contactId)}'
      '/visits/${Uri.encodeComponent(visit.id)}/edit',
    );
    if (changed == true) _invalidate(ref);
  }

  Future<void> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await action();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.contactActionError)));
      }
    }
  }

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    Contact contact,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await (await ref.read(contactRepositoryProvider.future)).setArchived(
        projectId: projectId,
        contactId: contactId,
        isArchived: !contact.isArchived,
      );
      _invalidate(ref);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.contactArchiveError)));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.contactDeleteConfirmTitle),
        content: Text(l10n.contactDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await (await ref.read(
        contactRepositoryProvider.future,
      )).delete(projectId: projectId, contactId: contactId);
      ref.invalidate(contactsControllerProvider);
      if (context.mounted) Navigator.pop(context, true);
    } on ContactInUseException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.contactDeleteInUseError)));
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.contactDeleteError)));
      }
    }
  }

  void _invalidate(WidgetRef ref) {
    ref.invalidate(contactDetailsProvider(_key));
    ref.invalidate(contactsControllerProvider);
  }
}

class _ContactDetailsBody extends StatelessWidget {
  const _ContactDetailsBody({
    required this.contact,
    required this.details,
    required this.stages,
    required this.onCall,
    required this.onEmail,
    required this.onAddVisit,
    required this.onEditVisit,
    required this.onRefresh,
  });

  final Contact contact;
  final ContactDetails details;
  final List<ProjectStage> stages;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final VoidCallback onAddVisit;
  final ValueChanged<SiteVisit> onEditVisit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const ValueKey('contactDetailsContent'),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: [
          _ContactHeader(contact: contact),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.filledTonal(
                key: const ValueKey('contactCallButton'),
                tooltip: l10n.contactCallTooltip,
                onPressed: onCall,
                icon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: const ValueKey('contactEmailButton'),
                tooltip: l10n.contactEmailTooltip,
                onPressed: onEmail,
                icon: const Icon(Icons.email_outlined),
              ),
              const Spacer(),
              if (contact.rating != null) ...[
                Text(
                  '${contact.rating}/5',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Icon(Icons.star_rounded),
              ],
            ],
          ),
          const Divider(height: 32),
          Text(
            l10n.contactAboutHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (contact.phone != null)
            _InfoRow(icon: Icons.phone_outlined, value: contact.phone!),
          if (contact.email != null)
            _InfoRow(icon: Icons.email_outlined, value: contact.email!),
          if (contact.taxId != null)
            _InfoRow(
              icon: Icons.receipt_long_outlined,
              value: '${l10n.contactTaxIdLabel}: ${contact.taxId}',
            ),
          if (contact.note != null)
            _InfoRow(icon: Icons.notes_rounded, value: contact.note!),
          if (contact.stageIds.isNotEmpty)
            _InfoRow(
              icon: Icons.account_tree_outlined,
              value: stages
                  .where((stage) => contact.stageIds.contains(stage.id))
                  .map((stage) => stageName(l10n, stage))
                  .join(', '),
            ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.contactVisitHeading,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton.filled(
                tooltip: l10n.contactAddVisitAction,
                onPressed: onAddVisit,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VisitSection(
            title: l10n.contactUpcomingVisits,
            emptyText: l10n.contactUpcomingEmpty,
            visits: details.plannedVisits,
            onTap: onEditVisit,
          ),
          const SizedBox(height: 24),
          _VisitSection(
            title: l10n.contactVisitHistory,
            emptyText: l10n.contactVisitHistoryEmpty,
            visits: details.visitHistory,
            onTap: onEditVisit,
          ),
        ],
      ),
    );
  }
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          child: Icon(
            contact.kind == ContactKind.company
                ? Icons.business_outlined
                : Icons.person_outline_rounded,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: contact.roles
                    .map(
                      (role) => Chip(
                        avatar: Icon(contactRoleIcon(role), size: 17),
                        label: Text(contactRoleLabel(l10n, role)),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _VisitSection extends StatelessWidget {
  const _VisitSection({
    required this.title,
    required this.emptyText,
    required this.visits,
    required this.onTap,
  });

  final String title;
  final String emptyText;
  final List<SiteVisit> visits;
  final ValueChanged<SiteVisit> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (visits.isEmpty)
          Text(emptyText)
        else
          ...visits.map(
            (visit) => _VisitRow(visit: visit, onTap: () => onTap(visit)),
          ),
      ],
    );
  }
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit, required this.onTap});

  final SiteVisit visit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat(
      'd MMM yyyy, HH:mm',
      'pl',
    ).format(visit.startsAtUtc.toLocal());
    final status = siteVisitStatusLabel(l10n, visit.status);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.event_outlined,
        color: siteVisitStatusColor(
          Theme.of(context).colorScheme,
          visit.status,
        ),
      ),
      title: Text(visit.purpose),
      subtitle: Text('$date · $status'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Text(label, style: color == null ? null : TextStyle(color: color)),
      ],
    );
  }
}

enum _ContactMenuAction { archive, delete }
