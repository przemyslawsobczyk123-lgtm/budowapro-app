import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/core/storage/local_restore_journal.dart';
import 'package:budowapro/core/storage/storage_capacity_probe.dart';
import 'package:budowapro/features/backup/domain/backup_models.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'backup_archive_reader.dart';
import 'backup_archive_format.dart';

typedef BackupDirectoryProvider = Future<Directory> Function();

final class LocalBackupArtifact {
  const LocalBackupArtifact({required this.file, required this.preview});

  final File file;
  final BackupPreview preview;
}

final class LocalBackupCandidate {
  const LocalBackupCandidate({
    required this.file,
    required this.preview,
    required this.inspection,
    required this.archiveSha256,
  });

  final File file;
  final BackupPreview preview;
  final BackupArchiveInspection inspection;
  final String archiveSha256;
}

final class LocalBackupService {
  factory LocalBackupService({
    required AppDatabase database,
    required ProjectFileStore fileStore,
    required BackupDirectoryProvider outputDirectoryProvider,
    required DateTime Function() utcNow,
    required String Function() idGenerator,
    StorageCapacityProbe storageCapacityProbe =
        const PlatformStorageCapacityProbe(),
  }) {
    return LocalBackupService._(
      database,
      fileStore,
      outputDirectoryProvider,
      utcNow,
      idGenerator,
      storageCapacityProbe,
    );
  }

  const LocalBackupService._(
    this._database,
    this._fileStore,
    this._outputDirectoryProvider,
    this._utcNow,
    this._idGenerator,
    this._storageCapacityProbe,
  );

  static const int restoreSafetyMarginBytes = 64 * 1024 * 1024;

  final AppDatabase _database;
  final ProjectFileStore _fileStore;
  final BackupDirectoryProvider _outputDirectoryProvider;
  final DateTime Function() _utcNow;
  final String Function() _idGenerator;
  final StorageCapacityProbe _storageCapacityProbe;

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
          if (projectCount > 10000) {
            throw const FileSystemException(
              'Project count exceeds the backup limit',
            );
          }
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

  Future<LocalBackupCandidate> inspectBackup(File archiveFile) async {
    final operationId = _validSegment(_idGenerator(), 'operationId');
    final candidateDirectory = Directory(
      p.join(_fileStore.rootDirectory.path, '.budowapro-restore-candidates'),
    );
    await candidateDirectory.create(recursive: true);
    final privateArchive = File(
      p.join(candidateDirectory.path, 'candidate-$operationId.zip'),
    );
    try {
      final archiveSha256 = await _copyBackupCandidateInIsolate(
        _CandidateCopyRequest(
          sourcePath: archiveFile.absolute.path,
          destinationPath: privateArchive.path,
        ),
      );
      final inspection = await inspectBackupArchive(privateArchive);
      if (inspection.manifest.schemaVersion > AppDatabase.schemaVersion) {
        throw const FormatException(
          'Backup was created by a newer app version',
        );
      }
      final candidateToken = sha256
          .convert(utf8.encode('$archiveSha256:${inspection.signature}'))
          .toString();
      return LocalBackupCandidate(
        file: privateArchive,
        preview: _previewFromInspection(
          inspection,
          candidateToken: candidateToken,
        ),
        inspection: inspection,
        archiveSha256: archiveSha256,
      );
    } on Object catch (error, stackTrace) {
      await _deleteFileIfPresent(privateArchive);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> discardCandidate(LocalBackupCandidate candidate) {
    return _deleteFileIfPresent(candidate.file);
  }

  Future<BackupPreview> restoreBackup(LocalBackupCandidate candidate) async {
    final root = _fileStore.rootDirectory;
    final journal = LocalRestoreJournal(
      rootDirectory: root,
      databaseFileName: AppDatabase.databaseFileName,
    );
    if (await journal.hasPendingJournal()) {
      throw const FileSystemException(
        'An interrupted restore must be recovered on app startup',
      );
    }
    await journal.removeAbandonedStage();

    final currentArchiveSha256 = await _sha256FileInIsolate(candidate.file);
    if (currentArchiveSha256 != candidate.archiveSha256) {
      throw const FormatException('Backup changed after it was selected');
    }
    final currentInspection = await inspectBackupArchive(candidate.file);
    if (currentInspection.signature != candidate.inspection.signature) {
      throw const FormatException('Backup changed after it was selected');
    }
    if (currentInspection.manifest.schemaVersion > AppDatabase.schemaVersion) {
      throw const FormatException('Backup was created by a newer app version');
    }

    final availableBytes = await _storageCapacityProbe.availableBytes(root);
    final requiredBytes =
        currentInspection.manifest.payloadBytes + restoreSafetyMarginBytes;
    if (availableBytes < requiredBytes) {
      throw const FileSystemException(
        'There is not enough free storage to restore this backup',
      );
    }

    try {
      final extractedInspection = await extractBackupArchive(
        archiveFile: candidate.file,
        stageDirectory: journal.stageDirectory,
      );
      if (extractedInspection.signature != currentInspection.signature) {
        throw const FormatException('Backup changed during extraction');
      }
      final databaseInspection = await _database.prepareRestoreCandidate(
        databaseFile: journal.stagedDatabase,
        sourceSchemaVersion: extractedInspection.manifest.schemaVersion,
        expectedProjectCount: extractedInspection.manifest.projectCount,
      );
      await _validateStagedFiles(
        journal: journal,
        archive: extractedInspection,
        database: databaseInspection,
      );

      await _fileStore.runMaintenance(() {
        return _database.runMaintenance((maintenance) async {
          await maintenance.deleteSidecarFiles();
          await journal.prepare();
          try {
            await journal.moveActiveToOld();
            await journal.promoteStaged();
            final promotedDatabase = await maintenance.reopen();
            final quickCheck = await promotedDatabase.rawQuery(
              'PRAGMA quick_check',
            );
            if (quickCheck.isEmpty ||
                quickCheck.any(
                  (row) => row.values.length != 1 || row.values.single != 'ok',
                ) ||
                (await promotedDatabase.rawQuery(
                  'PRAGMA foreign_key_check',
                )).isNotEmpty) {
              throw const FormatException(
                'Restored database verification failed',
              );
            }
            await maintenance.close();
            await journal.markCommitted();
            try {
              await journal.finishCommitted();
            } on FileSystemException {
              // A committed journal is finalized safely during app startup.
            }
          } on Object catch (error, stackTrace) {
            await maintenance.close();
            await maintenance.deleteSidecarFiles();
            await journal.rollback();
            Error.throwWithStackTrace(error, stackTrace);
          }
        });
      });

      await discardCandidate(candidate);
      return _previewFromInspection(
        currentInspection,
        candidateToken: candidate.preview.candidateToken,
      );
    } on Object catch (error, stackTrace) {
      if (!await journal.hasPendingJournal()) {
        await journal.removeAbandonedStage();
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

BackupPreview _previewFromInspection(
  BackupArchiveInspection inspection, {
  String? candidateToken,
}) {
  final manifest = inspection.manifest;
  return BackupPreview(
    createdAt: manifest.createdAtUtc,
    schemaVersion: manifest.schemaVersion,
    projectCount: manifest.projectCount,
    payloadFileCount: manifest.payloadFileCount,
    payloadBytes: manifest.payloadBytes,
    candidateToken: candidateToken ?? inspection.signature,
  );
}

Future<String> _copyBackupCandidateInIsolate(_CandidateCopyRequest request) {
  return Isolate.run(() => _copyBackupCandidate(request));
}

Future<String> _copyBackupCandidate(_CandidateCopyRequest request) async {
  final sourceType = await FileSystemEntity.type(
    request.sourcePath,
    followLinks: false,
  );
  if (sourceType != FileSystemEntityType.file) {
    throw const FormatException('Backup must be a regular file');
  }
  final source = File(request.sourcePath);
  final sourceLength = await source.length();
  if (sourceLength < 22 || sourceLength > maximumBackupArchiveBytes) {
    throw const FormatException('Backup archive size is unsupported');
  }

  final destination = File(request.destinationPath);
  await destination.create(exclusive: true);
  final sink = destination.openWrite(mode: FileMode.writeOnly);
  var copiedBytes = 0;
  try {
    await for (final chunk in source.openRead()) {
      copiedBytes += chunk.length;
      if (copiedBytes > maximumBackupArchiveBytes) {
        throw const FormatException('Backup archive size is unsupported');
      }
      sink.add(chunk);
    }
    await sink.flush();
  } on Object catch (error, stackTrace) {
    await sink.close();
    await _deleteFileIfPresent(destination);
    Error.throwWithStackTrace(error, stackTrace);
  }
  await sink.close();
  if (copiedBytes != sourceLength ||
      await destination.length() != sourceLength) {
    await _deleteFileIfPresent(destination);
    throw const FormatException('Backup changed while it was being copied');
  }
  final digest = await sha256.bind(destination.openRead()).first;
  return digest.toString();
}

Future<String> _sha256FileInIsolate(File file) {
  final path = file.absolute.path;
  return Isolate.run(() async {
    final digest = await sha256.bind(File(path).openRead()).first;
    return digest.toString();
  });
}

Future<void> _validateStagedFiles({
  required LocalRestoreJournal journal,
  required BackupArchiveInspection archive,
  required DatabaseRestoreInspection database,
}) async {
  if (database.schemaVersion != AppDatabase.schemaVersion ||
      archive.manifest.schemaVersion > database.schemaVersion ||
      database.projectIds.length != archive.manifest.projectCount ||
      !database.projectIds.containsAll(archive.projectIds)) {
    throw const FormatException(
      'Backup project data does not match its manifest',
    );
  }

  final checksums = <String, BackupChecksumEntry>{
    for (final entry in archive.checksums.entries) entry.path: entry,
  };
  for (final attachment in database.attachments) {
    final originalPath = p.posix.join(
      'projects',
      attachment.projectId,
      ProjectFileArea.originals.directoryName,
      attachment.originalStorageKey,
    );
    final original = checksums[originalPath];
    if (attachment.isAvailable) {
      if (original == null ||
          original.byteSize != attachment.byteSize ||
          (attachment.sha256 != null && attachment.sha256 != original.sha256)) {
        throw const FormatException(
          'Backup is missing an available attachment',
        );
      }
    }

    final previewKey = attachment.previewStorageKey;
    if (previewKey != null) {
      final previewPath = p.posix.join(
        'projects',
        attachment.projectId,
        ProjectFileArea.previews.directoryName,
        previewKey,
      );
      if (!checksums.containsKey(previewPath)) {
        throw const FormatException('Backup is missing an attachment preview');
      }
    }
  }

  final stagedProjectsType = await FileSystemEntity.type(
    journal.stagedProjects.path,
    followLinks: false,
  );
  if (stagedProjectsType == FileSystemEntityType.notFound) {
    await journal.stagedProjects.create(recursive: true);
  } else if (stagedProjectsType != FileSystemEntityType.directory) {
    throw const FormatException('Staged project storage is invalid');
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
  if (paths.length + 2 > maximumBackupEntryCount) {
    throw const FileSystemException('Backup contains too many files');
  }
  for (final archivePath in paths) {
    final file = payload[archivePath]!;
    final byteSize = await file.length();
    if (byteSize > maximumBackupEntryBytes) {
      throw const FileSystemException('Backup file exceeds the size limit');
    }
    final digest = await sha256.bind(file.openRead()).first;
    checksumEntries.add(
      BackupChecksumEntry(
        path: archivePath,
        byteSize: byteSize,
        sha256: digest.toString(),
      ),
    );
    payloadBytes += byteSize;
    if (payloadBytes > maximumBackupPayloadBytes) {
      throw const FileSystemException('Backup payload exceeds the size limit');
    }
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
  if (await File(request.outputPath).length() > maximumBackupArchiveBytes) {
    throw const FileSystemException('Backup archive exceeds the size limit');
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

final class _CandidateCopyRequest {
  const _CandidateCopyRequest({
    required this.sourcePath,
    required this.destinationPath,
  });

  final String sourcePath;
  final String destinationPath;
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
