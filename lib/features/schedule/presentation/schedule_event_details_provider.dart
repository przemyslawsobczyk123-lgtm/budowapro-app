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
      blockers = const <ScheduleBlocker>[],
      dateChanges = const <ScheduleDateChange>[],
      dependencyCandidates = const <ScheduleEvent>[];

  final ScheduleEvent? event;
  final List<ScheduleBlocker> blockers;
  final List<ScheduleDateChange> dateChanges;
  final List<ScheduleEvent> dependencyCandidates;
}
