import 'dart:collection';

enum CaptureDraftType {
  photo,
  document,
  note,
  voice,
  cost,
  task,
  decision,
  defect,
}

enum CaptureDraftStatus { needsReview, ready, classified }

enum CaptureMissingContext {
  title,
  content,
  attachment,
  grossAmount,
  vatRate,
  scheduledAt,
}

enum CaptureTargetType {
  document,
  costDraft,
  scheduleTask,
  note,
  decision,
  defect,
}

final class CaptureDraftInput {
  factory CaptureDraftInput({
    required String projectId,
    required CaptureDraftType type,
    String? title,
    String? content,
    Iterable<String> attachmentIds = const <String>[],
    int? grossAmountMinorUnits,
    int? vatRateBasisPoints,
    DateTime? scheduledAt,
    String? timeZoneId,
  }) {
    if (grossAmountMinorUnits != null && grossAmountMinorUnits <= 0) {
      throw RangeError.value(
        grossAmountMinorUnits,
        'grossAmountMinorUnits',
        'must be positive',
      );
    }
    if (vatRateBasisPoints != null &&
        !const <int>{0, 800, 2300}.contains(vatRateBasisPoints)) {
      throw ArgumentError.value(vatRateBasisPoints, 'vatRateBasisPoints');
    }
    final scheduledAtUtc = scheduledAt?.toUtc();
    final normalizedTimeZone = _optionalText(
      timeZoneId,
      'timeZoneId',
      maximumLength: 64,
    );
    if ((scheduledAtUtc == null) != (normalizedTimeZone == null)) {
      throw ArgumentError(
        'scheduledAt and timeZoneId must be provided together',
      );
    }
    return CaptureDraftInput._(
      projectId: _requiredText(projectId, 'projectId', maximumLength: 64),
      type: type,
      title: _optionalText(title, 'title', maximumLength: 160),
      content: _optionalText(content, 'content', maximumLength: 4000),
      attachmentIds: _normalizedIds(attachmentIds),
      grossAmountMinorUnits: grossAmountMinorUnits,
      vatRateBasisPoints: vatRateBasisPoints,
      scheduledAtUtc: scheduledAtUtc,
      timeZoneId: normalizedTimeZone,
    );
  }

  const CaptureDraftInput._({
    required this.projectId,
    required this.type,
    required this.title,
    required this.content,
    required this.attachmentIds,
    required this.grossAmountMinorUnits,
    required this.vatRateBasisPoints,
    required this.scheduledAtUtc,
    required this.timeZoneId,
  });

  final String projectId;
  final CaptureDraftType type;
  final String? title;
  final String? content;
  final UnmodifiableListView<String> attachmentIds;
  final int? grossAmountMinorUnits;
  final int? vatRateBasisPoints;
  final DateTime? scheduledAtUtc;
  final String? timeZoneId;

  Set<CaptureMissingContext> get missingContext {
    final missing = <CaptureMissingContext>{};
    if (title == null) missing.add(CaptureMissingContext.title);
    switch (type) {
      case CaptureDraftType.photo ||
          CaptureDraftType.document ||
          CaptureDraftType.voice:
        if (attachmentIds.isEmpty) {
          missing.add(CaptureMissingContext.attachment);
        }
      case CaptureDraftType.note ||
          CaptureDraftType.decision ||
          CaptureDraftType.defect:
        if (content == null) missing.add(CaptureMissingContext.content);
      case CaptureDraftType.cost:
        if (grossAmountMinorUnits == null) {
          missing.add(CaptureMissingContext.grossAmount);
        }
        if (vatRateBasisPoints == null) {
          missing.add(CaptureMissingContext.vatRate);
        }
      case CaptureDraftType.task:
        if (scheduledAtUtc == null || timeZoneId == null) {
          missing.add(CaptureMissingContext.scheduledAt);
        }
    }
    return Set<CaptureMissingContext>.unmodifiable(missing);
  }

  CaptureDraftStatus get status => missingContext.isEmpty
      ? CaptureDraftStatus.ready
      : CaptureDraftStatus.needsReview;
}

final class CaptureDraft {
  factory CaptureDraft({
    required String id,
    required CaptureDraftInput input,
    required CaptureDraftStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    CaptureTargetType? targetType,
    String? targetId,
  }) {
    final normalizedId = _requiredText(id, 'id', maximumLength: 64);
    final normalizedTargetId = _optionalText(
      targetId,
      'targetId',
      maximumLength: 64,
    );
    if ((targetType == null) != (normalizedTargetId == null)) {
      throw ArgumentError('targetType and targetId must be provided together');
    }
    if (status == CaptureDraftStatus.classified) {
      if (targetType == null || normalizedTargetId == null) {
        throw ArgumentError('A classified capture requires a target');
      }
      if (targetType != _targetFor(input.type)) {
        throw ArgumentError('Capture target does not match its type');
      }
    } else {
      if (targetType != null || normalizedTargetId != null) {
        throw ArgumentError('An open capture cannot have a target');
      }
      if (status != input.status) {
        throw ArgumentError('Open capture status must match missing context');
      }
    }
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return CaptureDraft._(
      id: normalizedId,
      input: input,
      status: status,
      targetType: targetType,
      targetId: normalizedTargetId,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const CaptureDraft._({
    required this.id,
    required this.input,
    required this.status,
    required this.targetType,
    required this.targetId,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final CaptureDraftInput input;
  final CaptureDraftStatus status;
  final CaptureTargetType? targetType;
  final String? targetId;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get projectId => input.projectId;
  CaptureDraftType get type => input.type;
  String? get title => input.title;
  String? get content => input.content;
  UnmodifiableListView<String> get attachmentIds => input.attachmentIds;
  Set<CaptureMissingContext> get missingContext => input.missingContext;
  bool get isOpen => status != CaptureDraftStatus.classified;
  bool get canClassify => status == CaptureDraftStatus.ready;
}

CaptureTargetType captureTargetFor(CaptureDraftType type) => _targetFor(type);

CaptureTargetType _targetFor(CaptureDraftType type) => switch (type) {
  CaptureDraftType.photo ||
  CaptureDraftType.document ||
  CaptureDraftType.voice => CaptureTargetType.document,
  CaptureDraftType.cost => CaptureTargetType.costDraft,
  CaptureDraftType.task => CaptureTargetType.scheduleTask,
  CaptureDraftType.note => CaptureTargetType.note,
  CaptureDraftType.decision => CaptureTargetType.decision,
  CaptureDraftType.defect => CaptureTargetType.defect,
};

UnmodifiableListView<String> _normalizedIds(Iterable<String> source) {
  final values = <String>[];
  final seen = <String>{};
  for (final raw in source) {
    final value = _requiredText(raw, 'attachmentIds', maximumLength: 64);
    if (seen.add(value)) values.add(value);
  }
  if (values.length > 20) {
    throw ArgumentError.value(source, 'attachmentIds', 'must not exceed 20');
  }
  return UnmodifiableListView<String>(values);
}

String _requiredText(String value, String name, {required int maximumLength}) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}

String? _optionalText(
  String? value,
  String name, {
  required int maximumLength,
}) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return _requiredText(normalized, name, maximumLength: maximumLength);
}
