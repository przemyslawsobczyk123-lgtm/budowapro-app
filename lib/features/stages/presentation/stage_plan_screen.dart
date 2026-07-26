import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/features/stages/domain/stage_guidance.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_editor_dialogs.dart';
import 'package:budowapro/features/stages/presentation/stage_guidance_sheet.dart';
import 'package:budowapro/features/stages/presentation/stage_guidance_ui_text.dart';
import 'package:budowapro/features/stages/presentation/stage_plan_controller.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StagePlanScreen extends ConsumerStatefulWidget {
  const StagePlanScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  ConsumerState<StagePlanScreen> createState() => _StagePlanScreenState();
}

class _StagePlanScreenState extends ConsumerState<StagePlanScreen> {
  bool _bulkMode = false;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(stagePlanControllerProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const ValueKey<String>('stage-plan-screen'),
      body: SafeArea(
        top: false,
        child: plan.when(
          loading: () => AppLoadingState(label: l10n.stagePlanLoading),
          error: (error, stackTrace) => AppErrorState(
            title: l10n.stagePlanLoadError,
            retryLabel: l10n.retryAction,
            onRetry: () =>
                ref.read(stagePlanControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            if (state.project == null) {
              return AppEmptyState(
                icon: Icons.account_tree_outlined,
                title: l10n.stagePlanNoProjectTitle,
                message: l10n.stagePlanNoProjectMessage,
                actionLabel: l10n.projectCreateAction,
                onAction: () => context.push('/projects/new'),
              );
            }
            return _StagePlanContent(
              state: state,
              showHeader: !widget.embedded,
              onBulkModeChanged: _setBulkMode,
            );
          },
        ),
      ),
      floatingActionButton: _bulkMode || plan.value?.selectedStage == null
          ? null
          : FloatingActionButton.extended(
              onPressed: plan.value!.isSaving
                  ? null
                  : () => _addChecklistItem(context, ref),
              icon: const Icon(Icons.playlist_add_rounded),
              label: Text(l10n.checklistAddAction),
            ),
    );
  }

  void _setBulkMode(bool enabled) {
    if (mounted && _bulkMode != enabled) {
      setState(() => _bulkMode = enabled);
    }
  }
}

class _StagePlanContent extends ConsumerStatefulWidget {
  const _StagePlanContent({
    required this.state,
    required this.showHeader,
    required this.onBulkModeChanged,
  });

  final StagePlanState state;
  final bool showHeader;
  final ValueChanged<bool> onBulkModeChanged;

  @override
  ConsumerState<_StagePlanContent> createState() => _StagePlanContentState();
}

class _StagePlanContentState extends ConsumerState<_StagePlanContent> {
  bool _bulkMode = false;
  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onBulkModeChanged(false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _StagePlanContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedStageId != widget.state.selectedStageId) {
      final wasBulkMode = _bulkMode;
      _bulkMode = false;
      _selectedIds.clear();
      if (wasBulkMode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onBulkModeChanged(false);
          }
        });
      }
    } else {
      final visibleIds = widget.state.checklistItems
          .map((item) => item.id)
          .toSet();
      _selectedIds.removeWhere((id) => !visibleIds.contains(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final showHeader = widget.showHeader;
    final l10n = AppLocalizations.of(context);
    final selectedStage = state.selectedStage;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (showHeader)
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.stagePlanEyebrow,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(l10n.planTitle),
                    ],
                  ),
                  actions: _stageActions(context, ref, l10n),
                  bottom: state.isSaving
                      ? const PreferredSize(
                          preferredSize: Size.fromHeight(2),
                          child: LinearProgressIndicator(minHeight: 2),
                        )
                      : null,
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.stagePlanEyebrow,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        ..._stageActions(context, ref, l10n),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: _StageTabs(state: state)),
              if (selectedStage != null)
                SliverToBoxAdapter(
                  child: _StageOverview(
                    stage: selectedStage,
                    state: state,
                    onEdit: () => _editStage(context, ref, state),
                    onRename: () => _renameStage(context, ref, selectedStage),
                  ),
                ),
              if (selectedStage != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  sliver: SliverToBoxAdapter(
                    child: _StageGuidancePanel(
                      stage: selectedStage,
                      checklistItems: state.checklistItems,
                      enabled: !state.isSaving,
                      onAddOwn: () => _addChecklistItem(context, ref),
                      onOpenChecklistItem: (item) =>
                          _editChecklistItem(context, ref, state, item),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: _ChecklistHeader(
                    selectionMode: _bulkMode,
                    selectedCount: _selectedIds.length,
                    enabled: !state.isSaving && state.checklistItems.isNotEmpty,
                    onStartSelection: _startBulkSelection,
                    onSelectAll: () => _selectAll(state.checklistItems),
                    onCancel: _cancelBulkSelection,
                  ),
                ),
              ),
              if (state.checklistItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: Icons.checklist_rounded,
                    title: l10n.stageNoChecklistTitle,
                    message: l10n.stageNoChecklistMessage,
                    actionLabel: l10n.checklistAddAction,
                    onAction: () => _addChecklistItem(context, ref),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 104),
                  sliver: SliverList.separated(
                    itemCount: state.checklistItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = state.checklistItems[index];
                      return _ChecklistRow(
                        key: ValueKey<String>(
                          'checklist-item-${item.templateKey?.name ?? item.id}',
                        ),
                        item: item,
                        enabled: !state.isSaving,
                        selectionMode: _bulkMode,
                        selected: _selectedIds.contains(item.id),
                        onSelected: (selected) =>
                            _selectItem(item.id, selected),
                        onTap: () =>
                            _editChecklistItem(context, ref, state, item),
                        onOpenEvidence: item.evidenceIds.isEmpty
                            ? null
                            : () async {
                                final changed = await _openChecklistEvidence(
                                  context,
                                  projectId: state.project!.id,
                                  evidenceIds: item.evidenceIds,
                                );
                                if (changed && context.mounted) {
                                  await ref
                                      .read(
                                        stagePlanControllerProvider.notifier,
                                      )
                                      .refresh();
                                }
                              },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        if (_bulkMode && _selectedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SafeArea(
              top: false,
              child: Material(
                elevation: 3,
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.checklistBulkSelectedCount(_selectedIds.length),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: state.isSaving
                              ? null
                              : () => _completeSelected(state),
                          child: Text(
                            l10n.checklistBulkCompleteAction,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _startBulkSelection() {
    setState(() {
      _bulkMode = true;
      _selectedIds.clear();
    });
    widget.onBulkModeChanged(true);
  }

  void _cancelBulkSelection() {
    setState(() {
      _bulkMode = false;
      _selectedIds.clear();
    });
    widget.onBulkModeChanged(false);
  }

  void _selectItem(String itemId, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(itemId);
      } else {
        _selectedIds.remove(itemId);
      }
    });
  }

  void _selectAll(List<ChecklistItem> items) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(
          items
              .where(
                (item) =>
                    item.status != ChecklistStatus.completed &&
                    item.status != ChecklistStatus.skipped,
              )
              .map((item) => item.id),
        );
    });
  }

  Future<void> _completeSelected(StagePlanState state) async {
    final l10n = AppLocalizations.of(context);
    final selectedItems = state.checklistItems
        .where((item) => _selectedIds.contains(item.id))
        .toList(growable: false);
    final completable = selectedItems
        .where(
          (item) =>
              item.evidenceRequirement == EvidenceRequirement.none ||
              item.hasEvidence ||
              item.hasEvidenceWaiver,
        )
        .toList(growable: false);
    final pendingCount = selectedItems.length - completable.length;
    if (completable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checklistBulkOnlyEvidencePendingMessage)),
      );
      return;
    }

    await ref
        .read(stagePlanControllerProvider.notifier)
        .completeChecklistItems(completable.map((item) => item.id));
    if (!mounted) return;
    setState(() {
      _bulkMode = false;
      _selectedIds.clear();
    });
    widget.onBulkModeChanged(false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pendingCount == 0
              ? l10n.checklistBulkCompletedMessage(completable.length)
              : l10n.checklistBulkEvidencePendingMessage(
                  completable.length,
                  pendingCount,
                ),
        ),
      ),
    );
  }

  List<Widget> _stageActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final state = widget.state;
    return <Widget>[
      IconButton(
        tooltip: l10n.stageAddAction,
        onPressed: state.isSaving ? null : () => _addStage(context, ref),
        icon: const Icon(Icons.add_rounded),
      ),
      IconButton(
        tooltip: l10n.stageReorderAction,
        onPressed: state.isSaving || state.stages.length < 2
            ? null
            : () => _reorderStages(context, ref, state),
        icon: const Icon(Icons.swap_vert_rounded),
      ),
    ];
  }
}

class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({
    required this.selectionMode,
    required this.selectedCount,
    required this.enabled,
    required this.onStartSelection,
    required this.onSelectAll,
    required this.onCancel,
  });

  final bool selectionMode;
  final int selectedCount;
  final bool enabled;
  final VoidCallback onStartSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (selectionMode) {
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.checklistBulkSelectedCount(selectedCount),
              style: theme.textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: l10n.checklistBulkSelectAllAction,
            onPressed: enabled ? onSelectAll : null,
            icon: const Icon(Icons.select_all_rounded),
          ),
          IconButton(
            tooltip: l10n.checklistBulkCancelAction,
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(l10n.checklistHeading, style: theme.textTheme.titleLarge),
        TextButton.icon(
          key: const ValueKey<String>('checklist-bulk-toggle'),
          onPressed: enabled ? onStartSelection : null,
          icon: const Icon(Icons.library_add_check_outlined),
          label: Text(l10n.checklistBulkSelectAction),
        ),
      ],
    );
  }
}

class _StageGuidancePanel extends StatelessWidget {
  const _StageGuidancePanel({
    required this.stage,
    required this.checklistItems,
    required this.enabled,
    required this.onAddOwn,
    required this.onOpenChecklistItem,
  });

  final ProjectStage stage;
  final List<ChecklistItem> checklistItems;
  final bool enabled;
  final VoidCallback onAddOwn;
  final Future<void> Function(ChecklistItem item) onOpenChecklistItem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final guidance = StageGuidanceCatalog.forStage(stage.templateKey);
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: ValueKey<String>('stage-guidance-${stage.id}'),
        initiallyExpanded: false,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: const Icon(Icons.lightbulb_outline_rounded),
        title: Text(
          l10n.stageGuidanceHeading,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: guidance.isEmpty
            ? null
            : Text(l10n.stageGuidanceCount(guidance.length)),
        children: [
          const Divider(height: 1),
          if (guidance.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l10n.stageGuidanceEmpty),
            )
          else
            for (final entry in guidance) ...[
              _StageGuidanceRow(
                guidance: entry,
                checklistItems: checklistItems,
                onOpenChecklistItem: onOpenChecklistItem,
              ),
              if (entry != guidance.last) const Divider(height: 1, indent: 56),
            ],
          ListTile(
            leading: const Icon(Icons.playlist_add_rounded),
            title: Text(l10n.stageGuidanceAddOwnAction),
            enabled: enabled,
            onTap: enabled ? onAddOwn : null,
          ),
        ],
      ),
    );
  }
}

class _StageGuidanceRow extends StatelessWidget {
  const _StageGuidanceRow({
    required this.guidance,
    required this.checklistItems,
    required this.onOpenChecklistItem,
  });

  final StageGuidanceDefinition guidance;
  final List<ChecklistItem> checklistItems;
  final Future<void> Function(ChecklistItem item) onOpenChecklistItem;

  @override
  Widget build(BuildContext context) {
    final content = stageGuidanceContent(
      AppLocalizations.of(context),
      guidance.key,
    );
    final relatedItems = checklistItems
        .where(
          (item) =>
              item.templateKey != null &&
              guidance.relatedChecklistKeys.contains(item.templateKey),
        )
        .toList(growable: false);
    return ListTile(
      key: ValueKey<String>('guidance-${guidance.key.name}'),
      minLeadingWidth: 32,
      leading: Icon(_guidanceIcon(guidance.key)),
      title: Text(content.title),
      subtitle: Text(
        content.timing,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () async {
        final selectedItemId = await showStageGuidanceSheet(
          context,
          guidance: guidance,
          relatedItems: relatedItems,
        );
        if (!context.mounted || selectedItemId == null) return;
        ChecklistItem? selectedItem;
        for (final item in relatedItems) {
          if (item.id == selectedItemId) {
            selectedItem = item;
            break;
          }
        }
        if (selectedItem != null) await onOpenChecklistItem(selectedItem);
      },
    );
  }
}

class _StageTabs extends ConsumerWidget {
  const _StageTabs({required this.state});

  final StagePlanState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: state.stages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final stage = state.stages[index];
          final selected = stage.id == state.selectedStageId;
          return ChoiceChip(
            key: ValueKey<String>('stage-tab-${stage.id}'),
            selected: selected,
            showCheckmark: stage.status == StageStatus.completed,
            avatar: stage.status == StageStatus.blocked
                ? const Icon(Icons.block_rounded, size: 16)
                : null,
            label: Text(stageName(l10n, stage)),
            onSelected: state.isSaving || selected
                ? null
                : (_) => ref
                      .read(stagePlanControllerProvider.notifier)
                      .selectStage(stage.id),
          );
        },
      ),
    );
  }
}

class _StageOverview extends StatelessWidget {
  const _StageOverview({
    required this.stage,
    required this.state,
    required this.onEdit,
    required this.onRename,
  });

  final ProjectStage stage;
  final StagePlanState state;
  final VoidCallback onEdit;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = stage.progress;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border.symmetric(
          horizontal: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stageName(l10n, stage),
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(stageStatusLabel(l10n, stage.status)),
                    ],
                  ),
                ),
                PopupMenuButton<_StageMenuAction>(
                  enabled: !state.isSaving,
                  tooltip: l10n.stageEditAction,
                  onSelected: (action) => switch (action) {
                    _StageMenuAction.edit => onEdit(),
                    _StageMenuAction.rename => onRename(),
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<_StageMenuAction>(
                      value: _StageMenuAction.edit,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.edit_calendar_outlined),
                        title: Text(l10n.stageEditAction),
                      ),
                    ),
                    PopupMenuItem<_StageMenuAction>(
                      value: _StageMenuAction.rename,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.drive_file_rename_outline),
                        title: Text(l10n.stageRenameAction),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.stageProgressLabel(
                      progress.resolvedItems,
                      progress.totalItems,
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text('${progress.percent}%'),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              label: l10n.stageProgressPercent(progress.percent),
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _StageMeta(
                  icon: Icons.calendar_today_outlined,
                  label: _dateRange(l10n, state, stage),
                ),
                _StageMeta(
                  icon: Icons.account_balance_wallet_outlined,
                  label: formatProjectBudget(
                    l10n,
                    stage.plannedBudgetMinorUnits,
                    state.project!.currencyCode,
                  ),
                ),
                if (progress.blockedItems > 0)
                  _StageMeta(
                    icon: Icons.block_rounded,
                    label: l10n.stageBlockedCount(progress.blockedItems),
                    isWarning: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageMeta extends StatelessWidget {
  const _StageMeta({
    required this.icon,
    required this.label,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isWarning ? colors.error : colors.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.item,
    required this.enabled,
    required this.selectionMode,
    required this.selected,
    required this.onSelected,
    required this.onTap,
    required this.onOpenEvidence,
    super.key,
  });

  final ChecklistItem item;
  final bool enabled;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onTap;
  final VoidCallback? onOpenEvidence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final risk = checklistRisk(l10n, item);
    final statusColor = _statusColor(theme.colorScheme, item.status);
    final selectable =
        item.status != ChecklistStatus.completed &&
        item.status != ChecklistStatus.skipped;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: !enabled
            ? null
            : selectionMode
            ? selectable
                  ? () => onSelected(!selected)
                  : null
            : onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 40,
                child: selectionMode
                    ? Checkbox(
                        value: selected,
                        onChanged: enabled && selectable
                            ? (value) => onSelected(value ?? false)
                            : null,
                      )
                    : Icon(
                        _statusIcon(item.status),
                        color: statusColor,
                        semanticLabel: checklistStatusLabel(l10n, item.status),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checklistTitle(l10n, item),
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: item.status == ChecklistStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (risk.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        risk,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _ChecklistTag(
                          icon: item.importance == ChecklistImportance.critical
                              ? Icons.priority_high_rounded
                              : Icons.flag_outlined,
                          label: checklistImportanceLabel(
                            l10n,
                            item.importance,
                          ),
                          emphasized:
                              item.importance == ChecklistImportance.critical,
                        ),
                        if (item.evidenceRequirement !=
                            EvidenceRequirement.none)
                          _ChecklistTag(
                            icon:
                                item.evidenceRequirement ==
                                    EvidenceRequirement.photo
                                ? Icons.photo_camera_outlined
                                : Icons.attach_file_rounded,
                            label: item.hasEvidenceWaiver
                                ? l10n.checklistEvidenceWaived
                                : l10n.checklistEvidenceCount(
                                    item.evidenceIds.length,
                                  ),
                            emphasized:
                                !item.hasEvidence && !item.hasEvidenceWaiver,
                            tooltip: onOpenEvidence == null
                                ? null
                                : l10n.checklistOpenEvidenceAction,
                            onTap: enabled ? onOpenEvidence : null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (!selectionMode)
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistTag extends StatelessWidget {
  const _ChecklistTag({
    required this.icon,
    required this.label,
    required this.emphasized,
    this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool emphasized;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = emphasized ? colors.error : colors.onSurfaceVariant;
    final background = emphasized
        ? colors.errorContainer
        : colors.surfaceContainerHighest;
    final tag = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return tag;
    return Tooltip(
      message: tooltip ?? label,
      child: Semantics(
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: tag,
        ),
      ),
    );
  }
}

enum _StageMenuAction { edit, rename }

enum _EvidenceAction { attach, waive }

Future<void> _addStage(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final name = await showStageNameDialog(context, title: l10n.stageAddTitle);
  if (name == null || !context.mounted) return;
  await _runMutation(
    context,
    () => ref.read(stagePlanControllerProvider.notifier).addStage(name),
  );
}

Future<void> _renameStage(
  BuildContext context,
  WidgetRef ref,
  ProjectStage stage,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await showStageNameDialog(
    context,
    title: l10n.stageRenameTitle,
    initialValue: stageName(l10n, stage),
  );
  if (name == null || !context.mounted) return;
  await _runMutation(
    context,
    () => ref
        .read(stagePlanControllerProvider.notifier)
        .renameStage(stage.id, name),
  );
}

Future<void> _reorderStages(
  BuildContext context,
  WidgetRef ref,
  StagePlanState state,
) async {
  final ids = await showStageReorderSheet(context, stages: state.stages);
  if (ids == null || !context.mounted) return;
  await _runMutation(
    context,
    () => ref.read(stagePlanControllerProvider.notifier).reorderStages(ids),
  );
}

Future<void> _editStage(
  BuildContext context,
  WidgetRef ref,
  StagePlanState state,
) async {
  final stage = state.selectedStage;
  if (stage == null) return;
  final input = await showStageEditorSheet(
    context,
    project: state.project!,
    stage: stage,
  );
  if (input == null || !context.mounted) return;
  await _runMutation(
    context,
    () => ref
        .read(stagePlanControllerProvider.notifier)
        .updateStage(stage.id, input),
  );
}

Future<void> _addChecklistItem(BuildContext context, WidgetRef ref) async {
  final result = await showAddChecklistDialog(context);
  if (result == null || !context.mounted) return;
  await _runMutation(
    context,
    () => ref
        .read(stagePlanControllerProvider.notifier)
        .addChecklistItem(title: result.title, input: result.details),
  );
}

Future<void> _editChecklistItem(
  BuildContext context,
  WidgetRef ref,
  StagePlanState state,
  ChecklistItem item,
) async {
  final input = await showChecklistEditorSheet(
    context,
    project: state.project!,
    item: item,
  );
  if (input == null || !context.mounted) return;
  try {
    await ref
        .read(stagePlanControllerProvider.notifier)
        .updateChecklistItem(item.id, input);
  } on ChecklistEvidenceRequiredException {
    if (!context.mounted) return;
    await _resolveRequiredEvidence(context, ref, item, input);
  } on Object {
    if (context.mounted) _showMutationError(context);
  }
}

Future<bool> _openChecklistEvidence(
  BuildContext context, {
  required String projectId,
  required List<String> evidenceIds,
}) async {
  String? documentId;
  if (evidenceIds.length == 1) {
    documentId = evidenceIds.single;
  } else {
    final l10n = AppLocalizations.of(context);
    documentId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (context) => ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: evidenceIds.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.checklistEvidenceItemLabel(index + 1)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.pop(context, evidenceIds[index]),
        ),
      ),
    );
  }
  if (documentId == null || !context.mounted) return false;
  return await context.push<bool>(
        '/projects/${Uri.encodeComponent(projectId)}'
        '/documents/${Uri.encodeComponent(documentId)}',
      ) ??
      false;
}

Future<void> _resolveRequiredEvidence(
  BuildContext context,
  WidgetRef ref,
  ChecklistItem item,
  ChecklistItemDetailsInput input,
) async {
  final l10n = AppLocalizations.of(context);
  final action = await showDialog<_EvidenceAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.checklistEvidenceRequiredTitle),
      content: Text(l10n.checklistEvidenceRequiredMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context, _EvidenceAction.waive),
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l10n.checklistWaiveEvidenceAction),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, _EvidenceAction.attach),
          icon: const Icon(Icons.attach_file_rounded),
          label: Text(l10n.checklistAddEvidenceAction),
        ),
      ],
    ),
  );
  if (action == null || !context.mounted) return;
  final controller = ref.read(stagePlanControllerProvider.notifier);
  try {
    switch (action) {
      case _EvidenceAction.attach:
        final attached = await controller.attachEvidence(item.id);
        if (attached) await controller.updateChecklistItem(item.id, input);
      case _EvidenceAction.waive:
        final comment = await showEvidenceWaiverDialog(context);
        if (comment == null || !context.mounted) return;
        await controller.updateChecklistItem(
          item.id,
          _withWaiver(input, comment),
        );
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checklistEvidenceImportError)),
      );
    }
  }
}

ChecklistItemDetailsInput _withWaiver(
  ChecklistItemDetailsInput input,
  String comment,
) {
  return ChecklistItemDetailsInput(
    status: input.status,
    importance: input.importance,
    evidenceRequirement: input.evidenceRequirement,
    dueDate: input.dueDate,
    assignee: input.assignee,
    note: input.note,
    riskIfSkipped: input.riskIfSkipped,
    statusReason: input.statusReason,
    evidenceWaiverComment: comment,
  );
}

Future<void> _runMutation(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } on Object {
    if (context.mounted) _showMutationError(context);
  }
}

void _showMutationError(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.stageMutationError)));
}

String _dateRange(
  AppLocalizations l10n,
  StagePlanState state,
  ProjectStage stage,
) {
  final start = stage.plannedStart;
  final end = stage.plannedEnd;
  if (start == null && end == null) return l10n.projectValueNotProvided;
  final startLabel = start == null
      ? l10n.projectValueNotProvided
      : formatProjectDate(start, state.project!.dateFormat);
  final endLabel = end == null
      ? l10n.projectValueNotProvided
      : formatProjectDate(end, state.project!.dateFormat);
  return '$startLabel - $endLabel';
}

IconData _statusIcon(ChecklistStatus status) => switch (status) {
  ChecklistStatus.todo => Icons.radio_button_unchecked_rounded,
  ChecklistStatus.inProgress => Icons.pending_outlined,
  ChecklistStatus.blocked => Icons.block_rounded,
  ChecklistStatus.completed => Icons.check_circle_rounded,
  ChecklistStatus.skipped => Icons.skip_next_rounded,
};

Color _statusColor(ColorScheme colors, ChecklistStatus status) =>
    switch (status) {
      ChecklistStatus.todo => colors.onSurfaceVariant,
      ChecklistStatus.inProgress => colors.secondary,
      ChecklistStatus.blocked => colors.error,
      ChecklistStatus.completed => colors.primary,
      ChecklistStatus.skipped => colors.outline,
    };

IconData _guidanceIcon(StageGuidanceKey key) => switch (key) {
  StageGuidanceKey.planningAndGroundConditions => Icons.map_outlined,
  StageGuidanceKey.designUtilitiesAndApprovals => Icons.draw_outlined,
  StageGuidanceKey.legalConstructionStart => Icons.gavel_outlined,
  StageGuidanceKey.siteLogisticsAndAccess => Icons.local_shipping_outlined,
  StageGuidanceKey.temporaryUtilitiesAndFacilities =>
    Icons.electrical_services_outlined,
  StageGuidanceKey.siteSafetyAndEvidence => Icons.health_and_safety_outlined,
  StageGuidanceKey.servicePenetrations => Icons.cable_rounded,
  StageGuidanceKey.foundationGrounding => Icons.electric_bolt_rounded,
  StageGuidanceKey.foundationWaterproofing => Icons.water_drop_outlined,
  StageGuidanceKey.drainageAndGroundLevels => Icons.landscape_outlined,
  StageGuidanceKey.concealedWorksEvidence => Icons.photo_camera_outlined,
  StageGuidanceKey.structuralShellChecks => Icons.foundation_outlined,
  StageGuidanceKey.roofAndWeatherProtection => Icons.roofing_outlined,
  StageGuidanceKey.windowShadingPreparation => Icons.window_rounded,
  StageGuidanceKey.windowDoorInstallation => Icons.door_front_door_outlined,
  StageGuidanceKey.closedShellMoistureControl => Icons.air_outlined,
  StageGuidanceKey.installationRoutesAndAccess => Icons.account_tree_outlined,
  StageGuidanceKey.installationTestsAndEvidence => Icons.fact_check_outlined,
  StageGuidanceKey.finishSubstratesAndHeating => Icons.layers_outlined,
  StageGuidanceKey.wetAreaWaterproofing => Icons.shower_outlined,
};
