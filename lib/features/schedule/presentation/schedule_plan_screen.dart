import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_controller.dart';
import 'package:budowapro/features/schedule/presentation/schedule_ui_text.dart';
import 'package:budowapro/features/stages/presentation/stage_plan_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SchedulePlanScreen extends StatelessWidget {
  const SchedulePlanScreen({this.initialTab = 0, super.key})
    : assert(initialTab == 0 || initialTab == 1);

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.planTitle),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.date_range_outlined),
                text: l10n.scheduleWeekTab,
              ),
              Tab(
                icon: const Icon(Icons.account_tree_outlined),
                text: l10n.scheduleStagesTab,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ScheduleWeekView(), StagePlanScreen(embedded: true)],
        ),
      ),
    );
  }
}

class _ScheduleWeekView extends ConsumerWidget {
  const _ScheduleWeekView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(schedulePlanControllerProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: plan.when(
          loading: () => AppLoadingState(label: l10n.scheduleLoading),
          error: (error, stackTrace) => AppErrorState(
            title: l10n.scheduleLoadError,
            retryLabel: l10n.retryAction,
            onRetry: () =>
                ref.read(schedulePlanControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            if (state.project == null) {
              return AppEmptyState(
                icon: Icons.event_note_outlined,
                title: l10n.stagePlanNoProjectTitle,
                message: l10n.stagePlanNoProjectMessage,
                actionLabel: l10n.projectCreateAction,
                onAction: () => context.push('/projects/new'),
              );
            }
            return _ScheduleAgenda(state: state);
          },
        ),
      ),
      floatingActionButton: plan.value?.project == null
          ? null
          : FloatingActionButton(
              key: const ValueKey('scheduleAddEventButton'),
              tooltip: l10n.scheduleAddEventTooltip,
              onPressed: plan.value!.isSaving
                  ? null
                  : () async {
                      final changed = await context.push<bool>(
                        '/projects/${plan.value!.project!.id}/schedule/new',
                      );
                      if (changed == true) {
                        ref
                            .read(schedulePlanControllerProvider.notifier)
                            .refresh();
                      }
                    },
              child: const Icon(Icons.add_rounded),
            ),
    );
  }
}

class _ScheduleAgenda extends ConsumerWidget {
  const _ScheduleAgenda({required this.state});

  final SchedulePlanState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifications = ref.read(scheduleNotificationGatewayProvider);
    final localStart = notifications.toTimeZone(
      state.window.startUtc,
      state.timeZoneId,
    );
    final days = List<DateTime>.generate(
      7,
      (index) =>
          DateTime(localStart.year, localStart.month, localStart.day + index),
      growable: false,
    );
    final eventsByDay = <String, List<ScheduleEvent>>{};
    for (final event in state.events) {
      final local = notifications.toTimeZone(
        event.startsAtUtc,
        event.timeZoneId,
      );
      (eventsByDay[_dayKey(local)] ??= <ScheduleEvent>[]).add(event);
    }
    return CustomScrollView(
      key: const ValueKey('scheduleAgenda'),
      slivers: [
        SliverToBoxAdapter(
          child: _ScheduleToolbar(state: state, localStart: localStart),
        ),
        if (state.permission == NotificationPermissionState.denied)
          SliverToBoxAdapter(child: _PermissionBanner(state: state)),
        SliverToBoxAdapter(child: _ScheduleSummary(state: state)),
        if (state.events.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyState(
              icon: Icons.event_available_outlined,
              title: l10n.scheduleEmptyTitle,
              message: l10n.scheduleEmptyMessage,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 104),
            sliver: SliverList.builder(
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final events =
                    eventsByDay[_dayKey(day)] ?? const <ScheduleEvent>[];
                if (events.isEmpty) return const SizedBox.shrink();
                return _ScheduleDay(day: day, events: events, state: state);
              },
            ),
          ),
      ],
    );
  }
}

class _ScheduleToolbar extends ConsumerWidget {
  const _ScheduleToolbar({required this.state, required this.localStart});

  final SchedulePlanState state;
  final DateTime localStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final end = DateTime(localStart.year, localStart.month, localStart.day + 6);
    final range =
        '${DateFormat('d MMM', 'pl').format(localStart)} - '
        '${DateFormat('d MMM', 'pl').format(end)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.schedulePreviousWeekTooltip,
            onPressed: state.isSaving
                ? null
                : () => ref
                      .read(schedulePlanControllerProvider.notifier)
                      .moveWindow(-7),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.scheduleEyebrow,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  range,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.scheduleNextWeekTooltip,
            onPressed: state.isSaving
                ? null
                : () => ref
                      .read(schedulePlanControllerProvider.notifier)
                      .moveWindow(7),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          IconButton(
            tooltip: l10n.scheduleReminderSettingsTooltip,
            onPressed: state.isSaving
                ? null
                : () => _showReminderSettings(context, ref, state),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }
}

class _PermissionBanner extends ConsumerWidget {
  const _PermissionBanner({required this.state});

  final SchedulePlanState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.schedulePermissionTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.schedulePermissionMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: state.isSaving
                ? null
                : () => ref
                      .read(schedulePlanControllerProvider.notifier)
                      .requestNotificationPermission(
                        notificationBody: l10n.scheduleNotificationBody,
                      ),
            child: Text(l10n.schedulePermissionAction),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSummary extends StatelessWidget {
  const _ScheduleSummary({required this.state});

  final SchedulePlanState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          _SummaryLabel(
            icon: Icons.event_note_outlined,
            label: l10n.scheduleItemsSummary(state.events.length),
          ),
          _SummaryLabel(
            icon: Icons.block_outlined,
            label: l10n.scheduleBlockedSummary(state.blockedCount),
            emphasized: state.blockedCount > 0,
          ),
        ],
      ),
    );
  }
}

class _SummaryLabel extends StatelessWidget {
  const _SummaryLabel({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = emphasized ? colors.error : colors.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ScheduleDay extends StatelessWidget {
  const _ScheduleDay({
    required this.day,
    required this.events,
    required this.state,
  });

  final DateTime day;
  final List<ScheduleEvent> events;
  final SchedulePlanState state;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today =
        now.year == day.year && now.month == day.month && now.day == day.day;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: Text(
              today
                  ? '${l10n.scheduleTodayLabel}, ${DateFormat('d MMM', 'pl').format(day)}'
                  : DateFormat('EEEE, d MMM', 'pl').format(day),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ScheduleEventRow(
                event: event,
                blockers:
                    state.blockersByEventId[event.id] ??
                    const <ScheduleBlocker>[],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleEventRow extends ConsumerWidget {
  const _ScheduleEventRow({required this.event, required this.blockers});

  final ScheduleEvent event;
  final List<ScheduleBlocker> blockers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final local = ref
        .read(scheduleNotificationGatewayProvider)
        .toTimeZone(event.startsAtUtc, event.timeZoneId);
    final unresolved = blockers
        .where((blocker) => !blocker.event.isResolved)
        .toList();
    final statusColor = scheduleStatusColor(theme.colorScheme, event.status);
    return Card(
      key: ValueKey('schedule-event-${event.id}'),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              unresolved.isNotEmpty ||
                  event.status == ScheduleEventStatus.blocked
              ? theme.colorScheme.error
              : theme.colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push('/projects/${event.projectId}/schedule/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                child: Column(
                  children: [
                    Icon(scheduleKindIcon(event.kind), color: statusColor),
                    const SizedBox(height: 4),
                    Text(
                      event.isAllDay
                          ? l10n.scheduleAllDayLabel
                          : DateFormat('HH:mm', 'pl').format(local),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      <String>[
                        scheduleKindLabel(l10n, event.kind),
                        scheduleStatusLabel(l10n, event.status),
                        ?event.assignee,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (unresolved.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.scheduleBlockedBy(unresolved.first.event.title),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showReminderSettings(
  BuildContext context,
  WidgetRef ref,
  SchedulePlanState state,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ReminderSettingsSheet(initialState: state),
  );
}

class _ReminderSettingsSheet extends ConsumerStatefulWidget {
  const _ReminderSettingsSheet({required this.initialState});

  final SchedulePlanState initialState;

  @override
  ConsumerState<_ReminderSettingsSheet> createState() =>
      _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState
    extends ConsumerState<_ReminderSettingsSheet> {
  late Set<ScheduleEventKind> _enabledKinds;
  late int _leadMinutes;
  late TimeOfDay _allDayTime;
  late NotificationPermissionState _permission;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final preferences = widget.initialState.preferences;
    _enabledKinds = preferences.enabledKinds.toSet();
    _leadMinutes = preferences.defaultLeadMinutes;
    _allDayTime = TimeOfDay(
      hour: preferences.allDayReminderMinute ~/ 60,
      minute: preferences.allDayReminderMinute % 60,
    );
    _permission = widget.initialState.permission;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.scheduleSettingsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.scheduleSettingsTypesHeading,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...ScheduleEventKind.values.map(
                (kind) => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(scheduleKindIcon(kind)),
                  title: Text(scheduleKindLabel(l10n, kind)),
                  value: _enabledKinds.contains(kind),
                  onChanged: _saving
                      ? null
                      : (enabled) => setState(() {
                          if (enabled) {
                            _enabledKinds.add(kind);
                          } else {
                            _enabledKinds.remove(kind);
                          }
                        }),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _leadMinutes,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.scheduleDefaultLeadLabel,
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
                items: _leadValues
                    .map(
                      (minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text(scheduleLeadLabel(l10n, minutes)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _saving
                    ? null
                    : (value) =>
                          setState(() => _leadMinutes = value ?? _leadMinutes),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l10n.scheduleAllDayTimeLabel)),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _saving ? null : _pickAllDayTime,
                    child: Text(_allDayTime.format(context)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    _permission == NotificationPermissionState.granted
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_permissionLabel(l10n))),
                  if (_permission != NotificationPermissionState.granted)
                    TextButton(
                      onPressed: _saving ? null : _requestPermission,
                      child: Text(l10n.schedulePermissionAction),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.saveAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _permissionLabel(AppLocalizations l10n) => switch (_permission) {
    NotificationPermissionState.granted => l10n.schedulePermissionGranted,
    NotificationPermissionState.denied => l10n.schedulePermissionDenied,
    NotificationPermissionState.unavailable =>
      l10n.schedulePermissionUnavailable,
  };

  List<int> get _leadValues {
    final values = <int>{
      0,
      15,
      30,
      60,
      120,
      1440,
      2880,
      10080,
      _leadMinutes,
    }.toList()..sort();
    return values;
  }

  Future<void> _pickAllDayTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _allDayTime,
    );
    if (selected != null) setState(() => _allDayTime = selected);
  }

  Future<void> _requestPermission() async {
    setState(() => _saving = true);
    await ref
        .read(schedulePlanControllerProvider.notifier)
        .requestNotificationPermission(
          notificationBody: AppLocalizations.of(
            context,
          ).scheduleNotificationBody,
        );
    if (!mounted) return;
    _permission = ref.read(schedulePlanControllerProvider).value!.permission;
    setState(() => _saving = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(schedulePlanControllerProvider.notifier)
          .savePreferences(
            ReminderPreferences(
              enabledKinds: _enabledKinds,
              defaultLeadMinutes: _leadMinutes,
              allDayReminderMinute: _allDayTime.hour * 60 + _allDayTime.minute,
            ),
            notificationBody: l10n.scheduleNotificationBody,
          );
      if (mounted) Navigator.pop(context);
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.scheduleMutationError)));
      }
    }
  }
}

String _dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
