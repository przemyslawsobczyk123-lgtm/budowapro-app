import 'dart:io';

import 'package:budowapro/core/storage/local_restore_journal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const oldDatabaseContent = 'SQLite format 3\u0000old-database';
const newDatabaseContent = 'SQLite format 3\u0000new-database';

void main() {
  late Directory root;
  late LocalRestoreJournal journal;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_restore_journal_');
    journal = LocalRestoreJournal(
      rootDirectory: root,
      databaseFileName: 'budowapro.db',
    );
    await journal.activeDatabase.writeAsString(oldDatabaseContent);
    await journal.activeProjects.create();
    await File(
      p.join(journal.activeProjects.path, 'old.txt'),
    ).writeAsString('old-projects');
    await journal.stagedDatabase.parent.create(recursive: true);
    await journal.stagedDatabase.writeAsString(newDatabaseContent);
    await journal.stagedProjects.create();
    await File(
      p.join(journal.stagedProjects.path, 'new.txt'),
    ).writeAsString('new-projects');
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test('rolls back a promoted restore after an interrupted run', () async {
    await journal.prepare();
    await journal.moveActiveToOld();
    await journal.promoteStaged();

    await LocalRestoreJournal.recover(
      rootDirectory: root,
      databaseFileName: 'budowapro.db',
    );

    expect(await journal.activeDatabase.readAsString(), oldDatabaseContent);
    expect(
      await File(p.join(journal.activeProjects.path, 'old.txt')).readAsString(),
      'old-projects',
    );
    expect(await journal.journalFile.exists(), isFalse);
    expect(await journal.oldDatabase.exists(), isFalse);
    expect(await journal.stageDirectory.exists(), isFalse);
  });

  test('finalizes a committed restore after an interrupted cleanup', () async {
    await journal.prepare();
    await journal.moveActiveToOld();
    await journal.promoteStaged();
    await journal.markCommitted();

    await LocalRestoreJournal.recover(
      rootDirectory: root,
      databaseFileName: 'budowapro.db',
    );

    expect(await journal.activeDatabase.readAsString(), newDatabaseContent);
    expect(
      await File(p.join(journal.activeProjects.path, 'new.txt')).readAsString(),
      'new-projects',
    );
    expect(await journal.journalFile.exists(), isFalse);
    expect(await journal.oldDatabase.exists(), isFalse);
    expect(await journal.stageDirectory.exists(), isFalse);
  });

  test('rolls back a committed restore when active validation fails', () async {
    await journal.prepare();
    await journal.moveActiveToOld();
    await journal.promoteStaged();
    await journal.markCommitted();

    await LocalRestoreJournal.recover(
      rootDirectory: root,
      databaseFileName: 'budowapro.db',
      validateCommitted: (database, projects) async => false,
    );

    expect(await journal.activeDatabase.readAsString(), oldDatabaseContent);
    expect(
      await File(p.join(journal.activeProjects.path, 'old.txt')).readAsString(),
      'old-projects',
    );
  });

  test('restores an active database when only old data was moved', () async {
    await journal.prepare();
    await journal.moveActiveToOld();

    await LocalRestoreJournal.recover(
      rootDirectory: root,
      databaseFileName: 'budowapro.db',
    );

    expect(await journal.activeDatabase.readAsString(), oldDatabaseContent);
    expect(
      await File(p.join(journal.activeProjects.path, 'old.txt')).readAsString(),
      'old-projects',
    );
  });

  test('rolls back old data when the journal marker is missing', () async {
    await journal.prepare();
    await journal.moveActiveToOld();
    await journal.journalFile.delete();

    await LocalRestoreJournal.recover(
      rootDirectory: root,
      databaseFileName: 'budowapro.db',
    );

    expect(await journal.activeDatabase.readAsString(), oldDatabaseContent);
    expect(
      await File(p.join(journal.activeProjects.path, 'old.txt')).readAsString(),
      'old-projects',
    );
  });

  test('uses old data when every journal slot is corrupt', () async {
    await journal.prepare();
    await journal.moveActiveToOld();
    await journal.promoteStaged();
    await journal.journalFile.writeAsString('{', flush: true);

    await LocalRestoreJournal.recover(
      rootDirectory: root,
      databaseFileName: 'budowapro.db',
    );

    expect(await journal.activeDatabase.readAsString(), oldDatabaseContent);
    expect(await journal.journalFile.exists(), isFalse);
  });
}
