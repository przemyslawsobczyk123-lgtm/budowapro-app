import 'dart:async';

import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/presentation/material_ui_text.dart';
import 'package:budowapro/features/materials/presentation/materials_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
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
    final state = ref.watch(materialsControllerProvider);
    final projectId = state.value?.project?.id;
    return Scaffold(
      key: const ValueKey('materialsScreen'),
      appBar: AppBar(
        title: Text(l10n.materialsTitle),
        actions: [
          IconButton(
            key: const ValueKey('materialAddButton'),
            tooltip: l10n.materialsAddTooltip,
            onPressed: projectId == null ? null : () => _add(projectId),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: state.when(
        loading: () => AppLoadingState(label: l10n.materialsLoading),
        error: (_, _) => AppErrorState(
          title: l10n.materialsLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () =>
              ref.read(materialsControllerProvider.notifier).refresh(),
        ),
        data: _body,
      ),
    );
  }

  Widget _body(MaterialsState state) {
    final l10n = AppLocalizations.of(context);
    final project = state.project;
    if (project == null) {
      return AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.materialsNoProjectTitle,
        message: l10n.materialsNoProjectMessage,
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(materialsControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _summary(state)),
          SliverToBoxAdapter(child: _searchAndFilters(state)),
          if (state.materials.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: state.searchText.isEmpty && state.statuses.isEmpty
                    ? l10n.materialsEmptyTitle
                    : l10n.materialsNoResultsTitle,
                message: state.searchText.isEmpty && state.statuses.isEmpty
                    ? l10n.materialsEmptyMessage
                    : l10n.materialsNoResultsMessage,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
              sliver: SliverList.separated(
                itemCount: state.materials.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == state.materials.length) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: state.isLoadingMore
                            ? null
                            : ref
                                  .read(materialsControllerProvider.notifier)
                                  .loadMore,
                        icon: state.isLoadingMore
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more_rounded),
                        label: Text(l10n.materialsLoadMore),
                      ),
                    );
                  }
                  final material = state.materials[index];
                  return _MaterialTile(
                    material: material,
                    currencyCode: project.currencyCode,
                    now: DateTime.now(),
                    onTap: () => _open(project.id, material.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _summary(MaterialsState state) {
    final summary = state.summary;
    if (summary == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final currency = state.project!.currencyCode;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            _SummaryValue(
              label: l10n.materialsOrderedValue,
              value: formatMoneyForDisplay(summary.orderedValue, currency),
            ),
            _SummaryValue(
              label: l10n.materialsExpectedReturns,
              value: formatMoneyForDisplay(
                summary.expectedReturnValue,
                currency,
              ),
            ),
            _SummaryValue(
              label: l10n.materialsDelayedCount,
              value: '${summary.delayedCount}',
              emphasize: summary.delayedCount > 0,
            ),
            _SummaryValue(
              label: l10n.materialsOverdueReturns,
              value: '${summary.overdueReturnCount}',
              emphasize: summary.overdueReturnCount > 0,
            ),
            _SummaryValue(
              label: l10n.materialsOpenDeliveries,
              value: '${summary.openDeliveryCount}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchAndFilters(MaterialsState state) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('materialSearchField'),
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.materialsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.materialsClearSearch,
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                        ref
                            .read(materialsControllerProvider.notifier)
                            .search('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
            onSubmitted: ref.read(materialsControllerProvider.notifier).search,
            onChanged: (value) {
              setState(() {});
              _debounce?.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 300),
                () => ref
                    .read(materialsControllerProvider.notifier)
                    .search(value),
              );
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MaterialStatus.values
                  .map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: ValueKey('materialStatusFilter-${status.name}'),
                        label: Text(materialStatusLabel(l10n, status)),
                        selected: state.statuses.contains(status),
                        onSelected: (selected) {
                          final next = Set<MaterialStatus>.of(state.statuses);
                          selected ? next.add(status) : next.remove(status);
                          ref
                              .read(materialsControllerProvider.notifier)
                              .setStatuses(next);
                        },
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(String projectId) async {
    await context.push(
      '/projects/${Uri.encodeComponent(projectId)}/materials/new',
    );
    if (mounted) await ref.read(materialsControllerProvider.notifier).refresh();
  }

  Future<void> _open(String projectId, String materialId) async {
    await context.push(
      '/projects/${Uri.encodeComponent(projectId)}'
      '/materials/${Uri.encodeComponent(materialId)}',
    );
    if (mounted) await ref.read(materialsControllerProvider.notifier).refresh();
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: emphasize ? colors.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({
    required this.material,
    required this.currencyCode,
    required this.now,
    required this.onTap,
  });

  final MaterialItem material;
  final String currencyCode;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = material.statusAt(now);
    final gross = material.input.orderedGross;
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: ValueKey('materialTile-${material.id}'),
      margin: EdgeInsets.zero,
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
                    child: Text(
                      material.input.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _Metric(
                    label: l10n.materialOrderedQuantity,
                    value:
                        '${formatMaterialQuantity(material.input.orderedQuantity)} '
                        '${material.input.unit}',
                  ),
                  _Metric(
                    label: l10n.costStatusLabel,
                    value: materialStatusLabel(l10n, status),
                    color: status == MaterialStatus.delayed
                        ? colors.error
                        : null,
                  ),
                  if (gross != null)
                    _Metric(
                      label: l10n.materialsOrderedValue,
                      value: formatMoneyForDisplay(gross, currencyCode),
                    ),
                  if (material.input.storageLocation case final location?)
                    _Metric(label: l10n.materialStorageLabel, value: location),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 92, maxWidth: 190),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
