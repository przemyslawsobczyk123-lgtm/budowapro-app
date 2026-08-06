import 'dart:io';

import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/receipt_scan/data/receipt_capture_adapters.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_receipt_capture_test_',
    );
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('MlKitReceiptDocumentScanner', () {
    test(
      'returns one local JPEG marked as a temporary scanner source',
      () async {
        final file = File(p.join(temporaryDirectory.path, 'scan.jpg'));
        await file.writeAsBytes(<int>[1, 2, 3], flush: true);
        final scanner = MlKitReceiptDocumentScanner(
          scanDocument: () async => file.uri,
        );

        final result = await scanner.pick();

        expect(result, isNotNull);
        expect(result!.captureMethod, ReceiptCaptureMethod.scanner);
        expect(result.deleteAfterStaging, isTrue);
        expect(result.attachment.source, LocalAttachmentSource.scanner);
        expect(result.attachment.mediaType, 'image/jpeg');
        expect(result.attachment.reportedByteSize, 3);
      },
    );

    test(
      'returns a multi-page PDF with matching attachment metadata',
      () async {
        final file = File(p.join(temporaryDirectory.path, 'scan.pdf'));
        await file.writeAsBytes(<int>[0x25, 0x50, 0x44, 0x46], flush: true);
        final scanner = MlKitReceiptDocumentScanner(
          scanDocument: () async => file.uri,
        );

        final result = await scanner.pick();

        expect(result, isNotNull);
        expect(result!.attachment.displayName, 'dokument-skan.pdf');
        expect(result.attachment.mediaType, 'application/pdf');
        expect(result.attachment.reportedByteSize, 4);
      },
    );

    test('maps the native cancellation to no result', () async {
      final scanner = MlKitReceiptDocumentScanner(
        scanDocument: () => throw PlatformException(
          code: 'DocumentScanner',
          message: 'Operation cancelled',
        ),
      );

      expect(await scanner.pick(), isNull);
    });

    test(
      'maps a scanner start failure to a stable unavailable error',
      () async {
        final scanner = MlKitReceiptDocumentScanner(
          scanDocument: () => throw PlatformException(
            code: 'DocumentScanner',
            message: 'Failed to start document scanner',
          ),
        );

        await expectLater(
          scanner.pick(),
          throwsA(
            isA<ReceiptScanException>().having(
              (error) => error.kind,
              'kind',
              ReceiptScanFailureKind.scannerUnavailable,
            ),
          ),
        );
      },
    );
  });

  group('FilePickerReceiptSourcePicker', () {
    test('imports only a local receipt image or PDF', () async {
      final file = File(p.join(temporaryDirectory.path, 'receipt.pdf'));
      await file.writeAsBytes(<int>[4, 5], flush: true);
      final picker = FilePickerReceiptSourcePicker(
        pickFiles: () async => FilePickerResult(<PlatformFile>[
          PlatformFile(name: 'receipt.pdf', size: 2, path: file.path),
        ]),
      );

      final result = await picker.pick();

      expect(result, isNotNull);
      expect(result!.captureMethod, ReceiptCaptureMethod.fileImport);
      expect(result.deleteAfterStaging, isFalse);
      expect(result.attachment.source, LocalAttachmentSource.filePicker);
      expect(result.attachment.mediaType, 'application/pdf');
    });

    test('returns no result after picker cancellation', () async {
      final picker = FilePickerReceiptSourcePicker(pickFiles: () async => null);

      expect(await picker.pick(), isNull);
    });
  });
}
