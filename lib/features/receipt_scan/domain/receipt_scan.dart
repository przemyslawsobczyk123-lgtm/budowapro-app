import 'receipt_ocr.dart';

enum ReceiptCaptureMethod { scanner, fileImport }

enum ReceiptScanFailureKind {
  scannerUnavailable,
  unsupportedInput,
  emptyText,
  storage,
  recognition,
}

final class ReceiptScanException implements Exception {
  const ReceiptScanException(this.kind);

  final ReceiptScanFailureKind kind;

  @override
  String toString() => 'Receipt scan failed: ${kind.name}';
}

final class StagedReceiptSource {
  const StagedReceiptSource({
    required this.projectId,
    required this.attachmentId,
    required this.captureMethod,
    required this.mediaType,
    required this.originalUri,
    required this.previewUri,
  });

  final String projectId;
  final String attachmentId;
  final ReceiptCaptureMethod captureMethod;
  final String mediaType;
  final Uri originalUri;
  final Uri previewUri;
}

final class ReceiptScanSession {
  const ReceiptScanSession({required this.source, required this.candidates});

  final StagedReceiptSource source;
  final ReceiptOcrCandidates candidates;
}

abstract interface class ReceiptScanGateway {
  Future<StagedReceiptSource?> capture({
    required String projectId,
    required ReceiptCaptureMethod method,
  });

  Future<ReceiptScanSession> recognize(StagedReceiptSource source);

  Future<void> discard(StagedReceiptSource source);
}
