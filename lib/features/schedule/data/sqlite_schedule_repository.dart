import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteScheduleRepository implements ScheduleRepository {
  const SqliteScheduleRepository({
    required AppDatabase database,
    required String Function() idGenerator,
    required DateTime Function() utcNow,
  }) : this._(database, idGenerator, utcNow);

  const SqliteScheduleRepository._(
    this._database,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final String Function() _idGenerator;
  final DateTime Function() _utcNow;

  @override
  Future<ScheduleEvent> create({
    required String projectId,
    required ScheduleEventInput input,
  }) {
    return _database.transaction<ScheduleEvent>((transaction) async {
      final now = _utcNow().toUtc();
      final event = ScheduleEvent(
        id: _idGenerator(),
        projectId: projectId,
        title: input.title,
        kind: input.kind,
        status: input.status,
        startsAt: input.startsAtUtc,
        endsAt: input.endsAtUtc,
        timeZoneId: input.timeZoneId,
        isAllDay: input.isAllDay,
        stageId: input.stageId,
        assignee: input.assignee,
        note: input.note,
        reminderEnabled: input.reminderEnabled,
        reminderLeadMinutes: input.reminderLeadMinutes,
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        AppDatabase.scheduleEventsTable,
        _eventToRow(event),
      );
      return event;
    });
  }

  @override
  Future<ScheduleEvent> update({
    required String projectId,
    required String eventId,
    required ScheduleEventInput input,
    String? rescheduleReason,
  }) {
    return _database.transaction<ScheduleEvent>((transaction) async {
      final existing = await _findById(transaction, projectId, eventId);
      if (existing == null) throw const ScheduleEventNotFoundException();
      final now = _utcNow().toUtc();
      final updated = ScheduleEvent(
        id: existing.id,
        projectId: existing.projectId,
        title: input.title,
        kind: input.kind,
        status: input.status,
        startsAt: input.startsAtUtc,
        endsAt: input.endsAtUtc,
        timeZoneId: input.timeZoneId,
        isAllDay: input.isAllDay,
        stageId: input.stageId,
        assignee: input.assignee,
        note: input.note,
        reminderEnabled: input.reminderEnabled,
        reminderLeadMinutes: input.reminderLeadMinutes,
        createdAt: existing.createdAtUtc,
        updatedAt: now,
      );
      if (_dateChanged(existing, updated)) {
        await transaction.insert(
          AppDatabase.scheduleDateChangesTable,
          _dateChangeToRow(
            ScheduleDateChange(
              id: _idGenerator(),
              projectId: projectId,
              eventId: eventId,
              previousStartsAt: existing.startsAtUtc,
              newStartsAt: updated.startsAtUtc,
              previousEndsAt: existing.endsAtUtc,
              newEndsAt: updated.endsAtUtc,
              previousTimeZoneId: existing.timeZoneId,
              newTimeZoneId: updated.timeZoneId,
              reason: rescheduleReason,
              changedAt: now,
            ),
          ),
        );
      }
      await transaction.update(
        AppDatabase.scheduleEventsTable,
        _eventToRow(updated),
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, eventId],
      );
      return updated;
    });
  }

  @override
  Future<ScheduleEvent?> findById({
    required String projectId,
    required String eventId,
  }) async {
    return _findById(await _database.open(), projectId, eventId);
  }

  @override
  Future<List<ScheduleEvent>> list({
    required String projectId,
    required ScheduleWindow window,
  }) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.scheduleEventsTable,
      where:
          'project_id = ? AND starts_at_utc_ms < ? AND '
          '((ends_at_utc_ms IS NULL AND starts_at_utc_ms >= ?) OR '
          '(ends_at_utc_ms IS NOT NULL AND ends_at_utc_ms > ?))',
      whereArgs: <Object?>[
        projectId,
        _toStorage(window.endExclusiveUtc),
        _toStorage(window.startUtc),
        _toStorage(window.startUtc),
      ],
      orderBy: 'starts_at_utc_ms ASC, id ASC',
    );
    return rows.map(_eventFromRow).toList(growable: false);
  }

  @override
  Future<List<ScheduleEvent>> listOpen({required String projectId}) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.scheduleEventsTable,
      where: 'project_id = ? AND status NOT IN (?, ?)',
      whereArgs: <Object?>[projectId, 'completed', 'cancelled'],
      orderBy: 'starts_at_utc_ms ASC, id ASC',
    );
    return rows.map(_eventFromRow).toList(growable: false);
  }

  @override
  Future<void> replaceDependencies({
    required String projectId,
    required String eventId,
    required Iterable<ScheduleDependencyInput> dependencies,
  }) {
    return _database.transaction<void>((transaction) async {
      if (await _findById(transaction, projectId, eventId) == null) {
        throw const ScheduleEventNotFoundException();
      }
      final now = _utcNow().toUtc();
      final normalized = <String, ScheduleDependency>{};
      for (final input in dependencies) {
        final dependency = ScheduleDependency(
          eventId: eventId,
          blockingEventId: input.blockingEventId,
          decisionDueAt: input.decisionDueAt,
          createdAt: now,
        );
        normalized[dependency.blockingEventId] = dependency;
      }
      for (final blockerId in normalized.keys) {
        if (await _findById(transaction, projectId, blockerId) == null) {
          throw const ScheduleEventNotFoundException();
        }
      }
      final rows = await transaction.query(
        AppDatabase.scheduleDependenciesTable,
        columns: const <String>['event_id', 'blocking_event_id'],
        where: 'project_id = ? AND event_id != ?',
        whereArgs: <Object?>[projectId, eventId],
      );
      final edges = <String, Set<String>>{};
      for (final row in rows) {
        (edges[row['event_id']! as String] ??= <String>{}).add(
          row['blocking_event_id']! as String,
        );
      }
      edges[eventId] = normalized.keys.toSet();
      if (_hasCycle(edges)) throw const ScheduleDependencyCycleException();

      await transaction.delete(
        AppDatabase.scheduleDependenciesTable,
        where: 'project_id = ? AND event_id = ?',
        whereArgs: <Object?>[projectId, eventId],
      );
      for (final dependency in normalized.values) {
        await transaction.insert(
          AppDatabase.scheduleDependenciesTable,
          _dependencyToRow(projectId, dependency),
        );
      }
    });
  }

  @override
  Future<List<ScheduleDependency>> listDependencies({
    required String projectId,
    required String eventId,
  }) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.scheduleDependenciesTable,
      where: 'project_id = ? AND event_id = ?',
      whereArgs: <Object?>[projectId, eventId],
      orderBy: 'created_at_utc_ms ASC, blocking_event_id ASC',
    );
    return rows.map(_dependencyFromRow).toList(growable: false);
  }

  @override
  Future<List<ScheduleDateChange>> listDateChanges({
    required String projectId,
    required String eventId,
  }) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.scheduleDateChangesTable,
      where: 'project_id = ? AND event_id = ?',
      whereArgs: <Object?>[projectId, eventId],
      orderBy: 'changed_at_utc_ms DESC, id DESC',
    );
    return rows.map(_dateChangeFromRow).toList(growable: false);
  }

  @override
  Future<ReminderPreferences> getReminderPreferences() async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.reminderPreferencesTable,
      where: 'id = ?',
      whereArgs: const <Object?>['app'],
      limit: 1,
    );
    return rows.isEmpty
        ? ReminderPreferences.defaults()
        : _preferencesFromRow(rows.single);
  }

  @override
  Future<void> saveReminderPreferences(ReminderPreferences preferences) async {
    final database = await _database.open();
    await database.insert(
      AppDatabase.reminderPreferencesTable,
      _preferencesToRow(preferences, _utcNow().toUtc()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Future<ScheduleEvent?> _findById(
  DatabaseExecutor executor,
  String projectId,
  String eventId,
) async {
  final rows = await executor.query(
    AppDatabase.scheduleEventsTable,
    where: 'project_id = ? AND id = ?',
    whereArgs: <Object?>[projectId, eventId],
    limit: 1,
  );
  return rows.isEmpty ? null : _eventFromRow(rows.single);
}

bool _dateChanged(ScheduleEvent before, ScheduleEvent after) {
  return before.startsAtUtc != after.startsAtUtc ||
      before.endsAtUtc != after.endsAtUtc ||
      before.timeZoneId != after.timeZoneId ||
      before.isAllDay != after.isAllDay;
}

bool _hasCycle(Map<String, Set<String>> edges) {
  final visiting = <String>{};
  final visited = <String>{};
  bool visit(String node) {
    if (visiting.contains(node)) return true;
    if (visited.contains(node)) return false;
    visiting.add(node);
    for (final next in edges[node] ?? const <String>{}) {
      if (visit(next)) return true;
    }
    visiting.remove(node);
    visited.add(node);
    return false;
  }

  return edges.keys.any(visit);
}

Map<String, Object?> _eventToRow(ScheduleEvent event) => <String, Object?>{
  'project_id': event.projectId,
  'id': event.id,
  'title': event.title,
  'kind': _kindToStorage(event.kind),
  'status': _statusToStorage(event.status),
  'starts_at_utc_ms': _toStorage(event.startsAtUtc),
  'ends_at_utc_ms': event.endsAtUtc == null
      ? null
      : _toStorage(event.endsAtUtc!),
  'time_zone_id': event.timeZoneId,
  'is_all_day': event.isAllDay ? 1 : 0,
  'stage_id': event.stageId,
  'assignee': event.assignee,
  'note': event.note,
  'reminder_enabled': event.reminderEnabled ? 1 : 0,
  'reminder_lead_minutes': event.reminderLeadMinutes,
  'created_at_utc_ms': _toStorage(event.createdAtUtc),
  'updated_at_utc_ms': _toStorage(event.updatedAtUtc),
};

ScheduleEvent _eventFromRow(Map<String, Object?> row) => ScheduleEvent(
  id: row['id']! as String,
  projectId: row['project_id']! as String,
  title: row['title']! as String,
  kind: _kindFromStorage(row['kind']! as String),
  status: _statusFromStorage(row['status']! as String),
  startsAt: _fromStorage(row['starts_at_utc_ms']! as int),
  endsAt: _nullableDate(row['ends_at_utc_ms']),
  timeZoneId: row['time_zone_id']! as String,
  isAllDay: row['is_all_day'] == 1,
  stageId: row['stage_id'] as String?,
  assignee: row['assignee'] as String?,
  note: row['note'] as String?,
  reminderEnabled: row['reminder_enabled'] == 1,
  reminderLeadMinutes: row['reminder_lead_minutes']! as int,
  createdAt: _fromStorage(row['created_at_utc_ms']! as int),
  updatedAt: _fromStorage(row['updated_at_utc_ms']! as int),
);

Map<String, Object?> _dependencyToRow(
  String projectId,
  ScheduleDependency dependency,
) => <String, Object?>{
  'project_id': projectId,
  'event_id': dependency.eventId,
  'blocking_event_id': dependency.blockingEventId,
  'decision_due_at_utc_ms': dependency.decisionDueAtUtc == null
      ? null
      : _toStorage(dependency.decisionDueAtUtc!),
  'created_at_utc_ms': _toStorage(dependency.createdAtUtc),
};

ScheduleDependency _dependencyFromRow(Map<String, Object?> row) =>
    ScheduleDependency(
      eventId: row['event_id']! as String,
      blockingEventId: row['blocking_event_id']! as String,
      decisionDueAt: _nullableDate(row['decision_due_at_utc_ms']),
      createdAt: _fromStorage(row['created_at_utc_ms']! as int),
    );

Map<String, Object?> _dateChangeToRow(ScheduleDateChange change) =>
    <String, Object?>{
      'id': change.id,
      'project_id': change.projectId,
      'event_id': change.eventId,
      'previous_starts_at_utc_ms': _toStorage(change.previousStartsAtUtc),
      'new_starts_at_utc_ms': _toStorage(change.newStartsAtUtc),
      'previous_ends_at_utc_ms': change.previousEndsAtUtc == null
          ? null
          : _toStorage(change.previousEndsAtUtc!),
      'new_ends_at_utc_ms': change.newEndsAtUtc == null
          ? null
          : _toStorage(change.newEndsAtUtc!),
      'previous_time_zone_id': change.previousTimeZoneId,
      'new_time_zone_id': change.newTimeZoneId,
      'reason': change.reason,
      'changed_at_utc_ms': _toStorage(change.changedAtUtc),
    };

ScheduleDateChange _dateChangeFromRow(Map<String, Object?> row) =>
    ScheduleDateChange(
      id: row['id']! as String,
      projectId: row['project_id']! as String,
      eventId: row['event_id']! as String,
      previousStartsAt: _fromStorage(row['previous_starts_at_utc_ms']! as int),
      newStartsAt: _fromStorage(row['new_starts_at_utc_ms']! as int),
      previousEndsAt: _nullableDate(row['previous_ends_at_utc_ms']),
      newEndsAt: _nullableDate(row['new_ends_at_utc_ms']),
      previousTimeZoneId: row['previous_time_zone_id']! as String,
      newTimeZoneId: row['new_time_zone_id']! as String,
      reason: row['reason'] as String?,
      changedAt: _fromStorage(row['changed_at_utc_ms']! as int),
    );

Map<String, Object?> _preferencesToRow(
  ReminderPreferences preferences,
  DateTime updatedAt,
) => <String, Object?>{
  'id': 'app',
  'task_enabled': preferences.isEnabledFor(ScheduleEventKind.task) ? 1 : 0,
  'visit_enabled': preferences.isEnabledFor(ScheduleEventKind.visit) ? 1 : 0,
  'delivery_enabled': preferences.isEnabledFor(ScheduleEventKind.delivery)
      ? 1
      : 0,
  'acceptance_enabled': preferences.isEnabledFor(ScheduleEventKind.acceptance)
      ? 1
      : 0,
  'payment_enabled': preferences.isEnabledFor(ScheduleEventKind.payment)
      ? 1
      : 0,
  'default_lead_minutes': preferences.defaultLeadMinutes,
  'all_day_reminder_minute': preferences.allDayReminderMinute,
  'updated_at_utc_ms': _toStorage(updatedAt),
};

ReminderPreferences _preferencesFromRow(Map<String, Object?> row) {
  final enabled = <ScheduleEventKind>{};
  if (row['task_enabled'] == 1) enabled.add(ScheduleEventKind.task);
  if (row['visit_enabled'] == 1) enabled.add(ScheduleEventKind.visit);
  if (row['delivery_enabled'] == 1) enabled.add(ScheduleEventKind.delivery);
  if (row['acceptance_enabled'] == 1) {
    enabled.add(ScheduleEventKind.acceptance);
  }
  if (row['payment_enabled'] == 1) enabled.add(ScheduleEventKind.payment);
  return ReminderPreferences(
    enabledKinds: enabled,
    defaultLeadMinutes: row['default_lead_minutes']! as int,
    allDayReminderMinute: row['all_day_reminder_minute']! as int,
  );
}

int _toStorage(DateTime value) =>
    DatabaseValueCodec.dateTimeToUtcMilliseconds(value);

DateTime _fromStorage(int value) =>
    DatabaseValueCodec.utcMillisecondsToDateTime(value);

DateTime? _nullableDate(Object? value) =>
    value == null ? null : _fromStorage(value as int);

String _kindToStorage(ScheduleEventKind kind) => kind.name;

ScheduleEventKind _kindFromStorage(String value) =>
    ScheduleEventKind.values.byName(value);

String _statusToStorage(ScheduleEventStatus status) => switch (status) {
  ScheduleEventStatus.inProgress => 'in_progress',
  _ => status.name,
};

ScheduleEventStatus _statusFromStorage(String value) => switch (value) {
  'in_progress' => ScheduleEventStatus.inProgress,
  _ => ScheduleEventStatus.values.byName(value),
};
