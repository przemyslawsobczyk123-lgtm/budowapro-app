import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/sqlite_stage_repository.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteStageRepository repository;
  var nextId = 0;
  var nextMinute = 0;

  String generateId() => 'generated-${++nextId}';
  DateTime utcNow() => DateTime.utc(2026, 7, 20, 10, nextMinute++);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_stage_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projectRepository = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: utcNow,
    );
    await projectRepository.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    repository = SqliteStageRepository(
      database: database,
      idGenerator: generateId,
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

  test(
    'seeds ordered house stages and the complete Stan 0 checklist once',
    () async {
      final firstLoad = await repository.listStages(
        projectId: 'project-1',
        template: ProjectTemplate.houseConstruction,
      );
      final secondLoad = await repository.listStages(
        projectId: 'project-1',
        template: ProjectTemplate.houseConstruction,
      );

      expect(firstLoad.map((stage) => stage.id), <String>[
        'formalities',
        'state_zero',
        'shell_open',
        'shell_closed',
        'installations',
        'finishing',
        'handover',
      ]);
      expect(secondLoad, hasLength(firstLoad.length));
      final checklist = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'state_zero',
      );
      expect(checklist, hasLength(18));
      expect(
        checklist.map((item) => item.templateKey).toSet(),
        ChecklistTemplateKey.values.toSet(),
      );
    },
  );

  test('adds, renames and reorders a custom stage', () async {
    final seeded = await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final custom = await repository.addCustomStage(
      projectId: 'project-1',
      name: 'Ogród i podjazd',
    );
    final renamed = await repository.renameStage(
      projectId: 'project-1',
      stageId: custom.id,
      name: 'Teren zewnętrzny',
    );
    final reorderedIds = <String>[
      custom.id,
      ...seeded.map((stage) => stage.id),
    ];

    await repository.reorderStages(
      projectId: 'project-1',
      stageIds: reorderedIds,
    );
    final result = await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );

    expect(renamed.customName, 'Teren zewnętrzny');
    expect(result.map((stage) => stage.id), reorderedIds);
    expect(result.first.customName, 'Teren zewnętrzny');
  });

  test('required item closes only after local evidence is linked', () async {
    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final checklist = await repository.listChecklistItems(
      projectId: 'project-1',
      stageId: 'state_zero',
    );
    final grounding = checklist.singleWhere(
      (item) => item.templateKey == ChecklistTemplateKey.foundationGrounding,
    );

    await expectLater(
      repository.updateChecklistItem(
        projectId: 'project-1',
        checklistItemId: grounding.id,
        input: _details(grounding, status: ChecklistStatus.completed),
      ),
      throwsA(isA<ChecklistEvidenceRequiredException>()),
    );
    await expectLater(
      repository.updateChecklistItem(
        projectId: 'project-1',
        checklistItemId: grounding.id,
        input: ChecklistItemDetailsInput(
          status: ChecklistStatus.completed,
          importance: grounding.importance,
          evidenceRequirement: EvidenceRequirement.none,
        ),
      ),
      throwsA(isA<ChecklistEvidenceRequiredException>()),
    );

    final rawDatabase = await database.open();
    await rawDatabase
        .insert(AppDatabase.costAttachmentsTable, <String, Object?>{
          'id': 'photo-1',
          'project_id': 'project-1',
          'display_name': 'bednarka.jpg',
          'original_storage_key': 'photo-1.jpg',
          'preview_storage_key': null,
          'media_type': 'image/jpeg',
          'byte_size': 42,
          'sha256': null,
          'source': 'file_picker',
          'availability': 'available',
          'imported_at_utc_ms': 0,
        });
    final withEvidence = await repository.attachEvidence(
      projectId: 'project-1',
      checklistItemId: grounding.id,
      attachmentId: 'photo-1',
    );
    final completed = await repository.updateChecklistItem(
      projectId: 'project-1',
      checklistItemId: grounding.id,
      input: _details(withEvidence, status: ChecklistStatus.completed),
    );

    expect(completed.status, ChecklistStatus.completed);
    expect(completed.evidenceIds, <String>['photo-1']);
    final stage = (await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    )).singleWhere((stage) => stage.id == 'state_zero');
    expect(stage.progress.completedItems, 1);
    expect(stage.progress.totalItems, 18);
  });

  test('documented waiver is an explicit alternative to evidence', () async {
    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final item =
        (await repository.listChecklistItems(
          projectId: 'project-1',
          stageId: 'state_zero',
        )).singleWhere(
          (item) => item.templateKey == ChecklistTemplateKey.soilResearch,
        );

    final completed = await repository.updateChecklistItem(
      projectId: 'project-1',
      checklistItemId: item.id,
      input: ChecklistItemDetailsInput(
        status: ChecklistStatus.completed,
        importance: item.importance,
        evidenceRequirement: item.evidenceRequirement,
        evidenceWaiverComment:
            'Dokument ma kierownik; inwestor zaakceptował odstępstwo.',
      ),
    );

    expect(completed.hasEvidence, isFalse);
    expect(completed.hasEvidenceWaiver, isTrue);
  });

  test('rejects a reordered list that omits a project stage', () async {
    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );

    await expectLater(
      repository.reorderStages(
        projectId: 'project-1',
        stageIds: const <String>['state_zero'],
      ),
      throwsA(isA<StageOrderMismatchException>()),
    );
  });
}

ChecklistItemDetailsInput _details(
  ChecklistItem item, {
  required ChecklistStatus status,
}) {
  return ChecklistItemDetailsInput(
    status: status,
    importance: item.importance,
    evidenceRequirement: item.evidenceRequirement,
    dueDate: item.dueDate,
    assignee: item.assignee,
    note: item.note,
    riskIfSkipped: item.riskIfSkipped,
    statusReason: item.statusReason,
    evidenceWaiverComment: item.evidenceWaiverComment,
  );
}
