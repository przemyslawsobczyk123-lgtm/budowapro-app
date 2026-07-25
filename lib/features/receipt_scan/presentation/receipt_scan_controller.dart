import 'dart:async';

import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter/foundation.dart';

enum ReceiptScanViewStatus { idle, processing, result, error }

enum ReceiptScanOperation { capture, recognition }

final class ReceiptScanViewState {
  const ReceiptScanViewState({
    required this.status,
    this.operation,
    this.source,
    this.session,
    this.failureKind,
  });

  const ReceiptScanViewState.idle()
    : status = ReceiptScanViewStatus.idle,
      operation = null,
      source = null,
      session = null,
      failureKind = null;

  final ReceiptScanViewStatus status;
  final ReceiptScanOperation? operation;
  final StagedReceiptSource? source;
  final ReceiptScanSession? session;
  final ReceiptScanFailureKind? failureKind;

  bool get isBusy => status == ReceiptScanViewStatus.processing;
}

final class ReceiptScanController extends ChangeNotifier {
  factory ReceiptScanController({
    required String projectId,
    required ReceiptScanGateway gateway,
  }) {
    return ReceiptScanController._(projectId, gateway);
  }

  ReceiptScanController._(this._projectId, this._gateway);

  final String _projectId;
  final ReceiptScanGateway _gateway;
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

  void _setState(ReceiptScanViewState next) {
    if (_isDisposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    final source = _state.source;
    if (source != null) {
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
