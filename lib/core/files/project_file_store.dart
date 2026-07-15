import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ProjectFileArea {
  originals('originals'),
  previews('previews'),
  exports('exports');

  const ProjectFileArea(this.directoryName);

  final String directoryName;
}

final class ProjectFileStore {
  ProjectFileStore({required Directory rootDirectory})
    : _rootDirectory = rootDirectory.absolute;

  final Directory _rootDirectory;
  static final Set<String> _activeImportTargets = <String>{};

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

  Future<void> ensureProjectDirectories(String projectId) async {
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
  }) async {
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
      await ensureProjectDirectories(projectId);

      if (await _entityExists(target.path)) {
        await _deleteIfPresent(part);
        throw const FileSystemException('Target file already exists');
      }

      await _deleteIfPresent(part);

      await part.create(exclusive: true);
      ownsPart = true;
      await source.openRead().pipe(part.openWrite());

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
