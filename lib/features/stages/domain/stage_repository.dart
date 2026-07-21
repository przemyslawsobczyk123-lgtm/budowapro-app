import 'package:budowapro/features/projects/domain/project_template.dart';

import 'stage_plan.dart';

abstract interface class StageRepository {
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  });

  Future<List<ChecklistItem>> listChecklistItems({
    required String projectId,
    required String stageId,
  });

  Future<List<ChecklistItem>> listProjectChecklistItems({
    required String projectId,
  });

  Future<ProjectStage> addCustomStage({
    required String projectId,
    required String name,
  });

  Future<ProjectStage> renameStage({
    required String projectId,
    required String stageId,
    required String name,
  });

  Future<void> reorderStages({
    required String projectId,
    required List<String> stageIds,
  });

  Future<ProjectStage> updateStage({
    required String projectId,
    required String stageId,
    required StageDetailsInput input,
  });

  Future<ChecklistItem> addChecklistItem({
    required String projectId,
    required String stageId,
    required String title,
    required ChecklistItemDetailsInput input,
  });

  Future<ChecklistItem> updateChecklistItem({
    required String projectId,
    required String checklistItemId,
    required ChecklistItemDetailsInput input,
  });

  Future<ChecklistItem> attachEvidence({
    required String projectId,
    required String checklistItemId,
    required String attachmentId,
  });

  Future<ChecklistItem> detachEvidence({
    required String projectId,
    required String checklistItemId,
    required String attachmentId,
  });
}

final class StageNotFoundException implements Exception {
  const StageNotFoundException();
}

final class ChecklistItemNotFoundException implements Exception {
  const ChecklistItemNotFoundException();
}

final class StageOrderMismatchException implements Exception {
  const StageOrderMismatchException();
}

final class ChecklistEvidenceNotFoundException implements Exception {
  const ChecklistEvidenceNotFoundException();
}
