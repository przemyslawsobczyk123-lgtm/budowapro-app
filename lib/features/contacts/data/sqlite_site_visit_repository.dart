import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/contacts/domain/site_visit_repository.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteSiteVisitRepository implements SiteVisitRepository {
  factory SqliteSiteVisitRepository({
    required AppDatabase database,
    required String Function() idGenerator,
    required DateTime Function() utcNow,
  }) => SqliteSiteVisitRepository._(database, idGenerator, utcNow);

  const SqliteSiteVisitRepository._(
    this._database,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final String Function() _idGenerator;
  final DateTime Function() _utcNow;

  @override
  Future<SiteVisit> create({
    required String projectId,
    required SiteVisitDraft draft,
  }) {
    return _database.transaction<SiteVisit>((transaction) async {
      final now = _utcNow().toUtc();
      final visit = SiteVisit(
        id: _idGenerator(),
        projectId: projectId,
        draft: draft,
        createdAt: now,
        updatedAt: now,
      );
      final contactName = await _contactName(
        transaction,
        projectId,
        draft.contactId,
      );
      await transaction.insert(
        AppDatabase.scheduleEventsTable,
        _scheduleRow(visit, contactName),
      );
      await transaction.insert(
        AppDatabase.siteVisitsTable,
        _visitDetailsRow(visit),
      );
      return visit;
    });
  }

  @override
  Future<SiteVisit> update({
    required String projectId,
    required String visitId,
    required SiteVisitDraft draft,
    String? rescheduleReason,
  }) {
    return _database.transaction<SiteVisit>((transaction) async {
      final existing = await _findById(transaction, projectId, visitId);
      if (existing == null) throw const SiteVisitNotFoundException();
      final updated = SiteVisit(
        id: existing.id,
        projectId: existing.projectId,
        draft: draft,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
      );
      if (_dateChanged(existing, updated)) {
        await transaction
            .insert(AppDatabase.scheduleDateChangesTable, <String, Object?>{
              'id': _idGenerator(),
              'project_id': projectId,
              'event_id': visitId,
              'previous_starts_at_utc_ms': _toStorage(existing.startsAtUtc),
              'new_starts_at_utc_ms': _toStorage(updated.startsAtUtc),
              'previous_ends_at_utc_ms': existing.endsAtUtc == null
                  ? null
                  : _toStorage(existing.endsAtUtc!),
              'new_ends_at_utc_ms': updated.endsAtUtc == null
                  ? null
                  : _toStorage(updated.endsAtUtc!),
              'previous_time_zone_id': existing.timeZoneId,
              'new_time_zone_id': updated.timeZoneId,
              'reason': _optionalText(rescheduleReason, 500),
              'changed_at_utc_ms': _toStorage(updated.updatedAtUtc),
            });
      }
      final contactName = await _contactName(
        transaction,
        projectId,
        draft.contactId,
      );
      await transaction.update(
        AppDatabase.scheduleEventsTable,
        _scheduleRow(updated, contactName),
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, visitId],
      );
      await transaction.update(
        AppDatabase.siteVisitsTable,
        _visitDetailsRow(updated),
        where: 'project_id = ? AND event_id = ?',
        whereArgs: <Object?>[projectId, visitId],
      );
      return updated;
    });
  }

  @override
  Future<SiteVisit?> findById({
    required String projectId,
    required String visitId,
  }) async {
    return _findById(await _database.open(), projectId, visitId);
  }

  @override
  Future<List<SiteVisit>> listForContact({
    required String projectId,
    required String contactId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '$_visitSelect WHERE v.project_id = ? AND v.contact_id = ? '
      'ORDER BY e.starts_at_utc_ms DESC, e.id DESC',
      <Object?>[projectId, contactId],
    );
    return rows.map(_visitFromJoinedRow).toList(growable: false);
  }
}

Future<SiteVisit?> _findById(
  DatabaseExecutor executor,
  String projectId,
  String visitId,
) async {
  final rows = await executor.rawQuery(
    '$_visitSelect WHERE v.project_id = ? AND v.event_id = ? LIMIT 1',
    <Object?>[projectId, visitId],
  );
  return rows.isEmpty ? null : _visitFromJoinedRow(rows.single);
}

Future<String> _contactName(
  DatabaseExecutor executor,
  String projectId,
  String contactId,
) async {
  final rows = await executor.query(
    AppDatabase.contactsTable,
    columns: const <String>['display_name'],
    where: 'project_id = ? AND id = ?',
    whereArgs: <Object?>[projectId, contactId],
    limit: 1,
  );
  if (rows.isEmpty) throw const SiteVisitNotFoundException();
  return rows.single['display_name']! as String;
}

Map<String, Object?> _scheduleRow(SiteVisit visit, String contactName) {
  final event = visit.scheduleEvent;
  return <String, Object?>{
    'project_id': event.projectId,
    'id': event.id,
    'title': event.title,
    'kind': 'visit',
    'status': switch (event.status) {
      ScheduleEventStatus.planned => 'planned',
      ScheduleEventStatus.completed => 'completed',
      ScheduleEventStatus.cancelled => 'cancelled',
      ScheduleEventStatus.inProgress => 'in_progress',
      ScheduleEventStatus.blocked => 'blocked',
    },
    'starts_at_utc_ms': _toStorage(event.startsAtUtc),
    'ends_at_utc_ms': event.endsAtUtc == null
        ? null
        : _toStorage(event.endsAtUtc!),
    'time_zone_id': event.timeZoneId,
    'is_all_day': event.isAllDay ? 1 : 0,
    'stage_id': event.stageId,
    'assignee': contactName,
    'note': visit.expectedResult,
    'reminder_enabled': event.reminderEnabled ? 1 : 0,
    'reminder_lead_minutes': event.reminderLeadMinutes,
    'created_at_utc_ms': _toStorage(event.createdAtUtc),
    'updated_at_utc_ms': _toStorage(event.updatedAtUtc),
  };
}

Map<String, Object?> _visitDetailsRow(SiteVisit visit) => <String, Object?>{
  'project_id': visit.projectId,
  'event_id': visit.id,
  'contact_id': visit.contactId,
  'expected_result': visit.expectedResult,
  'status': _statusToStorage(visit.status),
  'result': visit.result,
  'agreements': visit.agreements,
  'created_at_utc_ms': _toStorage(visit.createdAtUtc),
  'updated_at_utc_ms': _toStorage(visit.updatedAtUtc),
};

SiteVisit _visitFromJoinedRow(Map<String, Object?> row) => SiteVisit(
  id: row['event_id']! as String,
  projectId: row['project_id']! as String,
  draft: SiteVisitDraft(
    contactId: row['contact_id']! as String,
    purpose: row['purpose']! as String,
    expectedResult: row['expected_result']! as String,
    status: _statusFromStorage(row['visit_status']! as String),
    startsAt: _fromStorage(row['starts_at_utc_ms']! as int),
    endsAt: _nullableDate(row['ends_at_utc_ms']),
    timeZoneId: row['time_zone_id']! as String,
    isAllDay: row['is_all_day'] == 1,
    stageId: row['stage_id'] as String?,
    reminderEnabled: row['reminder_enabled'] == 1,
    reminderLeadMinutes: row['reminder_lead_minutes']! as int,
    result: row['result'] as String?,
    agreements: row['agreements'] as String?,
  ),
  createdAt: _fromStorage(row['visit_created_at_utc_ms']! as int),
  updatedAt: _fromStorage(row['visit_updated_at_utc_ms']! as int),
);

bool _dateChanged(SiteVisit before, SiteVisit after) =>
    before.startsAtUtc != after.startsAtUtc ||
    before.endsAtUtc != after.endsAtUtc ||
    before.timeZoneId != after.timeZoneId ||
    before.isAllDay != after.isAllDay;

String _statusToStorage(SiteVisitStatus value) => switch (value) {
  SiteVisitStatus.noShow => 'no_show',
  _ => value.name,
};

SiteVisitStatus _statusFromStorage(String value) => switch (value) {
  'no_show' => SiteVisitStatus.noShow,
  _ => SiteVisitStatus.values.byName(value),
};

String? _optionalText(String? value, int maximumLength) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized.length > maximumLength) {
    throw ArgumentError.value(value, 'rescheduleReason');
  }
  return normalized;
}

int _toStorage(DateTime value) =>
    DatabaseValueCodec.dateTimeToUtcMilliseconds(value);

DateTime _fromStorage(int value) =>
    DatabaseValueCodec.utcMillisecondsToDateTime(value);

DateTime? _nullableDate(Object? value) =>
    value == null ? null : _fromStorage(value as int);

const _visitSelect =
    '''
  SELECT
    v.project_id,
    v.event_id,
    v.contact_id,
    v.expected_result,
    v.status AS visit_status,
    v.result,
    v.agreements,
    v.created_at_utc_ms AS visit_created_at_utc_ms,
    v.updated_at_utc_ms AS visit_updated_at_utc_ms,
    e.title AS purpose,
    e.starts_at_utc_ms,
    e.ends_at_utc_ms,
    e.time_zone_id,
    e.is_all_day,
    e.stage_id,
    e.reminder_enabled,
    e.reminder_lead_minutes
  FROM ${AppDatabase.siteVisitsTable} v
  INNER JOIN ${AppDatabase.scheduleEventsTable} e
    ON e.project_id = v.project_id AND e.id = v.event_id
''';
