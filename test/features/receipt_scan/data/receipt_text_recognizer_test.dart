import 'dart:io';

import 'package:budowapro/features/receipt_scan/data/receipt_text_recognizer.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temporaryDirectory;
  late File imageFile;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_receipt_ocr_test_',
    );
    imageFile = File(p.join(temporaryDirectory.path, 'private.jpg'));
    await imageFile.writeAsBytes(<int>[1, 2, 3], flush: true);
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('recognizes and bounds text from a private local image', () async {
    String? receivedPath;
    final recognizer = MlKitReceiptTextRecognizer(
      recognizeImage: (path) async {
        receivedPath = path;
        return '  SKŁAD   DOM  \n RAZEM 12,50 ';
      },
    );

    final result = await recognizer.recognize(imageFile.uri);

    expect(receivedPath, imageFile.path);
    expect(result.lines, <String>['SKŁAD DOM', 'RAZEM 12,50']);
  });

  test('maps recognition failures without exposing the private path', () async {
    final recognizer = MlKitReceiptTextRecognizer(
      recognizeImage: (_) => throw StateError('native failure'),
    );

    Object? failure;
    try {
      await recognizer.recognize(imageFile.uri);
    } on Object catch (error) {
      failure = error;
    }

    expect(failure, isA<ReceiptScanException>());
    expect(
      (failure! as ReceiptScanException).kind,
      ReceiptScanFailureKind.recognition,
    );
    expect(failure.toString(), isNot(contains(imageFile.path)));
  });
}
