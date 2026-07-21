import 'dart:io';

import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'document_ui_text.dart';
import 'documents_controller.dart';

class DocumentDetailsScreen extends ConsumerStatefulWidget {
  const DocumentDetailsScreen({
    required this.projectId,
    required this.documentId,
    super.key,
  });

  final String projectId;
  final String documentId;

  @override
  ConsumerState<DocumentDetailsScreen> createState() =>
      _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends ConsumerState<DocumentDetailsScreen> {
  late Future<_DocumentDetailsData?> _load;
  var _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<_DocumentDetailsData?> _request() async {
    final repository = await ref.read(documentRepositoryProvider.future);
    final document = await repository.findById(
      projectId: widget.projectId,
      documentId: widget.documentId,
    );
    if (document == null) return null;
    final stager = await ref.read(localAttachmentStagerProvider.future);
    return _DocumentDetailsData(
      document: document,
      preview: await stager.previewFile(
        projectId: widget.projectId,
        attachmentId: widget.documentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentDetailsTitle)),
      body: FutureBuilder<_DocumentDetailsData?>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: l10n.documentDetailsTitle);
          }
          if (snapshot.hasError) {
            return AppErrorState(
              title: l10n.documentLoadError,
              retryLabel: l10n.retryAction,
              onRetry: () => setState(() => _load = _request()),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return AppEmptyState(
              icon: Icons.find_in_page_outlined,
              title: l10n.documentNotFoundTitle,
              message: l10n.documentNotFoundMessage,
            );
          }
          return _content(data);
        },
      ),
    );
  }

  Widget _content(_DocumentDetailsData data) {
    final document = data.document;
    final metadata = document.metadata;
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final warranty = metadata.warrantyStateAt(DateTime.now());
    return Column(
      children: [
        if (_isDeleting) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _PreviewBand(
                document: document,
                preview: data.preview,
                onTap: document.isPdf || document.isImage
                    ? () => _open(document)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusLabel(
                          label: documentTypeLabel(l10n, metadata.type),
                          color: colors.primary,
                        ),
                        if (warranty != DocumentWarrantyState.withoutWarranty)
                          _StatusLabel(
                            label: documentWarrantyLabel(l10n, warranty),
                            color:
                                warranty == DocumentWarrantyState.expired ||
                                    warranty ==
                                        DocumentWarrantyState.expiringSoon
                                ? colors.error
                                : colors.tertiary,
                          ),
                      ],
                    ),
                    if (metadata.description != null) ...[
                      const SizedBox(height: 16),
                      Text(metadata.description!),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          key: const ValueKey('openDocumentButton'),
                          onPressed: _isDeleting ? null : () => _open(document),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.documentOpenAction),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isDeleting ? null : _edit,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.documentEditTitle),
                        ),
                        Builder(
                          builder: (shareContext) => OutlinedButton.icon(
                            onPressed: _isDeleting
                                ? null
                                : () => _share(document, shareContext),
                            icon: const Icon(Icons.share_outlined),
                            label: Text(l10n.documentShareAction),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.deleteAction,
                          onPressed: _isDeleting
                              ? null
                              : () => _delete(document),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _SectionHeading(l10n.documentFileHeading),
                    const SizedBox(height: 10),
                    _DetailLine(
                      icon: Icons.insert_drive_file_outlined,
                      label: l10n.documentFileNameLabel,
                      value: document.displayName,
                    ),
                    _DetailLine(
                      icon: Icons.data_usage_outlined,
                      label: l10n.documentFileSizeLabel,
                      value: _fileSize(document.byteSize),
                    ),
                    _DetailLine(
                      icon: Icons.archive_outlined,
                      label: l10n.documentImportedAtLabel,
                      value: DateFormat.yMd(
                        'pl',
                      ).add_Hm().format(document.importedAtUtc.toLocal()),
                    ),
                    _DetailLine(
                      icon: Icons.lock_outline,
                      label: l10n.documentOriginalPreservedLabel,
                      value: '',
                    ),
                    if (metadata.documentDateUtc != null)
                      _DetailLine(
                        icon: Icons.event_outlined,
                        label: l10n.documentDateLabel,
                        value: DateFormat.yMd(
                          'pl',
                        ).format(metadata.documentDateUtc!.toLocal()),
                      ),
                    if (metadata.warrantyEndsAtUtc != null) ...[
                      const SizedBox(height: 22),
                      _SectionHeading(l10n.documentWarrantySection),
                      const SizedBox(height: 10),
                      _DetailLine(
                        icon: Icons.verified_outlined,
                        label: l10n.documentWarrantyStartLabel,
                        value: DateFormat.yMd(
                          'pl',
                        ).format(metadata.warrantyStartsAtUtc!.toLocal()),
                      ),
                      _DetailLine(
                        icon: Icons.event_busy_outlined,
                        label: l10n.documentWarrantyEndLabel,
                        value: DateFormat.yMd(
                          'pl',
                        ).format(metadata.warrantyEndsAtUtc!.toLocal()),
                      ),
                      if (metadata.warrantyReminderAtUtc != null)
                        _DetailLine(
                          icon: Icons.notifications_active_outlined,
                          label: l10n.documentWarrantyReminderLabel,
                          value: DateFormat.yMd(
                            'pl',
                          ).format(metadata.warrantyReminderAtUtc!.toLocal()),
                        ),
                    ],
                    const SizedBox(height: 22),
                    _SectionHeading(l10n.documentRelationsHeading),
                    const SizedBox(height: 8),
                    if (document.relations.isEmpty)
                      Text(
                        l10n.documentRelationsEmpty,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      )
                    else
                      ...document.relations.map(
                        (relation) => _RelationTile(
                          relation: relation,
                          onTap: _relationPath(document, relation) == null
                              ? null
                              : () => context.push(
                                  _relationPath(document, relation)!,
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _open(ProjectDocument document) {
    final l10n = AppLocalizations.of(context);
    if (!document.isPdf && !document.isImage) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.documentPreviewUnavailable)));
      return;
    }
    context.push(
      '/projects/${Uri.encodeComponent(document.projectId)}'
      '/documents/${Uri.encodeComponent(document.id)}/view',
    );
  }

  Future<void> _edit() async {
    final changed = await context.push<bool>(
      '/projects/${Uri.encodeComponent(widget.projectId)}'
      '/documents/${Uri.encodeComponent(widget.documentId)}/edit',
    );
    if (changed == true && mounted) {
      ref.invalidate(documentsControllerProvider);
      setState(() => _load = _request());
    }
  }

  Future<void> _share(
    ProjectDocument document,
    BuildContext shareContext,
  ) async {
    final l10n = AppLocalizations.of(context);
    final box = shareContext.findRenderObject() as RenderBox?;
    final shareOrigin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      final file = await (await ref.read(
        localAttachmentStagerProvider.future,
      )).originalFile(projectId: document.projectId, attachmentId: document.id);
      if (file == null) throw const FileSystemException('File is missing');
      await SharePlus.instance.share(
        ShareParams(
          title: document.metadata.title,
          files: <XFile>[
            XFile(
              file.path,
              mimeType: document.mediaType,
              name: document.displayName,
            ),
          ],
          fileNameOverrides: <String>[document.displayName],
          sharePositionOrigin: shareOrigin,
        ),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.documentShareError)));
      }
    }
  }

  Future<void> _delete(ProjectDocument document) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.documentDeleteTitle),
        content: Text(l10n.documentDeleteMessage(document.relations.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isDeleting = true);
    try {
      await (await ref.read(
        localAttachmentStagerProvider.future,
      )).deleteCatalogDocument(
        projectId: document.projectId,
        attachmentId: document.id,
      );
      ref.invalidate(documentsControllerProvider);
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.documentDeleteError)));
      }
    }
  }
}

final class _DocumentDetailsData {
  const _DocumentDetailsData({required this.document, required this.preview});

  final ProjectDocument document;
  final File? preview;
}

class _PreviewBand extends StatelessWidget {
  const _PreviewBand({
    required this.document,
    required this.preview,
    required this.onTap,
  });

  final ProjectDocument document;
  final File? preview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 230,
      child: Material(
        color: colors.surfaceContainer,
        child: InkWell(
          onTap: onTap,
          child: preview == null
              ? Center(
                  child: Icon(
                    document.isPdf
                        ? Icons.picture_as_pdf_outlined
                        : document.isImage
                        ? Icons.image_outlined
                        : Icons.description_outlined,
                    size: 64,
                    color: colors.onSurfaceVariant,
                  ),
                )
              : Image.file(
                  preview!,
                  fit: BoxFit.contain,
                  cacheWidth: 720,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 56,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: TextStyle(color: color)),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: Theme.of(context).textTheme.titleMedium);
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              if (value.isNotEmpty) Text(value),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RelationTile extends StatelessWidget {
  const _RelationTile({required this.relation, required this.onTap});

  final DocumentRelation relation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 54,
      leading: Icon(_relationIcon(relation.type)),
      title: Text(relation.label),
      subtitle: Text(documentRelationLabel(l10n, relation.type)),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

String? _relationPath(ProjectDocument document, DocumentRelation relation) =>
    switch (relation.type) {
      DocumentRelationType.cost =>
        '/projects/${Uri.encodeComponent(document.projectId)}'
            '/costs/${Uri.encodeComponent(relation.targetId)}',
      DocumentRelationType.quote =>
        '/projects/${Uri.encodeComponent(document.projectId)}'
            '/quotes/${Uri.encodeComponent(relation.targetId)}',
      DocumentRelationType.contact =>
        '/projects/${Uri.encodeComponent(document.projectId)}'
            '/contacts/${Uri.encodeComponent(relation.targetId)}',
      DocumentRelationType.stage ||
      DocumentRelationType.checklistItem => '/plan?tab=stages',
      _ => null,
    };

IconData _relationIcon(DocumentRelationType type) => switch (type) {
  DocumentRelationType.cost => Icons.account_balance_wallet_outlined,
  DocumentRelationType.stage => Icons.account_tree_outlined,
  DocumentRelationType.checklistItem => Icons.checklist_outlined,
  DocumentRelationType.contact => Icons.person_outline,
  DocumentRelationType.room => Icons.meeting_room_outlined,
  DocumentRelationType.quote => Icons.request_quote_outlined,
  DocumentRelationType.decision => Icons.rule_outlined,
  DocumentRelationType.defect => Icons.report_problem_outlined,
  DocumentRelationType.device => Icons.devices_other_outlined,
};

String _fileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
