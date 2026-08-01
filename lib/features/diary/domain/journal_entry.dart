import 'dart:collection';

import 'package:budowapro/shared/models/defect_severity.dart';

enum JournalEntryType { daily, note, decision, defect, scopeChange }

enum JournalEntryStatus {
  draft,
  open,
  inProgress,
  proposal,
  pending,
  approved,
  rejected,
  implemented,
  recheck,
  fixed,
  closed,
}

enum JournalRelationType { stage, contact, checklist, schedule, cost, capture }

enum JournalRelationPurpose { context, blocks }

abstract final class JournalFieldLimits {
  static const int id = 64;
  static const int title = 160;
  static const int shortText = 500;
  static const int longText = 4000;
  static const int relationLabel = 160;
  static const int maximumAttachments = 20;
  static const int maximumRelations = 50;
}

final class JournalRelation {
  factory JournalRelation({
    required JournalRelationType type,
    required String targetId,
    JournalRelationPurpose purpose = JournalRelationPurpose.context,
    String? label,
  }) {
    return JournalRelation._(
      type: type,
      targetId: _requiredText(targetId, 'targetId', JournalFieldLimits.id),
      purpose: purpose,
      label: _optionalText(label, 'label', JournalFieldLimits.relationLabel),
    );
  }

  const JournalRelation._({
    required this.type,
    required this.targetId,
    required this.purpose,
    required this.label,
  });

  final JournalRelationType type;
  final String targetId;
  final JournalRelationPurpose purpose;
  final String? label;
}

final class JournalApproval {
  factory JournalApproval({
    required String approvedByContactId,
    required DateTime approvedAt,
  }) {
    return JournalApproval._(
      approvedByContactId: _requiredText(
        approvedByContactId,
        'approvedByContactId',
        JournalFieldLimits.id,
      ),
      approvedAtUtc: approvedAt.toUtc(),
    );
  }

  const JournalApproval._({
    required this.approvedByContactId,
    required this.approvedAtUtc,
  });

  final String approvedByContactId;
  final DateTime approvedAtUtc;
}

final class DecisionImpactSummary {
  factory DecisionImpactSummary({
    required String projectId,
    required int approvedDecisionCount,
    required int costDeltaMinorUnits,
    required int scheduleDeltaDays,
  }) {
    if (approvedDecisionCount < 0) {
      throw RangeError.value(approvedDecisionCount, 'approvedDecisionCount');
    }
    return DecisionImpactSummary._(
      projectId: _requiredText(projectId, 'projectId', JournalFieldLimits.id),
      approvedDecisionCount: approvedDecisionCount,
      costDeltaMinorUnits: costDeltaMinorUnits,
      scheduleDeltaDays: scheduleDeltaDays,
    );
  }

  const DecisionImpactSummary._({
    required this.projectId,
    required this.approvedDecisionCount,
    required this.costDeltaMinorUnits,
    required this.scheduleDeltaDays,
  });

  final String projectId;
  final int approvedDecisionCount;
  final int costDeltaMinorUnits;
  final int scheduleDeltaDays;
}

final class JournalEntryInput {
  factory JournalEntryInput({
    required String projectId,
    required JournalEntryType type,
    required String title,
    required DateTime occurredAt,
    JournalEntryStatus? status,
    String? body,
    String? weather,
    String? people,
    String? workPerformed,
    String? deliveries,
    String? delays,
    String? nextSteps,
    String? problem,
    String? variants,
    String? selectedOption,
    String? rationale,
    String? stageId,
    String? responsibleContactId,
    String? decisionMakerContactId,
    DefectSeverity? defectSeverity,
    String? roomLabel,
    bool requiresResolutionPhoto = false,
    bool requiresSignedProtocol = false,
    DateTime? dueAt,
    int? costDeltaMinorUnits,
    int? scheduleDeltaDays,
    Iterable<String> attachmentIds = const <String>[],
    Iterable<JournalRelation> relations = const <JournalRelation>[],
    String? sourceCaptureId,
  }) {
    final normalizedProjectId = _requiredText(
      projectId,
      'projectId',
      JournalFieldLimits.id,
    );
    final normalizedTitle = _requiredText(
      title,
      'title',
      JournalFieldLimits.title,
    );
    final normalizedStatus = status ?? defaultStatusFor(type);
    if (!allowedStatusesFor(type).contains(normalizedStatus)) {
      throw ArgumentError.value(status, 'status');
    }
    final normalizedAttachments = _uniqueIds(
      attachmentIds,
      'attachmentIds',
      JournalFieldLimits.maximumAttachments,
    );
    final normalizedRelations = UnmodifiableListView<JournalRelation>(
      relations,
    );
    if (normalizedRelations.length > JournalFieldLimits.maximumRelations) {
      throw ArgumentError.value(relations, 'relations');
    }
    if (normalizedRelations.any(
          (relation) => relation.purpose == JournalRelationPurpose.blocks,
        ) &&
        type != JournalEntryType.decision &&
        type != JournalEntryType.scopeChange) {
      throw ArgumentError.value(relations, 'relations');
    }
    if (costDeltaMinorUnits != null &&
        costDeltaMinorUnits.abs() > 9000000000000) {
      throw RangeError.value(costDeltaMinorUnits, 'costDeltaMinorUnits');
    }
    if (scheduleDeltaDays != null && scheduleDeltaDays.abs() > 36500) {
      throw RangeError.value(scheduleDeltaDays, 'scheduleDeltaDays');
    }
    if (type != JournalEntryType.defect &&
        (defectSeverity != null ||
            roomLabel != null ||
            requiresResolutionPhoto ||
            requiresSignedProtocol)) {
      throw ArgumentError.value(type, 'type', 'does not accept defect fields');
    }
    return JournalEntryInput._(
      projectId: normalizedProjectId,
      type: type,
      title: normalizedTitle,
      occurredAt: occurredAt.toUtc(),
      status: normalizedStatus,
      body: _optionalText(body, 'body', JournalFieldLimits.longText),
      weather: _optionalText(weather, 'weather', JournalFieldLimits.shortText),
      people: _optionalText(people, 'people', JournalFieldLimits.shortText),
      workPerformed: _optionalText(
        workPerformed,
        'workPerformed',
        JournalFieldLimits.longText,
      ),
      deliveries: _optionalText(
        deliveries,
        'deliveries',
        JournalFieldLimits.longText,
      ),
      delays: _optionalText(delays, 'delays', JournalFieldLimits.longText),
      nextSteps: _optionalText(
        nextSteps,
        'nextSteps',
        JournalFieldLimits.longText,
      ),
      problem: _optionalText(problem, 'problem', JournalFieldLimits.longText),
      variants: _optionalText(
        variants,
        'variants',
        JournalFieldLimits.longText,
      ),
      selectedOption: _optionalText(
        selectedOption,
        'selectedOption',
        JournalFieldLimits.longText,
      ),
      rationale: _optionalText(
        rationale,
        'rationale',
        JournalFieldLimits.longText,
      ),
      stageId: _optionalText(stageId, 'stageId', JournalFieldLimits.id),
      responsibleContactId: _optionalText(
        responsibleContactId,
        'responsibleContactId',
        JournalFieldLimits.id,
      ),
      decisionMakerContactId: _optionalText(
        decisionMakerContactId,
        'decisionMakerContactId',
        JournalFieldLimits.id,
      ),
      defectSeverity: type == JournalEntryType.defect
          ? defectSeverity ?? DefectSeverity.medium
          : null,
      roomLabel: type == JournalEntryType.defect
          ? _optionalText(
              roomLabel,
              'roomLabel',
              JournalFieldLimits.relationLabel,
            )
          : null,
      requiresResolutionPhoto:
          type == JournalEntryType.defect && requiresResolutionPhoto,
      requiresSignedProtocol:
          type == JournalEntryType.defect && requiresSignedProtocol,
      dueAt: dueAt?.toUtc(),
      costDeltaMinorUnits: costDeltaMinorUnits,
      scheduleDeltaDays: scheduleDeltaDays,
      attachmentIds: normalizedAttachments,
      relations: normalizedRelations,
      sourceCaptureId: _optionalText(
        sourceCaptureId,
        'sourceCaptureId',
        JournalFieldLimits.id,
      ),
    );
  }

  const JournalEntryInput._({
    required this.projectId,
    required this.type,
    required this.title,
    required this.occurredAt,
    required this.status,
    required this.body,
    required this.weather,
    required this.people,
    required this.workPerformed,
    required this.deliveries,
    required this.delays,
    required this.nextSteps,
    required this.problem,
    required this.variants,
    required this.selectedOption,
    required this.rationale,
    required this.stageId,
    required this.responsibleContactId,
    required this.decisionMakerContactId,
    required this.defectSeverity,
    required this.roomLabel,
    required this.requiresResolutionPhoto,
    required this.requiresSignedProtocol,
    required this.dueAt,
    required this.costDeltaMinorUnits,
    required this.scheduleDeltaDays,
    required this.attachmentIds,
    required this.relations,
    required this.sourceCaptureId,
  });

  final String projectId;
  final JournalEntryType type;
  final String title;
  final DateTime occurredAt;
  final JournalEntryStatus status;
  final String? body;
  final String? weather;
  final String? people;
  final String? workPerformed;
  final String? deliveries;
  final String? delays;
  final String? nextSteps;
  final String? problem;
  final String? variants;
  final String? selectedOption;
  final String? rationale;
  final String? stageId;
  final String? responsibleContactId;
  final String? decisionMakerContactId;
  final DefectSeverity? defectSeverity;
  final String? roomLabel;
  final bool requiresResolutionPhoto;
  final bool requiresSignedProtocol;
  final DateTime? dueAt;
  final int? costDeltaMinorUnits;
  final int? scheduleDeltaDays;
  final UnmodifiableListView<String> attachmentIds;
  final UnmodifiableListView<JournalRelation> relations;
  final String? sourceCaptureId;
}

final class JournalEntry {
  JournalEntry({
    required this.id,
    required this.input,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.revision,
    this.approval,
  }) : createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    if (revision < 1) throw RangeError.value(revision, 'revision');
    final hasApprovedStatus =
        status == JournalEntryStatus.approved ||
        status == JournalEntryStatus.implemented;
    if (hasApprovedStatus != (approval != null)) {
      throw ArgumentError.value(approval, 'approval');
    }
  }

  final String id;
  final JournalEntryInput input;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final int revision;
  final JournalApproval? approval;

  String get projectId => input.projectId;
  JournalEntryType get type => input.type;
  JournalEntryStatus get status => input.status;
  String get title => input.title;
  DateTime get occurredAtUtc => input.occurredAt;
  String? get body => input.body;
  UnmodifiableListView<String> get attachmentIds => input.attachmentIds;
  UnmodifiableListView<JournalRelation> get relations => input.relations;
}

final class JournalEntryRevision {
  const JournalEntryRevision({
    required this.id,
    required this.projectId,
    required this.entryId,
    required this.revision,
    required this.action,
    required this.snapshotJson,
    required this.createdAtUtc,
  });

  final String id;
  final String projectId;
  final String entryId;
  final int revision;
  final String action;
  final String snapshotJson;
  final DateTime createdAtUtc;
}

final class JournalEntryQuery {
  factory JournalEntryQuery({
    required String projectId,
    Iterable<JournalEntryType> types = const <JournalEntryType>[],
    Iterable<JournalEntryStatus> statuses = const <JournalEntryStatus>[],
    String? searchTerm,
    String? stageId,
    DateTime? from,
    DateTime? to,
  }) {
    return JournalEntryQuery._(
      projectId: _requiredText(projectId, 'projectId', JournalFieldLimits.id),
      types: UnmodifiableSetView<JournalEntryType>(types.toSet()),
      statuses: UnmodifiableSetView<JournalEntryStatus>(statuses.toSet()),
      searchTerm: _optionalText(
        searchTerm,
        'searchTerm',
        JournalFieldLimits.title,
      )?.toLowerCase(),
      stageId: _optionalText(stageId, 'stageId', JournalFieldLimits.id),
      from: from?.toUtc(),
      to: to?.toUtc(),
    );
  }

  const JournalEntryQuery._({
    required this.projectId,
    required this.types,
    required this.statuses,
    required this.searchTerm,
    required this.stageId,
    required this.from,
    required this.to,
  });

  final String projectId;
  final UnmodifiableSetView<JournalEntryType> types;
  final UnmodifiableSetView<JournalEntryStatus> statuses;
  final String? searchTerm;
  final String? stageId;
  final DateTime? from;
  final DateTime? to;
}

JournalEntryStatus defaultStatusFor(JournalEntryType type) {
  return switch (type) {
    JournalEntryType.daily || JournalEntryType.note => JournalEntryStatus.open,
    JournalEntryType.decision ||
    JournalEntryType.scopeChange => JournalEntryStatus.proposal,
    JournalEntryType.defect => JournalEntryStatus.open,
  };
}

Set<JournalEntryStatus> allowedStatusesFor(JournalEntryType type) {
  return switch (type) {
    JournalEntryType.daily || JournalEntryType.note => <JournalEntryStatus>{
      JournalEntryStatus.draft,
      JournalEntryStatus.open,
      JournalEntryStatus.closed,
    },
    JournalEntryType.decision ||
    JournalEntryType.scopeChange => <JournalEntryStatus>{
      JournalEntryStatus.draft,
      JournalEntryStatus.proposal,
      JournalEntryStatus.pending,
      JournalEntryStatus.approved,
      JournalEntryStatus.rejected,
      JournalEntryStatus.implemented,
    },
    JournalEntryType.defect => <JournalEntryStatus>{
      JournalEntryStatus.draft,
      JournalEntryStatus.open,
      JournalEntryStatus.inProgress,
      JournalEntryStatus.recheck,
      JournalEntryStatus.fixed,
      JournalEntryStatus.closed,
    },
  };
}

UnmodifiableListView<String> _uniqueIds(
  Iterable<String> values,
  String name,
  int maximum,
) {
  final result = <String>[];
  for (final value in values) {
    final normalized = _requiredText(value, name, JournalFieldLimits.id);
    if (!result.contains(normalized)) result.add(normalized);
  }
  if (result.length > maximum) throw ArgumentError.value(values, name);
  return UnmodifiableListView<String>(result);
}

String _requiredText(String value, String name, int maximumLength) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}

String? _optionalText(String? value, String name, int maximumLength) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized.length > maximumLength) throw ArgumentError.value(value, name);
  return normalized;
}
