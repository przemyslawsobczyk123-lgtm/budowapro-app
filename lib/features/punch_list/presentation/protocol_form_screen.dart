import 'dart:async';

import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/punch_list/data/punch_providers.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/presentation/punch_controller.dart';
import 'package:budowapro/features/punch_list/presentation/punch_ui_text.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProtocolFormScreen extends ConsumerWidget {
  const ProtocolFormScreen({
    required this.projectId,
    this.protocolId,
    this.initialDefectId,
    super.key,
  });

  final String projectId;
  final String? protocolId;
  final String? initialDefectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final punch = ref.watch(punchControllerProvider);
    final defectOptions = ref.watch(protocolDefectOptionsProvider(projectId));
    if (punch.isLoading || defectOptions.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            protocolId == null ? l10n.protocolNewTitle : l10n.protocolEditTitle,
          ),
        ),
        body: AppLoadingState(label: l10n.punchLoading),
      );
    }
    if (punch.hasError || defectOptions.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.protocolEditTitle)),
        body: AppErrorState(
          title: l10n.punchLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () {
            ref.invalidate(punchControllerProvider);
            ref.invalidate(protocolDefectOptionsProvider(projectId));
          },
        ),
      );
    }
    final state = punch.requireValue;
    if (state.project?.id != projectId) return _notFound(context);
    final id = protocolId;
    if (id == null) {
      return _ProtocolFormBody(
        state: state,
        defectOptions: defectOptions.requireValue,
        initialDefectId: initialDefectId,
      );
    }
    final protocol = ref.watch(
      acceptanceProtocolProvider((projectId: projectId, protocolId: id)),
    );
    return protocol.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.protocolEditTitle)),
        body: AppLoadingState(label: l10n.punchLoading),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.protocolEditTitle)),
        body: AppErrorState(
          title: l10n.punchLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(
            acceptanceProtocolProvider((projectId: projectId, protocolId: id)),
          ),
        ),
      ),
      data: (value) => value == null
          ? _notFound(context)
          : _ProtocolFormBody(
              state: state,
              defectOptions: defectOptions.requireValue,
              protocol: value,
            ),
    );
  }

  Widget _notFound(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.protocolEditTitle)),
      body: AppEmptyState(
        icon: Icons.find_in_page_outlined,
        title: l10n.protocolNotFound,
        message: l10n.protocolNotFound,
      ),
    );
  }
}

class _ProtocolFormBody extends ConsumerStatefulWidget {
  const _ProtocolFormBody({
    required this.state,
    required this.defectOptions,
    this.protocol,
    this.initialDefectId,
  });

  final PunchState state;
  final List<DefectRecord> defectOptions;
  final AcceptanceProtocol? protocol;
  final String? initialDefectId;

  @override
  ConsumerState<_ProtocolFormBody> createState() => _ProtocolFormBodyState();
}

class _ProtocolFormBodyState extends ConsumerState<_ProtocolFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _room;
  late final TextEditingController _notes;
  late DateTime _inspectedAt;
  late AcceptanceProtocolStatus _status;
  String? _stageId;
  String? _contractorContactId;
  late Set<String> _defectIds;
  late List<String> _signedAttachmentIds;
  final _ownedAttachmentIds = <String>[];
  final _removedAttachmentIds = <String>[];
  var _saving = false;
  var _saved = false;

  @override
  void initState() {
    super.initState();
    final input = widget.protocol?.input;
    _title = TextEditingController(text: input?.title);
    _room = TextEditingController(text: input?.roomLabel);
    _notes = TextEditingController(text: input?.notes);
    _inspectedAt = input?.inspectedAtUtc.toLocal() ?? DateTime.now();
    _status = input?.status ?? AcceptanceProtocolStatus.draft;
    _stageId = input?.stageId;
    _contractorContactId = input?.contractorContactId;
    _defectIds = input?.defectIds.toSet() ?? <String>{};
    final initialDefectId = widget.initialDefectId;
    if (initialDefectId != null &&
        widget.defectOptions.any((defect) => defect.id == initialDefectId)) {
      _defectIds.add(initialDefectId);
    }
    _signedAttachmentIds = input?.signedAttachmentIds.toList() ?? <String>[];
  }

  @override
  void dispose() {
    _title.dispose();
    _room.dispose();
    _notes.dispose();
    if (!_saved && _ownedAttachmentIds.isNotEmpty) {
      unawaited(_discardOwnedAttachments());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedDefects = widget.defectOptions
        .where((defect) => _defectIds.contains(defect.id))
        .toList(growable: false);
    return Scaffold(
      key: const ValueKey('protocolFormScreen'),
      appBar: AppBar(
        title: Text(
          widget.protocol == null
              ? l10n.protocolNewTitle
              : l10n.protocolEditTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            TextFormField(
              key: const ValueKey('protocolTitleField'),
              controller: _title,
              maxLength: PunchFieldLimits.title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.protocolTitleLabel),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.protocolTitleLabel
                  : null,
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<AcceptanceProtocolStatus>(
              initialValue: _status,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.protocolStatusLabel),
              items: AcceptanceProtocolStatus.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(acceptanceProtocolStatusLabel(l10n, value)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${l10n.protocolDateLabel}: '
                  '${DateFormat('dd.MM.yyyy', 'pl_PL').format(_inspectedAt)}',
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
              decoration: InputDecoration(labelText: l10n.protocolStageLabel),
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
              decoration: InputDecoration(labelText: l10n.protocolRoomLabel),
            ),
            DropdownButtonFormField<String?>(
              initialValue:
                  widget.state.contacts.any(
                    (contact) => contact.id == _contractorContactId,
                  )
                  ? _contractorContactId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.protocolContractorLabel,
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
                  setState(() => _contractorContactId = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 7,
              maxLength: PunchFieldLimits.description,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.protocolNotesLabel,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.protocolDefectsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _saving ? null : _selectDefects,
                  icon: const Icon(Icons.playlist_add_check_rounded),
                  label: Text(l10n.protocolSelectDefects),
                ),
              ],
            ),
            if (selectedDefects.isEmpty)
              Text(
                l10n.protocolNoDefects,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...selectedDefects.map(
                (defect) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.report_problem_outlined),
                  title: Text(
                    defect.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${defectSeverityLabel(l10n, defect.severity)} · '
                    '${defectStatusLabel(l10n, defect.status)}',
                  ),
                  trailing: IconButton(
                    tooltip: l10n.defectRemoveEvidence,
                    onPressed: _saving
                        ? null
                        : () => setState(() => _defectIds.remove(defect.id)),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.protocolSignedFilesTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.protocolAddSignedFile,
                  onPressed: _saving ? null : _addSignedFile,
                  icon: const Icon(Icons.attach_file_rounded),
                ),
              ],
            ),
            if (_signedAttachmentIds.isEmpty)
              Text(
                l10n.protocolNoSignedFile,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ..._signedAttachmentIds.map(
                (id) => _ProtocolAttachmentTile(
                  projectId: widget.state.project!.id,
                  attachmentId: id,
                  onRemove: _saving ? null : () => _removeSignedFile(id),
                ),
              ),
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const ValueKey('saveProtocolButton'),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.protocolSaveAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _inspectedAt,
    );
    if (value != null && mounted) setState(() => _inspectedAt = value);
  }

  Future<void> _selectDefects() async {
    final selected = Set<String>.of(_defectIds);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final l10n = AppLocalizations.of(context);
          return SafeArea(
            child: FractionallySizedBox(
              heightFactor: 0.82,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.protocolSelectDefects,
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
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.defectOptions.length,
                      itemBuilder: (context, index) {
                        final defect = widget.defectOptions[index];
                        return CheckboxListTile(
                          value: selected.contains(defect.id),
                          title: Text(defect.title),
                          subtitle: Text(
                            '${defectSeverityLabel(l10n, defect.severity)} · '
                            '${defectStatusLabel(l10n, defect.status)}',
                          ),
                          onChanged: (value) => setModalState(() {
                            value == true
                                ? selected.add(defect.id)
                                : selected.remove(defect.id);
                          }),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(selected),
                        icon: const Icon(Icons.check_rounded),
                        label: Text(l10n.protocolSelectDefectsDone),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (result != null && mounted) setState(() => _defectIds = result);
  }

  Future<void> _addSignedFile() async {
    final l10n = AppLocalizations.of(context);
    try {
      final picked = await ref.read(localAttachmentPickerProvider).pick();
      if (picked == null) return;
      final stager = await ref.read(localAttachmentStagerProvider.future);
      final attachment = await stager.stage(
        projectId: widget.state.project!.id,
        pickedFile: picked,
      );
      final mediaType = attachment.mediaType ?? '';
      if (mediaType != 'application/pdf' && !mediaType.startsWith('image/')) {
        await stager.discard(
          projectId: attachment.projectId,
          attachmentId: attachment.id,
        );
        if (mounted) _message(l10n.protocolUnsupportedFile);
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
        _signedAttachmentIds.add(attachment.id);
        _ownedAttachmentIds.add(attachment.id);
      });
    } on Object {
      if (mounted) _message(l10n.defectAttachmentError);
    }
  }

  void _removeSignedFile(String id) {
    setState(() {
      _signedAttachmentIds.remove(id);
      if (!_ownedAttachmentIds.remove(id)) _removedAttachmentIds.add(id);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    if (_status == AcceptanceProtocolStatus.signed &&
        _signedAttachmentIds.isEmpty) {
      _message(l10n.protocolSignedFileRequired);
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(punchControllerProvider.notifier)
          .saveProtocol(
            AcceptanceProtocolInput(
              projectId: widget.state.project!.id,
              title: _title.text,
              inspectedAt: _inspectedAt,
              status: _status,
              stageId: _stageId,
              roomLabel: _room.text,
              contractorContactId: _contractorContactId,
              notes: _notes.text,
              defectIds: _defectIds,
              signedAttachmentIds: _signedAttachmentIds,
            ),
            protocolId: widget.protocol?.id,
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
      _message(l10n.protocolSavedMessage);
      Navigator.of(context).pop(true);
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        _message(l10n.protocolSaveError);
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

class _ProtocolAttachmentTile extends ConsumerWidget {
  const _ProtocolAttachmentTile({
    required this.projectId,
    required this.attachmentId,
    required this.onRemove,
  });

  final String projectId;
  final String attachmentId;
  final VoidCallback? onRemove;

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
      trailing: IconButton(
        tooltip: AppLocalizations.of(context).defectRemoveEvidence,
        onPressed: onRemove,
        icon: const Icon(Icons.remove_circle_outline),
      ),
    );
  }
}
