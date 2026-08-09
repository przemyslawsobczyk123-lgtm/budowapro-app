import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cost_form_screen.dart';
import 'cost_spreadsheet_import_gateway.dart';

class CostSpreadsheetImportScreen extends ConsumerWidget {
  const CostSpreadsheetImportScreen({
    required this.project,
    required this.stages,
    super.key,
  });

  final Project project;
  final List<ProjectStage> stages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final gateway = ref.watch(costSpreadsheetImportGatewayProvider);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.costSpreadsheetImportTitle)),
      body: SafeArea(
        top: false,
        child: gateway.when(
          loading: () => AppLoadingState(label: localizations.projectsLoading),
          error: (error, stackTrace) => AppErrorState(
            title: localizations.costSpreadsheetImportUnreadableFileError,
            retryLabel: localizations.retryAction,
            onRetry: () => ref.invalidate(costSpreadsheetImportGatewayProvider),
          ),
          data: (value) =>
              _ImportContent(gateway: value, project: project, stages: stages),
        ),
      ),
    );
  }
}

class _ImportContent extends StatefulWidget {
  const _ImportContent({
    required this.gateway,
    required this.project,
    required this.stages,
  });

  final CostSpreadsheetImportGateway gateway;
  final Project project;
  final List<ProjectStage> stages;

  @override
  State<_ImportContent> createState() => _ImportContentState();
}

class _ImportContentState extends State<_ImportContent> {
  CostSpreadsheetTable? _table;
  CostSpreadsheetImportError? _pickError;
  var _nameColumnIndex = 0;
  var _amountColumnIndex = 1;
  var _type = CostEntryType.planned;
  var _component = CostComponent.material;
  var _vatRate = VatRate.standard23;
  String? _stageId;
  var _isPicking = false;
  var _isSaving = false;
  var _saveFailed = false;

  Future<void> _pickFile() async {
    if (_isPicking || _isSaving) return;
    setState(() {
      _isPicking = true;
      _pickError = null;
      _saveFailed = false;
    });
    try {
      final table = await widget.gateway.pickFile();
      if (!mounted || table == null) return;
      setState(() {
        _table = table;
        _nameColumnIndex = 0;
        _amountColumnIndex = 1;
      });
    } on CostSpreadsheetImportException catch (error) {
      if (mounted) setState(() => _pickError = error.code);
    } on Object {
      if (mounted) {
        setState(() => _pickError = CostSpreadsheetImportError.unreadableFile);
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _import(CostSpreadsheetPreview preview) async {
    if (_isSaving || preview.validRows.isEmpty) return;
    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });
    try {
      final count = await widget.gateway.importRows(
        projectId: widget.project.id,
        currencyCode: widget.project.currencyCode,
        preview: preview,
        type: _type,
        component: _component,
        vatRate: _vatRate,
        stageId: _stageId,
      );
      if (!mounted) return;
      Navigator.of(context).pop(count);
      return;
    } on Object {
      if (mounted) setState(() => _saveFailed = true);
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final table = _table;
    if (table == null) {
      return Column(
        children: [
          Expanded(
            child: AppEmptyState(
              icon: Icons.table_view_outlined,
              title: localizations.costSpreadsheetImportEmptyTitle,
              message: localizations.costSpreadsheetImportEmptyMessage,
              actionLabel: _isPicking
                  ? null
                  : localizations.costSpreadsheetImportChooseFileAction,
              onAction: _isPicking ? null : _pickFile,
            ),
          ),
          if (_isPicking)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          if (_pickError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _InlineError(
                message: _pickErrorText(localizations, _pickError!),
              ),
            ),
        ],
      );
    }
    final preview = widget.gateway.preview(
      table,
      nameColumnIndex: _nameColumnIndex,
      amountColumnIndex: _amountColumnIndex,
    );
    return SingleChildScrollView(
      key: const ValueKey('costSpreadsheetImportScroll'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FileSummary(table: table),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('costSpreadsheetImportChangeFile'),
            onPressed: _isPicking || _isSaving ? null : _pickFile,
            icon: _isPicking
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.drive_folder_upload_outlined),
            label: Text(localizations.costSpreadsheetImportChangeFileAction),
          ),
          if (_pickError != null) ...[
            const SizedBox(height: 8),
            _InlineError(message: _pickErrorText(localizations, _pickError!)),
          ],
          const SizedBox(height: 24),
          _SectionTitle(localizations.costSpreadsheetImportMappingTitle),
          const SizedBox(height: 12),
          _ResponsivePair(
            children: [
              DropdownButtonFormField<int>(
                key: ValueKey('costImportNameColumn-$_nameColumnIndex'),
                initialValue: _nameColumnIndex,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: localizations.costSpreadsheetImportNameColumnLabel,
                ),
                items: _columnItems(localizations, table),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          if (value == _amountColumnIndex) {
                            _amountColumnIndex = _nameColumnIndex;
                          }
                          _nameColumnIndex = value;
                        });
                      },
              ),
              DropdownButtonFormField<int>(
                key: ValueKey('costImportAmountColumn-$_amountColumnIndex'),
                initialValue: _amountColumnIndex,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText:
                      localizations.costSpreadsheetImportAmountColumnLabel,
                ),
                items: _columnItems(localizations, table),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          if (value == _nameColumnIndex) {
                            _nameColumnIndex = _amountColumnIndex;
                          }
                          _amountColumnIndex = value;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(localizations.costSpreadsheetImportDefaultsTitle),
          const SizedBox(height: 12),
          _ResponsivePair(
            children: [
              DropdownButtonFormField<CostEntryType>(
                key: ValueKey('costImportType-${_type.name}'),
                initialValue: _type,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: localizations.costTypeLabel,
                ),
                items: CostEntryType.values
                    .map(
                      (value) => DropdownMenuItem<CostEntryType>(
                        value: value,
                        child: Text(
                          costTypeLabel(localizations, value),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _type = value);
                      },
              ),
              DropdownButtonFormField<CostComponent>(
                key: ValueKey('costImportComponent-${_component.name}'),
                initialValue: _component,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: localizations.costComponentLabel,
                ),
                items: CostComponent.values
                    .map(
                      (value) => DropdownMenuItem<CostComponent>(
                        value: value,
                        child: Text(
                          costComponentLabel(localizations, value),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _component = value);
                      },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ResponsivePair(
            children: [
              DropdownButtonFormField<VatRate>(
                key: ValueKey('costImportVat-${_vatRate.name}'),
                initialValue: _vatRate,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: localizations.costVatRateLabel,
                ),
                items: VatRate.values
                    .map(
                      (value) => DropdownMenuItem<VatRate>(
                        value: value,
                        child: Text(
                          costVatLabel(localizations, value),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _vatRate = value);
                      },
              ),
              DropdownButtonFormField<String?>(
                key: ValueKey('costImportStage-${_stageId ?? 'none'}'),
                initialValue: _stageId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: localizations.costStageLabel,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(localizations.costSpreadsheetImportStageNone),
                  ),
                  ...widget.stages.map(
                    (stage) => DropdownMenuItem<String?>(
                      value: stage.id,
                      child: Text(
                        stageName(localizations, stage),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() => _stageId = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(localizations.costSpreadsheetImportPreviewTitle),
          const SizedBox(height: 6),
          Text(
            localizations.costSpreadsheetImportSummary(
              preview.validRows.length,
              preview.invalidRows.length,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          ...preview.validRows
              .take(8)
              .map((row) => _PreviewRow(row: row, isError: false)),
          ...preview.invalidRows
              .take(20)
              .map((row) => _PreviewRow(row: row, isError: true)),
          if (preview.validRows.isEmpty) ...[
            const SizedBox(height: 8),
            _InlineError(
              message: localizations.costSpreadsheetImportNoValidRows,
            ),
          ],
          if (_saveFailed) ...[
            const SizedBox(height: 8),
            _InlineError(message: localizations.costSpreadsheetImportSaveError),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('costSpreadsheetImportSubmit'),
            onPressed: _isSaving || preview.validRows.isEmpty
                ? null
                : () => _import(preview),
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.playlist_add_check_rounded),
            label: Text(
              localizations.costSpreadsheetImportSubmitAction(
                preview.validRows.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileSummary extends StatelessWidget {
  const _FileSummary({required this.table});

  final CostSpreadsheetTable table;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.costSpreadsheetImportFileLabel,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Text(
          table.fileName,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        if (table.sheetName != null) ...[
          const SizedBox(height: 4),
          Text(
            '${localizations.costSpreadsheetImportSheetLabel}: ${table.sheetName}',
          ),
        ],
        const SizedBox(height: 4),
        Text(
          table.headerDetected
              ? localizations.costSpreadsheetImportHeaderDetected
              : localizations.costSpreadsheetImportNoHeader,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.row, required this.isError});

  final CostSpreadsheetPreviewRow row;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final error = row.error;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
        color: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        row.name.isEmpty
            ? localizations.costSpreadsheetImportRowLabel(row.sourceRowNumber)
            : row.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        error == null
            ? row.rawAmount
            : '${localizations.costSpreadsheetImportRowLabel(row.sourceRowNumber)} · ${_rowErrorText(localizations, error)}',
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 560) {
        return Column(
          children: [children.first, const SizedBox(height: 12), children.last],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: children.first),
          const SizedBox(width: 12),
          Expanded(child: children.last),
        ],
      );
    },
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.error_outline_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(message)),
    ],
  );
}

List<DropdownMenuItem<int>> _columnItems(
  AppLocalizations localizations,
  CostSpreadsheetTable table,
) {
  return List<DropdownMenuItem<int>>.generate(table.columns.length, (index) {
    final header = table.columns[index];
    return DropdownMenuItem<int>(
      value: index,
      child: Text(
        header.isEmpty
            ? localizations.costSpreadsheetImportColumnLabel(index + 1)
            : header,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }, growable: false);
}

String _rowErrorText(
  AppLocalizations localizations,
  CostSpreadsheetRowError error,
) => switch (error) {
  CostSpreadsheetRowError.missingName =>
    localizations.costSpreadsheetImportMissingNameError,
  CostSpreadsheetRowError.nameTooLong =>
    localizations.costSpreadsheetImportNameTooLongError,
  CostSpreadsheetRowError.missingAmount =>
    localizations.costSpreadsheetImportMissingAmountError,
  CostSpreadsheetRowError.invalidAmount =>
    localizations.costSpreadsheetImportInvalidAmountError,
  CostSpreadsheetRowError.amountTooLarge =>
    localizations.costSpreadsheetImportAmountTooLargeError,
  CostSpreadsheetRowError.formula =>
    localizations.costSpreadsheetImportFormulaError,
};

String _pickErrorText(
  AppLocalizations localizations,
  CostSpreadsheetImportError error,
) => switch (error) {
  CostSpreadsheetImportError.unsupportedFormat =>
    localizations.costSpreadsheetImportUnsupportedFormatError,
  CostSpreadsheetImportError.emptyFile =>
    localizations.costSpreadsheetImportEmptyFileError,
  CostSpreadsheetImportError.fileTooLarge =>
    localizations.costSpreadsheetImportFileTooLargeError,
  CostSpreadsheetImportError.workbookTooLarge =>
    localizations.costSpreadsheetImportWorkbookTooLargeError,
  CostSpreadsheetImportError.notEnoughColumns =>
    localizations.costSpreadsheetImportNotEnoughColumnsError,
  CostSpreadsheetImportError.tooManyRows =>
    localizations.costSpreadsheetImportTooManyRowsError,
  CostSpreadsheetImportError.tooManyColumns =>
    localizations.costSpreadsheetImportTooManyColumnsError,
  CostSpreadsheetImportError.unreadableFile =>
    localizations.costSpreadsheetImportUnreadableFileError,
};
