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
    'seeds ordered early stages and every built-in checklist once',
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
        'site_preparation',
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
      expect(checklist, hasLength(16));
      final formalities = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'formalities',
      );
      expect(formalities, hasLength(15));
      final sitePreparation = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'site_preparation',
      );
      expect(sitePreparation, hasLength(12));
      expect(
        <ChecklistItem>[
          ...formalities,
          ...sitePreparation,
          ...checklist,
        ].map((item) => item.templateKey).toSet(),
        ChecklistTemplateKey.values
            .where((key) => key != ChecklistTemplateKey.siteRoadPowerWater)
            .toSet(),
      );
      final shellOpenChecklist = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'shell_open',
      );
      expect(shellOpenChecklist, isEmpty);
      final projectChecklist = await repository.listProjectChecklistItems(
        projectId: 'project-1',
      );
      expect(projectChecklist, hasLength(43));
      expect(
        projectChecklist.every((item) => item.projectId == 'project-1'),
        isTrue,
      );
    },
  );

  test(
    'upgrades an older house checklist without losing user progress',
    () async {
      final sqlite = await database.open();
      const createdAt = 1;
      for (final stage in <(String, int)>[
        ('formalities', 0),
        ('state_zero', 1),
      ]) {
        await sqlite.insert(AppDatabase.projectStagesTable, <String, Object?>{
          'project_id': 'project-1',
          'id': stage.$1,
          'template_stage_key': stage.$1,
          'custom_name': null,
          'status': 'planned',
          'sort_order': stage.$2,
          'planned_start_utc_ms': null,
          'planned_end_utc_ms': null,
          'planned_budget_minor_units': null,
          'created_at_utc_ms': createdAt,
          'updated_at_utc_ms': createdAt,
        });
      }
      await sqlite.insert(AppDatabase.checklistItemsTable, <String, Object?>{
        'project_id': 'project-1',
        'id': 'state_zero_soil_research',
        'stage_id': 'state_zero',
        'template_item_key': 'soil_research',
        'custom_title': null,
        'status': 'completed',
        'importance': 'high',
        'due_at_utc_ms': null,
        'assignee_label': 'Geotechnik',
        'note': 'Wyniki przekazane projektantowi.',
        'risk_if_skipped': null,
        'status_reason': null,
        'evidence_requirement': 'any_attachment',
        'evidence_waiver_comment': 'Dokument pozostaje u projektanta.',
        'sort_order': 0,
        'created_at_utc_ms': createdAt,
        'updated_at_utc_ms': createdAt,
      });
      await sqlite.insert(AppDatabase.checklistItemsTable, <String, Object?>{
        'project_id': 'project-1',
        'id': 'state_zero_site_road_power_water',
        'stage_id': 'state_zero',
        'template_item_key': 'site_road_power_water',
        'custom_title': null,
        'status': 'todo',
        'importance': 'normal',
        'due_at_utc_ms': null,
        'assignee_label': null,
        'note': null,
        'risk_if_skipped': null,
        'status_reason': null,
        'evidence_requirement': 'none',
        'evidence_waiver_comment': null,
        'sort_order': 1,
        'created_at_utc_ms': createdAt,
        'updated_at_utc_ms': createdAt,
      });

      final stages = await repository.listStages(
        projectId: 'project-1',
        template: ProjectTemplate.houseConstruction,
      );
      final formalities = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'formalities',
      );
      final stateZero = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'state_zero',
      );

      expect(stages.take(3).map((stage) => stage.id), <String>[
        'formalities',
        'site_preparation',
        'state_zero',
      ]);
      final migratedSoil = formalities.singleWhere(
        (item) => item.templateKey == ChecklistTemplateKey.soilResearch,
      );
      expect(migratedSoil.id, 'state_zero_soil_research');
      expect(migratedSoil.status, ChecklistStatus.completed);
      expect(migratedSoil.assignee, 'Geotechnik');
      expect(migratedSoil.hasEvidenceWaiver, isTrue);
      expect(
        stateZero.any(
          (item) => item.templateKey == ChecklistTemplateKey.siteRoadPowerWater,
        ),
        isFalse,
      );
      expect(
        await repository.listProjectChecklistItems(projectId: 'project-1'),
        hasLength(43),
      );
    },
  );

  test('keeps a legacy site setup item with user-edited importance', () async {
    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final sqlite = await database.open();
    await sqlite.insert(AppDatabase.checklistItemsTable, <String, Object?>{
      'project_id': 'project-1',
      'id': 'edited_legacy_site_setup',
      'stage_id': 'state_zero',
      'template_item_key': 'site_road_power_water',
      'custom_title': null,
      'status': 'todo',
      'importance': 'high',
      'due_at_utc_ms': null,
      'assignee_label': null,
      'note': null,
      'risk_if_skipped': null,
      'status_reason': null,
      'evidence_requirement': 'none',
      'evidence_waiver_comment': null,
      'sort_order': 99,
      'created_at_utc_ms': 1,
      'updated_at_utc_ms': 2,
    });

    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final checklist = await repository.listChecklistItems(
      projectId: 'project-1',
      stageId: 'state_zero',
    );
    final legacy = checklist.singleWhere(
      (item) => item.templateKey == ChecklistTemplateKey.siteRoadPowerWater,
    );

    expect(legacy.id, 'edited_legacy_site_setup');
    expect(legacy.importance, ChecklistImportance.high);
  });

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

  test('reseed preserves user edits and own checklist positions', () async {
    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final grounding =
        (await repository.listChecklistItems(
          projectId: 'project-1',
          stageId: 'state_zero',
        )).singleWhere(
          (item) =>
              item.templateKey == ChecklistTemplateKey.foundationGrounding,
        );
    await repository.updateChecklistItem(
      projectId: 'project-1',
      checklistItemId: grounding.id,
      input: ChecklistItemDetailsInput(
        status: ChecklistStatus.inProgress,
        importance: ChecklistImportance.critical,
        evidenceRequirement: grounding.evidenceRequirement,
        assignee: 'Elektryk',
        note: 'Układ zaakceptowany przed betonowaniem.',
        riskIfSkipped: 'Nie zakrywać bez pomiaru ciągłości.',
      ),
    );
    final ownItem = await repository.addChecklistItem(
      projectId: 'project-1',
      stageId: 'state_zero',
      title: 'Sprawdź rezerwę do ogrodu',
      input: ChecklistItemDetailsInput(
        status: ChecklistStatus.todo,
        importance: ChecklistImportance.high,
        evidenceRequirement: EvidenceRequirement.none,
        assignee: 'Elektryk',
        note: 'Potwierdzić oba końce przepustu.',
      ),
    );

    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final reloaded = await repository.listChecklistItems(
      projectId: 'project-1',
      stageId: 'state_zero',
    );
    final templateItem = reloaded.singleWhere(
      (item) => item.templateKey == ChecklistTemplateKey.foundationGrounding,
    );
    final reloadedOwnItem = reloaded.singleWhere(
      (item) => item.id == ownItem.id,
    );

    expect(templateItem.status, ChecklistStatus.inProgress);
    expect(templateItem.importance, ChecklistImportance.critical);
    expect(templateItem.assignee, 'Elektryk');
    expect(templateItem.note, 'Układ zaakceptowany przed betonowaniem.');
    expect(templateItem.riskIfSkipped, 'Nie zakrywać bez pomiaru ciągłości.');
    expect(reloadedOwnItem.customTitle, 'Sprawdź rezerwę do ogrodu');
    expect(reloadedOwnItem.assignee, 'Elektryk');
    expect(reloadedOwnItem.note, 'Potwierdzić oba końce przepustu.');
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
    expect(stage.progress.totalItems, 16);
  });

  test('documented waiver is an explicit alternative to evidence', () async {
    await repository.listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final item =
        (await repository.listChecklistItems(
          projectId: 'project-1',
          stageId: 'formalities',
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

  test(
    'bulk completion is atomic when one item still requires evidence',
    () async {
      await repository.listStages(
        projectId: 'project-1',
        template: ProjectTemplate.houseConstruction,
      );
      final items = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'formalities',
      );
      final quickItem = items.singleWhere(
        (item) => item.templateKey == ChecklistTemplateKey.houseDesignSelection,
      );
      final evidenceItem = items.singleWhere(
        (item) =>
            item.templateKey == ChecklistTemplateKey.planningPermissionBasis,
      );

      await expectLater(
        repository.completeChecklistItems(
          projectId: 'project-1',
          checklistItemIds: <String>[quickItem.id, evidenceItem.id],
        ),
        throwsA(isA<ChecklistEvidenceRequiredException>()),
      );

      final unchanged = await repository.listChecklistItems(
        projectId: 'project-1',
        stageId: 'formalities',
      );
      expect(
        unchanged.singleWhere((item) => item.id == quickItem.id).status,
        ChecklistStatus.todo,
      );

      final completed = await repository.completeChecklistItems(
        projectId: 'project-1',
        checklistItemIds: <String>[quickItem.id],
      );
      expect(completed.single.status, ChecklistStatus.completed);
    },
  );

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
