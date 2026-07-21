import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/dashboard/data/repository_dashboard_reader.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_reader.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/sqlite_schedule_repository.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/stages/data/sqlite_stage_repository.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory directory;
  late AppDatabase database;
  late Project project;
  late SqliteCostRepository costs;
  late SqliteStageRepository stages;
  late SqliteScheduleRepository schedule;
  late RepositoryDashboardReader reader;
  var id = 0;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('dashboard_reader_');
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(directory.path, 'test.db'),
    );
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(directory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 7, 1),
    );
    project = await projects.create(
      ProjectDraft(
        name: 'Dom testowy',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
        plannedBudgetMinorUnits: 42000000,
      ),
    );
    costs = SqliteCostRepository(
      database: database,
      idGenerator: () => 'cost-${++id}',
      utcNow: () => DateTime.utc(2026, 7, 20, 10),
    );
    stages = SqliteStageRepository(
      database: database,
      idGenerator: () => 'stage-${++id}',
      utcNow: () => DateTime.utc(2026, 7, 20, 10),
    );
    schedule = SqliteScheduleRepository(
      database: database,
      idGenerator: () => 'event-${++id}',
      utcNow: () => DateTime.utc(2026, 7, 20, 10),
    );
    reader = RepositoryDashboardReader(
      costRepository: costs,
      stageRepository: stages,
      scheduleRepository: schedule,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('projects dashboard metrics from source repositories', () async {
    await costs.create(
      ConfirmedCostEntryInput(
        _cost(
          name: 'Beton oplacony',
          type: CostEntryType.cost,
          status: CostStatus.paid,
          grossMinorUnits: 8642000,
          date: DateTime.utc(2026, 7, 10),
        ),
      ),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        _cost(
          name: 'Faktura do zaplaty',
          type: CostEntryType.cost,
          status: CostStatus.due,
          grossMinorUnits: 475000,
          date: DateTime.utc(2026, 7, 21),
        ),
      ),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        _cost(
          name: 'Okna zaliczka',
          type: CostEntryType.planned,
          status: CostStatus.planned,
          grossMinorUnits: 4870000,
          date: DateTime.utc(2026, 7, 30),
        ),
      ),
    );
    await costs.create(
      ConfirmedCostEntryInput(
        _cost(
          name: 'Poza zakresem 30 dni',
          type: CostEntryType.planned,
          status: CostStatus.planned,
          grossMinorUnits: 99900,
          date: DateTime.utc(2026, 9, 1),
        ),
      ),
    );

    final seededStages = await stages.listStages(
      projectId: project.id,
      template: project.template,
    );
    final stateZero = seededStages.singleWhere(
      (stage) => stage.templateKey == ProjectStageKey.stateZero,
    );
    await stages.updateStage(
      projectId: project.id,
      stageId: stateZero.id,
      input: StageDetailsInput(status: StageStatus.inProgress),
    );
    final stateZeroItems = await stages.listChecklistItems(
      projectId: project.id,
      stageId: stateZero.id,
    );
    final grounding = stateZeroItems.singleWhere(
      (item) => item.templateKey == ChecklistTemplateKey.foundationGrounding,
    );
    await stages.updateChecklistItem(
      projectId: project.id,
      checklistItemId: grounding.id,
      input: ChecklistItemDetailsInput(
        status: ChecklistStatus.inProgress,
        importance: grounding.importance,
        evidenceRequirement: grounding.evidenceRequirement,
      ),
    );

    final today = await schedule.create(
      projectId: project.id,
      input: _event('Odbior zbrojenia', DateTime.utc(2026, 7, 21, 8)),
    );
    final upcomingVisit = await schedule.create(
      projectId: project.id,
      input: _event(
        'Wizyta elektryka',
        DateTime.utc(2026, 7, 22, 8),
        kind: ScheduleEventKind.visit,
      ),
    );

    final snapshot = await reader.load(
      project: project,
      window: DashboardWindow(
        todayStart: DateTime.utc(2026, 7, 21),
        todayEndExclusive: DateTime.utc(2026, 7, 22),
        forecastEndExclusive: DateTime.utc(2026, 8, 20),
      ),
    );

    expect(snapshot.spent.minorUnits, 8642000);
    expect(snapshot.plannedNext30Days.minorUnits, 5345000);
    expect(snapshot.unpaid.minorUnits, 475000);
    expect(snapshot.unpaidCount, 1);
    expect(snapshot.costRecordCount, 4);
    expect(snapshot.openScheduleCount, 2);
    expect(snapshot.todayAgenda.map((event) => event.id), [today.id]);
    expect(snapshot.upcomingVisits.map((event) => event.id), [
      upcomingVisit.id,
    ]);
    expect(snapshot.currentStage?.id, stateZero.id);
    expect(
      snapshot.criticalChecklistItems.map((record) => record.item.id),
      contains(grounding.id),
    );
  });

  test('keeps fresh project distinct from no project', () async {
    final snapshot = await reader.load(
      project: project,
      window: DashboardWindow(
        todayStart: DateTime.utc(2026, 7, 21),
        todayEndExclusive: DateTime.utc(2026, 7, 22),
        forecastEndExclusive: DateTime.utc(2026, 8, 20),
      ),
    );

    expect(snapshot.isEmptyProject, isTrue);
    expect(snapshot.stages, isNotEmpty);
  });
}

CostEntryInput _cost({
  required String name,
  required CostEntryType type,
  required CostStatus status,
  required int grossMinorUnits,
  required DateTime date,
}) {
  return CostEntryInput(
    projectId: 'project-1',
    name: name,
    type: type,
    status: status,
    amount: VatBreakdown.fromGross(
      Money(minorUnits: grossMinorUnits, currencyCode: 'PLN'),
      VatRate.standard23,
    ),
    entryDate: date,
  );
}

ScheduleEventInput _event(
  String title,
  DateTime startsAt, {
  ScheduleEventKind kind = ScheduleEventKind.task,
}) {
  return ScheduleEventInput(
    title: title,
    kind: kind,
    status: ScheduleEventStatus.planned,
    startsAt: startsAt,
    timeZoneId: 'Europe/Warsaw',
    isAllDay: false,
    reminderEnabled: false,
    reminderLeadMinutes: 60,
  );
}
