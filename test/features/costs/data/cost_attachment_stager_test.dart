import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late ProjectFileStore fileStore;
  late CostAttachmentStager stager;
  var nextId = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_attachment_stager_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    fileStore = ProjectFileStore(
      rootDirectory: Directory(p.join(temporaryDirectory.path, 'private')),
    );
    final projectRepository = SqliteProjectRepository(
      database: database,
      fileStore: fileStore,
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 7, 15),
    );
    await projectRepository.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    stager = CostAttachmentStager(
      database: database,
      fileStore: fileStore,
      idGenerator: () => 'attachment-${++nextId}',
      utcNow: () => DateTime.utc(2026, 7, 15, 12),
    );
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('stages an unchanged private original with safe storage key', () async {
    final source = File(p.join(temporaryDirectory.path, 'Faktura lipiec.PDF'));
    final bytes = <int>[0, 1, 2, 3, 254, 255];
    await source.writeAsBytes(bytes, flush: true);

    final attachment = await stager.stage(
      projectId: 'project-1',
      pickedFile: PickedCostAttachment(
        sourceUri: source.uri,
        displayName: 'Faktura lipiec.PDF',
        reportedByteSize: bytes.length,
        mediaType: 'application/pdf',
      ),
    );

    expect(attachment.id, 'attachment-1');
    expect(attachment.displayName, 'Faktura lipiec.PDF');
    expect(attachment.byteSize, bytes.length);
    expect(attachment.mediaType, 'application/pdf');
    expect(await source.readAsBytes(), bytes);
    final stored = fileStore.fileFor(
      projectId: 'project-1',
      area: ProjectFileArea.originals,
      fileName: 'attachment-1.pdf',
    );
    expect(await stored.readAsBytes(), bytes);
    final rows = await (await database.open()).query(
      AppDatabase.costAttachmentsTable,
    );
    expect(rows.single['availability'], 'available');
    expect(rows.single['original_storage_key'], 'attachment-1.pdf');
    expect(rows.single['preview_storage_key'], isNull);
  });

  test('failed import removes its database placeholder', () async {
    final missing = File(p.join(temporaryDirectory.path, 'missing.pdf'));

    await expectLater(
      stager.stage(
        projectId: 'project-1',
        pickedFile: PickedCostAttachment(
          sourceUri: missing.uri,
          displayName: 'missing.pdf',
          reportedByteSize: 10,
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(
      await (await database.open()).query(AppDatabase.costAttachmentsTable),
      isEmpty,
    );
  });

  test(
    'rejects unsupported and oversized files before creating a row',
    () async {
      final unsupported = File(p.join(temporaryDirectory.path, 'script.exe'));
      await unsupported.writeAsBytes(<int>[1], flush: true);
      await expectLater(
        stager.stage(
          projectId: 'project-1',
          pickedFile: PickedCostAttachment(
            sourceUri: unsupported.uri,
            displayName: 'script.exe',
            reportedByteSize: 1,
          ),
        ),
        throwsUnsupportedError,
      );

      final document = File(p.join(temporaryDirectory.path, 'large.pdf'));
      await document.writeAsBytes(<int>[1, 2, 3], flush: true);
      final strictStager = CostAttachmentStager(
        database: database,
        fileStore: fileStore,
        idGenerator: () => 'strict-attachment',
        utcNow: () => DateTime.utc(2026, 7, 15),
        maximumByteSize: 2,
      );
      await expectLater(
        strictStager.stage(
          projectId: 'project-1',
          pickedFile: PickedCostAttachment(
            sourceUri: document.uri,
            displayName: 'large.pdf',
            reportedByteSize: 3,
          ),
        ),
        throwsRangeError,
      );
      expect(
        await (await database.open()).query(AppDatabase.costAttachmentsTable),
        isEmpty,
      );
    },
  );

  test(
    'recovery removes interrupted imports and their private files',
    () async {
      final interruptedFile = fileStore.fileFor(
        projectId: 'project-1',
        area: ProjectFileArea.originals,
        fileName: 'interrupted.pdf',
      );
      await fileStore.ensureProjectDirectories('project-1');
      final interruptedPart = File('${interruptedFile.path}.part');
      await interruptedPart.writeAsBytes(<int>[1, 2, 3], flush: true);
      final rawDatabase = await database.open();
      await rawDatabase
          .insert(AppDatabase.costAttachmentsTable, <String, Object?>{
            'id': 'interrupted',
            'project_id': 'project-1',
            'display_name': 'interrupted.pdf',
            'original_storage_key': 'interrupted.pdf',
            'preview_storage_key': null,
            'media_type': 'application/pdf',
            'byte_size': 3,
            'sha256': null,
            'source': 'file_picker',
            'availability': 'importing',
            'imported_at_utc_ms': 0,
          });

      await stager.recoverInterruptedImports();

      expect(await interruptedFile.exists(), isFalse);
      expect(await interruptedPart.exists(), isFalse);
      expect(
        await rawDatabase.query(AppDatabase.costAttachmentsTable),
        isEmpty,
      );
    },
  );

  test('recovery finishes interrupted attachment deletion', () async {
    final deletingFile = fileStore.fileFor(
      projectId: 'project-1',
      area: ProjectFileArea.originals,
      fileName: 'deleting.pdf',
    );
    await fileStore.ensureProjectDirectories('project-1');
    await deletingFile.writeAsBytes(<int>[3, 2, 1], flush: true);
    final rawDatabase = await database.open();
    await rawDatabase
        .insert(AppDatabase.costAttachmentsTable, <String, Object?>{
          'id': 'deleting',
          'project_id': 'project-1',
          'display_name': 'deleting.pdf',
          'original_storage_key': 'deleting.pdf',
          'preview_storage_key': null,
          'media_type': 'application/pdf',
          'byte_size': 3,
          'sha256': null,
          'source': 'file_picker',
          'availability': 'deleting',
          'imported_at_utc_ms': 0,
        });

    await stager.recoverInterruptedDeletions();

    expect(await deletingFile.exists(), isFalse);
    expect(await rawDatabase.query(AppDatabase.costAttachmentsTable), isEmpty);
  });

  test(
    'discard removes an unlinked attachment and rejects a linked one',
    () async {
      final source = File(p.join(temporaryDirectory.path, 'receipt.jpg'));
      await source.writeAsBytes(<int>[1, 2, 3], flush: true);
      final first = await stager.stage(
        projectId: 'project-1',
        pickedFile: PickedCostAttachment(
          sourceUri: source.uri,
          displayName: 'receipt.jpg',
          reportedByteSize: 3,
        ),
      );

      await stager.discard(projectId: 'project-1', attachmentId: first.id);

      expect(
        await stager.findById(projectId: 'project-1', attachmentId: first.id),
        isNull,
      );

      final linked = await stager.stage(
        projectId: 'project-1',
        pickedFile: PickedCostAttachment(
          sourceUri: source.uri,
          displayName: 'receipt.jpg',
          reportedByteSize: 3,
        ),
      );
      final rawDatabase = await database.open();
      await rawDatabase.insert(
        AppDatabase.costEntriesTable,
        _minimalCostRow('cost-1'),
      );
      await rawDatabase
          .insert(AppDatabase.costEntryAttachmentsTable, <String, Object?>{
            'project_id': 'project-1',
            'cost_entry_id': 'cost-1',
            'attachment_id': linked.id,
            'sort_order': 0,
          });

      await expectLater(
        stager.discard(projectId: 'project-1', attachmentId: linked.id),
        throwsStateError,
      );
    },
  );

  test(
    'startup recovery removes an available attachment without links',
    () async {
      final source = File(p.join(temporaryDirectory.path, 'abandoned.pdf'));
      await source.writeAsBytes(<int>[4, 5, 6], flush: true);
      final abandoned = await stager.stage(
        projectId: 'project-1',
        pickedFile: PickedCostAttachment(
          sourceUri: source.uri,
          displayName: 'abandoned.pdf',
          reportedByteSize: 3,
        ),
      );

      await stager.recoverUnlinkedAttachments();

      expect(
        await stager.findById(
          projectId: 'project-1',
          attachmentId: abandoned.id,
        ),
        isNull,
      );
    },
  );
}

Map<String, Object?> _minimalCostRow(String id) {
  return <String, Object?>{
    'id': id,
    'project_id': 'project-1',
    'name': 'Cost',
    'entry_type': 'cost',
    'financial_status': 'paid',
    'lifecycle': 'confirmed',
    'entry_date_utc_ms': 0,
    'stage_id': null,
    'category_id': null,
    'supplier_id': null,
    'quantity_unscaled': null,
    'quantity_scale': null,
    'unit': null,
    'net_minor_units': 100,
    'vat_rate_basis_points': 0,
    'vat_minor_units': 0,
    'gross_minor_units': 100,
    'currency_code': 'PLN',
    'payment_method': null,
    'source': 'manual',
    'note': null,
    'revision': 1,
    'created_at_utc_ms': 0,
    'updated_at_utc_ms': 0,
  };
}
