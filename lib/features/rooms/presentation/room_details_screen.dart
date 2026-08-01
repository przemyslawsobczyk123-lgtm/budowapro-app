import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/rooms/data/room_providers.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/features/rooms/presentation/room_ui_text.dart';
import 'package:budowapro/features/rooms/presentation/rooms_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoomDetailsScreen extends ConsumerStatefulWidget {
  const RoomDetailsScreen({
    required this.projectId,
    required this.roomId,
    super.key,
  });

  final String projectId;
  final String roomId;

  @override
  ConsumerState<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends ConsumerState<RoomDetailsScreen> {
  late Future<_RoomDetailsData> _load = _request();
  final Set<String> _creatingOutputs = <String>{};

  Future<_RoomDetailsData> _request() async {
    final repository = await ref.read(roomRepositoryProvider.future);
    final details = await repository.findRoomDetails(
      projectId: widget.projectId,
      roomId: widget.roomId,
    );
    if (details == null) throw const RoomNotFoundException();
    return _RoomDetailsData(repository: repository, details: details);
  }

  void _reload() {
    setState(() {
      _load = _request();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const ValueKey('roomDetailsScreen'),
      appBar: AppBar(title: Text(l10n.roomDetailsTitle)),
      body: FutureBuilder<_RoomDetailsData>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: l10n.roomsLoading);
          }
          if (snapshot.hasError || snapshot.data == null) {
            return AppErrorState(
              title: snapshot.error is RoomNotFoundException
                  ? l10n.roomNotFound
                  : l10n.roomsLoadError,
              retryLabel: l10n.retryAction,
              onRetry: _reload,
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _content(_RoomDetailsData data) {
    final l10n = AppLocalizations.of(context);
    final overview = data.details.overview;
    final room = overview.room;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      <String>[
                        if (room.floorLabel != null) room.floorLabel!,
                        roomStandardLabel(l10n, room.standard),
                      ].join(' · '),
                    ),
                    if (room.note != null) ...[
                      const SizedBox(height: 8),
                      Text(room.note!),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.roomEditTooltip,
                onPressed: () => _editRoom(room.id),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l10n.roomDeleteTooltip,
                onPressed: () => _deleteRoom(data.repository, room.id),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
        _budgetBand(overview),
        if (room.dimensions != null) _dimensions(room.dimensions!),
        _sectionHeader(
          l10n.roomChoicesTitle,
          action: FilledButton.tonalIcon(
            onPressed: _addChoice,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.roomAddChoiceAction),
          ),
        ),
        if (data.details.choices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppEmptyState(
              icon: Icons.tune_rounded,
              title: l10n.roomNoChoices,
              message: l10n.roomNoChoicesMessage,
            ),
          )
        else
          ...data.details.choices.map(
            (choice) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _choiceCard(data.repository, room, choice),
            ),
          ),
        _sectionHeader(
          l10n.roomRelatedTitle,
          action: IconButton(
            tooltip: l10n.roomManageRelationsAction,
            onPressed: _manageRelations,
            icon: const Icon(Icons.link_rounded),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              _RelatedRow(
                icon: Icons.rule_folder_outlined,
                label: l10n.roomRelatedDecisions,
                count: overview.openDecisionCount,
              ),
              _RelatedRow(
                icon: Icons.inventory_2_outlined,
                label: l10n.roomRelatedMaterials,
                count: overview.materialCount,
              ),
              _RelatedRow(
                icon: Icons.groups_outlined,
                label: l10n.roomRelatedTeams,
                count: overview.contactCount,
              ),
              _RelatedRow(
                icon: Icons.photo_library_outlined,
                label: l10n.roomRelatedPhotos,
                count: overview.technicalPhotoCount,
              ),
              _RelatedRow(
                icon: Icons.report_problem_outlined,
                label: l10n.roomRelatedDefects,
                count: overview.openDefectCount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _budgetBand(RoomOverview overview) {
    final l10n = AppLocalizations.of(context);
    final budget = overview.room.plannedBudget;
    final actual = overview.actualCost;
    final remaining = budget == null ? null : budget - actual;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Wrap(
          spacing: 28,
          runSpacing: 12,
          children: [
            _BudgetValue(
              label: l10n.roomBudgetPlanned,
              value: budget == null ? null : _money(budget),
              empty: l10n.roomNoBudget,
            ),
            _BudgetValue(label: l10n.roomBudgetActual, value: _money(actual)),
            _BudgetValue(
              label: l10n.roomBudgetRemaining,
              value: remaining == null ? null : _money(remaining),
              empty: l10n.roomNoBudget,
              emphasize: remaining?.isNegative ?? false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dimensions(RoomDimensions dimensions) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          if (dimensions.lengthMillimeters != null)
            Text(
              '${l10n.roomLengthLabel}: ${formatRoomDimension(dimensions.lengthMillimeters!)} ${l10n.roomMetersSuffix}',
            ),
          if (dimensions.widthMillimeters != null)
            Text(
              '${l10n.roomWidthLabel}: ${formatRoomDimension(dimensions.widthMillimeters!)} ${l10n.roomMetersSuffix}',
            ),
          if (dimensions.heightMillimeters != null)
            Text(
              '${l10n.roomHeightLabel}: ${formatRoomDimension(dimensions.heightMillimeters!)} ${l10n.roomMetersSuffix}',
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _choiceCard(RoomRepository repository, Room room, RoomChoice choice) {
    final l10n = AppLocalizations.of(context);
    final selected = choice.selectedVariant;
    final estimated = choice.estimatedGross;
    final estimatedQuantity = choice.estimatedQuantityUnscaled;
    return Card(
      key: ValueKey('roomChoice-${choice.id}'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.input.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(roomChoiceStatusLabel(l10n, choice.status)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.roomChoiceEditTooltip,
                  onPressed: () => _editChoice(choice.id),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.roomChoiceDeleteTooltip,
                  onPressed: () => _deleteChoice(repository, choice),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            if (choice.input.orderDueUtc != null)
              Text(l10n.roomChoiceOrderDue(_date(choice.input.orderDueUtc!))),
            if (estimatedQuantity != null && choice.input.unit != null)
              Text(
                l10n.roomChoiceQuantityWithWaste(
                  formatRoomQuantity(
                    estimatedQuantity,
                    choice.estimatedQuantityScale!,
                  ),
                  choice.input.unit!,
                ),
              ),
            if (estimated != null)
              Text(
                l10n.roomChoiceEstimatedTotal(_money(estimated)),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            if (choice.input.note != null) ...[
              const SizedBox(height: 6),
              Text(choice.input.note!),
            ],
            const SizedBox(height: 10),
            ...choice.variants.map(
              (variant) => _VariantRow(
                variant: variant,
                selected: selected?.id == variant.id,
                onSelect:
                    choice.status == RoomChoiceStatus.selected &&
                        selected?.id == variant.id
                    ? null
                    : () => _selectVariant(repository, choice, variant),
              ),
            ),
            if (choice.status == RoomChoiceStatus.selected) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        choice.outputRecordId(
                              RoomChoiceOutputType.plannedCost,
                            ) !=
                            null
                        ? null
                        : _creatingOutputs.contains('${choice.id}-cost')
                        ? null
                        : () => _createPlannedCost(room, choice),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(
                      choice.outputRecordId(RoomChoiceOutputType.plannedCost) !=
                              null
                          ? l10n.roomChoicePlannedCostCreated
                          : l10n.roomChoiceCreatePlannedCost,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        choice.outputRecordId(RoomChoiceOutputType.material) !=
                            null
                        ? null
                        : _creatingOutputs.contains('${choice.id}-material')
                        ? null
                        : () => _createMaterial(room, choice),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(
                      choice.outputRecordId(RoomChoiceOutputType.material) !=
                              null
                          ? l10n.roomChoiceMaterialCreated
                          : l10n.roomChoiceCreateMaterial,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        choice.outputRecordId(RoomChoiceOutputType.decision) !=
                            null
                        ? null
                        : _creatingOutputs.contains('${choice.id}-decision')
                        ? null
                        : () => _createDecision(room, choice),
                    icon: const Icon(Icons.rule_folder_outlined),
                    label: Text(
                      choice.outputRecordId(RoomChoiceOutputType.decision) !=
                              null
                          ? l10n.roomChoiceDecisionCreated
                          : l10n.roomChoiceCreateDecision,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _reopenChoice(repository, choice.id),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(l10n.roomChoiceReopenAction),
                ),
              ),
            ] else if (choice.status == RoomChoiceStatus.open) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _cancelChoice(repository, choice.id),
                  icon: const Icon(Icons.block_outlined),
                  label: Text(l10n.roomChoiceCancelAction),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _money(Money money) =>
      formatMoneyForDisplay(money, money.currencyCode);

  String _date(DateTime date) =>
      MaterialLocalizations.of(context).formatMediumDate(date);

  Future<void> _addChoice() async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.projectId)}'
      '/rooms/${Uri.encodeComponent(widget.roomId)}/choices/new',
    );
    if (mounted) _reload();
  }

  Future<void> _manageRelations() async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.projectId)}'
      '/rooms/${Uri.encodeComponent(widget.roomId)}/relations',
    );
    if (mounted) _reload();
  }

  Future<void> _editChoice(String choiceId) async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.projectId)}'
      '/rooms/${Uri.encodeComponent(widget.roomId)}'
      '/choices/${Uri.encodeComponent(choiceId)}/edit',
    );
    if (mounted) _reload();
  }

  Future<void> _editRoom(String roomId) async {
    await context.push(
      '/projects/${Uri.encodeComponent(widget.projectId)}'
      '/rooms/${Uri.encodeComponent(roomId)}/edit',
    );
    if (mounted) _reload();
  }

  Future<void> _selectVariant(
    RoomRepository repository,
    RoomChoice choice,
    RoomChoiceVariant variant,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.roomChoiceSelectionTitle),
        content: Text('${variant.label}\n\n${l10n.roomChoiceSelectionMessage}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.roomChoiceSelectAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.selectVariant(
      projectId: widget.projectId,
      choiceId: choice.id,
      variantId: variant.id,
    );
    if (mounted) _reload();
  }

  Future<void> _reopenChoice(RoomRepository repository, String choiceId) async {
    await repository.reopenChoice(
      projectId: widget.projectId,
      choiceId: choiceId,
    );
    if (mounted) _reload();
  }

  Future<void> _cancelChoice(RoomRepository repository, String choiceId) async {
    await repository.cancelChoice(
      projectId: widget.projectId,
      choiceId: choiceId,
    );
    if (mounted) _reload();
  }

  Future<void> _createPlannedCost(Room room, RoomChoice choice) async {
    final vatRate = await _selectVatRate();
    if (vatRate == null || !mounted) return;
    final key = '${choice.id}-cost';
    setState(() {
      _creatingOutputs.add(key);
    });
    final l10n = AppLocalizations.of(context);
    try {
      final service = await ref.read(roomChoiceOutputServiceProvider.future);
      await service.createPlannedCost(
        room: room,
        choice: choice,
        vatRate: vatRate,
        name: l10n.roomChoiceCostName(
          choice.input.title,
          choice.selectedVariant!.label,
        ),
        note: l10n.roomChoiceCostNote(room.name),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.roomChoicePlannedCostCreated)),
      );
      _reload();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.roomChoiceOutputError)));
    } finally {
      if (mounted) {
        setState(() {
          _creatingOutputs.remove(key);
        });
      }
    }
  }

  Future<void> _createDecision(Room room, RoomChoice choice) async {
    final key = '${choice.id}-decision';
    setState(() {
      _creatingOutputs.add(key);
    });
    final l10n = AppLocalizations.of(context);
    try {
      final service = await ref.read(roomChoiceOutputServiceProvider.future);
      await service.createDecision(
        room: room,
        choice: choice,
        title: l10n.roomChoiceDecisionTitle(room.name, choice.input.title),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.roomChoiceDecisionCreated)));
      _reload();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.roomChoiceOutputError)));
    } finally {
      if (mounted) {
        setState(() {
          _creatingOutputs.remove(key);
        });
      }
    }
  }

  Future<void> _createMaterial(Room room, RoomChoice choice) async {
    final key = '${choice.id}-material';
    setState(() {
      _creatingOutputs.add(key);
    });
    final l10n = AppLocalizations.of(context);
    try {
      final service = await ref.read(roomChoiceOutputServiceProvider.future);
      await service.createMaterial(
        room: room,
        choice: choice,
        name: l10n.roomChoiceCostName(
          choice.input.title,
          choice.selectedVariant!.label,
        ),
        unitWhenQuantityMissing: l10n.materialDefaultUnit,
        note: l10n.roomChoiceCostNote(room.name),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.roomChoiceMaterialCreated)));
      _reload();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.roomChoiceOutputError)));
    } finally {
      if (mounted) {
        setState(() {
          _creatingOutputs.remove(key);
        });
      }
    }
  }

  Future<VatRate?> _selectVatRate() {
    final l10n = AppLocalizations.of(context);
    return showDialog<VatRate>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.roomChoiceVatTitle),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, VatRate.zero),
            child: Text(l10n.costVatZero),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, VatRate.reduced8),
            child: Text(l10n.costVatReduced),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, VatRate.standard23),
            child: Text(l10n.costVatStandard),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChoice(
    RoomRepository repository,
    RoomChoice choice,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.roomChoiceDeleteTooltip),
        content: Text(choice.input.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.deleteChoice(
      projectId: widget.projectId,
      choiceId: choice.id,
    );
    if (mounted) _reload();
  }

  Future<void> _deleteRoom(RoomRepository repository, String roomId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.roomDeleteTitle),
        content: Text(l10n.roomDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.roomDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.deleteRoom(projectId: widget.projectId, roomId: roomId);
    ref.invalidate(roomsControllerProvider);
    if (mounted) context.pop();
  }
}

final class _RoomDetailsData {
  const _RoomDetailsData({required this.repository, required this.details});

  final RoomRepository repository;
  final RoomDetails details;
}

class _BudgetValue extends StatelessWidget {
  const _BudgetValue({
    required this.label,
    required this.value,
    this.empty,
    this.emphasize = false,
  });

  final String label;
  final String? value;
  final String? empty;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            value ?? empty ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: emphasize ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.variant,
    required this.selected,
    required this.onSelect,
  });

  final RoomChoiceVariant variant;
  final bool selected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
          child: Row(
            children: [
              if (selected) ...[
                const Icon(Icons.check_circle_rounded, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      formatMoneyForDisplay(
                        variant.unitGrossPrice,
                        variant.unitGrossPrice.currencyCode,
                      ),
                    ),
                    if (variant.supplier != null) Text(variant.supplier!),
                  ],
                ),
              ),
              if (onSelect != null)
                IconButton(
                  tooltip: l10n.roomChoiceSelectAction,
                  onPressed: onSelect,
                  icon: const Icon(Icons.check_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatedRow extends StatelessWidget {
  const _RelatedRow({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        l10n.roomRelatedCount(count),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
