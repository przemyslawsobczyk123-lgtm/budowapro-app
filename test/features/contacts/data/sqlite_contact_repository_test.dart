import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/contacts/data/sqlite_contact_repository.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
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
  late SqliteContactRepository repository;
  var nextId = 0;
  var nextMinute = 0;

  DateTime utcNow() => DateTime.utc(2026, 7, 21, 10, nextMinute++);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_contact_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: utcNow,
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
      idGenerator: () => 'stage-generated-${++nextId}',
      utcNow: utcNow,
    ).listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    repository = SqliteContactRepository(
      database: database,
      idGenerator: () => 'contact-${++nextId}',
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

  test('round-trips contact roles and stage assignments', () async {
    final created = await repository.create(
      projectId: 'project-1',
      draft: _draft(
        roles: const <ContactRole>{
          ContactRole.electrician,
          ContactRole.generalContractor,
        },
        stageIds: const <String>{'state_zero', 'installations'},
      ),
    );

    final loaded = await repository.findById(
      projectId: 'project-1',
      contactId: created.id,
    );

    expect(loaded?.displayName, 'Instal-Pro');
    expect(loaded?.roles, <ContactRole>{
      ContactRole.electrician,
      ContactRole.generalContractor,
    });
    expect(loaded?.stageIds, <String>{'state_zero', 'installations'});
    expect(loaded?.createdAtUtc, created.createdAtUtc);
  });

  test('filters by normalized search, role and stage', () async {
    await repository.create(
      projectId: 'project-1',
      draft: _draft(stageIds: const <String>{'installations'}),
    );
    await repository.create(
      projectId: 'project-1',
      draft: ContactDraft(
        displayName: 'Dach-Bud',
        kind: ContactKind.company,
        roles: const <ContactRole>{ContactRole.roofer},
        stageIds: const <String>{'shell_open'},
      ),
    );

    final page = await repository.list(
      ContactQuery(
        projectId: 'project-1',
        searchTerm: 'INSTAL',
        role: ContactRole.electrician,
        stageId: 'installations',
      ),
      PageRequest(),
    );

    expect(page.totalCount, 1);
    expect(page.items.single.displayName, 'Instal-Pro');
  });

  test(
    'updates relation sets and hides archived contacts by default',
    () async {
      final created = await repository.create(
        projectId: 'project-1',
        draft: _draft(stageIds: const <String>{'state_zero'}),
      );
      final updated = await repository.update(
        projectId: 'project-1',
        contactId: created.id,
        draft: ContactDraft(
          displayName: 'Instal-Pro 2',
          kind: ContactKind.company,
          roles: const <ContactRole>{ContactRole.plumber},
          stageIds: const <String>{'installations'},
        ),
      );
      await repository.setArchived(
        projectId: 'project-1',
        contactId: created.id,
        isArchived: true,
      );

      expect(updated.roles, <ContactRole>{ContactRole.plumber});
      expect(updated.stageIds, <String>{'installations'});
      expect(
        (await repository.list(
          ContactQuery(projectId: 'project-1'),
          PageRequest(),
        )).items,
        isEmpty,
      );
      expect(
        (await repository.list(
          ContactQuery(projectId: 'project-1', includeArchived: true),
          PageRequest(),
        )).items.single.isArchived,
        isTrue,
      );
    },
  );
}

ContactDraft _draft({
  Set<ContactRole> roles = const <ContactRole>{ContactRole.electrician},
  Set<String> stageIds = const <String>{},
}) {
  return ContactDraft(
    displayName: 'Instal-Pro',
    kind: ContactKind.company,
    roles: roles,
    stageIds: stageIds,
    phone: '+48 500 600 700',
    email: 'biuro@instal-pro.pl',
  );
}
