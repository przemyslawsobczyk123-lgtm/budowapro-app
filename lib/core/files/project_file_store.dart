import 'dart:io';

import 'package:budowapro/core/storage/local_data_maintenance_lock.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ProjectFileArea {
  originals('originals'),
  previews('previews'),
  exports('exports');

  const ProjectFileArea(this.directoryName);

  final String directoryName;
}

abstract interface class ProjectFileStorage {
  Future<int> countProjectFiles(String projectId);

  Future<void> deleteProjectFiles(String projectId);
}

final class ProjectFileStore implements ProjectFileStorage {
  ProjectFileStore({required Directory rootDirectory})
    : _rootDirectory = rootDirectory.absolute;

  final Directory _rootDirectory;
  final LocalDataMaintenanceLock _maintenanceLock = LocalDataMaintenanceLock();
  static final Set<String> _activeImportTargets = <String>{};

  Directory get rootDirectory => _rootDirectory;

  static Future<ProjectFileStore> createForDevice({
    Future<Directory> Function()? applicationSupportDirectory,
  }) async {
    final directoryProvider =
        applicationSupportDirectory ?? getApplicationSupportDirectory;
    return ProjectFileStore(rootDirectory: await directoryProvider());
  }

  Directory directoryFor({
    required String projectId,
    required ProjectFileArea area,
  }) {
    _validatePathSegment(projectId, argumentName: 'projectId');
    return Directory(
      p.join(_rootDirectory.path, 'projects', projectId, area.directoryName),
    );
  }

  File fileFor({
    required String projectId,
    required ProjectFileArea area,
    required String fileName,
  }) {
    _validatePathSegment(fileName, argumentName: 'fileName');
    return File(
      p.join(directoryFor(projectId: projectId, area: area).path, fileName),
    );
  }

  Future<void> ensureProjectDirectories(String projectId) {
    return _maintenanceLock.runOperation(
      () => _ensureProjectDirectories(projectId),
    );
  }

  Future<void> _ensureProjectDirectories(String projectId) async {
    _validatePathSegment(projectId, argumentName: 'projectId');
    await _rootDirectory.create(recursive: true);
    final resolvedRoot = p.normalize(
      await _rootDirectory.resolveSymbolicLinks(),
    );

    final projectsDirectory = Directory(
      p.join(_rootDirectory.path, 'projects'),
    );
    await _ensureContainedDirectory(projectsDirectory, resolvedRoot);

    final projectDirectory = Directory(
      p.join(projectsDirectory.path, projectId),
    );
    await _ensureContainedDirectory(projectDirectory, resolvedRoot);

    for (final area in ProjectFileArea.values) {
      await _ensureContainedDirectory(
        Directory(p.join(projectDirectory.path, area.directoryName)),
        resolvedRoot,
      );
    }
  }

  Future<File> importFile({
    required String projectId,
    required ProjectFileArea area,
    required File source,
    required String fileName,
    int? maximumBytes,
  }) {
    return _maintenanceLock.runOperation(
      () => _importFile(
        projectId: projectId,
        area: area,
        source: source,
        fileName: fileName,
        maximumBytes: maximumBytes,
      ),
    );
  }

  Future<File> _importFile({
    required String projectId,
    required ProjectFileArea area,
    required File source,
    required String fileName,
    int? maximumBytes,
  }) async {
    if (maximumBytes != null && maximumBytes < 0) {
      throw RangeError.value(maximumBytes, 'maximumBytes');
    }
    final target = fileFor(
      projectId: projectId,
      area: area,
      fileName: fileName,
    );
    final importKey = _importKey(target);
    if (!_activeImportTargets.add(importKey)) {
      throw const FileSystemException('Target import is already in progress');
    }

    final part = File('${target.path}.part');
    var ownsPart = false;

    try {
      await _ensureProjectDirectories(projectId);

      if (await _entityExists(target.path)) {
        await _deleteIfPresent(part);
        throw const FileSystemException('Target file already exists');
      }

      await _deleteIfPresent(part);

      await part.create(exclusive: true);
      ownsPart = true;
      final sink = part.openWrite();
      try {
        var copiedBytes = 0;
        await for (final chunk in source.openRead()) {
          copiedBytes += chunk.length;
          if (maximumBytes != null && copiedBytes > maximumBytes) {
            throw RangeError.value(
              copiedBytes,
              'source',
              'exceeds the import byte limit',
            );
          }
          sink.add(chunk);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      if (await _entityExists(target.path)) {
        throw const FileSystemException('Target file already exists');
      }

      return await part.rename(target.path);
    } catch (error, stackTrace) {
      if (ownsPart) {
        await _deleteIfPresent(part);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      _activeImportTargets.remove(importKey);
    }
  }

  Future<void> deleteFile({
    required String projectId,
    required ProjectFileArea area,
    required String fileName,
  }) {
    return _maintenanceLock.runOperation(
      () => _deleteFile(projectId: projectId, area: area, fileName: fileName),
    );
  }

  Future<void> _deleteFile({
    required String projectId,
    required ProjectFileArea area,
    required String fileName,
  }) async {
    final file = fileFor(projectId: projectId, area: area, fileName: fileName);
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      return;
    }
    if (type != FileSystemEntityType.file) {
      throw const FileSystemException('Stored project path is not a file');
    }
    await file.delete();
  }

  @override
  Future<int> countProjectFiles(String projectId) {
    return _maintenanceLock.runOperation(() => _countProjectFiles(projectId));
  }

  Future<int> _countProjectFiles(String projectId) async {
    final projectDirectory = await _existingProjectDirectory(projectId);
    if (projectDirectory == null) {
      return 0;
    }

    var count = 0;
    await for (final entity in projectDirectory.list(
      recursive: true,
      followLinks: false,
    )) {
      final type = await FileSystemEntity.type(entity.path, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw const FileSystemException(
          'Project files contain an unsupported symbolic link',
        );
      }
      if (type == FileSystemEntityType.file && !entity.path.endsWith('.part')) {
        count += 1;
      }
    }
    return count;
  }

  @override
  Future<void> deleteProjectFiles(String projectId) {
    return _maintenanceLock.runOperation(() => _deleteProjectFiles(projectId));
  }

  /// Removes every project attachment while preserving the application root.
  ///
  /// The maintenance lock prevents an import from racing with the destructive
  /// privacy reset operation.
  Future<void> deleteAllProjectFiles() {
    return _maintenanceLock.runMaintenance(_deleteAllProjectFiles);
  }

  Future<void> _deleteAllProjectFiles() async {
    if (!await _rootDirectory.exists()) {
      return;
    }

    final rootType = await FileSystemEntity.type(
      _rootDirectory.path,
      followLinks: false,
    );
    if (rootType != FileSystemEntityType.directory) {
      throw const FileSystemException(
        'Project storage root is not a directory',
      );
    }

    final projectsDirectory = Directory(
      p.join(_rootDirectory.path, 'projects'),
    );
    final projectsType = await FileSystemEntity.type(
      projectsDirectory.path,
      followLinks: false,
    );
    if (projectsType == FileSystemEntityType.notFound) {
      return;
    }
    if (projectsType != FileSystemEntityType.directory) {
      throw const FileSystemException('Project storage is not a directory');
    }

    final resolvedRoot = p.normalize(
      await _rootDirectory.resolveSymbolicLinks(),
    );
    final resolvedProjects = p.normalize(
      await projectsDirectory.resolveSymbolicLinks(),
    );
    if (!p.isWithin(resolvedRoot, resolvedProjects)) {
      throw const FileSystemException('Project storage escapes local storage');
    }

    await for (final entity in projectsDirectory.list(
      recursive: true,
      followLinks: false,
    )) {
      final type = await FileSystemEntity.type(entity.path, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw const FileSystemException(
          'Project storage contains an unsupported symbolic link',
        );
      }
    }
    await projectsDirectory.delete(recursive: true);
  }

  Future<void> _deleteProjectFiles(String projectId) async {
    final projectDirectory = await _existingProjectDirectory(projectId);
    if (projectDirectory == null) {
      return;
    }

    await for (final entity in projectDirectory.list(
      recursive: true,
      followLinks: false,
    )) {
      final type = await FileSystemEntity.type(entity.path, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw const FileSystemException(
          'Project files contain an unsupported symbolic link',
        );
      }
    }
    await projectDirectory.delete(recursive: true);
  }

  Future<T> runMaintenance<T>(Future<T> Function() action) {
    return _maintenanceLock.runMaintenance(action);
  }

  Future<Directory?> _existingProjectDirectory(String projectId) async {
    _validatePathSegment(projectId, argumentName: 'projectId');
    if (!await _rootDirectory.exists()) {
      return null;
    }

    final projectDirectory = directoryFor(
      projectId: projectId,
      area: ProjectFileArea.originals,
    ).parent;
    final type = await FileSystemEntity.type(
      projectDirectory.path,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) {
      return null;
    }
    if (type != FileSystemEntityType.directory) {
      throw const FileSystemException('Project path is not a directory');
    }

    final resolvedRoot = p.normalize(
      await _rootDirectory.resolveSymbolicLinks(),
    );
    final resolvedProject = p.normalize(
      await projectDirectory.resolveSymbolicLinks(),
    );
    if (!p.isWithin(resolvedRoot, resolvedProject)) {
      throw const FileSystemException('Project path escapes local storage');
    }
    return projectDirectory;
  }

  static Future<void> _ensureContainedDirectory(
    Directory directory,
    String resolvedRoot,
  ) async {
    var type = await FileSystemEntity.type(directory.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      await directory.create();
      type = await FileSystemEntity.type(directory.path, followLinks: false);
    }

    if (type != FileSystemEntityType.directory) {
      throw const FileSystemException('Project path is not a directory');
    }

    final resolvedDirectory = p.normalize(
      await directory.resolveSymbolicLinks(),
    );
    if (!p.isWithin(resolvedRoot, resolvedDirectory)) {
      throw const FileSystemException('Project path escapes local storage');
    }
  }

  static String _importKey(File target) {
    final normalized = p.normalize(target.absolute.path);
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static Future<bool> _entityExists(String path) async {
    return await FileSystemEntity.type(path, followLinks: false) !=
        FileSystemEntityType.notFound;
  }

  static Future<void> _deleteIfPresent(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // Preserve the import error when best-effort cleanup cannot complete.
    }
  }

  static void _validatePathSegment(
    String value, {
    required String argumentName,
  }) {
    final isInvalid =
        value.isEmpty ||
        value == '.' ||
        value == '..' ||
        value.contains('/') ||
        value.contains(r'\') ||
        value.contains('\u0000') ||
        p.posix.isAbsolute(value) ||
        p.windows.isAbsolute(value);

    if (isInvalid) {
      throw ArgumentError.value(
        value,
        argumentName,
        'Must be one path segment',
      );
    }
  }
}
