import 'dart:io';

import 'package:budowapro/shared/services/local_private_cache_cleaner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Directory temporary;
  late Directory support;
  late Directory systemTemporary;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_cleaner_test_');
    temporary = Directory(p.join(root.path, 'temporary'));
    support = Directory(p.join(root.path, 'support'));
    systemTemporary = Directory(p.join(root.path, 'system-temporary'));
    await temporary.create();
    await support.create();
    await systemTemporary.create();
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test('removes only BudowaPRO private cache locations', () async {
    final staleLocations = <Directory>[
      Directory(p.join(temporary.path, 'budowapro-backups')),
      Directory(p.join(temporary.path, 'budowapro-exports')),
      Directory(p.join(temporary.path, 'share_plus')),
      Directory(p.join(support.path, '.budowapro-restore-candidates')),
      Directory(p.join(support.path, '.budowapro-backup-work')),
      Directory(p.join(systemTemporary.path, 'budowapro_preview_crashed')),
      Directory(p.join(systemTemporary.path, 'budowapro_receipt_ocr_crashed')),
    ];
    for (final location in staleLocations) {
      await location.create(recursive: true);
      await File(p.join(location.path, 'private.txt')).writeAsString('private');
    }
    final unrelated = Directory(p.join(temporary.path, 'other-app-cache'));
    await unrelated.create();
    var filePickerCacheCleared = false;
    final cleaner = LocalPrivateCacheCleaner(
      temporaryDirectoryProvider: () async => temporary,
      applicationSupportDirectoryProvider: () async => support,
      systemTemporaryDirectory: systemTemporary,
      clearFilePickerTemporaryFiles: () async {
        filePickerCacheCleared = true;
      },
    );

    await cleaner.clean();

    for (final location in staleLocations) {
      expect(await location.exists(), isFalse, reason: location.path);
    }
    expect(await unrelated.exists(), isTrue);
    expect(filePickerCacheCleared, isTrue);
  });

  test('cleanup is best effort when a platform cache call fails', () async {
    final backups = Directory(p.join(temporary.path, 'budowapro-backups'));
    await backups.create();
    final cleaner = LocalPrivateCacheCleaner(
      temporaryDirectoryProvider: () async => temporary,
      applicationSupportDirectoryProvider: () async => support,
      systemTemporaryDirectory: systemTemporary,
      clearFilePickerTemporaryFiles: () async {
        throw const FileSystemException('platform cleanup failed');
      },
    );

    await expectLater(cleaner.clean(), completes);
    expect(await backups.exists(), isFalse);
  });

  test('detach hides stale data before recursive purge', () async {
    final backups = Directory(p.join(temporary.path, 'budowapro-backups'));
    await backups.create();
    await File(p.join(backups.path, 'large-backup.zip')).writeAsString('data');
    final cleaner = LocalPrivateCacheCleaner(
      temporaryDirectoryProvider: () async => temporary,
      applicationSupportDirectoryProvider: () async => support,
      systemTemporaryDirectory: systemTemporary,
      clearFilePickerTemporaryFiles: () async {},
    );

    final batch = await cleaner.detachStale();

    expect(await backups.exists(), isFalse);
    expect(batch.directories, isNotEmpty);
    expect(await batch.directories.first.exists(), isTrue);

    await cleaner.purge(batch);

    for (final detached in batch.directories) {
      expect(await detached.exists(), isFalse);
    }
  });

  test('scheduled cleanup removes the share_plus copy', () async {
    final shareCache = Directory(p.join(temporary.path, 'share_plus'));
    await shareCache.create();
    await File(p.join(shareCache.path, 'backup.zip')).writeAsString('private');
    final cleaner = LocalPrivateCacheCleaner(
      temporaryDirectoryProvider: () async => temporary,
      applicationSupportDirectoryProvider: () async => support,
      systemTemporaryDirectory: systemTemporary,
      clearFilePickerTemporaryFiles: () async {},
    );

    cleaner.scheduleShareCacheCleanup(delay: Duration.zero);
    await _waitUntilMissing(shareCache);

    expect(await shareCache.exists(), isFalse);
    expect(
      temporary
          .listSync(followLinks: false)
          .whereType<Directory>()
          .where(
            (directory) =>
                p.basename(directory.path).startsWith('.budowapro-purge-'),
          ),
      isEmpty,
    );
  });

  test('a newer share cancels the previous cleanup timer', () async {
    final shareCache = Directory(p.join(temporary.path, 'share_plus'));
    await shareCache.create();
    final cleaner = LocalPrivateCacheCleaner(
      temporaryDirectoryProvider: () async => temporary,
      applicationSupportDirectoryProvider: () async => support,
      systemTemporaryDirectory: systemTemporary,
      clearFilePickerTemporaryFiles: () async {},
    );

    cleaner.scheduleShareCacheCleanup(delay: const Duration(milliseconds: 20));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await File(p.join(shareCache.path, 'new-export.csv')).writeAsString('new');
    cleaner.scheduleShareCacheCleanup(delay: const Duration(milliseconds: 100));

    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(await shareCache.exists(), isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _waitUntilMissing(shareCache);
  });
}

Future<void> _waitUntilMissing(Directory directory) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    if (!await directory.exists()) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for cleanup of ${directory.path}');
}
