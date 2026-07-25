import 'dart:io';

import 'package:budowapro/features/receipt_scan/data/receipt_scan_providers.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'receipt_scan_controller.dart';

class ReceiptScanScreen extends ConsumerStatefulWidget {
  const ReceiptScanScreen({required this.projectId, this.gateway, super.key});

  final String projectId;
  final ReceiptScanGateway? gateway;

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  ReceiptScanController? _controller;

  @override
  void initState() {
    super.initState();
    final gateway = widget.gateway;
    if (gateway != null) _attachController(gateway);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final injectedGateway = widget.gateway;
    if (_controller == null && injectedGateway == null) {
      final gateway = ref.watch(receiptScanGatewayProvider);
      return gateway.when(
        data: (value) {
          _attachController(value);
          return _screen(l10n, _controller!);
        },
        loading: () => _loadingScreen(l10n),
        error: (_, _) => _gatewayErrorScreen(l10n),
      );
    }
    return _screen(l10n, _controller!);
  }

  Widget _screen(AppLocalizations l10n, ReceiptScanController controller) {
    final state = controller.state;
    return PopScope(
      canPop: !state.isBusy,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.receiptScanTitle)),
        body: SafeArea(
          child: switch (state.status) {
            ReceiptScanViewStatus.idle => _ReceiptScanIdle(
              onScan: () => controller.start(ReceiptCaptureMethod.scanner),
              onImport: () => controller.start(ReceiptCaptureMethod.fileImport),
            ),
            ReceiptScanViewStatus.processing => _ReceiptScanProcessing(
              operation: state.operation!,
            ),
            ReceiptScanViewStatus.result => _ReceiptScanResult(
              session: state.session!,
              onDiscard: controller.discard,
            ),
            ReceiptScanViewStatus.error => _ReceiptScanError(
              state: state,
              onRetryRecognition: controller.retryRecognition,
              onScan: () => controller.start(ReceiptCaptureMethod.scanner),
              onImport: () => controller.start(ReceiptCaptureMethod.fileImport),
              onDiscard: controller.discard,
            ),
          },
        ),
      ),
    );
  }

  Scaffold _loadingScreen(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptScanTitle)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _gatewayErrorScreen(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptScanTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.receiptGatewayLoadError,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _attachController(ReceiptScanGateway gateway) {
    if (_controller != null) return;
    _controller = ReceiptScanController(
      projectId: widget.projectId,
      gateway: gateway,
    )..addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ?..removeListener(_handleControllerChange)
      ..dispose();
    super.dispose();
  }
}

class _ReceiptScanIdle extends StatelessWidget {
  const _ReceiptScanIdle({required this.onScan, required this.onImport});

  final VoidCallback onScan;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const ValueKey('receiptScanIdle'),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      children: [
        Icon(Icons.receipt_long_outlined, size: 48, color: colors.primary),
        const SizedBox(height: 18),
        Text(
          l10n.receiptScanIdleTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.receiptScanIdleMessage,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const ValueKey('scanReceiptButton'),
          onPressed: onScan,
          icon: const Icon(Icons.document_scanner_outlined),
          label: Text(l10n.receiptScanAction),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('importReceiptButton'),
          onPressed: onImport,
          icon: const Icon(Icons.folder_open_outlined),
          label: Text(l10n.receiptImportAction),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.phonelink_lock_outlined,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.receiptScanLocalOnly,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReceiptScanProcessing extends StatelessWidget {
  const _ReceiptScanProcessing({required this.operation});

  final ReceiptScanOperation operation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (operation) {
      ReceiptScanOperation.capture => l10n.receiptCaptureProcessing,
      ReceiptScanOperation.recognition => l10n.receiptRecognitionProcessing,
    };
    return Semantics(
      liveRegion: true,
      child: Padding(
        key: const ValueKey('receiptScanProcessing'),
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ReceiptScanResult extends StatelessWidget {
  const _ReceiptScanResult({required this.session, required this.onDiscard});

  final ReceiptScanSession session;
  final Future<void> Function() onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final candidates = session.candidates;
    return ListView(
      key: const ValueKey('receiptScanResult'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          l10n.receiptResultTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _ReceiptPreview(uri: session.source.previewUri),
        const SizedBox(height: 18),
        if (candidates.seller case final value?)
          _ReceiptField(label: l10n.receiptSellerLabel, value: value.value),
        if (candidates.dateText case final value?)
          _ReceiptField(label: l10n.receiptDateLabel, value: value.value),
        if (candidates.documentNumber case final value?)
          _ReceiptField(
            label: l10n.receiptDocumentNumberLabel,
            value: value.value,
          ),
        if (candidates.totalText case final value?)
          _ReceiptField(label: l10n.receiptTotalLabel, value: value.value),
        if (candidates.vatLines.isNotEmpty)
          _ReceiptTextSection(
            heading: l10n.receiptVatLinesLabel,
            lines: candidates.vatLines.map((line) => line.value),
          ),
        if (candidates.itemLines.isNotEmpty)
          _ReceiptTextSection(
            heading: l10n.receiptItemLinesLabel,
            lines: candidates.itemLines.map((line) => line.value),
          ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: Text(l10n.receiptRawTextLabel),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(candidates.recognizedText.value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _BudgetUnchangedNotice(),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          key: const ValueKey('discardReceiptResultButton'),
          onPressed: onDiscard,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.receiptDiscardAction),
        ),
      ],
    );
  }
}

class _ReceiptScanError extends StatelessWidget {
  const _ReceiptScanError({
    required this.state,
    required this.onRetryRecognition,
    required this.onScan,
    required this.onImport,
    required this.onDiscard,
  });

  final ReceiptScanViewState state;
  final VoidCallback onRetryRecognition;
  final VoidCallback onScan;
  final VoidCallback onImport;
  final Future<void> Function() onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.failureKind!;
    final (title, message) = _errorText(l10n, failure);
    return ListView(
      key: const ValueKey('receiptScanError'),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      children: [
        Icon(
          Icons.error_outline,
          size: 44,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (state.source != null)
          FilledButton.icon(
            key: const ValueKey('retryReceiptOcrButton'),
            onPressed: onRetryRecognition,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.receiptRetryOcrAction),
          )
        else
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.document_scanner_outlined),
            label: Text(l10n.receiptScanAction),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('receiptFallbackImportButton'),
          onPressed: state.source == null ? onImport : null,
          icon: const Icon(Icons.folder_open_outlined),
          label: Text(l10n.receiptImportAction),
        ),
        if (state.source != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onDiscard,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.receiptDiscardAction),
          ),
        ],
      ],
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Image.file(
        File.fromUri(uri),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(l10n.receiptPreviewUnavailable),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptField extends StatelessWidget {
  const _ReceiptField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptTextSection extends StatelessWidget {
  const _ReceiptTextSection({required this.heading, required this.lines});

  final String heading;
  final Iterable<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...lines
              .take(20)
              .map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(line),
                ),
              ),
        ],
      ),
    );
  }
}

class _BudgetUnchangedNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.fact_check_outlined, color: colors.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.receiptBudgetUnchangedTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.receiptBudgetUnchangedMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

(String, String) _errorText(
  AppLocalizations l10n,
  ReceiptScanFailureKind kind,
) {
  return switch (kind) {
    ReceiptScanFailureKind.scannerUnavailable => (
      l10n.receiptScannerUnavailableTitle,
      l10n.receiptScannerUnavailableMessage,
    ),
    ReceiptScanFailureKind.unsupportedInput => (
      l10n.receiptUnsupportedTitle,
      l10n.receiptUnsupportedMessage,
    ),
    ReceiptScanFailureKind.emptyText => (
      l10n.receiptEmptyTextTitle,
      l10n.receiptEmptyTextMessage,
    ),
    ReceiptScanFailureKind.storage => (
      l10n.receiptStorageErrorTitle,
      l10n.receiptStorageErrorMessage,
    ),
    ReceiptScanFailureKind.recognition => (
      l10n.receiptRecognitionErrorTitle,
      l10n.receiptRecognitionErrorMessage,
    ),
  };
}
