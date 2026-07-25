import 'dart:async';

import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_review.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter/foundation.dart';

enum ReceiptScanViewStatus { idle, processing, result, error, saved }

enum ReceiptScanOperation { capture, recognition, save }

final class ReceiptScanViewState {
  const ReceiptScanViewState({
    required this.status,
    this.operation,
    this.source,
    this.session,
    this.reviewDraft,
    this.failureKind,
    this.duplicateCheck,
    this.saveFailed = false,
    this.savedDraftCount,
  });

  const ReceiptScanViewState.idle()
    : status = ReceiptScanViewStatus.idle,
      operation = null,
      source = null,
      session = null,
      reviewDraft = null,
      failureKind = null,
      duplicateCheck = null,
      saveFailed = false,
      savedDraftCount = null;

  final ReceiptScanViewStatus status;
  final ReceiptScanOperation? operation;
  final StagedReceiptSource? source;
  final ReceiptScanSession? session;
  final ReceiptReviewDraft? reviewDraft;
  final ReceiptScanFailureKind? failureKind;
  final ReceiptDuplicateCheck? duplicateCheck;
  final bool saveFailed;
  final int? savedDraftCount;

  bool get isBusy => status == ReceiptScanViewStatus.processing;
}

final class ReceiptScanController extends ChangeNotifier {
  factory ReceiptScanController({
    required String projectId,
    required String currencyCode,
    required ReceiptScanGateway gateway,
    required ReceiptFinancialRepository financialRepository,
  }) {
    return ReceiptScanController._(
      projectId,
      currencyCode,
      gateway,
      financialRepository,
    );
  }

  ReceiptScanController._(
    this._projectId,
    this._currencyCode,
    this._gateway,
    this._financialRepository,
  );

  final String _projectId;
  final String _currencyCode;
  final ReceiptScanGateway _gateway;
  final ReceiptFinancialRepository _financialRepository;
  ReceiptScanViewState _state = const ReceiptScanViewState.idle();
  bool _isDisposed = false;

  ReceiptScanViewState get state => _state;

  Future<void> start(ReceiptCaptureMethod method) async {
    if (_state.isBusy || _state.source != null) return;
    _setState(
      const ReceiptScanViewState(
        status: ReceiptScanViewStatus.processing,
        operation: ReceiptScanOperation.capture,
      ),
    );
    try {
      final source = await _gateway.capture(
        projectId: _projectId,
        method: method,
      );
      if (source == null) {
        _setState(const ReceiptScanViewState.idle());
        return;
      }
      await _recognize(source);
    } on ReceiptScanException catch (error) {
      _setState(
        ReceiptScanViewState(
          status: ReceiptScanViewStatus.error,
          failureKind: error.kind,
        ),
      );
    } on Object {
      _setState(
        const ReceiptScanViewState(
          status: ReceiptScanViewStatus.error,
          failureKind: ReceiptScanFailureKind.storage,
        ),
      );
    }
  }

  Future<void> retryRecognition() async {
    final source = _state.source;
    if (_state.isBusy || source == null) return;
    await _recognize(source);
  }

  void updateField(ReceiptReviewFieldKey key, String value) {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(draft.updateField(key, value));
  }

  void confirmField(ReceiptReviewFieldKey key) {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(draft.confirmField(key));
  }

  void updateItem(
    String itemId, {
    String? name,
    String? grossAmountText,
    VatRate? vatRate,
  }) {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(
      draft.updateItem(
        itemId,
        name: name,
        grossAmountText: grossAmountText,
        vatRate: vatRate,
      ),
    );
  }

  void confirmItem(String itemId) {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(draft.confirmItem(itemId));
  }

  void addItem() {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(
      draft.addItem(name: '', grossAmountText: '', vatRate: VatRate.standard23),
    );
  }

  void removeItem(String itemId) {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(draft.removeItem(itemId));
  }

  void mergeWithNext(int index) {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(draft.mergeWithNext(index));
  }

  void splitItem(
    int index, {
    required String firstName,
    required String firstGrossAmountText,
    required String secondName,
    required String secondGrossAmountText,
  }) {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(
      draft.splitItem(
        index,
        firstName: firstName,
        firstGrossAmountText: firstGrossAmountText,
        secondName: secondName,
        secondGrossAmountText: secondGrossAmountText,
      ),
    );
  }

  void acceptTotalMismatch() {
    final draft = _state.reviewDraft;
    if (_state.status != ReceiptScanViewStatus.result || draft == null) return;
    _publishReview(draft.acceptTotalMismatch());
  }

  Future<void> saveReviewed({bool duplicateAcknowledged = false}) async {
    final source = _state.source;
    final session = _state.session;
    final draft = _state.reviewDraft;
    if (_state.isBusy ||
        source == null ||
        session == null ||
        draft == null ||
        !draft.canSubmit) {
      return;
    }
    _setState(
      ReceiptScanViewState(
        status: ReceiptScanViewStatus.processing,
        operation: ReceiptScanOperation.save,
        source: source,
        session: session,
        reviewDraft: draft,
      ),
    );
    try {
      final batch = _financialBatch(source, draft);
      final duplicate = await _financialRepository.checkDuplicates(batch);
      if (duplicate.isDuplicate && !duplicateAcknowledged) {
        _restoreReview(
          source: source,
          session: session,
          draft: draft,
          duplicateCheck: duplicate,
        );
        return;
      }
      final result = await _financialRepository.saveReviewedDrafts(
        batch,
        duplicateAcknowledged: duplicateAcknowledged,
      );
      _setState(
        ReceiptScanViewState(
          status: ReceiptScanViewStatus.saved,
          savedDraftCount: result.drafts.length,
        ),
      );
    } on ReceiptDuplicateException catch (error) {
      _restoreReview(
        source: source,
        session: session,
        draft: draft,
        duplicateCheck: error.check,
      );
    } on Object {
      _restoreReview(
        source: source,
        session: session,
        draft: draft,
        saveFailed: true,
      );
    }
  }

  Future<void> discard() async {
    if (_state.isBusy) return;
    final source = _state.source;
    try {
      if (source != null) {
        await _gateway.discard(source);
      }
      _setState(const ReceiptScanViewState.idle());
    } on Object {
      _setState(
        ReceiptScanViewState(
          status: ReceiptScanViewStatus.error,
          source: source,
          failureKind: ReceiptScanFailureKind.storage,
        ),
      );
    }
  }

  Future<void> _recognize(StagedReceiptSource source) async {
    _setState(
      ReceiptScanViewState(
        status: ReceiptScanViewStatus.processing,
        operation: ReceiptScanOperation.recognition,
        source: source,
      ),
    );
    try {
      final session = await _gateway.recognize(source);
      _setState(
        ReceiptScanViewState(
          status: ReceiptScanViewStatus.result,
          source: source,
          session: session,
          reviewDraft: ReceiptReviewDraft.fromCandidates(session.candidates),
        ),
      );
    } on ReceiptScanException catch (error) {
      _setState(
        ReceiptScanViewState(
          status: ReceiptScanViewStatus.error,
          source: source,
          failureKind: error.kind,
        ),
      );
    } on Object {
      _setState(
        ReceiptScanViewState(
          status: ReceiptScanViewStatus.error,
          source: source,
          failureKind: ReceiptScanFailureKind.recognition,
        ),
      );
    }
  }

  ReviewedReceiptBatch _financialBatch(
    StagedReceiptSource source,
    ReceiptReviewDraft draft,
  ) {
    return ReviewedReceiptBatch(
      projectId: _projectId,
      attachmentId: source.attachmentId,
      sellerName: draft.seller.value,
      purchaseDate: draft.receiptDate!,
      documentNumber: draft.documentNumber.value,
      totalGrossMinorUnits: draft.receiptTotalMinorUnits!,
      currencyCode: _currencyCode,
      totalMismatchAcknowledged: draft.totalMismatchAccepted,
      lines: draft.items.map(
        (item) => ReviewedReceiptLine(
          name: item.name,
          grossMinorUnits: parseReceiptMinorUnits(item.grossAmountText)!,
          vatRate: item.vatRate,
        ),
      ),
    );
  }

  void _publishReview(ReceiptReviewDraft draft) {
    _setState(
      ReceiptScanViewState(
        status: ReceiptScanViewStatus.result,
        source: _state.source,
        session: _state.session,
        reviewDraft: draft,
      ),
    );
  }

  void _restoreReview({
    required StagedReceiptSource source,
    required ReceiptScanSession session,
    required ReceiptReviewDraft draft,
    ReceiptDuplicateCheck? duplicateCheck,
    bool saveFailed = false,
  }) {
    _setState(
      ReceiptScanViewState(
        status: ReceiptScanViewStatus.result,
        source: source,
        session: session,
        reviewDraft: draft,
        duplicateCheck: duplicateCheck,
        saveFailed: saveFailed,
      ),
    );
  }

  void _setState(ReceiptScanViewState next) {
    if (_isDisposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    final source = _state.source;
    final saveIsRunning =
        _state.status == ReceiptScanViewStatus.processing &&
        _state.operation == ReceiptScanOperation.save;
    if (source != null && !saveIsRunning) {
      unawaited(_discardOnDispose(source));
    }
    super.dispose();
  }

  Future<void> _discardOnDispose(StagedReceiptSource source) async {
    try {
      await _gateway.discard(source);
    } on Object {
      // Startup recovery removes an unlinked receipt left after app exit.
    }
  }
}
