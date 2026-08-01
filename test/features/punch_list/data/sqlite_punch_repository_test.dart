import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/diary/data/sqlite_journal_repository.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/punch_list/data/sqlite_punch_repository.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/domain/punch_repository.dart';
import 'package:budowapro/features/stages/data/sqlite_stage_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqlitePunchRepository repository;
  final now = DateTime.utc(2026, 7, 31, 12);
  var sequence = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_punch_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: () => now,
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    await SqliteStageRepository(
      database: database,
      idGenerator: () => 'unused',
      utcNow: () => now,
    ).listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final handle = await database.open();
    await handle.insert(AppDatabase.contactsTable, <String, Object?>{
      'id': 'contact-1',
      'project_id': 'project-1',
      'display_name': 'Hydraulik',
      'kind': 'person',
      'is_archived': 0,
      'created_at_utc_ms': now.millisecondsSinceEpoch,
      'updated_at_utc_ms': now.millisecondsSinceEpoch,
    });
    await _insertAttachment(database, 'report-photo', 'image/jpeg');
    await _insertAttachment(database, 'resolution-photo', 'image/jpeg');
    await _insertAttachment(database, 'signed-protocol', 'application/pdf');
    await _insertAttachment(database, 'not-a-protocol', 'text/plain');
    final journal = SqliteJournalRepository(
      database: database,
      idGenerator: () => 'journal-${sequence++}',
      utcNow: () => now,
    );
    repository = SqlitePunchRepository(
      database: database,
      journalRepository: journal,
      idGenerator: () => 'punch-${sequence++}',
      utcNow: () => now,
    );
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('returns zero counters when the project has no defects', () async {
    final summary = await repository.summarizeDefects(
      projectId: 'project-1',
      now: now,
    );

    expect(summary.openCount, 0);
    expect(summary.criticalCount, 0);
    expect(summary.overdueCount, 0);
  });

  test('creates and filters a durable defect backed by the journal', () async {
    final created = await repository.createDefect(
      DefectInput(
        projectId: 'project-1',
        title: 'Wilgoc przy przepuscie',
        occurredAt: now,
        severity: DefectSeverity.critical,
        stageId: 'state_zero',
        roomLabel: 'Kotlownia',
        responsibleContactId: 'contact-1',
        dueAt: now.subtract(const Duration(hours: 1)),
        description: 'Sprawdzic uszczelnienie.',
        attachmentIds: const <String>['report-photo'],
      ),
    );

    final page = await repository.listDefects(
      DefectQuery(
        projectId: 'project-1',
        searchText: 'przepuscie',
        severities: const <DefectSeverity>{DefectSeverity.critical},
        stageId: 'state_zero',
        responsibleContactId: 'contact-1',
        roomLabel: 'kotlownia',
        overdueOnly: true,
        now: now,
      ),
      PageRequest(limit: 20),
    );
    final summary = await repository.summarizeDefects(
      projectId: 'project-1',
      now: now,
    );

    expect(page.items.single.id, created.id);
    expect(page.items.single.entry.attachmentIds, <String>['report-photo']);
    expect(summary.openCount, 1);
    expect(summary.criticalCount, 1);
    expect(summary.overdueCount, 1);
    final handle = await database.open();
    expect(
      (await handle.query(
        AppDatabase.journalEntriesTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>['project-1', created.id],
      )).single['entry_type'],
      'defect',
    );
  });

  test(
    'blocks closure until required photo and signed protocol exist',
    () async {
      final created = await repository.createDefect(
        DefectInput(
          projectId: 'project-1',
          title: 'Nieszczelnosc',
          occurredAt: now,
          severity: DefectSeverity.high,
          requiresResolutionPhoto: true,
          requiresSignedProtocol: true,
        ),
      );

      await expectLater(
        repository.updateDefect(
          projectId: 'project-1',
          defectId: created.id,
          input: DefectInput(
            projectId: 'project-1',
            title: created.title,
            occurredAt: created.entry.input.occurredAt,
            severity: created.severity,
            status: JournalEntryStatus.closed,
            requiresResolutionPhoto: true,
            requiresSignedProtocol: true,
          ),
        ),
        throwsA(isA<DefectClosureEvidenceRequiredException>()),
      );

      await expectLater(
        repository.setDefectStatus(
          projectId: 'project-1',
          defectId: created.id,
          status: JournalEntryStatus.closed,
        ),
        throwsA(isA<DefectClosureEvidenceRequiredException>()),
      );

      final withPhoto = await repository.updateDefect(
        projectId: 'project-1',
        defectId: created.id,
        input: DefectInput(
          projectId: 'project-1',
          title: created.title,
          occurredAt: created.entry.occurredAtUtc,
          severity: created.severity,
          requiresResolutionPhoto: true,
          requiresSignedProtocol: true,
          resolutionAttachmentIds: const <String>['resolution-photo'],
        ),
      );
      expect(withPhoto.resolutionAttachmentIds, <String>['resolution-photo']);

      await expectLater(
        repository.setDefectStatus(
          projectId: 'project-1',
          defectId: created.id,
          status: JournalEntryStatus.closed,
        ),
        throwsA(isA<DefectClosureProtocolRequiredException>()),
      );

      final protocol = await repository.createProtocol(
        AcceptanceProtocolInput(
          projectId: 'project-1',
          title: 'Odbior poprawki',
          inspectedAt: now,
          status: AcceptanceProtocolStatus.signed,
          defectIds: <String>[created.id],
          signedAttachmentIds: const <String>['signed-protocol'],
        ),
      );
      final closed = await repository.setDefectStatus(
        projectId: 'project-1',
        defectId: created.id,
        status: JournalEntryStatus.closed,
      );

      expect(protocol.defectIds, <String>[created.id]);
      expect(closed.status, JournalEntryStatus.closed);
      expect(closed.hasSignedProtocol, isTrue);
      expect(closed.canClose, isTrue);
    },
  );

  test('rejects a signed protocol attachment that is not a document', () async {
    await expectLater(
      repository.createProtocol(
        AcceptanceProtocolInput(
          projectId: 'project-1',
          title: 'Odbior',
          inspectedAt: now,
          status: AcceptanceProtocolStatus.signed,
          signedAttachmentIds: const <String>['not-a-protocol'],
        ),
      ),
      throwsA(isA<PunchRelationNotFoundException>()),
    );
  });
}

Future<void> _insertAttachment(
  AppDatabase database,
  String id,
  String mediaType,
) async {
  final handle = await database.open();
  await handle.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
    'id': id,
    'project_id': 'project-1',
    'display_name': '$id.${mediaType == 'application/pdf' ? 'pdf' : 'jpg'}',
    'original_storage_key': '$id.bin',
    'preview_storage_key': null,
    'media_type': mediaType,
    'byte_size': 100,
    'source': 'file_picker',
    'availability': 'available',
    'imported_at_utc_ms': DateTime.utc(2026, 7, 31).millisecondsSinceEpoch,
  });
}
