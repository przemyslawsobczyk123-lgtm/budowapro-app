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

    expect(prepared.imageUri, original.uri);
    await prepared.dispose();
    expect(await original.exists(), isTrue);
  });

  test(
    'renders a PDF first page and deletes the temporary derivative',
    () async {
      final original = File(p.join(temporaryDirectory.path, 'receipt.pdf'));
      await original.writeAsString('%PDF-1.7\nfixture', flush: true);
      final preparer = LocalReceiptOcrImagePreparer(
        renderPdfFirstPage: (source, target) async {
          expect(source.uri, original.uri);
          await target.writeAsBytes(<int>[9, 8, 7], flush: true);
        },
      );

      final prepared = await preparer.prepare(
        originalUri: original.uri,
        mediaType: 'application/pdf',
      );
      final derivative = File.fromUri(prepared.imageUri);

      expect(await derivative.readAsBytes(), <int>[9, 8, 7]);
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
}
