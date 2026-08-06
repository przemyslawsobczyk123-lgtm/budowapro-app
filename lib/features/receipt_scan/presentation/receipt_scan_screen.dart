import 'dart:io';

import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/receipt_scan/data/receipt_scan_providers.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_review.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'receipt_scan_controller.dart';

class ReceiptScanScreen extends ConsumerStatefulWidget {
  const ReceiptScanScreen({
    required this.projectId,
    this.gateway,
    this.financialRepository,
    this.currencyCode,
    this.stageOptions = const <ProjectStage>[],
    this.defaultStageId,
    super.key,
  }) : assert(
         (gateway == null &&
                 financialRepository == null &&
                 currencyCode == null) ||
             (gateway != null &&
                 financialRepository != null &&
                 currencyCode != null),
       );

  final String projectId;
  final ReceiptScanGateway? gateway;
  final ReceiptFinancialRepository? financialRepository;
  final String? currencyCode;
  final List<ProjectStage> stageOptions;
  final String? defaultStageId;

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  ReceiptScanController? _controller;
  String? _currencyCode;
  List<ProjectStage> _stages = const <ProjectStage>[];

  @override
  void initState() {
    super.initState();
    final gateway = widget.gateway;
    if (gateway != null) {
      _attachController(
        ReceiptScanDependencies(
          gateway: gateway,
          financialRepository: widget.financialRepository!,
          currencyCode: widget.currencyCode!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_controller == null && widget.gateway == null) {
      final dependencies = ref.watch(
        receiptScanDependenciesProvider(widget.projectId),
      );
      return dependencies.when(
        data: (value) {
          _attachController(value);
          return _screen(l10n, _controller!);
        },
        loading: () => _loadingScreen(l10n),
        error: (_, _) => _gatewayErrorScreen(l10n),
      );
    }
    return _screen(l10n, _controller!);
  }

  Widget _screen(AppLocalizations l10n, ReceiptScanController controller) {
    final state = controller.state;
    return PopScope(
      canPop: !state.isBusy,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.receiptScanTitle)),
        body: SafeArea(
          child: switch (state.status) {
            ReceiptScanViewStatus.idle => _ReceiptScanIdle(
              onScan: () => controller.start(ReceiptCaptureMethod.scanner),
              onImport: () => controller.start(ReceiptCaptureMethod.fileImport),
            ),
            ReceiptScanViewStatus.processing => _ReceiptScanProcessing(
              operation: state.operation!,
            ),
            ReceiptScanViewStatus.result => _ReceiptScanResult(
              session: state.session!,
              draft: state.reviewDraft!,
              duplicateCheck: state.duplicateCheck,
              saveFailed: state.saveFailed,
              currencyCode: _currencyCode!,
              stages: _stages,
              controller: controller,
              onDiscard: controller.discard,
            ),
            ReceiptScanViewStatus.error => _ReceiptScanError(
              state: state,
              onRetryRecognition: controller.retryRecognition,
              onContinueManually: controller.continueManually,
              onScan: () => controller.start(ReceiptCaptureMethod.scanner),
              onImport: () => controller.start(ReceiptCaptureMethod.fileImport),
              onDiscard: controller.discard,
            ),
            ReceiptScanViewStatus.saved => _ReceiptSaved(
              draftCount: state.savedDraftCount!,
              onOpenDrafts: () => context.go('/budget?drafts=1'),
              onDone: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/budget?drafts=1');
                }
              },
            ),
          },
        ),
      ),
    );
  }

  Scaffold _loadingScreen(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptScanTitle)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _gatewayErrorScreen(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptScanTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.receiptGatewayLoadError,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _attachController(ReceiptScanDependencies dependencies) {
    if (_controller != null) return;
    _currencyCode = dependencies.currencyCode;
    _stages = dependencies.stages.isEmpty
        ? widget.stageOptions
        : dependencies.stages;
    _controller = ReceiptScanController(
      projectId: widget.projectId,
      currencyCode: dependencies.currencyCode,
      gateway: dependencies.gateway,
      financialRepository: dependencies.financialRepository,
      defaultStageId: dependencies.defaultStageId ?? widget.defaultStageId,
    )..addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ?..removeListener(_handleControllerChange)
      ..dispose();
    super.dispose();
  }
}

class _ReceiptScanIdle extends StatelessWidget {
  const _ReceiptScanIdle({required this.onScan, required this.onImport});

  final VoidCallback onScan;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const ValueKey('receiptScanIdle'),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      children: [
        Icon(Icons.receipt_long_outlined, size: 48, color: colors.primary),
        const SizedBox(height: 18),
        Text(
          l10n.receiptScanIdleTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.receiptScanIdleMessage,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const ValueKey('scanReceiptButton'),
          onPressed: onScan,
          icon: const Icon(Icons.document_scanner_outlined),
          label: Text(l10n.receiptScanAction),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('importReceiptButton'),
          onPressed: onImport,
          icon: const Icon(Icons.folder_open_outlined),
          label: Text(l10n.receiptImportAction),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.phonelink_lock_outlined,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.receiptScanLocalOnly,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReceiptScanProcessing extends StatelessWidget {
  const _ReceiptScanProcessing({required this.operation});

  final ReceiptScanOperation operation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (operation) {
      ReceiptScanOperation.capture => l10n.receiptCaptureProcessing,
      ReceiptScanOperation.recognition => l10n.receiptRecognitionProcessing,
      ReceiptScanOperation.save => l10n.receiptSaveProcessing,
    };
    return Semantics(
      liveRegion: true,
      child: Padding(
        key: const ValueKey('receiptScanProcessing'),
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ReceiptScanResult extends StatelessWidget {
  const _ReceiptScanResult({
    required this.session,
    required this.draft,
    required this.duplicateCheck,
    required this.saveFailed,
    required this.currencyCode,
    required this.stages,
    required this.controller,
    required this.onDiscard,
  });

  final ReceiptScanSession session;
  final ReceiptReviewDraft draft;
  final ReceiptDuplicateCheck? duplicateCheck;
  final bool saveFailed;
  final String currencyCode;
  final List<ProjectStage> stages;
  final ReceiptScanController controller;
  final Future<void> Function() onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final candidates = session.candidates;
    return CustomScrollView(
      key: const ValueKey('receiptScanResult'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              Text(
                l10n.receiptReviewTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _ReceiptPreview(uri: session.source.previewUri),
              const SizedBox(height: 18),
              _ReceiptReviewTextField(
                fieldKey: const ValueKey('receiptSellerInput'),
                label: l10n.receiptSellerLabel,
                field: draft.seller,
                errorText: _fieldError(
                  l10n,
                  draft,
                  ReceiptReviewFieldKey.seller,
                ),
                onChanged: (value) =>
                    controller.updateField(ReceiptReviewFieldKey.seller, value),
                onConfirm: () =>
                    controller.confirmField(ReceiptReviewFieldKey.seller),
              ),
              const SizedBox(height: 12),
              _ReceiptReviewTextField(
                fieldKey: const ValueKey('receiptDateInput'),
                label: l10n.receiptDateLabel,
                field: draft.date,
                errorText: _fieldError(l10n, draft, ReceiptReviewFieldKey.date),
                keyboardType: TextInputType.datetime,
                onChanged: (value) =>
                    controller.updateField(ReceiptReviewFieldKey.date, value),
                onConfirm: () =>
                    controller.confirmField(ReceiptReviewFieldKey.date),
              ),
              const SizedBox(height: 12),
              _ReceiptReviewTextField(
                fieldKey: const ValueKey('receiptDocumentNumberInput'),
                label: l10n.receiptDocumentNumberLabel,
                field: draft.documentNumber,
                errorText: _fieldError(
                  l10n,
                  draft,
                  ReceiptReviewFieldKey.documentNumber,
                ),
                onChanged: (value) => controller.updateField(
                  ReceiptReviewFieldKey.documentNumber,
                  value,
                ),
                onConfirm: () => controller.confirmField(
                  ReceiptReviewFieldKey.documentNumber,
                ),
              ),
              const SizedBox(height: 12),
              _ReceiptReviewTextField(
                fieldKey: const ValueKey('receiptTotalInput'),
                label: '${l10n.receiptTotalLabel} ($currencyCode)',
                field: draft.total,
                errorText: _fieldError(
                  l10n,
                  draft,
                  ReceiptReviewFieldKey.total,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (value) =>
                    controller.updateField(ReceiptReviewFieldKey.total, value),
                onConfirm: () =>
                    controller.confirmField(ReceiptReviewFieldKey.total),
              ),
              if (candidates.vatLines.isNotEmpty)
                _ReceiptTextSection(
                  heading: l10n.receiptVatLinesLabel,
                  lines: candidates.vatLines.map((line) => line.value),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const ValueKey('receiptStageField'),
                initialValue: draft.stageId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.receiptStageLabel),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.materialNoRelation),
                  ),
                  ...stages.map(
                    (stage) => DropdownMenuItem<String?>(
                      value: _stageId(stage),
                      child: Text(stageName(l10n, stage)),
                    ),
                  ),
                ],
                onChanged: controller.updateStage,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CostComponent?>(
                key: const ValueKey('receiptAllComponentsField'),
                initialValue: null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.receiptApplyComponentLabel,
                ),
                items: CostComponent.values
                    .where((value) => value != CostComponent.unassigned)
                    .map(
                      (value) => DropdownMenuItem<CostComponent?>(
                        value: value,
                        child: Text(_receiptComponentLabel(l10n, value)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) controller.applyComponentToAll(value);
                },
              ),
              if (draft.validationIssues.contains(
                ReceiptReviewIssue.componentRequired,
              )) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.receiptComponentRequiredMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.receiptItemLinesLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('addReceiptItemButton'),
                    tooltip: l10n.receiptAddItemAction,
                    onPressed:
                        draft.items.length < ReviewedReceiptBatch.maximumLines
                        ? controller.addItem
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _itemEditor(context, index),
              childCount: draft.items.length,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              _ReceiptTotalsSummary(
                draft: draft,
                currencyCode: currencyCode,
                onUseItemsTotal: controller.useItemTotalAsDocumentTotal,
                onReplaceItems: () => controller.replaceItemsWithDocumentTotal(
                  name: l10n.receiptSingleItemDefaultName,
                ),
              ),
              if (draft.hasTotalMismatch)
                _ReceiptTotalMismatchNotice(
                  accepted: draft.totalMismatchAccepted,
                  onAccepted: controller.acceptTotalMismatch,
                ),
              if (duplicateCheck case final duplicate?)
                _ReceiptDuplicateNotice(
                  duplicate: duplicate,
                  onContinue: () =>
                      controller.saveReviewed(duplicateAcknowledged: true),
                ),
              if (saveFailed)
                _ReceiptInlineError(message: l10n.receiptSaveError),
              if (!draft.canSubmit &&
                  duplicateCheck == null &&
                  !draft.hasTotalMismatch)
                _ReceiptInlineError(
                  key: const ValueKey('receiptReviewValidation'),
                  message: l10n.receiptValidationMessage,
                ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: Text(l10n.receiptRawTextLabel),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(candidates.recognizedText.value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _BudgetUnchangedNotice(),
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const ValueKey('saveReceiptDraftsButton'),
                onPressed: draft.canSubmit && duplicateCheck == null
                    ? controller.saveReviewed
                    : null,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.receiptSaveDraftsAction),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const ValueKey('discardReceiptResultButton'),
                onPressed: onDiscard,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.receiptDiscardAction),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _itemEditor(BuildContext context, int index) {
    final item = draft.items[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _ReceiptItemEditor(
        key: ValueKey('receiptItem-${item.id}'),
        index: index,
        item: item,
        isLast: index == draft.items.length - 1,
        currencyCode: currencyCode,
        onNameChanged: (value) => controller.updateItem(item.id, name: value),
        onAmountChanged: (value) =>
            controller.updateItem(item.id, grossAmountText: value),
        onVatChanged: (value) => controller.updateItem(item.id, vatRate: value),
        onComponentChanged: (value) =>
            controller.updateItem(item.id, component: value),
        onConfirm: () => controller.confirmItem(item.id),
        onMerge: () => controller.mergeWithNext(index),
        onSplit: () => _splitItem(context, index: index, item: item),
        onRemove: () => controller.removeItem(item.id),
      ),
    );
  }

  Future<void> _splitItem(
    BuildContext context, {
    required int index,
    required ReceiptReviewItem item,
  }) async {
    final result = await showDialog<_ReceiptSplitResult>(
      context: context,
      builder: (context) => _ReceiptSplitDialog(item: item),
    );
    if (result == null) return;
    controller.splitItem(
      index,
      firstName: result.firstName,
      firstGrossAmountText: result.firstAmount,
      secondName: result.secondName,
      secondGrossAmountText: result.secondAmount,
    );
  }
}

class _ReceiptReviewTextField extends StatelessWidget {
  const _ReceiptReviewTextField({
    required this.fieldKey,
    required this.label,
    required this.field,
    required this.onChanged,
    required this.onConfirm,
    this.keyboardType,
    this.errorText,
  });

  final Key fieldKey;
  final String label;
  final ReceiptReviewField field;
  final ValueChanged<String> onChanged;
  final VoidCallback onConfirm;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      key: fieldKey,
      initialValue: field.value,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: field.requiresReview,
        fillColor: field.requiresReview ? colors.tertiaryContainer : null,
        helperText: field.requiresReview
            ? l10n.receiptConfidenceNeedsReview
            : null,
        helperMaxLines: 2,
        errorText: errorText,
        errorMaxLines: 2,
        suffixIcon: field.requiresReview
            ? IconButton(
                tooltip: l10n.receiptConfirmFieldTooltip,
                onPressed: onConfirm,
                icon: const Icon(Icons.check_circle_outline),
              )
            : null,
      ),
    );
  }
}

class _ReceiptItemEditor extends StatefulWidget {
  const _ReceiptItemEditor({
    required this.index,
    required this.item,
    required this.isLast,
    required this.currencyCode,
    required this.onNameChanged,
    required this.onAmountChanged,
    required this.onVatChanged,
    required this.onComponentChanged,
    required this.onConfirm,
    required this.onMerge,
    required this.onSplit,
    required this.onRemove,
    super.key,
  });

  final int index;
  final ReceiptReviewItem item;
  final bool isLast;
  final String currencyCode;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<VatRate> onVatChanged;
  final ValueChanged<CostComponent> onComponentChanged;
  final VoidCallback onConfirm;
  final VoidCallback onMerge;
  final VoidCallback onSplit;
  final VoidCallback onRemove;

  @override
  State<_ReceiptItemEditor> createState() => _ReceiptItemEditorState();
}

class _ReceiptItemEditorState extends State<_ReceiptItemEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _amountController = TextEditingController(
      text: widget.item.grossAmountText,
    );
  }

  @override
  void didUpdateWidget(covariant _ReceiptItemEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_nameController, widget.item.name);
    _syncController(_amountController, widget.item.grossAmountText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final item = widget.item;
    final reviewMessage =
        item.requiresConfidenceReview && item.requiresVatReview
        ? l10n.receiptItemNeedsReview
        : item.requiresVatReview
        ? l10n.receiptItemVatNeedsReview
        : l10n.receiptConfidenceNeedsReview;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: item.requiresReview ? colors.tertiary : colors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: ValueKey('receiptItemName-${item.id}'),
              controller: _nameController,
              onChanged: widget.onNameChanged,
              decoration: InputDecoration(
                labelText: l10n.receiptItemNameLabel,
                errorText: _itemNameError(l10n, item),
                errorMaxLines: 2,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final amountField = _amountField(l10n, item);
                final vatField = _vatField(l10n, item);
                final componentField = _componentField(l10n, item);
                final scaledBodySize = MediaQuery.textScalerOf(
                  context,
                ).scale(14);
                final stackFields =
                    constraints.maxWidth < 300 || scaledBodySize > 20;
                if (stackFields) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      amountField,
                      const SizedBox(height: 10),
                      vatField,
                      const SizedBox(height: 10),
                      componentField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: amountField),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: vatField),
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: componentField),
                  ],
                );
              },
            ),
            if (item.requiresReview) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: colors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reviewMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    key: ValueKey('confirmReceiptItem-${item.id}'),
                    tooltip: l10n.receiptConfirmItemTooltip,
                    onPressed: widget.onConfirm,
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.isLast)
                  IconButton(
                    key: ValueKey('mergeReceiptItem-${widget.index}'),
                    tooltip: l10n.receiptMergeNextTooltip,
                    onPressed: widget.onMerge,
                    icon: const Icon(Icons.call_merge),
                  ),
                IconButton(
                  key: ValueKey('splitReceiptItem-${widget.index}'),
                  tooltip: l10n.receiptSplitTooltip,
                  onPressed: widget.onSplit,
                  icon: const Icon(Icons.call_split),
                ),
                IconButton(
                  key: ValueKey('removeReceiptItem-${item.id}'),
                  tooltip: l10n.receiptRemoveItemTooltip,
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _componentField(AppLocalizations l10n, ReceiptReviewItem item) {
    return DropdownButtonFormField<CostComponent>(
      key: ValueKey('receiptItemComponent-${item.id}'),
      initialValue: item.component,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.costComponentLabel,
        prefixIcon: const Icon(Icons.construction_outlined),
      ),
      items: CostComponent.values
          .map(
            (component) => DropdownMenuItem<CostComponent>(
              value: component,
              child: Text(_componentLabel(l10n, component)),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) widget.onComponentChanged(value);
      },
    );
  }

  Widget _amountField(AppLocalizations l10n, ReceiptReviewItem item) {
    return TextFormField(
      key: ValueKey('receiptItemAmount-${item.id}'),
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: widget.onAmountChanged,
      decoration: InputDecoration(
        labelText: '${l10n.receiptGrossAmountLabel} (${widget.currencyCode})',
        errorText: _itemAmountError(l10n, item),
        errorMaxLines: 2,
      ),
    );
  }

  Widget _vatField(AppLocalizations l10n, ReceiptReviewItem item) {
    return DropdownButtonFormField<VatRate>(
      key: ValueKey('receiptItemVat-${item.id}'),
      initialValue: item.vatRate,
      decoration: InputDecoration(labelText: l10n.receiptVatRateLabel),
      items: VatRate.values
          .map(
            (rate) => DropdownMenuItem<VatRate>(
              value: rate,
              child: Text(_vatLabel(rate)),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) widget.onVatChanged(value);
      },
    );
  }

  String _componentLabel(AppLocalizations l10n, CostComponent value) =>
      switch (value) {
        CostComponent.material => l10n.costComponentMaterial,
        CostComponent.labor => l10n.costComponentLabor,
        CostComponent.mixed => l10n.costComponentMixed,
        CostComponent.unassigned => l10n.costComponentUnassigned,
      };

  static void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _ReceiptTotalsSummary extends StatelessWidget {
  const _ReceiptTotalsSummary({
    required this.draft,
    required this.currencyCode,
    required this.onUseItemsTotal,
    required this.onReplaceItems,
  });

  final ReceiptReviewDraft draft;
  final String currencyCode;
  final VoidCallback onUseItemsTotal;
  final VoidCallback onReplaceItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final itemTotal = draft.itemTotalMinorUnits;
    final documentTotal = draft.receiptTotalMinorUnits;
    final canUseItemsTotal =
        itemTotal != null && itemTotal > 0 && itemTotal != documentTotal;
    final canReplaceItems =
        documentTotal != null &&
        documentTotal > 0 &&
        (draft.items.length != 1 ||
            itemTotal != documentTotal ||
            draft.items.single.name.trim().isEmpty);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.receiptItemsTotalLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                itemTotal == null
                    ? '—'
                    : '${formatReceiptMinorUnits(itemTotal)} $currencyCode',
                key: const ValueKey('receiptItemsTotalValue'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          if (canUseItemsTotal) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('useReceiptItemsTotalButton'),
              onPressed: onUseItemsTotal,
              icon: const Icon(Icons.calculate_outlined),
              label: Text(l10n.receiptUseItemsTotalAction),
            ),
          ],
          if (canReplaceItems) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('replaceReceiptItemsWithDocumentTotalButton'),
              onPressed: onReplaceItems,
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(l10n.receiptReplaceItemsAction),
            ),
          ],
        ],
      ),
    );
  }
}

String _receiptComponentLabel(AppLocalizations l10n, CostComponent value) =>
    switch (value) {
      CostComponent.material => l10n.costComponentMaterial,
      CostComponent.labor => l10n.costComponentLabor,
      CostComponent.mixed => l10n.costComponentMixed,
      CostComponent.unassigned => l10n.costComponentUnassigned,
    };

String _stageId(ProjectStage stage) {
  final key = stage.templateKey;
  return key == null
      ? stage.id
      : switch (key) {
          ProjectStageKey.planning => 'planning',
          ProjectStageKey.formalities => 'formalities',
          ProjectStageKey.sitePreparation => 'site_preparation',
          ProjectStageKey.stateZero => 'state_zero',
          ProjectStageKey.shellOpen => 'shell_open',
          ProjectStageKey.shellClosed => 'shell_closed',
          ProjectStageKey.demolition => 'demolition',
          ProjectStageKey.installations => 'installations',
          ProjectStageKey.plaster => 'plaster',
          ProjectStageKey.finishing => 'finishing',
          ProjectStageKey.handover => 'handover',
        };
}

class _ReceiptTotalMismatchNotice extends StatelessWidget {
  const _ReceiptTotalMismatchNotice({
    required this.accepted,
    required this.onAccepted,
  });

  final bool accepted;
  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('receiptTotalMismatch'),
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.receiptTotalMismatchTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(l10n.receiptTotalMismatchMessage),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: accepted,
            onChanged: accepted ? null : (_) => onAccepted(),
            title: Text(l10n.receiptTotalMismatchAction),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _ReceiptDuplicateNotice extends StatelessWidget {
  const _ReceiptDuplicateNotice({
    required this.duplicate,
    required this.onContinue,
  });

  final ReceiptDuplicateCheck duplicate;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final canOverride = !duplicate.reasons.contains(
      ReceiptDuplicateReason.sameAttachment,
    );
    return Container(
      key: const ValueKey('receiptDuplicateWarning'),
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.receiptDuplicateTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            canOverride
                ? l10n.receiptDuplicateMessage
                : l10n.receiptDuplicateAlreadySavedMessage,
          ),
          const SizedBox(height: 8),
          ...duplicate.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_duplicateLabel(l10n, reason))),
                ],
              ),
            ),
          ),
          if (canOverride) ...[
            const SizedBox(height: 10),
            FilledButton(
              key: const ValueKey('saveDuplicateReceiptButton'),
              onPressed: onContinue,
              child: Text(l10n.receiptDuplicateContinueAction),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReceiptInlineError extends StatelessWidget {
  const _ReceiptInlineError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ReceiptSaved extends StatelessWidget {
  const _ReceiptSaved({
    required this.draftCount,
    required this.onOpenDrafts,
    required this.onDone,
  });

  final int draftCount;
  final VoidCallback onOpenDrafts;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const ValueKey('receiptSaved'),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      children: [
        Icon(Icons.task_alt, size: 52, color: colors.primary),
        const SizedBox(height: 18),
        Text(
          l10n.receiptSavedTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(l10n.receiptSavedMessage(draftCount), textAlign: TextAlign.center),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onOpenDrafts,
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: Text(l10n.receiptOpenDraftsAction),
        ),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: onDone, child: Text(l10n.receiptDoneAction)),
      ],
    );
  }
}

final class _ReceiptSplitResult {
  const _ReceiptSplitResult({
    required this.firstName,
    required this.firstAmount,
    required this.secondName,
    required this.secondAmount,
  });

  final String firstName;
  final String firstAmount;
  final String secondName;
  final String secondAmount;
}

class _ReceiptSplitDialog extends StatefulWidget {
  const _ReceiptSplitDialog({required this.item});

  final ReceiptReviewItem item;

  @override
  State<_ReceiptSplitDialog> createState() => _ReceiptSplitDialogState();
}

class _ReceiptSplitDialogState extends State<_ReceiptSplitDialog> {
  late final TextEditingController _firstName;
  late final TextEditingController _firstAmount;
  late final TextEditingController _secondName;
  late final TextEditingController _secondAmount;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.item.name);
    _firstAmount = TextEditingController(text: widget.item.grossAmountText);
    _secondName = TextEditingController();
    _secondAmount = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _firstAmount.dispose();
    _secondName.dispose();
    _secondAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.receiptSplitTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.receiptSplitFirstHeading,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstName,
              decoration: InputDecoration(labelText: l10n.receiptItemNameLabel),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstAmount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.receiptGrossAmountLabel,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.receiptSplitSecondHeading,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _secondName,
              decoration: InputDecoration(labelText: l10n.receiptItemNameLabel),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _secondAmount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.receiptGrossAmountLabel,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _ReceiptSplitResult(
              firstName: _firstName.text,
              firstAmount: _firstAmount.text,
              secondName: _secondName.text,
              secondAmount: _secondAmount.text,
            ),
          ),
          child: Text(l10n.receiptSplitApplyAction),
        ),
      ],
    );
  }
}

class _ReceiptScanError extends StatelessWidget {
  const _ReceiptScanError({
    required this.state,
    required this.onRetryRecognition,
    required this.onContinueManually,
    required this.onScan,
    required this.onImport,
    required this.onDiscard,
  });

  final ReceiptScanViewState state;
  final VoidCallback onRetryRecognition;
  final VoidCallback onContinueManually;
  final VoidCallback onScan;
  final VoidCallback onImport;
  final Future<void> Function() onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.failureKind!;
    final (title, message) = _errorText(l10n, failure);
    return ListView(
      key: const ValueKey('receiptScanError'),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      children: [
        Icon(
          Icons.error_outline,
          size: 44,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (state.source != null)
          FilledButton.icon(
            key: const ValueKey('retryReceiptOcrButton'),
            onPressed: onRetryRecognition,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.receiptRetryOcrAction),
          )
        else
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.document_scanner_outlined),
            label: Text(l10n.receiptScanAction),
          ),
        if (state.source != null &&
            failure == ReceiptScanFailureKind.emptyText) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const ValueKey('receiptManualEntryButton'),
            onPressed: onContinueManually,
            icon: const Icon(Icons.edit_note_outlined),
            label: Text(l10n.receiptManualEntryAction),
          ),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('receiptFallbackImportButton'),
          onPressed: state.source == null ? onImport : null,
          icon: const Icon(Icons.folder_open_outlined),
          label: Text(l10n.receiptImportAction),
        ),
        if (state.source != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onDiscard,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.receiptDiscardAction),
          ),
        ],
      ],
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Image.file(
        File.fromUri(uri),
        fit: BoxFit.contain,
        cacheWidth: 1200,
        errorBuilder: (_, _, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(l10n.receiptPreviewUnavailable),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptTextSection extends StatelessWidget {
  const _ReceiptTextSection({required this.heading, required this.lines});

  final String heading;
  final Iterable<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...lines
              .take(20)
              .map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(line),
                ),
              ),
        ],
      ),
    );
  }
}

class _BudgetUnchangedNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: const ValueKey('receiptBudgetUnchanged'),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.fact_check_outlined, color: colors.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.receiptBudgetUnchangedTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.receiptBudgetUnchangedMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSecondaryContainer,
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

String? _fieldError(
  AppLocalizations l10n,
  ReceiptReviewDraft draft,
  ReceiptReviewFieldKey key,
) {
  final issues = draft.validationIssues;
  return switch (key) {
    ReceiptReviewFieldKey.seller =>
      issues.contains(ReceiptReviewIssue.sellerRequired)
          ? l10n.receiptSellerRequiredError
          : issues.contains(ReceiptReviewIssue.invalidSeller)
          ? l10n.receiptSellerInvalidError
          : null,
    ReceiptReviewFieldKey.date =>
      issues.contains(ReceiptReviewIssue.dateRequired)
          ? l10n.receiptDateRequiredError
          : issues.contains(ReceiptReviewIssue.invalidDate)
          ? l10n.receiptDateInvalidError
          : null,
    ReceiptReviewFieldKey.documentNumber =>
      issues.contains(ReceiptReviewIssue.invalidDocumentNumber)
          ? l10n.receiptDocumentNumberInvalidError
          : null,
    ReceiptReviewFieldKey.total =>
      issues.contains(ReceiptReviewIssue.totalRequired)
          ? l10n.receiptTotalRequiredError
          : issues.contains(ReceiptReviewIssue.invalidTotal)
          ? l10n.receiptTotalInvalidError
          : null,
  };
}

String? _itemNameError(AppLocalizations l10n, ReceiptReviewItem item) {
  if (item.name.trim().isEmpty) return l10n.receiptItemNameRequiredError;
  if (!isValidReviewedReceiptLineName(item.name)) {
    return l10n.receiptItemNameInvalidError;
  }
  return null;
}

String? _itemAmountError(AppLocalizations l10n, ReceiptReviewItem item) {
  final amount = parseReceiptMinorUnits(item.grossAmountText);
  return (amount ?? 0) <= 0 ? l10n.receiptItemAmountInvalidError : null;
}

String _vatLabel(VatRate rate) => switch (rate) {
  VatRate.zero => '0%',
  VatRate.reduced8 => '8%',
  VatRate.standard23 => '23%',
};

String _duplicateLabel(AppLocalizations l10n, ReceiptDuplicateReason reason) {
  return switch (reason) {
    ReceiptDuplicateReason.sameAttachment =>
      l10n.receiptDuplicateSameAttachmentReason,
    ReceiptDuplicateReason.fileHash => l10n.receiptDuplicateFileReason,
    ReceiptDuplicateReason.receiptSignature =>
      l10n.receiptDuplicateSignatureReason,
  };
}

(String, String) _errorText(
  AppLocalizations l10n,
  ReceiptScanFailureKind kind,
) {
  return switch (kind) {
    ReceiptScanFailureKind.scannerUnavailable => (
      l10n.receiptScannerUnavailableTitle,
      l10n.receiptScannerUnavailableMessage,
    ),
    ReceiptScanFailureKind.unsupportedInput => (
      l10n.receiptUnsupportedTitle,
      l10n.receiptUnsupportedMessage,
    ),
    ReceiptScanFailureKind.emptyText => (
      l10n.receiptEmptyTextTitle,
      l10n.receiptEmptyTextMessage,
    ),
    ReceiptScanFailureKind.storage => (
      l10n.receiptStorageErrorTitle,
      l10n.receiptStorageErrorMessage,
    ),
    ReceiptScanFailureKind.recognition => (
      l10n.receiptRecognitionErrorTitle,
      l10n.receiptRecognitionErrorMessage,
    ),
  };
}
