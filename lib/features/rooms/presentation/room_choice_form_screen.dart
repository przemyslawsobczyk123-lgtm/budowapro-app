import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/rooms/data/room_providers.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/features/rooms/presentation/rooms_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RoomChoiceFormScreen extends ConsumerStatefulWidget {
  const RoomChoiceFormScreen({
    required this.projectId,
    required this.roomId,
    this.choiceId,
    super.key,
  });

  final String projectId;
  final String roomId;
  final String? choiceId;

  @override
  ConsumerState<RoomChoiceFormScreen> createState() =>
      _RoomChoiceFormScreenState();
}

class _RoomChoiceFormScreenState extends ConsumerState<RoomChoiceFormScreen> {
  late Future<_ChoiceEditorData> _load;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<_ChoiceEditorData> _request() async {
    final projects = await ref.read(projectsControllerProvider.future);
    Project? project;
    for (final candidate in projects.projects) {
      if (candidate.id == widget.projectId) project = candidate;
    }
    if (project == null) throw const RoomNotFoundException();
    final repository = await ref.read(roomRepositoryProvider.future);
    final details = await repository.findRoomDetails(
      projectId: widget.projectId,
      roomId: widget.roomId,
    );
    if (details == null) throw const RoomNotFoundException();
    RoomChoice? choice;
    final choiceId = widget.choiceId;
    if (choiceId != null) {
      for (final candidate in details.choices) {
        if (candidate.id == choiceId) choice = candidate;
      }
      if (choice == null) throw const RoomChoiceNotFoundException();
    }
    return _ChoiceEditorData(
      project: project,
      room: details.overview.room,
      repository: repository,
      choice: choice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.choiceId == null
        ? l10n.roomChoiceNewTitle
        : l10n.roomChoiceEditTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<_ChoiceEditorData>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: title);
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return AppErrorState(
              title:
                  snapshot.error is RoomNotFoundException ||
                      snapshot.error is RoomChoiceNotFoundException
                  ? l10n.roomNotFound
                  : l10n.roomsLoadError,
              retryLabel: l10n.retryAction,
              onRetry: () => setState(() {
                _load = _request();
              }),
            );
          }
          return _ChoiceForm(
            key: ValueKey('${widget.roomId}/${widget.choiceId}'),
            data: snapshot.data!,
            onSaved: () {
              ref.invalidate(roomsControllerProvider);
              if (context.mounted) Navigator.of(context).pop(true);
            },
          );
        },
      ),
    );
  }
}

final class _ChoiceEditorData {
  const _ChoiceEditorData({
    required this.project,
    required this.room,
    required this.repository,
    required this.choice,
  });

  final Project project;
  final Room room;
  final RoomRepository repository;
  final RoomChoice? choice;
}

class _ChoiceForm extends StatefulWidget {
  const _ChoiceForm({required this.data, required this.onSaved, super.key});

  final _ChoiceEditorData data;
  final VoidCallback onSaved;

  @override
  State<_ChoiceForm> createState() => _ChoiceFormState();
}

class _ChoiceFormState extends State<_ChoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController();
  final _waste = TextEditingController();
  final _note = TextEditingController();
  final _variants = <_VariantControllers>[];
  DateTime? _orderDue;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final choice = widget.data.choice;
    _title.text = choice?.input.title ?? '';
    final quantity = choice?.input.quantity;
    _quantity.text = quantity == null
        ? ''
        : _formatDecimal(quantity.unscaledValue, quantity.scale);
    _unit.text = choice?.input.unit ?? '';
    _waste.text = choice == null
        ? '10'
        : _formatDecimal(choice.input.wasteBasisPoints, 2);
    _note.text = choice?.input.note ?? '';
    _orderDue = choice?.input.orderDueUtc?.toLocal();
    if (choice == null) {
      _variants.add(_VariantControllers());
    } else {
      _variants.addAll(choice.variants.map(_VariantControllers.fromVariant));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _quantity.dispose();
    _unit.dispose();
    _waste.dispose();
    _note.dispose();
    for (final variant in _variants) {
      variant.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (widget.data.choice?.status == RoomChoiceStatus.selected)
            Material(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l10n.roomSelectedChoiceEditNotice)),
                  ],
                ),
              ),
            ),
          if (widget.data.choice?.status == RoomChoiceStatus.selected)
            const SizedBox(height: 12),
          TextFormField(
            key: const ValueKey('roomChoiceTitleField'),
            controller: _title,
            maxLength: RoomFieldLimits.choiceTitle,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.roomChoiceTitleLabel),
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.requiredFieldError
                : null,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final quantity = TextFormField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.roomChoiceQuantityLabel,
                ),
                validator: _quantityValidator,
              );
              final unit = TextFormField(
                controller: _unit,
                maxLength: 24,
                decoration: InputDecoration(
                  labelText: l10n.roomChoiceUnitLabel,
                ),
                validator: _unitValidator,
              );
              final waste = TextFormField(
                controller: _waste,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.roomChoiceWasteLabel,
                  suffixText: l10n.roomChoiceWasteSuffix,
                ),
                validator: (value) => _parseBasisPoints(value ?? '') == null
                    ? l10n.invalidNumberError
                    : null,
              );
              if (constraints.maxWidth < 430) {
                return Column(
                  children: [
                    quantity,
                    const SizedBox(height: 8),
                    unit,
                    const SizedBox(height: 8),
                    waste,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: quantity),
                  const SizedBox(width: 8),
                  Expanded(child: unit),
                  const SizedBox(width: 8),
                  Expanded(child: waste),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(l10n.roomChoiceOrderDateLabel),
            subtitle: Text(
              _orderDue == null
                  ? l10n.roomChoiceNoOrderDate
                  : DateFormat.yMMMd('pl').format(_orderDue!),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_orderDue != null)
                  IconButton(
                    tooltip: l10n.roomChoiceClearOrderDate,
                    onPressed: () => setState(() => _orderDue = null),
                    icon: const Icon(Icons.close),
                  ),
                IconButton(
                  tooltip: l10n.roomChoiceOrderDateLabel,
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: _note,
            minLines: 2,
            maxLines: 5,
            maxLength: RoomFieldLimits.note,
            decoration: InputDecoration(labelText: l10n.roomChoiceNoteLabel),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.roomChoiceVariantsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                key: const ValueKey('roomChoiceAddVariantButton'),
                tooltip: l10n.roomChoiceAddVariant,
                onPressed: _variants.length >= RoomFieldLimits.maximumVariants
                    ? null
                    : _addVariant,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          ...List<Widget>.generate(
            _variants.length,
            (index) => _VariantEditor(
              key: ValueKey(_variants[index]),
              index: index,
              controllers: _variants[index],
              currencyCode: widget.data.project.currencyCode,
              canRemove: _variants.length > 1,
              onRemove: () => _removeVariant(index),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('roomChoiceSaveButton'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.roomChoiceSaveAction),
          ),
        ],
      ),
    );
  }

  String? _quantityValidator(String? value) {
    final hasQuantity = value != null && value.trim().isNotEmpty;
    final hasUnit = _unit.text.trim().isNotEmpty;
    if (hasQuantity != hasUnit) {
      return AppLocalizations.of(context).requiredFieldError;
    }
    if (!hasQuantity) return null;
    return _parseQuantity(value) == null
        ? AppLocalizations.of(context).invalidNumberError
        : null;
  }

  String? _unitValidator(String? value) => _quantityValidator(_quantity.text);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDue ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) setState(() => _orderDue = picked);
  }

  void _addVariant() => setState(() => _variants.add(_VariantControllers()));

  void _removeVariant(int index) {
    final removed = _variants.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final quantity = _parseQuantity(_quantity.text);
    final waste = _parseBasisPoints(_waste.text);
    if (waste == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final input = RoomChoiceInput(
        projectId: widget.data.project.id,
        roomId: widget.data.room.id,
        title: _title.text,
        quantity: quantity,
        unit: _unit.text,
        wasteBasisPoints: waste,
        orderDue: _orderDue,
        note: _note.text,
      );
      final variants = _variants
          .map(
            (variant) => RoomChoiceVariantInput(
              projectId: widget.data.project.id,
              label: variant.label.text,
              supplier: variant.supplier.text,
              productCode: variant.productCode.text,
              unitGrossPrice: Money(
                minorUnits: _parseMinorUnits(variant.price.text)!,
                currencyCode: widget.data.project.currencyCode,
              ),
              note: variant.note.text,
            ),
          )
          .toList(growable: false);
      final existing = widget.data.choice;
      if (existing == null) {
        await widget.data.repository.createChoice(
          input: input,
          variants: variants,
        );
      } else {
        await widget.data.repository.updateChoice(
          projectId: existing.input.projectId,
          choiceId: existing.id,
          input: input,
          variants: variants,
        );
      }
      widget.onSaved();
    } on Object {
      if (mounted) setState(() => _error = l10n.roomChoiceSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _VariantEditor extends StatelessWidget {
  const _VariantEditor({
    required this.index,
    required this.controllers,
    required this.currencyCode,
    required this.canRemove,
    required this.onRemove,
    super.key,
  });

  final int index;
  final _VariantControllers controllers;
  final String currencyCode;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.roomChoiceVariantLabel} ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.roomChoiceRemoveVariant,
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFormField(
              controller: controllers.label,
              maxLength: RoomFieldLimits.variantLabel,
              decoration: InputDecoration(
                labelText: l10n.roomChoiceVariantLabel,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.requiredFieldError
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers.price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\s]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.roomChoiceVariantPriceLabel,
                suffixText: currencyCode,
              ),
              validator: (value) => _parseMinorUnits(value ?? '') == null
                  ? l10n.invalidAmountError
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers.supplier,
              maxLength: RoomFieldLimits.supplier,
              decoration: InputDecoration(
                labelText: l10n.roomChoiceVariantSupplierLabel,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers.productCode,
              maxLength: RoomFieldLimits.productCode,
              decoration: InputDecoration(
                labelText: l10n.roomChoiceVariantCodeLabel,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers.note,
              minLines: 1,
              maxLines: 3,
              maxLength: RoomFieldLimits.note,
              decoration: InputDecoration(
                labelText: l10n.roomChoiceVariantNoteLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _VariantControllers {
  _VariantControllers({
    String label = '',
    String price = '',
    String supplier = '',
    String productCode = '',
    String note = '',
  }) : label = TextEditingController(text: label),
       price = TextEditingController(text: price),
       supplier = TextEditingController(text: supplier),
       productCode = TextEditingController(text: productCode),
       note = TextEditingController(text: note);

  factory _VariantControllers.fromVariant(RoomChoiceVariant variant) {
    return _VariantControllers(
      label: variant.label,
      price: formatMinorUnitsForInput(variant.unitGrossPrice.minorUnits),
      supplier: variant.supplier ?? '',
      productCode: variant.productCode ?? '',
      note: variant.note ?? '',
    );
  }

  final TextEditingController label;
  final TextEditingController price;
  final TextEditingController supplier;
  final TextEditingController productCode;
  final TextEditingController note;

  void dispose() {
    label.dispose();
    price.dispose();
    supplier.dispose();
    productCode.dispose();
    note.dispose();
  }
}

DecimalQuantity? _parseQuantity(String source) {
  final normalized = source.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^\d+(?:\.\d{1,6})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final scale = parts.length == 1 ? 0 : parts[1].length;
  final unscaled = int.tryParse(parts.join());
  if (unscaled == null || unscaled <= 0) return null;
  return DecimalQuantity(unscaledValue: unscaled, scale: scale);
}

int? _parseBasisPoints(String source) {
  final normalized = source.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,3}(?:\.\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final value = int.parse(parts[0]) * 100 + int.parse(fraction);
  return value <= 10000 ? value : null;
}

int? _parseMinorUnits(String source) {
  final normalized = source.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final value =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  if (value > BigInt.from(Money.maximumMinorUnits)) return null;
  return value.toInt();
}

String _formatDecimal(int unscaled, int scale) {
  if (scale == 0) return '$unscaled';
  final digits = unscaled.toString().padLeft(scale + 1, '0');
  final split = digits.length - scale;
  return '${digits.substring(0, split)},${digits.substring(split)}'
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r',$'), '');
}
