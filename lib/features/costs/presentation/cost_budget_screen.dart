import 'dart:async';

import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_summary.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/costs/presentation/cost_register_initial_filter.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CostBudgetScreen extends ConsumerWidget {
  const CostBudgetScreen({this.initialFilter, super.key});

  final CostRegisterInitialFilter? initialFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsControllerProvider);
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: projects.when(
          loading: () => AppLoadingState(label: localizations.projectsLoading),
          error: (error, stackTrace) => AppErrorState(
            title: localizations.projectsLoadError,
            retryLabel: localizations.retryAction,
            onRetry: () =>
                ref.read(projectsControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            final project = state.selectedProject;
            if (project == null) {
              return _NoProject(localizations: localizations);
            }
            return _ProjectBudget(
              project: project,
              initialFilter: initialFilter ?? CostRegisterInitialFilter(),
            );
          },
        ),
      ),
    );
  }
}

class _NoProject extends StatelessWidget {
  const _NoProject({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Text(
            localizations.budgetTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: localizations.costBudgetNoProjectTitle,
          message: localizations.costBudgetNoProjectMessage,
        ),
      ),
    ],
  );
}

class _ProjectBudget extends ConsumerWidget {
  const _ProjectBudget({required this.project, required this.initialFilter});

  final Project project;
  final CostRegisterInitialFilter initialFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(costRepositoryProvider);
    final stages = ref.watch(projectStagesProvider(project));
    final localizations = AppLocalizations.of(context);
    return repository.when(
      loading: () => AppLoadingState(label: localizations.projectsLoading),
      error: (error, stackTrace) => AppErrorState(
        title: localizations.costBudgetLoadError,
        retryLabel: localizations.retryAction,
        onRetry: () => ref.invalidate(costRepositoryProvider),
      ),
      data: (value) => stages.when(
        loading: () => AppLoadingState(label: localizations.projectsLoading),
        error: (error, stackTrace) => AppErrorState(
          title: localizations.costBudgetLoadError,
          retryLabel: localizations.retryAction,
          onRetry: () => ref.invalidate(projectStagesProvider(project)),
        ),
        data: (projectStages) => _CostRegister(
          key: ValueKey<String>(
            'cost-register-${project.id}-${initialFilter.cacheKey}',
          ),
          project: project,
          repository: value,
          stages: projectStages,
          initialFilter: initialFilter,
        ),
      ),
    );
  }
}

class _CostRegister extends StatefulWidget {
  const _CostRegister({
    required this.project,
    required this.repository,
    required this.stages,
    required this.initialFilter,
    super.key,
  });

  final Project project;
  final CostRepository repository;
  final List<ProjectStage> stages;
  final CostRegisterInitialFilter initialFilter;

  @override
  State<_CostRegister> createState() => _CostRegisterState();
}

class _CostRegisterState extends State<_CostRegister> {
  static const _pageSize = 30;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<CostEntry> _entries = const <CostEntry>[];
  CostSummary? _summary;
  CostFilterOptions _options = CostFilterOptions();
  PageRequest? _nextRequest;
  Object? _initialError;
  Object? _loadMoreError;
  var _totalCount = 0;
  var _generation = 0;
  var _isInitialLoading = true;
  var _isLoadingMore = false;
  var _types = <CostEntryType>{};
  var _statuses = <CostStatus>{};
  var _missingAssignments = <CostMissingAssignment>{};
  String? _stageId;
  String? _categoryId;
  String? _supplierId;
  var _paymentMethods = <CostPaymentMethod>{};
  var _sources = <CostSource>{};
  var _warnings = <CostWarning>{};
  DateTime? _fromDate;
  DateTime? _toDate;
  var _includeDrafts = true;
  var _sort = CostSort.newest;

  @override
  void initState() {
    super.initState();
    _applyInitialFilter();
    _scrollController.addListener(_handleScroll);
    unawaited(_reload());
  }

  @override
  void didUpdateWidget(covariant _CostRegister oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id ||
        !identical(oldWidget.repository, widget.repository) ||
        oldWidget.initialFilter.cacheKey != widget.initialFilter.cacheKey) {
      _applyInitialFilter();
      unawaited(_reload());
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  CostQuery _query() => CostQuery(
    projectId: widget.project.id,
    searchText: _searchController.text,
    types: _types,
    statuses: _statuses,
    missingAssignments: _missingAssignments,
    stageIds: _stageId == null ? const <String>{} : <String>{_stageId!},
    categoryIds: _categoryId == null
        ? const <String>{}
        : <String>{_categoryId!},
    supplierIds: _supplierId == null
        ? const <String>{}
        : <String>{_supplierId!},
    paymentMethods: _paymentMethods,
    sources: _sources,
    warnings: _warnings,
    fromInclusive: _localDayStartUtc(_fromDate),
    toExclusive: _nextLocalDayStartUtc(_toDate),
    includeDrafts: _includeDrafts,
    sort: _sort,
  );

  int get _sheetFilterCount {
    final query = _query();
    return query.activeFilterCount - (query.searchText == null ? 0 : 1);
  }

  Future<void> _reload() async {
    final generation = ++_generation;
    final query = _query();
    setState(() {
      _isInitialLoading = true;
      _isLoadingMore = false;
      _initialError = null;
      _loadMoreError = null;
      _nextRequest = null;
    });
    try {
      final results = await Future.wait<Object>([
        widget.repository.list(query, PageRequest(limit: _pageSize)),
        widget.repository.summarize(CostSummaryQuery.fromCostQuery(query)),
        widget.repository.filterOptions(projectId: widget.project.id),
      ]);
      if (!mounted || generation != _generation) return;
      final page = results[0] as Page<CostEntry>;
      setState(() {
        _entries = page.items;
        _summary = results[1] as CostSummary;
        _options = results[2] as CostFilterOptions;
        _totalCount = page.totalCount;
        _nextRequest = page.nextRequest;
        _isInitialLoading = false;
      });
    } on Object catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _initialError = error;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final request = _nextRequest;
    if (request == null || _isLoadingMore || _isInitialLoading) return;
    final generation = _generation;
    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });
    try {
      final page = await widget.repository.list(_query(), request);
      if (!mounted || generation != _generation) return;
      setState(() {
        _entries = <CostEntry>[..._entries, ...page.items];
        _totalCount = page.totalCount;
        _nextRequest = page.nextRequest;
        _isLoadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loadMoreError = error;
        _isLoadingMore = false;
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels < 420) {
      unawaited(_loadMore());
    }
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _reload);
    setState(() {});
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<_CostFilterSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _CostFilterSheet(
        initial: _selection,
        project: widget.project,
        options: _options,
        stages: widget.stages,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _types = result.types;
      _statuses = result.statuses;
      _missingAssignments = <CostMissingAssignment>{
        for (final missing in _missingAssignments)
          if (!((missing == CostMissingAssignment.stage &&
                  result.stageId != null) ||
              (missing == CostMissingAssignment.category &&
                  result.categoryId != null) ||
              (missing == CostMissingAssignment.supplier &&
                  result.supplierId != null)))
            missing,
      };
      _stageId = result.stageId;
      _categoryId = result.categoryId;
      _supplierId = result.supplierId;
      _paymentMethods = result.paymentMethods;
      _sources = result.sources;
      _warnings = result.warnings;
      _fromDate = result.fromDate;
      _toDate = result.toDate;
      _includeDrafts = result.includeDrafts;
      _sort = result.sort;
    });
    await _reload();
  }

  _CostFilterSelection get _selection => _CostFilterSelection(
    types: _types,
    statuses: _statuses,
    stageId: _stageId,
    categoryId: _categoryId,
    supplierId: _supplierId,
    paymentMethods: _paymentMethods,
    sources: _sources,
    warnings: _warnings,
    fromDate: _fromDate,
    toDate: _toDate,
    includeDrafts: _includeDrafts,
    sort: _sort,
  );

  void _resetSessionFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _types = <CostEntryType>{};
    _statuses = <CostStatus>{};
    _missingAssignments = <CostMissingAssignment>{};
    _stageId = null;
    _categoryId = null;
    _supplierId = null;
    _paymentMethods = <CostPaymentMethod>{};
    _sources = <CostSource>{};
    _warnings = <CostWarning>{};
    _fromDate = null;
    _toDate = null;
    _includeDrafts = true;
    _sort = CostSort.newest;
  }

  void _applyInitialFilter() {
    _resetSessionFilters();
    final filter = widget.initialFilter;
    _types = Set<CostEntryType>.of(filter.types);
    _statuses = Set<CostStatus>.of(filter.statuses);
    _missingAssignments = Set<CostMissingAssignment>.of(
      filter.missingAssignments,
    );
    _stageId = filter.stageId;
    _categoryId = filter.categoryId;
    _supplierId = filter.supplierId;
    _fromDate = filter.fromDate;
    _toDate = filter.toDate;
    _includeDrafts = filter.includeDrafts;
  }

  Future<void> _clearAllFilters() async {
    setState(_resetSessionFilters);
    await _reload();
  }

  Future<void> _openNewCost() async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.project.id)}/costs/new',
    );
    if (mounted) await _reload();
  }

  Future<void> _openDetails(CostEntry entry) async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.project.id)}/costs/${Uri.encodeComponent(entry.id)}',
    );
    if (mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (_isInitialLoading) {
      return AppLoadingState(label: localizations.projectsLoading);
    }
    if (_initialError != null || _summary == null) {
      return AppErrorState(
        title: localizations.costBudgetLoadError,
        retryLabel: localizations.retryAction,
        onRetry: _reload,
      );
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: CustomScrollView(
        key: const ValueKey('costRegisterScroll'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            sliver: SliverToBoxAdapter(child: _buildHeader(localizations)),
          ),
          if (_entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmpty(localizations),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              sliver: SliverList.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CostEntryRow(
                    project: widget.project,
                    stages: widget.stages,
                    entry: _entries[index],
                    onTap: () => _openDetails(_entries[index]),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(child: _buildFooter(localizations)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              localizations.budgetTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          IconButton(
            key: const ValueKey('costBudgetAdd'),
            tooltip: localizations.costBudgetAddTooltip,
            onPressed: _openNewCost,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      const SizedBox(height: 14),
      TextField(
        key: const ValueKey('costRegisterSearch'),
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: _scheduleSearch,
        decoration: InputDecoration(
          hintText: localizations.costRegisterSearchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  key: const ValueKey('costRegisterClearSearch'),
                  tooltip: localizations.costRegisterClearFilters,
                  onPressed: () {
                    _searchController.clear();
                    _scheduleSearch('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              _FilterIconButton(
                count: _sheetFilterCount,
                tooltip: localizations.costRegisterFilterTooltip,
                onPressed: _openFilters,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      _BudgetSummary(project: widget.project, summary: _summary!),
      const SizedBox(height: 12),
      FilledButton.icon(
        key: const ValueKey('costBudgetCreate'),
        onPressed: _openNewCost,
        icon: const Icon(Icons.add_rounded),
        label: Text(localizations.costBudgetAddTooltip),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Text(
              localizations.costRegisterResultCount(_totalCount),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          if (_query().activeFilterCount > 0)
            TextButton.icon(
              key: const ValueKey('costRegisterClearFilters'),
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(localizations.costRegisterClearFilters),
            ),
        ],
      ),
    ],
  );

  Widget _buildEmpty(AppLocalizations localizations) {
    if (_query().activeFilterCount > 0) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: localizations.costRegisterNoResultsTitle,
        message: localizations.costRegisterNoResultsMessage,
      );
    }
    return AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: localizations.costBudgetEmptyTitle,
      message: localizations.costBudgetEmptyMessage,
      actionLabel: localizations.costBudgetAddTooltip,
      onAction: _openNewCost,
    );
  }

  Widget _buildFooter(AppLocalizations localizations) {
    if (_isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Semantics(
            label: localizations.costRegisterLoadingMore,
            child: const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
      );
    }
    if (_loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: OutlinedButton.icon(
            key: const ValueKey('costRegisterRetryMore'),
            onPressed: _loadMore,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(localizations.costRegisterLoadMoreError),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.project, required this.summary});

  final Project project;
  final CostSummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final values = [
      _SummaryValue(
        label: localizations.costBudgetPlannedLabel,
        value: _money(summary.planned, project.currencyCode),
      ),
      _SummaryValue(
        label: localizations.costBudgetActualLabel,
        value: _money(summary.actual, project.currencyCode),
      ),
      _SummaryValue(
        label: localizations.costBudgetDifferenceLabel,
        value: _money(summary.difference, project.currencyCode),
      ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 440) {
              return Column(
                children: values
                    .map(
                      (value) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: value,
                      ),
                    )
                    .toList(growable: false),
              );
            }
            return Row(
              children: values
                  .map((value) => Expanded(child: value))
                  .toList(growable: false),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    ],
  );
}

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({
    required this.count,
    required this.tooltip,
    required this.onPressed,
  });

  final int count;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        key: const ValueKey('costRegisterFilters'),
        tooltip: tooltip,
        onPressed: onPressed,
        icon: const Icon(Icons.tune_rounded),
      ),
      if (count > 0)
        Positioned(
          top: 3,
          right: 3,
          child: IgnorePointer(
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class _CostEntryRow extends StatelessWidget {
  const _CostEntryRow({
    required this.project,
    required this.entry,
    required this.stages,
    required this.onTap,
  });

  final Project project;
  final CostEntry entry;
  final List<ProjectStage> stages;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final warnings = _warningsFor(entry);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _entryIcon(entry.type),
                    size: 21,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 96,
                          height: 24,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _money(entry.amount.gross, project.currencyCode),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _entryContext(localizations, entry, stages),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (warnings.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: warnings
                            .map(
                              (warning) => _WarningLabel(
                                text: _warningLabel(localizations, warning),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningLabel extends StatelessWidget {
  const _WarningLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 14,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ],
    ),
  );
}

class _CostFilterSelection {
  _CostFilterSelection({
    required Set<CostEntryType> types,
    required Set<CostStatus> statuses,
    required this.stageId,
    required this.categoryId,
    required this.supplierId,
    required Set<CostPaymentMethod> paymentMethods,
    required Set<CostSource> sources,
    required Set<CostWarning> warnings,
    required this.fromDate,
    required this.toDate,
    required this.includeDrafts,
    required this.sort,
  }) : types = Set<CostEntryType>.unmodifiable(types),
       statuses = Set<CostStatus>.unmodifiable(statuses),
       paymentMethods = Set<CostPaymentMethod>.unmodifiable(paymentMethods),
       sources = Set<CostSource>.unmodifiable(sources),
       warnings = Set<CostWarning>.unmodifiable(warnings);

  final Set<CostEntryType> types;
  final Set<CostStatus> statuses;
  final String? stageId;
  final String? categoryId;
  final String? supplierId;
  final Set<CostPaymentMethod> paymentMethods;
  final Set<CostSource> sources;
  final Set<CostWarning> warnings;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool includeDrafts;
  final CostSort sort;
}

class _CostFilterSheet extends StatefulWidget {
  const _CostFilterSheet({
    required this.initial,
    required this.project,
    required this.options,
    required this.stages,
  });

  final _CostFilterSelection initial;
  final Project project;
  final CostFilterOptions options;
  final List<ProjectStage> stages;

  @override
  State<_CostFilterSheet> createState() => _CostFilterSheetState();
}

class _CostFilterSheetState extends State<_CostFilterSheet> {
  late Set<CostEntryType> _types;
  late Set<CostStatus> _statuses;
  String? _stageId;
  String? _categoryId;
  String? _supplierId;
  late Set<CostPaymentMethod> _paymentMethods;
  late Set<CostSource> _sources;
  late Set<CostWarning> _warnings;
  DateTime? _fromDate;
  DateTime? _toDate;
  late bool _includeDrafts;
  late CostSort _sort;

  @override
  void initState() {
    super.initState();
    _load(widget.initial);
  }

  void _load(_CostFilterSelection value) {
    _types = Set<CostEntryType>.of(value.types);
    _statuses = Set<CostStatus>.of(value.statuses);
    _stageId = value.stageId;
    _categoryId = value.categoryId;
    _supplierId = value.supplierId;
    _paymentMethods = Set<CostPaymentMethod>.of(value.paymentMethods);
    _sources = Set<CostSource>.of(value.sources);
    _warnings = Set<CostWarning>.of(value.warnings);
    _fromDate = value.fromDate;
    _toDate = value.toDate;
    _includeDrafts = value.includeDrafts;
    _sort = value.sort;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.costRegisterFilterTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                _FilterSection(
                  title: localizations.costRegisterTypeSection,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: CostEntryType.values
                        .map(
                          (value) => FilterChip(
                            key: ValueKey('costFilterType-${value.name}'),
                            label: Text(_typeLabel(localizations, value)),
                            selected: _types.contains(value),
                            onSelected: (selected) => setState(() {
                              selected
                                  ? _types.add(value)
                                  : _types.remove(value);
                            }),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                _FilterSection(
                  title: localizations.costRegisterStatusSection,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: CostStatus.values
                        .map(
                          (value) => FilterChip(
                            key: ValueKey('costFilterStatus-${value.name}'),
                            label: Text(_statusLabel(localizations, value)),
                            selected: _statuses.contains(value),
                            onSelected: (selected) => setState(() {
                              selected
                                  ? _statuses.add(value)
                                  : _statuses.remove(value);
                            }),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                _FilterSection(
                  title: localizations.costRegisterContextSection,
                  child: Column(
                    children: [
                      _StringFilterField(
                        key: const ValueKey('costFilterStage'),
                        label: localizations.costStageLabel,
                        value: _stageId,
                        options: _stageOptions(
                          widget.project,
                          widget.options,
                          widget.stages,
                        ),
                        optionLabel: (value) =>
                            _stageLabel(localizations, value, widget.stages),
                        onChanged: (value) => setState(() => _stageId = value),
                      ),
                      const SizedBox(height: 10),
                      _StringFilterField(
                        key: const ValueKey('costFilterCategory'),
                        label: localizations.costCategoryLabel,
                        value: _categoryId,
                        options: widget.options.categoryIds,
                        onChanged: (value) =>
                            setState(() => _categoryId = value),
                      ),
                      const SizedBox(height: 10),
                      _StringFilterField(
                        key: const ValueKey('costFilterSupplier'),
                        label: localizations.costSupplierLabel,
                        value: _supplierId,
                        options: widget.options.supplierIds,
                        onChanged: (value) =>
                            setState(() => _supplierId = value),
                      ),
                    ],
                  ),
                ),
                _FilterSection(
                  title: localizations.costRegisterPaymentSection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: CostPaymentMethod.values
                            .map(
                              (value) => FilterChip(
                                label: Text(
                                  _paymentLabel(localizations, value),
                                ),
                                selected: _paymentMethods.contains(value),
                                onSelected: (selected) => setState(() {
                                  selected
                                      ? _paymentMethods.add(value)
                                      : _paymentMethods.remove(value);
                                }),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: CostSource.values
                            .map(
                              (value) => FilterChip(
                                label: Text(_sourceLabel(localizations, value)),
                                selected: _sources.contains(value),
                                onSelected: (selected) => setState(() {
                                  selected
                                      ? _sources.add(value)
                                      : _sources.remove(value);
                                }),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                _FilterSection(
                  title: localizations.costRegisterDateSection,
                  child: Row(
                    children: [
                      Expanded(
                        child: _DateFilterButton(
                          label: localizations.costRegisterDateFrom,
                          value: _fromDate,
                          onPressed: () => _pickDate(isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateFilterButton(
                          label: localizations.costRegisterDateTo,
                          value: _toDate,
                          onPressed: () => _pickDate(isFrom: false),
                        ),
                      ),
                    ],
                  ),
                ),
                _FilterSection(
                  title: localizations.costRegisterQualitySection,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: CostWarning.values
                        .map(
                          (value) => FilterChip(
                            label: Text(_warningLabel(localizations, value)),
                            selected: _warnings.contains(value),
                            onSelected: (selected) => setState(() {
                              selected
                                  ? _warnings.add(value)
                                  : _warnings.remove(value);
                            }),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                _FilterSection(
                  title: localizations.costRegisterSortSection,
                  child: DropdownButtonFormField<CostSort>(
                    initialValue: _sort,
                    isExpanded: true,
                    items: CostSort.values
                        .map(
                          (value) => DropdownMenuItem<CostSort>(
                            value: value,
                            child: Text(_sortLabel(localizations, value)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) setState(() => _sort = value);
                    },
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.costRegisterIncludeDrafts),
                  value: _includeDrafts,
                  onChanged: (value) => setState(() => _includeDrafts = value),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('costFilterReset'),
                        onPressed: () => setState(() {
                          _load(
                            _CostFilterSelection(
                              types: const <CostEntryType>{},
                              statuses: const <CostStatus>{},
                              stageId: null,
                              categoryId: null,
                              supplierId: null,
                              paymentMethods: const <CostPaymentMethod>{},
                              sources: const <CostSource>{},
                              warnings: const <CostWarning>{},
                              fromDate: null,
                              toDate: null,
                              includeDrafts: true,
                              sort: CostSort.newest,
                            ),
                          );
                        }),
                        child: Text(localizations.costRegisterResetFilters),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('costFilterApply'),
                        onPressed: () => Navigator.pop(
                          context,
                          _CostFilterSelection(
                            types: _types,
                            statuses: _statuses,
                            stageId: _stageId,
                            categoryId: _categoryId,
                            supplierId: _supplierId,
                            paymentMethods: _paymentMethods,
                            sources: _sources,
                            warnings: _warnings,
                            fromDate: _fromDate,
                            toDate: _toDate,
                            includeDrafts: _includeDrafts,
                            sort: _sort,
                          ),
                        ),
                        child: Text(localizations.costRegisterApplyFilters),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final current = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && picked.isAfter(_toDate!)) _toDate = picked;
      } else {
        _toDate = picked;
        if (_fromDate != null && picked.isBefore(_fromDate!)) {
          _fromDate = picked;
        }
      }
    });
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 9),
        child,
      ],
    ),
  );
}

class _StringFilterField extends StatelessWidget {
  const _StringFilterField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.optionLabel,
    super.key,
  });

  final String label;
  final String? value;
  final Iterable<String> options;
  final ValueChanged<String?> onChanged;
  final String Function(String value)? optionLabel;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final values = <String>{...options};
    if (value != null) values.add(value!);
    final sorted = values.toList(
      growable: false,
    )..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
    return DropdownButtonFormField<String?>(
      key: ValueKey<String?>('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(localizations.costRegisterAllOption),
        ),
        ...sorted.map(
          (option) => DropdownMenuItem<String?>(
            value: option,
            child: Text(
              optionLabel?.call(option) ?? option,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.calendar_today_outlined, size: 18),
    label: Text(
      value == null ? label : '$label: ${_date(value!)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

DateTime? _localDayStartUtc(DateTime? value) =>
    value == null ? null : DateTime(value.year, value.month, value.day).toUtc();

DateTime? _nextLocalDayStartUtc(DateTime? value) => value == null
    ? null
    : DateTime(value.year, value.month, value.day + 1).toUtc();

String _money(Money value, String currencyCode) =>
    formatMoneyForDisplay(value, currencyCode);

String _date(DateTime value) => DateFormat('dd.MM.yyyy', 'pl_PL').format(value);

IconData _entryIcon(CostEntryType type) => switch (type) {
  CostEntryType.cost => Icons.receipt_long_outlined,
  CostEntryType.offer => Icons.request_quote_outlined,
  CostEntryType.planned => Icons.event_note_outlined,
};

List<CostWarning> _warningsFor(CostEntry entry) {
  if (entry.lifecycle != CostLifecycle.confirmed ||
      entry.type != CostEntryType.cost) {
    return const <CostWarning>[];
  }
  return <CostWarning>[
    if (entry.input.attachmentIds.isEmpty) CostWarning.missingDocument,
    if (entry.input.note?.trim().isEmpty ?? true)
      CostWarning.missingDescription,
    if (entry.amount.gross.minorUnits > 0 && entry.amount.rate == VatRate.zero)
      CostWarning.vatToReview,
  ];
}

String _entryContext(
  AppLocalizations l10n,
  CostEntry entry,
  List<ProjectStage> stages,
) {
  final values = <String>[
    entry.lifecycle == CostLifecycle.draft
        ? l10n.costDraftLabel
        : _statusLabel(l10n, entry.status),
    _sourceLabel(l10n, entry.input.source),
    if (entry.input.stageId case final stageId?)
      _stageLabel(l10n, stageId, stages),
    ?entry.input.categoryId,
    ?entry.input.supplierId,
    _date(entry.entryDate.toLocal()),
  ];
  return values.join(' · ');
}

String _typeLabel(AppLocalizations l10n, CostEntryType value) =>
    switch (value) {
      CostEntryType.cost => l10n.costTypeCost,
      CostEntryType.offer => l10n.costTypeOffer,
      CostEntryType.planned => l10n.costTypePlanned,
    };

String _statusLabel(AppLocalizations l10n, CostStatus value) => switch (value) {
  CostStatus.planned => l10n.costStatusPlanned,
  CostStatus.ordered => l10n.costStatusOrdered,
  CostStatus.due => l10n.costStatusDue,
  CostStatus.paid => l10n.costStatusPaid,
  CostStatus.returned => l10n.costStatusReturned,
  CostStatus.disputed => l10n.costStatusDisputed,
};

String _paymentLabel(AppLocalizations l10n, CostPaymentMethod value) =>
    switch (value) {
      CostPaymentMethod.cash => l10n.costPaymentCash,
      CostPaymentMethod.card => l10n.costPaymentCard,
      CostPaymentMethod.bankTransfer => l10n.costPaymentBankTransfer,
      CostPaymentMethod.blik => l10n.costPaymentBlik,
      CostPaymentMethod.other => l10n.costPaymentOther,
    };

String _sourceLabel(AppLocalizations l10n, CostSource value) => switch (value) {
  CostSource.manual => l10n.costSourceManual,
  CostSource.receiptOcr => l10n.costSourceReceiptOcr,
  CostSource.invoiceOcr => l10n.costSourceInvoiceOcr,
  CostSource.imported => l10n.costSourceImported,
  CostSource.offerConversion => l10n.costSourceOfferConversion,
};

String _warningLabel(AppLocalizations l10n, CostWarning value) =>
    switch (value) {
      CostWarning.missingDocument => l10n.costWarningMissingDocument,
      CostWarning.missingDescription => l10n.costWarningMissingDescription,
      CostWarning.vatToReview => l10n.costWarningVatToReview,
    };

String _sortLabel(AppLocalizations l10n, CostSort value) => switch (value) {
  CostSort.newest => l10n.costRegisterSortNewest,
  CostSort.oldest => l10n.costRegisterSortOldest,
  CostSort.amountDescending => l10n.costRegisterSortAmountDescending,
  CostSort.amountAscending => l10n.costRegisterSortAmountAscending,
  CostSort.nameAscending => l10n.costRegisterSortName,
};

List<String> _stageOptions(
  Project project,
  CostFilterOptions options,
  List<ProjectStage> stages,
) {
  final values = <String>{
    if (stages.isEmpty)
      ...project.template.definition.stages.map(_stageStorageId)
    else
      ...stages.map((stage) => stage.id),
    ...options.stageIds,
  };
  return values.toList(growable: false);
}

String _stageStorageId(ProjectStageKey value) => switch (value) {
  ProjectStageKey.planning => 'planning',
  ProjectStageKey.formalities => 'formalities',
  ProjectStageKey.stateZero => 'state_zero',
  ProjectStageKey.shellOpen => 'shell_open',
  ProjectStageKey.shellClosed => 'shell_closed',
  ProjectStageKey.demolition => 'demolition',
  ProjectStageKey.installations => 'installations',
  ProjectStageKey.plaster => 'plaster',
  ProjectStageKey.finishing => 'finishing',
  ProjectStageKey.handover => 'handover',
};

String _stageLabel(
  AppLocalizations localizations,
  String stageId,
  List<ProjectStage> stages,
) {
  for (final stage in stages) {
    if (stage.id == stageId) return stageName(localizations, stage);
  }
  for (final stage in ProjectStageKey.values) {
    if (_stageStorageId(stage) == stageId) {
      return projectStageLabel(localizations, stage);
    }
  }
  return stageId;
}
