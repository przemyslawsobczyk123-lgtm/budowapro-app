import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'quote_editor_gateway.dart';
import 'quote_ui_text.dart';

class QuoteComparisonScreen extends ConsumerWidget {
  const QuoteComparisonScreen({
    required this.projectId,
    required this.quoteIds,
    super.key,
  });

  final String projectId;
  final List<String> quoteIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gateway = ref.watch(quoteEditorGatewayProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quoteComparisonTitle)),
      body: quoteIds.length < 2
          ? AppEmptyState(
              icon: Icons.compare_arrows,
              title: l10n.quoteComparisonNeedsTwo,
              message: l10n.quoteComparisonNeedsTwo,
            )
          : gateway.when(
              loading: () => AppLoadingState(label: l10n.quoteComparisonTitle),
              error: (error, stackTrace) => AppErrorState(
                title: l10n.quotesLoadError,
                retryLabel: l10n.retryAction,
                onRetry: () => ref.invalidate(quoteEditorGatewayProvider),
              ),
              data: (value) => _ComparisonLoader(
                gateway: value,
                projectId: projectId,
                quoteIds: quoteIds,
              ),
            ),
    );
  }
}

class _ComparisonLoader extends StatefulWidget {
  const _ComparisonLoader({
    required this.gateway,
    required this.projectId,
    required this.quoteIds,
  });

  final QuoteEditorGateway gateway;
  final String projectId;
  final List<String> quoteIds;

  @override
  State<_ComparisonLoader> createState() => _ComparisonLoaderState();
}

class _ComparisonLoaderState extends State<_ComparisonLoader> {
  late Future<List<QuoteEditorData>> _load;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<List<QuoteEditorData>> _request() => Future.wait(
    widget.quoteIds.map(
      (id) => widget.gateway.load(projectId: widget.projectId, quoteId: id),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<QuoteEditorData>>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return AppLoadingState(label: l10n.quoteComparisonTitle);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return AppErrorState(
            title: l10n.quotesLoadError,
            retryLabel: l10n.retryAction,
            onRetry: () => setState(() => _load = _request()),
          );
        }
        final data = snapshot.data!;
        final quotes = data
            .map((item) => item.quote)
            .whereType<ContractorQuote>()
            .toList(growable: false);
        if (quotes.length < 2) {
          return AppEmptyState(
            icon: Icons.compare_arrows,
            title: l10n.quoteComparisonNeedsTwo,
            message: l10n.quoteComparisonNeedsTwo,
          );
        }
        final contactNames = <String, String>{};
        for (final item in data) {
          for (final contact in item.contacts) {
            contactNames[contact.id] = contact.displayName;
          }
        }
        return _ComparisonTable(
          comparison: QuoteComparison(quotes),
          contactNames: contactNames,
        );
      },
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({
    required this.comparison,
    required this.contactNames,
  });

  final QuoteComparison comparison;
  final Map<String, String> contactNames;

  static const double labelWidth = 168;
  static const double quoteWidth = 190;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalWidth = labelWidth + quoteWidth * comparison.quotes.length;
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: SizedBox(
          width: totalWidth,
          child: ListView(
            children: [
              _header(context),
              _priceRow(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                child: Text(
                  l10n.quoteComparisonScopeHeading,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (var index = 0; index < comparison.rows.length; index++)
                _scopeRow(context, comparison.rows[index], index.isEven),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.quoteComparisonTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          ...comparison.quotes.map(
            (quote) => SizedBox(
              width: quoteWidth,
              child: InkWell(
                onTap: () => context.push(
                  '/projects/${Uri.encodeComponent(quote.projectId)}'
                  '/quotes/${Uri.encodeComponent(quote.id)}',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.draft.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contactNames[quote.draft.contactId] ??
                            l10n.quoteContractorLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quote.draft.variantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.quoteComparisonPriceHeading,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          ...comparison.quotes.map(
            (quote) => SizedBox(
              width: quoteWidth,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatMoneyForDisplay(
                        quote.draft.amount.gross,
                        quote.draft.amount.gross.currencyCode,
                      ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (comparison.lowestPriceQuoteIds.contains(quote.id)) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.quoteLowestPriceLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scopeRow(BuildContext context, QuoteComparisonRow row, bool shaded) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: shaded ? colors.surfaceContainerLowest : colors.surface,
        border: Border(
          left: BorderSide(color: colors.outlineVariant),
          right: BorderSide(color: colors.outlineVariant),
          bottom: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(row.label),
            ),
          ),
          ...comparison.quotes.map((quote) {
            final presence =
                row.presenceByQuoteId[quote.id] ??
                QuoteScopePresence.notSpecified;
            final color = switch (presence) {
              QuoteScopePresence.included => colors.tertiary,
              QuoteScopePresence.excluded => colors.error,
              QuoteScopePresence.notSpecified => colors.outline,
            };
            return SizedBox(
              width: quoteWidth,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(quotePresenceIcon(presence), size: 18, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        quotePresenceLabel(
                          AppLocalizations.of(context),
                          presence,
                        ),
                        style: TextStyle(color: color),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
