import 'dart:io';

import 'package:path/path.dart' as p;

abstract final class LocalDataWipeJournal {
  static const String markerFileName = '.budowapro_pending_wipe';
  static const String _markerContents = 'budowapro-wipe-v1';

  static File markerFor(Directory rootDirectory) {
    return File(p.join(rootDirectory.absolute.path, markerFileName));
  }

  static Future<File> prepare(Directory rootDirectory) async {
    final root = rootDirectory.absolute;
    await root.create(recursive: true);
    if (await FileSystemEntity.type(root.path, followLinks: false) !=
        FileSystemEntityType.directory) {
      throw const FileSystemException('Application storage is not a directory');
    }
    final marker = markerFor(root);
    final type = await FileSystemEntity.type(marker.path, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.file) {
      throw const FileSystemException('Data wipe marker is invalid');
    }
    await marker.writeAsString(_markerContents, flush: true);
    return marker;
  }

  static Future<bool> recover({
    required Directory rootDirectory,
    required String databaseFileName,
  }) async {
    final root = rootDirectory.absolute;
    final marker = markerFor(root);
    final markerType = await FileSystemEntity.type(
      marker.path,
      followLinks: false,
    );
    if (markerType == FileSystemEntityType.notFound) return false;
    if (markerType != FileSystemEntityType.file ||
        await marker.readAsString() != _markerContents) {
      throw const FileSystemException('Data wipe marker is invalid');
    }

    await _deleteFileIfPresent(File(p.join(root.path, databaseFileName)));
    for (final suffix in const <String>['-wal', '-shm', '-journal']) {
      await _deleteFileIfPresent(
        File(p.join(root.path, '$databaseFileName$suffix')),
      );
    }
    await _deleteProjectsIfPresent(root);
    await marker.delete();
    return true;
  }

  static Future<void> _deleteFileIfPresent(File file) async {
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.file) {
      throw const FileSystemException('Wipe target is not a regular file');
    }
    await file.delete();
  }

  static Future<void> _deleteProjectsIfPresent(Directory root) async {
    final projects = Directory(p.join(root.path, 'projects'));
    final type = await FileSystemEntity.type(projects.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.directory) {
      throw const FileSystemException('Project storage is not a directory');
    }
    final resolvedRoot = p.normalize(await root.resolveSymbolicLinks());
    final resolvedProjects = p.normalize(await projects.resolveSymbolicLinks());
    if (!p.isWithin(resolvedRoot, resolvedProjects)) {
      throw const FileSystemException(
        'Project storage leaves application root',
      );
    }
    await projects.delete(recursive: true);
  }
}
