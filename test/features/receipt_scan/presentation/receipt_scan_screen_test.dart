import 'dart:async';

import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_ocr.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:budowapro/features/receipt_scan/presentation/receipt_scan_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens idle and never starts the scanner automatically', (
    tester,
  ) async {
    final gateway = _FakeGateway();

    await tester.pumpWidget(_app(gateway));

    expect(find.byKey(const ValueKey('receiptScanIdle')), findsOneWidget);
    expect(gateway.captureCalls, 0);
    expect(find.text('Zeskanuj dokument'), findsOneWidget);
    expect(find.text('Importuj obraz lub PDF'), findsOneWidget);
  });

  testWidgets('shows processing while the user-triggered scanner is open', (
    tester,
  ) async {
    final capture = Completer<StagedReceiptSource?>();
    final gateway = _FakeGateway(captureFuture: capture.future);
    await tester.pumpWidget(_app(gateway));

    final scanButton = find.byKey(const ValueKey('scanReceiptButton'));
    await tester.scrollUntilVisible(scanButton, 200);
    await tester.tap(scanButton);
    await tester.pump();

    expect(find.byKey(const ValueKey('receiptScanProcessing')), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    capture.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('fits a provisional OCR result at 320 px', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: ReceiptScanSession(
        source: _source,
        candidates: ReceiptOcrCandidates(
          recognizedText: RecognizedReceiptText.fromRaw(
            'SKŁAD BUDOWLANY\nPTU A 23% 7,95\nRAZEM 42,50',
          ),
          seller: ReceiptOcrField(value: 'SKŁAD BUDOWLANY', confidence: 0.96),
          dateText: ReceiptOcrField(value: '25.07.2026', confidence: 0.93),
          totalText: ReceiptOcrField(value: '42,50', confidence: 0.92),
          vatLines: <ReceiptOcrField>[
            ReceiptOcrField(value: 'PTU A 23% 7,95', confidence: 0.89),
          ],
        ),
      ),
    );
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('receiptScanResult')), findsOneWidget);
    expect(find.text('SKŁAD BUDOWLANY'), findsOneWidget);
    expect(find.text('42,50'), findsOneWidget);
    await _scrollReceiptResultTo(
      tester,
      find.byKey(const ValueKey('receiptBudgetUnchanged')),
    );
    expect(find.text('Budżet bez zmian'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits an item editor at 320 px with 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: _reviewableSession(),
    );
    await tester.pumpWidget(_app(gateway, textScaler: TextScaler.linear(2)));

    final scanButton = find.byKey(const ValueKey('scanReceiptButton'));
    await tester.scrollUntilVisible(scanButton, 200);
    await tester.tap(scanButton);
    await tester.pumpAndSettle();
    await _scrollReceiptResultTo(
      tester,
      find.byKey(const ValueKey('receiptItemAmount-ocr-item-1')),
    );

    expect(
      find.textContaining('OCR nie ustala pewnej stawki VAT'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('builds receipt item cards lazily', (tester) async {
    final itemLines = <ReceiptOcrField>[
      for (var index = 1; index <= 240; index += 1)
        ReceiptOcrField(value: 'Pozycja $index 1,00', confidence: 0.95),
    ];
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: ReceiptScanSession(
        source: _source,
        candidates: ReceiptOcrCandidates(
          recognizedText: RecognizedReceiptText.fromRaw('PARAGON'),
          seller: ReceiptOcrField(value: 'MARKET', confidence: 0.95),
          dateText: ReceiptOcrField(value: '25.07.2026', confidence: 0.95),
          totalText: ReceiptOcrField(value: '240,00', confidence: 0.95),
          itemLines: itemLines,
        ),
      ),
    );
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('receiptItem-ocr-item-240')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('receiptScanResult')), findsOneWidget);
  });

  testWidgets('offers file fallback when the scanner is unavailable', (
    tester,
  ) async {
    final gateway = _FakeGateway(
      captureFailure: const ReceiptScanException(
        ReceiptScanFailureKind.scannerUnavailable,
      ),
    );
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('receiptScanError')), findsOneWidget);
    expect(find.text('Skaner jest niedostępny'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('receiptFallbackImportButton')),
      findsOneWidget,
    );
  });

  testWidgets('saves reviewed lines as drafts only after an explicit tap', (
    tester,
  ) async {
    final financial = _FakeFinancialRepository();
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: ReceiptScanSession(
        source: _source,
        candidates: ReceiptOcrCandidates(
          recognizedText: RecognizedReceiptText.fromRaw(
            'MARKET\n25.07.2026\nKlej 30,00\nGrunt 20,00\nRAZEM 50,00',
          ),
          seller: ReceiptOcrField(value: 'MARKET', confidence: 0.96),
          dateText: ReceiptOcrField(value: '25.07.2026', confidence: 0.95),
          totalText: ReceiptOcrField(value: '50,00', confidence: 0.94),
          itemLines: <ReceiptOcrField>[
            ReceiptOcrField(value: 'Klej 30,00', confidence: 0.94),
            ReceiptOcrField(value: 'Grunt 20,00', confidence: 0.93),
          ],
        ),
      ),
    );
    await tester.pumpWidget(_app(gateway, financial: financial));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    expect(financial.saveCalls, 0);
    await _confirmAllReceiptItems(tester);
    final saveButton = find.byKey(const ValueKey('saveReceiptDraftsButton'));
    await _scrollReceiptResultTo(tester, saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(financial.saveCalls, 1);
    expect(financial.lastBatch?.lines, hasLength(2));
    expect(find.byKey(const ValueKey('receiptSaved')), findsOneWidget);
    expect(
      find.textContaining('Liczba zapisanych szkiców kosztów: 2'),
      findsOneWidget,
    );
  });

  testWidgets('requires confirmation of a low-confidence OCR field', (
    tester,
  ) async {
    final financial = _FakeFinancialRepository();
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: _reviewableSession(sellerConfidence: 0.61),
    );
    await tester.pumpWidget(_app(gateway, financial: financial));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Niepewny odczyt'), findsOneWidget);
    final seller = find.byKey(const ValueKey('receiptSellerInput'));
    final confirm = find.descendant(
      of: seller,
      matching: find.byType(IconButton),
    );
    expect(confirm, findsOneWidget);
    await tester.tap(confirm);
    await tester.pump();

    await _confirmAllReceiptItems(tester);
    final saveButton = find.byKey(const ValueKey('saveReceiptDraftsButton'));
    await _scrollReceiptResultTo(tester, saveButton);
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
  });

  testWidgets('requires an explicit override for a suspected duplicate', (
    tester,
  ) async {
    final financial = _FakeFinancialRepository(
      duplicateCheck: ReceiptDuplicateCheck(const <ReceiptDuplicateReason>[
        ReceiptDuplicateReason.receiptSignature,
      ]),
    );
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: _reviewableSession(),
    );
    await tester.pumpWidget(_app(gateway, financial: financial));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();
    await _confirmAllReceiptItems(tester);
    final saveButton = find.byKey(const ValueKey('saveReceiptDraftsButton'));
    await _scrollReceiptResultTo(tester, saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(financial.saveCalls, 0);
    final override = find.byKey(const ValueKey('saveDuplicateReceiptButton'));
    await _scrollReceiptResultTo(tester, override);
    await tester.tap(override);
    await tester.pumpAndSettle();

    expect(financial.saveCalls, 1);
    expect(financial.duplicateAcknowledged, isTrue);
    expect(find.byKey(const ValueKey('receiptSaved')), findsOneWidget);
  });

  testWidgets('shows the merged item name and amount immediately', (
    tester,
  ) async {
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: _reviewableSession(),
    );
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();
    final merge = find.byKey(const ValueKey('mergeReceiptItem-0'));
    await _scrollReceiptResultTo(tester, merge);
    await tester.tap(merge);
    await tester.pump();

    expect(
      _editableText(
        tester,
        find.byKey(const ValueKey('receiptItemName-ocr-item-1')),
      ),
      'Klej + Grunt',
    );
    expect(
      _editableText(
        tester,
        find.byKey(const ValueKey('receiptItemAmount-ocr-item-1')),
      ),
      '50,00',
    );
    expect(find.byKey(const ValueKey('receiptItem-ocr-item-2')), findsNothing);
  });

  testWidgets('can copy the item sum into a missing document total', (
    tester,
  ) async {
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: ReceiptScanSession(
        source: _source,
        candidates: ReceiptOcrCandidates(
          recognizedText: RecognizedReceiptText.fromRaw('PARAGON'),
          seller: ReceiptOcrField(value: 'MARKET', confidence: 0.95),
          dateText: ReceiptOcrField(value: '25.07.2026', confidence: 0.95),
          itemLines: <ReceiptOcrField>[
            ReceiptOcrField(value: 'Klej 5,99', confidence: 0.95),
            ReceiptOcrField(value: 'Grunt 13,41', confidence: 0.95),
          ],
        ),
      ),
    );
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    final action = find.byKey(const ValueKey('useReceiptItemsTotalButton'));
    await _scrollReceiptResultTo(tester, action);
    expect(find.text('Suma pozycji'), findsOneWidget);
    expect(find.text('19,40 PLN'), findsOneWidget);
    await tester.tap(action);
    await tester.pump();

    await _scrollReceiptResultToStart(tester);
    final totalField = find.byKey(const ValueKey('receiptTotalInput'));
    expect(_editableText(tester, totalField), '19,40');
  });

  testWidgets('can replace unreliable OCR rows with one document cost', (
    tester,
  ) async {
    final gateway = _FakeGateway(
      captureResult: _source,
      recognitionResult: _reviewableSession(),
    );
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    final action = find.byKey(
      const ValueKey('replaceReceiptItemsWithDocumentTotalButton'),
    );
    await _scrollReceiptResultTo(tester, action);
    await tester.tap(action);
    await tester.pump();

    await _scrollReceiptResultToStart(tester);
    final singleItem = find.byKey(const ValueKey('receiptItem-review-item-3'));
    await _scrollReceiptResultTo(tester, singleItem);
    expect(find.byKey(const ValueKey('receiptItem-ocr-item-1')), findsNothing);
    expect(singleItem, findsOneWidget);
    expect(
      _editableText(
        tester,
        find.byKey(const ValueKey('receiptItemName-review-item-3')),
      ),
      'Zakup z dokumentu',
    );
    expect(
      _editableText(
        tester,
        find.byKey(const ValueKey('receiptItemAmount-review-item-3')),
      ),
      '50,00',
    );
  });
}

Future<void> _confirmAllReceiptItems(WidgetTester tester) async {
  for (final itemId in <String>['ocr-item-1', 'ocr-item-2']) {
    final confirm = find.byKey(ValueKey('confirmReceiptItem-$itemId'));
    await _scrollReceiptResultTo(tester, confirm);
    await tester.tap(confirm);
    await tester.pump();
  }
}

Future<void> _scrollReceiptResultTo(WidgetTester tester, Finder target) async {
  final result = find.byKey(const ValueKey('receiptScanResult'));
  await tester.scrollUntilVisible(
    target,
    300,
    scrollable: find
        .descendant(of: result, matching: find.byType(Scrollable))
        .first,
  );
}

Future<void> _scrollReceiptResultToStart(WidgetTester tester) async {
  final result = find.byKey(const ValueKey('receiptScanResult'));
  final scrollable = find
      .descendant(of: result, matching: find.byType(Scrollable))
      .first;
  for (var attempt = 0; attempt < 8; attempt += 1) {
    if (find.byKey(const ValueKey('receiptTotalInput')).evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(scrollable, const Offset(0, 500));
    await tester.pump();
  }
}

String _editableText(WidgetTester tester, Finder field) {
  return tester
      .widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      )
      .controller
      .text;
}

Widget _app(
  ReceiptScanGateway gateway, {
  ReceiptFinancialRepository? financial,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: ReceiptScanScreen(
      projectId: 'project-1',
      gateway: gateway,
      financialRepository: financial ?? _FakeFinancialRepository(),
      currencyCode: 'PLN',
    ),
  );
}

final StagedReceiptSource _source = StagedReceiptSource(
  projectId: 'project-1',
  attachmentId: 'attachment-1',
  captureMethod: ReceiptCaptureMethod.scanner,
  mediaType: 'image/jpeg',
  originalUri: Uri(path: 'C:/private/original.jpg', scheme: 'file'),
  previewUri: Uri(path: 'C:/private/missing-preview.jpg', scheme: 'file'),
);

ReceiptScanSession _reviewableSession({double sellerConfidence = 0.96}) {
  return ReceiptScanSession(
    source: _source,
    candidates: ReceiptOcrCandidates(
      recognizedText: RecognizedReceiptText.fromRaw(
        'MARKET\n25.07.2026\nKlej 30,00\nGrunt 20,00\nRAZEM 50,00',
      ),
      seller: ReceiptOcrField(value: 'MARKET', confidence: sellerConfidence),
      dateText: ReceiptOcrField(value: '25.07.2026', confidence: 0.95),
      totalText: ReceiptOcrField(value: '50,00', confidence: 0.94),
      itemLines: <ReceiptOcrField>[
        ReceiptOcrField(value: 'Klej 30,00', confidence: 0.94),
        ReceiptOcrField(value: 'Grunt 20,00', confidence: 0.93),
      ],
    ),
  );
}

final class _FakeGateway implements ReceiptScanGateway {
  _FakeGateway({
    this.captureResult,
    this.recognitionResult,
    this.captureFailure,
    this.captureFuture,
  });

  final StagedReceiptSource? captureResult;
  final ReceiptScanSession? recognitionResult;
  final ReceiptScanException? captureFailure;
  final Future<StagedReceiptSource?>? captureFuture;
  int captureCalls = 0;

  @override
  Future<StagedReceiptSource?> capture({
    required String projectId,
    required ReceiptCaptureMethod method,
  }) async {
    captureCalls += 1;
    if (captureFailure case final failure?) throw failure;
    return captureFuture ?? Future<StagedReceiptSource?>.value(captureResult);
  }

  @override
  Future<ReceiptScanSession> recognize(StagedReceiptSource source) async {
    return recognitionResult!;
  }

  @override
  Future<void> discard(StagedReceiptSource source) async {}
}

final class _FakeFinancialRepository implements ReceiptFinancialRepository {
  _FakeFinancialRepository({ReceiptDuplicateCheck? duplicateCheck})
    : duplicateCheck =
          duplicateCheck ??
          ReceiptDuplicateCheck(const <ReceiptDuplicateReason>[]);

  final ReceiptDuplicateCheck duplicateCheck;
  int saveCalls = 0;
  ReviewedReceiptBatch? lastBatch;
  bool duplicateAcknowledged = false;

  @override
  Future<ReceiptDuplicateCheck> checkDuplicates(
    ReviewedReceiptBatch batch,
  ) async {
    return duplicateCheck;
  }

  @override
  Future<ReceiptDraftBatchResult> saveReviewedDrafts(
    ReviewedReceiptBatch batch, {
    bool duplicateAcknowledged = false,
  }) async {
    saveCalls += 1;
    lastBatch = batch;
    this.duplicateAcknowledged = duplicateAcknowledged;
    return ReceiptDraftBatchResult(
      drafts: <CostEntry>[
        for (var index = 0; index < batch.lines.length; index += 1)
          CostEntry(
            id: 'draft-$index',
            input: CostEntryInput(
              projectId: batch.projectId,
              name: batch.lines[index].name,
              type: CostEntryType.cost,
              status: CostStatus.planned,
              amount: VatBreakdown.fromGross(
                Money(
                  minorUnits: batch.lines[index].grossMinorUnits,
                  currencyCode: batch.currencyCode,
                ),
                batch.lines[index].vatRate,
              ),
              entryDate: batch.purchaseDate,
              source: CostSource.receiptOcr,
              attachmentIds: <String>[batch.attachmentId],
            ),
            lifecycle: CostLifecycle.draft,
            createdAt: DateTime.utc(2026, 7, 25),
            updatedAt: DateTime.utc(2026, 7, 25),
          ),
      ],
      duplicateAcknowledged: duplicateAcknowledged,
    );
  }
}
