import 'dart:io';

import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'document_ui_text.dart';
import 'documents_controller.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(documentsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentsTitle)),
      body: asyncState.when(
        loading: () => AppLoadingState(label: l10n.documentsTitle),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.documentsLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(documentsControllerProvider),
        ),
        data: _body,
      ),
      floatingActionButton: asyncState.value?.project == null
          ? null
          : FloatingActionButton(
              key: const ValueKey('addDocumentButton'),
              tooltip: l10n.documentImportAction,
              onPressed: asyncState.value?.isImporting == true ? null : _import,
              child: asyncState.value?.isImporting == true
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.add),
            ),
    );
  }

  Widget _body(DocumentsState state) {
    final l10n = AppLocalizations.of(context);
    if (state.project == null) {
      return AppEmptyState(
        icon: Icons.home_work_outlined,
        title: l10n.documentsNoProjectTitle,
        message: l10n.documentsNoProjectMessage,
      );
    }
    if (_searchController.text != state.filters.searchText) {
      _searchController.value = TextEditingValue(
        text: state.filters.searchText,
        selection: TextSelection.collapsed(
          offset: state.filters.searchText.length,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(documentsControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _toolbar(state),
            ),
          ),
          if (state.documents.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon:
                    state.filters.searchText.isEmpty &&
                        !state.filters.hasStructuredFilters
                    ? Icons.folder_open_outlined
                    : Icons.search_off_outlined,
                title:
                    state.filters.searchText.isEmpty &&
                        !state.filters.hasStructuredFilters
                    ? l10n.documentsEmptyTitle
                    : l10n.documentsNoResultsTitle,
                message:
                    state.filters.searchText.isEmpty &&
                        !state.filters.hasStructuredFilters
                    ? l10n.documentsEmptyMessage
                    : l10n.documentsNoResultsMessage,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              sliver: SliverList.separated(
                itemCount: state.documents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final document = state.documents[index];
                  return _DocumentRow(
                    document: document,
                    preview: state.previewFiles[document.id],
                    onTap: () => _openDetails(document),
                  );
                },
              ),
            ),
          if (state.nextPage != null || state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                child: OutlinedButton.icon(
                  key: const ValueKey('loadMoreDocumentsButton'),
                  onPressed: state.isLoadingMore
                      ? null
                      : () => ref
                            .read(documentsControllerProvider.notifier)
                            .loadNext(),
                  icon: state.isLoadingMore
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more),
                  label: Text(l10n.documentsLoadMoreAction),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }

  Widget _toolbar(DocumentsState state) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('documentSearchField'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: l10n.documentsSearchLabel,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clearAction,
                    onPressed: () {
                      _searchController.clear();
                      _applySearch(state, '');
                    },
                    icon: const Icon(Icons.clear),
                  ),
          ),
          onSubmitted: (value) => _applySearch(state, value),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              key: const ValueKey('documentFiltersButton'),
              onPressed: () => _showFilters(state),
              icon: const Icon(Icons.tune),
              label: Text(
                state.filters.activeFilterCount == 0
                    ? l10n.documentsFiltersAction
                    : l10n.documentsFiltersCount(
                        state.filters.activeFilterCount,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.documentsResultCount(state.totalCount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _applySearch(DocumentsState state, String value) {
    ref
        .read(documentsControllerProvider.notifier)
        .applyFilters(
          DocumentLibraryFilters(
            searchText: value,
            type: state.filters.type,
            stageId: state.filters.stageId,
            roomId: state.filters.roomId,
            warrantyState: state.filters.warrantyState,
            fromDate: state.filters.fromDate,
            toDateInclusive: state.filters.toDateInclusive,
          ),
        );
  }

  Future<void> _showFilters(DocumentsState state) async {
    final filters = await showModalBottomSheet<DocumentLibraryFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _DocumentFilterSheet(
        initial: state.filters,
        options: state.filterOptions,
      ),
    );
    if (filters != null) {
      await ref
          .read(documentsControllerProvider.notifier)
          .applyFilters(filters);
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(documentsControllerProvider.notifier);
    try {
      final attachment = await controller.pickAndStage();
      if (attachment == null || !mounted) return;
      var keep = true;
      final duplicates = await controller.duplicatesOf(attachment);
      if (duplicates.isNotEmpty && mounted) {
        keep =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.documentDuplicateTitle),
                content: Text(l10n.documentDuplicateMessage(duplicates.length)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancelAction),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.documentDuplicateContinueAction),
                  ),
                ],
              ),
            ) ??
            false;
      }
      if (!keep) {
        await controller.discardDraft(attachment);
        return;
      }
      if (!mounted) return;
      final saved = await context.push<bool>(
        '/projects/${Uri.encodeComponent(attachment.projectId)}'
        '/documents/${Uri.encodeComponent(attachment.id)}/edit?new=1',
      );
      if (saved == true) {
        await controller.refresh();
      } else {
        await controller.discardDraft(attachment);
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.documentImportError)));
      }
    }
  }

  Future<void> _openDetails(ProjectDocument document) async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(document.projectId)}'
      '/documents/${Uri.encodeComponent(document.id)}',
    );
    if (changed == true) {
      ref.invalidate(documentsControllerProvider);
    }
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.document,
    required this.preview,
    required this.onTap,
  });

  final ProjectDocument document;
  final File? preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metadata = document.metadata;
    final warranty = metadata.warrantyStateAt(DateTime.now());
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 68,
                height: 76,
                child: preview == null
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _documentIcon(metadata.type),
                          color: colors.onSecondaryContainer,
                          size: 30,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          preview!,
                          fit: BoxFit.cover,
                          cacheWidth: 160,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: colors.surfaceContainerHighest,
                                child: Icon(_documentIcon(metadata.type)),
                              ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      documentTypeLabel(l10n, metadata.type),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _RowMeta(
                          icon: Icons.event_outlined,
                          value: DateFormat.yMd('pl').format(
                            (metadata.documentDateUtc ?? document.importedAtUtc)
                                .toLocal(),
                          ),
                        ),
                        if (document.relations.isNotEmpty)
                          _RowMeta(
                            icon: Icons.link,
                            value: document.relations.length.toString(),
                          ),
                        if (warranty != DocumentWarrantyState.withoutWarranty)
                          _RowMeta(
                            icon: warranty == DocumentWarrantyState.expired
                                ? Icons.warning_amber_rounded
                                : Icons.verified_outlined,
                            value: documentWarrantyLabel(l10n, warranty),
                            color:
                                warranty == DocumentWarrantyState.expired ||
                                    warranty ==
                                        DocumentWarrantyState.expiringSoon
                                ? colors.error
                                : null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowMeta extends StatelessWidget {
  const _RowMeta({required this.icon, required this.value, this.color});

  final IconData icon;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ),
    ],
  );
}

class _DocumentFilterSheet extends StatefulWidget {
  const _DocumentFilterSheet({required this.initial, required this.options});

  final DocumentLibraryFilters initial;
  final DocumentFilterOptions options;

  @override
  State<_DocumentFilterSheet> createState() => _DocumentFilterSheetState();
}

class _DocumentFilterSheetState extends State<_DocumentFilterSheet> {
  ProjectDocumentType? _type;
  String? _stageId;
  String? _roomId;
  DocumentWarrantyState? _warranty;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial.type;
    _stageId = initial.stageId;
    _roomId = initial.roomId;
    _warranty = initial.warrantyState;
    _fromDate = initial.fromDate;
    _toDate = initial.toDateInclusive;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.documentsFilterTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.cancelAction,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProjectDocumentType?>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.documentTypeLabel),
              items: <DropdownMenuItem<ProjectDocumentType?>>[
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.documentsFilterTypeAll),
                ),
                ...ProjectDocumentType.values.map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(documentTypeLabel(l10n, type)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _stageId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.documentStageLabel),
              items: <DropdownMenuItem<String?>>[
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.documentsFilterStageAll),
                ),
                ...widget.options.stages.map(
                  (option) => DropdownMenuItem(
                    value: option.id,
                    child: Text(
                      _stageOptionLabel(l10n, option),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _stageId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _roomId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.documentRoomLabel),
              items: <DropdownMenuItem<String?>>[
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.documentsFilterRoomAll),
                ),
                ...widget.options.rooms.map(
                  (option) => DropdownMenuItem(
                    value: option.id,
                    child: Text(option.label, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _roomId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DocumentWarrantyState?>(
              initialValue: _warranty,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.documentWarrantySection,
              ),
              items: <DropdownMenuItem<DocumentWarrantyState?>>[
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.documentsFilterWarrantyAll),
                ),
                ...DocumentWarrantyState.values.map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(documentWarrantyLabel(l10n, value)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _warranty = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FilterDateButton(
                    label: l10n.documentsFilterFromDate,
                    value: _fromDate,
                    onChanged: (value) => setState(() => _fromDate = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterDateButton(
                    label: l10n.documentsFilterToDate,
                    value: _toDate,
                    onChanged: (value) => setState(() => _toDate = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            OverflowBar(
              spacing: 8,
              overflowSpacing: 8,
              alignment: MainAxisAlignment.spaceBetween,
              overflowAlignment: OverflowBarAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() {
                    _type = null;
                    _stageId = null;
                    _roomId = null;
                    _warranty = null;
                    _fromDate = null;
                    _toDate = null;
                  }),
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: Text(l10n.clearAction),
                ),
                FilledButton.icon(
                  key: const ValueKey('applyDocumentFiltersButton'),
                  onPressed: () => Navigator.pop(
                    context,
                    DocumentLibraryFilters(
                      searchText: widget.initial.searchText,
                      type: _type,
                      stageId: _stageId,
                      roomId: _roomId,
                      warrantyState: _warranty,
                      fromDate: _fromDate,
                      toDateInclusive: _toDate,
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.documentsApplyFiltersAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDateButton extends StatelessWidget {
  const _FilterDateButton({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => _pick(context),
    icon: const Icon(Icons.event_outlined),
    label: Text(
      value == null ? label : DateFormat.yMd('pl').format(value!),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 30),
    );
    if (selected != null) onChanged(selected);
  }
}

IconData _documentIcon(ProjectDocumentType type) => switch (type) {
  ProjectDocumentType.receipt => Icons.receipt_long_outlined,
  ProjectDocumentType.invoice => Icons.request_quote_outlined,
  ProjectDocumentType.quote => Icons.price_check_outlined,
  ProjectDocumentType.contract => Icons.handshake_outlined,
  ProjectDocumentType.deliveryNote => Icons.local_shipping_outlined,
  ProjectDocumentType.protocol => Icons.fact_check_outlined,
  ProjectDocumentType.warranty => Icons.verified_outlined,
  ProjectDocumentType.instruction => Icons.menu_book_outlined,
  ProjectDocumentType.map => Icons.map_outlined,
  ProjectDocumentType.photo => Icons.photo_outlined,
  ProjectDocumentType.other => Icons.description_outlined,
};

String _stageOptionLabel(AppLocalizations l10n, DocumentFilterOption option) {
  final key = switch (option.id) {
    'planning' => ProjectStageKey.planning,
    'formalities' => ProjectStageKey.formalities,
    'state_zero' => ProjectStageKey.stateZero,
    'shell_open' => ProjectStageKey.shellOpen,
    'shell_closed' => ProjectStageKey.shellClosed,
    'demolition' => ProjectStageKey.demolition,
    'installations' => ProjectStageKey.installations,
    'plaster' => ProjectStageKey.plaster,
    'finishing' => ProjectStageKey.finishing,
    'handover' => ProjectStageKey.handover,
    _ => null,
  };
  return key == null ? option.label : projectStageLabel(l10n, key);
}
