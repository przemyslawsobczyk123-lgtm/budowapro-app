import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/materials/data/material_providers.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/features/materials/presentation/materials_controller.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/rooms/data/room_providers.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaterialFormScreen extends ConsumerStatefulWidget {
  const MaterialFormScreen({
    required this.projectId,
    this.materialId,
    super.key,
  });

  final String projectId;
  final String? materialId;

  @override
  ConsumerState<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends ConsumerState<MaterialFormScreen> {
  late Future<_MaterialEditorData> _load = _request();

  Future<_MaterialEditorData> _request() async {
    final projects = await ref.read(projectsControllerProvider.future);
    final project = projects.projects
        .where((value) => value.id == widget.projectId)
        .firstOrNull;
    if (project == null) throw const MaterialNotFoundException();
    final repository = await ref.read(materialRepositoryProvider.future);
    final materialId = widget.materialId;
    final material = materialId == null
        ? null
        : await repository.findById(
            projectId: widget.projectId,
            materialId: materialId,
          );
    if (materialId != null && material == null) {
      throw const MaterialNotFoundException();
    }
    final stages = await (await ref.read(
      stageRepositoryProvider.future,
    )).listStages(projectId: project.id, template: project.template);
    final rooms = await _allRooms(
      await ref.read(roomRepositoryProvider.future),
      project.id,
    );
    final contacts = await _allContacts(
      await ref.read(contactRepositoryProvider.future),
      project.id,
    );
    final costs = await _allCosts(
      await ref.read(costRepositoryProvider.future),
      project.id,
    );
    final documents = await _allDocuments(
      await ref.read(documentRepositoryProvider.future),
      project.id,
    );
    return _MaterialEditorData(
      project: project,
      repository: repository,
      material: material,
      stages: stages,
      rooms: rooms,
      contacts: contacts,
      costs: costs,
      documents: documents,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.materialId == null
        ? l10n.materialNewTitle
        : l10n.materialEditTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<_MaterialEditorData>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: title);
          }
          if (snapshot.hasError || snapshot.data == null) {
            return AppErrorState(
              title: snapshot.error is MaterialNotFoundException
                  ? l10n.materialNotFound
                  : l10n.materialsLoadError,
              retryLabel: l10n.retryAction,
              onRetry: () => setState(() => _load = _request()),
            );
          }
          return _MaterialForm(
            data: snapshot.data!,
            onSaved: () {
              ref.invalidate(materialsControllerProvider);
              if (context.mounted) Navigator.of(context).pop(true);
            },
          );
        },
      ),
    );
  }
}

final class _MaterialEditorData {
  const _MaterialEditorData({
    required this.project,
    required this.repository,
    required this.material,
    required this.stages,
    required this.rooms,
    required this.contacts,
    required this.costs,
    required this.documents,
  });

  final Project project;
  final MaterialRepository repository;
  final MaterialItem? material;
  final List<ProjectStage> stages;
  final List<RoomOverview> rooms;
  final List<Contact> contacts;
  final List<CostEntry> costs;
  final List<ProjectDocument> documents;
}

class _MaterialForm extends StatefulWidget {
  const _MaterialForm({required this.data, required this.onSaved});

  final _MaterialEditorData data;
  final VoidCallback onSaved;

  @override
  State<_MaterialForm> createState() => _MaterialFormState();
}

class _MaterialFormState extends State<_MaterialForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController();
  final _gross = TextEditingController();
  final _storage = TextEditingController();
  final _note = TextEditingController();
  String? _stageId;
  String? _roomId;
  String? _supplierContactId;
  String? _costEntryId;
  String? _receiptDocumentId;
  DateTime? _orderedAt;
  DateTime? _expectedDeliveryAt;
  var _deliveryReminderEnabled = false;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final input = widget.data.material?.input;
    _name.text = input?.name ?? '';
    _quantity.text = input == null
        ? ''
        : _formatQuantityForInput(input.orderedQuantity);
    _unit.text = input?.unit ?? '';
    _gross.text = input?.orderedGross == null
        ? ''
        : formatMinorUnitsForInput(input!.orderedGross!.minorUnits);
    _storage.text = input?.storageLocation ?? '';
    _note.text = input?.note ?? '';
    _stageId =
        input?.stageId ?? _stageStorageId(widget.data.project.currentStage);
    _roomId = input?.roomId;
    _supplierContactId = input?.supplierContactId;
    _costEntryId = input?.costEntryId;
    _receiptDocumentId = input?.receiptDocumentId;
    _orderedAt = input?.orderedAtUtc;
    _expectedDeliveryAt = input?.expectedDeliveryAtUtc;
    _deliveryReminderEnabled = input?.deliveryReminderEnabled ?? false;
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _name,
      _quantity,
      _unit,
      _gross,
      _storage,
      _note,
    ]) {
      controller.dispose();
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
          TextFormField(
            key: const ValueKey('materialNameField'),
            controller: _name,
            maxLength: MaterialFieldLimits.name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.materialNameLabel),
            validator: _required,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final quantity = TextFormField(
                key: const ValueKey('materialQuantityField'),
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.materialQuantityLabel,
                ),
                validator: (value) => _parseQuantity(value ?? '') == null
                    ? l10n.materialInvalidQuantity
                    : null,
              );
              final unit = TextFormField(
                key: const ValueKey('materialUnitField'),
                controller: _unit,
                maxLength: MaterialFieldLimits.unit,
                decoration: InputDecoration(labelText: l10n.materialUnitLabel),
                validator: _required,
              );
              if (constraints.maxWidth < 360) {
                return Column(
                  children: [quantity, const SizedBox(height: 8), unit],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: quantity),
                  const SizedBox(width: 10),
                  Expanded(child: unit),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            key: const ValueKey('materialStageField'),
            initialValue: _stageId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.materialStageLabel),
            items: <DropdownMenuItem<String?>>[
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.materialNoRelation),
              ),
              ...widget.data.stages.map(
                (stage) => DropdownMenuItem<String?>(
                  value: _stageIdForRecord(stage),
                  child: Text(stageName(l10n, stage)),
                ),
              ),
            ],
            onChanged: _saving ? null : (value) => _stageId = value,
          ),
          const SizedBox(height: 8),
          _relationDropdown(
            key: const ValueKey('materialRoomField'),
            label: l10n.materialRoomLabel,
            value: _roomId,
            options: widget.data.rooms.map(
              (value) => MapEntry(value.room.id, value.room.name),
            ),
            onChanged: (value) => _roomId = value,
          ),
          const SizedBox(height: 8),
          _relationDropdown(
            key: const ValueKey('materialSupplierField'),
            label: l10n.materialSupplierLabel,
            value: _supplierContactId,
            options: widget.data.contacts.map(
              (value) => MapEntry(value.id, value.displayName),
            ),
            onChanged: (value) => _supplierContactId = value,
          ),
          const SizedBox(height: 8),
          _relationDropdown(
            key: const ValueKey('materialCostField'),
            label: l10n.materialCostLabel,
            value: _costEntryId,
            options: widget.data.costs.map(
              (value) => MapEntry(value.id, value.name),
            ),
            onChanged: (value) => _costEntryId = value,
          ),
          const SizedBox(height: 8),
          _relationDropdown(
            key: const ValueKey('materialReceiptField'),
            label: l10n.materialReceiptLabel,
            value: _receiptDocumentId,
            options: widget.data.documents.map(
              (value) => MapEntry(value.id, value.metadata.title),
            ),
            onChanged: (value) => _receiptDocumentId = value,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey('materialGrossField'),
            controller: _gross,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,. \s]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.materialOrderedGrossLabel,
              suffixText: widget.data.project.currencyCode,
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? null
                : _parseMoney(value) == null
                ? l10n.invalidAmountError
                : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _storage,
            maxLength: MaterialFieldLimits.location,
            decoration: InputDecoration(labelText: l10n.materialStorageLabel),
          ),
          SwitchListTile.adaptive(
            key: const ValueKey('materialOrderedToggle'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.materialOrderedToggle),
            value: _orderedAt != null,
            onChanged: _saving
                ? null
                : (value) => setState(() {
                    _orderedAt = value ? DateTime.now() : null;
                  }),
          ),
          if (_orderedAt != null)
            _dateTile(
              label: l10n.materialOrderedDateLabel,
              value: _orderedAt!,
              onChanged: (value) => setState(() => _orderedAt = value),
            ),
          _optionalDateTile(
            label: l10n.materialExpectedDeliveryLabel,
            value: _expectedDeliveryAt,
            onChanged: (value) => setState(() => _expectedDeliveryAt = value),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.materialReminderToggle),
            value: _deliveryReminderEnabled,
            onChanged: _saving
                ? null
                : (value) => setState(() => _deliveryReminderEnabled = value),
          ),
          TextFormField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            maxLength: MaterialFieldLimits.note,
            decoration: InputDecoration(labelText: l10n.materialNoteLabel),
          ),
          if (_error case final error?) ...[
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
          ],
          FilledButton.icon(
            key: const ValueKey('materialSaveButton'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.materialSaveAction),
          ),
        ],
      ),
    );
  }

  Widget _relationDropdown({
    required Key key,
    required String label,
    required String? value,
    required Iterable<MapEntry<String, String>> options,
    required ValueChanged<String?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    final normalized = options.toList(growable: true);
    if (value != null && normalized.every((item) => item.key != value)) {
      normalized.add(MapEntry(value, l10n.materialRelationMissing));
    }
    return DropdownButtonFormField<String?>(
      key: key,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: <DropdownMenuItem<String?>>[
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.materialNoRelation),
        ),
        ...normalized.map(
          (option) => DropdownMenuItem<String?>(
            value: option.key,
            child: Text(option.value, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: _saving ? null : onChanged,
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(_formatDate(value)),
      trailing: IconButton(
        tooltip: l10n.materialDatePickTooltip,
        onPressed: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: value.toLocal(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (selected != null) onChanged(selected);
        },
        icon: const Icon(Icons.calendar_month_outlined),
      ),
    );
  }

  Widget _optionalDateTile({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        value == null ? l10n.materialNoRelation : _formatDate(value),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            IconButton(
              tooltip: l10n.materialsClearSearch,
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.close_rounded),
            ),
          IconButton(
            tooltip: l10n.materialDatePickTooltip,
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: value?.toLocal() ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selected != null) onChanged(selected);
            },
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final input = MaterialInput(
        projectId: widget.data.project.id,
        name: _name.text,
        orderedQuantity: _parseQuantity(_quantity.text)!,
        unit: _unit.text,
        stageId: _stageId,
        roomId: _roomId,
        supplierContactId: _supplierContactId,
        costEntryId: _costEntryId,
        receiptDocumentId: _receiptDocumentId,
        orderedGross: _gross.text.trim().isEmpty
            ? null
            : Money(
                minorUnits: _parseMoney(_gross.text)!,
                currencyCode: widget.data.project.currencyCode,
              ),
        storageLocation: _storage.text,
        orderedAt: _orderedAt,
        expectedDeliveryAt: _expectedDeliveryAt,
        deliveryReminderEnabled: _deliveryReminderEnabled,
        note: _note.text,
      );
      final existing = widget.data.material;
      if (existing == null) {
        await widget.data.repository.create(input);
      } else {
        await widget.data.repository.update(
          projectId: existing.input.projectId,
          materialId: existing.id,
          input: input,
        );
      }
      widget.onSaved();
    } on Object {
      if (mounted) setState(() => _error = l10n.materialSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? AppLocalizations.of(context).requiredFieldError
      : null;
}

Future<List<RoomOverview>> _allRooms(
  RoomRepository repository,
  String projectId,
) async {
  final values = <RoomOverview>[];
  var request = PageRequest(limit: PageRequest.maximumLimit);
  while (true) {
    final page = await repository.listRooms(
      RoomQuery(projectId: projectId),
      request,
    );
    values.addAll(page.items);
    final next = page.nextRequest;
    if (next == null) return values;
    request = next;
  }
}

Future<List<Contact>> _allContacts(
  ContactRepository repository,
  String projectId,
) async {
  final values = <Contact>[];
  var request = PageRequest(limit: PageRequest.maximumLimit);
  while (true) {
    final page = await repository.list(
      ContactQuery(projectId: projectId),
      request,
    );
    values.addAll(page.items);
    final next = page.nextRequest;
    if (next == null) return values;
    request = next;
  }
}

Future<List<CostEntry>> _allCosts(
  CostRepository repository,
  String projectId,
) async {
  final values = <CostEntry>[];
  var request = PageRequest(limit: PageRequest.maximumLimit);
  while (true) {
    final page = await repository.list(
      CostQuery(projectId: projectId, includeDrafts: true),
      request,
    );
    values.addAll(page.items);
    final next = page.nextRequest;
    if (next == null) return values;
    request = next;
  }
}

Future<List<ProjectDocument>> _allDocuments(
  DocumentRepository repository,
  String projectId,
) async {
  final values = <ProjectDocument>[];
  var request = PageRequest(limit: PageRequest.maximumLimit);
  while (true) {
    final page = await repository.list(
      DocumentQuery(projectId: projectId),
      request,
    );
    values.addAll(page.items);
    final next = page.nextRequest;
    if (next == null) return values;
    request = next;
  }
}

MaterialQuantity? _parseQuantity(String source) {
  final normalized = source.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(?:\.\d{1,6})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final scale = parts.length == 1 ? 0 : parts[1].length;
  final unscaled = BigInt.parse(parts.join());
  if (unscaled < BigInt.one || unscaled > BigInt.from(9223372036854775807)) {
    return null;
  }
  return MaterialQuantity(unscaledValue: unscaled.toInt(), scale: scale);
}

int? _parseMoney(String source) {
  final normalized = source.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final value =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  return value > BigInt.from(Money.maximumMinorUnits) ? null : value.toInt();
}

String _formatQuantityForInput(MaterialQuantity value) {
  final digits = value.unscaledValue.toString().padLeft(value.scale + 1, '0');
  if (value.scale == 0) return digits;
  final split = digits.length - value.scale;
  return '${digits.substring(0, split)}.${digits.substring(split)}';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.'
      '${local.month.toString().padLeft(2, '0')}.${local.year}';
}

String _stageIdForRecord(ProjectStage stage) {
  final key = stage.templateKey;
  return key == null ? stage.id : _stageStorageId(key);
}

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
