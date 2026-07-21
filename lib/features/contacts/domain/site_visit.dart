import 'package:budowapro/features/schedule/domain/schedule_event.dart';

enum SiteVisitStatus { planned, completed, cancelled, noShow }

final class SiteVisitDraft {
  factory SiteVisitDraft({
    required String contactId,
    required String purpose,
    required String expectedResult,
    required SiteVisitStatus status,
    required DateTime startsAt,
    required String timeZoneId,
    required bool isAllDay,
    required bool reminderEnabled,
    required int reminderLeadMinutes,
    DateTime? endsAt,
    String? stageId,
    String? result,
    String? agreements,
  }) {
    final startsAtUtc = startsAt.toUtc();
    final endsAtUtc = endsAt?.toUtc();
    if (endsAtUtc != null && endsAtUtc.isBefore(startsAtUtc)) {
      throw ArgumentError.value(endsAt, 'endsAt');
    }
    if (reminderLeadMinutes < 0 || reminderLeadMinutes > 10080) {
      throw RangeError.range(reminderLeadMinutes, 0, 10080);
    }
    final normalizedResult = _optionalText(result, 'result', 4000);
    if (status == SiteVisitStatus.completed && normalizedResult == null) {
      throw ArgumentError.value(result, 'result', 'required when completed');
    }
    return SiteVisitDraft._(
      contactId: _requiredText(contactId, 'contactId', 64),
      purpose: _requiredText(purpose, 'purpose', 160),
      expectedResult: _requiredText(expectedResult, 'expectedResult', 2000),
      status: status,
      startsAtUtc: startsAtUtc,
      endsAtUtc: endsAtUtc,
      timeZoneId: _requiredText(timeZoneId, 'timeZoneId', 64),
      isAllDay: isAllDay,
      stageId: _optionalText(stageId, 'stageId', 64),
      reminderEnabled: reminderEnabled,
      reminderLeadMinutes: reminderLeadMinutes,
      result: normalizedResult,
      agreements: _optionalText(agreements, 'agreements', 4000),
    );
  }

  const SiteVisitDraft._({
    required this.contactId,
    required this.purpose,
    required this.expectedResult,
    required this.status,
    required this.startsAtUtc,
    required this.endsAtUtc,
    required this.timeZoneId,
    required this.isAllDay,
    required this.stageId,
    required this.reminderEnabled,
    required this.reminderLeadMinutes,
    required this.result,
    required this.agreements,
  });

  final String contactId;
  final String purpose;
  final String expectedResult;
  final SiteVisitStatus status;
  final DateTime startsAtUtc;
  final DateTime? endsAtUtc;
  final String timeZoneId;
  final bool isAllDay;
  final String? stageId;
  final bool reminderEnabled;
  final int reminderLeadMinutes;
  final String? result;
  final String? agreements;
}

final class SiteVisit {
  factory SiteVisit({
    required String id,
    required String projectId,
    required SiteVisitDraft draft,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return SiteVisit._(
      id: _requiredText(id, 'id', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      draft: draft,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const SiteVisit._({
    required this.id,
    required this.projectId,
    required this.draft,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String projectId;
  final SiteVisitDraft draft;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get contactId => draft.contactId;
  String get purpose => draft.purpose;
  String get expectedResult => draft.expectedResult;
  SiteVisitStatus get status => draft.status;
  DateTime get startsAtUtc => draft.startsAtUtc;
  DateTime? get endsAtUtc => draft.endsAtUtc;
  String get timeZoneId => draft.timeZoneId;
  bool get isAllDay => draft.isAllDay;
  String? get stageId => draft.stageId;
  bool get reminderEnabled => draft.reminderEnabled;
  int get reminderLeadMinutes => draft.reminderLeadMinutes;
  String? get result => draft.result;
  String? get agreements => draft.agreements;

  bool get isResolved => status != SiteVisitStatus.planned;

  ScheduleEvent get scheduleEvent => ScheduleEvent(
    id: id,
    projectId: projectId,
    title: purpose,
    kind: ScheduleEventKind.visit,
    status: switch (status) {
      SiteVisitStatus.planned => ScheduleEventStatus.planned,
      SiteVisitStatus.completed => ScheduleEventStatus.completed,
      SiteVisitStatus.cancelled ||
      SiteVisitStatus.noShow => ScheduleEventStatus.cancelled,
    },
    startsAt: startsAtUtc,
    endsAt: endsAtUtc,
    timeZoneId: timeZoneId,
    isAllDay: isAllDay,
    stageId: stageId,
    reminderEnabled: reminderEnabled,
    reminderLeadMinutes: reminderLeadMinutes,
    createdAt: createdAtUtc,
    updatedAt: updatedAtUtc,
  );
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
