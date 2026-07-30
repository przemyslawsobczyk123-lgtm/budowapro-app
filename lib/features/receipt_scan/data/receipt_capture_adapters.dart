import 'dart:io';

import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path/path.dart' as p;

typedef ScanReceiptDocument = Future<Uri?> Function();
typedef PickReceiptFile = Future<FilePickerResult?> Function();

final class PickedReceiptSource {
  const PickedReceiptSource({
    required this.attachment,
    required this.captureMethod,
    required this.deleteAfterStaging,
  });

  final PickedLocalAttachment attachment;
  final ReceiptCaptureMethod captureMethod;
  final bool deleteAfterStaging;
}

abstract interface class ReceiptSourcePicker {
  Future<PickedReceiptSource?> pick();
}

final class MlKitReceiptDocumentScanner implements ReceiptSourcePicker {
  MlKitReceiptDocumentScanner({ScanReceiptDocument? scanDocument})
    : _scanDocument = scanDocument ?? _scanSingleDocument;

  final ScanReceiptDocument _scanDocument;

  @override
  Future<PickedReceiptSource?> pick() async {
    final Uri? sourceUri;
    try {
      sourceUri = await _scanDocument();
    } on PlatformException catch (error) {
      if (error.code == 'DocumentScanner' &&
          error.message == 'Operation cancelled') {
        return null;
      }
      throw const ReceiptScanException(
        ReceiptScanFailureKind.scannerUnavailable,
      );
    } on ReceiptScanException {
      rethrow;
    } on Object {
      throw const ReceiptScanException(
        ReceiptScanFailureKind.scannerUnavailable,
      );
    }
    if (sourceUri == null) return null;
    if (!sourceUri.isScheme('file')) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    final file = File.fromUri(sourceUri);
    if (!await file.exists() || await file.length() == 0) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    return PickedReceiptSource(
      attachment: PickedLocalAttachment(
        sourceUri: sourceUri,
        displayName: 'paragon-skan.jpg',
        reportedByteSize: await file.length(),
        mediaType: 'image/jpeg',
        source: LocalAttachmentSource.scanner,
      ),
      captureMethod: ReceiptCaptureMethod.scanner,
      deleteAfterStaging: true,
    );
  }

  static Future<Uri?> _scanSingleDocument() async {
    if (Platform.isIOS) {
      final path = await const MethodChannel(
        'pl.budowapro/receipt_scanner',
      ).invokeMethod<String>('scan');
      if (path == null || path.trim().isEmpty) return null;
      return Uri.file(path);
    }
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const <DocumentFormat>{DocumentFormat.jpeg},
        pageLimit: 1,
        mode: ScannerMode.full,
        isGalleryImport: true,
      ),
    );
    try {
      final result = await scanner.scanDocument();
      final images = result.images;
      if (images == null || images.isEmpty) {
        throw const ReceiptScanException(
          ReceiptScanFailureKind.unsupportedInput,
        );
      }
      final path = images.first;
      return path.startsWith('file:') ? Uri.parse(path) : Uri.file(path);
    } finally {
      try {
        await scanner.close();
      } on Object {
        // A close failure must not replace a valid user-approved scan.
      }
    }
  }
}

final class FilePickerReceiptSourcePicker implements ReceiptSourcePicker {
  FilePickerReceiptSourcePicker({PickReceiptFile? pickFiles})
    : _pickFiles = pickFiles ?? _pickSingleReceipt;

  static const List<String> allowedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
    'pdf',
  ];

  final PickReceiptFile _pickFiles;

  @override
  Future<PickedReceiptSource?> pick() async {
    final result = await _pickFiles();
    if (result == null) return null;
    final selected = result.files.single;
    final sourcePath = selected.path;
    if (sourcePath == null) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    final extension = p.extension(selected.name).toLowerCase();
    if (!allowedExtensions.contains(extension.replaceFirst('.', ''))) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    return PickedReceiptSource(
      attachment: PickedLocalAttachment(
        sourceUri: Uri.file(sourcePath),
        displayName: selected.name,
        reportedByteSize: selected.size,
        mediaType: _receiptMediaType(extension),
      ),
      captureMethod: ReceiptCaptureMethod.fileImport,
      deleteAfterStaging: false,
    );
  }

  static Future<FilePickerResult?> _pickSingleReceipt() {
    return FilePicker.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
  }
}

String _receiptMediaType(String extension) {
  return switch (extension) {
    '.pdf' => 'application/pdf',
    '.png' => 'image/png',
    '.webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}
