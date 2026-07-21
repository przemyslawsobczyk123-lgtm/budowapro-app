import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/quotes/data/quote_providers.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'quote_editor_gateway.dart';
import 'quote_ui_text.dart';
import 'quotes_controller.dart';

class QuoteDetailsScreen extends ConsumerStatefulWidget {
  const QuoteDetailsScreen({
    required this.projectId,
    required this.quoteId,
    super.key,
  });

  final String projectId;
  final String quoteId;

  @override
  ConsumerState<QuoteDetailsScreen> createState() => _QuoteDetailsScreenState();
}

class _QuoteDetailsScreenState extends ConsumerState<QuoteDetailsScreen> {
  Future<QuoteEditorData>? _load;
  var _isMutating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gateway = ref.watch(quoteEditorGatewayProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quoteDetailsTitle)),
      body: gateway.when(
        loading: () => AppLoadingState(label: l10n.quoteDetailsTitle),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.quoteLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(quoteEditorGatewayProvider),
        ),
        data: (value) {
          _load ??= value.load(
            projectId: widget.projectId,
            quoteId: widget.quoteId,
          );
          return FutureBuilder<QuoteEditorData>(
            future: _load,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return AppLoadingState(label: l10n.quoteDetailsTitle);
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return AppErrorState(
                  title: snapshot.error is QuoteEditorNotFoundException
                      ? l10n.quoteNotFoundTitle
                      : l10n.quoteLoadError,
                  retryLabel: l10n.retryAction,
                  onRetry: () => setState(() {
                    _load = value.load(
                      projectId: widget.projectId,
                      quoteId: widget.quoteId,
                    );
                  }),
                );
              }
              return _content(context, snapshot.data!);
            },
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, QuoteEditorData data) {
    final quote = data.quote;
    final l10n = AppLocalizations.of(context);
    if (quote == null) {
      return AppEmptyState(
        icon: Icons.request_quote_outlined,
        title: l10n.quoteNotFoundTitle,
        message: l10n.quoteNotFoundMessage,
      );
    }
    final contact = data.contacts
        .where((item) => item.id == quote.draft.contactId)
        .firstOrNull;
    final stage = data.stages
        .where((item) => item.id == quote.draft.stageId)
        .firstOrNull;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _QuoteHeader(
              quote: quote,
              contractorName: contact?.displayName ?? l10n.quoteContractorLabel,
            ),
            const SizedBox(height: 20),
            _DetailsBand(
              children: [
                _Detail(
                  icon: Icons.tune_outlined,
                  label: l10n.quoteVariantLabel,
                  value: quote.draft.variantName,
                ),
                _Detail(
                  icon: Icons.flag_outlined,
                  label: l10n.quoteStageLabel,
                  value: stage == null
                      ? l10n.quoteNoStage
                      : stageName(l10n, stage),
                ),
                _Detail(
                  icon: Icons.event_note_outlined,
                  label: l10n.quoteReceivedDateLabel,
                  value: DateFormat.yMd(
                    'pl',
                  ).format(quote.draft.receivedAtUtc.toLocal()),
                ),
                _Detail(
                  icon: Icons.event_available_outlined,
                  label: l10n.quoteValidUntilLabel,
                  value: DateFormat.yMd(
                    'pl',
                  ).format(quote.draft.validUntilUtc.toLocal()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ScopeSection(
              title: l10n.quoteIncludedScopeHeading,
              icon: Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.tertiary,
              lines: quote.draft.includedScope,
            ),
            if (quote.draft.excludedScope.isNotEmpty) ...[
              const SizedBox(height: 20),
              _ScopeSection(
                title: l10n.quoteExcludedScopeHeading,
                icon: Icons.remove_circle_outline,
                color: Theme.of(context).colorScheme.error,
                lines: quote.draft.excludedScope,
              ),
            ],
            if (data.attachments.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                l10n.quoteAttachmentsHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              ...data.attachments.map(
                (attachment) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    attachment.mediaType?.startsWith('image/') == true
                        ? Icons.image_outlined
                        : Icons.picture_as_pdf_outlined,
                  ),
                  title: Text(attachment.displayName),
                  subtitle: Text(_fileSize(attachment.byteSize)),
                ),
              ),
            ],
            if (quote.draft.note != null) ...[
              const SizedBox(height: 24),
              Text(
                l10n.quoteNoteLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(quote.draft.note!),
            ],
            const SizedBox(height: 28),
            _actions(context, quote),
          ],
        ),
        if (_isMutating) const LinearProgressIndicator(),
      ],
    );
  }

  Widget _actions(BuildContext context, ContractorQuote quote) {
    final l10n = AppLocalizations.of(context);
    if (quote.status == ContractorQuoteStatus.accepted) {
      return FilledButton.icon(
        onPressed: _isMutating
            ? null
            : () => context.push(
                '/projects/${Uri.encodeComponent(widget.projectId)}'
                '/costs/${Uri.encodeComponent(quote.acceptedCostEntryId!)}',
              ),
        icon: const Icon(Icons.account_balance_wallet_outlined),
        label: Text(l10n.quoteViewCostAction),
      );
    }
    if (quote.status == ContractorQuoteStatus.rejected) {
      return OutlinedButton.icon(
        onPressed: _isMutating ? null : _delete,
        icon: const Icon(Icons.delete_outline),
        label: Text(l10n.deleteAction),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          key: const ValueKey('acceptQuoteButton'),
          onPressed: _isMutating ? null : _accept,
          icon: const Icon(Icons.check),
          label: Text(l10n.quoteAcceptAction),
        ),
        OutlinedButton.icon(
          onPressed: _isMutating ? null : _edit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.quoteEditTitle),
        ),
        OutlinedButton.icon(
          onPressed: _isMutating ? null : _reject,
          icon: const Icon(Icons.close),
          label: Text(l10n.quoteRejectAction),
        ),
        IconButton(
          tooltip: l10n.deleteAction,
          onPressed: _isMutating ? null : _delete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  Future<void> _edit() async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(widget.projectId)}'
      '/quotes/${Uri.encodeComponent(widget.quoteId)}/edit',
    );
    if (changed == true && mounted) _reload();
  }

  Future<void> _accept() async {
    final l10n = AppLocalizations.of(context);
    final target = await showDialog<QuoteCostTarget>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quoteAcceptTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelAction),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, QuoteCostTarget.planned),
            child: Text(l10n.quoteAcceptPlannedAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, QuoteCostTarget.ordered),
            child: Text(l10n.quoteAcceptOrderedAction),
          ),
        ],
      ),
    );
    if (target == null) return;
    await _mutate(() async {
      await (await ref.read(quoteRepositoryProvider.future)).accept(
        projectId: widget.projectId,
        quoteId: widget.quoteId,
        target: target,
      );
      ref.invalidate(costRepositoryProvider);
    }, l10n.quoteAcceptError);
  }

  Future<void> _reject() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.quoteRejectConfirmTitle,
      message: l10n.quoteRejectConfirmMessage,
      action: l10n.quoteRejectAction,
    );
    if (!confirmed) return;
    await _mutate(() async {
      await (await ref.read(
        quoteRepositoryProvider.future,
      )).reject(projectId: widget.projectId, quoteId: widget.quoteId);
    }, l10n.quoteRejectError);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.quoteDeleteConfirmTitle,
      message: l10n.quoteDeleteConfirmMessage,
      action: l10n.deleteAction,
    );
    if (!confirmed) return;
    setState(() => _isMutating = true);
    try {
      await (await ref.read(
        quoteRepositoryProvider.future,
      )).delete(projectId: widget.projectId, quoteId: widget.quoteId);
      ref.invalidate(quotesControllerProvider);
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted) {
        setState(() => _isMutating = false);
        _showError(l10n.quoteDeleteError);
      }
    }
  }

  Future<void> _mutate(Future<void> Function() action, String error) async {
    setState(() => _isMutating = true);
    try {
      await action();
      ref.invalidate(quotesControllerProvider);
      if (mounted) _reload();
    } on Object {
      if (mounted) {
        setState(() => _isMutating = false);
        _showError(error);
      }
    }
  }

  void _reload() {
    final gateway = ref.read(quoteEditorGatewayProvider).value;
    if (gateway == null) return;
    setState(() {
      _isMutating = false;
      _load = gateway.load(
        projectId: widget.projectId,
        quoteId: widget.quoteId,
      );
    });
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancelAction),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _QuoteHeader extends StatelessWidget {
  const _QuoteHeader({required this.quote, required this.contractorName});

  final ContractorQuote quote;
  final String contractorName;

  @override
  Widget build(BuildContext context) {
    final color = quoteStatusColor(Theme.of(context).colorScheme, quote);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                quote.draft.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                quoteStatusLabel(AppLocalizations.of(context), quote),
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          contractorName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          formatMoneyForDisplay(
            quote.draft.amount.gross,
            quote.draft.amount.gross.currencyCode,
          ),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class _DetailsBand extends StatelessWidget {
  const _DetailsBand({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 24, runSpacing: 16, children: children);
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ScopeSection extends StatelessWidget {
  const _ScopeSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<QuoteScopeLine> lines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ...lines.map(
        (line) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.label),
                    if (line.details != null)
                      Text(
                        line.details!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

String _fileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
