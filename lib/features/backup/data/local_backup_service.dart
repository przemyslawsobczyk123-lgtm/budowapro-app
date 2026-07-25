import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/backup/domain/backup_models.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'backup_archive_format.dart';

typedef BackupDirectoryProvider = Future<Directory> Function();

final class LocalBackupArtifact {
  const LocalBackupArtifact({required this.file, required this.preview});

  final File file;
  final BackupPreview preview;
}

final class LocalBackupService {
  factory LocalBackupService({
    required AppDatabase database,
    required ProjectFileStore fileStore,
    required BackupDirectoryProvider outputDirectoryProvider,
    required DateTime Function() utcNow,
    required String Function() idGenerator,
  }) {
    return LocalBackupService._(
      database,
      fileStore,
      outputDirectoryProvider,
      utcNow,
      idGenerator,
    );
  }

  const LocalBackupService._(
    this._database,
    this._fileStore,
    this._outputDirectoryProvider,
    this._utcNow,
    this._idGenerator,
  );

  final AppDatabase _database;
  final ProjectFileStore _fileStore;
  final BackupDirectoryProvider _outputDirectoryProvider;
  final DateTime Function() _utcNow;
  final String Function() _idGenerator;

  Future<LocalBackupArtifact> createBackup() async {
    final createdAtUtc = _utcNow().toUtc();
    final operationId = _validSegment(_idGenerator(), 'operationId');
    final root = _fileStore.rootDirectory;
    final workDirectory = Directory(
      p.join(root.path, '.budowapro-backup-work', operationId),
    );
    final snapshot = File(
      p.join(workDirectory.path, 'database', AppDatabase.databaseFileName),
    );
    final outputDirectory = await _outputDirectoryProvider();
    await outputDirectory.create(recursive: true);
    final archiveFile = File(
      p.join(outputDirectory.path, _backupFileName(createdAtUtc, operationId)),
    );

    try {
      return await _fileStore.runMaintenance(() {
        return _database.runMaintenance((database) async {
          await database.createSnapshot(snapshot);
          final activeDatabase = await database.reopen();
          final projectRows = await activeDatabase.rawQuery(
            'SELECT COUNT(*) AS total FROM ${AppDatabase.projectsTable}',
          );
          final projectCount = projectRows.single['total']! as int;
          final build = await _buildArchiveInIsolate(
            _ArchiveBuildRequest(
              rootPath: root.path,
              snapshotPath: snapshot.path,
              workPath: workDirectory.path,
              outputPath: archiveFile.path,
              createdAtIso: createdAtUtc.toIso8601String(),
              schemaVersion: AppDatabase.schemaVersion,
              projectCount: projectCount,
            ),
          );
          return LocalBackupArtifact(
            file: archiveFile,
            preview: BackupPreview(
              createdAt: createdAtUtc,
              schemaVersion: AppDatabase.schemaVersion,
              projectCount: projectCount,
              payloadFileCount: build.payloadFileCount,
              payloadBytes: build.payloadBytes,
            ),
          );
        });
      });
    } on Object catch (error, stackTrace) {
      await _deleteFileIfPresent(archiveFile);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      await _deleteDirectoryIfPresent(workDirectory);
    }
  }
}

Future<_ArchiveBuildResult> _buildArchiveInIsolate(
  _ArchiveBuildRequest request,
) {
  return Isolate.run(() => _buildArchive(request));
}

Future<_ArchiveBuildResult> _buildArchive(_ArchiveBuildRequest request) async {
  final payload = <String, File>{
    backupDatabasePath: File(request.snapshotPath),
    ...await _projectPayload(Directory(p.join(request.rootPath, 'projects'))),
  };
  final checksumEntries = <BackupChecksumEntry>[];
  var payloadBytes = 0;
  final paths = payload.keys.toList(growable: false)..sort();
  for (final archivePath in paths) {
    final file = payload[archivePath]!;
    final byteSize = await file.length();
    final digest = await sha256.bind(file.openRead()).first;
    checksumEntries.add(
      BackupChecksumEntry(
        path: archivePath,
        byteSize: byteSize,
        sha256: digest.toString(),
      ),
    );
    payloadBytes += byteSize;
  }

  final manifest = BackupManifest(
    createdAtUtc: DateTime.parse(request.createdAtIso),
    schemaVersion: request.schemaVersion,
    projectCount: request.projectCount,
    payloadFileCount: payload.length,
    payloadBytes: payloadBytes,
  );
  final catalog = BackupChecksumCatalog(checksumEntries);
  final manifestFile = File(p.join(request.workPath, backupManifestPath));
  final checksumsFile = File(p.join(request.workPath, backupChecksumsPath));
  await manifestFile.writeAsString(
    jsonEncode(manifest.toJson()),
    encoding: utf8,
    flush: true,
  );
  await checksumsFile.writeAsString(
    jsonEncode(catalog.toJson()),
    encoding: utf8,
    flush: true,
  );

  final encoder = ZipFileEncoder();
  encoder.create(request.outputPath, level: 6, modified: manifest.createdAtUtc);
  try {
    await encoder.addFile(manifestFile, backupManifestPath, 6);
    await encoder.addFile(checksumsFile, backupChecksumsPath, 6);
    for (final archivePath in paths) {
      await encoder.addFile(payload[archivePath]!, archivePath, 6);
    }
  } finally {
    await encoder.close();
  }
  return _ArchiveBuildResult(
    payloadFileCount: payload.length,
    payloadBytes: payloadBytes,
  );
}

final class _ArchiveBuildRequest {
  const _ArchiveBuildRequest({
    required this.rootPath,
    required this.snapshotPath,
    required this.workPath,
    required this.outputPath,
    required this.createdAtIso,
    required this.schemaVersion,
    required this.projectCount,
  });

  final String rootPath;
  final String snapshotPath;
  final String workPath;
  final String outputPath;
  final String createdAtIso;
  final int schemaVersion;
  final int projectCount;
}

Future<Map<String, File>> _projectPayload(Directory projectsRoot) async {
  final rootType = await FileSystemEntity.type(
    projectsRoot.path,
    followLinks: false,
  );
  if (rootType == FileSystemEntityType.notFound) {
    return const <String, File>{};
  }
  if (rootType != FileSystemEntityType.directory) {
    throw const FileSystemException('Projects storage is not a directory');
  }

  final payload = <String, File>{};
  await for (final entity in projectsRoot.list(
    recursive: true,
    followLinks: false,
  )) {
    final type = await FileSystemEntity.type(entity.path, followLinks: false);
    if (type == FileSystemEntityType.link) {
      throw const FileSystemException(
        'Projects storage contains a symbolic link',
      );
    }
    final relative = p.relative(entity.path, from: projectsRoot.path);
    final segments = p.split(relative);
    if (type == FileSystemEntityType.directory) {
      _validateProjectDirectorySegments(segments);
      continue;
    }
    if (type != FileSystemEntityType.file) {
      throw const FileSystemException('Unsupported project storage entry');
    }
    if (segments.length != 3) {
      throw const FileSystemException('Nested project files are unsupported');
    }
    final projectId = _validSegment(segments[0], 'projectId');
    final area = segments[1];
    if (!ProjectFileArea.values.any((value) => value.directoryName == area)) {
      throw const FileSystemException('Unsupported project file area');
    }
    final fileName = _validSegment(segments[2], 'fileName');
    if (fileName.endsWith('.part')) continue;
    final archivePath = p.posix.join('projects', projectId, area, fileName);
    if (payload.containsKey(archivePath)) {
      throw const FileSystemException('Duplicate project storage path');
    }
    payload[archivePath] = File(entity.path);
  }
  return payload;
}

void _validateProjectDirectorySegments(List<String> segments) {
  if (segments.isEmpty || segments.length > 2) {
    throw const FileSystemException('Invalid project storage directory');
  }
  _validSegment(segments[0], 'projectId');
  if (segments.length == 2 &&
      !ProjectFileArea.values.any(
        (value) => value.directoryName == segments[1],
      )) {
    throw const FileSystemException('Unsupported project file area');
  }
}

String _validSegment(String value, String argumentName) {
  if (value.isEmpty ||
      value == '.' ||
      value == '..' ||
      value.contains('/') ||
      value.contains(r'\') ||
      value.contains('\u0000') ||
      p.posix.isAbsolute(value) ||
      p.windows.isAbsolute(value)) {
    throw ArgumentError.value(value, argumentName, 'must be one path segment');
  }
  return value;
}

String _backupFileName(DateTime createdAtUtc, String operationId) {
  String two(int value) => value.toString().padLeft(2, '0');
  return 'budowapro-backup-'
      '${createdAtUtc.year}${two(createdAtUtc.month)}${two(createdAtUtc.day)}-'
      '${two(createdAtUtc.hour)}${two(createdAtUtc.minute)}'
      '${two(createdAtUtc.second)}-$operationId.zip';
}

Future<void> _deleteFileIfPresent(File file) async {
  try {
    if (await file.exists()) await file.delete();
  } on FileSystemException {
    // Best-effort cleanup must not replace the backup error.
  }
}

Future<void> _deleteDirectoryIfPresent(Directory directory) async {
  try {
    if (await directory.exists()) await directory.delete(recursive: true);
  } on FileSystemException {
    // Best-effort cleanup must not replace the backup error.
  }
}

final class _ArchiveBuildResult {
  const _ArchiveBuildResult({
    required this.payloadFileCount,
    required this.payloadBytes,
  });

  final int payloadFileCount;
  final int payloadBytes;
}
