import 'dart:io';

import 'package:budowapro/core/files/local_file_preflight.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('budowapro_preflight_test_');
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test('accepts a bounded JPEG and reports its dimensions', () async {
    final file = File(p.join(root.path, 'photo.jpg'));
    await file.writeAsBytes(
      image.encodeJpg(image.Image(width: 80, height: 60)),
      flush: true,
    );

    final inspection = await LocalFilePreflight.inspectImage(
      file,
      maximumBytes: 1024 * 1024,
      maximumPixels: 10000,
    );

    expect(inspection.width, 80);
    expect(inspection.height, 60);
    expect(inspection.byteSize, await file.length());
  });

  test('rejects a mislabeled image before a decoder receives it', () async {
    final file = File(p.join(root.path, 'fake.jpg'));
    await file.writeAsString('not-an-image', flush: true);

    await expectLater(
      LocalFilePreflight.inspectImage(
        file,
        maximumBytes: 1024,
        maximumPixels: 10000,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects an image whose decoded pixel count is excessive', () async {
    final file = File(p.join(root.path, 'large.png'));
    await file.writeAsBytes(
      image.encodePng(image.Image(width: 200, height: 200)),
      flush: true,
    );

    await expectLater(
      LocalFilePreflight.inspectImage(
        file,
        maximumBytes: 1024 * 1024,
        maximumPixels: 10000,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('requires the PDF signature and an explicit byte limit', () async {
    final valid = File(p.join(root.path, 'valid.pdf'));
    await valid.writeAsString('%PDF-1.7\nfixture', flush: true);
    await expectLater(
      LocalFilePreflight.requirePdf(valid, maximumBytes: 1024),
      completes,
    );

    final invalid = File(p.join(root.path, 'invalid.pdf'));
    await invalid.writeAsString('plain text', flush: true);
    await expectLater(
      LocalFilePreflight.requirePdf(invalid, maximumBytes: 1024),
      throwsA(isA<FormatException>()),
    );
    await expectLater(
      LocalFilePreflight.requirePdf(valid, maximumBytes: 4),
      throwsA(isA<FormatException>()),
    );
  });
}
