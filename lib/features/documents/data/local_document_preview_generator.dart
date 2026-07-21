import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:budowapro/core/files/project_file_store.dart';
import 'package:image/image.dart' as image;
import 'package:pdfrx/pdfrx.dart';

import 'local_attachment_stager.dart';

final class LocalDocumentPreviewGenerator
    implements LocalAttachmentPreviewGenerator {
  factory LocalDocumentPreviewGenerator({required ProjectFileStore fileStore}) {
    return LocalDocumentPreviewGenerator._(fileStore);
  }

  const LocalDocumentPreviewGenerator._(this._fileStore);

  static const int maximumWidth = 320;
  static const int maximumHeight = 480;
  static const int maximumPreviewBytes = 5 * 1024 * 1024;

  final ProjectFileStore _fileStore;

  @override
  Future<String?> generate({
    required String projectId,
    required String attachmentId,
    required String originalStorageKey,
    required String? mediaType,
  }) async {
    if (mediaType != 'application/pdf' &&
        !(mediaType?.startsWith('image/') ?? false)) {
      return null;
    }
    final original = _fileStore.fileFor(
      projectId: projectId,
      area: ProjectFileArea.originals,
      fileName: originalStorageKey,
    );
    if (!await original.exists()) {
      throw const FileSystemException('Document original is missing');
    }
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_preview_',
    );
    final temporaryPreview = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}$attachmentId.jpg',
    );
    try {
      if (mediaType == 'application/pdf') {
        await _generatePdfPreview(original, temporaryPreview);
      } else {
        await _generateImagePreview(original, temporaryPreview);
      }
      if (!await temporaryPreview.exists() ||
          await temporaryPreview.length() == 0) {
        throw const FileSystemException('Generated preview is empty');
      }
      final previewStorageKey = '$attachmentId.jpg';
      await _fileStore.importFile(
        projectId: projectId,
        area: ProjectFileArea.previews,
        source: temporaryPreview,
        fileName: previewStorageKey,
        maximumBytes: maximumPreviewBytes,
      );
      return previewStorageKey;
    } finally {
      if (await temporaryPreview.exists()) {
        await temporaryPreview.delete();
      }
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete();
      }
    }
  }

  static Future<void> _generateImagePreview(File source, File target) async {
    final command = image.Command()
      ..decodeImageFile(source.path)
      ..copyResize(
        width: maximumWidth,
        height: maximumHeight,
        maintainAspect: true,
        interpolation: image.Interpolation.linear,
      )
      ..encodeJpgFile(target.path, quality: 82);
    await command.executeThread();
  }

  static Future<void> _generatePdfPreview(File source, File target) async {
    final document = await PdfDocument.openFile(source.path);
    try {
      if (document.pages.isEmpty) {
        throw const FormatException('PDF has no pages');
      }
      final page = await document.pages.first.ensureLoaded();
      final pageRatio = page.height / page.width;
      final targetWidth = maximumWidth;
      final targetHeight = (targetWidth * pageRatio).round().clamp(
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
        throw const FormatException('PDF first page could not be rendered');
      }
      try {
        final transferable = TransferableTypedData.fromList(<Uint8List>[
          rendered.pixels,
        ]);
        final bytes = await Isolate.run<Uint8List>(
          () => _encodeBgraJpeg(
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

Uint8List _encodeBgraJpeg(
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
  return image.encodeJpg(decoded, quality: 82);
}
