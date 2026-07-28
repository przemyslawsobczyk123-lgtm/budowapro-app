import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as image;

final class LocalImageInspection {
  const LocalImageInspection({
    required this.byteSize,
    required this.width,
    required this.height,
  });

  final int byteSize;
  final int width;
  final int height;
}

abstract final class LocalFilePreflight {
  static const int maximumOcrInputBytes = 32 * 1024 * 1024;
  static const int maximumPreviewInputBytes = 64 * 1024 * 1024;
  static const int maximumDecodedImagePixels = 48 * 1024 * 1024;

  static Future<LocalImageInspection> inspectImage(
    File file, {
    required int maximumBytes,
    required int maximumPixels,
  }) async {
    _requirePositiveLimits(maximumBytes, maximumPixels);
    final result = await Isolate.run<List<int>>(
      () => _inspectImage(
        file.absolute.path,
        maximumBytes: maximumBytes,
        maximumPixels: maximumPixels,
      ),
    );
    return LocalImageInspection(
      byteSize: result[0],
      width: result[1],
      height: result[2],
    );
  }

  static Future<void> requirePdf(File file, {required int maximumBytes}) {
    if (maximumBytes <= 0) {
      throw RangeError.value(maximumBytes, 'maximumBytes', 'must be positive');
    }
    return Isolate.run<void>(
      () => _requirePdf(file.absolute.path, maximumBytes),
    );
  }

  static void _requirePositiveLimits(int maximumBytes, int maximumPixels) {
    if (maximumBytes <= 0) {
      throw RangeError.value(maximumBytes, 'maximumBytes', 'must be positive');
    }
    if (maximumPixels <= 0) {
      throw RangeError.value(
        maximumPixels,
        'maximumPixels',
        'must be positive',
      );
    }
  }
}

List<int> _inspectImage(
  String path, {
  required int maximumBytes,
  required int maximumPixels,
}) {
  final file = File(path);
  final byteSize = _regularFileLength(file, maximumBytes);
  final bytes = file.readAsBytesSync();
  if (bytes.length != byteSize) {
    throw const FormatException('Image changed during validation');
  }
  final decoder = image.findDecoderForData(bytes);
  if (decoder == null ||
      !const <image.ImageFormat>{
        image.ImageFormat.jpg,
        image.ImageFormat.png,
        image.ImageFormat.webp,
      }.contains(decoder.format)) {
    throw const FormatException('Unsupported or invalid image');
  }
  final info = decoder.startDecode(bytes);
  if (info == null || info.width <= 0 || info.height <= 0) {
    throw const FormatException('Image dimensions are invalid');
  }
  final pixelCount = BigInt.from(info.width) * BigInt.from(info.height);
  if (pixelCount > BigInt.from(maximumPixels)) {
    throw const FormatException('Image dimensions exceed the safety limit');
  }
  return <int>[byteSize, info.width, info.height];
}

void _requirePdf(String path, int maximumBytes) {
  final file = File(path);
  _regularFileLength(file, maximumBytes);
  final handle = file.openSync();
  try {
    final header = handle.readSync(5);
    if (header.length != 5 ||
        header[0] != 0x25 ||
        header[1] != 0x50 ||
        header[2] != 0x44 ||
        header[3] != 0x46 ||
        header[4] != 0x2D) {
      throw const FormatException('PDF signature is invalid');
    }
  } finally {
    handle.closeSync();
  }
}

int _regularFileLength(File file, int maximumBytes) {
  if (FileSystemEntity.typeSync(file.path, followLinks: false) !=
      FileSystemEntityType.file) {
    throw const FormatException('Input must be a regular local file');
  }
  final byteSize = file.lengthSync();
  if (byteSize <= 0 || byteSize > maximumBytes) {
    throw const FormatException('Input file size is unsupported');
  }
  return byteSize;
}
