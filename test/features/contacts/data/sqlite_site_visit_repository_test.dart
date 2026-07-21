import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/contacts/data/sqlite_contact_repository.dart';
import 'package:budowapro/features/contacts/data/sqlite_site_visit_repository.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/sqlite_schedule_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteContactRepository contacts;
  late SqliteSiteVisitRepository visits;
  late String contactId;
  var nextId = 0;
  var nextMinute = 0;

  DateTime utcNow() => DateTime.utc(2026, 7, 21, 10, nextMinute++);
  String idGenerator() => 'generated-${++nextId}';

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_site_visit_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    await SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: utcNow,
    ).create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    contacts = SqliteContactRepository(
      database: database,
      idGenerator: idGenerator,
      utcNow: utcNow,
    );
    contactId = (await contacts.create(
      projectId: 'project-1',
      draft: ContactDraft(
        displayName: 'Elektryk',
        kind: ContactKind.person,
        roles: const <ContactRole>{ContactRole.electrician},
      ),
    )).id;
    visits = SqliteSiteVisitRepository(
      database: database,
      idGenerator: idGenerator,
      utcNow: utcNow,
    );
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('persists visit and its schedule event in one project', () async {
    final created = await visits.create(
      projectId: 'project-1',
      draft: _draft(contactId: contactId),
    );
    final loaded = await visits.findById(
      projectId: 'project-1',
      visitId: created.id,
    );
    final scheduleEvent = await SqliteScheduleRepository(
      database: database,
      idGenerator: idGenerator,
      utcNow: utcNow,
    ).findById(projectId: 'project-1', eventId: created.id);

    expect(loaded?.expectedResult, 'Zatwierdzona trasa przewodow');
    expect(scheduleEvent?.title, 'Ustalenie instalacji');
    expect(scheduleEvent?.kind.name, 'visit');
    expect(scheduleEvent?.startsAtUtc, created.startsAtUtc);
  });

  test('keeps completed, cancelled and no-show visits in history', () async {
    for (final status in <SiteVisitStatus>[
      SiteVisitStatus.completed,
      SiteVisitStatus.cancelled,
      SiteVisitStatus.noShow,
    ]) {
      await visits.create(
        projectId: 'project-1',
        draft: _draft(
          contactId: contactId,
          status: status,
          result: status == SiteVisitStatus.completed ? 'Odebrane' : null,
        ),
      );
    }

    final history = await visits.listForContact(
      projectId: 'project-1',
      contactId: contactId,
    );

    expect(history, hasLength(3));
    expect(history.map((visit) => visit.status).toSet(), {
      SiteVisitStatus.completed,
      SiteVisitStatus.cancelled,
      SiteVisitStatus.noShow,
    });
  });

  test('updates result and appends schedule date history', () async {
    final created = await visits.create(
      projectId: 'project-1',
      draft: _draft(contactId: contactId),
    );
    final moved = _draft(
      contactId: contactId,
      status: SiteVisitStatus.completed,
      result: 'Trasy zatwierdzone',
      agreements: 'Rozdzielnia w pomieszczeniu technicznym',
      startsAt: DateTime.parse('2026-07-25T10:00:00+02:00'),
    );

    final updated = await visits.update(
      projectId: 'project-1',
      visitId: created.id,
      draft: moved,
      rescheduleReason: 'Wykonawca zmienil termin',
    );
    final changes = await SqliteScheduleRepository(
      database: database,
      idGenerator: idGenerator,
      utcNow: utcNow,
    ).listDateChanges(projectId: 'project-1', eventId: created.id);

    expect(updated.status, SiteVisitStatus.completed);
    expect(updated.result, 'Trasy zatwierdzone');
    expect(changes.single.reason, 'Wykonawca zmienil termin');
  });

  test('prevents deleting a contact referenced by visit history', () async {
    await visits.create(
      projectId: 'project-1',
      draft: _draft(contactId: contactId),
    );

    await expectLater(
      contacts.delete(projectId: 'project-1', contactId: contactId),
      throwsA(isA<ContactInUseException>()),
    );
  });
}

SiteVisitDraft _draft({
  required String contactId,
  SiteVisitStatus status = SiteVisitStatus.planned,
  String? result,
  String? agreements,
  DateTime? startsAt,
}) {
  return SiteVisitDraft(
    contactId: contactId,
    purpose: 'Ustalenie instalacji',
    expectedResult: 'Zatwierdzona trasa przewodow',
    status: status,
    startsAt: startsAt ?? DateTime.parse('2026-07-24T09:00:00+02:00'),
    timeZoneId: 'Europe/Warsaw',
    isAllDay: false,
    reminderEnabled: true,
    reminderLeadMinutes: 60,
    result: result,
    agreements: agreements,
  );
}
