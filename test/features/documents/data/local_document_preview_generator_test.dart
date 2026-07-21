import 'dart:io';

import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/documents/data/local_document_preview_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as p;

void main() {
  late Directory temporaryDirectory;
  late ProjectFileStore fileStore;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_preview_test_',
    );
    fileStore = ProjectFileStore(
      rootDirectory: Directory(p.join(temporaryDirectory.path, 'private')),
    );
    await fileStore.ensureProjectDirectories('project-1');
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'creates a bounded derivative without changing image original',
    () async {
      final original = fileStore.fileFor(
        projectId: 'project-1',
        area: ProjectFileArea.originals,
        fileName: 'document-1.jpg',
      );
      final sourceImage = image.Image(width: 1200, height: 700)
        ..clear(image.ColorRgb8(32, 116, 78));
      final sourceBytes = image.encodeJpg(sourceImage, quality: 95);
      await original.writeAsBytes(sourceBytes, flush: true);

      final key = await LocalDocumentPreviewGenerator(fileStore: fileStore)
          .generate(
            projectId: 'project-1',
            attachmentId: 'document-1',
            originalStorageKey: 'document-1.jpg',
            mediaType: 'image/jpeg',
          );

      expect(key, 'document-1.jpg');
      expect(await original.readAsBytes(), sourceBytes);
      final preview = fileStore.fileFor(
        projectId: 'project-1',
        area: ProjectFileArea.previews,
        fileName: key!,
      );
      final decoded = image.decodeJpg(await preview.readAsBytes());
      expect(decoded, isNotNull);
      expect(decoded!.width, lessThanOrEqualTo(320));
      expect(decoded.height, lessThanOrEqualTo(480));
    },
  );

  test('does not create previews for unsupported documents', () async {
    final key = await LocalDocumentPreviewGenerator(fileStore: fileStore)
        .generate(
          projectId: 'project-1',
          attachmentId: 'document-2',
          originalStorageKey: 'document-2.xlsx',
          mediaType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );

    expect(key, isNull);
  });
}
