import 'dart:async';

import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/punch_list/data/punch_providers.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/domain/punch_repository.dart';
import 'package:budowapro/features/punch_list/presentation/punch_controller.dart';
import 'package:budowapro/features/punch_list/presentation/punch_ui_text.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DefectFormScreen extends ConsumerWidget {
  const DefectFormScreen({required this.projectId, this.defectId, super.key});

  final String projectId;
  final String? defectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final punch = ref.watch(punchControllerProvider);
    return punch.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(
            defectId == null ? l10n.defectNewTitle : l10n.defectEditTitle,
          ),
        ),
        body: AppLoadingState(label: l10n.punchLoading),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.defectEditTitle)),
        body: AppErrorState(
          title: l10n.punchLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.read(punchControllerProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        if (state.project?.id != projectId) {
          return _notFound(context);
        }
        final id = defectId;
        if (id == null) return _DefectFormBody(state: state);
        final defect = ref.watch(
          defectProvider((projectId: projectId, defectId: id)),
        );
        return defect.when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.defectEditTitle)),
            body: AppLoadingState(label: l10n.punchLoading),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(l10n.defectEditTitle)),
            body: AppErrorState(
              title: l10n.punchLoadError,
              retryLabel: l10n.retryAction,
              onRetry: () => ref.invalidate(
                defectProvider((projectId: projectId, defectId: id)),
              ),
            ),
          ),
          data: (value) => value == null
              ? _notFound(context)
              : _DefectFormBody(state: state, defect: value),
        );
      },
    );
  }

  Widget _notFound(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.defectEditTitle)),
      body: AppEmptyState(
        icon: Icons.find_in_page_outlined,
        title: l10n.defectNotFound,
        message: l10n.defectNotFound,
      ),
    );
  }
}

class _DefectFormBody extends ConsumerStatefulWidget {
  const _DefectFormBody({required this.state, this.defect});

  final PunchState state;
  final DefectRecord? defect;

  @override
  ConsumerState<_DefectFormBody> createState() => _DefectFormBodyState();
}

class _DefectFormBodyState extends ConsumerState<_DefectFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _room;
  late DateTime _occurredAt;
  DateTime? _dueAt;
  late DefectSeverity _severity;
  late JournalEntryStatus _status;
  String? _stageId;
  String? _responsibleContactId;
  late bool _requiresResolutionPhoto;
  late bool _requiresSignedProtocol;
  late List<String> _reportAttachmentIds;
  late List<String> _resolutionAttachmentIds;
  final _ownedAttachmentIds = <String>[];
  final _removedAttachmentIds = <String>[];
  var _saving = false;
  var _saved = false;

  @override
  void initState() {
    super.initState();
    final defect = widget.defect;
    _title = TextEditingController(text: defect?.title);
    _description = TextEditingController(text: defect?.description);
    _room = TextEditingController(text: defect?.roomLabel);
    _occurredAt = defect?.entry.input.occurredAt.toLocal() ?? DateTime.now();
    _dueAt = defect?.dueAtUtc?.toLocal();
    _severity = defect?.severity ?? DefectSeverity.medium;
    _status = defect?.status ?? JournalEntryStatus.open;
    _stageId = defect?.stageId;
    _responsibleContactId = defect?.responsibleContactId;
    _requiresResolutionPhoto = defect?.requiresResolutionPhoto ?? true;
    _requiresSignedProtocol = defect?.requiresSignedProtocol ?? false;
    _reportAttachmentIds = defect?.entry.input.attachmentIds.toList() ?? [];
    _resolutionAttachmentIds = defect?.resolutionAttachmentIds.toList() ?? [];
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _room.dispose();
    if (!_saved && _ownedAttachmentIds.isNotEmpty) {
      unawaited(_discardOwnedAttachments());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statuses = allowedStatusesFor(JournalEntryType.defect)
        .where((status) => status != JournalEntryStatus.draft)
        .toList(growable: false);
    return Scaffold(
      key: const ValueKey('defectFormScreen'),
      appBar: AppBar(
        title: Text(
          widget.defect == null ? l10n.defectNewTitle : l10n.defectEditTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            TextFormField(
              key: const ValueKey('defectTitleField'),
              controller: _title,
              maxLength: PunchFieldLimits.title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.defectTitleLabel),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.defectTitleLabel
                  : null,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<DefectSeverity>(
                    initialValue: _severity,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.punchSeverityLabel,
                    ),
                    items: DefectSeverity.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(defectSeverityLabel(l10n, value)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) =>
                        setState(() => _severity = value ?? _severity),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<JournalEntryStatus>(
                    initialValue: _status,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.punchStatusLabel,
                    ),
                    items: statuses
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(defectStatusLabel(l10n, value)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) =>
                        setState(() => _status = value ?? _status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _pickDate(isDueDate: false),
              icon: const Icon(Icons.event_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${l10n.defectOccurredAtLabel}: '
                  '${DateFormat('dd.MM.yyyy', 'pl_PL').format(_occurredAt)}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue:
                  widget.state.stages.any((stage) => stage.id == _stageId)
                  ? _stageId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.defectStageLabel),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.defectNoStage),
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
            TextFormField(
              controller: _room,
              maxLength: PunchFieldLimits.room,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.defectRoomLabel),
            ),
            DropdownButtonFormField<String?>(
              initialValue:
                  widget.state.contacts.any(
                    (contact) => contact.id == _responsibleContactId,
                  )
                  ? _responsibleContactId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.defectResponsibleLabel,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.defectNoResponsible),
                ),
                ...widget.state.contacts.map(
                  (contact) => DropdownMenuItem<String?>(
                    value: contact.id,
                    child: Text(contact.displayName),
                  ),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _responsibleContactId = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 7,
              maxLength: PunchFieldLimits.description,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.defectDescriptionLabel,
                alignLabelWithHint: true,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _pickDate(isDueDate: true),
              icon: const Icon(Icons.schedule_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _dueAt == null
                      ? l10n.defectDueAtLabel
                      : '${l10n.defectDueAtLabel}: '
                            '${DateFormat('dd.MM.yyyy', 'pl_PL').format(_dueAt!)}',
                ),
              ),
            ),
            if (_dueAt != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() => _dueAt = null),
                  child: Text(l10n.defectClearDueAt),
                ),
              ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _requiresResolutionPhoto,
              title: Text(l10n.defectRequiresPhoto),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _requiresResolutionPhoto = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _requiresSignedProtocol,
              title: Text(l10n.defectRequiresProtocol),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _requiresSignedProtocol = value),
            ),
            const SizedBox(height: 8),
            _attachmentSection(
              title: l10n.defectReportEvidenceTitle,
              attachmentIds: _reportAttachmentIds,
              resolution: false,
            ),
            const SizedBox(height: 12),
            _attachmentSection(
              title: l10n.defectResolutionEvidenceTitle,
              attachmentIds: _resolutionAttachmentIds,
              resolution: true,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const ValueKey('saveDefectButton'),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.defectSaveAction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentSection({
    required String title,
    required List<String> attachmentIds,
    required bool resolution,
  }) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.defectAddEvidence,
              onPressed: _saving ? null : () => _addAttachment(resolution),
              icon: const Icon(Icons.add_a_photo_outlined),
            ),
          ],
        ),
        if (attachmentIds.isEmpty)
          Text(
            l10n.defectNoEvidence,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...attachmentIds.map(
            (id) => _PunchAttachmentTile(
              projectId: widget.state.project!.id,
              attachmentId: id,
              onRemove: _saving
                  ? null
                  : () => _removeAttachment(id, resolution),
            ),
          ),
      ],
    );
  }

  Future<void> _pickDate({required bool isDueDate}) async {
    final initial = isDueDate ? _dueAt ?? DateTime.now() : _occurredAt;
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (value == null || !mounted) return;
    setState(() {
      if (isDueDate) {
        _dueAt = value;
      } else {
        _occurredAt = value;
      }
    });
  }

  Future<void> _addAttachment(bool resolution) async {
    final l10n = AppLocalizations.of(context);
    try {
      final picked = await ref.read(localAttachmentPickerProvider).pick();
      if (picked == null) return;
      final stager = await ref.read(localAttachmentStagerProvider.future);
      final attachment = await stager.stage(
        projectId: widget.state.project!.id,
        pickedFile: picked,
      );
      if (!(attachment.mediaType?.startsWith('image/') ?? false)) {
        await stager.discard(
          projectId: attachment.projectId,
          attachmentId: attachment.id,
        );
        if (mounted) _message(l10n.defectUnsupportedEvidence);
        return;
      }
      if (!mounted) {
        await stager.discardIfUnlinked(
          projectId: attachment.projectId,
          attachmentId: attachment.id,
        );
        return;
      }
      setState(() {
        (resolution ? _resolutionAttachmentIds : _reportAttachmentIds).add(
          attachment.id,
        );
        _ownedAttachmentIds.add(attachment.id);
      });
    } on Object {
      if (mounted) _message(l10n.defectAttachmentError);
    }
  }

  void _removeAttachment(String id, bool resolution) {
    setState(() {
      (resolution ? _resolutionAttachmentIds : _reportAttachmentIds).remove(id);
      if (!_ownedAttachmentIds.remove(id)) _removedAttachmentIds.add(id);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(punchControllerProvider.notifier)
          .saveDefect(
            DefectInput(
              projectId: widget.state.project!.id,
              title: _title.text,
              occurredAt: _occurredAt,
              severity: _severity,
              status: _status,
              description: _description.text,
              stageId: _stageId,
              roomLabel: _room.text,
              responsibleContactId: _responsibleContactId,
              dueAt: _dueAt,
              requiresResolutionPhoto: _requiresResolutionPhoto,
              requiresSignedProtocol: _requiresSignedProtocol,
              attachmentIds: _reportAttachmentIds,
              resolutionAttachmentIds: _resolutionAttachmentIds,
            ),
            defectId: widget.defect?.id,
          );
      final stager = await ref.read(localAttachmentStagerProvider.future);
      for (final id in _removedAttachmentIds) {
        await stager.discardIfUnlinked(
          projectId: saved.projectId,
          attachmentId: id,
        );
      }
      _ownedAttachmentIds.clear();
      _saved = true;
      if (!mounted) return;
      _message(l10n.defectSavedMessage);
      Navigator.of(context).pop(true);
    } on DefectClosureEvidenceRequiredException {
      if (mounted) {
        setState(() => _saving = false);
        _message(l10n.defectClosureMissingPhoto);
      }
    } on DefectClosureProtocolRequiredException {
      if (mounted) {
        setState(() => _saving = false);
        _message(l10n.defectClosureMissingProtocol);
      }
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        _message(l10n.defectSaveError);
      }
    }
  }

  Future<void> _discardOwnedAttachments() async {
    final stager = await ref.read(localAttachmentStagerProvider.future);
    for (final id in List<String>.of(_ownedAttachmentIds)) {
      await stager.discardIfUnlinked(
        projectId: widget.state.project!.id,
        attachmentId: id,
      );
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _PunchAttachmentTile extends ConsumerWidget {
  const _PunchAttachmentTile({
    required this.projectId,
    required this.attachmentId,
    required this.onRemove,
  });

  final String projectId;
  final String attachmentId;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final attachment = ref.watch(
      punchAttachmentProvider((
        projectId: projectId,
        attachmentId: attachmentId,
      )),
    );
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.image_outlined),
      title: Text(
        attachment.value?.displayName ?? attachmentId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip: l10n.defectRemoveEvidence,
        onPressed: onRemove,
        icon: const Icon(Icons.remove_circle_outline),
      ),
    );
  }
}
