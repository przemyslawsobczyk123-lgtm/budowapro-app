enum ScheduleEventKind { task, visit, delivery, acceptance, payment }

enum ScheduleEventStatus { planned, inProgress, blocked, completed, cancelled }

final class ScheduleEvent {
  factory ScheduleEvent({
    required String id,
    required String projectId,
    required String title,
    required ScheduleEventKind kind,
    required ScheduleEventStatus status,
    required DateTime startsAt,
    required String timeZoneId,
    required bool isAllDay,
    required bool reminderEnabled,
    required int reminderLeadMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? endsAt,
    String? stageId,
    String? assignee,
    String? note,
  }) {
    final input = ScheduleEventInput(
      title: title,
      kind: kind,
      status: status,
      startsAt: startsAt,
      endsAt: endsAt,
      timeZoneId: timeZoneId,
      isAllDay: isAllDay,
      stageId: stageId,
      assignee: assignee,
      note: note,
      reminderEnabled: reminderEnabled,
      reminderLeadMinutes: reminderLeadMinutes,
    );
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return ScheduleEvent._(
      id: _requiredText(id, 'id', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      title: input.title,
      kind: kind,
      status: status,
      startsAtUtc: input.startsAtUtc,
      endsAtUtc: input.endsAtUtc,
      timeZoneId: input.timeZoneId,
      isAllDay: isAllDay,
      stageId: input.stageId,
      assignee: input.assignee,
      note: input.note,
      reminderEnabled: reminderEnabled,
      reminderLeadMinutes: reminderLeadMinutes,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const ScheduleEvent._({
    required this.id,
    required this.projectId,
    required this.title,
    required this.kind,
    required this.status,
    required this.startsAtUtc,
    required this.endsAtUtc,
    required this.timeZoneId,
    required this.isAllDay,
    required this.stageId,
    required this.assignee,
    required this.note,
    required this.reminderEnabled,
    required this.reminderLeadMinutes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String projectId;
  final String title;
  final ScheduleEventKind kind;
  final ScheduleEventStatus status;
  final DateTime startsAtUtc;
  final DateTime? endsAtUtc;
  final String timeZoneId;
  final bool isAllDay;
  final String? stageId;
  final String? assignee;
  final String? note;
  final bool reminderEnabled;
  final int reminderLeadMinutes;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  bool get isResolved =>
      status == ScheduleEventStatus.completed ||
      status == ScheduleEventStatus.cancelled;

  DateTime? get reminderAtUtc => reminderEnabled && !isAllDay
      ? startsAtUtc.subtract(Duration(minutes: reminderLeadMinutes))
      : null;
}

final class ScheduleEventInput {
  factory ScheduleEventInput({
    required String title,
    required ScheduleEventKind kind,
    required ScheduleEventStatus status,
    required DateTime startsAt,
    required String timeZoneId,
    required bool isAllDay,
    required bool reminderEnabled,
    required int reminderLeadMinutes,
    DateTime? endsAt,
    String? stageId,
    String? assignee,
    String? note,
  }) {
    final startsAtUtc = startsAt.toUtc();
    final endsAtUtc = endsAt?.toUtc();
    if (endsAtUtc != null && endsAtUtc.isBefore(startsAtUtc)) {
      throw ArgumentError.value(endsAt, 'endsAt');
    }
    if (reminderLeadMinutes < 0 || reminderLeadMinutes > 10080) {
      throw RangeError.range(reminderLeadMinutes, 0, 10080);
    }
    return ScheduleEventInput._(
      title: _requiredText(title, 'title', 160),
      kind: kind,
      status: status,
      startsAtUtc: startsAtUtc,
      endsAtUtc: endsAtUtc,
      timeZoneId: _requiredText(timeZoneId, 'timeZoneId', 64),
      isAllDay: isAllDay,
      stageId: _optionalText(stageId, 'stageId', 64),
      assignee: _optionalText(assignee, 'assignee', 120),
      note: _optionalText(note, 'note', 2000),
      reminderEnabled: reminderEnabled,
      reminderLeadMinutes: reminderLeadMinutes,
    );
  }

  const ScheduleEventInput._({
    required this.title,
    required this.kind,
    required this.status,
    required this.startsAtUtc,
    required this.endsAtUtc,
    required this.timeZoneId,
    required this.isAllDay,
    required this.stageId,
    required this.assignee,
    required this.note,
    required this.reminderEnabled,
    required this.reminderLeadMinutes,
  });

  final String title;
  final ScheduleEventKind kind;
  final ScheduleEventStatus status;
  final DateTime startsAtUtc;
  final DateTime? endsAtUtc;
  final String timeZoneId;
  final bool isAllDay;
  final String? stageId;
  final String? assignee;
  final String? note;
  final bool reminderEnabled;
  final int reminderLeadMinutes;
}

final class ScheduleWindow {
  factory ScheduleWindow({
    required DateTime start,
    required DateTime endExclusive,
  }) {
    final startUtc = start.toUtc();
    final endUtc = endExclusive.toUtc();
    if (!endUtc.isAfter(startUtc)) {
      throw ArgumentError.value(endExclusive, 'endExclusive');
    }
    return ScheduleWindow._(startUtc, endUtc);
  }

  factory ScheduleWindow.sevenDaysFrom(DateTime day) {
    final utc = day.toUtc();
    final start = DateTime.utc(utc.year, utc.month, utc.day);
    return ScheduleWindow(
      start: start,
      endExclusive: start.add(const Duration(days: 7)),
    );
  }

  const ScheduleWindow._(this.startUtc, this.endExclusiveUtc);

  final DateTime startUtc;
  final DateTime endExclusiveUtc;

  bool contains(DateTime instant) {
    final value = instant.toUtc();
    return !value.isBefore(startUtc) && value.isBefore(endExclusiveUtc);
  }
}

final class ScheduleDependency {
  factory ScheduleDependency({
    required String eventId,
    required String blockingEventId,
    required DateTime createdAt,
    DateTime? decisionDueAt,
  }) {
    final normalizedEventId = _requiredText(eventId, 'eventId', 64);
    final normalizedBlockingId = _requiredText(
      blockingEventId,
      'blockingEventId',
      64,
    );
    if (normalizedEventId == normalizedBlockingId) {
      throw ArgumentError('an event cannot block itself');
    }
    return ScheduleDependency._(
      eventId: normalizedEventId,
      blockingEventId: normalizedBlockingId,
      decisionDueAtUtc: decisionDueAt?.toUtc(),
      createdAtUtc: createdAt.toUtc(),
    );
  }

  const ScheduleDependency._({
    required this.eventId,
    required this.blockingEventId,
    required this.decisionDueAtUtc,
    required this.createdAtUtc,
  });

  final String eventId;
  final String blockingEventId;
  final DateTime? decisionDueAtUtc;
  final DateTime createdAtUtc;
}

final class ScheduleDateChange {
  factory ScheduleDateChange({
    required String id,
    required String projectId,
    required String eventId,
    required DateTime previousStartsAt,
    required DateTime newStartsAt,
    required String previousTimeZoneId,
    required String newTimeZoneId,
    required DateTime changedAt,
    DateTime? previousEndsAt,
    DateTime? newEndsAt,
    String? reason,
  }) {
    return ScheduleDateChange._(
      id: _requiredText(id, 'id', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      eventId: _requiredText(eventId, 'eventId', 64),
      previousStartsAtUtc: previousStartsAt.toUtc(),
      newStartsAtUtc: newStartsAt.toUtc(),
      previousEndsAtUtc: previousEndsAt?.toUtc(),
      newEndsAtUtc: newEndsAt?.toUtc(),
      previousTimeZoneId: _requiredText(
        previousTimeZoneId,
        'previousTimeZoneId',
        64,
      ),
      newTimeZoneId: _requiredText(newTimeZoneId, 'newTimeZoneId', 64),
      reason: _optionalText(reason, 'reason', 500),
      changedAtUtc: changedAt.toUtc(),
    );
  }

  const ScheduleDateChange._({
    required this.id,
    required this.projectId,
    required this.eventId,
    required this.previousStartsAtUtc,
    required this.newStartsAtUtc,
    required this.previousEndsAtUtc,
    required this.newEndsAtUtc,
    required this.previousTimeZoneId,
    required this.newTimeZoneId,
    required this.reason,
    required this.changedAtUtc,
  });

  final String id;
  final String projectId;
  final String eventId;
  final DateTime previousStartsAtUtc;
  final DateTime newStartsAtUtc;
  final DateTime? previousEndsAtUtc;
  final DateTime? newEndsAtUtc;
  final String previousTimeZoneId;
  final String newTimeZoneId;
  final String? reason;
  final DateTime changedAtUtc;
}

final class ReminderPreferences {
  factory ReminderPreferences({
    required Iterable<ScheduleEventKind> enabledKinds,
    required int defaultLeadMinutes,
    required int allDayReminderMinute,
  }) {
    if (defaultLeadMinutes < 0 || defaultLeadMinutes > 10080) {
      throw RangeError.range(defaultLeadMinutes, 0, 10080);
    }
    if (allDayReminderMinute < 0 || allDayReminderMinute > 1439) {
      throw RangeError.range(allDayReminderMinute, 0, 1439);
    }
    return ReminderPreferences._(
      Set<ScheduleEventKind>.unmodifiable(enabledKinds),
      defaultLeadMinutes,
      allDayReminderMinute,
    );
  }

  factory ReminderPreferences.defaults() => ReminderPreferences(
    enabledKinds: ScheduleEventKind.values,
    defaultLeadMinutes: 60,
    allDayReminderMinute: 8 * 60,
  );

  const ReminderPreferences._(
    this.enabledKinds,
    this.defaultLeadMinutes,
    this.allDayReminderMinute,
  );

  final Set<ScheduleEventKind> enabledKinds;
  final int defaultLeadMinutes;
  final int allDayReminderMinute;

  bool isEnabledFor(ScheduleEventKind kind) => enabledKinds.contains(kind);

  ReminderPreferences copyWith({
    Iterable<ScheduleEventKind>? enabledKinds,
    int? defaultLeadMinutes,
    int? allDayReminderMinute,
  }) {
    return ReminderPreferences(
      enabledKinds: enabledKinds ?? this.enabledKinds,
      defaultLeadMinutes: defaultLeadMinutes ?? this.defaultLeadMinutes,
      allDayReminderMinute: allDayReminderMinute ?? this.allDayReminderMinute,
    );
  }
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
  if (normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}
