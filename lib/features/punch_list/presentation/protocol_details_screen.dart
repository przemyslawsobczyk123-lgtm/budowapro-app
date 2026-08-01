import 'package:budowapro/features/punch_list/data/punch_providers.dart';
import 'package:budowapro/features/punch_list/data/protocol_pdf_gateway.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/presentation/punch_controller.dart';
import 'package:budowapro/features/punch_list/presentation/punch_ui_text.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProtocolDetailsScreen extends ConsumerWidget {
  const ProtocolDetailsScreen({
    required this.projectId,
    required this.protocolId,
    super.key,
  });

  final String projectId;
  final String protocolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final target = (projectId: projectId, protocolId: protocolId);
    final protocol = ref.watch(acceptanceProtocolProvider(target));
    return Scaffold(
      key: const ValueKey('protocolDetailsScreen'),
      appBar: AppBar(
        title: Text(l10n.protocolDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.protocolEditTooltip,
            onPressed: protocol.value == null
                ? null
                : () async {
                    final saved = await context.push<bool>(
                      '/projects/${Uri.encodeComponent(projectId)}'
                      '/punch/protocols/${Uri.encodeComponent(protocolId)}/edit',
                    );
                    if (saved == true) {
                      ref.invalidate(acceptanceProtocolProvider(target));
                    }
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: protocol.when(
        loading: () => AppLoadingState(label: l10n.punchLoading),
        error: (error, stackTrace) => AppErrorState(
          title: l10n.punchLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(acceptanceProtocolProvider(target)),
        ),
        data: (value) => value == null
            ? AppEmptyState(
                icon: Icons.find_in_page_outlined,
                title: l10n.protocolNotFound,
                message: l10n.protocolNotFound,
              )
            : _ProtocolDetailsBody(protocol: value),
      ),
    );
  }
}

class _ProtocolDetailsBody extends ConsumerStatefulWidget {
  const _ProtocolDetailsBody({required this.protocol});

  final AcceptanceProtocol protocol;

  @override
  ConsumerState<_ProtocolDetailsBody> createState() =>
      _ProtocolDetailsBodyState();
}

class _ProtocolDetailsBodyState extends ConsumerState<_ProtocolDetailsBody> {
  var _sharingPdf = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final protocol = widget.protocol;
    final punch = ref.watch(punchControllerProvider).value;
    final defects = ref.watch(
      protocolDefectOptionsProvider(protocol.projectId),
    );
    final stage = punch?.stages
        .where((item) => item.id == protocol.input.stageId)
        .firstOrNull;
    final contact = punch?.contacts
        .where((item) => item.id == protocol.input.contractorContactId)
        .firstOrNull;
    final defectsById = <String, DefectRecord>{
      for (final defect in defects.value ?? const <DefectRecord>[])
        defect.id: defect,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(protocol.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: Icon(
              protocol.status == AcceptanceProtocolStatus.signed
                  ? Icons.verified_outlined
                  : Icons.assignment_outlined,
              size: 18,
            ),
            label: Text(acceptanceProtocolStatusLabel(l10n, protocol.status)),
          ),
        ),
        const SizedBox(height: 8),
        _ProtocolInfoRow(
          icon: Icons.event_outlined,
          label: l10n.protocolDateLabel,
          value: DateFormat(
            'dd.MM.yyyy',
            'pl_PL',
          ).format(protocol.inspectedAtUtc.toLocal()),
        ),
        if (stage != null)
          _ProtocolInfoRow(
            icon: Icons.account_tree_outlined,
            label: l10n.protocolStageLabel,
            value: stageName(l10n, stage),
          ),
        if (protocol.input.roomLabel != null)
          _ProtocolInfoRow(
            icon: Icons.meeting_room_outlined,
            label: l10n.protocolRoomLabel,
            value: protocol.input.roomLabel!,
          ),
        if (contact != null)
          _ProtocolInfoRow(
            icon: Icons.engineering_outlined,
            label: l10n.protocolContractorLabel,
            value: contact.displayName,
          ),
        if (protocol.input.notes != null) ...[
          const SizedBox(height: 16),
          Text(
            l10n.protocolNotesLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(protocol.input.notes!),
        ],
        const SizedBox(height: 20),
        Text(
          l10n.protocolDefectsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (protocol.defectIds.isEmpty)
          Text(
            l10n.protocolNoDefects,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...protocol.defectIds.map((id) {
            final defect = defectsById[id];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.report_problem_outlined),
              title: Text(
                defect?.title ?? id,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: defect == null
                  ? null
                  : Text(
                      '${defectSeverityLabel(l10n, defect.severity)} · '
                      '${defectStatusLabel(l10n, defect.status)}',
                    ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(
                '/projects/${Uri.encodeComponent(protocol.projectId)}'
                '/punch/defects/${Uri.encodeComponent(id)}',
              ),
            );
          }),
        const SizedBox(height: 16),
        Text(
          l10n.protocolSignedFilesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (protocol.signedAttachmentIds.isEmpty)
          Text(
            l10n.protocolNoSignedFile,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...protocol.signedAttachmentIds.map(
            (id) => _SignedFileTile(
              projectId: protocol.projectId,
              attachmentId: id,
            ),
          ),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const ValueKey('shareProtocolPdfButton'),
          onPressed: _sharingPdf || defects.isLoading || punch?.project == null
              ? null
              : () => _sharePdf(
                  projectName: punch!.project!.name,
                  stageLabel: stage == null ? null : stageName(l10n, stage),
                  contractorLabel: contact?.displayName,
                  defects: protocol.defectIds
                      .map((id) => defectsById[id])
                      .whereType<DefectRecord>()
                      .toList(growable: false),
                ),
          icon: _sharingPdf
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(l10n.protocolGeneratePdf),
        ),
      ],
    );
  }

  Future<void> _sharePdf({
    required String projectName,
    required String? stageLabel,
    required String? contractorLabel,
    required List<DefectRecord> defects,
  }) async {
    final l10n = AppLocalizations.of(context);
    final protocol = widget.protocol;
    setState(() => _sharingPdf = true);
    try {
      await ref
          .read(protocolPdfGatewayProvider)
          .share(
            request: ProtocolPdfRequest(
              projectName: projectName,
              protocolTitle: protocol.title,
              inspectedAt: DateFormat(
                'dd.MM.yyyy',
                'pl_PL',
              ).format(protocol.inspectedAtUtc.toLocal()),
              status: acceptanceProtocolStatusLabel(l10n, protocol.status),
              stage: stageLabel,
              room: protocol.input.roomLabel,
              contractor: contractorLabel,
              notes: protocol.input.notes,
              defects: defects.map(
                (defect) => ProtocolPdfDefectRow(
                  title: defect.title,
                  severity: defectSeverityLabel(l10n, defect.severity),
                  status: defectStatusLabel(l10n, defect.status),
                  deadline: defect.dueAtUtc == null
                      ? null
                      : DateFormat(
                          'dd.MM.yyyy',
                          'pl_PL',
                        ).format(defect.dueAtUtc!.toLocal()),
                ),
              ),
              labels: ProtocolPdfLabels(
                documentTitle: l10n.protocolPdfTitle,
                project: l10n.protocolPdfProjectLabel,
                date: l10n.protocolDateLabel,
                status: l10n.protocolStatusLabel,
                stage: l10n.protocolStageLabel,
                room: l10n.protocolRoomLabel,
                contractor: l10n.protocolContractorLabel,
                notes: l10n.protocolNotesLabel,
                defects: l10n.protocolDefectsTitle,
                defectTitle: l10n.protocolPdfDefectTitleLabel,
                severity: l10n.punchSeverityLabel,
                deadline: l10n.protocolPdfDeadlineLabel,
                noDefects: l10n.protocolNoDefects,
                signatures: l10n.protocolPdfSignaturesTitle,
                investorSignature: l10n.protocolPdfInvestorSignature,
                contractorSignature: l10n.protocolPdfContractorSignature,
                generatedNotice: l10n.protocolPdfGeneratedNotice,
              ),
            ),
            fileStem: 'protokol-${protocol.id}',
          );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.protocolPdfShareError)));
      }
    } finally {
      if (mounted) setState(() => _sharingPdf = false);
    }
  }
}

class _ProtocolInfoRow extends StatelessWidget {
  const _ProtocolInfoRow({
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('$label: $value')),
        ],
      ),
    );
  }
}

class _SignedFileTile extends ConsumerWidget {
  const _SignedFileTile({required this.projectId, required this.attachmentId});

  final String projectId;
  final String attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachment = ref.watch(
      punchAttachmentProvider((
        projectId: projectId,
        attachmentId: attachmentId,
      )),
    );
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        attachment.value?.mediaType == 'application/pdf'
            ? Icons.picture_as_pdf_outlined
            : Icons.image_outlined,
      ),
      title: Text(
        attachment.value?.displayName ?? attachmentId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
