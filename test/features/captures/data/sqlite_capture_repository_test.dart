import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/captures/data/sqlite_capture_repository.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/captures/domain/capture_repository.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/schedule/data/sqlite_schedule_repository.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteCaptureRepository captures;
  late SqliteCostRepository costs;
  late SqliteDocumentRepository documents;
  late SqliteScheduleRepository schedule;
  var captureId = 0;
  var costId = 0;
  var scheduleId = 0;
  final now = DateTime.utc(2026, 7, 27, 12);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_capture_repository_test_',
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
    await projects.create(
      ProjectDraft(
        name: 'Mieszkanie',
        type: ProjectType.apartmentRenovation,
        template: ProjectTemplate.renovation,
      ),
    );
    costs = SqliteCostRepository(
      database: database,
      idGenerator: () => 'cost-${++costId}',
      utcNow: () => now,
    );
    documents = SqliteDocumentRepository(database: database, utcNow: () => now);
    schedule = SqliteScheduleRepository(
      database: database,
      idGenerator: () => 'event-${++scheduleId}',
      utcNow: () => now,
    );
    captures = SqliteCaptureRepository(
      database: database,
      costRepository: costs,
      documentRepository: documents,
      scheduleRepository: schedule,
      idGenerator: () => 'capture-${++captureId}',
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

  test('keeps open drafts project-scoped and ordered newest first', () async {
    await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.note,
        title: 'Pierwsza',
        content: 'Treść',
      ),
    );
    await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.cost,
        title: 'Brak kwoty',
      ),
    );
    await captures.create(
      CaptureDraftInput(
        projectId: 'project-2',
        type: CaptureDraftType.note,
        title: 'Inny projekt',
        content: 'Treść',
      ),
    );

    final page = await captures.list(
      CaptureDraftQuery(projectId: 'project-1'),
      PageRequest(limit: 20),
    );

    expect(page.totalCount, 2);
    expect(page.items.map((item) => item.id), <String>[
      'capture-2',
      'capture-1',
    ]);
    expect(page.items.first.status, CaptureDraftStatus.needsReview);
    expect(await captures.countOpen(projectId: 'project-1'), 2);
    expect(await captures.countOpen(projectId: 'project-2'), 1);
  });

  test('merges same-type text and attachment links atomically', () async {
    await _insertAttachment(database, id: 'file-1');
    await _insertAttachment(database, id: 'file-2');
    final retained = await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.document,
        title: 'Projekt',
        content: 'Pierwsza część',
        attachmentIds: const <String>['file-1'],
      ),
    );
    final merged = await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.document,
        title: 'Załącznik',
        content: 'Druga część',
        attachmentIds: const <String>['file-2'],
      ),
    );

    final result = await captures.merge(
      projectId: 'project-1',
      retainedCaptureId: retained.id,
      mergedCaptureId: merged.id,
    );

    expect(result.attachmentIds, <String>['file-1', 'file-2']);
    expect(result.content, 'Pierwsza część\n\nDruga część');
    expect(
      await captures.findById(projectId: 'project-1', captureId: merged.id),
      isNull,
    );
  });

  test('classifies an attachment as a document in one transaction', () async {
    await _insertAttachment(
      database,
      id: 'photo-1',
      displayName: 'instalacja.jpg',
      mediaType: 'image/jpeg',
    );
    final capture = await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.photo,
        title: 'Przewody przed tynkiem',
        content: 'Ściana północna.',
        attachmentIds: const <String>['photo-1'],
      ),
    );

    final classified = await captures.classify(
      projectId: 'project-1',
      captureId: capture.id,
      currencyCode: 'PLN',
    );
    final document = await documents.findById(
      projectId: 'project-1',
      documentId: 'photo-1',
    );

    expect(classified.status, CaptureDraftStatus.classified);
    expect(classified.targetType, CaptureTargetType.document);
    expect(classified.targetId, 'photo-1');
    expect(document?.metadata.title, 'Przewody przed tynkiem');
    expect(document?.metadata.type, ProjectDocumentType.photo);
    expect(await captures.countOpen(projectId: 'project-1'), 0);
  });

  test('classifies a financial capture as an excluded cost draft', () async {
    final capture = await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.cost,
        title: 'Pustaki',
        content: 'Dostawa na rano.',
        grossAmountMinorUnits: 12345,
        vatRateBasisPoints: 2300,
      ),
    );

    final classified = await captures.classify(
      projectId: 'project-1',
      captureId: capture.id,
      currencyCode: 'PLN',
    );
    final cost = await costs.findById(
      projectId: 'project-1',
      costEntryId: classified.targetId!,
    );
    final summary = await costs.summarize(
      CostSummaryQuery(projectId: 'project-1'),
    );

    expect(classified.targetType, CaptureTargetType.costDraft);
    expect(cost?.lifecycle, CostLifecycle.draft);
    expect(cost?.input.amount.gross.minorUnits, 12345);
    expect(summary.actual.minorUnits, 0);
    expect(summary.planned.minorUnits, 0);
  });

  test('classifies a task capture as a local schedule event', () async {
    final capture = await captures.create(
      CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.task,
        title: 'Odbierz stal',
        content: 'Sprawdź średnicę.',
        scheduledAt: DateTime.utc(2026, 8, 1, 7),
        timeZoneId: 'Europe/Warsaw',
      ),
    );

    final classified = await captures.classify(
      projectId: 'project-1',
      captureId: capture.id,
      currencyCode: 'PLN',
    );
    final event = await schedule.findById(
      projectId: 'project-1',
      eventId: classified.targetId!,
    );

    expect(classified.targetType, CaptureTargetType.scheduleTask);
    expect(event?.kind, ScheduleEventKind.task);
    expect(event?.title, 'Odbierz stal');
    expect(event?.note, 'Sprawdź średnicę.');
  });

  test(
    'reject returns attachment candidates and removes only its draft',
    () async {
      await _insertAttachment(database, id: 'file-1');
      final capture = await captures.create(
        CaptureDraftInput(
          projectId: 'project-1',
          type: CaptureDraftType.document,
          title: 'Do usunięcia',
          attachmentIds: const <String>['file-1'],
        ),
      );

      final attachments = await captures.reject(
        projectId: 'project-1',
        captureId: capture.id,
      );

      expect(attachments, <String>['file-1']);
      expect(
        await captures.findById(projectId: 'project-1', captureId: capture.id),
        isNull,
      );
      final handle = await database.open();
      expect(
        await handle.query(
          AppDatabase.costAttachmentsTable,
          where: 'id = ?',
          whereArgs: const <Object?>['file-1'],
        ),
        hasLength(1),
      );
    },
  );
}

Future<void> _insertAttachment(
  AppDatabase database, {
  required String id,
  String displayName = 'dokument.pdf',
  String mediaType = 'application/pdf',
}) async {
  final handle = await database.open();
  await handle.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
    'id': id,
    'project_id': 'project-1',
    'display_name': displayName,
    'original_storage_key': '$id.bin',
    'preview_storage_key': null,
    'media_type': mediaType,
    'byte_size': 10,
    'sha256': null,
    'source': 'file_picker',
    'availability': 'available',
    'imported_at_utc_ms': 1,
  });
}
