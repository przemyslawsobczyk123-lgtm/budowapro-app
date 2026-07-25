import 'dart:async';

import 'package:budowapro/core/theme/app_theme.dart';
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
    expect(find.text('Zeskanuj paragon'), findsOneWidget);
    expect(find.text('Importuj obraz lub PDF'), findsOneWidget);
  });

  testWidgets('shows processing while the user-triggered scanner is open', (
    tester,
  ) async {
    final capture = Completer<StagedReceiptSource?>();
    final gateway = _FakeGateway(captureFuture: capture.future);
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
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
          seller: 'SKŁAD BUDOWLANY',
          dateText: '25.07.2026',
          totalText: '42,50',
          vatLines: const <String>['PTU A 23% 7,95'],
        ),
      ),
    );
    await tester.pumpWidget(_app(gateway));

    await tester.tap(find.byKey(const ValueKey('scanReceiptButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('receiptScanResult')), findsOneWidget);
    expect(find.text('SKŁAD BUDOWLANY'), findsOneWidget);
    expect(find.text('42,50'), findsOneWidget);
    expect(find.text('Budżet bez zmian'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
}

Widget _app(ReceiptScanGateway gateway) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    home: ReceiptScanScreen(projectId: 'project-1', gateway: gateway),
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
