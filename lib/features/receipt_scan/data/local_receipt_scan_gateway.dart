import 'dart:io';

import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';

import 'receipt_capture_adapters.dart';
import 'receipt_ocr_image_preparer.dart';
import 'receipt_text_recognizer.dart';

abstract interface class ReceiptAttachmentStore {
  Future<StagedLocalAttachment> stage({
    required String projectId,
    required PickedLocalAttachment pickedFile,
  });

  Future<Uri?> original({
    required String projectId,
    required String attachmentId,
  });

  Future<Uri?> preview({
    required String projectId,
    required String attachmentId,
  });

  Future<void> discard({
    required String projectId,
    required String attachmentId,
  });
}

final class LocalReceiptAttachmentStore implements ReceiptAttachmentStore {
  const LocalReceiptAttachmentStore(this._stager);

  final LocalAttachmentStager _stager;

  @override
  Future<StagedLocalAttachment> stage({
    required String projectId,
    required PickedLocalAttachment pickedFile,
  }) {
    return _stager.stage(projectId: projectId, pickedFile: pickedFile);
  }

  @override
  Future<Uri?> original({
    required String projectId,
    required String attachmentId,
  }) async {
    return (await _stager.originalFile(
      projectId: projectId,
      attachmentId: attachmentId,
    ))?.uri;
  }

  @override
  Future<Uri?> preview({
    required String projectId,
    required String attachmentId,
  }) async {
    return (await _stager.previewFile(
      projectId: projectId,
      attachmentId: attachmentId,
    ))?.uri;
  }

  @override
  Future<void> discard({
    required String projectId,
    required String attachmentId,
  }) {
    return _stager.discard(projectId: projectId, attachmentId: attachmentId);
  }
}

final class LocalReceiptScanGateway implements ReceiptScanGateway {
  factory LocalReceiptScanGateway({
    required ReceiptAttachmentStore attachmentStore,
    required ReceiptSourcePicker scanner,
    required ReceiptSourcePicker filePicker,
    required ReceiptOcrImagePreparer imagePreparer,
    required ReceiptTextRecognizer textRecognizer,
    ReceiptOcrCandidateParser candidateParser =
        const ReceiptOcrCandidateParser(),
  }) {
    return LocalReceiptScanGateway._(
      attachmentStore,
      scanner,
      filePicker,
      imagePreparer,
      textRecognizer,
      candidateParser,
    );
  }

  const LocalReceiptScanGateway._(
    this._attachmentStore,
    this._scanner,
    this._filePicker,
    this._imagePreparer,
    this._textRecognizer,
    this._candidateParser,
  );

  final ReceiptAttachmentStore _attachmentStore;
  final ReceiptSourcePicker _scanner;
  final ReceiptSourcePicker _filePicker;
  final ReceiptOcrImagePreparer _imagePreparer;
  final ReceiptTextRecognizer _textRecognizer;
  final ReceiptOcrCandidateParser _candidateParser;

  @override
  Future<StagedReceiptSource?> capture({
    required String projectId,
    required ReceiptCaptureMethod method,
  }) async {
    final picker = switch (method) {
      ReceiptCaptureMethod.scanner => _scanner,
      ReceiptCaptureMethod.fileImport => _filePicker,
    };
    final picked = await picker.pick();
    if (picked == null) return null;

    StagedLocalAttachment? staged;
    try {
      staged = await _attachmentStore.stage(
        projectId: projectId,
        pickedFile: picked.attachment,
      );
      final mediaType = staged.mediaType;
      final original = await _attachmentStore.original(
        projectId: projectId,
        attachmentId: staged.id,
      );
      final preview = await _attachmentStore.preview(
        projectId: projectId,
        attachmentId: staged.id,
      );
      if (mediaType == null || original == null || preview == null) {
        throw const ReceiptScanException(ReceiptScanFailureKind.storage);
      }
      return StagedReceiptSource(
        projectId: projectId,
        attachmentId: staged.id,
        captureMethod: picked.captureMethod,
        mediaType: mediaType,
        originalUri: original,
        previewUri: preview,
      );
    } on ReceiptScanException {
      if (staged != null) await _discardBestEffort(staged);
      rethrow;
    } on UnsupportedError {
      if (staged != null) await _discardBestEffort(staged);
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    } on Object {
      if (staged != null) await _discardBestEffort(staged);
      throw const ReceiptScanException(ReceiptScanFailureKind.storage);
    } finally {
      if (picked.deleteAfterStaging) {
        await _deleteSourceBestEffort(picked.attachment.sourceUri);
      }
    }
  }

  @override
  Future<ReceiptScanSession> recognize(StagedReceiptSource source) async {
    PreparedReceiptImage? prepared;
    try {
      prepared = await _imagePreparer.prepare(
        originalUri: source.originalUri,
        mediaType: source.mediaType,
      );
      final recognizedText = await _textRecognizer.recognize(prepared.imageUri);
      if (recognizedText.isEmpty) {
        throw const ReceiptScanException(ReceiptScanFailureKind.emptyText);
      }
      return ReceiptScanSession(
        source: source,
        candidates: _candidateParser.parse(recognizedText),
      );
    } on ReceiptScanException {
      rethrow;
    } on Object {
      throw const ReceiptScanException(ReceiptScanFailureKind.recognition);
    } finally {
      await prepared?.dispose();
    }
  }

  @override
  Future<void> discard(StagedReceiptSource source) {
    return _attachmentStore.discard(
      projectId: source.projectId,
      attachmentId: source.attachmentId,
    );
  }

  Future<void> _discardBestEffort(StagedLocalAttachment staged) async {
    try {
      await _attachmentStore.discard(
        projectId: staged.projectId,
        attachmentId: staged.id,
      );
    } on Object {
      // Startup recovery removes an available attachment left without links.
    }
  }
}

Future<void> _deleteSourceBestEffort(Uri sourceUri) async {
  try {
    final source = File.fromUri(sourceUri);
    if (await source.exists()) await source.delete();
  } on FileSystemException {
    // The scanner cache can also be reclaimed by its owning system component.
  }
}
