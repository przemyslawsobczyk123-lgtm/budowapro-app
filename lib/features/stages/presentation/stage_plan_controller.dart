import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stage_plan_gateway.dart';

final stagePlanControllerProvider =
    AsyncNotifierProvider<StagePlanController, StagePlanState>(
      StagePlanController.new,
    );

final class StagePlanState {
  StagePlanState({
    required this.project,
    required Iterable<ProjectStage> stages,
    required this.selectedStageId,
    required Iterable<ChecklistItem> checklistItems,
    this.isSaving = false,
  }) : stages = List<ProjectStage>.unmodifiable(stages),
       checklistItems = List<ChecklistItem>.unmodifiable(checklistItems);

  final Project? project;
  final List<ProjectStage> stages;
  final String? selectedStageId;
  final List<ChecklistItem> checklistItems;
  final bool isSaving;

  ProjectStage? get selectedStage {
    for (final stage in stages) {
      if (stage.id == selectedStageId) {
        return stage;
      }
    }
    return null;
  }

  StagePlanState copyWith({bool? isSaving}) {
    return StagePlanState(
      project: project,
      stages: stages,
      selectedStageId: selectedStageId,
      checklistItems: checklistItems,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final class StagePlanController extends AsyncNotifier<StagePlanState> {
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<StagePlanState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) {
      return StagePlanState(
        project: null,
        stages: const <ProjectStage>[],
        selectedStageId: null,
        checklistItems: const <ChecklistItem>[],
      );
    }
    final repository = await ref.watch(stageRepositoryProvider.future);
    return _load(repository, project);
  }

  Future<void> refresh() async {
    ref.invalidate(stagePlanGatewayProvider);
    ref.invalidate(stagePlanControllerProvider);
  }

  Future<void> selectStage(String stageId) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null || current.selectedStageId == stageId) {
      return;
    }
    final repository = await ref.read(stageRepositoryProvider.future);
    if (!ref.mounted) return;
    state = AsyncData<StagePlanState>(current.copyWith(isSaving: true));
    try {
      final selected = await _load(
        repository,
        project,
        selectedStageId: stageId,
      );
      if (!ref.mounted) return;
      state = AsyncData<StagePlanState>(selected);
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncData<StagePlanState>(current);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> addStage(String name) {
    return _mutate((repository, current) async {
      final added = await repository.addCustomStage(
        projectId: current.project!.id,
        name: name,
      );
      return added.id;
    });
  }

  Future<void> renameStage(String stageId, String name) {
    return _mutate((repository, current) async {
      await repository.renameStage(
        projectId: current.project!.id,
        stageId: stageId,
        name: name,
      );
      return stageId;
    });
  }

  Future<void> reorderStages(List<String> stageIds) {
    return _mutate((repository, current) async {
      await repository.reorderStages(
        projectId: current.project!.id,
        stageIds: stageIds,
      );
      return current.selectedStageId;
    });
  }

  Future<void> updateStage(String stageId, StageDetailsInput input) {
    return _mutate((repository, current) async {
      await repository.updateStage(
        projectId: current.project!.id,
        stageId: stageId,
        input: input,
      );
      return stageId;
    });
  }

  Future<void> addChecklistItem({
    required String title,
    required ChecklistItemDetailsInput input,
  }) {
    return _mutate((repository, current) async {
      await repository.addChecklistItem(
        projectId: current.project!.id,
        stageId: current.selectedStageId!,
        title: title,
        input: input,
      );
      return current.selectedStageId;
    });
  }

  Future<void> updateChecklistItem(
    String checklistItemId,
    ChecklistItemDetailsInput input,
  ) {
    return _mutate((repository, current) async {
      await repository.updateChecklistItem(
        projectId: current.project!.id,
        checklistItemId: checklistItemId,
        input: input,
      );
      return current.selectedStageId;
    });
  }

  Future<void> completeChecklistItems(Iterable<String> checklistItemIds) {
    final uniqueIds = checklistItemIds.toSet().toList(growable: false);
    if (uniqueIds.isEmpty) {
      return Future<void>.value();
    }
    return _mutate((repository, current) async {
      await repository.completeChecklistItems(
        projectId: current.project!.id,
        checklistItemIds: uniqueIds,
      );
      return current.selectedStageId;
    });
  }

  Future<bool> attachEvidence(String checklistItemId) async {
    var attached = false;
    await _mutate((repository, current) async {
      final gateway = await ref.read(stagePlanGatewayProvider.future);
      attached = await gateway.pickAndAttachEvidence(
        projectId: current.project!.id,
        checklistItemId: checklistItemId,
      );
      return current.selectedStageId;
    });
    return attached;
  }

  Future<void> _mutate(
    Future<String?> Function(StageRepository repository, StagePlanState current)
    action,
  ) {
    final mutation = _mutationQueue.then<void>((_) async {
      if (!ref.mounted) return;
      final current = state.requireValue;
      final project = current.project;
      if (project == null) {
        return;
      }
      state = AsyncData<StagePlanState>(current.copyWith(isSaving: true));
      try {
        final repository = await ref.read(stageRepositoryProvider.future);
        if (!ref.mounted) return;
        final selectedStageId = await action(repository, current);
        if (!ref.mounted) return;
        final refreshed = await _load(
          repository,
          project,
          selectedStageId: selectedStageId,
        );
        if (!ref.mounted) return;
        state = AsyncData<StagePlanState>(refreshed);
      } on Object catch (error, stackTrace) {
        if (ref.mounted) {
          state = AsyncData<StagePlanState>(current);
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _mutationQueue = mutation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return mutation;
  }

  static Future<StagePlanState> _load(
    StageRepository repository,
    Project project, {
    String? selectedStageId,
  }) async {
    final stages = await repository.listStages(
      projectId: project.id,
      template: project.template,
    );
    var selected = selectedStageId;
    if (!stages.any((stage) => stage.id == selected)) {
      selected = stages
          .where(
            (stage) =>
                stage.templateKey == project.currentStage ||
                stage.id == _stageId(project.currentStage),
          )
          .firstOrNull
          ?.id;
    }
    selected ??= stages.firstOrNull?.id;
    final items = selected == null
        ? const <ChecklistItem>[]
        : await repository.listChecklistItems(
            projectId: project.id,
            stageId: selected,
          );
    return StagePlanState(
      project: project,
      stages: stages,
      selectedStageId: selected,
      checklistItems: items,
    );
  }
}

String _stageId(ProjectStageKey key) => switch (key) {
  ProjectStageKey.planning => 'planning',
  ProjectStageKey.formalities => 'formalities',
  ProjectStageKey.sitePreparation => 'site_preparation',
  ProjectStageKey.stateZero => 'state_zero',
  ProjectStageKey.shellOpen => 'shell_open',
  ProjectStageKey.shellClosed => 'shell_closed',
  ProjectStageKey.demolition => 'demolition',
  ProjectStageKey.installations => 'installations',
  ProjectStageKey.plaster => 'plaster',
  ProjectStageKey.finishing => 'finishing',
  ProjectStageKey.handover => 'handover',
};
