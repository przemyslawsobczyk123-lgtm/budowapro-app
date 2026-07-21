import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'quote_ui_text.dart';
import 'quotes_controller.dart';

class QuotesScreen extends ConsumerStatefulWidget {
  const QuotesScreen({super.key});

  @override
  ConsumerState<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(quotesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quotesTitle)),
      body: asyncState.when(
        loading: () => AppLoadingState(label: l10n.quotesTitle),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.quotesLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(quotesControllerProvider),
        ),
        data: (state) => _body(context, state),
      ),
      floatingActionButton: asyncState.value?.project == null
          ? null
          : FloatingActionButton(
              key: const ValueKey('addQuoteButton'),
              tooltip: l10n.quoteNewTitle,
              onPressed: () => _openNew(context, asyncState.requireValue),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: _compareBar(context, asyncState.value),
    );
  }

  Widget _body(BuildContext context, QuotesState state) {
    final l10n = AppLocalizations.of(context);
    if (state.project == null) {
      return AppEmptyState(
        icon: Icons.home_work_outlined,
        title: l10n.quotesNoProjectTitle,
        message: l10n.quotesNoProjectMessage,
      );
    }
    if (_searchController.text != state.searchTerm) {
      _searchController.value = TextEditingValue(
        text: state.searchTerm,
        selection: TextSelection.collapsed(offset: state.searchTerm.length),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(quotesControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _filters(context, state),
            ),
          ),
          if (state.quotes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: state.searchTerm.isEmpty && state.statusFilter == null
                    ? Icons.request_quote_outlined
                    : Icons.search_off_outlined,
                title: state.searchTerm.isEmpty && state.statusFilter == null
                    ? l10n.quotesEmptyTitle
                    : l10n.quotesNoResultsTitle,
                message: state.searchTerm.isEmpty && state.statusFilter == null
                    ? l10n.quotesEmptyMessage
                    : l10n.quotesNoResultsMessage,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
              sliver: SliverList.separated(
                itemCount: state.quotes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _QuoteCard(
                  quote: state.quotes[index],
                  contractorName:
                      state
                          .contact(state.quotes[index].draft.contactId)
                          ?.displayName ??
                      l10n.quoteContractorLabel,
                  stageName: _stageName(
                    context,
                    state.stages,
                    state.quotes[index].draft.stageId,
                  ),
                  selected: state.selectedQuoteIds.contains(
                    state.quotes[index].id,
                  ),
                  onSelected: () =>
                      _toggleComparison(context, state.quotes[index].id),
                  onTap: () => _openDetails(context, state.quotes[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context, QuotesState state) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          key: const ValueKey('quoteSearchField'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: l10n.quotesSearchLabel,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.cancelAction,
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters(
                        state,
                        searchTerm: '',
                        status: state.statusFilter,
                      );
                    },
                    icon: const Icon(Icons.clear),
                  ),
          ),
          onSubmitted: (value) => _applyFilters(
            state,
            searchTerm: value,
            status: state.statusFilter,
          ),
        );
        final status = DropdownButtonFormField<ContractorQuoteStatus?>(
          key: ValueKey('quoteStatusFilter-${state.statusFilter?.name}'),
          initialValue: state.statusFilter,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.filter_list),
          ),
          items: <DropdownMenuItem<ContractorQuoteStatus?>>[
            DropdownMenuItem(value: null, child: Text(l10n.quotesStatusAll)),
            ...ContractorQuoteStatus.values.map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(quoteStatusFilterLabel(l10n, value)),
              ),
            ),
          ],
          onChanged: (value) => _applyFilters(state, status: value),
        );
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              search,
              const SizedBox(height: 8),
              status,
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.quotesResultCount(state.quotes.length)),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 2, child: search),
            const SizedBox(width: 12),
            Expanded(child: status),
            const SizedBox(width: 12),
            Text(l10n.quotesResultCount(state.quotes.length)),
          ],
        );
      },
    );
  }

  Widget? _compareBar(BuildContext context, QuotesState? state) {
    if (state == null || state.selectedQuoteIds.isEmpty) return null;
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: FilledButton.icon(
            key: const ValueKey('compareQuotesButton'),
            onPressed: state.selectedQuoteIds.length < 2
                ? null
                : () {
                    final ids = state.selectedQuoteIds
                        .map(Uri.encodeComponent)
                        .join(',');
                    context.push(
                      '/projects/${Uri.encodeComponent(state.project!.id)}'
                      '/quotes/compare?ids=$ids',
                    );
                  },
            icon: const Icon(Icons.compare_arrows),
            label: Text(
              l10n.quotesCompareAction(state.selectedQuoteIds.length),
            ),
          ),
        ),
      ),
    );
  }

  void _applyFilters(
    QuotesState state, {
    String? searchTerm,
    ContractorQuoteStatus? status,
  }) {
    ref
        .read(quotesControllerProvider.notifier)
        .setFilters(searchTerm: searchTerm ?? state.searchTerm, status: status);
  }

  void _toggleComparison(BuildContext context, String quoteId) {
    final added = ref
        .read(quotesControllerProvider.notifier)
        .toggleComparison(quoteId);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).quotesCompareLimit),
        ),
      );
    }
  }

  Future<void> _openNew(BuildContext context, QuotesState state) async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(state.project!.id)}/quotes/new',
    );
    if (changed == true) {
      ref.invalidate(quotesControllerProvider);
    }
  }

  Future<void> _openDetails(BuildContext context, ContractorQuote quote) async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(quote.projectId)}'
      '/quotes/${Uri.encodeComponent(quote.id)}',
    );
    if (changed == true) {
      ref.invalidate(quotesControllerProvider);
    }
  }
}

String? _stageName(
  BuildContext context,
  List<ProjectStage> stages,
  String? stageId,
) {
  if (stageId == null) return null;
  for (final stage in stages) {
    if (stage.id == stageId) {
      return stageName(AppLocalizations.of(context), stage);
    }
  }
  return stageId;
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.contractorName,
    required this.stageName,
    required this.selected,
    required this.onSelected,
    required this.onTap,
  });

  final ContractorQuote quote;
  final String contractorName;
  final String? stageName;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat.yMd(
      'pl',
    ).format(quote.draft.validUntilUtc.toLocal());
    final expired = quote.isExpiredAt(DateTime.now());
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                key: ValueKey('quoteCompare-${quote.id}'),
                value: selected,
                onChanged: (_) => onSelected(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            quote.draft.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusLabel(quote: quote),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$contractorName · ${quote.draft.variantName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          formatMoneyForDisplay(
                            quote.draft.amount.gross,
                            quote.draft.amount.gross.currencyCode,
                          ),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (stageName != null)
                          _Meta(icon: Icons.flag_outlined, label: stageName!),
                        _Meta(
                          icon: expired
                              ? Icons.event_busy_outlined
                              : Icons.event_available_outlined,
                          label: expired
                              ? l10n.quoteExpiredOnValue(date)
                              : l10n.quoteValidUntilValue(date),
                          color: expired ? colors.error : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.quote});

  final ContractorQuote quote;

  @override
  Widget build(BuildContext context) {
    final color = quoteStatusColor(Theme.of(context).colorScheme, quote);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        quoteStatusLabel(AppLocalizations.of(context), quote),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: effectiveColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: effectiveColor),
          ),
        ),
      ],
    );
  }
}
