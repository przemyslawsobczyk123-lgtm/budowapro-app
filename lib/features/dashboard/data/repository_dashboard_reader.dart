import 'package:budowapro/features/captures/domain/capture_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_summary.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_reader.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/shared/models/page.dart';

final class RepositoryDashboardReader implements DashboardReader {
  factory RepositoryDashboardReader({
    required CaptureRepository captureRepository,
    required CostRepository costRepository,
    required StageRepository stageRepository,
    required ScheduleRepository scheduleRepository,
  }) {
    return RepositoryDashboardReader._(
      captureRepository,
      costRepository,
      stageRepository,
      scheduleRepository,
    );
  }

  const RepositoryDashboardReader._(
    this._captureRepository,
    this._costRepository,
    this._stageRepository,
    this._scheduleRepository,
  );

  final CaptureRepository _captureRepository;
  final CostRepository _costRepository;
  final StageRepository _stageRepository;
  final ScheduleRepository _scheduleRepository;

  @override
  Future<DashboardSnapshot> load({
    required Project project,
    required DashboardWindow window,
  }) async {
    final spentQuery = CostQuery(
      projectId: project.id,
      types: const <CostEntryType>{CostEntryType.cost},
      statuses: const <CostStatus>{CostStatus.paid},
    );
    final forecastQuery = CostQuery(
      projectId: project.id,
      types: const <CostEntryType>{CostEntryType.cost, CostEntryType.planned},
      statuses: const <CostStatus>{
        CostStatus.planned,
        CostStatus.ordered,
        CostStatus.due,
        CostStatus.disputed,
      },
      fromInclusive: window.todayStartUtc,
      toExclusive: window.forecastEndExclusiveUtc,
    );
    final unpaidQuery = CostQuery(
      projectId: project.id,
      types: const <CostEntryType>{CostEntryType.cost},
      statuses: const <CostStatus>{CostStatus.due, CostStatus.disputed},
    );
    final allCostsQuery = CostQuery(projectId: project.id, includeDrafts: true);
    final stages = await _stageRepository.listStages(
      projectId: project.id,
      template: project.template,
    );
    final results = await Future.wait<Object>([
      _stageRepository.listProjectChecklistItems(projectId: project.id),
      _costRepository.summarize(CostSummaryQuery.fromCostQuery(spentQuery)),
      _costRepository.summarize(CostSummaryQuery.fromCostQuery(forecastQuery)),
      _costRepository.summarize(CostSummaryQuery.fromCostQuery(unpaidQuery)),
      _costRepository.list(unpaidQuery, PageRequest(limit: 1)),
      _costRepository.list(allCostsQuery, PageRequest(limit: 1)),
      _scheduleRepository.list(
        projectId: project.id,
        window: ScheduleWindow(
          start: window.todayStartUtc,
          endExclusive: window.todayEndExclusiveUtc,
        ),
      ),
      _scheduleRepository.listOpen(projectId: project.id),
      _captureRepository.countOpen(projectId: project.id),
    ]);

    final checklistItems = results[0] as List<ChecklistItem>;
    final spent = results[1] as CostSummary;
    final forecast = results[2] as CostSummary;
    final unpaid = results[3] as CostSummary;
    final unpaidPage = results[4] as Page<CostEntry>;
    final allCostsPage = results[5] as Page<CostEntry>;
    final todayAgenda = results[6] as List<ScheduleEvent>;
    final openEvents = results[7] as List<ScheduleEvent>;
    final openCaptureCount = results[8] as int;
    final upcomingVisits = openEvents
        .where(
          (event) =>
              event.kind == ScheduleEventKind.visit &&
              !event.startsAtUtc.isBefore(window.todayStartUtc) &&
              event.startsAtUtc.isBefore(window.forecastEndExclusiveUtc),
        )
        .take(3)
        .toList(growable: false);
    final stagesById = <String, ProjectStage>{
      for (final stage in stages) stage.id: stage,
    };
    final checklistRecords = checklistItems
        .map((item) {
          final stage = stagesById[item.stageId];
          if (stage == null) {
            throw StateError('Checklist item references a missing stage');
          }
          return DashboardChecklistRecord(stage: stage, item: item);
        })
        .toList(growable: false);

    return DashboardSnapshot(
      project: project,
      stages: stages,
      checklistItems: checklistRecords,
      todayAgenda: todayAgenda,
      upcomingVisits: upcomingVisits,
      spent: spent.actual,
      plannedNext30Days: forecast.planned + forecast.actual,
      unpaid: unpaid.actual,
      unpaidCount: unpaidPage.totalCount,
      costRecordCount: allCostsPage.totalCount,
      openScheduleCount: openEvents.length,
      openCaptureCount: openCaptureCount,
    );
  }
}
