import 'dart:io';

import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/receipt_scan/data/local_receipt_scan_gateway.dart';
import 'package:budowapro/features/receipt_scan/data/receipt_capture_adapters.dart';
import 'package:budowapro/features/receipt_scan/data/receipt_ocr_image_preparer.dart';
import 'package:budowapro/features/receipt_scan/data/receipt_text_recognizer.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temporaryDirectory;
  late File scannerTemporary;
  late File privateOriginal;
  late File privatePreview;
  late _FakeAttachmentStore attachmentStore;
  late _FakeSourcePicker scanner;
  late _FakeSourcePicker filePicker;
  late _FakeRecognizer recognizer;
  late _FakePreparer preparer;
  late LocalReceiptScanGateway gateway;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_receipt_gateway_test_',
    );
    scannerTemporary = File(
      p.join(temporaryDirectory.path, 'scanner-temporary.jpg'),
    );
    privateOriginal = File(p.join(temporaryDirectory.path, 'private.jpg'));
    privatePreview = File(p.join(temporaryDirectory.path, 'preview.jpg'));
    await scannerTemporary.writeAsBytes(<int>[1, 2, 3], flush: true);
    await privateOriginal.writeAsBytes(<int>[1, 2, 3], flush: true);
    await privatePreview.writeAsBytes(<int>[4, 5], flush: true);
    attachmentStore = _FakeAttachmentStore(
      originalUri: privateOriginal.uri,
      previewUri: privatePreview.uri,
    );
    scanner = _FakeSourcePicker(
      result: PickedReceiptSource(
        attachment: PickedLocalAttachment(
          sourceUri: scannerTemporary.uri,
          displayName: 'paragon-skan.jpg',
          reportedByteSize: 3,
          mediaType: 'image/jpeg',
          source: LocalAttachmentSource.scanner,
        ),
        captureMethod: ReceiptCaptureMethod.scanner,
        deleteAfterStaging: true,
      ),
    );
    filePicker = _FakeSourcePicker(result: null);
    recognizer = _FakeRecognizer(
      result: RecognizedReceiptText.fromRaw('SKŁAD BUDOWLANY\nRAZEM 42,50'),
    );
    preparer = _FakePreparer();
    gateway = LocalReceiptScanGateway(
      attachmentStore: attachmentStore,
      scanner: scanner,
      filePicker: filePicker,
      imagePreparer: preparer,
      textRecognizer: recognizer,
    );
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('cancellation creates no attachment', () async {
    scanner.result = null;

    final result = await gateway.capture(
      projectId: 'project-1',
      method: ReceiptCaptureMethod.scanner,
    );

    expect(result, isNull);
    expect(attachmentStore.stageCalls, 0);
  });

  test(
    'stages a scan, requires preview and removes scanner temporary',
    () async {
      final result = await gateway.capture(
        projectId: 'project-1',
        method: ReceiptCaptureMethod.scanner,
      );

      expect(result, isNotNull);
      expect(result!.attachmentId, 'attachment-1');
      expect(result.originalUri, privateOriginal.uri);
      expect(result.previewUri, privatePreview.uri);
      expect(await scannerTemporary.exists(), isFalse);
      expect(attachmentStore.discardCalls, 0);
    },
  );

  test('rolls back a staged receipt when preview is unavailable', () async {
    attachmentStore.previewUri = null;

    await expectLater(
      gateway.capture(
        projectId: 'project-1',
        method: ReceiptCaptureMethod.scanner,
      ),
      throwsA(
        isA<ReceiptScanException>().having(
          (error) => error.kind,
          'kind',
          ReceiptScanFailureKind.storage,
        ),
      ),
    );

    expect(attachmentStore.discardCalls, 1);
  });

  test('recognizes only the private original and returns a proposal', () async {
    final source = (await gateway.capture(
      projectId: 'project-1',
      method: ReceiptCaptureMethod.scanner,
    ))!;

    final result = await gateway.recognize(source);

    expect(recognizer.receivedUri, privateOriginal.uri);
    expect(result.source, same(source));
    expect(result.candidates.seller?.value, 'SKŁAD BUDOWLANY');
    expect(result.candidates.totalText?.value, '42,50');
    expect(preparer.disposeCalls, 1);
  });

  test('keeps the staged source after a retryable OCR failure', () async {
    final source = (await gateway.capture(
      projectId: 'project-1',
      method: ReceiptCaptureMethod.scanner,
    ))!;
    recognizer.failure = const ReceiptScanException(
      ReceiptScanFailureKind.recognition,
    );

    await expectLater(
      gateway.recognize(source),
      throwsA(isA<ReceiptScanException>()),
    );

    expect(attachmentStore.discardCalls, 0);
    expect(preparer.disposeCalls, 1);
  });

  test('explicit discard removes the unlinked private attachment', () async {
    final source = (await gateway.capture(
      projectId: 'project-1',
      method: ReceiptCaptureMethod.scanner,
    ))!;

    await gateway.discard(source);

    expect(attachmentStore.discardCalls, 1);
  });
}

final class _FakeSourcePicker implements ReceiptSourcePicker {
  _FakeSourcePicker({required this.result});

  PickedReceiptSource? result;

  @override
  Future<PickedReceiptSource?> pick() async => result;
}

final class _FakeAttachmentStore implements ReceiptAttachmentStore {
  _FakeAttachmentStore({required this.originalUri, required this.previewUri});

  Uri? originalUri;
  Uri? previewUri;
  int stageCalls = 0;
  int discardCalls = 0;

  @override
  Future<StagedLocalAttachment> stage({
    required String projectId,
    required PickedLocalAttachment pickedFile,
  }) async {
    stageCalls += 1;
    return StagedLocalAttachment(
      id: 'attachment-1',
      projectId: projectId,
      displayName: pickedFile.displayName,
      byteSize: pickedFile.reportedByteSize,
      mediaType: pickedFile.mediaType,
      sha256: 'hash',
      hasPreview: previewUri != null,
      importedAtUtc: DateTime.utc(2026, 7, 25),
    );
  }

  @override
  Future<Uri?> original({
    required String projectId,
    required String attachmentId,
  }) async => originalUri;

  @override
  Future<Uri?> preview({
    required String projectId,
    required String attachmentId,
  }) async => previewUri;

  @override
  Future<void> discard({
    required String projectId,
    required String attachmentId,
  }) async {
    discardCalls += 1;
  }
}

final class _FakeRecognizer implements ReceiptTextRecognizer {
  _FakeRecognizer({required this.result});

  final RecognizedReceiptText result;
  ReceiptScanException? failure;
  Uri? receivedUri;

  @override
  Future<RecognizedReceiptText> recognize(Uri imageUri) async {
    receivedUri = imageUri;
    if (failure case final failure?) throw failure;
    return result;
  }
}

final class _FakePreparer implements ReceiptOcrImagePreparer {
  int disposeCalls = 0;

  @override
  Future<PreparedReceiptImage> prepare({
    required Uri originalUri,
    required String mediaType,
  }) async {
    return PreparedReceiptImage(
      imageUri: originalUri,
      disposeImage: () async {
        disposeCalls += 1;
      },
    );
  }
}
