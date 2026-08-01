import 'dart:collection';

import 'cost_entry.dart';
import 'money.dart';

final class CostComponentTotals {
  factory CostComponentTotals({
    required CostComponent component,
    required Money planned,
    required Money actual,
  }) {
    if (planned.currencyCode != actual.currencyCode) {
      throw ArgumentError('Component totals must use one currency');
    }
    return CostComponentTotals._(
      component: component,
      planned: planned,
      actual: actual,
    );
  }

  const CostComponentTotals._({
    required this.component,
    required this.planned,
    required this.actual,
  });

  final CostComponent component;
  final Money planned;
  final Money actual;

  Money get difference => actual - planned;
}

final class CostSummary {
  factory CostSummary.fromTotals({
    required Money planned,
    required Money actual,
    Iterable<CostComponentTotals> componentTotals =
        const <CostComponentTotals>[],
  }) {
    if (planned.currencyCode != actual.currencyCode) {
      throw ArgumentError.value(
        actual.currencyCode,
        'actual',
        'must use currency ${planned.currencyCode}',
      );
    }
    final normalizedComponents = <CostComponent, CostComponentTotals>{};
    for (final totals in componentTotals) {
      if (totals.planned.currencyCode != planned.currencyCode) {
        throw ArgumentError(
          'Component totals must use ${planned.currencyCode}',
        );
      }
      if (normalizedComponents.containsKey(totals.component)) {
        throw ArgumentError('Component totals must not contain duplicates');
      }
      normalizedComponents[totals.component] = totals;
    }
    return CostSummary._(
      planned: planned,
      actual: actual,
      difference: actual - planned,
      componentTotals: UnmodifiableMapView(normalizedComponents),
    );
  }

  const CostSummary._({
    required this.planned,
    required this.actual,
    required this.difference,
    required this.componentTotals,
  });

  final Money planned;
  final Money actual;
  final Money difference;
  final UnmodifiableMapView<CostComponent, CostComponentTotals> componentTotals;
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
    final plannedByComponent = <CostComponent, BigInt>{};
    final actualByComponent = <CostComponent, BigInt>{};
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
          plannedByComponent.update(
            entry.component,
            (value) => value + BigInt.from(entry.amount.gross.minorUnits),
            ifAbsent: () => BigInt.from(entry.amount.gross.minorUnits),
          );
        case CostEntryType.cost:
          actualMinorUnits += BigInt.from(entry.amount.gross.minorUnits);
          actualByComponent.update(
            entry.component,
            (value) => value + BigInt.from(entry.amount.gross.minorUnits),
            ifAbsent: () => BigInt.from(entry.amount.gross.minorUnits),
          );
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
      actualByComponent.update(
        target.component,
        (value) => value + correctionTotal.value,
        ifAbsent: () => correctionTotal.value,
      );
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
        plannedByComponent.update(
          CostComponent.unassigned,
          (value) => value + BigInt.from(impact.delta.minorUnits),
          ifAbsent: () => BigInt.from(impact.delta.minorUnits),
        );
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
    return CostSummary.fromTotals(
      planned: planned,
      actual: actual,
      componentTotals: CostComponent.values.map(
        (component) => CostComponentTotals(
          component: component,
          planned: Money.fromBigInt(
            minorUnits: plannedByComponent[component] ?? BigInt.zero,
            currencyCode: currencyCode,
          ),
          actual: Money.fromBigInt(
            minorUnits: actualByComponent[component] ?? BigInt.zero,
            currencyCode: currencyCode,
          ),
        ),
      ),
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
