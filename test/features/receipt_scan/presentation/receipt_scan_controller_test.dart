import 'dart:async';

import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_review.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:budowapro/features/receipt_scan/presentation/receipt_scan_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeGateway gateway;
  late _FakeFinancialRepository financialRepository;
  late ReceiptScanController controller;
  var controllerDisposed = false;

  setUp(() {
    gateway = _FakeGateway();
    financialRepository = _FakeFinancialRepository();
    controller = ReceiptScanController(
      projectId: 'project-1',
      currencyCode: 'PLN',
      gateway: gateway,
      financialRepository: financialRepository,
    );
    controllerDisposed = false;
  });

  tearDown(() {
    if (!controllerDisposed) controller.dispose();
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
          seller: ReceiptOcrField(value: 'SKŁAD BUDOWLANY', confidence: 0.96),
          totalText: ReceiptOcrField(value: '42,50', confidence: 0.92),
        ),
      );

      await controller.start(ReceiptCaptureMethod.scanner);

      expect(controller.state.status, ReceiptScanViewStatus.result);
      expect(controller.state.session?.candidates.totalText?.value, '42,50');
      expect(controller.state.reviewDraft, isNotNull);
      expect(financialRepository.saveCalls, 0);
    },
  );

  test('does not persist until the complete review is valid', () async {
    gateway.captureResult = _source;
    gateway.recognitionResult = _reviewableSession(
      dateConfidence: 0.5,
      secondItemConfidence: 0.6,
    );
    await controller.start(ReceiptCaptureMethod.scanner);

    await controller.saveReviewed();

    expect(financialRepository.saveCalls, 0);
    expect(controller.state.reviewDraft?.hasUnreviewedConfidence, isTrue);

    controller.confirmField(ReceiptReviewFieldKey.date);
    controller.confirmItem(controller.state.reviewDraft!.items[0].id);
    controller.confirmItem(controller.state.reviewDraft!.items[1].id);
    await controller.saveReviewed();

    expect(financialRepository.saveCalls, 1);
    expect(financialRepository.lastBatch?.lines, hasLength(2));
    expect(controller.state.status, ReceiptScanViewStatus.saved);
    expect(controller.state.savedDraftCount, 2);
    expect(controller.state.source, isNull);
  });

  test(
    'requires a separate acknowledgement for a suspected duplicate',
    () async {
      gateway.captureResult = _source;
      gateway.recognitionResult = _reviewableSession();
      financialRepository.duplicate = ReceiptDuplicateCheck(
        const <ReceiptDuplicateReason>[
          ReceiptDuplicateReason.fileHash,
          ReceiptDuplicateReason.receiptSignature,
        ],
      );
      await controller.start(ReceiptCaptureMethod.scanner);
      _confirmAllItems(controller);

      await controller.saveReviewed();

      expect(controller.state.status, ReceiptScanViewStatus.result);
      expect(controller.state.duplicateCheck?.isDuplicate, isTrue);
      expect(financialRepository.saveCalls, 0);

      await controller.saveReviewed(duplicateAcknowledged: true);

      expect(financialRepository.saveCalls, 1);
      expect(financialRepository.lastDuplicateAcknowledged, isTrue);
      expect(controller.state.status, ReceiptScanViewStatus.saved);
    },
  );

  test('keeps the reviewed source after a financial save failure', () async {
    gateway.captureResult = _source;
    gateway.recognitionResult = _reviewableSession();
    financialRepository.failure = StateError('database failure');
    await controller.start(ReceiptCaptureMethod.scanner);
    _confirmAllItems(controller);

    await controller.saveReviewed();

    expect(controller.state.status, ReceiptScanViewStatus.result);
    expect(controller.state.saveFailed, isTrue);
    expect(controller.state.source, same(_source));
    expect(controller.state.reviewDraft, isNotNull);
  });

  test('does not discard the source while financial save is running', () async {
    gateway.captureResult = _source;
    gateway.recognitionResult = _reviewableSession();
    final duplicateCompleter = Completer<ReceiptDuplicateCheck>();
    financialRepository.duplicateFuture = duplicateCompleter.future;
    await controller.start(ReceiptCaptureMethod.scanner);
    _confirmAllItems(controller);

    final save = controller.saveReviewed();
    expect(controller.state.operation, ReceiptScanOperation.save);

    controller.dispose();
    controllerDisposed = true;
    await Future<void>.delayed(Duration.zero);
    expect(gateway.discardCalls, 0);

    duplicateCompleter.complete(
      ReceiptDuplicateCheck(const <ReceiptDuplicateReason>[]),
    );
    await save;
    expect(financialRepository.saveCalls, 1);
    expect(gateway.discardCalls, 0);
  });

  test(
    'turns an invalid financial batch into a recoverable save error',
    () async {
      final localController = ReceiptScanController(
        projectId: 'project-1',
        currencyCode: 'pln',
        gateway: gateway,
        financialRepository: financialRepository,
      );
      addTearDown(localController.dispose);
      gateway.captureResult = _source;
      gateway.recognitionResult = _reviewableSession();
      await localController.start(ReceiptCaptureMethod.scanner);
      _confirmAllItems(localController);

      await localController.saveReviewed();

      expect(localController.state.status, ReceiptScanViewStatus.result);
      expect(localController.state.saveFailed, isTrue);
      expect(localController.state.source, same(_source));
      expect(financialRepository.checkCalls, 0);
      expect(financialRepository.saveCalls, 0);
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
          totalText: ReceiptOcrField(value: '42,50', confidence: 0.92),
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

ReceiptScanSession _reviewableSession({
  double dateConfidence = 0.95,
  double secondItemConfidence = 0.95,
}) {
  return ReceiptScanSession(
    source: _source,
    candidates: ReceiptOcrCandidates(
      recognizedText: RecognizedReceiptText.fromRaw(
        'SKŁAD BUDOWLANY\n25.07.2026\nKlej 30,00\nGrunt 20,00\nRAZEM 50,00',
      ),
      seller: ReceiptOcrField(value: 'SKŁAD BUDOWLANY', confidence: 0.95),
      dateText: ReceiptOcrField(
        value: '25.07.2026',
        confidence: dateConfidence,
      ),
      totalText: ReceiptOcrField(value: '50,00', confidence: 0.95),
      itemLines: <ReceiptOcrField>[
        ReceiptOcrField(value: 'Klej 30,00', confidence: 0.95),
        ReceiptOcrField(value: 'Grunt 20,00', confidence: secondItemConfidence),
      ],
    ),
  );
}

void _confirmAllItems(ReceiptScanController controller) {
  for (final item in controller.state.reviewDraft!.items) {
    controller.confirmItem(item.id);
  }
}

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

final class _FakeFinancialRepository implements ReceiptFinancialRepository {
  ReceiptDuplicateCheck duplicate = ReceiptDuplicateCheck(
    const <ReceiptDuplicateReason>[],
  );
  Object? failure;
  Future<ReceiptDuplicateCheck>? duplicateFuture;
  int checkCalls = 0;
  int saveCalls = 0;
  ReviewedReceiptBatch? lastBatch;
  bool? lastDuplicateAcknowledged;

  @override
  Future<ReceiptDuplicateCheck> checkDuplicates(
    ReviewedReceiptBatch batch,
  ) async {
    checkCalls += 1;
    if (duplicateFuture case final future?) return future;
    return duplicate;
  }

  @override
  Future<ReceiptDraftBatchResult> saveReviewedDrafts(
    ReviewedReceiptBatch batch, {
    bool duplicateAcknowledged = false,
  }) async {
    saveCalls += 1;
    lastBatch = batch;
    lastDuplicateAcknowledged = duplicateAcknowledged;
    if (failure case final failure?) throw failure;
    return ReceiptDraftBatchResult(
      drafts: <CostEntry>[
        for (var index = 0; index < batch.lines.length; index += 1)
          CostEntry(
            id: 'draft-$index',
            input: CostEntryInput(
              projectId: batch.projectId,
              name: batch.lines[index].name,
              type: CostEntryType.cost,
              status: CostStatus.planned,
              amount: VatBreakdown.fromGross(
                Money(
                  minorUnits: batch.lines[index].grossMinorUnits,
                  currencyCode: batch.currencyCode,
                ),
                batch.lines[index].vatRate,
              ),
              entryDate: batch.purchaseDate,
              source: CostSource.receiptOcr,
              attachmentIds: <String>[batch.attachmentId],
            ),
            lifecycle: CostLifecycle.draft,
            createdAt: DateTime.utc(2026, 7, 25),
            updatedAt: DateTime.utc(2026, 7, 25),
          ),
      ],
      duplicateAcknowledged: duplicateAcknowledged,
    );
  }
}
