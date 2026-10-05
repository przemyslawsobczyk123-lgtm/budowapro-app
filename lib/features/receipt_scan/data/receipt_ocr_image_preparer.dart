import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:budowapro/core/files/local_file_preflight.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:image/image.dart' as image;
import 'package:pdfrx/pdfrx.dart';

typedef RenderReceiptPdfPages =
    Future<List<Uri>> Function(File source, Directory targetDirectory);
typedef DisposePreparedReceiptImages = Future<void> Function();

final class PreparedReceiptImages {
  factory PreparedReceiptImages({
    required Iterable<Uri> imageUris,
    required DisposePreparedReceiptImages disposeImage,
  }) {
    final normalized = List<Uri>.unmodifiable(imageUris);
    if (normalized.isEmpty) {
      throw ArgumentError.value(imageUris, 'imageUris', 'must not be empty');
    }
    return PreparedReceiptImages._(normalized, disposeImage);
  }

  PreparedReceiptImages._(this.imageUris, this._disposeImage);

  final List<Uri> imageUris;
  final DisposePreparedReceiptImages _disposeImage;
  bool _isDisposed = false;

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _disposeImage();
  }
}

abstract interface class ReceiptOcrImagePreparer {
  Future<PreparedReceiptImages> prepare({
    required Uri originalUri,
    required String mediaType,
  });
}

final class LocalReceiptOcrImagePreparer implements ReceiptOcrImagePreparer {
  LocalReceiptOcrImagePreparer({RenderReceiptPdfPages? renderPdfPages})
    : _renderPdfPages = renderPdfPages ?? _renderAllPdfPages;

  static const int maximumWidth = 1600;
  static const int maximumHeight = 2400;
  static const int maximumPdfPages = 20;

  final RenderReceiptPdfPages _renderPdfPages;

  @override
  Future<PreparedReceiptImages> prepare({
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
      late final LocalImageInspection inspection;
      try {
        inspection = await LocalFilePreflight.inspectImage(
          original,
          maximumBytes: LocalFilePreflight.maximumOcrInputBytes,
          maximumPixels: LocalFilePreflight.maximumDecodedImagePixels,
        );
      } on FormatException {
        throw const ReceiptScanException(
          ReceiptScanFailureKind.unsupportedInput,
        );
      }
      if (inspection.width <= maximumWidth &&
          inspection.height <= maximumHeight) {
        return PreparedReceiptImages(
          imageUris: <Uri>[originalUri],
          disposeImage: () async {},
        );
      }
      return _prepareDownscaledImage(original);
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
    late final List<Uri> renderedPages;
    try {
      renderedPages = await _renderPdfPages(original, temporaryDirectory);
      if (renderedPages.isEmpty || renderedPages.length > maximumPdfPages) {
        throw const FormatException('Rendered receipt page count is invalid');
      }
      for (final pageUri in renderedPages) {
        if (!pageUri.isScheme('file')) {
          throw const FormatException('Rendered receipt page is not local');
        }
        final page = File.fromUri(pageUri);
        if (!await page.exists() || await page.length() == 0) {
          throw const FormatException('Rendered receipt page is empty');
        }
      }
    } on Object catch (error, stackTrace) {
      await _deleteTemporaryDirectory(temporaryDirectory);
      if (error is ReceiptScanException) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    return PreparedReceiptImages(
      imageUris: renderedPages,
      disposeImage: () => _deleteTemporaryDirectory(temporaryDirectory),
    );
  }

  static Future<PreparedReceiptImages> _prepareDownscaledImage(
    File original,
  ) async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_receipt_ocr_',
    );
    final target = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}receipt.jpg',
    );
    try {
      final command = image.Command()
        ..decodeImageFile(original.path)
        ..copyResize(
          width: maximumWidth,
          height: maximumHeight,
          maintainAspect: true,
          interpolation: image.Interpolation.linear,
        )
        ..encodeJpgFile(target.path, quality: 90);
      await command.executeThread();
      if (!await target.exists() || await target.length() == 0) {
        throw const FormatException('Downscaled receipt image is empty');
      }
      return PreparedReceiptImages(
        imageUris: <Uri>[target.uri],
        disposeImage: () => _deleteTemporaryDirectory(temporaryDirectory),
      );
    } on Object catch (error, stackTrace) {
      await _deleteTemporaryDirectory(temporaryDirectory);
      if (error is ReceiptScanException) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
  }

  static Future<List<Uri>> _renderAllPdfPages(
    File source,
    Directory targetDirectory,
  ) async {
    final document = await PdfDocument.openFile(source.path);
    try {
      if (document.pages.isEmpty) {
        throw const FormatException('PDF has no pages');
      }
      if (document.pages.length > maximumPdfPages) {
        throw const ReceiptScanException(
          ReceiptScanFailureKind.unsupportedInput,
        );
      }
      final targets = <Uri>[];
      final pageCount = document.pages.length;
      for (var index = 0; index < pageCount; index += 1) {
        final page = await document.pages[index].ensureLoaded();
        final scale = <double>[
          maximumWidth / page.width,
          maximumHeight / page.height,
        ].reduce((first, second) => first < second ? first : second);
        final targetWidth = (page.width * scale).round().clamp(1, maximumWidth);
        final targetHeight = (page.height * scale).round().clamp(
          1,
          maximumHeight,
        );
        final rendered = await page.render(
          width: targetWidth,
          height: targetHeight,
          fullWidth: targetWidth.toDouble(),
          fullHeight: targetHeight.toDouble(),
          backgroundColor: 0xFFFFFFFF,
        );
        if (rendered == null) {
          throw const FormatException('PDF page could not be rendered');
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
          final target = File(
            '${targetDirectory.path}${Platform.pathSeparator}'
            'page-${(index + 1).toString().padLeft(3, '0')}.jpg',
          );
          await target.writeAsBytes(bytes, flush: true);
          targets.add(target.uri);
        } finally {
          rendered.dispose();
        }
      }
      return targets;
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
