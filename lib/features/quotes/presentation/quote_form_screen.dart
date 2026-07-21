import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'quote_editor_gateway.dart';
import 'quote_form_model.dart';

class QuoteFormScreen extends ConsumerWidget {
  const QuoteFormScreen({
    required this.projectId,
    this.quoteId,
    this.initialContactId,
    super.key,
  });

  final String projectId;
  final String? quoteId;
  final String? initialContactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(quoteEditorGatewayProvider);
    return gateway.when(
      loading: () => _FormScaffold(
        title: AppLocalizations.of(context).quoteNewTitle,
        child: AppLoadingState(
          label: AppLocalizations.of(context).quoteNewTitle,
        ),
      ),
      error: (error, stackTrace) => _FormScaffold(
        title: AppLocalizations.of(context).quoteNewTitle,
        child: AppErrorState(
          title: AppLocalizations.of(context).quoteLoadError,
          retryLabel: AppLocalizations.of(context).retryAction,
          onRetry: () => ref.invalidate(quoteEditorGatewayProvider),
        ),
      ),
      data: (value) => _QuoteFormLoader(
        key: ValueKey('$projectId/$quoteId/$initialContactId'),
        gateway: value,
        projectId: projectId,
        quoteId: quoteId,
        initialContactId: initialContactId,
      ),
    );
  }
}

class _QuoteFormLoader extends StatefulWidget {
  const _QuoteFormLoader({
    required this.gateway,
    required this.projectId,
    required this.quoteId,
    required this.initialContactId,
    super.key,
  });

  final QuoteEditorGateway gateway;
  final String projectId;
  final String? quoteId;
  final String? initialContactId;

  @override
  State<_QuoteFormLoader> createState() => _QuoteFormLoaderState();
}

class _QuoteFormLoaderState extends State<_QuoteFormLoader> {
  late Future<QuoteEditorData> _load;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<QuoteEditorData> _request() =>
      widget.gateway.load(projectId: widget.projectId, quoteId: widget.quoteId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<QuoteEditorData>(
      future: _load,
      builder: (context, snapshot) {
        final title = widget.quoteId == null
            ? l10n.quoteNewTitle
            : l10n.quoteEditTitle;
        if (snapshot.connectionState != ConnectionState.done) {
          return _FormScaffold(
            title: title,
            child: AppLoadingState(label: title),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _FormScaffold(
            title: title,
            child: AppErrorState(
              title: snapshot.error is QuoteEditorNotFoundException
                  ? l10n.quoteNotFoundTitle
                  : l10n.quoteLoadError,
              retryLabel: l10n.retryAction,
              onRetry: () => setState(() => _load = _request()),
            ),
          );
        }
        return _QuoteForm(
          gateway: widget.gateway,
          data: snapshot.data!,
          initialContactId: widget.initialContactId,
        );
      },
    );
  }
}

class _QuoteForm extends StatefulWidget {
  const _QuoteForm({
    required this.gateway,
    required this.data,
    required this.initialContactId,
  });

  final QuoteEditorGateway gateway;
  final QuoteEditorData data;
  final String? initialContactId;

  @override
  State<_QuoteForm> createState() => _QuoteFormState();
}

class _QuoteFormState extends State<_QuoteForm> {
  final _titleController = TextEditingController();
  final _variantController = TextEditingController();
  final _grossController = TextEditingController();
  final _noteController = TextEditingController();
  final _includedControllers = <TextEditingController>[];
  final _excludedControllers = <TextEditingController>[];
  final _newAttachmentIds = <String>{};
  final _removedAttachmentIds = <String>{};

  String? _contactId;
  String? _stageId;
  late VatRate _vatRate;
  late DateTime _receivedAt;
  late DateTime _validUntil;
  late List<StagedCostAttachment> _attachments;
  var _isDirty = false;
  var _isSubmitting = false;
  var _allowPop = false;
  String? _error;

  ContractorQuote? get _quote => widget.data.quote;

  @override
  void initState() {
    super.initState();
    final draft = _quote?.draft;
    _titleController.text = draft?.title ?? '';
    _variantController.text = draft?.variantName ?? '';
    _grossController.text = draft == null
        ? ''
        : formatMinorUnitsForInput(draft.amount.gross.minorUnits);
    _noteController.text = draft?.note ?? '';
    _contactId = draft?.contactId ?? _validInitialContact();
    _stageId = draft?.stageId;
    _vatRate = draft?.amount.rate ?? VatRate.standard23;
    _receivedAt = draft?.receivedAtUtc.toLocal() ?? DateTime.now();
    _validUntil =
        draft?.validUntilUtc.toLocal() ??
        DateTime.now().add(const Duration(days: 30));
    _attachments = List<StagedCostAttachment>.of(widget.data.attachments);
    _fillControllers(_includedControllers, draft?.includedScope);
    _fillControllers(
      _excludedControllers,
      draft?.excludedScope,
      optional: true,
    );
  }

  String? _validInitialContact() {
    final id = widget.initialContactId;
    if (id == null) return null;
    return widget.data.contacts.any((contact) => contact.id == id) ? id : null;
  }

  static void _fillControllers(
    List<TextEditingController> target,
    List<QuoteScopeLine>? source, {
    bool optional = false,
  }) {
    if (source == null || source.isEmpty) {
      if (!optional) target.add(TextEditingController());
      return;
    }
    target.addAll(
      source.map((line) => TextEditingController(text: line.label)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _variantController.dispose();
    _grossController.dispose();
    _noteController.dispose();
    for (final controller in [
      ..._includedControllers,
      ..._excludedControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _FormScaffold(
      title: _quote == null ? l10n.quoteNewTitle : l10n.quoteEditTitle,
      child: PopScope<bool>(
        canPop: _allowPop || !_isDirty,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _confirmDiscard();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isSubmitting) const LinearProgressIndicator(),
                if (_error != null) ...[
                  _InlineError(message: _error!),
                  const SizedBox(height: 12),
                ],
                _SectionTitle(l10n.quoteContractorLabel),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey('quoteContact-${_contactId ?? 'none'}'),
                  initialValue: _contactId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.quoteContractorLabel,
                    prefixIcon: const Icon(Icons.engineering_outlined),
                  ),
                  items: widget.data.contacts
                      .map(
                        (contact) => DropdownMenuItem(
                          value: contact.id,
                          child: Text(
                            contact.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _isSubmitting
                      ? null
                      : (value) => _change(() => _contactId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('quoteTitleField'),
                  controller: _titleController,
                  enabled: !_isSubmitting,
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.quoteTitleLabel,
                    prefixIcon: const Icon(Icons.request_quote_outlined),
                  ),
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 4),
                TextField(
                  key: const ValueKey('quoteVariantField'),
                  controller: _variantController,
                  enabled: !_isSubmitting,
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.quoteVariantLabel,
                    prefixIcon: const Icon(Icons.tune_outlined),
                  ),
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.quoteGrossAmountLabel),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final amount = TextField(
                      key: const ValueKey('quoteGrossField'),
                      controller: _grossController,
                      enabled: !_isSubmitting,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.quoteGrossAmountLabel,
                        prefixIcon: const Icon(Icons.payments_outlined),
                        suffixText: widget.data.project.currencyCode,
                      ),
                      onChanged: (_) => _markDirty(),
                    );
                    final vat = DropdownButtonFormField<VatRate>(
                      key: ValueKey('quoteVat-${_vatRate.name}'),
                      initialValue: _vatRate,
                      decoration: InputDecoration(
                        labelText: l10n.quoteVatRateLabel,
                        prefixIcon: const Icon(Icons.percent_outlined),
                      ),
                      items: VatRate.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_vatLabel(l10n, value)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                _change(() => _vatRate = value);
                              }
                            },
                    );
                    if (constraints.maxWidth < 560) {
                      return Column(
                        children: [amount, const SizedBox(height: 12), vat],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: amount),
                        const SizedBox(width: 12),
                        Expanded(child: vat),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  key: ValueKey('quoteStage-${_stageId ?? 'none'}'),
                  initialValue: _stageId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.quoteStageLabel,
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.quoteNoStage),
                    ),
                    ...widget.data.stages.map(
                      (stage) => DropdownMenuItem(
                        value: stage.id,
                        child: Text(
                          stageName(l10n, stage),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) => _change(() => _stageId = value),
                ),
                const SizedBox(height: 12),
                _DatePair(
                  receivedAt: _receivedAt,
                  validUntil: _validUntil,
                  enabled: !_isSubmitting,
                  onReceived: () => _pickDate(received: true),
                  onValidUntil: () => _pickDate(received: false),
                ),
                const SizedBox(height: 24),
                _ScopeEditor(
                  heading: l10n.quoteIncludedScopeHeading,
                  controllers: _includedControllers,
                  required: true,
                  enabled: !_isSubmitting,
                  onAdd: () => _addScope(_includedControllers),
                  onRemove: (index) =>
                      _removeScope(_includedControllers, index),
                  onChanged: _markDirty,
                ),
                const SizedBox(height: 20),
                _ScopeEditor(
                  heading: l10n.quoteExcludedScopeHeading,
                  controllers: _excludedControllers,
                  required: false,
                  enabled: !_isSubmitting,
                  onAdd: () => _addScope(_excludedControllers),
                  onRemove: (index) =>
                      _removeScope(_excludedControllers, index),
                  onChanged: _markDirty,
                ),
                const SizedBox(height: 24),
                _SectionTitle(l10n.quoteAttachmentsHeading),
                const SizedBox(height: 8),
                ..._attachments.map(
                  (attachment) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      attachment.mediaType?.startsWith('image/') == true
                          ? Icons.image_outlined
                          : Icons.picture_as_pdf_outlined,
                    ),
                    title: Text(
                      attachment.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: l10n.deleteAction,
                      onPressed: _isSubmitting
                          ? null
                          : () => _removeAttachment(attachment),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('quoteAddAttachmentButton'),
                  onPressed: _isSubmitting ? null : _pickAttachment,
                  icon: const Icon(Icons.attach_file),
                  label: Text(l10n.quoteAddAttachmentAction),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _noteController,
                  enabled: !_isSubmitting,
                  maxLength: 2000,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.quoteNoteLabel,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const ValueKey('saveQuoteButton'),
                  onPressed: _isSubmitting ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.saveAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _change(VoidCallback change) {
    setState(() {
      change();
      _isDirty = true;
      _error = null;
    });
  }

  void _markDirty() {
    if (!_isDirty || _error != null) {
      setState(() {
        _isDirty = true;
        _error = null;
      });
    }
  }

  void _addScope(List<TextEditingController> target) {
    _change(() => target.add(TextEditingController()));
  }

  void _removeScope(List<TextEditingController> target, int index) {
    final controller = target.removeAt(index);
    controller.dispose();
    _change(() {});
  }

  Future<void> _pickDate({required bool received}) async {
    final current = received ? _receivedAt : _validUntil;
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    _change(() {
      if (received) {
        _receivedAt = selected;
      } else {
        _validUntil = selected;
      }
    });
  }

  Future<void> _pickAttachment() async {
    try {
      final attachment = await widget.gateway.pickAttachment(
        widget.data.project.id,
      );
      if (attachment == null || !mounted) return;
      setState(() {
        _attachments.add(attachment);
        _newAttachmentIds.add(attachment.id);
        _isDirty = true;
      });
    } on Object {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).quoteAttachmentError,
        );
      }
    }
  }

  Future<void> _removeAttachment(StagedCostAttachment attachment) async {
    setState(() {
      _attachments.removeWhere((item) => item.id == attachment.id);
      _isDirty = true;
    });
    if (_newAttachmentIds.remove(attachment.id)) {
      await widget.gateway.discardIfUnlinked(
        projectId: widget.data.project.id,
        attachmentId: attachment.id,
      );
    } else {
      _removedAttachmentIds.add(attachment.id);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final included = _scope(_includedControllers);
    final excluded = _scope(_excludedControllers);
    if (_contactId == null ||
        _titleController.text.trim().isEmpty ||
        _variantController.text.trim().isEmpty ||
        included.isEmpty) {
      setState(() => _error = l10n.quoteRequiredFieldsError);
      return;
    }
    if (_validUntil.isBefore(_receivedAt)) {
      setState(() => _error = l10n.quoteInvalidValidityError);
      return;
    }
    late final VatBreakdown amount;
    try {
      amount = parseQuoteAmount(
        grossAmount: _grossController.text,
        currencyCode: widget.data.project.currencyCode,
        vatRate: _vatRate,
      );
    } on QuoteAmountFormatException {
      setState(() => _error = l10n.quoteInvalidAmountError);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.gateway.save(
        projectId: widget.data.project.id,
        quoteId: _quote?.id,
        draft: ContractorQuoteDraft(
          contactId: _contactId!,
          title: _titleController.text,
          variantName: _variantController.text,
          amount: amount,
          receivedAt: _startOfDay(_receivedAt),
          validUntil: _endOfDay(_validUntil),
          includedScope: included,
          excludedScope: excluded,
          attachmentIds: _attachments.map((attachment) => attachment.id),
          stageId: _stageId,
          note: _noteController.text,
        ),
      );
      for (final attachmentId in _removedAttachmentIds) {
        await widget.gateway.discardIfUnlinked(
          projectId: widget.data.project.id,
          attachmentId: attachmentId,
        );
      }
      _allowPop = true;
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = l10n.quoteSaveError;
        });
      }
    }
  }

  List<QuoteScopeLine> _scope(List<TextEditingController> controllers) =>
      controllers
          .map((controller) => controller.text.trim())
          .where((value) => value.isNotEmpty)
          .map((value) => QuoteScopeLine(label: value))
          .toList(growable: false);

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discardChangesAction),
          ),
        ],
      ),
    );
    if (discard != true) return;
    for (final attachmentId in _newAttachmentIds) {
      await widget.gateway.discardIfUnlinked(
        projectId: widget.data.project.id,
        attachmentId: attachmentId,
      );
    }
    _allowPop = true;
    if (mounted) Navigator.pop(context);
  }
}

class _DatePair extends StatelessWidget {
  const _DatePair({
    required this.receivedAt,
    required this.validUntil,
    required this.enabled,
    required this.onReceived,
    required this.onValidUntil,
  });

  final DateTime receivedAt;
  final DateTime validUntil;
  final bool enabled;
  final VoidCallback onReceived;
  final VoidCallback onValidUntil;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat.yMd('pl');
    Widget field(String label, DateTime value, VoidCallback onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: enabled ? onTap : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(format.format(value)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final first = field(
          l10n.quoteReceivedDateLabel,
          receivedAt,
          onReceived,
        );
        final second = field(
          l10n.quoteValidUntilLabel,
          validUntil,
          onValidUntil,
        );
        if (constraints.maxWidth < 560) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _ScopeEditor extends StatelessWidget {
  const _ScopeEditor({
    required this.heading,
    required this.controllers,
    required this.required,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final String heading;
  final List<TextEditingController> controllers;
  final bool required;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _SectionTitle(heading)),
            IconButton(
              tooltip: l10n.quoteAddScopeLineTooltip,
              onPressed: enabled ? onAdd : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        if (controllers.isEmpty && !required)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: enabled ? onAdd : null,
              icon: const Icon(Icons.add),
              label: Text(l10n.quoteAddScopeLineTooltip),
            ),
          ),
        for (var index = 0; index < controllers.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey('$heading-$index'),
                  controller: controllers[index],
                  enabled: enabled,
                  maxLength: 160,
                  decoration: InputDecoration(
                    labelText: l10n.quoteScopeLineLabel,
                    prefixIcon: const Icon(Icons.checklist_outlined),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              IconButton(
                tooltip: l10n.quoteRemoveScopeLineTooltip,
                onPressed: enabled && (!required || controllers.length > 1)
                    ? () => onRemove(index)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
          if (index + 1 < controllers.length) const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleSmall);
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    ),
  );
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: child,
  );
}

String _vatLabel(AppLocalizations l10n, VatRate rate) => switch (rate) {
  VatRate.zero => l10n.costVatZero,
  VatRate.reduced8 => l10n.costVatReduced,
  VatRate.standard23 => l10n.costVatStandard,
};

DateTime _startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _endOfDay(DateTime value) => DateTime(
  value.year,
  value.month,
  value.day + 1,
).subtract(const Duration(milliseconds: 1));
