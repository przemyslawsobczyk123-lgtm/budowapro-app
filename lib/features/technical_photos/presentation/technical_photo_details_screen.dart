import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_editor_gateway.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TechnicalPhotoDetailsScreen extends ConsumerWidget {
  const TechnicalPhotoDetailsScreen({
    required this.projectId,
    required this.attachmentId,
    super.key,
  });

  final String projectId;
  final String attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final target = (projectId: projectId, attachmentId: attachmentId);
    final data = ref.watch(technicalPhotoEditorDataProvider(target));
    return data.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.technicalPhotoDetailsTitle)),
        body: AppLoadingState(label: l10n.technicalPhotosLoading),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.technicalPhotoDetailsTitle)),
        body: AppErrorState(
          title: l10n.technicalPhotoNotFound,
          retryLabel: l10n.retryAction,
          onRetry: () =>
              ref.invalidate(technicalPhotoEditorDataProvider(target)),
        ),
      ),
      data: (value) {
        final photo = value.photo;
        if (photo == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.technicalPhotoDetailsTitle)),
            body: AppEmptyState(
              icon: Icons.hide_image_outlined,
              title: l10n.technicalPhotoNotFound,
              message: l10n.technicalPhotosMissingPreview,
            ),
          );
        }
        final album = value.albums
            .where((item) => item.album.id == photo.albumId)
            .firstOrNull
            ?.album;
        final stage = value.stages
            .where((item) => item.id == photo.stageId)
            .firstOrNull;
        final contact = value.contacts
            .where((item) => item.id == photo.contractorContactId)
            .firstOrNull;
        final checklist = value.checklistItems
            .where((item) => item.id == photo.checklistItemId)
            .firstOrNull;
        return Scaffold(
          key: const ValueKey('technicalPhotoDetailsScreen'),
          appBar: AppBar(
            title: Text(l10n.technicalPhotoDetailsTitle),
            actions: [
              IconButton(
                tooltip: l10n.technicalPhotoEditTooltip,
                onPressed: () async {
                  final changed = await context.push<bool>(
                    '/projects/${Uri.encodeComponent(projectId)}'
                    '/technical/${Uri.encodeComponent(attachmentId)}/edit',
                  );
                  if (changed == true) {
                    ref.invalidate(technicalPhotoEditorDataProvider(target));
                  }
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: value.originalFile == null
                      ? _MissingFile(label: l10n.technicalPhotosMissingPreview)
                      : Image.file(
                          value.originalFile!,
                          fit: BoxFit.contain,
                          cacheWidth: 1440,
                          errorBuilder: (context, error, stackTrace) =>
                              _MissingFile(
                                label: l10n.technicalPhotosMissingPreview,
                              ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(photo.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.folder_outlined,
                label: l10n.technicalFilterAlbumLabel,
                value: album?.title ?? photo.albumId,
              ),
              _DetailRow(
                icon: Icons.event_outlined,
                label: l10n.technicalPhotoDateLabel,
                value: DateFormat(
                  'dd.MM.yyyy',
                  'pl_PL',
                ).format(photo.capturedAtUtc.toLocal()),
              ),
              _DetailRow(
                icon: Icons.account_tree_outlined,
                label: l10n.technicalFilterInstallationLabel,
                value: technicalInstallationLabel(l10n, photo.installationType),
              ),
              if (stage != null)
                _DetailRow(
                  icon: Icons.stairs_outlined,
                  label: l10n.technicalFilterStageLabel,
                  value: stageName(l10n, stage),
                ),
              if (photo.zoneLabel != null)
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: l10n.technicalPhotoZoneLabel,
                  value: photo.zoneLabel!,
                ),
              if (contact != null)
                _DetailRow(
                  icon: Icons.engineering_outlined,
                  label: l10n.technicalPhotoContractorLabel,
                  value: contact.displayName,
                ),
              if (checklist != null)
                _DetailRow(
                  icon: Icons.fact_check_outlined,
                  label: l10n.technicalPhotoLinkedChecklist,
                  value: checklistTitle(l10n, checklist),
                ),
              if (photo.links.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.technicalPhotoLinksTitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                ...photo.links.map(
                  (link) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_linkIcon(link.type)),
                    title: Text(technicalPhotoLinkTypeLabel(l10n, link.type)),
                    subtitle: Text(
                      _linkLabel(value.linkOptions, link),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(
                      _linkRoute(projectId: projectId, link: link),
                    ),
                  ),
                ),
              ],
              if (photo.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.technicalPhotoDescriptionLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                SelectableText(photo.description!),
              ],
              if (photo.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: photo.tags
                      .map(
                        (tag) => Chip(
                          avatar: const Icon(Icons.tag_rounded, size: 16),
                          label: Text(tag),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              if (value.originalFile != null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.push(
                    '/projects/${Uri.encodeComponent(projectId)}'
                    '/documents/${Uri.encodeComponent(attachmentId)}/view',
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(l10n.technicalPhotoOpenFile),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _linkLabel(
  Iterable<TechnicalPhotoLinkOption> options,
  TechnicalPhotoLink link,
) {
  return options
          .where(
            (option) =>
                option.type == link.type && option.targetId == link.targetId,
          )
          .firstOrNull
          ?.label ??
      link.targetId;
}

IconData _linkIcon(TechnicalPhotoLinkType type) => switch (type) {
  TechnicalPhotoLinkType.cost => Icons.payments_outlined,
  TechnicalPhotoLinkType.decision => Icons.gavel_outlined,
  TechnicalPhotoLinkType.defect => Icons.report_problem_outlined,
  TechnicalPhotoLinkType.acceptanceProtocol =>
    Icons.assignment_turned_in_outlined,
};

String _linkRoute({
  required String projectId,
  required TechnicalPhotoLink link,
}) {
  final project = Uri.encodeComponent(projectId);
  final target = Uri.encodeComponent(link.targetId);
  return switch (link.type) {
    TechnicalPhotoLinkType.cost => '/projects/$project/costs/$target',
    TechnicalPhotoLinkType.decision => '/diary/$target',
    TechnicalPhotoLinkType.defect => '/projects/$project/punch/defects/$target',
    TechnicalPhotoLinkType.acceptanceProtocol =>
      '/projects/$project/punch/protocols/$target',
  };
}

class _MissingFile extends StatelessWidget {
  const _MissingFile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('technicalPhotoDetailsMissingFile'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined, size: 40),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
