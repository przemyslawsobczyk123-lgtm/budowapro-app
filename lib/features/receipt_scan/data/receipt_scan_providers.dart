import 'dart:math';

import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_receipt_scan_gateway.dart';
import 'receipt_capture_adapters.dart';
import 'receipt_ocr_image_preparer.dart';
import 'receipt_text_recognizer.dart';
import 'sqlite_receipt_financial_repository.dart';

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

final receiptFinancialRepositoryProvider =
    FutureProvider<ReceiptFinancialRepository>((ref) async {
      final database = await ref.watch(appDatabaseProvider.future);
      final costs = SqliteCostRepository(
        database: database,
        idGenerator: _secureReceiptId,
        utcNow: DateTime.now,
      );
      return SqliteReceiptFinancialRepository(
        database: database,
        costRepository: costs,
        idGenerator: _secureReceiptId,
        utcNow: DateTime.now,
      );
    });

String _secureReceiptId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
