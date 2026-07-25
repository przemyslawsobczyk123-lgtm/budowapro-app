import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:budowapro/features/receipt_scan/presentation/receipt_scan_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeGateway gateway;
  late ReceiptScanController controller;

  setUp(() {
    gateway = _FakeGateway();
    controller = ReceiptScanController(
      projectId: 'project-1',
      gateway: gateway,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('starts idle without invoking capture', () {
    expect(controller.state.status, ReceiptScanViewStatus.idle);
    expect(gateway.captureCalls, 0);
  });

  test('returns to idle after native cancellation', () async {
    gateway.captureResult = null;

    await controller.start(ReceiptCaptureMethod.scanner);

    expect(controller.state.status, ReceiptScanViewStatus.idle);
    expect(gateway.captureCalls, 1);
    expect(gateway.recognizeCalls, 0);
  });

  test(
    'publishes a provisional result without financial persistence',
    () async {
      gateway.captureResult = _source;
      gateway.recognitionResult = ReceiptScanSession(
        source: _source,
        candidates: ReceiptOcrCandidates(
          recognizedText: RecognizedReceiptText.fromRaw(
            'SKŁAD BUDOWLANY\nRAZEM 42,50',
          ),
          seller: 'SKŁAD BUDOWLANY',
          totalText: '42,50',
        ),
      );

      await controller.start(ReceiptCaptureMethod.scanner);

      expect(controller.state.status, ReceiptScanViewStatus.result);
      expect(controller.state.session?.candidates.totalText, '42,50');
    },
  );

  test(
    'keeps a source available for OCR retry after recognition failure',
    () async {
      gateway.captureResult = _source;
      gateway.failure = const ReceiptScanException(
        ReceiptScanFailureKind.recognition,
      );

      await controller.start(ReceiptCaptureMethod.scanner);

      expect(controller.state.status, ReceiptScanViewStatus.error);
      expect(controller.state.source, same(_source));
      expect(gateway.discardCalls, 0);

      gateway.failure = null;
      gateway.recognitionResult = ReceiptScanSession(
        source: _source,
        candidates: ReceiptOcrCandidates(
          recognizedText: RecognizedReceiptText.fromRaw('RAZEM 42,50'),
          totalText: '42,50',
        ),
      );
      await controller.retryRecognition();

      expect(controller.state.status, ReceiptScanViewStatus.result);
      expect(gateway.recognizeCalls, 2);
    },
  );

  test('discard removes the source and resets the screen', () async {
    gateway.captureResult = _source;
    gateway.failure = const ReceiptScanException(
      ReceiptScanFailureKind.emptyText,
    );
    await controller.start(ReceiptCaptureMethod.fileImport);

    await controller.discard();

    expect(gateway.discardCalls, 1);
    expect(controller.state.status, ReceiptScanViewStatus.idle);
    expect(controller.state.source, isNull);
  });

  test('keeps the source visible when explicit cleanup fails', () async {
    gateway.captureResult = _source;
    gateway.failure = const ReceiptScanException(
      ReceiptScanFailureKind.emptyText,
    );
    await controller.start(ReceiptCaptureMethod.fileImport);
    gateway.failure = null;
    gateway.discardFailure = StateError('cleanup failed');

    await controller.discard();

    expect(controller.state.status, ReceiptScanViewStatus.error);
    expect(controller.state.failureKind, ReceiptScanFailureKind.storage);
    expect(controller.state.source, same(_source));
  });
}

final StagedReceiptSource _source = StagedReceiptSource(
  projectId: 'project-1',
  attachmentId: 'attachment-1',
  captureMethod: ReceiptCaptureMethod.scanner,
  mediaType: 'image/jpeg',
  originalUri: Uri(path: 'C:/private/original.jpg', scheme: 'file'),
  previewUri: Uri(path: 'C:/private/preview.jpg', scheme: 'file'),
);

final class _FakeGateway implements ReceiptScanGateway {
  int captureCalls = 0;
  int recognizeCalls = 0;
  int discardCalls = 0;
  StagedReceiptSource? captureResult;
  ReceiptScanSession? recognitionResult;
  ReceiptScanException? failure;
  Object? discardFailure;

  @override
  Future<StagedReceiptSource?> capture({
    required String projectId,
    required ReceiptCaptureMethod method,
  }) async {
    captureCalls += 1;
    if (failure case final failure?
        when failure.kind == ReceiptScanFailureKind.scannerUnavailable) {
      throw failure;
    }
    return captureResult;
  }

  @override
  Future<ReceiptScanSession> recognize(StagedReceiptSource source) async {
    recognizeCalls += 1;
    if (failure case final failure?) throw failure;
    return recognitionResult!;
  }

  @override
  Future<void> discard(StagedReceiptSource source) async {
    discardCalls += 1;
    if (discardFailure case final failure?) throw failure;
  }
}
