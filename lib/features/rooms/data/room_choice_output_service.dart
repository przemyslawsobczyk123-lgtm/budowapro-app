import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/diary/domain/journal_repository.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';

final class RoomChoiceOutputService {
  const RoomChoiceOutputService(
    this._roomRepository,
    this._costRepository,
    this._journalRepository,
    this._materialRepository,
    this._utcNow,
  );

  final RoomRepository _roomRepository;
  final CostRepository _costRepository;
  final JournalRepository _journalRepository;
  final MaterialRepository _materialRepository;
  final DateTime Function() _utcNow;

  Future<CostEntry> createPlannedCost({
    required Room room,
    required RoomChoice choice,
    required VatRate vatRate,
    required String name,
    String? note,
  }) async {
    final selected = _requireSelected(room, choice);
    if (choice.outputRecordId(RoomChoiceOutputType.plannedCost) != null) {
      throw const RoomChoiceOutputExistsException();
    }
    final gross = choice.estimatedGross!;
    final quantity = _estimatedQuantity(choice);
    final cost = await _costRepository.saveDraft(
      CostDraftInput(
        CostEntryInput(
          projectId: room.projectId,
          name: name,
          type: CostEntryType.planned,
          component: CostComponent.material,
          status: CostStatus.planned,
          amount: VatBreakdown.fromGross(gross, vatRate),
          entryDate: _utcNow(),
          quantity: quantity,
          unit: quantity == null ? null : choice.input.unit,
          source: CostSource.manual,
          note: note ?? selected.note,
        ),
      ),
    );
    try {
      await _roomRepository.assignRecord(
        projectId: room.projectId,
        roomId: room.id,
        type: RoomRecordType.cost,
        recordId: cost.id,
      );
      await _roomRepository.registerChoiceOutput(
        projectId: room.projectId,
        choiceId: choice.id,
        outputType: RoomChoiceOutputType.plannedCost,
        recordId: cost.id,
      );
      return cost;
    } on Object {
      await _roomRepository.unassignRecord(
        projectId: room.projectId,
        type: RoomRecordType.cost,
        recordId: cost.id,
      );
      await _costRepository.delete(
        projectId: room.projectId,
        costEntryId: cost.id,
      );
      rethrow;
    }
  }

  Future<JournalEntry> createDecision({
    required Room room,
    required RoomChoice choice,
    required String title,
    String? rationale,
  }) async {
    final selected = _requireSelected(room, choice);
    if (choice.outputRecordId(RoomChoiceOutputType.decision) != null) {
      throw const RoomChoiceOutputExistsException();
    }
    final decision = await _journalRepository.create(
      JournalEntryInput(
        projectId: room.projectId,
        type: JournalEntryType.decision,
        title: title,
        occurredAt: _utcNow(),
        status: JournalEntryStatus.proposal,
        problem: choice.input.title,
        variants: choice.variants.map((variant) => variant.label).join('\n'),
        selectedOption: selected.label,
        rationale: rationale ?? choice.input.note,
      ),
    );
    try {
      await _roomRepository.assignRecord(
        projectId: room.projectId,
        roomId: room.id,
        type: RoomRecordType.journal,
        recordId: decision.id,
      );
      await _roomRepository.registerChoiceOutput(
        projectId: room.projectId,
        choiceId: choice.id,
        outputType: RoomChoiceOutputType.decision,
        recordId: decision.id,
      );
      return decision;
    } on Object {
      await _roomRepository.unassignRecord(
        projectId: room.projectId,
        type: RoomRecordType.journal,
        recordId: decision.id,
      );
      await _journalRepository.delete(
        projectId: room.projectId,
        entryId: decision.id,
      );
      rethrow;
    }
  }

  Future<MaterialItem> createMaterial({
    required Room room,
    required RoomChoice choice,
    required String name,
    required String unitWhenQuantityMissing,
    String? note,
  }) async {
    final selected = _requireSelected(room, choice);
    if (choice.outputRecordId(RoomChoiceOutputType.material) != null) {
      throw const RoomChoiceOutputExistsException();
    }
    final quantity = _materialQuantity(choice);
    final material = await _materialRepository.create(
      MaterialInput(
        projectId: room.projectId,
        name: name,
        orderedQuantity:
            quantity ?? MaterialQuantity(unscaledValue: 1, scale: 0),
        unit: quantity == null ? unitWhenQuantityMissing : choice.input.unit!,
        roomId: room.id,
        costEntryId: choice.outputRecordId(RoomChoiceOutputType.plannedCost),
        orderedGross: choice.estimatedGross,
        note: note ?? selected.note,
      ),
    );
    try {
      await _roomRepository.registerChoiceOutput(
        projectId: room.projectId,
        choiceId: choice.id,
        outputType: RoomChoiceOutputType.material,
        recordId: material.id,
      );
      return material;
    } on Object {
      await _materialRepository.delete(
        projectId: room.projectId,
        materialId: material.id,
      );
      rethrow;
    }
  }

  RoomChoiceVariant _requireSelected(Room room, RoomChoice choice) {
    if (choice.input.projectId != room.projectId ||
        choice.input.roomId != room.id ||
        choice.status != RoomChoiceStatus.selected ||
        choice.selectedVariant == null ||
        choice.estimatedGross == null) {
      throw const RoomChoiceOutputUnavailableException();
    }
    return choice.selectedVariant!;
  }

  DecimalQuantity? _estimatedQuantity(RoomChoice choice) {
    final unscaled = choice.estimatedQuantityUnscaled;
    final scale = choice.estimatedQuantityScale;
    if (unscaled == null || scale == null) return null;
    if (unscaled > BigInt.from(9223372036854775807)) {
      throw const RoomChoiceOutputUnavailableException();
    }
    return DecimalQuantity(unscaledValue: unscaled.toInt(), scale: scale);
  }

  MaterialQuantity? _materialQuantity(RoomChoice choice) {
    final unscaled = choice.estimatedQuantityUnscaled;
    final scale = choice.estimatedQuantityScale;
    if (unscaled == null || scale == null) return null;
    if (unscaled > BigInt.from(9223372036854775807)) {
      throw const RoomChoiceOutputUnavailableException();
    }
    return MaterialQuantity(unscaledValue: unscaled.toInt(), scale: scale);
  }
}
