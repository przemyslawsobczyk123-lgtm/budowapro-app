import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'schedule_plan_controller.dart';

typedef ScheduleEventKey = ({String projectId, String eventId});

final scheduleEventDetailsProvider = FutureProvider.autoDispose
    .family<ScheduleEventDetails, ScheduleEventKey>((ref, key) async {
      final repository = await ref.watch(scheduleRepositoryProvider.future);
      final event = await repository.findById(
        projectId: key.projectId,
        eventId: key.eventId,
      );
      if (event == null) return const ScheduleEventDetails.missing();
      final siteVisit = event.kind == ScheduleEventKind.visit
          ? await (await ref.watch(
              siteVisitRepositoryProvider.future,
            )).findById(projectId: key.projectId, visitId: key.eventId)
          : null;
      final dependencies = await repository.listDependencies(
        projectId: key.projectId,
        eventId: key.eventId,
      );
      final blockers = <ScheduleBlocker>[];
      for (final dependency in dependencies) {
        final blocker = await repository.findById(
          projectId: key.projectId,
          eventId: dependency.blockingEventId,
        );
        if (blocker != null) {
          blockers.add(ScheduleBlocker(dependency: dependency, event: blocker));
        }
      }
      return ScheduleEventDetails(
        event: event,
        siteVisit: siteVisit,
        blockers: blockers,
        dateChanges: await repository.listDateChanges(
          projectId: key.projectId,
          eventId: key.eventId,
        ),
        dependencyCandidates: (await repository.listOpen(
          projectId: key.projectId,
        )).where((candidate) => candidate.id != event.id),
      );
    });

final class ScheduleEventDetails {
  ScheduleEventDetails({
    required this.event,
    this.siteVisit,
    required Iterable<ScheduleBlocker> blockers,
    required Iterable<ScheduleDateChange> dateChanges,
    required Iterable<ScheduleEvent> dependencyCandidates,
  }) : blockers = List<ScheduleBlocker>.unmodifiable(blockers),
       dateChanges = List<ScheduleDateChange>.unmodifiable(dateChanges),
       dependencyCandidates = List<ScheduleEvent>.unmodifiable(
         dependencyCandidates,
       );

  const ScheduleEventDetails.missing()
    : event = null,
      siteVisit = null,
      blockers = const <ScheduleBlocker>[],
      dateChanges = const <ScheduleDateChange>[],
      dependencyCandidates = const <ScheduleEvent>[];

  final ScheduleEvent? event;
  final SiteVisit? siteVisit;
  final List<ScheduleBlocker> blockers;
  final List<ScheduleDateChange> dateChanges;
  final List<ScheduleEvent> dependencyCandidates;
}
