import 'dart:io';

import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

class DocumentViewerScreen extends ConsumerStatefulWidget {
  const DocumentViewerScreen({
    required this.projectId,
    required this.documentId,
    super.key,
  });

  final String projectId;
  final String documentId;

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  late Future<_ViewerData?> _load;

  @override
  void initState() {
    super.initState();
    _load = _request();
  }

  Future<_ViewerData?> _request() async {
    final document = await (await ref.read(
      documentRepositoryProvider.future,
    )).findById(projectId: widget.projectId, documentId: widget.documentId);
    if (document == null) return null;
    final file = await (await ref.read(localAttachmentStagerProvider.future))
        .originalFile(
          projectId: widget.projectId,
          attachmentId: widget.documentId,
        );
    return file == null ? null : _ViewerData(document: document, file: file);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentViewerTitle)),
      body: FutureBuilder<_ViewerData?>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppLoadingState(label: l10n.documentViewerTitle);
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
          if (data.document.isPdf) {
            return PdfViewer.file(
              data.file.path,
              params: const PdfViewerParams(backgroundColor: Color(0xFFE6E8E5)),
            );
          }
          if (data.document.isImage) {
            return ColoredBox(
              color: Colors.black,
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: Center(
                  child: Image.file(
                    data.file,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        l10n.documentLoadError,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return AppEmptyState(
            icon: Icons.visibility_off_outlined,
            title: l10n.documentPreviewUnavailable,
            message: l10n.documentPreviewUnavailableMessage,
          );
        },
      ),
    );
  }
}

final class _ViewerData {
  const _ViewerData({required this.document, required this.file});

  final ProjectDocument document;
  final File file;
}
