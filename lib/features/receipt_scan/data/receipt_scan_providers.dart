import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_receipt_scan_gateway.dart';
import 'receipt_capture_adapters.dart';
import 'receipt_ocr_image_preparer.dart';
import 'receipt_text_recognizer.dart';

final receiptScanGatewayProvider = FutureProvider<ReceiptScanGateway>((
  ref,
) async {
  final stager = await ref.watch(localAttachmentStagerProvider.future);
  return LocalReceiptScanGateway(
    attachmentStore: LocalReceiptAttachmentStore(stager),
    scanner: MlKitReceiptDocumentScanner(),
    filePicker: FilePickerReceiptSourcePicker(),
    imagePreparer: LocalReceiptOcrImagePreparer(),
    textRecognizer: MlKitReceiptTextRecognizer(),
  );
});
