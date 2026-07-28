import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:budowapro/core/files/local_file_preflight.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:image/image.dart' as image;
import 'package:pdfrx/pdfrx.dart';

typedef RenderFirstReceiptPdfPage =
    Future<void> Function(File source, File target);
typedef DisposePreparedReceiptImage = Future<void> Function();

final class PreparedReceiptImage {
  factory PreparedReceiptImage({
    required Uri imageUri,
    required DisposePreparedReceiptImage disposeImage,
  }) {
    return PreparedReceiptImage._(imageUri, disposeImage);
  }

  PreparedReceiptImage._(this.imageUri, this._disposeImage);

  final Uri imageUri;
  final DisposePreparedReceiptImage _disposeImage;
  bool _isDisposed = false;

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _disposeImage();
  }
}

abstract interface class ReceiptOcrImagePreparer {
  Future<PreparedReceiptImage> prepare({
    required Uri originalUri,
    required String mediaType,
  });
}

final class LocalReceiptOcrImagePreparer implements ReceiptOcrImagePreparer {
  LocalReceiptOcrImagePreparer({RenderFirstReceiptPdfPage? renderPdfFirstPage})
    : _renderPdfFirstPage = renderPdfFirstPage ?? _renderFirstPdfPage;

  static const int maximumWidth = 1600;
  static const int maximumHeight = 2400;

  final RenderFirstReceiptPdfPage _renderPdfFirstPage;

  @override
  Future<PreparedReceiptImage> prepare({
    required Uri originalUri,
    required String mediaType,
  }) async {
    if (!originalUri.isScheme('file')) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    final original = File.fromUri(originalUri);
    if (!await original.exists() || await original.length() == 0) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    if (mediaType.startsWith('image/')) {
      try {
        await LocalFilePreflight.inspectImage(
          original,
          maximumBytes: LocalFilePreflight.maximumOcrInputBytes,
          maximumPixels: LocalFilePreflight.maximumDecodedImagePixels,
        );
      } on FormatException {
        throw const ReceiptScanException(
          ReceiptScanFailureKind.unsupportedInput,
        );
      }
      return PreparedReceiptImage(
        imageUri: originalUri,
        disposeImage: () async {},
      );
    }
    if (mediaType != 'application/pdf') {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    try {
      await LocalFilePreflight.requirePdf(
        original,
        maximumBytes: LocalFilePreflight.maximumOcrInputBytes,
      );
    } on FormatException {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }

    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_receipt_ocr_',
    );
    final target = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}first-page.jpg',
    );
    try {
      await _renderPdfFirstPage(original, target);
      if (!await target.exists() || await target.length() == 0) {
        throw const FormatException('Rendered receipt page is empty');
      }
    } on Object catch (error, stackTrace) {
      await _deleteTemporaryDirectory(temporaryDirectory);
      if (error is ReceiptScanException) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    return PreparedReceiptImage(
      imageUri: target.uri,
      disposeImage: () => _deleteTemporaryDirectory(temporaryDirectory),
    );
  }

  static Future<void> _renderFirstPdfPage(File source, File target) async {
    final document = await PdfDocument.openFile(source.path);
    try {
      if (document.pages.isEmpty) {
        throw const FormatException('PDF has no pages');
      }
      final page = await document.pages.first.ensureLoaded();
      final targetWidth = maximumWidth;
      final targetHeight = (targetWidth * page.height / page.width)
          .round()
          .clamp(1, maximumHeight);
      final rendered = await page.render(
        width: targetWidth,
        height: targetHeight,
        fullWidth: targetWidth.toDouble(),
        fullHeight: targetHeight.toDouble(),
        backgroundColor: 0xFFFFFFFF,
      );
      if (rendered == null) {
        throw const FormatException('PDF first page could not be rendered');
      }
      try {
        final transferable = TransferableTypedData.fromList(<Uint8List>[
          rendered.pixels,
        ]);
        final bytes = await Isolate.run<Uint8List>(
          () => _encodeReceiptPage(
            transferable,
            width: rendered.width,
            height: rendered.height,
          ),
        );
        await target.writeAsBytes(bytes, flush: true);
      } finally {
        rendered.dispose();
      }
    } finally {
      await document.dispose();
    }
  }
}

Future<void> _deleteTemporaryDirectory(Directory directory) async {
  try {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  } on FileSystemException {
    // Temporary cleanup is best effort; startup storage cleanup remains intact.
  }
}

Uint8List _encodeReceiptPage(
  TransferableTypedData source, {
  required int width,
  required int height,
}) {
  final pixels = source.materialize().asUint8List();
  final decoded = image.Image.fromBytes(
    width: width,
    height: height,
    bytes: pixels.buffer,
    bytesOffset: pixels.offsetInBytes,
    numChannels: 4,
    order: image.ChannelOrder.bgra,
  );
  return image.encodeJpg(decoded, quality: 90);
}
