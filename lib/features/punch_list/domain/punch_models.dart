import 'dart:collection';

import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/shared/models/defect_severity.dart';

export 'package:budowapro/shared/models/defect_severity.dart';

enum AcceptanceProtocolStatus { draft, finalized, signed }

abstract final class PunchFieldLimits {
  static const int id = 64;
  static const int title = 160;
  static const int room = 160;
  static const int description = 4000;
  static const int maximumAttachments = 20;
  static const int maximumDefectsPerProtocol = 100;
}

final class DefectInput {
  factory DefectInput({
    required String projectId,
    required String title,
    required DateTime occurredAt,
    required DefectSeverity severity,
    JournalEntryStatus status = JournalEntryStatus.open,
    String? description,
    String? stageId,
    String? roomLabel,
    String? responsibleContactId,
    DateTime? dueAt,
    bool requiresResolutionPhoto = true,
    bool requiresSignedProtocol = false,
    Iterable<String> attachmentIds = const <String>[],
    Iterable<String> resolutionAttachmentIds = const <String>[],
  }) {
    if (!allowedStatusesFor(JournalEntryType.defect).contains(status) ||
        status == JournalEntryStatus.draft) {
      throw ArgumentError.value(status, 'status');
    }
    return DefectInput._(
      projectId: _requiredText(projectId, 'projectId', PunchFieldLimits.id),
      title: _requiredText(title, 'title', PunchFieldLimits.title),
      occurredAtUtc: occurredAt.toUtc(),
      severity: severity,
      status: status,
      description: _optionalText(
        description,
        'description',
        PunchFieldLimits.description,
      ),
      stageId: _optionalText(stageId, 'stageId', PunchFieldLimits.id),
      roomLabel: _optionalText(roomLabel, 'roomLabel', PunchFieldLimits.room),
      responsibleContactId: _optionalText(
        responsibleContactId,
        'responsibleContactId',
        PunchFieldLimits.id,
      ),
      dueAtUtc: dueAt?.toUtc(),
      requiresResolutionPhoto: requiresResolutionPhoto,
      requiresSignedProtocol: requiresSignedProtocol,
      attachmentIds: _ids(
        attachmentIds,
        'attachmentIds',
        PunchFieldLimits.maximumAttachments,
      ),
      resolutionAttachmentIds: _ids(
        resolutionAttachmentIds,
        'resolutionAttachmentIds',
        PunchFieldLimits.maximumAttachments,
      ),
    );
  }

  const DefectInput._({
    required this.projectId,
    required this.title,
    required this.occurredAtUtc,
    required this.severity,
    required this.status,
    required this.description,
    required this.stageId,
    required this.roomLabel,
    required this.responsibleContactId,
    required this.dueAtUtc,
    required this.requiresResolutionPhoto,
    required this.requiresSignedProtocol,
    required this.attachmentIds,
    required this.resolutionAttachmentIds,
  });

  final String projectId;
  final String title;
  final DateTime occurredAtUtc;
  final DefectSeverity severity;
  final JournalEntryStatus status;
  final String? description;
  final String? stageId;
  final String? roomLabel;
  final String? responsibleContactId;
  final DateTime? dueAtUtc;
  final bool requiresResolutionPhoto;
  final bool requiresSignedProtocol;
  final UnmodifiableListView<String> attachmentIds;
  final UnmodifiableListView<String> resolutionAttachmentIds;

  JournalEntryInput toJournalInput() => JournalEntryInput(
    projectId: projectId,
    type: JournalEntryType.defect,
    title: title,
    occurredAt: occurredAtUtc,
    status: status,
    body: description,
    problem: description,
    stageId: stageId,
    responsibleContactId: responsibleContactId,
    defectSeverity: severity,
    roomLabel: roomLabel,
    requiresResolutionPhoto: requiresResolutionPhoto,
    requiresSignedProtocol: requiresSignedProtocol,
    dueAt: dueAtUtc,
    attachmentIds: attachmentIds,
  );
}

final class DefectRecord {
  factory DefectRecord({
    required JournalEntry entry,
    Iterable<String> resolutionAttachmentIds = const <String>[],
    Iterable<String> acceptanceProtocolIds = const <String>[],
    bool hasSignedProtocol = false,
  }) {
    if (entry.type != JournalEntryType.defect ||
        entry.input.defectSeverity == null) {
      throw ArgumentError.value(entry, 'entry', 'must be a defect');
    }
    return DefectRecord._(
      entry: entry,
      resolutionAttachmentIds: _ids(
        resolutionAttachmentIds,
        'resolutionAttachmentIds',
        PunchFieldLimits.maximumAttachments,
      ),
      acceptanceProtocolIds: _ids(
        acceptanceProtocolIds,
        'acceptanceProtocolIds',
        PunchFieldLimits.maximumDefectsPerProtocol,
      ),
      hasSignedProtocol: hasSignedProtocol,
    );
  }

  const DefectRecord._({
    required this.entry,
    required this.resolutionAttachmentIds,
    required this.acceptanceProtocolIds,
    required this.hasSignedProtocol,
  });

  final JournalEntry entry;
  final UnmodifiableListView<String> resolutionAttachmentIds;
  final UnmodifiableListView<String> acceptanceProtocolIds;
  final bool hasSignedProtocol;

  String get id => entry.id;
  String get projectId => entry.projectId;
  String get title => entry.title;
  JournalEntryStatus get status => entry.status;
  DefectSeverity get severity => entry.input.defectSeverity!;
  String? get description => entry.input.body;
  String? get stageId => entry.input.stageId;
  String? get roomLabel => entry.input.roomLabel;
  String? get responsibleContactId => entry.input.responsibleContactId;
  DateTime? get dueAtUtc => entry.input.dueAt;
  bool get requiresResolutionPhoto => entry.input.requiresResolutionPhoto;
  bool get requiresSignedProtocol => entry.input.requiresSignedProtocol;
  bool get isClosed => status == JournalEntryStatus.closed;
  bool get canClose =>
      (!requiresResolutionPhoto || resolutionAttachmentIds.isNotEmpty) &&
      (!requiresSignedProtocol || hasSignedProtocol);

  bool isOverdue(DateTime now) {
    final dueAt = dueAtUtc;
    return !isClosed && dueAt != null && dueAt.isBefore(now.toUtc());
  }
}

final class DefectQuery {
  factory DefectQuery({
    required String projectId,
    String? searchText,
    Iterable<JournalEntryStatus> statuses = const <JournalEntryStatus>[],
    Iterable<DefectSeverity> severities = const <DefectSeverity>[],
    String? stageId,
    String? responsibleContactId,
    String? roomLabel,
    bool overdueOnly = false,
    DateTime? now,
  }) {
    final normalizedStatuses = statuses.toSet();
    if (normalizedStatuses.any(
      (status) => !allowedStatusesFor(JournalEntryType.defect).contains(status),
    )) {
      throw ArgumentError.value(statuses, 'statuses');
    }
    return DefectQuery._(
      projectId: _requiredText(projectId, 'projectId', PunchFieldLimits.id),
      searchText: _optionalText(
        searchText,
        'searchText',
        PunchFieldLimits.title,
      )?.toLowerCase(),
      statuses: UnmodifiableSetView<JournalEntryStatus>(normalizedStatuses),
      severities: UnmodifiableSetView<DefectSeverity>(severities.toSet()),
      stageId: _optionalText(stageId, 'stageId', PunchFieldLimits.id),
      responsibleContactId: _optionalText(
        responsibleContactId,
        'responsibleContactId',
        PunchFieldLimits.id,
      ),
      roomLabel: _optionalText(
        roomLabel,
        'roomLabel',
        PunchFieldLimits.room,
      )?.toLowerCase(),
      overdueOnly: overdueOnly,
      nowUtc: (now ?? DateTime.now()).toUtc(),
    );
  }

  const DefectQuery._({
    required this.projectId,
    required this.searchText,
    required this.statuses,
    required this.severities,
    required this.stageId,
    required this.responsibleContactId,
    required this.roomLabel,
    required this.overdueOnly,
    required this.nowUtc,
  });

  final String projectId;
  final String? searchText;
  final UnmodifiableSetView<JournalEntryStatus> statuses;
  final UnmodifiableSetView<DefectSeverity> severities;
  final String? stageId;
  final String? responsibleContactId;
  final String? roomLabel;
  final bool overdueOnly;
  final DateTime nowUtc;
}

final class PunchSummary {
  factory PunchSummary({
    required int openCount,
    required int criticalCount,
    required int overdueCount,
  }) {
    if (openCount < 0 || criticalCount < 0 || overdueCount < 0) {
      throw ArgumentError('Punch summary values cannot be negative');
    }
    return PunchSummary._(
      openCount: openCount,
      criticalCount: criticalCount,
      overdueCount: overdueCount,
    );
  }

  const PunchSummary._({
    required this.openCount,
    required this.criticalCount,
    required this.overdueCount,
  });

  factory PunchSummary.fromDefects(
    Iterable<DefectRecord> defects, {
    required DateTime now,
  }) {
    var open = 0;
    var critical = 0;
    var overdue = 0;
    for (final defect in defects) {
      if (defect.isClosed) continue;
      open++;
      if (defect.severity == DefectSeverity.critical) critical++;
      if (defect.isOverdue(now)) overdue++;
    }
    return PunchSummary(
      openCount: open,
      criticalCount: critical,
      overdueCount: overdue,
    );
  }

  final int openCount;
  final int criticalCount;
  final int overdueCount;
}

final class AcceptanceProtocolInput {
  factory AcceptanceProtocolInput({
    required String projectId,
    required String title,
    required DateTime inspectedAt,
    AcceptanceProtocolStatus status = AcceptanceProtocolStatus.draft,
    String? stageId,
    String? roomLabel,
    String? contractorContactId,
    String? notes,
    Iterable<String> defectIds = const <String>[],
    Iterable<String> signedAttachmentIds = const <String>[],
  }) {
    final normalizedAttachments = _ids(
      signedAttachmentIds,
      'signedAttachmentIds',
      PunchFieldLimits.maximumAttachments,
    );
    if (status == AcceptanceProtocolStatus.signed &&
        normalizedAttachments.isEmpty) {
      throw ArgumentError.value(
        signedAttachmentIds,
        'signedAttachmentIds',
        'signed protocol requires a document',
      );
    }
    return AcceptanceProtocolInput._(
      projectId: _requiredText(projectId, 'projectId', PunchFieldLimits.id),
      title: _requiredText(title, 'title', PunchFieldLimits.title),
      inspectedAtUtc: inspectedAt.toUtc(),
      status: status,
      stageId: _optionalText(stageId, 'stageId', PunchFieldLimits.id),
      roomLabel: _optionalText(roomLabel, 'roomLabel', PunchFieldLimits.room),
      contractorContactId: _optionalText(
        contractorContactId,
        'contractorContactId',
        PunchFieldLimits.id,
      ),
      notes: _optionalText(notes, 'notes', PunchFieldLimits.description),
      defectIds: _ids(
        defectIds,
        'defectIds',
        PunchFieldLimits.maximumDefectsPerProtocol,
      ),
      signedAttachmentIds: normalizedAttachments,
    );
  }

  const AcceptanceProtocolInput._({
    required this.projectId,
    required this.title,
    required this.inspectedAtUtc,
    required this.status,
    required this.stageId,
    required this.roomLabel,
    required this.contractorContactId,
    required this.notes,
    required this.defectIds,
    required this.signedAttachmentIds,
  });

  final String projectId;
  final String title;
  final DateTime inspectedAtUtc;
  final AcceptanceProtocolStatus status;
  final String? stageId;
  final String? roomLabel;
  final String? contractorContactId;
  final String? notes;
  final UnmodifiableListView<String> defectIds;
  final UnmodifiableListView<String> signedAttachmentIds;
}

final class AcceptanceProtocol {
  AcceptanceProtocol({
    required this.id,
    required this.input,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAtUtc = createdAt.toUtc(),
       updatedAtUtc = updatedAt.toUtc() {
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
  }

  final String id;
  final AcceptanceProtocolInput input;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get projectId => input.projectId;
  String get title => input.title;
  AcceptanceProtocolStatus get status => input.status;
  DateTime get inspectedAtUtc => input.inspectedAtUtc;
  UnmodifiableListView<String> get defectIds => input.defectIds;
  UnmodifiableListView<String> get signedAttachmentIds =>
      input.signedAttachmentIds;
}

final class AcceptanceProtocolQuery {
  factory AcceptanceProtocolQuery({
    required String projectId,
    String? searchText,
    Iterable<AcceptanceProtocolStatus> statuses =
        const <AcceptanceProtocolStatus>[],
  }) => AcceptanceProtocolQuery._(
    projectId: _requiredText(projectId, 'projectId', PunchFieldLimits.id),
    searchText: _optionalText(
      searchText,
      'searchText',
      PunchFieldLimits.title,
    )?.toLowerCase(),
    statuses: UnmodifiableSetView<AcceptanceProtocolStatus>(statuses.toSet()),
  );

  const AcceptanceProtocolQuery._({
    required this.projectId,
    required this.searchText,
    required this.statuses,
  });

  final String projectId;
  final String? searchText;
  final UnmodifiableSetView<AcceptanceProtocolStatus> statuses;
}

UnmodifiableListView<String> _ids(
  Iterable<String> values,
  String name,
  int maximum,
) {
  final result = <String>[];
  for (final value in values) {
    final normalized = _requiredText(value, name, PunchFieldLimits.id);
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
  return _requiredText(normalized, name, maximumLength);
}
