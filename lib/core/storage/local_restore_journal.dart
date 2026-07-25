import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

enum LocalRestoreState { prepared, oldMoved, newMoved, committed }

final class LocalRestoreJournal {
  factory LocalRestoreJournal({
    required Directory rootDirectory,
    required String databaseFileName,
  }) {
    return LocalRestoreJournal._(rootDirectory.absolute, databaseFileName);
  }

  LocalRestoreJournal._(this._rootDirectory, this._databaseFileName);

  static const int journalVersion = 1;
  static const String journalFileName = '.budowapro-restore.json';
  static const String pendingJournalFileName =
      '.budowapro-restore-pending.json';
  static const String stageDirectoryName = '.budowapro-restore-stage';
  static const String oldDatabaseFileName = '.budowapro-restore-old.db';
  static const String oldProjectsDirectoryName =
      '.budowapro-restore-old-projects';

  final Directory _rootDirectory;
  final String _databaseFileName;

  File get journalFile => File(p.join(_rootDirectory.path, journalFileName));
  File get pendingJournalFile =>
      File(p.join(_rootDirectory.path, pendingJournalFileName));
  Directory get stageDirectory =>
      Directory(p.join(_rootDirectory.path, stageDirectoryName));
  File get stagedDatabase =>
      File(p.join(stageDirectory.path, 'database', _databaseFileName));
  Directory get stagedProjects =>
      Directory(p.join(stageDirectory.path, 'projects'));
  File get activeDatabase =>
      File(p.join(_rootDirectory.path, _databaseFileName));
  Directory get activeProjects =>
      Directory(p.join(_rootDirectory.path, 'projects'));
  File get oldDatabase =>
      File(p.join(_rootDirectory.path, oldDatabaseFileName));
  Directory get oldProjects =>
      Directory(p.join(_rootDirectory.path, oldProjectsDirectoryName));

  Future<void> prepare() async {
    await _rootDirectory.create(recursive: true);
    if (await hasPendingJournal() ||
        await _entityExists(oldDatabase.path) ||
        await _entityExists(oldProjects.path)) {
      throw const FileSystemException('Restore workspace is not clean');
    }
    if (await FileSystemEntity.type(stagedDatabase.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const FileSystemException('Staged database is missing');
    }
    final stagedProjectsType = await FileSystemEntity.type(
      stagedProjects.path,
      followLinks: false,
    );
    if (stagedProjectsType == FileSystemEntityType.notFound) {
      await stagedProjects.create(recursive: true);
    } else if (stagedProjectsType != FileSystemEntityType.directory) {
      throw const FileSystemException('Staged projects are invalid');
    }

    await _write(
      _JournalRecord(
        state: LocalRestoreState.prepared,
        hadDatabase: await _entityExists(activeDatabase.path),
        hadProjects: await _entityExists(activeProjects.path),
      ),
    );
  }

  Future<void> moveActiveToOld() async {
    final record = await _readExpected(LocalRestoreState.prepared);
    await _moveExistingFile(activeDatabase, oldDatabase);
    await _moveExistingDirectory(activeProjects, oldProjects);
    await _write(record.withState(LocalRestoreState.oldMoved));
  }

  Future<void> promoteStaged() async {
    final record = await _readExpected(LocalRestoreState.oldMoved);
    await stagedDatabase.rename(activeDatabase.path);
    await stagedProjects.rename(activeProjects.path);
    await _write(record.withState(LocalRestoreState.newMoved));
  }

  Future<void> markCommitted() async {
    final record = await _readExpected(LocalRestoreState.newMoved);
    await _write(record.withState(LocalRestoreState.committed));
  }

  Future<void> finishCommitted() async {
    final record = await _read();
    if (record.state != LocalRestoreState.committed) {
      throw const FileSystemException('Restore is not committed');
    }
    await _deleteFileIfPresent(oldDatabase);
    await _deleteDirectoryIfPresent(oldProjects);
    await _deleteDirectoryIfPresent(stageDirectory);
    await _deleteFileIfPresent(journalFile);
    await _deleteFileIfPresent(pendingJournalFile);
  }

  Future<void> rollback() async {
    final record = await _read();
    if (record.state == LocalRestoreState.committed) {
      throw const FileSystemException(
        'Committed restore cannot be rolled back',
      );
    }
    await _rollback(record);
  }

  Future<void> removeAbandonedStage() async {
    if (await hasPendingJournal()) {
      throw const FileSystemException('Restore journal requires recovery');
    }
    await _deleteDirectoryIfPresent(stageDirectory);
  }

  Future<bool> hasPendingJournal() async {
    return await journalFile.exists() || await pendingJournalFile.exists();
  }

  static Future<void> recover({
    required Directory rootDirectory,
    required String databaseFileName,
    Future<bool> Function(File database, Directory projects)? validateCommitted,
  }) async {
    final journal = LocalRestoreJournal(
      rootDirectory: rootDirectory,
      databaseFileName: databaseFileName,
    );
    if (!await journal.hasPendingJournal()) {
      await journal._recoverWithoutJournal();
      return;
    }

    late final _JournalRecord record;
    try {
      record = await journal._read();
    } on FileSystemException {
      await journal._rollbackUnknown();
      return;
    }
    if (record.state == LocalRestoreState.committed) {
      final activeLooksComplete = await journal._activeLooksComplete();
      final activeIsValid =
          activeLooksComplete &&
          (validateCommitted == null ||
              await validateCommitted(
                journal.activeDatabase,
                journal.activeProjects,
              ));
      if (activeIsValid) {
        await journal.finishCommitted();
      } else {
        await journal._deleteActiveSidecars();
        await journal._rollback(record);
      }
      return;
    }
    await journal._deleteActiveSidecars();
    await journal._rollback(record);
  }

  Future<void> _rollback(_JournalRecord record) async {
    await _restoreFile(
      active: activeDatabase,
      old: oldDatabase,
      hadActive: record.hadDatabase,
    );
    await _restoreDirectory(
      active: activeProjects,
      old: oldProjects,
      hadActive: record.hadProjects,
    );
    await _deleteDirectoryIfPresent(stageDirectory);
    await _deleteFileIfPresent(journalFile);
    await _deleteFileIfPresent(pendingJournalFile);
  }

  Future<void> _write(_JournalRecord record) async {
    final bytes = utf8.encode(jsonEncode(record.toJson()));
    await _deleteFileIfPresent(pendingJournalFile);
    final handle = await pendingJournalFile.open(mode: FileMode.writeOnly);
    try {
      await handle.writeFrom(bytes);
      await handle.flush();
    } finally {
      await handle.close();
    }
    await pendingJournalFile.rename(journalFile.path);
  }

  Future<_JournalRecord> _readExpected(LocalRestoreState state) async {
    final record = await _read();
    if (record.state != state) {
      throw const FileSystemException('Unexpected restore journal state');
    }
    return record;
  }

  Future<_JournalRecord> _read() async {
    final records = <_JournalRecord>[];
    for (final file in <File>[journalFile, pendingJournalFile]) {
      if (!await file.exists()) continue;
      try {
        final value = jsonDecode(await file.readAsString());
        if (value is! Map<String, Object?>) continue;
        records.add(_JournalRecord.fromJson(value));
      } on FormatException {
        // A second, flushed journal slot may still provide the latest state.
      }
    }
    if (records.isEmpty) {
      throw const FileSystemException('Restore journal is unreadable');
    }
    records.sort((left, right) => right.sequence.compareTo(left.sequence));
    return records.first;
  }

  Future<void> _recoverWithoutJournal() async {
    if (await _entityExists(oldDatabase.path) ||
        await _entityExists(oldProjects.path)) {
      await _rollbackUnknown();
      return;
    }
    await _deleteDirectoryIfPresent(stageDirectory);
    await _deleteFileIfPresent(pendingJournalFile);
  }

  Future<void> _rollbackUnknown() async {
    await _deleteActiveSidecars();
    await _restoreUnknownFile(active: activeDatabase, old: oldDatabase);
    await _restoreUnknownDirectory(active: activeProjects, old: oldProjects);
    await _deleteDirectoryIfPresent(stageDirectory);
    await _deleteFileIfPresent(journalFile);
    await _deleteFileIfPresent(pendingJournalFile);
  }

  Future<void> _restoreUnknownFile({
    required File active,
    required File old,
  }) async {
    final type = await FileSystemEntity.type(old.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.file) {
      throw const FileSystemException('Old database path is invalid');
    }
    await _deleteFileIfPresent(active);
    await old.rename(active.path);
  }

  Future<void> _restoreUnknownDirectory({
    required Directory active,
    required Directory old,
  }) async {
    final type = await FileSystemEntity.type(old.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.directory) {
      throw const FileSystemException('Old projects path is invalid');
    }
    await _deleteDirectoryIfPresent(active);
    await old.rename(active.path);
  }

  Future<bool> _activeLooksComplete() async {
    if (await FileSystemEntity.type(activeDatabase.path, followLinks: false) !=
        FileSystemEntityType.file) {
      return false;
    }
    if (await FileSystemEntity.type(activeProjects.path, followLinks: false) !=
        FileSystemEntityType.directory) {
      return false;
    }
    final handle = await activeDatabase.open();
    try {
      final bytes = await handle.read(16);
      return bytes.length == 16 &&
          utf8.decode(bytes, allowMalformed: true) == 'SQLite format 3\u0000';
    } finally {
      await handle.close();
    }
  }

  Future<void> _deleteActiveSidecars() async {
    for (final suffix in const <String>['-wal', '-shm', '-journal']) {
      await _deleteFileIfPresent(File('${activeDatabase.path}$suffix'));
    }
  }

  Future<void> _moveExistingFile(File source, File target) async {
    final type = await FileSystemEntity.type(source.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.file) {
      throw const FileSystemException('Active database path is invalid');
    }
    await source.rename(target.path);
  }

  Future<void> _moveExistingDirectory(
    Directory source,
    Directory target,
  ) async {
    final type = await FileSystemEntity.type(source.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.directory) {
      throw const FileSystemException('Active projects path is invalid');
    }
    await source.rename(target.path);
  }

  Future<void> _restoreFile({
    required File active,
    required File old,
    required bool hadActive,
  }) async {
    final oldType = await FileSystemEntity.type(old.path, followLinks: false);
    if (oldType == FileSystemEntityType.file) {
      await _deleteFileIfPresent(active);
      await old.rename(active.path);
      return;
    }
    if (oldType != FileSystemEntityType.notFound) {
      throw const FileSystemException('Old database path is invalid');
    }
    if (!hadActive) await _deleteFileIfPresent(active);
  }

  Future<void> _restoreDirectory({
    required Directory active,
    required Directory old,
    required bool hadActive,
  }) async {
    final oldType = await FileSystemEntity.type(old.path, followLinks: false);
    if (oldType == FileSystemEntityType.directory) {
      await _deleteDirectoryIfPresent(active);
      await old.rename(active.path);
      return;
    }
    if (oldType != FileSystemEntityType.notFound) {
      throw const FileSystemException('Old projects path is invalid');
    }
    if (!hadActive) await _deleteDirectoryIfPresent(active);
  }

  Future<void> _deleteFileIfPresent(File file) async {
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.file) {
      throw const FileSystemException('Expected a regular file');
    }
    await file.delete();
  }

  Future<void> _deleteDirectoryIfPresent(Directory directory) async {
    final type = await FileSystemEntity.type(
      directory.path,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.directory) {
      throw const FileSystemException('Expected a directory');
    }
    await directory.delete(recursive: true);
  }

  static Future<bool> _entityExists(String path) async {
    return await FileSystemEntity.type(path, followLinks: false) !=
        FileSystemEntityType.notFound;
  }
}

final class _JournalRecord {
  const _JournalRecord({
    required this.state,
    required this.hadDatabase,
    required this.hadProjects,
  });

  factory _JournalRecord.fromJson(Map<String, Object?> json) {
    const expected = <String>{
      'version',
      'sequence',
      'state',
      'hadDatabase',
      'hadProjects',
      'checksum',
    };
    if (json.keys.toSet().length != expected.length ||
        !json.keys.toSet().containsAll(expected) ||
        json['version'] != LocalRestoreJournal.journalVersion ||
        json['sequence'] is! int ||
        json['state'] is! String ||
        json['hadDatabase'] is! bool ||
        json['hadProjects'] is! bool ||
        json['checksum'] is! String) {
      throw const FormatException('Invalid restore journal fields');
    }
    final state = LocalRestoreState.values
        .where((value) => value.name == json['state'])
        .firstOrNull;
    if (state == null) {
      throw const FormatException('Invalid restore journal state');
    }
    final record = _JournalRecord(
      state: state,
      hadDatabase: json['hadDatabase']! as bool,
      hadProjects: json['hadProjects']! as bool,
    );
    if (json['sequence'] != record.sequence ||
        json['checksum'] != _checksum(record._payload)) {
      throw const FormatException('Invalid restore journal checksum');
    }
    return record;
  }

  final LocalRestoreState state;
  final bool hadDatabase;
  final bool hadProjects;
  int get sequence => state.index + 1;

  _JournalRecord withState(LocalRestoreState nextState) => _JournalRecord(
    state: nextState,
    hadDatabase: hadDatabase,
    hadProjects: hadProjects,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    ..._payload,
    'checksum': _checksum(_payload),
  };

  Map<String, Object?> get _payload => <String, Object?>{
    'version': LocalRestoreJournal.journalVersion,
    'sequence': sequence,
    'state': state.name,
    'hadDatabase': hadDatabase,
    'hadProjects': hadProjects,
  };

  static String _checksum(Map<String, Object?> payload) {
    return sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  }
}
