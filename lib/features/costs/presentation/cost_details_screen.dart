import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart' as paging;
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cost_editor_gateway.dart';
import 'cost_form_screen.dart';
import 'cost_form_model.dart';

class CostDetailsScreen extends ConsumerWidget {
  const CostDetailsScreen({
    required this.projectId,
    required this.costEntryId,
    super.key,
  });

  final String projectId;
  final String costEntryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(costEditorGatewayProvider);
    return gateway.when(
      loading: () => _DetailsScaffold(
        title: AppLocalizations.of(context).costDetailsTitle,
        child: AppLoadingState(
          label: AppLocalizations.of(context).projectsLoading,
        ),
      ),
      error: (error, stackTrace) => _DetailsScaffold(
        title: AppLocalizations.of(context).costDetailsTitle,
        child: AppErrorState(
          title: AppLocalizations.of(context).costLoadError,
          retryLabel: AppLocalizations.of(context).retryAction,
          onRetry: () => ref.invalidate(costEditorGatewayProvider),
        ),
      ),
      data: (value) => _CostDetailsLoader(
        key: ValueKey('$projectId/$costEntryId'),
        gateway: value,
        projectId: projectId,
        costEntryId: costEntryId,
      ),
    );
  }
}

class _CostDetailsLoader extends StatefulWidget {
  const _CostDetailsLoader({
    required this.gateway,
    required this.projectId,
    required this.costEntryId,
    super.key,
  });

  final CostEditorGateway gateway;
  final String projectId;
  final String costEntryId;

  @override
  State<_CostDetailsLoader> createState() => _CostDetailsLoaderState();
}

class _CostDetailsLoaderState extends State<_CostDetailsLoader> {
  late Future<CostEditorData> _load;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<CostEditorData> _request() {
    return widget.gateway.load(
      projectId: widget.projectId,
      costEntryId: widget.costEntryId,
    );
  }

  void _reload() {
    setState(() {
      _load = _request();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return FutureBuilder<CostEditorData>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _DetailsScaffold(
            title: localizations.costDetailsTitle,
            child: AppLoadingState(label: localizations.projectsLoading),
          );
        }
        final data = snapshot.data;
        if (snapshot.hasError || data?.entry == null) {
          return _DetailsScaffold(
            title: localizations.costDetailsTitle,
            child: AppErrorState(
              title: snapshot.error is CostEditorNotFoundException
                  ? localizations.costNotFoundError
                  : localizations.costLoadError,
              retryLabel: localizations.retryAction,
              onRetry: _reload,
            ),
          );
        }
        return _CostDetails(
          key: ValueKey('${data!.entry!.id}/${data.entry!.revision}'),
          data: data,
          gateway: widget.gateway,
          onChanged: _reload,
        );
      },
    );
  }
}

class _CostDetails extends StatefulWidget {
  const _CostDetails({
    required this.data,
    required this.gateway,
    required this.onChanged,
    super.key,
  });

  final CostEditorData data;
  final CostEditorGateway gateway;
  final VoidCallback onChanged;

  @override
  State<_CostDetails> createState() => _CostDetailsState();
}

class _CostDetailsState extends State<_CostDetails> {
  late final Future<paging.Page<CostHistoryEntry>> _history;
  var _isWorking = false;

  CostEntry get _entry => widget.data.entry!;

  @override
  void initState() {
    super.initState();
    _history = widget.gateway.history(
      projectId: widget.data.project.id,
      costEntryId: _entry.id,
      page: paging.PageRequest(limit: paging.PageRequest.maximumLimit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final entry = _entry;
    final input = entry.input;
    final canMarkPaid =
        entry.lifecycle == CostLifecycle.confirmed &&
        entry.type == CostEntryType.cost &&
        {CostStatus.ordered, CostStatus.due}.contains(entry.status);
    return _DetailsScaffold(
      title: localizations.costDetailsTitle,
      actions: [
        IconButton(
          key: const ValueKey('costDetailsEdit'),
          tooltip: localizations.costDetailsEditAction,
          onPressed: _isWorking ? null : _edit,
          icon: const Icon(Icons.edit_outlined),
        ),
        PopupMenuButton<_DetailsAction>(
          key: const ValueKey('costDetailsActions'),
          tooltip: localizations.moreTitle,
          enabled: !_isWorking,
          onSelected: _handleAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _DetailsAction.copyDraft,
              child: Text(localizations.costDetailsCopyDraftAction),
            ),
            if (canMarkPaid)
              PopupMenuItem(
                value: _DetailsAction.markPaid,
                child: Text(localizations.costDetailsMarkPaidAction),
              ),
            PopupMenuItem(
              value: _DetailsAction.delete,
              child: Text(localizations.costDetailsDeleteAction),
            ),
          ],
        ),
      ],
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList.list(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusChip(
                        label: entry.lifecycle == CostLifecycle.draft
                            ? localizations.costDraftLabel
                            : costStatusLabel(localizations, entry.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailGroup(
                    children: [
                      _DetailRow(
                        icon: Icons.sell_outlined,
                        label: localizations.costTypeLabel,
                        value: costTypeLabel(localizations, entry.type),
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: localizations.costDateLabel,
                        value: formatCostDate(entry.entryDate.toLocal()),
                      ),
                      _DetailRow(
                        icon: Icons.payments_outlined,
                        label: localizations.costGrossAmountLabel,
                        value: formatCostMoney(
                          input.amount.gross,
                          widget.data.project.currencyCode,
                        ),
                      ),
                      _DetailRow(
                        icon: Icons.calculate_outlined,
                        label: localizations.costNetAmountLabel,
                        value: formatCostMoney(
                          input.amount.net,
                          widget.data.project.currencyCode,
                        ),
                      ),
                      _DetailRow(
                        icon: Icons.percent_outlined,
                        label: localizations.costVatAmountLabel,
                        value:
                            '${formatCostMoney(input.amount.vat, widget.data.project.currencyCode)} (${costVatLabel(localizations, input.amount.rate)})',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailsSectionTitle(localizations.costFormDetailsSection),
                  const SizedBox(height: 8),
                  _DetailGroup(
                    children: [
                      _DetailRow(
                        icon: Icons.flag_outlined,
                        label: localizations.costStageLabel,
                        value:
                            input.stageId ??
                            localizations.projectValueNotProvided,
                      ),
                      _DetailRow(
                        icon: Icons.category_outlined,
                        label: localizations.costCategoryLabel,
                        value:
                            input.categoryId ??
                            localizations.projectValueNotProvided,
                      ),
                      _DetailRow(
                        icon: Icons.storefront_outlined,
                        label: localizations.costSupplierLabel,
                        value:
                            input.supplierId ??
                            localizations.projectValueNotProvided,
                      ),
                      if (input.quantity != null)
                        _DetailRow(
                          icon: Icons.straighten_outlined,
                          label: localizations.costQuantityLabel,
                          value:
                              '${formatQuantityForInput(input.quantity)} ${input.unit}',
                        ),
                      _DetailRow(
                        icon: Icons.credit_card_outlined,
                        label: localizations.costPaymentMethodLabel,
                        value: input.paymentMethod == null
                            ? localizations.projectValueNotProvided
                            : costPaymentLabel(
                                localizations,
                                input.paymentMethod!,
                              ),
                      ),
                      if (input.note != null)
                        _DetailRow(
                          icon: Icons.notes_outlined,
                          label: localizations.costNoteLabel,
                          value: input.note!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailsSectionTitle(localizations.costFormDocumentsSection),
                  const SizedBox(height: 8),
                  _DetailsAttachmentList(
                    attachments: widget.data.attachments,
                    emptyText: localizations.costAttachmentsEmpty,
                  ),
                  const SizedBox(height: 20),
                  _DetailsSectionTitle(localizations.costHistorySection),
                  const SizedBox(height: 8),
                  FutureBuilder<paging.Page<CostHistoryEntry>>(
                    future: _history,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: LinearProgressIndicator(),
                        );
                      }
                      final history =
                          snapshot.data?.items ?? const <CostHistoryEntry>[];
                      if (history.isEmpty) {
                        return Text(localizations.costHistoryEmpty);
                      }
                      return _HistoryList(history: history);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit() async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.data.project.id)}/costs/${Uri.encodeComponent(_entry.id)}/edit',
    );
    if (mounted) widget.onChanged();
  }

  Future<void> _handleAction(_DetailsAction action) async {
    switch (action) {
      case _DetailsAction.copyDraft:
        await _copyDraft();
      case _DetailsAction.markPaid:
        await _markPaid();
      case _DetailsAction.delete:
        await _delete();
    }
  }

  Future<void> _copyDraft() async {
    await _runAction(() async {
      final copy = await widget.gateway.copyAsDraft(
        projectId: widget.data.project.id,
        costEntryId: _entry.id,
      );
      if (mounted) {
        await context.push(
          '/projects/${Uri.encodeComponent(widget.data.project.id)}/costs/${Uri.encodeComponent(copy.id)}/edit',
        );
      }
    });
  }

  Future<void> _markPaid() async {
    await _runAction(
      () => widget.gateway.changeStatus(
        projectId: widget.data.project.id,
        costEntryId: _entry.id,
        status: CostStatus.paid,
      ),
    );
  }

  Future<void> _delete() async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.costDeleteTitle),
        content: Text(localizations.costDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(localizations.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(() async {
      await widget.gateway.delete(
        projectId: widget.data.project.id,
        costEntryId: _entry.id,
      );
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _isWorking = true);
    try {
      await action();
      if (mounted) widget.onChanged();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).costDetailsActionError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }
}

enum _DetailsAction { copyDraft, markPaid, delete }

class _DetailsScaffold extends StatelessWidget {
  const _DetailsScaffold({
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: child,
  );
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(children: children),
  );
}

class _DetailsSectionTitle extends StatelessWidget {
  const _DetailsSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    ),
  );
}

class _DetailsAttachmentList extends StatelessWidget {
  const _DetailsAttachmentList({
    required this.attachments,
    required this.emptyText,
  });

  final List<StagedCostAttachment> attachments;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return Text(emptyText);
    return _DetailGroup(
      children: attachments
          .map(
            (attachment) => ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(
                attachment.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<CostHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return _DetailGroup(
      children: history
          .map(
            (item) => _DetailRow(
              icon: Icons.history_outlined,
              label: _historyLabel(localizations, item.action),
              value: formatCostDate(item.createdAtUtc.toLocal()),
            ),
          )
          .toList(growable: false),
    );
  }
}

String _historyLabel(AppLocalizations l10n, CostHistoryAction value) =>
    switch (value) {
      CostHistoryAction.created => l10n.costHistoryCreated,
      CostHistoryAction.draftSaved => l10n.costHistoryDraftSaved,
      CostHistoryAction.draftReplaced => l10n.costHistoryDraftReplaced,
      CostHistoryAction.confirmed => l10n.costHistoryConfirmed,
      CostHistoryAction.detailsUpdated => l10n.costHistoryDetailsUpdated,
      CostHistoryAction.statusChanged => l10n.costHistoryStatusChanged,
      CostHistoryAction.correctionAdded => l10n.costHistoryCorrectionAdded,
    };
