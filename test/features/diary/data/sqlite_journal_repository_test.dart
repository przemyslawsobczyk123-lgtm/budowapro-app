import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/captures/data/sqlite_capture_repository.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/contacts/data/sqlite_contact_repository.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/diary/data/sqlite_journal_repository.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/diary/domain/journal_repository.dart';
import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/sqlite_schedule_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteJournalRepository journal;
  late String approverId;
  final now = DateTime.utc(2026, 7, 30, 12);
  var journalId = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_journal_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    var projectId = 0;
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-${++projectId}',
      utcNow: () => now,
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    journal = SqliteJournalRepository(
      database: database,
      idGenerator: () => 'journal-${++journalId}',
      utcNow: () => now,
    );
    approverId =
        (await SqliteContactRepository(
              database: database,
              idGenerator: () => 'contact-1',
              utcNow: () => now,
            ).create(
              projectId: 'project-1',
              draft: ContactDraft(
                displayName: 'Przemyslaw Sobczyk',
                kind: ContactKind.person,
                roles: const <ContactRole>{ContactRole.other},
              ),
            ))
            .id;
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('creates, lists, updates and preserves journal revisions', () async {
    final created = await journal.create(
      JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.daily,
        title: 'Dzień na budowie',
        occurredAt: now,
        workPerformed: 'Wykonano izolację.',
      ),
    );
    expect(created.revision, 1);

    final updated = await journal.update(
      projectId: 'project-1',
      entryId: created.id,
      input: JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.daily,
        title: 'Dzień na budowie po korekcie',
        occurredAt: now,
        workPerformed: 'Wykonano izolację i kontrolę.',
      ),
    );
    expect(updated.revision, 2);

    final page = await journal.list(
      JournalEntryQuery(projectId: 'project-1'),
      PageRequest(limit: 10),
    );
    expect(page.items.single.title, 'Dzień na budowie po korekcie');
    final revisions = await journal.revisions(
      projectId: 'project-1',
      entryId: created.id,
    );
    expect(revisions.map((item) => item.revision), <int>[2, 1]);
    expect(revisions.first.snapshotJson, contains('po korekcie'));
  });

  test(
    'deletes an unneeded journal output and reports a missing row',
    () async {
      final created = await journal.create(
        JournalEntryInput(
          projectId: 'project-1',
          type: JournalEntryType.decision,
          title: 'Tymczasowa decyzja',
          occurredAt: now,
          selectedOption: 'Wariant A',
        ),
      );

      await journal.delete(projectId: 'project-1', entryId: created.id);

      expect(
        await journal.findById(projectId: 'project-1', entryId: created.id),
        isNull,
      );
      await expectLater(
        journal.delete(projectId: 'project-1', entryId: created.id),
        throwsA(isA<JournalEntryNotFoundException>()),
      );
    },
  );

  test('classifies a quick note into a durable journal entry', () async {
    final captures = SqliteCaptureRepository(
      database: database,
      costRepository: SqliteCostRepository(
        database: database,
        idGenerator: () => 'cost-1',
        utcNow: () => now,
      ),
      documentRepository: SqliteDocumentRepository(
        database: database,
        utcNow: () => now,
      ),
      scheduleRepository: SqliteScheduleRepository(
        database: database,
        idGenerator: () => 'event-1',
        utcNow: () => now,
      ),
      diaryRepository: journal,
      idGenerator: () => 'capture-1',
      utcNow: () => now,
    );
    final draft = await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.note,
        title: 'Przepust pod wodę',
        content: 'Uzgodnić z instalatorem.',
      ),
    );
    final classified = await captures.classify(
      projectId: 'project-1',
      captureId: draft.id,
      currencyCode: 'PLN',
    );

    expect(classified.targetId, isNot(draft.id));
    final entry = await journal.findById(
      projectId: 'project-1',
      entryId: classified.targetId!,
    );
    expect(entry?.title, 'Przepust pod wodę');
    expect(entry?.input.sourceCaptureId, draft.id);
  });

  test('approves a complete decision and sums only active impacts', () async {
    final proposed = await journal.create(
      JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.decision,
        title: 'Dodatkowy przepust',
        occurredAt: now,
        problem: 'Brak rezerwy pod przewod do ogrodu.',
        variants: 'Bez przepustu albo rura oslonowa.',
        selectedOption: 'Rura oslonowa pod fundamentem.',
        rationale: 'Brak kucia po wykonaniu posadzki.',
        costDeltaMinorUnits: 125000,
        scheduleDeltaDays: 2,
      ),
    );
    await journal.create(
      JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.scopeChange,
        title: 'Niezatwierdzony wariant',
        occurredAt: now,
        selectedOption: 'Wariant roboczy',
        costDeltaMinorUnits: 900000,
        scheduleDeltaDays: 14,
      ),
    );

    await expectLater(
      journal.setStatus(
        projectId: 'project-1',
        entryId: proposed.id,
        status: JournalEntryStatus.approved,
      ),
      throwsA(isA<JournalDecisionApprovalRequiredException>()),
    );

    final approved = await journal.approveDecision(
      projectId: 'project-1',
      entryId: proposed.id,
      approvedByContactId: approverId,
    );
    final summary = await journal.decisionImpactSummary(projectId: 'project-1');

    expect(approved.status, JournalEntryStatus.approved);
    expect(approved.input.decisionMakerContactId, approverId);
    expect(approved.approval?.approvedByContactId, approverId);
    expect(approved.approval?.approvedAtUtc, now);
    expect(summary.approvedDecisionCount, 1);
    expect(summary.costDeltaMinorUnits, 125000);
    expect(summary.scheduleDeltaDays, 2);
    final revisions = await journal.revisions(
      projectId: 'project-1',
      entryId: proposed.id,
    );
    expect(revisions, hasLength(2));
    expect(revisions.first.snapshotJson, contains('approvedByContactId'));
  });

  test('editing an approved decision creates a proposal revision', () async {
    final created = await journal.create(
      JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.decision,
        title: 'Przepust',
        occurredAt: now,
        selectedOption: 'Rura 110 mm',
        costDeltaMinorUnits: 125000,
      ),
    );
    final approved = await journal.approveDecision(
      projectId: 'project-1',
      entryId: created.id,
      approvedByContactId: approverId,
    );

    final corrected = await journal.update(
      projectId: 'project-1',
      entryId: created.id,
      input: JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.decision,
        title: 'Przepust po korekcie',
        occurredAt: now,
        status: approved.status,
        selectedOption: 'Dwie rury 110 mm',
        costDeltaMinorUnits: 145000,
      ),
    );

    expect(corrected.status, JournalEntryStatus.proposal);
    expect(corrected.approval, isNull);
    expect(corrected.revision, 3);
    final summary = await journal.decisionImpactSummary(projectId: 'project-1');
    expect(summary.approvedDecisionCount, 0);
    expect(summary.costDeltaMinorUnits, 0);
    final revisions = await journal.revisions(
      projectId: 'project-1',
      entryId: created.id,
    );
    expect(revisions.map((revision) => revision.revision), <int>[3, 2, 1]);
  });

  test('rejects approval without a selected option', () async {
    final incomplete = await journal.create(
      JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.decision,
        title: 'Niepelna decyzja',
        occurredAt: now,
      ),
    );

    await expectLater(
      journal.approveDecision(
        projectId: 'project-1',
        entryId: incomplete.id,
        approvedByContactId: approverId,
      ),
      throwsA(isA<JournalDecisionIncompleteException>()),
    );
  });
}
