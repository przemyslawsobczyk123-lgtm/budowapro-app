import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef PrivateDirectoryProvider = Future<Directory> Function();
typedef ClearPlatformTemporaryFiles = Future<void> Function();

final class PrivateCacheCleanupBatch {
  const PrivateCacheCleanupBatch(this.directories);

  final List<Directory> directories;
}

final class LocalPrivateCacheCleaner {
  factory LocalPrivateCacheCleaner.forDevice() {
    return LocalPrivateCacheCleaner(
      temporaryDirectoryProvider: getTemporaryDirectory,
      applicationSupportDirectoryProvider: getApplicationSupportDirectory,
      systemTemporaryDirectory: Directory.systemTemp,
      clearFilePickerTemporaryFiles: () async {
        await FilePicker.clearTemporaryFiles();
      },
    );
  }

  factory LocalPrivateCacheCleaner({
    required PrivateDirectoryProvider temporaryDirectoryProvider,
    required PrivateDirectoryProvider applicationSupportDirectoryProvider,
    required Directory systemTemporaryDirectory,
    required ClearPlatformTemporaryFiles clearFilePickerTemporaryFiles,
  }) {
    return LocalPrivateCacheCleaner._(
      temporaryDirectoryProvider,
      applicationSupportDirectoryProvider,
      systemTemporaryDirectory,
      clearFilePickerTemporaryFiles,
    );
  }

  LocalPrivateCacheCleaner._(
    this._temporaryDirectoryProvider,
    this._applicationSupportDirectoryProvider,
    this._systemTemporaryDirectory,
    this._clearFilePickerTemporaryFiles,
  );

  final PrivateDirectoryProvider _temporaryDirectoryProvider;
  final PrivateDirectoryProvider _applicationSupportDirectoryProvider;
  final Directory _systemTemporaryDirectory;
  final ClearPlatformTemporaryFiles _clearFilePickerTemporaryFiles;
  var _purgeSequence = 0;
  static Timer? _shareCacheCleanupTimer;

  Future<PrivateCacheCleanupBatch> detachStale() async {
    final detached = <Directory>[];
    await _detachKnownChildren(_temporaryDirectoryProvider, const <String>[
      'budowapro-backups',
      'budowapro-exports',
      'share_plus',
    ], detached);
    await _detachKnownChildren(
      _applicationSupportDirectoryProvider,
      const <String>['.budowapro-restore-candidates', '.budowapro-backup-work'],
      detached,
    );
    await _detachPrefixedSystemDirectories(detached);
    return PrivateCacheCleanupBatch(List<Directory>.unmodifiable(detached));
  }

  Future<void> purge(PrivateCacheCleanupBatch batch) async {
    for (final directory in batch.directories) {
      await _deleteDirectory(directory);
    }
    try {
      await _clearFilePickerTemporaryFiles();
    } on Object {
      // Platform caches are best effort and never replace an app operation.
    }
  }

  Future<void> clean() async {
    final batch = await detachStale();
    await purge(batch);
  }

  void scheduleShareCacheCleanup({
    Duration delay = const Duration(minutes: 2),
  }) {
    _shareCacheCleanupTimer?.cancel();
    late final Timer timer;
    timer = Timer(delay, () {
      if (!identical(_shareCacheCleanupTimer, timer)) return;
      _shareCacheCleanupTimer = null;
      unawaited(() async {
        final detached = <Directory>[];
        await _detachKnownChildren(_temporaryDirectoryProvider, const <String>[
          'share_plus',
        ], detached);
        for (final directory in detached) {
          await _deleteDirectory(directory);
        }
      }());
    });
    _shareCacheCleanupTimer = timer;
  }

  Future<void> _detachKnownChildren(
    PrivateDirectoryProvider rootProvider,
    List<String> names,
    List<Directory> detached,
  ) async {
    Directory root;
    try {
      root = await rootProvider();
    } on Object {
      return;
    }
    await _collectPreviousPurgeDirectories(root, detached);
    for (final name in names) {
      final renamed = await _detachDirectory(
        Directory(p.join(root.path, name)),
      );
      if (renamed != null) detached.add(renamed);
    }
  }

  Future<void> _detachPrefixedSystemDirectories(
    List<Directory> detached,
  ) async {
    try {
      if (!await _systemTemporaryDirectory.exists()) return;
      await for (final entity in _systemTemporaryDirectory.list(
        followLinks: false,
      )) {
        final name = p.basename(entity.path);
        if (entity is! Directory) continue;
        if (name.startsWith(_purgePrefix)) {
          detached.add(entity);
        } else if (name.startsWith('budowapro_preview_') ||
            name.startsWith('budowapro_receipt_ocr_')) {
          final renamed = await _detachDirectory(entity);
          if (renamed != null) detached.add(renamed);
        }
      }
    } on FileSystemException {
      // Other app-owned cache locations can still be detached.
    }
  }

  Future<void> _collectPreviousPurgeDirectories(
    Directory root,
    List<Directory> detached,
  ) async {
    try {
      if (!await root.exists()) return;
      await for (final entity in root.list(followLinks: false)) {
        if (entity is Directory &&
            p.basename(entity.path).startsWith(_purgePrefix)) {
          detached.add(entity);
        }
      }
    } on FileSystemException {
      // A later startup can retry a directory that is temporarily locked.
    }
  }

  Future<Directory?> _detachDirectory(Directory directory) async {
    try {
      final type = await FileSystemEntity.type(
        directory.path,
        followLinks: false,
      );
      if (type != FileSystemEntityType.directory) return null;
      final suffix =
          '${DateTime.now().microsecondsSinceEpoch}-${_purgeSequence++}';
      final detached = Directory(
        p.join(
          directory.parent.path,
          '$_purgePrefix${p.basename(directory.path)}-$suffix',
        ),
      );
      return await directory.rename(detached.path);
    } on FileSystemException {
      return null;
    }
  }

  static const _purgePrefix = '.budowapro-purge-';

  static Future<void> _deleteDirectory(Directory directory) async {
    try {
      final type = await FileSystemEntity.type(
        directory.path,
        followLinks: false,
      );
      if (type == FileSystemEntityType.directory) {
        await directory.delete(recursive: true);
      }
    } on FileSystemException {
      // The OS may already have reclaimed or locked a temporary location.
    }
  }
}
