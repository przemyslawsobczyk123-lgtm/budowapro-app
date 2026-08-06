import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/materials/data/material_providers.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/features/materials/presentation/material_ui_text.dart';
import 'package:budowapro/features/materials/presentation/materials_controller.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MaterialDetailsScreen extends ConsumerStatefulWidget {
  const MaterialDetailsScreen({
    required this.projectId,
    required this.materialId,
    super.key,
  });

  final String projectId;
  final String materialId;

  @override
  ConsumerState<MaterialDetailsScreen> createState() =>
      _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends ConsumerState<MaterialDetailsScreen> {
  late Future<_MaterialDetailsData> _load = _request();

  Future<_MaterialDetailsData> _request() async {
    final repository = await ref.read(materialRepositoryProvider.future);
    final item = await repository.findById(
      projectId: widget.projectId,
      materialId: widget.materialId,
    );
    if (item == null) throw const MaterialNotFoundException();
    final projects = await ref.read(projectsControllerProvider.future);
    final project = projects.projects
        .where((value) => value.id == widget.projectId)
        .firstOrNull;
    if (project == null) throw const MaterialNotFoundException();
    return _MaterialDetailsData(
      repository: repository,
      item: item,
      currencyCode: project.currencyCode,
      contacts: await _contacts(
        await ref.read(contactRepositoryProvider.future),
        widget.projectId,
      ),
      documents: await _documents(
        await ref.read(documentRepositoryProvider.future),
        widget.projectId,
      ),
    );
  }

  void _reload() => setState(() => _load = _request());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const ValueKey('materialDetailsScreen'),
      appBar: AppBar(title: Text(l10n.materialDetailsTitle)),
      body: FutureBuilder<_MaterialDetailsData>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: l10n.materialsLoading);
          }
          if (snapshot.hasError || snapshot.data == null) {
            return AppErrorState(
              title: snapshot.error is MaterialNotFoundException
                  ? l10n.materialNotFound
                  : l10n.materialsLoadError,
              retryLabel: l10n.retryAction,
              onRetry: _reload,
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _content(_MaterialDetailsData data) {
    final l10n = AppLocalizations.of(context);
    final item = data.item;
    final input = item.input;
    final status = item.statusAt(DateTime.now());
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      input.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(materialStatusLabel(l10n, status)),
                    if (input.note case final note?) ...[
                      const SizedBox(height: 8),
                      Text(note),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.materialEditTooltip,
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l10n.materialDeleteTooltip,
                onPressed: () => _delete(data.repository),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
        ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Value(
                  label: l10n.materialOrderedQuantity,
                  value:
                      '${formatMaterialQuantity(input.orderedQuantity)} ${input.unit}',
                ),
                _Value(
                  label: l10n.materialDeliveredQuantity,
                  value: item.deliveredQuantity == null
                      ? '0 ${input.unit}'
                      : '${formatMaterialQuantity(item.deliveredQuantity!)} ${input.unit}',
                ),
                _Value(
                  label: l10n.materialReturnedQuantity,
                  value: item.returnedQuantity == null
                      ? '0 ${input.unit}'
                      : '${formatMaterialQuantity(item.returnedQuantity!)} ${input.unit}',
                ),
                if (input.orderedGross case final gross?)
                  _Value(
                    label: l10n.materialsOrderedValue,
                    value: formatMoneyForDisplay(gross, data.currencyCode),
                  ),
              ],
            ),
          ),
        ),
        _section(l10n.materialRelationsTitle),
        _relationRows(data),
        _section(
          l10n.materialDeliveriesTitle,
          action: FilledButton.tonalIcon(
            onPressed: () => _editDelivery(data),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.materialAddDeliveryAction),
          ),
        ),
        if (item.deliveries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.materialNoDeliveries),
          )
        else
          ...item.deliveries.map(
            (delivery) => _DeliveryTile(
              delivery: delivery,
              unit: input.unit,
              now: DateTime.now(),
              onTap: () => _editDelivery(data, delivery: delivery),
              onDelete: () => _deleteDelivery(data.repository, delivery.id),
            ),
          ),
        _section(
          l10n.materialReturnsTitle,
          action: FilledButton.tonalIcon(
            onPressed: () => _editReturn(data),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.materialAddReturnAction),
          ),
        ),
        if (item.returns.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.materialNoReturns),
          )
        else
          ...item.returns.map(
            (value) => _ReturnTile(
              value: value,
              unit: input.unit,
              currencyCode: data.currencyCode,
              now: DateTime.now(),
              onTap: () => _editReturn(data, value: value),
              onDelete: () => _deleteReturn(data.repository, value.id),
            ),
          ),
      ],
    );
  }

  Widget _relationRows(_MaterialDetailsData data) {
    final l10n = AppLocalizations.of(context);
    final input = data.item.input;
    return Column(
      children: [
        if (input.stageId case final value?)
          _RelationRow(
            icon: Icons.account_tree_outlined,
            label: l10n.materialStageLabel,
            value: value,
          ),
        if (input.roomId case final value?)
          _RelationRow(
            icon: Icons.meeting_room_outlined,
            label: l10n.materialRoomLabel,
            value: value,
          ),
        if (input.supplierContactId case final value?)
          _RelationRow(
            icon: Icons.groups_outlined,
            label: l10n.materialSupplierLabel,
            value: data.contactLabel(value),
          ),
        if (input.costEntryId case final value?)
          _RelationRow(
            icon: Icons.payments_outlined,
            label: l10n.materialCostLabel,
            value: value,
          ),
        if (input.receiptDocumentId case final value?)
          _RelationRow(
            icon: Icons.receipt_long_outlined,
            label: l10n.materialReceiptLabel,
            value: data.documentLabel(value),
          ),
        if (input.storageLocation case final value?)
          _RelationRow(
            icon: Icons.warehouse_outlined,
            label: l10n.materialStorageLabel,
            value: value,
          ),
      ],
    );
  }

  Widget _section(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...(action == null ? const <Widget>[] : <Widget>[action]),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.projectId)}'
      '/materials/${Uri.encodeComponent(widget.materialId)}/edit',
    );
    if (mounted) _reload();
  }

  Future<void> _delete(MaterialRepository repository) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.materialDeleteTitle),
        content: Text(l10n.materialDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.materialDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await repository.delete(
        projectId: widget.projectId,
        materialId: widget.materialId,
      );
      ref.invalidate(materialsControllerProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on MaterialInUseException {
      if (mounted) _snack(l10n.materialDeleteInUseError);
    } on Object {
      if (mounted) _snack(l10n.materialDeleteError);
    }
  }

  Future<void> _editDelivery(
    _MaterialDetailsData data, {
    MaterialDelivery? delivery,
  }) async {
    final input = await showDialog<MaterialDeliveryInput>(
      context: context,
      builder: (context) => _DeliveryDialog(
        item: data.item,
        value: delivery,
        contacts: data.contacts,
        documents: data.documents,
      ),
    );
    if (input == null) return;
    try {
      await data.repository.saveDelivery(
        deliveryId: delivery?.id,
        input: input,
      );
      _reload();
    } on MaterialOverDeliveryConfirmationRequired {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.materialDeliveryOverTitle),
          content: Text(l10n.materialDeliveryOverMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.materialDeliveryOverAction),
            ),
          ],
        ),
      );
      if (accepted == true) {
        await data.repository.saveDelivery(
          deliveryId: delivery?.id,
          input: input,
          confirmOrderedQuantityCorrection: true,
        );
        _reload();
      }
    } on Object {
      if (mounted) {
        _snack(AppLocalizations.of(context).materialDeliverySaveError);
      }
    }
  }

  Future<void> _editReturn(
    _MaterialDetailsData data, {
    MaterialReturn? value,
  }) async {
    final input = await showDialog<MaterialReturnInput>(
      context: context,
      builder: (context) => _ReturnDialog(
        item: data.item,
        value: value,
        currencyCode: data.currencyCode,
        documents: data.documents,
      ),
    );
    if (input == null) return;
    try {
      await data.repository.saveReturn(returnId: value?.id, input: input);
      _reload();
    } on Object {
      if (mounted) _snack(AppLocalizations.of(context).materialReturnSaveError);
    }
  }

  Future<void> _deleteDelivery(MaterialRepository repository, String id) async {
    if (!await _confirmRecordDeletion()) return;
    try {
      await repository.deleteDelivery(
        projectId: widget.projectId,
        materialId: widget.materialId,
        deliveryId: id,
      );
      _reload();
    } on Object {
      if (mounted) {
        _snack(AppLocalizations.of(context).materialDeliverySaveError);
      }
    }
  }

  Future<void> _deleteReturn(MaterialRepository repository, String id) async {
    if (!await _confirmRecordDeletion()) return;
    try {
      await repository.deleteReturn(
        projectId: widget.projectId,
        materialId: widget.materialId,
        returnId: id,
      );
      _reload();
    } on Object {
      if (mounted) _snack(AppLocalizations.of(context).materialReturnSaveError);
    }
  }

  Future<bool> _confirmRecordDeletion() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.materialRecordDeleteTitle),
        content: Text(l10n.materialRecordDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.materialDeleteAction),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _snack(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

final class _MaterialDetailsData {
  const _MaterialDetailsData({
    required this.repository,
    required this.item,
    required this.currencyCode,
    required this.contacts,
    required this.documents,
  });

  final MaterialRepository repository;
  final MaterialItem item;
  final String currencyCode;
  final List<Contact> contacts;
  final List<ProjectDocument> documents;

  String contactLabel(String id) =>
      contacts
          .where((value) => value.id == id)
          .map((value) => value.displayName)
          .firstOrNull ??
      id;

  String documentLabel(String id) =>
      documents
          .where((value) => value.id == id)
          .map((value) => value.metadata.title)
          .firstOrNull ??
      id;
}

class _DeliveryDialog extends StatefulWidget {
  const _DeliveryDialog({
    required this.item,
    required this.value,
    required this.contacts,
    required this.documents,
  });

  final MaterialItem item;
  final MaterialDelivery? value;
  final List<Contact> contacts;
  final List<ProjectDocument> documents;

  @override
  State<_DeliveryDialog> createState() => _DeliveryDialogState();
}

class _DeliveryDialogState extends State<_DeliveryDialog> {
  final _form = GlobalKey<FormState>();
  final _expected = TextEditingController();
  final _actual = TextEditingController();
  final _shortage = TextEditingController();
  final _damage = TextEditingController();
  late DateTime _due;
  var _received = false;
  var _reminder = false;
  String? _contactId;
  String? _documentId;

  @override
  void initState() {
    super.initState();
    final input = widget.value?.input;
    _expected.text = _quantityInput(
      input?.expectedQuantity ?? widget.item.input.orderedQuantity,
    );
    _actual.text = input?.deliveredQuantity == null
        ? _expected.text
        : _quantityInput(input!.deliveredQuantity!);
    _shortage.text = input?.shortageNote ?? '';
    _damage.text = input?.damageNote ?? '';
    _due = input?.dueAtUtc ?? DateTime.now().add(const Duration(days: 1));
    _received = input?.receivedAtUtc != null;
    _reminder = input?.reminderEnabled ?? false;
    _contactId = input?.contactId;
    _documentId = input?.documentId;
  }

  @override
  void dispose() {
    _expected.dispose();
    _actual.dispose();
    _shortage.dispose();
    _damage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.materialDeliveriesTitle),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _quantityField(
                  _expected,
                  l10n.materialDeliveryExpectedLabel,
                  l10n.materialInvalidQuantity,
                ),
                _dateRow(
                  l10n.materialDeliveryDueLabel,
                  _due,
                  (value) => setState(() => _due = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.materialDeliveryReceivedToggle),
                  value: _received,
                  onChanged: (value) => setState(() => _received = value),
                ),
                if (_received)
                  _quantityField(
                    _actual,
                    l10n.materialDeliveryActualLabel,
                    l10n.materialInvalidQuantity,
                  ),
                _select(
                  label: l10n.materialDeliveryContactLabel,
                  value: _contactId,
                  options: widget.contacts.map(
                    (value) => MapEntry(value.id, value.displayName),
                  ),
                  onChanged: (value) => _contactId = value,
                ),
                const SizedBox(height: 8),
                _select(
                  label: l10n.materialDeliveryDocumentLabel,
                  value: _documentId,
                  options: widget.documents.map(
                    (value) => MapEntry(value.id, value.metadata.title),
                  ),
                  onChanged: (value) => _documentId = value,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _shortage,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.materialDeliveryShortageLabel,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _damage,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.materialDeliveryDamageLabel,
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.materialReminderToggle),
                  value: _reminder,
                  onChanged: (value) => setState(() => _reminder = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.materialDeliverySaveAction),
        ),
      ],
    );
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      MaterialDeliveryInput(
        projectId: widget.item.input.projectId,
        materialId: widget.item.id,
        expectedQuantity: _parseQuantity(_expected.text)!,
        dueAt: _due,
        deliveredQuantity: _received ? _parseQuantity(_actual.text)! : null,
        receivedAt: _received
            ? widget.value?.input.receivedAtUtc ?? DateTime.now()
            : null,
        contactId: _contactId,
        documentId: _documentId,
        shortageNote: _shortage.text,
        damageNote: _damage.text,
        reminderEnabled: _reminder,
      ),
    );
  }
}

class _ReturnDialog extends StatefulWidget {
  const _ReturnDialog({
    required this.item,
    required this.value,
    required this.currencyCode,
    required this.documents,
  });

  final MaterialItem item;
  final MaterialReturn? value;
  final String currencyCode;
  final List<ProjectDocument> documents;

  @override
  State<_ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<_ReturnDialog> {
  final _form = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _expected = TextEditingController();
  final _actual = TextEditingController();
  final _note = TextEditingController();
  late DateTime _deadline;
  var _receiptRequired = true;
  var _completed = false;
  var _reminder = false;
  String? _documentId;

  @override
  void initState() {
    super.initState();
    final input = widget.value?.input;
    _quantity.text = _quantityInput(
      input?.quantity ?? widget.item.input.orderedQuantity,
    );
    _expected.text = input?.expectedRefund == null
        ? ''
        : formatMinorUnitsForInput(input!.expectedRefund!.minorUnits);
    _actual.text = input?.actualRefund == null
        ? ''
        : formatMinorUnitsForInput(input!.actualRefund!.minorUnits);
    _note.text = input?.note ?? '';
    _deadline =
        input?.deadlineUtc ?? DateTime.now().add(const Duration(days: 7));
    _receiptRequired = input?.receiptRequired ?? true;
    _completed = input?.completedAtUtc != null;
    _reminder = input?.reminderEnabled ?? false;
    _documentId = input?.receiptDocumentId;
  }

  @override
  void dispose() {
    _quantity.dispose();
    _expected.dispose();
    _actual.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.materialReturnsTitle),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _quantityField(
                  _quantity,
                  l10n.materialReturnQuantityLabel,
                  l10n.materialInvalidQuantity,
                ),
                _dateRow(
                  l10n.materialReturnDeadlineLabel,
                  _deadline,
                  (value) => setState(() => _deadline = value),
                ),
                _moneyField(
                  _expected,
                  l10n.materialReturnExpectedLabel,
                  widget.currencyCode,
                  l10n.invalidAmountError,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.materialReturnReceiptRequired),
                  value: _receiptRequired,
                  onChanged: (value) =>
                      setState(() => _receiptRequired = value),
                ),
                _select(
                  label: l10n.materialReturnDocumentLabel,
                  value: _documentId,
                  options: widget.documents.map(
                    (value) => MapEntry(value.id, value.metadata.title),
                  ),
                  onChanged: (value) => _documentId = value,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.materialReturnCompletedToggle),
                  value: _completed,
                  onChanged: (value) => setState(() => _completed = value),
                ),
                if (_completed)
                  _moneyField(
                    _actual,
                    l10n.materialReturnActualLabel,
                    widget.currencyCode,
                    l10n.invalidAmountError,
                  ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.materialReminderToggle),
                  value: _reminder,
                  onChanged: (value) => setState(() => _reminder = value),
                ),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.materialNoteLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.materialReturnSaveAction),
        ),
      ],
    );
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      MaterialReturnInput(
        projectId: widget.item.input.projectId,
        materialId: widget.item.id,
        quantity: _parseQuantity(_quantity.text)!,
        deadline: _deadline,
        expectedRefund: _money(_expected.text, widget.currencyCode),
        receiptRequired: _receiptRequired,
        receiptDocumentId: _documentId,
        completedAt: _completed
            ? widget.value?.input.completedAtUtc ?? DateTime.now()
            : null,
        actualRefund: _completed
            ? _money(_actual.text, widget.currencyCode)
            : null,
        reminderEnabled: _reminder,
        note: _note.text,
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({
    required this.delivery,
    required this.unit,
    required this.now,
    required this.onTap,
    required this.onDelete,
  });
  final MaterialDelivery delivery;
  final String unit;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = delivery.isReceived
        ? l10n.materialDeliveryReceived
        : delivery.isDelayedAt(now)
        ? l10n.materialDeliveryDelayed
        : l10n.materialDeliveryPlanned;
    return ListTile(
      key: ValueKey('materialDelivery-${delivery.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: const Icon(Icons.local_shipping_outlined),
      title: Text(
        '${formatMaterialQuantity(delivery.input.expectedQuantity)} $unit',
      ),
      subtitle: Text('${_date(delivery.input.dueAtUtc)} · $status'),
      onTap: onTap,
      trailing: IconButton(
        tooltip: l10n.materialRecordDeleteTooltip,
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}

class _ReturnTile extends StatelessWidget {
  const _ReturnTile({
    required this.value,
    required this.unit,
    required this.currencyCode,
    required this.now,
    required this.onTap,
    required this.onDelete,
  });
  final MaterialReturn value;
  final String unit;
  final String currencyCode;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = value.isCompleted
        ? l10n.materialReturnCompleted
        : value.isOverdueAt(now)
        ? l10n.materialReturnOverdue
        : l10n.materialReturnPending;
    final refund = value.input.expectedRefund;
    return ListTile(
      key: ValueKey('materialReturn-${value.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: const Icon(Icons.assignment_return_outlined),
      title: Text('${formatMaterialQuantity(value.input.quantity)} $unit'),
      subtitle: Text(
        [
          '${_date(value.input.deadlineUtc)} · $status',
          if (refund != null) formatMoneyForDisplay(refund, currencyCode),
        ].join('\n'),
      ),
      onTap: onTap,
      trailing: IconButton(
        tooltip: l10n.materialRecordDeleteTooltip,
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}

class _RelationRow extends StatelessWidget {
  const _RelationRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value),
  );
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 142,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

Widget _quantityField(
  TextEditingController controller,
  String label,
  String invalidError,
) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
    ],
    decoration: InputDecoration(labelText: label),
    validator: (value) =>
        _parseQuantity(value ?? '') == null ? invalidError : null,
  );
}

Widget _moneyField(
  TextEditingController controller,
  String label,
  String currency,
  String invalidError,
) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\s]')),
    ],
    decoration: InputDecoration(labelText: label, suffixText: currency),
    validator: (value) =>
        value == null || value.trim().isEmpty || _money(value, currency) != null
        ? null
        : invalidError,
  );
}

Widget _dateRow(
  String label,
  DateTime value,
  ValueChanged<DateTime> onChanged,
) {
  return Builder(
    builder: (context) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(_date(value)),
      trailing: IconButton(
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
    ),
  );
}

Widget _select({
  required String label,
  required String? value,
  required Iterable<MapEntry<String, String>> options,
  required ValueChanged<String?> onChanged,
}) {
  return Builder(
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return DropdownButtonFormField<String?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: <DropdownMenuItem<String?>>[
          DropdownMenuItem<String?>(
            value: null,
            child: Text(l10n.materialNoRelation),
          ),
          ...options.map(
            (item) => DropdownMenuItem<String?>(
              value: item.key,
              child: Text(item.value, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
      );
    },
  );
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

Money? _money(String source, String currency) {
  final normalized = source.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.replaceAll(',', '.').split('.');
  final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final amount =
      BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(fraction);
  if (amount > BigInt.from(Money.maximumMinorUnits)) return null;
  return Money(minorUnits: amount.toInt(), currencyCode: currency);
}

String _quantityInput(MaterialQuantity value) {
  final digits = value.unscaledValue.toString().padLeft(value.scale + 1, '0');
  if (value.scale == 0) return digits;
  final split = digits.length - value.scale;
  return '${digits.substring(0, split)},${digits.substring(split)}';
}

String _date(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
}

Future<List<Contact>> _contacts(
  ContactRepository repository,
  String projectId,
) async {
  final result = <Contact>[];
  var page = PageRequest(limit: PageRequest.maximumLimit);
  while (true) {
    final current = await repository.list(
      ContactQuery(projectId: projectId),
      page,
    );
    result.addAll(current.items);
    final next = current.nextRequest;
    if (next == null) return result;
    page = next;
  }
}

Future<List<ProjectDocument>> _documents(
  DocumentRepository repository,
  String projectId,
) async {
  final result = <ProjectDocument>[];
  var page = PageRequest(limit: PageRequest.maximumLimit);
  while (true) {
    final current = await repository.list(
      DocumentQuery(projectId: projectId),
      page,
    );
    result.addAll(current.items);
    final next = current.nextRequest;
    if (next == null) return result;
    page = next;
  }
}
