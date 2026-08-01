import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/sqlite_stage_repository.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/technical_photos/data/sqlite_technical_photo_repository.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteTechnicalPhotoRepository repository;
  late ChecklistItem groundingChecklist;
  final now = DateTime.utc(2026, 7, 31, 12);
  var nextId = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_technical_photo_repository_test_',
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
    final stages = SqliteStageRepository(
      database: database,
      idGenerator: () => 'unused',
      utcNow: () => now,
    );
    await stages.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    groundingChecklist =
        (await stages.listChecklistItems(
          projectId: 'project-1',
          stageId: 'state_zero',
        )).singleWhere(
          (item) =>
              item.templateKey == ChecklistTemplateKey.foundationGrounding,
        );
    final handle = await database.open();
    await handle.insert(AppDatabase.contactsTable, <String, Object?>{
      'id': 'contact-1',
      'project_id': 'project-1',
      'display_name': 'Elektryk',
      'kind': 'person',
      'is_archived': 0,
      'created_at_utc_ms': now.millisecondsSinceEpoch,
      'updated_at_utc_ms': now.millisecondsSinceEpoch,
    });
    await _insertAttachment(database, id: 'photo-1', mediaType: 'image/jpeg');
    await _insertAttachment(
      database,
      id: 'document-1',
      mediaType: 'application/pdf',
    );
    repository = SqliteTechnicalPhotoRepository(
      database: database,
      documentRepository: SqliteDocumentRepository(
        database: database,
        utcNow: () => now,
      ),
      idGenerator: () => 'generated-${nextId++}',
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

  test(
    'creates an album and an auditable checklist photo atomically',
    () async {
      final album = await repository.createAlbum(
        TechnicalAlbumInput(
          projectId: 'project-1',
          title: 'Przed betonem',
          kind: TechnicalAlbumKind.beforeConcrete,
          stageId: 'state_zero',
        ),
      );

      final photo = await repository.createPhoto(
        TechnicalPhotoInput(
          projectId: 'project-1',
          attachmentId: 'photo-1',
          albumId: album.id,
          title: 'Uziom fundamentowy',
          capturedAt: DateTime.utc(2026, 7, 31, 10),
          installationType: TechnicalInstallationType.grounding,
          stageId: 'state_zero',
          contractorContactId: 'contact-1',
          checklistItemId: groundingChecklist.id,
          description: 'Polaczenia przed betonowaniem.',
          tags: const <String>['uziom', 'bednarka'],
        ),
      );

      expect(photo.tags, <String>['bednarka', 'uziom']);
      expect(photo.checklistItemId, groundingChecklist.id);
      expect(
        (await repository.listAlbums(projectId: 'project-1')).single.photoCount,
        1,
      );
      final handle = await database.open();
      expect(
        (await handle.query(
          AppDatabase.documentMetadataTable,
          where: 'project_id = ? AND attachment_id = ?',
          whereArgs: const <Object?>['project-1', 'photo-1'],
        )).single['document_type'],
        'photo',
      );
      expect(
        await handle.query(
          AppDatabase.checklistItemAttachmentsTable,
          where:
              'project_id = ? AND checklist_item_id = ? AND attachment_id = ?',
          whereArgs: <Object?>['project-1', groundingChecklist.id, 'photo-1'],
        ),
        hasLength(1),
      );
      expect(await handle.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test('infers the photo stage from linked checklist evidence', () async {
    final album = await repository.createAlbum(
      TechnicalAlbumInput(
        projectId: 'project-1',
        title: 'Dokumentacja uziomu',
        kind: TechnicalAlbumKind.custom,
      ),
    );

    final photo = await repository.createPhoto(
      TechnicalPhotoInput(
        projectId: 'project-1',
        attachmentId: 'photo-1',
        albumId: album.id,
        title: 'Bednarka przed betonowaniem',
        capturedAt: now,
        installationType: TechnicalInstallationType.grounding,
        checklistItemId: groundingChecklist.id,
      ),
    );

    expect(photo.stageId, 'state_zero');
    final handle = await database.open();
    expect(
      await handle.query(
        AppDatabase.documentContextLinksTable,
        where: 'project_id = ? AND attachment_id = ? AND relation_type = ?',
        whereArgs: const <Object?>['project-1', 'photo-1', 'stage'],
      ),
      hasLength(1),
    );
  });

  test('filters by text, tag, stage and installation type', () async {
    final album = await _createAlbum(repository);
    await repository.createPhoto(
      TechnicalPhotoInput(
        projectId: 'project-1',
        attachmentId: 'photo-1',
        albumId: album.id,
        title: 'Podejscie wody w kuchni',
        capturedAt: DateTime.utc(2026, 7, 31, 10),
        installationType: TechnicalInstallationType.water,
        stageId: 'installations',
        zoneLabel: 'Kuchnia',
        tags: const <String>['przed tynkiem', 'woda'],
      ),
    );

    final page = await repository.listPhotos(
      TechnicalPhotoQuery(
        projectId: 'project-1',
        searchText: 'KUCHNI',
        albumIds: <String>{album.id},
        stageIds: const <String>{'installations'},
        installationTypes: const <TechnicalInstallationType>{
          TechnicalInstallationType.water,
        },
        tags: const <String>{'WODA'},
      ),
      PageRequest(limit: 20),
    );

    expect(page.totalCount, 1);
    expect(page.items.single.attachmentId, 'photo-1');
  });

  test(
    'persists validated links to cost, decision, defect and protocol',
    () async {
      final handle = await database.open();
      await handle.insert(AppDatabase.costEntriesTable, <String, Object?>{
        'id': 'cost-1',
        'project_id': 'project-1',
        'name': 'Material',
        'entry_type': 'cost',
        'financial_status': 'paid',
        'lifecycle': 'confirmed',
        'entry_date_utc_ms': now.millisecondsSinceEpoch,
        'net_minor_units': 100,
        'vat_rate_basis_points': 0,
        'vat_minor_units': 0,
        'gross_minor_units': 100,
        'currency_code': 'PLN',
        'source': 'manual',
        'revision': 1,
        'created_at_utc_ms': now.millisecondsSinceEpoch,
        'updated_at_utc_ms': now.millisecondsSinceEpoch,
      });
      for (final record in const <(String, String)>[
        ('decision-1', 'decision'),
        ('defect-1', 'defect'),
      ]) {
        await handle.insert(AppDatabase.journalEntriesTable, <String, Object?>{
          'id': record.$1,
          'project_id': 'project-1',
          'entry_type': record.$2,
          'status': record.$2 == 'decision' ? 'proposal' : 'open',
          'title': record.$1,
          'defect_severity': record.$2 == 'defect' ? 'medium' : null,
          'requires_resolution_photo': 0,
          'requires_signed_protocol': 0,
          'occurred_at_utc_ms': now.millisecondsSinceEpoch,
          'created_at_utc_ms': now.millisecondsSinceEpoch,
          'updated_at_utc_ms': now.millisecondsSinceEpoch,
          'revision': 1,
        });
      }
      await handle
          .insert(AppDatabase.acceptanceProtocolsTable, <String, Object?>{
            'id': 'protocol-1',
            'project_id': 'project-1',
            'title': 'Odbior',
            'status': 'draft',
            'inspected_at_utc_ms': now.millisecondsSinceEpoch,
            'created_at_utc_ms': now.millisecondsSinceEpoch,
            'updated_at_utc_ms': now.millisecondsSinceEpoch,
          });
      final album = await _createAlbum(repository);

      final photo = await repository.createPhoto(
        TechnicalPhotoInput(
          projectId: 'project-1',
          attachmentId: 'photo-1',
          albumId: album.id,
          title: 'Instalacja przed tynkiem',
          capturedAt: now,
          installationType: TechnicalInstallationType.electrical,
          links: const <TechnicalPhotoLink>[
            TechnicalPhotoLink(
              type: TechnicalPhotoLinkType.cost,
              targetId: 'cost-1',
            ),
            TechnicalPhotoLink(
              type: TechnicalPhotoLinkType.decision,
              targetId: 'decision-1',
            ),
            TechnicalPhotoLink(
              type: TechnicalPhotoLinkType.defect,
              targetId: 'defect-1',
            ),
            TechnicalPhotoLink(
              type: TechnicalPhotoLinkType.acceptanceProtocol,
              targetId: 'protocol-1',
            ),
          ],
        ),
      );

      expect(photo.links, hasLength(4));
      expect(
        await handle.query(
          AppDatabase.technicalPhotoLinksTable,
          where: 'project_id = ? AND attachment_id = ?',
          whereArgs: const <Object?>['project-1', 'photo-1'],
        ),
        hasLength(4),
      );
    },
  );

  test('rolls back a photo when a typed link target does not exist', () async {
    final album = await _createAlbum(repository);

    await expectLater(
      repository.createPhoto(
        TechnicalPhotoInput(
          projectId: 'project-1',
          attachmentId: 'photo-1',
          albumId: album.id,
          title: 'Bledne powiazanie',
          capturedAt: now,
          installationType: TechnicalInstallationType.other,
          links: const <TechnicalPhotoLink>[
            TechnicalPhotoLink(
              type: TechnicalPhotoLinkType.defect,
              targetId: 'missing-defect',
            ),
          ],
        ),
      ),
      throwsArgumentError,
    );

    final handle = await database.open();
    expect(await handle.query(AppDatabase.technicalPhotosTable), isEmpty);
    expect(await handle.query(AppDatabase.technicalPhotoLinksTable), isEmpty);
  });

  test(
    'rejects a non-image without leaving metadata or checklist evidence',
    () async {
      final album = await _createAlbum(repository);

      await expectLater(
        repository.createPhoto(
          TechnicalPhotoInput(
            projectId: 'project-1',
            attachmentId: 'document-1',
            albumId: album.id,
            title: 'Nie jest zdjeciem',
            capturedAt: now,
            installationType: TechnicalInstallationType.other,
            checklistItemId: groundingChecklist.id,
          ),
        ),
        throwsArgumentError,
      );

      final handle = await database.open();
      expect(await handle.query(AppDatabase.technicalPhotosTable), isEmpty);
      expect(
        await handle.query(
          AppDatabase.documentMetadataTable,
          where: 'attachment_id = ?',
          whereArgs: const <Object?>['document-1'],
        ),
        isEmpty,
      );
      expect(
        await handle.query(
          AppDatabase.checklistItemAttachmentsTable,
          where: 'attachment_id = ?',
          whereArgs: const <Object?>['document-1'],
        ),
        isEmpty,
      );
    },
  );

  test('pages a 500 photo fixture without materializing every row', () async {
    final album = await _createAlbum(repository);
    final handle = await database.open();
    await handle.transaction((transaction) async {
      final batch = transaction.batch();
      for (var index = 0; index < 500; index++) {
        final id = 'fixture-$index';
        batch.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
          'id': id,
          'project_id': 'project-1',
          'display_name': '$id.jpg',
          'original_storage_key': '$id.jpg',
          'preview_storage_key': null,
          'media_type': 'image/jpeg',
          'byte_size': 100,
          'source': 'file_picker',
          'availability': 'available',
          'imported_at_utc_ms': now.millisecondsSinceEpoch + index,
        });
        batch.insert(AppDatabase.technicalPhotosTable, <String, Object?>{
          'project_id': 'project-1',
          'attachment_id': id,
          'album_id': album.id,
          'title': 'Zdjecie $index',
          'captured_at_utc_ms': now.millisecondsSinceEpoch + index,
          'installation_type': 'other',
          'created_at_utc_ms': now.millisecondsSinceEpoch,
          'updated_at_utc_ms': now.millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);
    });

    final page = await repository.listPhotos(
      TechnicalPhotoQuery(projectId: 'project-1'),
      PageRequest(limit: 30),
    );

    expect(page.totalCount, 500);
    expect(page.items, hasLength(30));
    expect(page.nextRequest?.offset, 30);
  });
}

Future<TechnicalAlbum> _createAlbum(
  SqliteTechnicalPhotoRepository repository,
) => repository.createAlbum(
  TechnicalAlbumInput(
    projectId: 'project-1',
    title: 'Instalacje przed tynkiem',
    kind: TechnicalAlbumKind.beforePlaster,
    stageId: 'installations',
  ),
);

Future<void> _insertAttachment(
  AppDatabase database, {
  required String id,
  required String mediaType,
}) async {
  final handle = await database.open();
  await handle.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
    'id': id,
    'project_id': 'project-1',
    'display_name': '$id.${mediaType.startsWith('image/') ? 'jpg' : 'pdf'}',
    'original_storage_key': '$id.bin',
    'preview_storage_key': null,
    'media_type': mediaType,
    'byte_size': 100,
    'source': 'file_picker',
    'availability': 'available',
    'imported_at_utc_ms': DateTime.utc(2026, 7, 31).millisecondsSinceEpoch,
  });
}
