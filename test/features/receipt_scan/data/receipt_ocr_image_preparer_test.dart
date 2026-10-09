import 'dart:io';

import 'package:budowapro/features/receipt_scan/data/receipt_ocr_image_preparer.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as p;

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_receipt_prepare_test_',
    );
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('uses a private image original without creating a derivative', () async {
    final original = File(p.join(temporaryDirectory.path, 'receipt.jpg'));
    await original.writeAsBytes(
      image.encodeJpg(image.Image(width: 120, height: 80)),
      flush: true,
    );
    final preparer = LocalReceiptOcrImagePreparer();

    final prepared = await preparer.prepare(
      originalUri: original.uri,
      mediaType: 'image/jpeg',
    );

    expect(prepared.imageUris, <Uri>[original.uri]);
    await prepared.dispose();
    expect(await original.exists(), isTrue);
  });

  test(
    'renders every PDF page and deletes all temporary derivatives',
    () async {
      final original = File(p.join(temporaryDirectory.path, 'receipt.pdf'));
      await original.writeAsString('%PDF-1.7\nfixture', flush: true);
      final preparer = LocalReceiptOcrImagePreparer(
        renderPdfPages: (source, targetDirectory) async {
          expect(source.uri, original.uri);
          final first = File(p.join(targetDirectory.path, 'page-001.jpg'));
          final second = File(p.join(targetDirectory.path, 'page-002.jpg'));
          await first.writeAsBytes(<int>[9, 8, 7], flush: true);
          await second.writeAsBytes(<int>[6, 5, 4], flush: true);
          return <Uri>[first.uri, second.uri];
        },
      );

      final prepared = await preparer.prepare(
        originalUri: original.uri,
        mediaType: 'application/pdf',
      );
      final derivatives = prepared.imageUris.map(File.fromUri).toList();

      expect(prepared.imageUris, hasLength(2));
      expect(await derivatives.first.readAsBytes(), <int>[9, 8, 7]);
      expect(await derivatives.last.readAsBytes(), <int>[6, 5, 4]);
      await prepared.dispose();
      expect(await derivatives.first.exists(), isFalse);
      expect(await derivatives.last.exists(), isFalse);
      expect(await original.exists(), isTrue);
    },
  );

  test(
    'downscales a large image before OCR and removes the derivative',
    () async {
      final original = File(p.join(temporaryDirectory.path, 'large.jpg'));
      await original.writeAsBytes(
        image.encodeJpg(image.Image(width: 2400, height: 1800)),
        flush: true,
      );

      final prepared = await LocalReceiptOcrImagePreparer().prepare(
        originalUri: original.uri,
        mediaType: 'image/jpeg',
      );
      final derivative = File.fromUri(prepared.imageUris.single);
      final decoded = image.decodeImage(await derivative.readAsBytes());

      expect(prepared.imageUris.single, isNot(original.uri));
      expect(decoded, isNotNull);
      expect(decoded!.width, lessThanOrEqualTo(1600));
      expect(decoded.height, lessThanOrEqualTo(2400));
      await prepared.dispose();
      expect(await derivative.exists(), isFalse);
      expect(await original.exists(), isTrue);
    },
  );

  test('rejects a mislabeled image before OCR', () async {
    final original = File(p.join(temporaryDirectory.path, 'fake.jpg'));
    await original.writeAsString('not an image', flush: true);

    await expectLater(
      LocalReceiptOcrImagePreparer().prepare(
        originalUri: original.uri,
        mediaType: 'image/jpeg',
      ),
      throwsA(
        isA<ReceiptScanException>().having(
          (error) => error.kind,
          'kind',
          ReceiptScanFailureKind.unsupportedInput,
        ),
      ),
    );
  });

  test('rejects a PDF that exceeds the OCR page limit', () async {
    final original = File(
      p.join(temporaryDirectory.path, 'too-many-pages.pdf'),
    );
    await original.writeAsString('%PDF-1.7\nfixture', flush: true);
    // The default renderer needs the native PDFium library, which the Linux
    // CI runner does not have; there the worker isolate died and the test
    // only timed out. A fake renderer exercises the same limit everywhere.
    late Directory renderDirectory;
    final preparer = LocalReceiptOcrImagePreparer(
      renderPdfPages: (source, targetDirectory) async {
        renderDirectory = targetDirectory;
        final pages = <Uri>[];
        for (
          var index = 0;
          index < LocalReceiptOcrImagePreparer.maximumPdfPages + 1;
          index += 1
        ) {
          final page = File(p.join(targetDirectory.path, 'page-$index.jpg'));
          await page.writeAsBytes(<int>[1, 2, 3], flush: true);
          pages.add(page.uri);
        }
        return pages;
      },
    );

    await expectLater(
      preparer.prepare(originalUri: original.uri, mediaType: 'application/pdf'),
      throwsA(
        isA<ReceiptScanException>().having(
          (error) => error.kind,
          'kind',
          ReceiptScanFailureKind.unsupportedInput,
        ),
      ),
    );
    expect(await renderDirectory.exists(), isFalse);
    expect(await original.exists(), isTrue);
  });
}
