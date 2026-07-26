import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'cost_editor_gateway.dart';
import 'cost_form_model.dart';

class CostFormScreen extends ConsumerWidget {
  const CostFormScreen({required this.projectId, this.costEntryId, super.key});

  final String projectId;
  final String? costEntryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(costEditorGatewayProvider);
    return gateway.when(
      loading: () => _FormScaffold(
        title: AppLocalizations.of(context).costFormNewTitle,
        child: AppLoadingState(
          label: AppLocalizations.of(context).projectsLoading,
        ),
      ),
      error: (error, stackTrace) => _FormScaffold(
        title: AppLocalizations.of(context).costFormNewTitle,
        child: AppErrorState(
          title: AppLocalizations.of(context).costLoadError,
          retryLabel: AppLocalizations.of(context).retryAction,
          onRetry: () => ref.invalidate(costEditorGatewayProvider),
        ),
      ),
      data: (value) => _CostFormLoader(
        key: ValueKey('$projectId/$costEntryId'),
        gateway: value,
        projectId: projectId,
        costEntryId: costEntryId,
      ),
    );
  }
}

class _CostFormLoader extends StatefulWidget {
  const _CostFormLoader({
    required this.gateway,
    required this.projectId,
    required this.costEntryId,
    super.key,
  });

  final CostEditorGateway gateway;
  final String projectId;
  final String? costEntryId;

  @override
  State<_CostFormLoader> createState() => _CostFormLoaderState();
}

class _CostFormLoaderState extends State<_CostFormLoader> {
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
          return _FormScaffold(
            title: widget.costEntryId == null
                ? localizations.costFormNewTitle
                : localizations.costFormEditTitle,
            child: AppLoadingState(label: localizations.projectsLoading),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _FormScaffold(
            title: widget.costEntryId == null
                ? localizations.costFormNewTitle
                : localizations.costFormEditTitle,
            child: AppErrorState(
              title: snapshot.error is CostEditorNotFoundException
                  ? localizations.costNotFoundError
                  : localizations.costLoadError,
              retryLabel: localizations.retryAction,
              onRetry: _reload,
            ),
          );
        }
        return _CostForm(initialData: snapshot.data!, gateway: widget.gateway);
      },
    );
  }
}

class _CostForm extends StatefulWidget {
  const _CostForm({required this.initialData, required this.gateway});

  final CostEditorData initialData;
  final CostEditorGateway gateway;

  @override
  State<_CostForm> createState() => _CostFormState();
}

class _CostFormState extends State<_CostForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _grossController = TextEditingController();
  final _categoryController = TextEditingController();
  final _supplierController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _categoryFocusNode = FocusNode();
  final _supplierFocusNode = FocusNode();

  late CostEntryType _type;
  late CostStatus _status;
  late VatRate _vatRate;
  late DateTime _entryDate;
  String? _stageId;
  CostPaymentMethod? _paymentMethod;
  late List<StagedCostAttachment> _attachments;
  final _newAttachmentIds = <String>{};
  var _isDirty = false;
  var _isSubmitting = false;
  String? _submissionError;
  Map<CostFormField, CostFormError> _errors = const {};

  CostEntry? get _entry => widget.initialData.entry;
  bool get _financialFieldsLocked =>
      _entry?.lifecycle == CostLifecycle.confirmed;
  bool get _canSaveDraft => !_financialFieldsLocked;

  @override
  void initState() {
    super.initState();
    final input = _entry?.input;
    _nameController.text = input?.name ?? '';
    _grossController.text = input == null
        ? ''
        : formatMinorUnitsForInput(input.amount.gross.minorUnits);
    _stageId = input?.stageId;
    _categoryController.text = input?.categoryId ?? '';
    _supplierController.text = input?.supplierId ?? '';
    _quantityController.text = formatQuantityForInput(input?.quantity);
    _unitController.text = input?.unit ?? '';
    _noteController.text = input?.note ?? '';
    _type = input?.type ?? CostEntryType.cost;
    _status = input != null && validStatusesFor(_type).contains(input.status)
        ? input.status
        : defaultStatusFor(_type);
    _vatRate = input?.amount.rate ?? VatRate.standard23;
    _entryDate = input?.entryDate.toLocal() ?? DateTime.now();
    _paymentMethod = input?.paymentMethod;
    _attachments = List<StagedCostAttachment>.of(
      widget.initialData.attachments,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _grossController.dispose();
    _categoryController.dispose();
    _supplierController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _categoryFocusNode.dispose();
    _supplierFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final preview = _preview();
    return _FormScaffold(
      title: _entry == null
          ? localizations.costFormNewTitle
          : localizations.costFormEditTitle,
      child: SafeArea(
        child: Form(
          key: _formKey,
          canPop: !_isDirty && !_isSubmitting,
          onChanged: _markDirty,
          onPopInvokedWithResult: _handlePopInvoked,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isSubmitting) const LinearProgressIndicator(),
                if (_submissionError != null) ...[
                  _InlineError(message: _submissionError!),
                  const SizedBox(height: 16),
                ],
                _SectionTitle(localizations.costFormBasicsSection),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('costNameField'),
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizations.costNameLabel,
                    prefixIcon: const Icon(Icons.receipt_long_outlined),
                  ),
                  validator: (_) =>
                      _errorText(CostFormField.name, localizations),
                  onChanged: (_) => _clearError(CostFormField.name),
                ),
                const SizedBox(height: 8),
                _ResponsivePair(
                  children: [
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: localizations.costTypeLabel,
                        prefixIcon: const Icon(Icons.sell_outlined),
                      ),
                      child: SegmentedButton<CostEntryType>(
                        key: ValueKey('costType-${_type.name}'),
                        showSelectedIcon: false,
                        segments: CostEntryType.values
                            .map(
                              (value) => ButtonSegment<CostEntryType>(
                                value: value,
                                label: Text(
                                  costTypeLabel(localizations, value),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false),
                        selected: {_type},
                        onSelectionChanged:
                            _financialFieldsLocked || _isSubmitting
                            ? null
                            : (selection) {
                                final value = selection.single;
                                setState(() {
                                  _type = value;
                                  _status = defaultStatusFor(value);
                                  _isDirty = true;
                                });
                              },
                      ),
                    ),
                    DropdownButtonFormField<CostStatus>(
                      key: ValueKey('costStatus-${_status.name}'),
                      initialValue: _status,
                      decoration: InputDecoration(
                        labelText: localizations.costStatusLabel,
                        prefixIcon: const Icon(Icons.task_alt_outlined),
                      ),
                      items: validStatusesFor(_type)
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                costStatusLabel(localizations, value),
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _financialFieldsLocked || _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _status = value;
                                  _isDirty = true;
                                });
                              }
                            },
                      validator: (_) =>
                          _errorText(CostFormField.status, localizations),
                    ),
                  ],
                ),
                if (_financialFieldsLocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    localizations.costFinancialFieldsLocked,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _SectionTitle(localizations.costFormFinancialSection),
                const SizedBox(height: 12),
                _ResponsivePair(
                  children: [
                    TextFormField(
                      key: const ValueKey('costGrossField'),
                      controller: _grossController,
                      enabled: !_financialFieldsLocked && !_isSubmitting,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: localizations.costGrossAmountLabel,
                        prefixIcon: const Icon(Icons.payments_outlined),
                        suffixText: widget.initialData.project.currencyCode,
                      ),
                      validator: (_) =>
                          _errorText(CostFormField.grossAmount, localizations),
                      onChanged: (_) {
                        _clearError(CostFormField.grossAmount);
                        setState(() {});
                      },
                    ),
                    DropdownButtonFormField<VatRate>(
                      key: ValueKey('costVat-${_vatRate.name}'),
                      initialValue: _vatRate,
                      decoration: InputDecoration(
                        labelText: localizations.costVatRateLabel,
                        prefixIcon: const Icon(Icons.percent_outlined),
                      ),
                      items: VatRate.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(costVatLabel(localizations, value)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _financialFieldsLocked || _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _vatRate = value;
                                  _isDirty = true;
                                });
                              }
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ResponsivePair(
                  children: [
                    _CalculatedField(
                      label: localizations.costNetAmountLabel,
                      value: preview == null
                          ? '—'
                          : formatCostMoney(
                              preview.net,
                              widget.initialData.project.currencyCode,
                            ),
                    ),
                    _CalculatedField(
                      label: localizations.costVatAmountLabel,
                      value: preview == null
                          ? '—'
                          : formatCostMoney(
                              preview.vat,
                              widget.initialData.project.currencyCode,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(localizations.costFormDetailsSection),
                const SizedBox(height: 12),
                _DateField(
                  value: formatCostDate(_entryDate),
                  label: localizations.costDateLabel,
                  tooltip: localizations.costDatePickerTooltip,
                  enabled: !_isSubmitting,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                _ResponsivePair(
                  children: [
                    _StageField(
                      projectTemplate: widget.initialData.project.template,
                      projectStages: widget.initialData.stageOptions,
                      value: _stageId,
                      label: localizations.costStageLabel,
                      emptyLabel: localizations.projectValueNotProvided,
                      enabled: !_isSubmitting,
                      onChanged: (value) => setState(() {
                        _stageId = value;
                        _isDirty = true;
                      }),
                    ),
                    _SuggestedDetailField(
                      controller: _categoryController,
                      focusNode: _categoryFocusNode,
                      label: localizations.costCategoryLabel,
                      icon: Icons.category_outlined,
                      options: {
                        ...widget.initialData.categoryOptions,
                        if (_categoryController.text.trim().isNotEmpty)
                          _categoryController.text.trim(),
                      },
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ResponsivePair(
                  children: [
                    _SuggestedDetailField(
                      controller: _supplierController,
                      focusNode: _supplierFocusNode,
                      label: localizations.costSupplierLabel,
                      icon: Icons.storefront_outlined,
                      options: {
                        ...widget.initialData.supplierOptions,
                        if (_supplierController.text.trim().isNotEmpty)
                          _supplierController.text.trim(),
                      },
                      enabled: !_isSubmitting,
                    ),
                    DropdownButtonFormField<CostPaymentMethod?>(
                      key: ValueKey('costPayment-${_paymentMethod?.name}'),
                      initialValue: _paymentMethod,
                      decoration: InputDecoration(
                        labelText: localizations.costPaymentMethodLabel,
                        prefixIcon: const Icon(Icons.credit_card_outlined),
                      ),
                      items: [
                        DropdownMenuItem<CostPaymentMethod?>(
                          value: null,
                          child: Text(localizations.projectValueNotProvided),
                        ),
                        ...CostPaymentMethod.values.map(
                          (value) => DropdownMenuItem<CostPaymentMethod?>(
                            value: value,
                            child: Text(costPaymentLabel(localizations, value)),
                          ),
                        ),
                      ],
                      onChanged: _isSubmitting
                          ? null
                          : (value) => setState(() {
                              _paymentMethod = value;
                              _isDirty = true;
                            }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ResponsivePair(
                  children: [
                    TextFormField(
                      key: const ValueKey('costQuantityField'),
                      controller: _quantityController,
                      enabled: !_isSubmitting,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: localizations.costQuantityLabel,
                        prefixIcon: const Icon(Icons.straighten_outlined),
                      ),
                      validator: (_) =>
                          _errorText(CostFormField.quantity, localizations),
                      onChanged: (_) => _clearError(CostFormField.quantity),
                    ),
                    TextFormField(
                      key: const ValueKey('costUnitField'),
                      controller: _unitController,
                      enabled: !_isSubmitting,
                      maxLength: 24,
                      decoration: InputDecoration(
                        labelText: localizations.costUnitLabel,
                        prefixIcon: const Icon(Icons.square_foot_outlined),
                      ),
                      validator: (_) =>
                          _errorText(CostFormField.unit, localizations),
                      onChanged: (_) => _clearError(CostFormField.unit),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('costNoteField'),
                  controller: _noteController,
                  enabled: !_isSubmitting,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    labelText: localizations.costNoteLabel,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  validator: (_) =>
                      _errorText(CostFormField.note, localizations),
                  onChanged: (_) => _clearError(CostFormField.note),
                ),
                const SizedBox(height: 24),
                _SectionTitle(localizations.costFormDocumentsSection),
                const SizedBox(height: 8),
                if (_attachments.isEmpty)
                  _DocumentWarning(
                    message: localizations.costNoDocumentsWarning,
                  )
                else
                  _AttachmentList(
                    attachments: _attachments,
                    removeTooltip: localizations.costRemoveDocumentTooltip,
                    enabled: !_isSubmitting,
                    removableIds: _newAttachmentIds,
                    onRemove: _removeAttachment,
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const ValueKey('costAddAttachment'),
                  onPressed: _isSubmitting ? null : _addAttachment,
                  icon: const Icon(Icons.attach_file_outlined),
                  label: Text(localizations.costAddDocumentAction),
                ),
                const SizedBox(height: 24),
                if (_canSaveDraft)
                  OutlinedButton.icon(
                    key: const ValueKey('costSaveDraft'),
                    onPressed: _isSubmitting
                        ? null
                        : () => _submit(asDraft: true),
                    icon: const Icon(Icons.bookmark_outline),
                    label: Text(localizations.costSaveDraftAction),
                  ),
                if (_canSaveDraft) const SizedBox(height: 12),
                FilledButton.icon(
                  key: const ValueKey('costSave'),
                  onPressed: _isSubmitting
                      ? null
                      : () => _submit(asDraft: false),
                  icon: Icon(
                    _entry == null ? Icons.save_outlined : Icons.check_outlined,
                  ),
                  label: Text(
                    _financialFieldsLocked
                        ? localizations.costSaveChangesAction
                        : localizations.costSaveAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  VatBreakdown? _preview() {
    final normalized = _grossController.text.replaceAll(
      RegExp(r'[\s\u00A0]'),
      '',
    );
    if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) return null;
    final parts = normalized.replaceAll(',', '.').split('.');
    final cents = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
    try {
      final minorUnits =
          BigInt.parse(parts.first) * BigInt.from(100) + BigInt.parse(cents);
      if (minorUnits > BigInt.from(Money.maximumMinorUnits)) return null;
      return VatBreakdown.fromGross(
        Money(
          minorUnits: minorUnits.toInt(),
          currencyCode: widget.initialData.project.currencyCode,
        ),
        _vatRate,
      );
    } on Object {
      return null;
    }
  }

  CostFormSubmission _submission() {
    return CostFormSubmission(
      name: _nameController.text,
      type: _type,
      status: _status,
      grossAmount: _grossController.text,
      vatRate: _vatRate,
      entryDate: _entryDate,
      stageId: _stageId,
      categoryId: _categoryController.text,
      supplierId: _supplierController.text,
      quantity: _quantityController.text,
      unit: _unitController.text,
      paymentMethod: _paymentMethod,
      note: _noteController.text,
      attachmentIds: _attachments.map((item) => item.id),
    );
  }

  Future<void> _submit({required bool asDraft}) async {
    FocusScope.of(context).unfocus();
    final submission = _submission();
    try {
      parseCostForm(
        submission,
        projectId: widget.initialData.project.id,
        currencyCode: widget.initialData.project.currencyCode,
        asDraft: asDraft,
      );
    } on CostFormValidationException catch (error) {
      setState(() => _errors = error.errors);
      _formKey.currentState!.validate();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
      _errors = const {};
    });
    try {
      await widget.gateway.save(
        initialData: widget.initialData,
        submission: submission,
        asDraft: asDraft,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isDirty = false;
      });
      Navigator.of(context).pop();
    } on CostFormValidationException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errors = error.errors;
      });
      _formKey.currentState!.validate();
    } on Object {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submissionError = AppLocalizations.of(context).costSaveError;
        });
      }
    }
  }

  Future<void> _addAttachment() async {
    try {
      final attachment = await widget.gateway.pickAttachment(
        widget.initialData.project.id,
      );
      if (attachment == null || !mounted) {
        return;
      }
      setState(() {
        _attachments = [..._attachments, attachment];
        _newAttachmentIds.add(attachment.id);
        _isDirty = true;
      });
    } on Object {
      if (mounted) {
        setState(
          () => _submissionError = AppLocalizations.of(
            context,
          ).costDetailsActionError,
        );
      }
    }
  }

  Future<void> _removeAttachment(StagedCostAttachment attachment) async {
    if (!_newAttachmentIds.contains(attachment.id)) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });
    try {
      await widget.gateway.discardAttachment(
        projectId: widget.initialData.project.id,
        attachmentId: attachment.id,
      );
      if (!mounted) return;
      setState(() {
        _attachments = _attachments
            .where((item) => item.id != attachment.id)
            .toList();
        _newAttachmentIds.remove(attachment.id);
        _isSubmitting = false;
        _isDirty = true;
      });
    } on Object {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submissionError = AppLocalizations.of(
            context,
          ).costDetailsActionError;
        });
      }
    }
  }

  Future<bool> _discardNewAttachments() async {
    if (_newAttachmentIds.isEmpty) return true;
    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });
    for (final attachmentId in _newAttachmentIds.toList(growable: false)) {
      try {
        await widget.gateway.discardAttachment(
          projectId: widget.initialData.project.id,
          attachmentId: attachmentId,
        );
      } on Object {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _submissionError = AppLocalizations.of(
              context,
            ).costDetailsActionError;
          });
        }
        return false;
      }
      if (!mounted) return false;
      setState(() {
        _newAttachmentIds.remove(attachmentId);
        _attachments = _attachments
            .where((item) => item.id != attachmentId)
            .toList();
      });
    }
    if (!mounted) return false;
    setState(() => _isSubmitting = false);
    return true;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _entryDate = selected;
      _isDirty = true;
    });
  }

  void _markDirty() {
    if (!_isDirty && !_isSubmitting) setState(() => _isDirty = true);
  }

  void _clearError(CostFormField field) {
    if (!_errors.containsKey(field)) return;
    setState(() => _errors = {..._errors}..remove(field));
  }

  String? _errorText(CostFormField field, AppLocalizations localizations) {
    return switch (_errors[field]) {
      CostFormError.requiredName => localizations.costNameRequiredError,
      CostFormError.nameTooLong => localizations.costNameTooLongError,
      CostFormError.requiredAmount => localizations.costAmountRequiredError,
      CostFormError.invalidAmount => localizations.costAmountInvalidError,
      CostFormError.amountTooLarge => localizations.costAmountTooLargeError,
      CostFormError.quantityAndUnitRequired =>
        localizations.costQuantityUnitRequiredError,
      CostFormError.invalidQuantity => localizations.costQuantityInvalidError,
      CostFormError.noteTooLong => localizations.costNoteTooLongError,
      CostFormError.invalidStatus => localizations.costStatusInvalidError,
      null => null,
    };
  }

  Future<void> _handlePopInvoked(bool didPop, Object? result) async {
    if (didPop || !_isDirty || _isSubmitting) return;
    final localizations = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.unsavedChangesTitle),
        content: Text(localizations.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(localizations.discardChangesAction),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    if (!await _discardNewAttachments() || !mounted) return;
    setState(() => _isDirty = false);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop(result);
  }
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

class _StageField extends StatelessWidget {
  const _StageField({
    required this.projectTemplate,
    required this.projectStages,
    required this.value,
    required this.label,
    required this.emptyLabel,
    required this.enabled,
    required this.onChanged,
  });

  final ProjectTemplate projectTemplate;
  final List<ProjectStage> projectStages;
  final String? value;
  final String label;
  final String emptyLabel;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final stagesById = <String, ProjectStage>{
      for (final stage in projectStages) stage.id: stage,
    };
    final values = projectStages.isEmpty
        ? projectTemplate.definition.stages
              .map(_stageStorageId)
              .toList(growable: true)
        : projectStages.map((stage) => stage.id).toList(growable: true);
    if (value != null && !values.contains(value)) values.add(value!);
    return DropdownButtonFormField<String?>(
      key: ValueKey('costStage-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.flag_outlined),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(emptyLabel, overflow: TextOverflow.ellipsis),
        ),
        ...values.map(
          (stageId) => DropdownMenuItem<String?>(
            value: stageId,
            child: Text(switch (stagesById[stageId]) {
              final stage? => stageName(localizations, stage),
              null => _stageLabel(localizations, stageId),
            }, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _SuggestedDetailField extends StatelessWidget {
  const _SuggestedDetailField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    required this.options,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final Iterable<String> options;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          displayStringForOption: (option) => option,
          optionsBuilder: (text) {
            final query = text.text.trim().toLowerCase();
            final matches = options.where(
              (option) => query.isEmpty || option.toLowerCase().contains(query),
            );
            return matches.toList()..sort();
          },
          fieldViewBuilder:
              (context, fieldController, fieldFocusNode, onSubmitted) {
                return TextFormField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  enabled: enabled,
                  maxLength: 64,
                  decoration: InputDecoration(
                    labelText: label,
                    prefixIcon: Icon(icon),
                  ),
                  onFieldSubmitted: (_) => onSubmitted(),
                );
              },
          optionsViewBuilder: (context, onSelected, availableOptions) {
            final visibleOptions = availableOptions.toList(growable: false);
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: visibleOptions.length,
                      itemBuilder: (context, index) {
                        final option = visibleOptions[index];
                        return ListTile(
                          dense: true,
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              children.first,
              const SizedBox(height: 12),
              children.last,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children.first),
            const SizedBox(width: 12),
            Expanded(child: children.last),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

class _CalculatedField extends StatelessWidget {
  const _CalculatedField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.calculate_outlined),
    ),
    child: Text(
      value,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.label,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final String value;
  final String label;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.calendar_today_outlined),
    ),
    child: Row(
      children: [
        Expanded(child: Text(value)),
        IconButton(
          tooltip: tooltip,
          onPressed: enabled ? onTap : null,
          icon: const Icon(Icons.edit_calendar_outlined),
        ),
      ],
    ),
  );
}

class _DocumentWarning extends StatelessWidget {
  const _DocumentWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({
    required this.attachments,
    required this.removeTooltip,
    required this.enabled,
    required this.removableIds,
    required this.onRemove,
  });

  final List<StagedCostAttachment> attachments;
  final String removeTooltip;
  final bool enabled;
  final Set<String> removableIds;
  final ValueChanged<StagedCostAttachment> onRemove;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: attachments
          .map(
            (attachment) => ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(
                attachment.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: removableIds.contains(attachment.id)
                  ? IconButton(
                      tooltip: removeTooltip,
                      onPressed: enabled ? () => onRemove(attachment) : null,
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
          )
          .toList(growable: false),
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(padding: const EdgeInsets.all(12), child: Text(message)),
  );
}

String formatCostMoney(Money value, String currencyCode) =>
    formatMoneyForDisplay(value, currencyCode);

String formatCostDate(DateTime value) =>
    DateFormat('dd.MM.yyyy', 'pl_PL').format(value);

String costTypeLabel(AppLocalizations l10n, CostEntryType value) =>
    switch (value) {
      CostEntryType.cost => l10n.costTypeCost,
      CostEntryType.offer => l10n.costTypeOffer,
      CostEntryType.planned => l10n.costTypePlanned,
    };

String costStatusLabel(AppLocalizations l10n, CostStatus value) =>
    switch (value) {
      CostStatus.planned => l10n.costStatusPlanned,
      CostStatus.ordered => l10n.costStatusOrdered,
      CostStatus.due => l10n.costStatusDue,
      CostStatus.paid => l10n.costStatusPaid,
      CostStatus.returned => l10n.costStatusReturned,
      CostStatus.disputed => l10n.costStatusDisputed,
    };

String costVatLabel(AppLocalizations l10n, VatRate value) => switch (value) {
  VatRate.zero => l10n.costVatZero,
  VatRate.reduced8 => l10n.costVatReduced,
  VatRate.standard23 => l10n.costVatStandard,
};

String costPaymentLabel(AppLocalizations l10n, CostPaymentMethod value) =>
    switch (value) {
      CostPaymentMethod.cash => l10n.costPaymentCash,
      CostPaymentMethod.card => l10n.costPaymentCard,
      CostPaymentMethod.bankTransfer => l10n.costPaymentBankTransfer,
      CostPaymentMethod.blik => l10n.costPaymentBlik,
      CostPaymentMethod.other => l10n.costPaymentOther,
    };

String _stageStorageId(ProjectStageKey value) => switch (value) {
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

String _stageLabel(AppLocalizations localizations, String stageId) {
  for (final stage in ProjectStageKey.values) {
    if (_stageStorageId(stage) == stageId) {
      return projectStageLabel(localizations, stage);
    }
  }
  return stageId;
}
