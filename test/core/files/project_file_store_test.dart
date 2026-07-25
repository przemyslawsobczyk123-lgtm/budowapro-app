import 'dart:async';
import 'dart:io';

import 'package:budowapro/core/files/project_file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory rootDirectory;
  late Directory sourceDirectory;
  late ProjectFileStore store;

  setUp(() async {
    rootDirectory = await Directory.systemTemp.createTemp(
      'budowapro_file_store_root_',
    );
    sourceDirectory = await Directory.systemTemp.createTemp(
      'budowapro_file_store_source_',
    );
    store = ProjectFileStore(rootDirectory: rootDirectory);
  });

  tearDown(() async {
    if (await rootDirectory.exists()) {
      await rootDirectory.delete(recursive: true);
    }
    if (await sourceDirectory.exists()) {
      await sourceDirectory.delete(recursive: true);
    }
  });

  test('creates project-scoped originals, previews, and exports', () async {
    await store.ensureProjectDirectories('project-123');

    for (final area in ProjectFileArea.values) {
      final directory = store.directoryFor(
        projectId: 'project-123',
        area: area,
      );

      expect(await directory.exists(), isTrue);
      expect(
        p.normalize(directory.path),
        p.normalize(
          p.join(
            rootDirectory.path,
            'projects',
            'project-123',
            area.directoryName,
          ),
        ),
      );
    }
  });

  test('device factory uses the application support directory', () async {
    final deviceStore = await ProjectFileStore.createForDevice(
      applicationSupportDirectory: () async => rootDirectory,
    );

    expect(
      p.normalize(
        deviceStore
            .directoryFor(
              projectId: 'project-123',
              area: ProjectFileArea.originals,
            )
            .path,
      ),
      p.normalize(
        p.join(rootDirectory.path, 'projects', 'project-123', 'originals'),
      ),
    );
  });

  test('maintenance blocks new file operations until it completes', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final maintenance = store.runMaintenance(() async {
      entered.complete();
      await release.future;
    });
    await entered.future;

    final operation = store.ensureProjectDirectories('blocked-project');
    await Future<void>.delayed(Duration.zero);
    expect(
      store
          .directoryFor(
            projectId: 'blocked-project',
            area: ProjectFileArea.originals,
          )
          .existsSync(),
      isFalse,
    );

    release.complete();
    await Future.wait<void>(<Future<void>>[maintenance, operation]);
    expect(
      store
          .directoryFor(
            projectId: 'blocked-project',
            area: ProjectFileArea.originals,
          )
          .existsSync(),
      isTrue,
    );
  });

  test('rejects project IDs that can escape their directory', () {
    const invalidProjectIds = <String>[
      '',
      '.',
      '..',
      '../outside',
      r'..\outside',
      'nested/project',
      r'nested\project',
      '/absolute',
      r'C:\absolute',
    ];

    for (final projectId in invalidProjectIds) {
      expect(
        () => store.directoryFor(
          projectId: projectId,
          area: ProjectFileArea.originals,
        ),
        throwsArgumentError,
        reason: 'projectId: $projectId',
      );
    }
  });

  test('rejects file names that can escape their directory', () async {
    final source = File(p.join(sourceDirectory.path, 'source.pdf'));
    await source.writeAsString('source bytes');
    const invalidFileNames = <String>[
      '',
      '.',
      '..',
      '../outside.pdf',
      r'..\outside.pdf',
      'nested/file.pdf',
      r'nested\file.pdf',
      '/absolute.pdf',
      r'C:\absolute.pdf',
    ];

    for (final fileName in invalidFileNames) {
      await expectLater(
        store.importFile(
          projectId: 'project-123',
          area: ProjectFileArea.originals,
          source: source,
          fileName: fileName,
        ),
        throwsArgumentError,
        reason: 'fileName: $fileName',
      );
    }
  });

  test('imports through a part file and leaves only the final file', () async {
    final source = File(p.join(sourceDirectory.path, 'source.pdf'));
    await source.writeAsString('source bytes');

    final imported = await store.importFile(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
      source: source,
      fileName: 'receipt.pdf',
    );

    expect(await imported.readAsString(), 'source bytes');
    expect(await File('${imported.path}.part').exists(), isFalse);
    expect(await source.readAsString(), 'source bytes');
  });

  test('removes its part file when import fails', () async {
    final missingSource = File(p.join(sourceDirectory.path, 'missing.pdf'));
    final target = store.fileFor(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
      fileName: 'receipt.pdf',
    );

    await expectLater(
      store.importFile(
        projectId: 'project-123',
        area: ProjectFileArea.originals,
        source: missingSource,
        fileName: 'receipt.pdf',
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(await target.exists(), isFalse);
    expect(await File('${target.path}.part').exists(), isFalse);
  });

  test('stops a streaming import at the configured byte limit', () async {
    final source = File(p.join(sourceDirectory.path, 'oversized.pdf'));
    await source.writeAsBytes(List<int>.filled(12, 1), flush: true);
    final target = store.fileFor(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
      fileName: 'oversized.pdf',
    );

    await expectLater(
      store.importFile(
        projectId: 'project-123',
        area: ProjectFileArea.originals,
        source: source,
        fileName: 'oversized.pdf',
        maximumBytes: 8,
      ),
      throwsRangeError,
    );

    expect(await target.exists(), isFalse);
    expect(await File('${target.path}.part').exists(), isFalse);
  });

  test('recovers from a part file left by an interrupted process', () async {
    final source = File(p.join(sourceDirectory.path, 'source.pdf'));
    await source.writeAsString('recovered bytes');
    final target = store.fileFor(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
      fileName: 'receipt.pdf',
    );
    await target.parent.create(recursive: true);
    await File('${target.path}.part').writeAsString('stale partial bytes');

    final imported = await store.importFile(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
      source: source,
      fileName: 'receipt.pdf',
    );

    expect(await imported.readAsString(), 'recovered bytes');
    expect(await File('${target.path}.part').exists(), isFalse);
  });

  test('allows only one concurrent import for the same target', () async {
    final source = File(p.join(sourceDirectory.path, 'source.pdf'));
    await source.writeAsString('source bytes');

    final firstImport = store.importFile(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
      source: source,
      fileName: 'receipt.pdf',
    );
    await expectLater(
      store.importFile(
        projectId: 'project-123',
        area: ProjectFileArea.originals,
        source: source,
        fileName: 'receipt.pdf',
      ),
      throwsA(isA<FileSystemException>()),
    );

    final imported = await firstImport;
    expect(await imported.readAsString(), 'source bytes');
  });

  test('rejects a project area that is a symbolic link', () async {
    final source = File(p.join(sourceDirectory.path, 'source.pdf'));
    await source.writeAsString('source bytes');
    final outsideDirectory = Directory(p.join(sourceDirectory.path, 'outside'));
    await outsideDirectory.create();
    final areaDirectory = store.directoryFor(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
    );
    await areaDirectory.parent.create(recursive: true);

    expect(
      await _createDirectoryLink(
        linkPath: areaDirectory.path,
        targetPath: outsideDirectory.path,
      ),
      isTrue,
      reason: 'The platform must support a directory link for this test',
    );

    await expectLater(
      store.importFile(
        projectId: 'project-123',
        area: ProjectFileArea.originals,
        source: source,
        fileName: 'receipt.pdf',
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(
      await File(p.join(outsideDirectory.path, 'receipt.pdf')).exists(),
      isFalse,
    );
  });

  test('does not overwrite an existing target', () async {
    final source = File(p.join(sourceDirectory.path, 'source.pdf'));
    await source.writeAsString('new bytes');
    final target = store.fileFor(
      projectId: 'project-123',
      area: ProjectFileArea.originals,
      fileName: 'receipt.pdf',
    );
    await target.parent.create(recursive: true);
    await target.writeAsString('existing bytes');

    await expectLater(
      store.importFile(
        projectId: 'project-123',
        area: ProjectFileArea.originals,
        source: source,
        fileName: 'receipt.pdf',
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(await target.readAsString(), 'existing bytes');
    expect(await File('${target.path}.part').exists(), isFalse);
  });

  test('counts and deletes only files from the requested project', () async {
    await store.ensureProjectDirectories('project-123');
    await store.ensureProjectDirectories('project-other');
    await store
        .fileFor(
          projectId: 'project-123',
          area: ProjectFileArea.originals,
          fileName: 'receipt.pdf',
        )
        .writeAsString('receipt');
    await store
        .fileFor(
          projectId: 'project-123',
          area: ProjectFileArea.previews,
          fileName: 'preview.jpg',
        )
        .writeAsString('preview');
    final otherFile = store.fileFor(
      projectId: 'project-other',
      area: ProjectFileArea.originals,
      fileName: 'keep.pdf',
    );
    await otherFile.writeAsString('keep');

    expect(await store.countProjectFiles('project-123'), 2);
    await store.deleteProjectFiles('project-123');

    expect(await store.countProjectFiles('project-123'), 0);
    expect(await otherFile.readAsString(), 'keep');
  });
}

Future<bool> _createDirectoryLink({
  required String linkPath,
  required String targetPath,
}) async {
  if (Platform.isWindows) {
    final result = await Process.run('cmd.exe', <String>[
      '/c',
      'mklink',
      '/J',
      linkPath,
      targetPath,
    ]);
    return result.exitCode == 0;
  }

  try {
    await Link(linkPath).create(targetPath);
    return true;
  } on FileSystemException {
    return false;
  }
}
