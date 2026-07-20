import 'package:budowapro/features/projects/domain/project_template.dart';

enum StageStatus { planned, inProgress, blocked, completed }

enum ChecklistStatus { todo, inProgress, blocked, completed, skipped }

enum ChecklistImportance { low, normal, high, critical }

enum EvidenceRequirement { none, anyAttachment, photo }

final class StageProgress {
  const StageProgress._({
    required this.totalItems,
    required this.completedItems,
    required this.skippedItems,
    required this.blockedItems,
  });

  factory StageProgress.fromStatuses(Iterable<ChecklistStatus> statuses) {
    var total = 0;
    var completed = 0;
    var skipped = 0;
    var blocked = 0;
    for (final status in statuses) {
      total++;
      switch (status) {
        case ChecklistStatus.completed:
          completed++;
        case ChecklistStatus.skipped:
          skipped++;
        case ChecklistStatus.blocked:
          blocked++;
        case ChecklistStatus.todo || ChecklistStatus.inProgress:
          break;
      }
    }
    return StageProgress.fromCounts(
      totalItems: total,
      completedItems: completed,
      skippedItems: skipped,
      blockedItems: blocked,
    );
  }

  factory StageProgress.fromCounts({
    required int totalItems,
    required int completedItems,
    required int skippedItems,
    required int blockedItems,
  }) {
    if (totalItems < 0 ||
        completedItems < 0 ||
        skippedItems < 0 ||
        blockedItems < 0 ||
        completedItems + skippedItems + blockedItems > totalItems) {
      throw ArgumentError('invalid checklist progress counts');
    }
    return StageProgress._(
      totalItems: totalItems,
      completedItems: completedItems,
      skippedItems: skippedItems,
      blockedItems: blockedItems,
    );
  }

  final int totalItems;
  final int completedItems;
  final int skippedItems;
  final int blockedItems;

  int get resolvedItems => completedItems + skippedItems;
  double get fraction => totalItems == 0 ? 0 : resolvedItems / totalItems;
  int get percent => (fraction * 100).round();
}

final class ProjectStage {
  factory ProjectStage({
    required String id,
    required String projectId,
    required StageStatus status,
    required int sortOrder,
    required StageProgress progress,
    required DateTime createdAt,
    required DateTime updatedAt,
    ProjectStageKey? templateKey,
    String? customName,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    int? plannedBudgetMinorUnits,
  }) {
    final normalizedCustomName = _optionalText(
      customName,
      'customName',
      maximumLength: 80,
    );
    if ((templateKey == null) == (normalizedCustomName == null)) {
      throw ArgumentError(
        'exactly one of templateKey and customName must be provided',
      );
    }
    final start = plannedStart?.toUtc();
    final end = plannedEnd?.toUtc();
    if (start != null && end != null && end.isBefore(start)) {
      throw ArgumentError.value(plannedEnd, 'plannedEnd');
    }
    if (plannedBudgetMinorUnits != null && plannedBudgetMinorUnits < 0) {
      throw RangeError.value(
        plannedBudgetMinorUnits,
        'plannedBudgetMinorUnits',
      );
    }
    if (sortOrder < 0) {
      throw RangeError.value(sortOrder, 'sortOrder');
    }
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return ProjectStage._(
      id: _requiredText(id, 'id', maximumLength: 64),
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      templateKey: templateKey,
      customName: normalizedCustomName,
      status: status,
      sortOrder: sortOrder,
      plannedStart: start,
      plannedEnd: end,
      plannedBudgetMinorUnits: plannedBudgetMinorUnits,
      progress: progress,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const ProjectStage._({
    required this.id,
    required this.projectId,
    required this.templateKey,
    required this.customName,
    required this.status,
    required this.sortOrder,
    required this.plannedStart,
    required this.plannedEnd,
    required this.plannedBudgetMinorUnits,
    required this.progress,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String projectId;
  final ProjectStageKey? templateKey;
  final String? customName;
  final StageStatus status;
  final int sortOrder;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final int? plannedBudgetMinorUnits;
  final StageProgress progress;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class StageDetailsInput {
  factory StageDetailsInput({
    required StageStatus status,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    int? plannedBudgetMinorUnits,
  }) {
    final start = plannedStart?.toUtc();
    final end = plannedEnd?.toUtc();
    if (start != null && end != null && end.isBefore(start)) {
      throw ArgumentError.value(plannedEnd, 'plannedEnd');
    }
    if (plannedBudgetMinorUnits != null && plannedBudgetMinorUnits < 0) {
      throw RangeError.value(
        plannedBudgetMinorUnits,
        'plannedBudgetMinorUnits',
      );
    }
    return StageDetailsInput._(
      status: status,
      plannedStart: start,
      plannedEnd: end,
      plannedBudgetMinorUnits: plannedBudgetMinorUnits,
    );
  }

  const StageDetailsInput._({
    required this.status,
    required this.plannedStart,
    required this.plannedEnd,
    required this.plannedBudgetMinorUnits,
  });

  final StageStatus status;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final int? plannedBudgetMinorUnits;
}

final class ChecklistItem {
  factory ChecklistItem({
    required String id,
    required String projectId,
    required String stageId,
    required ChecklistStatus status,
    required ChecklistImportance importance,
    required EvidenceRequirement evidenceRequirement,
    required Iterable<String> evidenceIds,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    ChecklistTemplateKey? templateKey,
    String? customTitle,
    DateTime? dueDate,
    String? assignee,
    String? note,
    String? riskIfSkipped,
    String? statusReason,
    String? evidenceWaiverComment,
  }) {
    final normalizedTitle = _optionalText(
      customTitle,
      'customTitle',
      maximumLength: 160,
    );
    if ((templateKey == null) == (normalizedTitle == null)) {
      throw ArgumentError(
        'exactly one of templateKey and customTitle must be provided',
      );
    }
    final normalizedEvidenceIds = evidenceIds
        .map((id) => _requiredText(id, 'evidenceId', maximumLength: 64))
        .toSet()
        .toList(growable: false);
    final normalizedReason = _optionalText(
      statusReason,
      'statusReason',
      maximumLength: 500,
    );
    final normalizedWaiver = _optionalText(
      evidenceWaiverComment,
      'evidenceWaiverComment',
      maximumLength: 500,
    );
    validateChecklistResolution(
      status: status,
      evidenceRequirement: evidenceRequirement,
      evidenceCount: normalizedEvidenceIds.length,
      statusReason: normalizedReason,
      evidenceWaiverComment: normalizedWaiver,
    );
    if (sortOrder < 0) {
      throw RangeError.value(sortOrder, 'sortOrder');
    }
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return ChecklistItem._(
      id: _requiredText(id, 'id', maximumLength: 64),
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      stageId: _requiredText(stageId, 'stageId', maximumLength: 64),
      templateKey: templateKey,
      customTitle: normalizedTitle,
      status: status,
      importance: importance,
      dueDate: dueDate?.toUtc(),
      assignee: _optionalText(assignee, 'assignee', maximumLength: 120),
      note: _optionalText(note, 'note', maximumLength: 2000),
      riskIfSkipped: _optionalText(
        riskIfSkipped,
        'riskIfSkipped',
        maximumLength: 500,
      ),
      statusReason: normalizedReason,
      evidenceRequirement: evidenceRequirement,
      evidenceWaiverComment: normalizedWaiver,
      evidenceIds: normalizedEvidenceIds,
      sortOrder: sortOrder,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const ChecklistItem._({
    required this.id,
    required this.projectId,
    required this.stageId,
    required this.templateKey,
    required this.customTitle,
    required this.status,
    required this.importance,
    required this.dueDate,
    required this.assignee,
    required this.note,
    required this.riskIfSkipped,
    required this.statusReason,
    required this.evidenceRequirement,
    required this.evidenceWaiverComment,
    required this.evidenceIds,
    required this.sortOrder,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String projectId;
  final String stageId;
  final ChecklistTemplateKey? templateKey;
  final String? customTitle;
  final ChecklistStatus status;
  final ChecklistImportance importance;
  final DateTime? dueDate;
  final String? assignee;
  final String? note;
  final String? riskIfSkipped;
  final String? statusReason;
  final EvidenceRequirement evidenceRequirement;
  final String? evidenceWaiverComment;
  final List<String> evidenceIds;
  final int sortOrder;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  bool get hasEvidence => evidenceIds.isNotEmpty;
  bool get hasEvidenceWaiver => evidenceWaiverComment != null;
}

final class ChecklistItemDetailsInput {
  factory ChecklistItemDetailsInput({
    required ChecklistStatus status,
    required ChecklistImportance importance,
    required EvidenceRequirement evidenceRequirement,
    DateTime? dueDate,
    String? assignee,
    String? note,
    String? riskIfSkipped,
    String? statusReason,
    String? evidenceWaiverComment,
  }) {
    return ChecklistItemDetailsInput._(
      status: status,
      importance: importance,
      dueDate: dueDate?.toUtc(),
      assignee: _optionalText(assignee, 'assignee', maximumLength: 120),
      note: _optionalText(note, 'note', maximumLength: 2000),
      riskIfSkipped: _optionalText(
        riskIfSkipped,
        'riskIfSkipped',
        maximumLength: 500,
      ),
      statusReason: _optionalText(
        statusReason,
        'statusReason',
        maximumLength: 500,
      ),
      evidenceRequirement: evidenceRequirement,
      evidenceWaiverComment: _optionalText(
        evidenceWaiverComment,
        'evidenceWaiverComment',
        maximumLength: 500,
      ),
    );
  }

  const ChecklistItemDetailsInput._({
    required this.status,
    required this.importance,
    required this.dueDate,
    required this.assignee,
    required this.note,
    required this.riskIfSkipped,
    required this.statusReason,
    required this.evidenceRequirement,
    required this.evidenceWaiverComment,
  });

  final ChecklistStatus status;
  final ChecklistImportance importance;
  final DateTime? dueDate;
  final String? assignee;
  final String? note;
  final String? riskIfSkipped;
  final String? statusReason;
  final EvidenceRequirement evidenceRequirement;
  final String? evidenceWaiverComment;
}

void validateChecklistResolution({
  required ChecklistStatus status,
  required EvidenceRequirement evidenceRequirement,
  required int evidenceCount,
  String? statusReason,
  String? evidenceWaiverComment,
}) {
  if (evidenceCount < 0) {
    throw RangeError.value(evidenceCount, 'evidenceCount');
  }
  final reason = statusReason?.trim();
  if (status == ChecklistStatus.skipped && (reason == null || reason.isEmpty)) {
    throw const ChecklistSkipReasonRequiredException();
  }
  final waiver = evidenceWaiverComment?.trim();
  if (status == ChecklistStatus.completed &&
      evidenceRequirement != EvidenceRequirement.none &&
      evidenceCount == 0 &&
      (waiver == null || waiver.isEmpty)) {
    throw const ChecklistEvidenceRequiredException();
  }
}

final class ChecklistEvidenceRequiredException implements Exception {
  const ChecklistEvidenceRequiredException();
}

final class ChecklistSkipReasonRequiredException implements Exception {
  const ChecklistSkipReasonRequiredException();
}

enum ChecklistTemplateKey {
  soilResearch,
  surveyorBuildingSetout,
  siteRoadPowerWater,
  excavationFoundationLevels,
  underSlabSewerAndRisers,
  waterPenetration,
  powerPenetration,
  telecomPenetration,
  gasPenetration,
  gateIntercomGardenReserve,
  heatPumpOutdoorReserve,
  foundationGrounding,
  continuityMeasurement,
  horizontalVerticalWaterproofing,
  drainage,
  concealedWorksPhotos,
  concreteDeliveryAndAcceptance,
  postFoundationSurvey,
}

String _requiredText(
  String value,
  String argumentName, {
  required int maximumLength,
}) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, argumentName);
  }
  return normalized;
}

String? _optionalText(
  String? value,
  String argumentName, {
  required int maximumLength,
}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return _requiredText(value, argumentName, maximumLength: maximumLength);
}
