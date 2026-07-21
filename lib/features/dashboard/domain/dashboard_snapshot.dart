import 'dart:collection';

import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';

final class DashboardChecklistRecord {
  const DashboardChecklistRecord({required this.stage, required this.item});

  final ProjectStage stage;
  final ChecklistItem item;
}

final class DashboardSnapshot {
  factory DashboardSnapshot({
    required Project project,
    required Iterable<ProjectStage> stages,
    required Iterable<DashboardChecklistRecord> checklistItems,
    required Iterable<ScheduleEvent> todayAgenda,
    required Money spent,
    required Money plannedNext30Days,
    required Money unpaid,
    required int unpaidCount,
    required int costRecordCount,
    required int openScheduleCount,
  }) {
    final stageList = stages.toList(growable: false)
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final checklistList = checklistItems.toList(growable: false);
    final agenda = todayAgenda.toList(growable: false)
      ..sort((left, right) {
        final byTime = left.startsAtUtc.compareTo(right.startsAtUtc);
        return byTime != 0 ? byTime : left.id.compareTo(right.id);
      });

    _requireCurrency(project, spent);
    _requireCurrency(project, plannedNext30Days);
    _requireCurrency(project, unpaid);
    if (unpaidCount < 0 || costRecordCount < 0 || openScheduleCount < 0) {
      throw ArgumentError('dashboard counts must not be negative');
    }
    for (final stage in stageList) {
      if (stage.projectId != project.id) {
        throw ArgumentError('stage belongs to another project');
      }
    }
    for (final record in checklistList) {
      if (record.stage.projectId != project.id ||
          record.item.projectId != project.id ||
          record.item.stageId != record.stage.id) {
        throw ArgumentError('checklist record belongs to another project');
      }
    }
    for (final event in agenda) {
      if (event.projectId != project.id) {
        throw ArgumentError('agenda event belongs to another project');
      }
    }

    final critical =
        checklistList.where(_isCriticalAndOpen).toList(growable: false)
          ..sort(_compareCriticalRecords);
    return DashboardSnapshot._(
      project: project,
      stages: UnmodifiableListView<ProjectStage>(stageList),
      checklistItems: UnmodifiableListView<DashboardChecklistRecord>(
        checklistList,
      ),
      criticalChecklistItems: UnmodifiableListView<DashboardChecklistRecord>(
        critical,
      ),
      todayAgenda: UnmodifiableListView<ScheduleEvent>(agenda),
      spent: spent,
      plannedNext30Days: plannedNext30Days,
      unpaid: unpaid,
      unpaidCount: unpaidCount,
      costRecordCount: costRecordCount,
      openScheduleCount: openScheduleCount,
    );
  }

  const DashboardSnapshot._({
    required this.project,
    required this.stages,
    required this.checklistItems,
    required this.criticalChecklistItems,
    required this.todayAgenda,
    required this.spent,
    required this.plannedNext30Days,
    required this.unpaid,
    required this.unpaidCount,
    required this.costRecordCount,
    required this.openScheduleCount,
  });

  final Project project;
  final UnmodifiableListView<ProjectStage> stages;
  final UnmodifiableListView<DashboardChecklistRecord> checklistItems;
  final UnmodifiableListView<DashboardChecklistRecord> criticalChecklistItems;
  final UnmodifiableListView<ScheduleEvent> todayAgenda;
  final Money spent;
  final Money plannedNext30Days;
  final Money unpaid;
  final int unpaidCount;
  final int costRecordCount;
  final int openScheduleCount;

  ProjectStage? get currentStage {
    for (final stage in stages) {
      if (stage.status == StageStatus.inProgress) return stage;
    }
    for (final stage in stages) {
      if (stage.status == StageStatus.blocked) return stage;
    }
    for (final stage in stages) {
      if (stage.templateKey == project.currentStage) return stage;
    }
    for (final stage in stages) {
      if (stage.status != StageStatus.completed) return stage;
    }
    return stages.lastOrNull;
  }

  Money? get plannedBudget {
    final minorUnits = project.plannedBudgetMinorUnits;
    if (minorUnits == null) return null;
    return Money(minorUnits: minorUnits, currencyCode: project.currencyCode);
  }

  Money? get remainingBudget {
    final budget = plannedBudget;
    return budget == null ? null : budget - spent;
  }

  double? get budgetUtilization {
    final budget = plannedBudget;
    if (budget == null || budget.isZero) return null;
    return spent.minorUnits / budget.minorUnits;
  }

  bool get isEmptyProject {
    return costRecordCount == 0 &&
        openScheduleCount == 0 &&
        stages.every((stage) => stage.status == StageStatus.planned) &&
        checklistItems.every(
          (record) => record.item.status == ChecklistStatus.todo,
        );
  }
}

bool _isCriticalAndOpen(DashboardChecklistRecord record) {
  final item = record.item;
  final isOpen =
      item.status != ChecklistStatus.completed &&
      item.status != ChecklistStatus.skipped;
  return isOpen &&
      (item.importance == ChecklistImportance.high ||
          item.importance == ChecklistImportance.critical);
}

int _compareCriticalRecords(
  DashboardChecklistRecord left,
  DashboardChecklistRecord right,
) {
  final byImportance = _importanceRank(
    left.item.importance,
  ).compareTo(_importanceRank(right.item.importance));
  if (byImportance != 0) return byImportance;
  final byStatus = _statusRank(
    left.item.status,
  ).compareTo(_statusRank(right.item.status));
  if (byStatus != 0) return byStatus;
  final byDueDate = _compareNullableDates(
    left.item.dueDate,
    right.item.dueDate,
  );
  if (byDueDate != 0) return byDueDate;
  final byStage = left.stage.sortOrder.compareTo(right.stage.sortOrder);
  if (byStage != 0) return byStage;
  final byItem = left.item.sortOrder.compareTo(right.item.sortOrder);
  return byItem != 0 ? byItem : left.item.id.compareTo(right.item.id);
}

int _importanceRank(ChecklistImportance value) => switch (value) {
  ChecklistImportance.critical => 0,
  ChecklistImportance.high => 1,
  ChecklistImportance.normal => 2,
  ChecklistImportance.low => 3,
};

int _statusRank(ChecklistStatus value) => switch (value) {
  ChecklistStatus.blocked => 0,
  ChecklistStatus.inProgress => 1,
  ChecklistStatus.todo => 2,
  ChecklistStatus.completed || ChecklistStatus.skipped => 3,
};

int _compareNullableDates(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return left.compareTo(right);
}

void _requireCurrency(Project project, Money value) {
  if (value.currencyCode != project.currencyCode) {
    throw ArgumentError.value(
      value.currencyCode,
      'currencyCode',
      'must match project currency ${project.currencyCode}',
    );
  }
}
