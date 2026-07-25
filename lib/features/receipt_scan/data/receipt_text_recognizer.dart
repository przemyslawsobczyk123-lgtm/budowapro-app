import 'dart:io';

import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

typedef RecognizeReceiptImage =
    Future<List<RecognizedReceiptLine>> Function(String path);

abstract interface class ReceiptTextRecognizer {
  Future<RecognizedReceiptText> recognize(Uri imageUri);
}

final class MlKitReceiptTextRecognizer implements ReceiptTextRecognizer {
  MlKitReceiptTextRecognizer({RecognizeReceiptImage? recognizeImage})
    : _recognizeImage = recognizeImage ?? _recognizeWithMlKit;

  final RecognizeReceiptImage _recognizeImage;

  @override
  Future<RecognizedReceiptText> recognize(Uri imageUri) async {
    if (!imageUri.isScheme('file')) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    final image = File.fromUri(imageUri);
    if (!await image.exists() || await image.length() == 0) {
      throw const ReceiptScanException(ReceiptScanFailureKind.unsupportedInput);
    }
    try {
      return RecognizedReceiptText.fromLines(
        await _recognizeImage(image.absolute.path),
      );
    } on ReceiptScanException {
      rethrow;
    } on Object {
      throw const ReceiptScanException(ReceiptScanFailureKind.recognition);
    }
  }

  static Future<List<RecognizedReceiptLine>> _recognizeWithMlKit(
    String path,
  ) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return <RecognizedReceiptLine>[
        for (final block in result.blocks)
          for (final line in block.lines)
            RecognizedReceiptLine(text: line.text, confidence: line.confidence),
      ];
    } finally {
      try {
        await recognizer.close();
      } on Object {
        // A close failure must not replace successfully recognized text.
      }
    }
  }
}
