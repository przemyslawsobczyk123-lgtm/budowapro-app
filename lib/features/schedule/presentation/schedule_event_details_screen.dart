import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_details_provider.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_controller.dart';
import 'package:budowapro/features/schedule/presentation/schedule_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScheduleEventDetailsScreen extends ConsumerWidget {
  const ScheduleEventDetailsScreen({
    required this.projectId,
    required this.eventId,
    super.key,
  });

  final String projectId;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (projectId: projectId, eventId: eventId);
    final details = ref.watch(scheduleEventDetailsProvider(key));
    return Scaffold(
      key: const ValueKey('scheduleEventDetailsScreen'),
      appBar: AppBar(
        title: Text(l10n.scheduleDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.scheduleEditAction,
            onPressed: details.value?.event == null
                ? null
                : () async {
                    final changed = await context.push<bool>(
                      '/projects/$projectId/schedule/$eventId/edit',
                    );
                    if (changed == true) {
                      ref.invalidate(scheduleEventDetailsProvider(key));
                    }
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: details.when(
        loading: () => AppLoadingState(label: l10n.scheduleLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.scheduleLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(scheduleEventDetailsProvider(key)),
        ),
        data: (details) {
          final event = details.event;
          if (event == null) {
            return AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: l10n.scheduleSourceMissingTitle,
              message: l10n.scheduleSourceMissingMessage,
            );
          }
          return _EventDetailsContent(details: details);
        },
      ),
    );
  }
}

class _EventDetailsContent extends ConsumerWidget {
  const _EventDetailsContent({required this.details});

  final ScheduleEventDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = details.event!;
    final l10n = AppLocalizations.of(context);
    final local = ref
        .read(scheduleNotificationGatewayProvider)
        .toTimeZone(event.startsAtUtc, event.timeZoneId);
    final dateLabel = event.isAllDay
        ? DateFormat('EEEE, d MMMM yyyy', 'pl').format(local)
        : DateFormat('EEEE, d MMMM yyyy, HH:mm', 'pl').format(local);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _EventHeader(event: event, dateLabel: dateLabel),
        const SizedBox(height: 20),
        _InfoRow(
          icon: Icons.flag_outlined,
          label: l10n.scheduleStatusLabel,
          value: scheduleStatusLabel(l10n, event.status),
        ),
        if (event.assignee != null)
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: l10n.scheduleAssigneeLabel,
            value: event.assignee!,
          ),
        _InfoRow(
          icon: event.reminderEnabled
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          label: l10n.scheduleSettingsTitle,
          value: event.reminderEnabled
              ? '${l10n.scheduleReminderEnabled} · '
                    '${scheduleLeadLabel(l10n, event.reminderLeadMinutes)}'
              : l10n.scheduleReminderDisabled,
        ),
        if (event.note != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.scheduleNoteLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(event.note!),
        ],
        const Divider(height: 32),
        _SectionHeader(
          title: l10n.scheduleDependenciesHeading,
          actionLabel: l10n.scheduleDependenciesEditAction,
          onAction: () => _editDependencies(context, ref, details),
        ),
        if (details.blockers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.scheduleDependenciesEmpty),
          )
        else
          ...details.blockers.map((blocker) => _BlockerRow(blocker: blocker)),
        const Divider(height: 32),
        Text(
          l10n.scheduleHistoryHeading,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (details.dateChanges.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.scheduleHistoryEmpty),
          )
        else
          ...details.dateChanges.map(
            (change) =>
                _DateChangeRow(change: change, timeZoneId: event.timeZoneId),
          ),
      ],
    );
  }
}

class _EventHeader extends StatelessWidget {
  const _EventHeader({required this.event, required this.dateLabel});

  final ScheduleEvent event;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(scheduleKindIcon(event.kind), size: 32, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(scheduleKindLabel(l10n, event.kind)),
                const SizedBox(height: 2),
                Text(
                  event.isAllDay
                      ? '$dateLabel · ${l10n.scheduleAllDayLabel}'
                      : dateLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.account_tree_outlined),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _BlockerRow extends StatelessWidget {
  const _BlockerRow({required this.blocker});

  final ScheduleBlocker blocker;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final due = blocker.dependency.decisionDueAtUtc;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        blocker.event.isResolved
            ? Icons.check_circle_outline
            : Icons.block_outlined,
      ),
      title: Text(blocker.event.title),
      subtitle: due == null
          ? Text(scheduleStatusLabel(l10n, blocker.event.status))
          : Text(
              l10n.scheduleDecisionDue(
                DateFormat('d MMM yyyy', 'pl').format(due.toLocal()),
              ),
            ),
      onTap: () => context.push(
        '/projects/${blocker.event.projectId}/schedule/${blocker.event.id}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _DateChangeRow extends ConsumerWidget {
  const _DateChangeRow({required this.change, required this.timeZoneId});

  final ScheduleDateChange change;
  final String timeZoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gateway = ref.read(scheduleNotificationGatewayProvider);
    final previous = gateway.toTimeZone(
      change.previousStartsAtUtc,
      change.previousTimeZoneId,
    );
    final next = gateway.toTimeZone(
      change.newStartsAtUtc,
      change.newTimeZoneId,
    );
    final format = DateFormat('d MMM yyyy, HH:mm', 'pl');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history_rounded),
      title: Text(
        l10n.scheduleHistoryMoved(format.format(previous), format.format(next)),
      ),
      subtitle: change.reason == null ? null : Text(change.reason!),
    );
  }
}

Future<void> _editDependencies(
  BuildContext context,
  WidgetRef ref,
  ScheduleEventDetails details,
) async {
  final result = await showModalBottomSheet<List<ScheduleDependencyInput>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _DependencySheet(details: details),
  );
  if (result == null || !context.mounted) return;
  final event = details.event!;
  final l10n = AppLocalizations.of(context);
  try {
    final repository = await ref.read(scheduleRepositoryProvider.future);
    await repository.replaceDependencies(
      projectId: event.projectId,
      eventId: event.id,
      dependencies: result,
    );
    ref.invalidate(
      scheduleEventDetailsProvider((
        projectId: event.projectId,
        eventId: event.id,
      )),
    );
    ref.invalidate(schedulePlanControllerProvider);
  } on ScheduleDependencyCycleException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scheduleDependencyCycleError)),
      );
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.scheduleMutationError)));
    }
  }
}

class _DependencySheet extends StatefulWidget {
  const _DependencySheet({required this.details});

  final ScheduleEventDetails details;

  @override
  State<_DependencySheet> createState() => _DependencySheetState();
}

class _DependencySheetState extends State<_DependencySheet> {
  late final List<ScheduleEvent> _candidates;
  late final Set<String> _selected;
  late final Map<String, DateTime?> _deadlines;

  @override
  void initState() {
    super.initState();
    final byId = <String, ScheduleEvent>{
      for (final candidate in widget.details.dependencyCandidates)
        candidate.id: candidate,
      for (final blocker in widget.details.blockers)
        blocker.event.id: blocker.event,
    };
    _candidates = byId.values.toList()
      ..sort((a, b) => a.startsAtUtc.compareTo(b.startsAtUtc));
    _selected = widget.details.blockers
        .map((blocker) => blocker.event.id)
        .toSet();
    _deadlines = <String, DateTime?>{
      for (final blocker in widget.details.blockers)
        blocker.event.id: blocker.dependency.decisionDueAtUtc,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.scheduleDependencySheetTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _selected
                          .map(
                            (id) => ScheduleDependencyInput(
                              blockingEventId: id,
                              decisionDueAt: _deadlines[id],
                            ),
                          )
                          .toList(growable: false),
                    ),
                    child: Text(l10n.saveAction),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_candidates.isEmpty)
              Expanded(
                child: AppEmptyState(
                  icon: Icons.account_tree_outlined,
                  title: l10n.scheduleDependenciesEmpty,
                  message: l10n.scheduleEmptyMessage,
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _candidates.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final candidate = _candidates[index];
                    final selected = _selected.contains(candidate.id);
                    final deadline = _deadlines[candidate.id];
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          _selected.add(candidate.id);
                        } else {
                          _selected.remove(candidate.id);
                          _deadlines.remove(candidate.id);
                        }
                      }),
                      title: Text(candidate.title),
                      subtitle: deadline == null
                          ? Text(scheduleStatusLabel(l10n, candidate.status))
                          : Text(
                              l10n.scheduleDecisionDue(
                                DateFormat('d MMM yyyy', 'pl').format(deadline),
                              ),
                            ),
                      secondary: Icon(scheduleKindIcon(candidate.kind)),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.only(left: 16, right: 4),
                      isThreeLine: false,
                      // The calendar is separate from the checkbox for fast editing.
                      shape: const RoundedRectangleBorder(),
                    );
                  },
                ),
              ),
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selected
                      .map((id) {
                        final candidate = _candidates.firstWhere(
                          (event) => event.id == id,
                        );
                        return ActionChip(
                          avatar: const Icon(Icons.event_outlined, size: 18),
                          label: Text(candidate.title),
                          tooltip: l10n.scheduleDependencyDeadlineTooltip,
                          onPressed: () => _pickDeadline(id),
                        );
                      })
                      .toList(growable: false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline(String id) async {
    final initial = _deadlines[id]?.toLocal() ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _deadlines[id] = selected.toUtc());
    }
  }
}
