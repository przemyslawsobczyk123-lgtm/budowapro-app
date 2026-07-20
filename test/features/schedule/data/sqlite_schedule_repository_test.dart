import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/features/schedule/data/sqlite_schedule_repository.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory directory;
  late AppDatabase database;
  late SqliteScheduleRepository repository;
  var id = 0;
  var now = DateTime.utc(2026, 7, 20, 10);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('schedule_repository_');
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(directory.path, 'test.db'),
    );
    await _insertProject(await database.open(), 'project-1');
    await _insertProject(await database.open(), 'project-2');
    repository = SqliteScheduleRepository(
      database: database,
      idGenerator: () => 'generated-${++id}',
      utcNow: () => now,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test(
    'creates and lists intersecting events in deterministic order',
    () async {
      final first = await repository.create(
        projectId: 'project-1',
        input: _input('Odbior', DateTime.utc(2026, 7, 21, 8)),
      );
      await repository.create(
        projectId: 'project-1',
        input: _input('Poza planem', DateTime.utc(2026, 8, 1, 8)),
      );
      await repository.create(
        projectId: 'project-2',
        input: _input('Inny projekt', DateTime.utc(2026, 7, 21, 7)),
      );

      final events = await repository.list(
        projectId: 'project-1',
        window: ScheduleWindow(
          start: DateTime.utc(2026, 7, 20),
          endExclusive: DateTime.utc(2026, 7, 27),
        ),
      );

      expect(events.map((event) => event.id), <String>[first.id]);
    },
  );

  test('date update appends history but title update does not', () async {
    final event = await repository.create(
      projectId: 'project-1',
      input: _input('Wizyta', DateTime.utc(2026, 7, 21, 8)),
    );
    now = now.add(const Duration(hours: 1));
    await repository.update(
      projectId: 'project-1',
      eventId: event.id,
      input: _input('Wizyta hydraulika', DateTime.utc(2026, 7, 21, 8)),
    );
    now = now.add(const Duration(hours: 1));
    await repository.update(
      projectId: 'project-1',
      eventId: event.id,
      input: _input('Wizyta hydraulika', DateTime.utc(2026, 7, 22, 9)),
      rescheduleReason: 'Zmiana terminu ekipy',
    );

    final history = await repository.listDateChanges(
      projectId: 'project-1',
      eventId: event.id,
    );
    expect(history, hasLength(1));
    expect(history.single.previousStartsAtUtc, DateTime.utc(2026, 7, 21, 8));
    expect(history.single.newStartsAtUtc, DateTime.utc(2026, 7, 22, 9));
    expect(history.single.reason, 'Zmiana terminu ekipy');
  });

  test('replaces dependencies atomically and rejects a cycle', () async {
    final first = await repository.create(
      projectId: 'project-1',
      input: _input('Decyzja', DateTime.utc(2026, 7, 20, 8)),
    );
    final second = await repository.create(
      projectId: 'project-1',
      input: _input('Zamowienie', DateTime.utc(2026, 7, 21, 8)),
    );
    await repository.replaceDependencies(
      projectId: 'project-1',
      eventId: second.id,
      dependencies: <ScheduleDependencyInput>[
        ScheduleDependencyInput(
          blockingEventId: first.id,
          decisionDueAt: DateTime.utc(2026, 7, 20, 12),
        ),
      ],
    );

    await expectLater(
      repository.replaceDependencies(
        projectId: 'project-1',
        eventId: first.id,
        dependencies: <ScheduleDependencyInput>[
          ScheduleDependencyInput(blockingEventId: second.id),
        ],
      ),
      throwsA(isA<ScheduleDependencyCycleException>()),
    );
    expect(
      await repository.listDependencies(
        projectId: 'project-1',
        eventId: second.id,
      ),
      hasLength(1),
    );
  });

  test('round trips reminder preferences', () async {
    expect(
      (await repository.getReminderPreferences()).enabledKinds,
      ScheduleEventKind.values.toSet(),
    );
    final preferences = ReminderPreferences(
      enabledKinds: const <ScheduleEventKind>{
        ScheduleEventKind.task,
        ScheduleEventKind.visit,
      },
      defaultLeadMinutes: 180,
      allDayReminderMinute: 390,
    );

    await repository.saveReminderPreferences(preferences);

    final stored = await repository.getReminderPreferences();
    expect(stored.enabledKinds, preferences.enabledKinds);
    expect(stored.defaultLeadMinutes, 180);
    expect(stored.allDayReminderMinute, 390);
  });
}

ScheduleEventInput _input(String title, DateTime startsAt) {
  return ScheduleEventInput(
    title: title,
    kind: ScheduleEventKind.task,
    status: ScheduleEventStatus.planned,
    startsAt: startsAt,
    timeZoneId: 'Europe/Warsaw',
    isAllDay: false,
    reminderEnabled: false,
    reminderLeadMinutes: 60,
  );
}

Future<void> _insertProject(Database database, String id) {
  return database.insert(AppDatabase.projectsTable, <String, Object?>{
    'id': id,
    'name': id,
    'project_type': 'house_build',
    'template_key': 'build_house',
    'template_version': 1,
    'currency_code': 'PLN',
    'date_format': 'day_month_year',
    'current_stage_key': 'planning',
    'is_archived': 0,
    'deletion_pending': 0,
    'created_at_utc_ms': 0,
    'updated_at_utc_ms': 0,
  });
}
