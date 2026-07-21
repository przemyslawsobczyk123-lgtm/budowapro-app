import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
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
  late SqliteDocumentRepository documents;
  final now = DateTime.utc(2026, 7, 21, 10);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_document_repository_test_',
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
    await _insertAttachment(
      database,
      id: 'document-1',
      name: 'faktura.pdf',
      mediaType: 'application/pdf',
    );
    await _insertAttachment(
      database,
      id: 'document-2',
      name: 'gwarancja.jpg',
      mediaType: 'image/jpeg',
    );
    await SqliteCostRepository(
      database: database,
      idGenerator: () => 'cost-1',
      utcNow: () => now,
    ).create(
      ConfirmedCostEntryInput(
        CostEntryInput(
          projectId: 'project-1',
          name: 'Pompa ciepla',
          type: CostEntryType.cost,
          status: CostStatus.paid,
          amount: VatBreakdown.fromGross(_pln(3000000), VatRate.standard23),
          entryDate: DateTime.utc(2026, 7, 10),
          stageId: 'installations',
          attachmentIds: const <String>['document-1'],
        ),
      ),
    );
    documents = SqliteDocumentRepository(database: database, utcNow: () => now);
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('legacy attachment appears without copying or metadata row', () async {
    final document = await documents.findById(
      projectId: 'project-1',
      documentId: 'document-1',
    );

    expect(document?.metadata.title, 'faktura.pdf');
    expect(document?.metadata.type, ProjectDocumentType.other);
    expect(document?.relations.single.type, DocumentRelationType.cost);
    expect(document?.relations.single.label, 'Pompa ciepla');
    final handle = await database.open();
    expect(await handle.query(AppDatabase.documentMetadataTable), isEmpty);
    expect(
      (await handle.query(
        AppDatabase.costAttachmentsTable,
        where: 'id = ?',
        whereArgs: const <Object?>['document-1'],
      )).single['original_storage_key'],
      'document-1.pdf',
    );
  });

  test(
    'updates metadata and filters by type, inferred stage and date',
    () async {
      await documents.updateMetadata(
        projectId: 'project-1',
        documentId: 'document-1',
        metadata: DocumentMetadata(
          title: 'Faktura za pompe ciepla',
          type: ProjectDocumentType.invoice,
          description: 'Jednostka zewnetrzna i montaz',
          documentDate: DateTime.utc(2026, 7, 10),
        ),
      );

      final page = await documents.list(
        DocumentQuery(
          projectId: 'project-1',
          searchText: 'POMPE',
          types: const <ProjectDocumentType>{ProjectDocumentType.invoice},
          stageIds: const <String>{'installations'},
          fromInclusive: DateTime.utc(2026, 7, 1),
          toExclusive: DateTime.utc(2026, 8, 1),
        ),
        PageRequest(limit: 20),
      );

      expect(page.totalCount, 1);
      expect(page.items.single.id, 'document-1');
      expect(
        page.items.single.metadata.documentDateUtc,
        DateTime.utc(2026, 7, 10),
      );
    },
  );

  test('stores validated stage and room context links', () async {
    final updated = await documents.replaceContextLinks(
      projectId: 'project-1',
      documentId: 'document-2',
      links: <DocumentRelation>[
        DocumentRelation(
          type: DocumentRelationType.stage,
          targetId: 'installations',
          label: 'Instalacje',
        ),
        DocumentRelation(
          type: DocumentRelationType.room,
          targetId: 'kuchnia',
          label: 'Kuchnia',
        ),
      ],
    );

    expect(
      updated.relations.map((relation) => relation.type),
      containsAll(<DocumentRelationType>[
        DocumentRelationType.stage,
        DocumentRelationType.room,
      ]),
    );
    expect(
      (await documents.list(
        DocumentQuery(
          projectId: 'project-1',
          roomIds: const <String>{'kuchnia'},
        ),
        PageRequest(),
      )).items.single.id,
      'document-2',
    );
    final options = await documents.filterOptions(projectId: 'project-1');
    expect(options.rooms.single.label, 'Kuchnia');
    expect(options.stages.map((stage) => stage.id), contains('installations'));
  });

  test('filters warranty state at the shared 30 day boundary', () async {
    await documents.updateMetadata(
      projectId: 'project-1',
      documentId: 'document-2',
      metadata: DocumentMetadata(
        title: 'Gwarancja pompy',
        type: ProjectDocumentType.warranty,
        warrantyStartsAt: DateTime.utc(2026, 7, 1),
        warrantyEndsAt: DateTime.utc(2026, 8, 20, 10),
      ),
    );

    final page = await documents.list(
      DocumentQuery(
        projectId: 'project-1',
        warrantyStates: const <DocumentWarrantyState>{
          DocumentWarrantyState.expiringSoon,
        },
      ),
      PageRequest(),
    );

    expect(page.items.map((document) => document.id), <String>['document-2']);
  });

  test('finds hash duplicates and can exclude current document', () async {
    expect(
      await documents.findPotentialDuplicates(
        projectId: 'project-1',
        sha256: _hash,
      ),
      hasLength(2),
    );
    expect(
      (await documents.findPotentialDuplicates(
        projectId: 'project-1',
        sha256: _hash,
        excludingDocumentId: 'document-1',
      )).single.id,
      'document-2',
    );
  });

  test('rejects native and unknown context targets', () async {
    await expectLater(
      documents.replaceContextLinks(
        projectId: 'project-1',
        documentId: 'document-2',
        links: <DocumentRelation>[
          DocumentRelation(
            type: DocumentRelationType.cost,
            targetId: 'cost-1',
            label: 'Koszt',
          ),
        ],
      ),
      throwsArgumentError,
    );
    await expectLater(
      documents.replaceContextLinks(
        projectId: 'project-1',
        documentId: 'document-2',
        links: <DocumentRelation>[
          DocumentRelation(
            type: DocumentRelationType.stage,
            targetId: 'outside-project',
            label: 'Obcy etap',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('rolls back metadata when saving context links fails', () async {
    await expectLater(
      documents.saveDetails(
        projectId: 'project-1',
        documentId: 'document-2',
        metadata: DocumentMetadata(
          title: 'Nie powinno zostac',
          type: ProjectDocumentType.warranty,
        ),
        contextLinks: <DocumentRelation>[
          DocumentRelation(
            type: DocumentRelationType.stage,
            targetId: 'outside-project',
            label: 'Obcy etap',
          ),
        ],
      ),
      throwsArgumentError,
    );

    final handle = await database.open();
    expect(
      await handle.query(
        AppDatabase.documentMetadataTable,
        where: 'attachment_id = ?',
        whereArgs: const <Object?>['document-2'],
      ),
      isEmpty,
    );
  });
}

const String _hash =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

Future<void> _insertAttachment(
  AppDatabase database, {
  required String id,
  required String name,
  required String mediaType,
}) async {
  final handle = await database.open();
  final extension = p.extension(name);
  await handle.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
    'id': id,
    'project_id': 'project-1',
    'display_name': name,
    'original_storage_key': '$id$extension',
    'preview_storage_key': null,
    'media_type': mediaType,
    'byte_size': 100,
    'sha256': _hash,
    'source': 'file_picker',
    'availability': 'available',
    'imported_at_utc_ms': DateTime.utc(2026, 7, 1).millisecondsSinceEpoch,
  });
}

Money _pln(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');
