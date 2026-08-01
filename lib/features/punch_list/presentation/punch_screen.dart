import 'dart:async';

import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/presentation/punch_controller.dart';
import 'package:budowapro/features/punch_list/presentation/punch_ui_text.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PunchScreen extends ConsumerStatefulWidget {
  const PunchScreen({super.key});

  @override
  ConsumerState<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends ConsumerState<PunchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _search = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)..addListener(_tabChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    _tabs
      ..removeListener(_tabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(punchControllerProvider);
    final filterCount = state.value?.filters.activeFilterCount ?? 0;
    return Scaffold(
      key: const ValueKey('punchScreen'),
      appBar: AppBar(
        title: Text(l10n.punchTitle),
        actions: [
          IconButton(
            key: const ValueKey('punchFiltersButton'),
            tooltip: l10n.punchFilterTooltip,
            onPressed: state.hasValue && state.requireValue.project != null
                ? () => _showFilters(state.requireValue)
                : null,
            icon: filterCount == 0
                ? const Icon(Icons.filter_list_rounded)
                : Badge(
                    label: Text('$filterCount'),
                    child: const Icon(Icons.filter_list_rounded),
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.punchDefectsTab, icon: const Icon(Icons.rule)),
            Tab(
              text: l10n.punchProtocolsTab,
              icon: const Icon(Icons.assignment_turned_in_outlined),
            ),
          ],
        ),
      ),
      body: state.when(
        loading: () => AppLoadingState(label: l10n.punchLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.punchLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.read(punchControllerProvider.notifier).refresh(),
        ),
        data: (value) => _body(context, value),
      ),
      floatingActionButton: state.value?.project == null
          ? null
          : FloatingActionButton(
              key: const ValueKey('punchAddButton'),
              tooltip: _tabs.index == 0
                  ? l10n.punchAddDefectTooltip
                  : l10n.punchAddProtocolTooltip,
              onPressed: () => _add(state.value!),
              child: Icon(
                _tabs.index == 0
                    ? Icons.add_task_rounded
                    : Icons.note_add_outlined,
              ),
            ),
    );
  }

  Widget _body(BuildContext context, PunchState state) {
    final l10n = AppLocalizations.of(context);
    if (state.project == null) {
      return AppEmptyState(
        icon: Icons.home_work_outlined,
        title: l10n.punchNoProjectTitle,
        message: l10n.punchNoProjectMessage,
      );
    }
    return Column(
      children: [
        _summary(context, state.summary),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            key: const ValueKey('punchSearchField'),
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.punchSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.clearAction,
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                        _applySearch('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
            onChanged: (value) {
              setState(() {});
              _searchDebounce?.cancel();
              _searchDebounce = Timer(
                const Duration(milliseconds: 300),
                () => _applySearch(value),
              );
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [_defects(context, state), _protocols(context, state)],
          ),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context, PunchSummary summary) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: l10n.punchOpenCounter,
              value: summary.openCount,
              icon: Icons.pending_actions_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryItem(
              label: l10n.punchCriticalCounter,
              value: summary.criticalCount,
              icon: Icons.priority_high_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryItem(
              label: l10n.punchOverdueCounter,
              value: summary.overdueCount,
              icon: Icons.event_busy_outlined,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _defects(BuildContext context, PunchState state) {
    final l10n = AppLocalizations.of(context);
    if (state.defects.isEmpty) {
      return AppEmptyState(
        icon: Icons.fact_check_outlined,
        title: l10n.punchDefectsEmptyTitle,
        message: l10n.punchDefectsEmptyMessage,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
      itemCount:
          state.defects.length + 1 + (state.nextDefectPage == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              l10n.punchDefectCount(state.defectTotalCount),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          );
        }
        final itemIndex = index - 1;
        if (itemIndex == state.defects.length) {
          return _LoadMoreButton(
            loading: state.isLoadingMoreDefects,
            onPressed: () =>
                ref.read(punchControllerProvider.notifier).loadMoreDefects(),
          );
        }
        final defect = state.defects[itemIndex];
        return _DefectTile(
          defect: defect,
          stageLabel: _stageLabel(context, state.stages, defect.stageId),
          contactLabel: _contactLabel(
            state.contacts,
            defect.responsibleContactId,
          ),
          onTap: () => context.push(
            '/projects/${Uri.encodeComponent(defect.projectId)}'
            '/punch/defects/${Uri.encodeComponent(defect.id)}',
          ),
        );
      },
    );
  }

  Widget _protocols(BuildContext context, PunchState state) {
    final l10n = AppLocalizations.of(context);
    if (state.protocols.isEmpty) {
      return AppEmptyState(
        icon: Icons.assignment_turned_in_outlined,
        title: l10n.punchProtocolsEmptyTitle,
        message: l10n.punchProtocolsEmptyMessage,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
      itemCount:
          state.protocols.length + 1 + (state.nextProtocolPage == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              l10n.punchProtocolCount(state.protocolTotalCount),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          );
        }
        final itemIndex = index - 1;
        if (itemIndex == state.protocols.length) {
          return _LoadMoreButton(
            loading: state.isLoadingMoreProtocols,
            onPressed: () =>
                ref.read(punchControllerProvider.notifier).loadMoreProtocols(),
          );
        }
        final protocol = state.protocols[itemIndex];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            minTileHeight: 72,
            leading: Icon(
              protocol.status == AcceptanceProtocolStatus.signed
                  ? Icons.verified_outlined
                  : Icons.assignment_outlined,
            ),
            title: Text(
              protocol.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${acceptanceProtocolStatusLabel(l10n, protocol.status)}'
              ' · ${DateFormat('dd.MM.yyyy', 'pl_PL').format(protocol.inspectedAtUtc.toLocal())}'
              ' · ${l10n.punchDefectCount(protocol.defectIds.length)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(
              '/projects/${Uri.encodeComponent(protocol.projectId)}'
              '/punch/protocols/${Uri.encodeComponent(protocol.id)}',
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilters(PunchState state) async {
    final result = await showModalBottomSheet<PunchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PunchFiltersSheet(state: state),
    );
    if (result != null) {
      await ref.read(punchControllerProvider.notifier).applyFilters(result);
    }
  }

  void _applySearch(String value) {
    if (!mounted) return;
    final current = ref.read(punchControllerProvider).value;
    if (current == null || current.filters.searchText == value.trim()) return;
    ref
        .read(punchControllerProvider.notifier)
        .applyFilters(current.filters.copyWith(searchText: value));
  }

  Future<void> _add(PunchState state) async {
    final project = state.project;
    if (project == null) return;
    final projectPath = Uri.encodeComponent(project.id);
    final saved = await context.push<bool>(
      _tabs.index == 0
          ? '/projects/$projectPath/punch/defects/new'
          : '/projects/$projectPath/punch/protocols/new',
    );
    if (saved == true) {
      await ref.read(punchControllerProvider.notifier).refresh();
    }
  }

  void _tabChanged() {
    if (!_tabs.indexIsChanging && mounted) setState(() {});
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
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

class _DefectTile extends StatelessWidget {
  const _DefectTile({
    required this.defect,
    required this.stageLabel,
    required this.contactLabel,
    required this.onTap,
  });

  final DefectRecord defect;
  final String? stageLabel;
  final String? contactLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overdue = defect.isOverdue(DateTime.now());
    final metadata = <String>[
      defectStatusLabel(l10n, defect.status),
      defectSeverityLabel(l10n, defect.severity),
      ?stageLabel,
      ?defect.roomLabel,
      ?contactLabel,
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        minTileHeight: 84,
        leading: Icon(
          defect.isClosed
              ? Icons.check_circle_outline
              : overdue
              ? Icons.event_busy_outlined
              : Icons.report_problem_outlined,
          color: defect.severity == DefectSeverity.critical || overdue
              ? Theme.of(context).colorScheme.error
              : null,
        ),
        title: Text(defect.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metadata.join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (defect.dueAtUtc != null)
              Text(
                '${l10n.defectDueAtLabel}: '
                '${DateFormat('dd.MM.yyyy', 'pl_PL').format(defect.dueAtUtc!.toLocal())}',
                style: overdue
                    ? TextStyle(color: Theme.of(context).colorScheme.error)
                    : null,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more_rounded),
        label: Text(AppLocalizations.of(context).punchLoadMore),
      ),
    );
  }
}

class _PunchFiltersSheet extends StatefulWidget {
  const _PunchFiltersSheet({required this.state});

  final PunchState state;

  @override
  State<_PunchFiltersSheet> createState() => _PunchFiltersSheetState();
}

class _PunchFiltersSheetState extends State<_PunchFiltersSheet> {
  late final Set<JournalEntryStatus> _statuses = Set.of(
    widget.state.filters.statuses,
  );
  late final Set<DefectSeverity> _severities = Set.of(
    widget.state.filters.severities,
  );
  late String? _stageId = widget.state.filters.stageId;
  late String? _contactId = widget.state.filters.responsibleContactId;
  late bool _overdueOnly = widget.state.filters.overdueOnly;
  late final TextEditingController _room = TextEditingController(
    text: widget.state.filters.roomLabel,
  );

  @override
  void dispose() {
    _room.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statuses = allowedStatusesFor(
      JournalEntryType.defect,
    ).where((status) => status != JournalEntryStatus.draft);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.punchFiltersTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cancelAction,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text(
                    l10n.punchStatusLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  ...statuses.map(
                    (status) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: _statuses.contains(status),
                      title: Text(defectStatusLabel(l10n, status)),
                      onChanged: (selected) => setState(() {
                        selected == true
                            ? _statuses.add(status)
                            : _statuses.remove(status);
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.punchSeverityLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Wrap(
                    spacing: 8,
                    children: DefectSeverity.values
                        .map(
                          (severity) => FilterChip(
                            selected: _severities.contains(severity),
                            label: Text(defectSeverityLabel(l10n, severity)),
                            onSelected: (selected) => setState(() {
                              selected
                                  ? _severities.add(severity)
                                  : _severities.remove(severity);
                            }),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _stageId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.defectStageLabel,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.punchAllStages),
                      ),
                      ...widget.state.stages.map(
                        (stage) => DropdownMenuItem<String?>(
                          value: stage.id,
                          child: Text(stageName(l10n, stage)),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _stageId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _contactId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.defectResponsibleLabel,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.punchAllContacts),
                      ),
                      ...widget.state.contacts.map(
                        (contact) => DropdownMenuItem<String?>(
                          value: contact.id,
                          child: Text(contact.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _contactId = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _room,
                    decoration: InputDecoration(
                      labelText: l10n.punchRoomFilterLabel,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _overdueOnly,
                    title: Text(l10n.punchOverdueOnly),
                    onChanged: (value) => setState(() => _overdueOnly = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(
                        PunchFilters(
                          searchText: widget.state.filters.searchText,
                        ),
                      ),
                      child: Text(l10n.punchClearFilters),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('applyPunchFilters'),
                      onPressed: () => Navigator.of(context).pop(
                        PunchFilters(
                          searchText: widget.state.filters.searchText,
                          statuses: _statuses,
                          severities: _severities,
                          stageId: _stageId,
                          responsibleContactId: _contactId,
                          roomLabel: _room.text,
                          overdueOnly: _overdueOnly,
                        ),
                      ),
                      child: Text(l10n.punchApplyFilters),
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

String? _stageLabel(
  BuildContext context,
  Iterable<ProjectStage> stages,
  String? id,
) {
  if (id == null) return null;
  for (final stage in stages) {
    if (stage.id == id) return stageName(AppLocalizations.of(context), stage);
  }
  return null;
}

String? _contactLabel(Iterable<Contact> contacts, String? id) {
  if (id == null) return null;
  for (final contact in contacts) {
    if (contact.id == id) return contact.displayName;
  }
  return null;
}
