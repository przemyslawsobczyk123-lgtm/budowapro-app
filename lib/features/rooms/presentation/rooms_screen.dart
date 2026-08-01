import 'dart:async';

import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/presentation/room_ui_text.dart';
import 'package:budowapro/features/rooms/presentation/rooms_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(roomsControllerProvider);
    final projectId = state.value?.project?.id;
    return Scaffold(
      key: const ValueKey('roomsScreen'),
      appBar: AppBar(
        title: Text(l10n.roomsTitle),
        actions: [
          IconButton(
            key: const ValueKey('roomAddButton'),
            tooltip: l10n.roomsAddTooltip,
            onPressed: projectId == null ? null : () => _addRoom(projectId),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: state.when(
        loading: () => AppLoadingState(label: l10n.roomsLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.roomsLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.read(roomsControllerProvider.notifier).refresh(),
        ),
        data: _body,
      ),
    );
  }

  Widget _body(RoomsState state) {
    final l10n = AppLocalizations.of(context);
    final project = state.project;
    if (project == null) {
      return AppEmptyState(
        icon: Icons.home_work_outlined,
        title: l10n.roomsNoProjectTitle,
        message: l10n.roomsNoProjectMessage,
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(roomsControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _summary(state)),
          SliverToBoxAdapter(child: _searchField()),
          if (state.rooms.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: Icons.meeting_room_outlined,
                title: l10n.roomsEmptyTitle,
                message: l10n.roomsEmptyMessage,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              sliver: SliverList.separated(
                itemCount: state.rooms.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == state.rooms.length) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: state.isLoadingMore
                            ? null
                            : () => ref
                                  .read(roomsControllerProvider.notifier)
                                  .loadMore(),
                        icon: state.isLoadingMore
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more_rounded),
                        label: Text(l10n.roomsLoadMore),
                      ),
                    );
                  }
                  final overview = state.rooms[index];
                  return _RoomTile(
                    overview: overview,
                    currencyCode: project.currencyCode,
                    onTap: () => _openRoom(project.id, overview.room.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _summary(RoomsState state) {
    final l10n = AppLocalizations.of(context);
    final summary = state.summary;
    final currency = state.project!.currencyCode;
    if (summary == null) return const SizedBox.shrink();
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _SummaryValue(
              label: l10n.roomsRoomCount(summary.roomCount),
              value: '${summary.roomCount}',
            ),
            _SummaryValue(
              label: l10n.roomsPlannedTotal,
              value: formatMoneyForDisplay(summary.plannedBudget, currency),
            ),
            _SummaryValue(
              label: l10n.roomsActualTotal,
              value: formatMoneyForDisplay(summary.actualCost, currency),
            ),
            _SummaryValue(
              label: l10n.roomsOpenChoices,
              value: '${summary.openChoiceCount}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        key: const ValueKey('roomSearchField'),
        controller: _search,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.roomsSearchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.roomsClearSearch,
                  onPressed: () {
                    _search.clear();
                    setState(() {});
                    ref.read(roomsControllerProvider.notifier).search('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        onSubmitted: (value) =>
            ref.read(roomsControllerProvider.notifier).search(value),
        onChanged: (value) {
          setState(() {});
          _debounce?.cancel();
          _debounce = Timer(
            const Duration(milliseconds: 300),
            () => ref.read(roomsControllerProvider.notifier).search(value),
          );
        },
      ),
    );
  }

  Future<void> _addRoom(String projectId) async {
    await context.push('/projects/${Uri.encodeComponent(projectId)}/rooms/new');
    if (mounted) await ref.read(roomsControllerProvider.notifier).refresh();
  }

  Future<void> _openRoom(String projectId, String roomId) async {
    await context.push(
      '/projects/${Uri.encodeComponent(projectId)}'
      '/rooms/${Uri.encodeComponent(roomId)}',
    );
    if (mounted) await ref.read(roomsControllerProvider.notifier).refresh();
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.overview,
    required this.currencyCode,
    required this.onTap,
  });

  final RoomOverview overview;
  final String currencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final room = overview.room;
    final budget = room.plannedBudget;
    return Card(
      key: ValueKey('roomTile-${room.id}'),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                          room.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          <String>[
                            if (room.floorLabel != null) room.floorLabel!,
                            roomStandardLabel(l10n, room.standard),
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _TileMetric(
                    label: l10n.roomBudgetPlanned,
                    value: budget == null
                        ? l10n.roomNoBudget
                        : formatMoneyForDisplay(budget, currencyCode),
                  ),
                  _TileMetric(
                    label: l10n.roomBudgetActual,
                    value: formatMoneyForDisplay(
                      overview.actualCost,
                      currencyCode,
                    ),
                  ),
                  _TileMetric(
                    label: l10n.roomsOpenChoices,
                    value: '${overview.openChoiceCount}',
                  ),
                  if (overview.openDefectCount > 0)
                    _TileMetric(
                      label: l10n.roomRelatedDefects,
                      value: '${overview.openDefectCount}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileMetric extends StatelessWidget {
  const _TileMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 92, maxWidth: 170),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
