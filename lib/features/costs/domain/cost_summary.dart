import 'cost_entry.dart';
import 'money.dart';

final class CostSummary {
  factory CostSummary.fromTotals({
    required Money planned,
    required Money actual,
  }) {
    if (planned.currencyCode != actual.currencyCode) {
      throw ArgumentError.value(
        actual.currencyCode,
        'actual',
        'must use currency ${planned.currencyCode}',
      );
    }
    return CostSummary._(
      planned: planned,
      actual: actual,
      difference: actual - planned,
    );
  }

  const CostSummary._({
    required this.planned,
    required this.actual,
    required this.difference,
  });

  final Money planned;
  final Money actual;
  final Money difference;
}

final class CalculateCostSummary {
  const CalculateCostSummary();

  CostSummary call({
    required String projectId,
    required String currencyCode,
    Iterable<CostEntry> entries = const <CostEntry>[],
    Iterable<CostCorrection> corrections = const <CostCorrection>[],
    Iterable<DecisionCostImpact> decisionImpacts = const <DecisionCostImpact>[],
  }) {
    final normalizedProjectId = projectId.trim();
    if (normalizedProjectId.isEmpty) {
      throw ArgumentError.value(projectId, 'projectId', 'must not be empty');
    }

    var plannedMinorUnits = BigInt.zero;
    var actualMinorUnits = BigInt.zero;
    final entriesById = <String, CostEntry>{};

    for (final entry in entries) {
      _requireProject(normalizedProjectId, entry.projectId);
      _requireCurrency(currencyCode, entry.amount.gross);
      if (entriesById.containsKey(entry.id)) {
        throw StateError('Duplicate cost entry id: ${entry.id}');
      }
      entriesById[entry.id] = entry;
      if (entry.lifecycle != CostLifecycle.confirmed) {
        continue;
      }
      switch (entry.type) {
        case CostEntryType.planned:
          plannedMinorUnits += BigInt.from(entry.amount.gross.minorUnits);
        case CostEntryType.cost:
          actualMinorUnits += BigInt.from(entry.amount.gross.minorUnits);
        case CostEntryType.offer:
          break;
      }
    }

    final correctionIds = <String>{};
    final correctionDeltaByEntryId = <String, BigInt>{};
    for (final correction in corrections) {
      _requireProject(normalizedProjectId, correction.projectId);
      _requireCurrency(currencyCode, correction.delta.gross);
      if (!correctionIds.add(correction.id)) {
        throw StateError('Duplicate cost correction id: ${correction.id}');
      }
      final target = entriesById[correction.costEntryId];
      if (target == null ||
          target.type != CostEntryType.cost ||
          target.lifecycle != CostLifecycle.confirmed) {
        throw StateError('Cost correction must target a confirmed cost entry');
      }
      correctionDeltaByEntryId.update(
        target.id,
        (delta) => delta + BigInt.from(correction.delta.gross.minorUnits),
        ifAbsent: () => BigInt.from(correction.delta.gross.minorUnits),
      );
    }

    for (final correctionTotal in correctionDeltaByEntryId.entries) {
      final target = entriesById[correctionTotal.key]!;
      final correctedGross =
          BigInt.from(target.amount.gross.minorUnits) + correctionTotal.value;
      if (correctedGross.isNegative) {
        throw StateError('Cost corrections exceed the original gross amount');
      }
      actualMinorUnits += correctionTotal.value;
    }

    final impactIds = <String>{};
    for (final impact in decisionImpacts) {
      _requireProject(normalizedProjectId, impact.projectId);
      _requireCurrency(currencyCode, impact.delta);
      if (!impactIds.add(impact.id)) {
        throw StateError('Duplicate decision cost impact id: ${impact.id}');
      }
      if (impact.status == DecisionCostImpactStatus.approved) {
        plannedMinorUnits += BigInt.from(impact.delta.minorUnits);
      }
    }

    final planned = Money.fromBigInt(
      minorUnits: plannedMinorUnits,
      currencyCode: currencyCode,
    );
    final actual = Money.fromBigInt(
      minorUnits: actualMinorUnits,
      currencyCode: currencyCode,
    );
    return CostSummary._(
      planned: planned,
      actual: actual,
      difference: actual - planned,
    );
  }

  static void _requireProject(String expected, String actual) {
    if (expected != actual) {
      throw ArgumentError.value(
        actual,
        'projectId',
        'must match project $expected',
      );
    }
  }

  static void _requireCurrency(String expected, Money amount) {
    if (expected != amount.currencyCode) {
      throw ArgumentError.value(
        amount.currencyCode,
        'currencyCode',
        'must match project currency $expected',
      );
    }
  }
}
