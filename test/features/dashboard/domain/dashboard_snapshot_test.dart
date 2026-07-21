import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardSnapshot', () {
    test('uses active stage and calculates remaining project budget', () {
      final formalities = _stage(
        id: 'formalities',
        key: ProjectStageKey.formalities,
        order: 0,
        status: StageStatus.completed,
      );
      final stateZero = _stage(
        id: 'state_zero',
        key: ProjectStageKey.stateZero,
        order: 1,
        status: StageStatus.inProgress,
      );

      final snapshot = DashboardSnapshot(
        project: _project(plannedBudgetMinorUnits: 42000000),
        stages: [formalities, stateZero],
        checklistItems: const [],
        todayAgenda: const [],
        spent: _money(8642000),
        plannedNext30Days: _money(4870000),
        unpaid: _money(475000),
        unpaidCount: 3,
        costRecordCount: 2,
        openScheduleCount: 0,
      );

      expect(snapshot.currentStage, same(stateZero));
      expect(snapshot.remainingBudget, _money(33358000));
      expect(snapshot.budgetUtilization, closeTo(0.20576, 0.00001));
      expect(snapshot.isEmptyProject, isFalse);
    });

    test(
      'falls back to project stage when all persisted stages are planned',
      () {
        final formalities = _stage(
          id: 'formalities',
          key: ProjectStageKey.formalities,
          order: 0,
        );
        final stateZero = _stage(
          id: 'state_zero',
          key: ProjectStageKey.stateZero,
          order: 1,
        );

        final snapshot = DashboardSnapshot(
          project: _project(currentStage: ProjectStageKey.stateZero),
          stages: [formalities, stateZero],
          checklistItems: const [],
          todayAgenda: const [],
          spent: _money(0),
          plannedNext30Days: _money(0),
          unpaid: _money(0),
          unpaidCount: 0,
          costRecordCount: 0,
          openScheduleCount: 0,
        );

        expect(snapshot.currentStage, same(stateZero));
        expect(snapshot.isEmptyProject, isTrue);
      },
    );

    test('prioritizes unresolved critical checklist records', () {
      final earlyStage = _stage(
        id: 'state_zero',
        key: ProjectStageKey.stateZero,
        order: 1,
      );
      final laterStage = _stage(
        id: 'shell_open',
        key: ProjectStageKey.shellOpen,
        order: 2,
      );
      final high = _checklist(
        id: 'high',
        stageId: earlyStage.id,
        importance: ChecklistImportance.high,
      );
      final completedCritical = _checklist(
        id: 'done',
        stageId: earlyStage.id,
        importance: ChecklistImportance.critical,
        status: ChecklistStatus.completed,
      );
      final critical = _checklist(
        id: 'critical',
        stageId: laterStage.id,
        importance: ChecklistImportance.critical,
      );

      final snapshot = DashboardSnapshot(
        project: _project(),
        stages: [earlyStage, laterStage],
        checklistItems: [
          DashboardChecklistRecord(stage: earlyStage, item: high),
          DashboardChecklistRecord(stage: earlyStage, item: completedCritical),
          DashboardChecklistRecord(stage: laterStage, item: critical),
        ],
        todayAgenda: const [],
        spent: _money(0),
        plannedNext30Days: _money(0),
        unpaid: _money(0),
        unpaidCount: 0,
        costRecordCount: 0,
        openScheduleCount: 0,
      );

      expect(snapshot.criticalChecklistItems.map((record) => record.item.id), [
        'critical',
        'high',
      ]);
      expect(snapshot.isEmptyProject, isFalse);
    });

    test('rejects metrics in a currency different from the project', () {
      expect(
        () => DashboardSnapshot(
          project: _project(),
          stages: const [],
          checklistItems: const [],
          todayAgenda: const [],
          spent: Money(minorUnits: 0, currencyCode: 'EUR'),
          plannedNext30Days: _money(0),
          unpaid: _money(0),
          unpaidCount: 0,
          costRecordCount: 0,
          openScheduleCount: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}

Project _project({
  int? plannedBudgetMinorUnits,
  ProjectStageKey currentStage = ProjectStageKey.formalities,
}) {
  return Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom testowy',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currencyCode: 'PLN',
      plannedBudgetMinorUnits: plannedBudgetMinorUnits,
      currentStage: currentStage,
    ),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

ProjectStage _stage({
  required String id,
  required ProjectStageKey key,
  required int order,
  StageStatus status = StageStatus.planned,
}) {
  return ProjectStage(
    id: id,
    projectId: 'project-1',
    templateKey: key,
    status: status,
    sortOrder: order,
    progress: StageProgress.fromCounts(
      totalItems: 0,
      completedItems: 0,
      skippedItems: 0,
      blockedItems: 0,
    ),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

ChecklistItem _checklist({
  required String id,
  required String stageId,
  required ChecklistImportance importance,
  ChecklistStatus status = ChecklistStatus.todo,
}) {
  return ChecklistItem(
    id: id,
    projectId: 'project-1',
    stageId: stageId,
    customTitle: 'Pozycja $id',
    status: status,
    importance: importance,
    evidenceRequirement: EvidenceRequirement.none,
    evidenceIds: const [],
    sortOrder: 0,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

Money _money(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');
