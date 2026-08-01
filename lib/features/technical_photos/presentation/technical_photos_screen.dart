import 'dart:async';
import 'dart:io';

import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_ui_text.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photos_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TechnicalPhotosScreen extends ConsumerStatefulWidget {
  const TechnicalPhotosScreen({super.key});

  @override
  ConsumerState<TechnicalPhotosScreen> createState() =>
      _TechnicalPhotosScreenState();
}

class _TechnicalPhotosScreenState extends ConsumerState<TechnicalPhotosScreen> {
  final _search = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(technicalPhotosControllerProvider);
    final filterCount = state.value?.filters.activeFilterCount ?? 0;
    return Scaffold(
      key: const ValueKey('technicalPhotosScreen'),
      appBar: AppBar(
        title: Text(l10n.technicalPhotosTitle),
        actions: [
          IconButton(
            tooltip: l10n.technicalPhotosAlbumAddTooltip,
            onPressed: state.hasValue && state.requireValue.project != null
                ? () => _createAlbum(state.requireValue)
                : null,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          IconButton(
            key: const ValueKey('technicalPhotoFiltersButton'),
            tooltip: l10n.technicalPhotosFilterTooltip,
            onPressed: state.hasValue && state.requireValue.project != null
                ? () => _showFilters(state.requireValue)
                : null,
            icon: filterCount == 0
                ? const Icon(Icons.filter_list_rounded)
                : Badge(
                    label: Text('$filterCount'),
                    child: const Icon(Icons.filter_list_rounded),
                  ),
          ),
        ],
      ),
      body: state.when(
        loading: () => AppLoadingState(label: l10n.technicalPhotosLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.technicalPhotosLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () =>
              ref.read(technicalPhotosControllerProvider.notifier).refresh(),
        ),
        data: (value) => _body(context, value),
      ),
      floatingActionButton: state.value?.project == null
          ? null
          : FloatingActionButton(
              key: const ValueKey('technicalPhotoAddButton'),
              tooltip: l10n.technicalPhotosAddTooltip,
              onPressed: state.value!.isImporting
                  ? null
                  : () => _addPhoto(state.value!),
              child: state.value!.isImporting
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
            ),
    );
  }

  Widget _body(BuildContext context, TechnicalPhotosState state) {
    final l10n = AppLocalizations.of(context);
    if (state.project == null) {
      return AppEmptyState(
        icon: Icons.home_work_outlined,
        title: l10n.technicalPhotosNoProjectTitle,
        message: l10n.technicalPhotosNoProjectMessage,
      );
    }
    final activeAlbum = state.filters.albumId == null
        ? null
        : state.albums
              .where((overview) => overview.album.id == state.filters.albumId)
              .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            key: const ValueKey('technicalPhotoSearchField'),
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.technicalPhotosSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.clearAction,
                      onPressed: () {
                        _search.clear();
                        _applySearch('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
            onChanged: (value) {
              setState(() {});
              _searchDebounce?.cancel();
              _searchDebounce = Timer(
                const Duration(milliseconds: 300),
                () => _applySearch(value),
              );
            },
          ),
        ),
        _albumStrip(context, state),
        if (activeAlbum != null) _albumSummary(context, activeAlbum),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            l10n.technicalPhotosCount(state.totalCount),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: state.photos.isEmpty
              ? AppEmptyState(
                  icon: Icons.photo_library_outlined,
                  title: l10n.technicalPhotosEmptyTitle,
                  message: l10n.technicalPhotosEmptyMessage,
                )
              : _photoGrid(context, state),
        ),
      ],
    );
  }

  Widget _albumStrip(BuildContext context, TechnicalPhotosState state) {
    final l10n = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: textScale > 1.3 ? 68 : 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: state.filters.albumId == null,
              label: Text(l10n.technicalPhotosAllAlbums),
              onSelected: (_) => _selectAlbum(state, null),
            ),
          ),
          ...state.albums.map(
            (overview) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                selected: state.filters.albumId == overview.album.id,
                label: Text(
                  '${overview.album.title} (${overview.photoCount})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onSelected: (_) => _selectAlbum(state, overview.album.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _albumSummary(BuildContext context, TechnicalAlbumOverview overview) {
    final l10n = AppLocalizations.of(context);
    final album = overview.album;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(album.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(technicalAlbumKindLabel(l10n, album.kind)),
              if (album.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  album.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoGrid(BuildContext context, TechnicalPhotosState state) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final columns = width >= 900
        ? 4
        : width >= 600
        ? 3
        : textScale > 1.3
        ? 1
        : 2;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: columns == 1 ? 1.65 : 0.78,
      ),
      itemCount: state.photos.length + (state.nextPage == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == state.photos.length) {
          return Center(
            child: TextButton.icon(
              onPressed: state.isLoadingMore
                  ? null
                  : () => ref
                        .read(technicalPhotosControllerProvider.notifier)
                        .loadNext(),
              icon: state.isLoadingMore
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded),
              label: Text(AppLocalizations.of(context).technicalPhotosLoadMore),
            ),
          );
        }
        final photo = state.photos[index];
        return _TechnicalPhotoTile(
          photo: photo,
          previewFile: state.previewFiles[photo.attachmentId],
          onTap: () => context.push(
            '/projects/${Uri.encodeComponent(photo.projectId)}'
            '/technical/${Uri.encodeComponent(photo.attachmentId)}',
          ),
        );
      },
    );
  }

  void _applySearch(String value) {
    if (!mounted) return;
    final state = ref.read(technicalPhotosControllerProvider).value;
    if (state == null || state.filters.searchText == value.trim()) return;
    ref
        .read(technicalPhotosControllerProvider.notifier)
        .applyFilters(state.filters.copyWith(searchText: value));
  }

  void _selectAlbum(TechnicalPhotosState state, String? albumId) {
    ref
        .read(technicalPhotosControllerProvider.notifier)
        .applyFilters(
          state.filters.copyWith(albumId: albumId, clearAlbum: albumId == null),
        );
  }

  Future<TechnicalAlbum?> _createAlbum(TechnicalPhotosState state) async {
    final project = state.project;
    if (project == null) return null;
    final input = await showDialog<TechnicalAlbumInput>(
      context: context,
      builder: (context) =>
          _AlbumDialog(projectId: project.id, stages: state.stages),
    );
    if (input == null || !mounted) return null;
    try {
      return await ref
          .read(technicalPhotosControllerProvider.notifier)
          .createAlbum(input);
    } on Object {
      if (mounted) {
        _message(AppLocalizations.of(context).technicalAlbumCreateError);
      }
      return null;
    }
  }

  Future<void> _addPhoto(TechnicalPhotosState state) async {
    if (state.albums.isEmpty && await _createAlbum(state) == null) return;
    if (!mounted) return;
    try {
      final attachment = await ref
          .read(technicalPhotosControllerProvider.notifier)
          .pickAndStageImage();
      if (attachment == null || !mounted) return;
      final saved = await context.push<bool>(
        '/projects/${Uri.encodeComponent(attachment.projectId)}'
        '/technical/${Uri.encodeComponent(attachment.id)}/edit?new=1',
      );
      if (saved != true) {
        await ref
            .read(technicalPhotosControllerProvider.notifier)
            .discardDraft(attachment);
      }
      await ref.read(technicalPhotosControllerProvider.notifier).refresh();
    } on UnsupportedTechnicalPhotoException {
      if (mounted) {
        _message(AppLocalizations.of(context).technicalPhotosUnsupportedFile);
      }
    } on Object {
      if (mounted) {
        _message(AppLocalizations.of(context).technicalPhotosImportError);
      }
    }
  }

  Future<void> _showFilters(TechnicalPhotosState state) async {
    final result = await showModalBottomSheet<TechnicalPhotoFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TechnicalFiltersSheet(state: state),
    );
    if (result != null) {
      await ref
          .read(technicalPhotosControllerProvider.notifier)
          .applyFilters(result);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _TechnicalPhotoTile extends StatelessWidget {
  const _TechnicalPhotoTile({
    required this.photo,
    required this.previewFile,
    required this.onTap,
  });

  final TechnicalPhoto photo;
  final File? previewFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: previewFile == null
                  ? _MissingPreview(label: l10n.technicalPhotosMissingPreview)
                  : Image.file(
                      previewFile!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _MissingPreview(
                            label: l10n.technicalPhotosMissingPreview,
                          ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    technicalInstallationLabel(l10n, photo.installationType),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    DateFormat(
                      'dd.MM.yyyy',
                      'pl_PL',
                    ).format(photo.capturedAtUtc.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall,
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

class _MissingPreview extends StatelessWidget {
  const _MissingPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('technicalPhotoMissingPreview'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumDialog extends StatefulWidget {
  const _AlbumDialog({required this.projectId, required this.stages});

  final String projectId;
  final List<ProjectStage> stages;

  @override
  State<_AlbumDialog> createState() => _AlbumDialogState();
}

class _AlbumDialogState extends State<_AlbumDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  TechnicalAlbumKind _kind = TechnicalAlbumKind.beforeConcrete;
  String? _stageId;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.technicalAlbumNewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: l10n.technicalAlbumTitleLabel,
              ),
            ),
            DropdownButtonFormField<TechnicalAlbumKind>(
              initialValue: _kind,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.technicalAlbumKindLabel,
              ),
              items: TechnicalAlbumKind.values
                  .map(
                    (kind) => DropdownMenuItem<TechnicalAlbumKind>(
                      value: kind,
                      child: Text(technicalAlbumKindLabel(l10n, kind)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _kind = value ?? _kind),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _stageId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.technicalFilterStageLabel,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.technicalPhotoNoStage),
                ),
                ...widget.stages.map(
                  (stage) => DropdownMenuItem<String?>(
                    value: stage.id,
                    child: Text(stageName(l10n, stage)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _stageId = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: l10n.technicalAlbumDescriptionLabel,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () {
            try {
              Navigator.of(context).pop(
                TechnicalAlbumInput(
                  projectId: widget.projectId,
                  title: _title.text,
                  kind: _kind,
                  stageId: _stageId,
                  description: _description.text,
                ),
              );
            } on ArgumentError {
              return;
            }
          },
          child: Text(l10n.technicalAlbumCreateAction),
        ),
      ],
    );
  }
}

class _TechnicalFiltersSheet extends StatefulWidget {
  const _TechnicalFiltersSheet({required this.state});

  final TechnicalPhotosState state;

  @override
  State<_TechnicalFiltersSheet> createState() => _TechnicalFiltersSheetState();
}

class _TechnicalFiltersSheetState extends State<_TechnicalFiltersSheet> {
  late String? _stageId = widget.state.filters.stageId;
  late TechnicalInstallationType? _installation =
      widget.state.filters.installationType;
  late String? _tag = widget.state.filters.tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tags = widget.state.availableTags.toList()..sort();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.technicalFiltersTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cancelAction,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              DropdownButtonFormField<String?>(
                initialValue: _stageId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.technicalFilterStageLabel,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.technicalFilterAllStages),
                  ),
                  ...widget.state.stages.map(
                    (stage) => DropdownMenuItem<String?>(
                      value: stage.id,
                      child: Text(stageName(l10n, stage)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _stageId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TechnicalInstallationType?>(
                initialValue: _installation,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.technicalFilterInstallationLabel,
                ),
                items: [
                  DropdownMenuItem<TechnicalInstallationType?>(
                    value: null,
                    child: Text(l10n.technicalFilterAllInstallations),
                  ),
                  ...TechnicalInstallationType.values.map(
                    (type) => DropdownMenuItem<TechnicalInstallationType?>(
                      value: type,
                      child: Text(technicalInstallationLabel(l10n, type)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _installation = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _tag,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.technicalFilterTagLabel,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.technicalFilterAllTags),
                  ),
                  ...tags.map(
                    (tag) =>
                        DropdownMenuItem<String?>(value: tag, child: Text(tag)),
                  ),
                ],
                onChanged: (value) => setState(() => _tag = value),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(
                        TechnicalPhotoFilters(
                          searchText: widget.state.filters.searchText,
                          albumId: widget.state.filters.albumId,
                        ),
                      ),
                      child: Text(l10n.clearAction),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('applyTechnicalPhotoFilters'),
                      onPressed: () => Navigator.of(context).pop(
                        widget.state.filters.copyWith(
                          stageId: _stageId,
                          clearStage: _stageId == null,
                          installationType: _installation,
                          clearInstallationType: _installation == null,
                          tag: _tag,
                          clearTag: _tag == null,
                        ),
                      ),
                      child: Text(l10n.documentsApplyFiltersAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
