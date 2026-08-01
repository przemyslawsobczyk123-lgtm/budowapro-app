import 'package:budowapro/features/contacts/presentation/contacts_controller.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/diary/presentation/journal_controller.dart';
import 'package:budowapro/features/diary/presentation/journal_form_model.dart';
import 'package:budowapro/features/diary/presentation/journal_ui_text.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_controller.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class JournalFormScreen extends ConsumerWidget {
  const JournalFormScreen({this.entryId, super.key});

  final String? entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsControllerProvider);
    final project = projects.value?.selectedProject;
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).journalTitle)),
        body: AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: AppLocalizations.of(context).journalNoProjectTitle,
          message: AppLocalizations.of(context).journalNoProjectMessage,
        ),
      );
    }
    if (entryId == null) {
      return _JournalFormBody(project: project);
    }
    final entry = ref.watch(
      journalEntryProvider((projectId: project.id, entryId: entryId!)),
    );
    return entry.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).journalEditTitle),
        ),
        body: AppLoadingState(label: AppLocalizations.of(context).journalTitle),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).journalEditTitle),
        ),
        body: AppErrorState(
          title: AppLocalizations.of(context).journalLoadError,
          retryLabel: AppLocalizations.of(context).retryAction,
          onRetry: () => ref.invalidate(
            journalEntryProvider((projectId: project.id, entryId: entryId!)),
          ),
        ),
      ),
      data: (value) => value == null
          ? Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context).journalEditTitle),
              ),
              body: AppEmptyState(
                icon: Icons.find_in_page_outlined,
                title: AppLocalizations.of(context).journalEmptyTitle,
                message: AppLocalizations.of(context).journalNoContent,
              ),
            )
          : _JournalFormBody(project: project, entry: value),
    );
  }
}

class _JournalFormBody extends ConsumerStatefulWidget {
  const _JournalFormBody({required this.project, this.entry});

  final Project project;
  final JournalEntry? entry;

  @override
  ConsumerState<_JournalFormBody> createState() => _JournalFormBodyState();
}

class _JournalFormBodyState extends ConsumerState<_JournalFormBody> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _weather;
  late final TextEditingController _people;
  late final TextEditingController _work;
  late final TextEditingController _deliveries;
  late final TextEditingController _delays;
  late final TextEditingController _nextSteps;
  late final TextEditingController _problem;
  late final TextEditingController _variants;
  late final TextEditingController _selectedOption;
  late final TextEditingController _rationale;
  late final TextEditingController _costDelta;
  late final TextEditingController _scheduleDelta;
  late JournalEntryType _type;
  late JournalEntryStatus _status;
  late DateTime _occurredAt;
  DateTime? _dueAt;
  String? _stageId;
  String? _responsibleContactId;
  String? _decisionMakerContactId;
  late Set<String> _blockedScheduleEventIds;
  late List<JournalRelation> _preservedRelations;
  late List<String> _attachmentIds;
  final _ownedAttachmentIds = <String>[];
  final _removedAttachmentIds = <String>[];
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final input = widget.entry?.input;
    _title = TextEditingController(text: input?.title);
    _body = TextEditingController(text: input?.body);
    _weather = TextEditingController(text: input?.weather);
    _people = TextEditingController(text: input?.people);
    _work = TextEditingController(text: input?.workPerformed);
    _deliveries = TextEditingController(text: input?.deliveries);
    _delays = TextEditingController(text: input?.delays);
    _nextSteps = TextEditingController(text: input?.nextSteps);
    _problem = TextEditingController(text: input?.problem);
    _variants = TextEditingController(text: input?.variants);
    _selectedOption = TextEditingController(text: input?.selectedOption);
    _rationale = TextEditingController(text: input?.rationale);
    _costDelta = TextEditingController(
      text: formatJournalCostDelta(input?.costDeltaMinorUnits),
    );
    _scheduleDelta = TextEditingController(
      text: formatJournalScheduleDelta(input?.scheduleDeltaDays),
    );
    _type = input?.type ?? JournalEntryType.daily;
    _status = input?.status ?? defaultStatusFor(_type);
    _occurredAt = input?.occurredAt.toLocal() ?? DateTime.now();
    _dueAt = input?.dueAt?.toLocal();
    _stageId = input?.stageId;
    _responsibleContactId = input?.responsibleContactId;
    _decisionMakerContactId = input?.decisionMakerContactId;
    _blockedScheduleEventIds =
        input?.relations
            .where(
              (relation) =>
                  relation.purpose == JournalRelationPurpose.blocks &&
                  relation.type == JournalRelationType.schedule,
            )
            .map((relation) => relation.targetId)
            .toSet() ??
        <String>{};
    _preservedRelations =
        input?.relations
            .where(
              (relation) =>
                  relation.purpose != JournalRelationPurpose.blocks &&
                  relation.type != JournalRelationType.stage &&
                  relation.type != JournalRelationType.contact,
            )
            .toList(growable: false) ??
        <JournalRelation>[];
    _attachmentIds = input?.attachmentIds.toList() ?? <String>[];
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _title,
      _body,
      _weather,
      _people,
      _work,
      _deliveries,
      _delays,
      _nextSteps,
      _problem,
      _variants,
      _selectedOption,
      _rationale,
      _costDelta,
      _scheduleDelta,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final journalReady = ref.watch(journalControllerProvider).hasValue;
    final stagesAsync = ref.watch(projectStagesProvider(widget.project));
    final contacts =
        ref.watch(contactsControllerProvider).value?.contacts ??
        const <Contact>[];
    final scheduleEvents =
        ref.watch(schedulePlanControllerProvider).value?.openEvents ??
        const <ScheduleEvent>[];
    final isDecision =
        _type == JournalEntryType.decision ||
        _type == JournalEntryType.scopeChange;
    final availableStatuses = allowedStatusesFor(_type)
        .where(
          (status) =>
              (_type != JournalEntryType.defect ||
                  (status != JournalEntryStatus.draft &&
                      (status != JournalEntryStatus.closed ||
                          status == _status))) &&
              (!isDecision ||
                  status == _status ||
                  (status != JournalEntryStatus.approved &&
                      status != JournalEntryStatus.implemented)),
        )
        .toList();
    if (!availableStatuses.contains(_status)) {
      _status = defaultStatusFor(_type);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null ? l10n.journalNewTitle : l10n.journalEditTitle,
        ),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            DropdownButtonFormField<JournalEntryType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.journalTypeRequiredError,
              ),
              items: JournalEntryType.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(journalTypeLabel(l10n, value)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: widget.entry != null
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _type = value;
                        _status = defaultStatusFor(value);
                      });
                    },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.journalTitleLabel),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.journalTitleRequiredError
                  : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickOccurredAt,
              icon: const Icon(Icons.event_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${l10n.journalDateLabel}: '
                  '${DateFormat('dd.MM.yyyy HH:mm', 'pl_PL').format(_occurredAt)}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            stagesAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (error, stackTrace) => const SizedBox.shrink(),
              data: (stages) => DropdownButtonFormField<String?>(
                initialValue: stages.any((stage) => stage.id == _stageId)
                    ? _stageId
                    : null,
                decoration: InputDecoration(labelText: l10n.journalStageLabel),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.journalStageNone),
                  ),
                  ...stages.map(
                    (stage) => DropdownMenuItem<String?>(
                      value: stage.id,
                      child: Text(stageName(l10n, stage)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _stageId = value),
              ),
            ),
            if (contacts.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue:
                    contacts.any(
                      (contact) => contact.id == _responsibleContactId,
                    )
                    ? _responsibleContactId
                    : null,
                decoration: InputDecoration(labelText: l10n.journalPersonLabel),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.journalPersonNone),
                  ),
                  ...contacts.map(
                    (contact) => DropdownMenuItem<String?>(
                      value: contact.id,
                      child: Text(contact.displayName),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _responsibleContactId = value),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<JournalEntryStatus>(
              initialValue: _status,
              decoration: InputDecoration(labelText: l10n.journalStatusLabel),
              items: availableStatuses
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(journalStatusLabel(l10n, value)),
                    ),
                  )
                  .toList(growable: false),
              onChanged:
                  isDecision &&
                      (_status == JournalEntryStatus.approved ||
                          _status == JournalEntryStatus.implemented)
                  ? null
                  : (value) {
                      if (value != null) setState(() => _status = value);
                    },
            ),
            if (isDecision &&
                (_status == JournalEntryStatus.approved ||
                    _status == JournalEntryStatus.implemented))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.journalApprovalManagedInDetails,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 18),
            if (_type == JournalEntryType.daily) ...[
              _textField(_weather, l10n.journalWeatherLabel),
              _textField(_people, l10n.journalPeopleLabel),
              _textField(_work, l10n.journalWorkLabel, minLines: 3),
              _textField(_deliveries, l10n.journalDeliveriesLabel, minLines: 2),
              _textField(_delays, l10n.journalDelaysLabel, minLines: 2),
              _textField(_nextSteps, l10n.journalNextStepsLabel, minLines: 2),
            ] else if (_type == JournalEntryType.decision ||
                _type == JournalEntryType.scopeChange) ...[
              _textField(_problem, l10n.journalProblemLabel, minLines: 3),
              _textField(_variants, l10n.journalVariantsLabel, minLines: 3),
              _textField(
                _selectedOption,
                l10n.journalSelectedOptionLabel,
                minLines: 2,
              ),
              _textField(_rationale, l10n.journalRationaleLabel, minLines: 3),
              if (contacts.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue:
                      contacts.any(
                        (contact) => contact.id == _decisionMakerContactId,
                      )
                      ? _decisionMakerContactId
                      : null,
                  decoration: InputDecoration(
                    labelText: l10n.journalDecisionMakerLabel,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.journalDecisionMakerNone),
                    ),
                    ...contacts.map(
                      (contact) => DropdownMenuItem<String?>(
                        value: contact.id,
                        child: Text(contact.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _decisionMakerContactId = value),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _textField(
                      _costDelta,
                      '${l10n.journalCostImpactLabel} (PLN)',
                      hintText: l10n.journalCostImpactHint,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9,+.\-\s]'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      _scheduleDelta,
                      '${l10n.journalScheduleImpactLabel} (${l10n.journalDaysSuffix})',
                      hintText: l10n.journalScheduleImpactHint,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-]')),
                      ],
                    ),
                  ),
                ],
              ),
              _blockedRecordsSection(context, scheduleEvents),
              const SizedBox(height: 12),
            ],
            _textField(
              _body,
              l10n.journalBodyLabel,
              minLines: _type == JournalEntryType.daily ? 2 : 4,
            ),
            if (_type == JournalEntryType.defect ||
                _type == JournalEntryType.decision ||
                _type == JournalEntryType.scopeChange) ...[
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickDueAt,
                icon: const Icon(Icons.schedule_outlined),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _dueAt == null
                        ? l10n.journalDueDateLabel
                        : '${l10n.journalDueDateLabel}: '
                              '${DateFormat('dd.MM.yyyy', 'pl_PL').format(_dueAt!)}',
                  ),
                ),
              ),
              if (_dueAt != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _dueAt = null),
                    child: Text(l10n.journalClearDueDate),
                  ),
                ),
            ],
            const SizedBox(height: 14),
            _attachmentsSection(context),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _saving || !journalReady ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.journalSaveAction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    int minLines = 1,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines == 1 ? 1 : 6,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(labelText: label, hintText: hintText),
      ),
    );
  }

  Widget _blockedRecordsSection(
    BuildContext context,
    List<ScheduleEvent> events,
  ) {
    final l10n = AppLocalizations.of(context);
    final eventsById = <String, ScheduleEvent>{
      for (final event in events) event.id: event,
    };
    final previousLabels = <String, String>{
      for (final relation
          in widget.entry?.input.relations ?? const <JournalRelation>[])
        if (relation.purpose == JournalRelationPurpose.blocks &&
            relation.type == JournalRelationType.schedule &&
            relation.label != null)
          relation.targetId: relation.label!,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.journalBlockedRecordsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: events.isEmpty || _saving
                  ? null
                  : () => _pickBlockedScheduleEvents(events),
              icon: const Icon(Icons.playlist_add_check_rounded),
              label: Text(l10n.journalBlockedRecordsSelect),
            ),
          ],
        ),
        if (_blockedScheduleEventIds.isEmpty)
          Text(
            l10n.journalBlockedRecordsEmpty,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _blockedScheduleEventIds
                .map(
                  (id) => InputChip(
                    label: Text(
                      eventsById[id]?.title ?? previousLabels[id] ?? id,
                    ),
                    onDeleted: _saving
                        ? null
                        : () => setState(
                            () => _blockedScheduleEventIds.remove(id),
                          ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }

  Future<void> _pickBlockedScheduleEvents(List<ScheduleEvent> events) async {
    final selected = Set<String>.of(_blockedScheduleEventIds);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) => SafeArea(
            child: FractionallySizedBox(
              heightFactor: 0.72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.journalBlockedRecordsTitle,
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
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return CheckboxListTile(
                          value: selected.contains(event.id),
                          title: Text(event.title),
                          subtitle: Text(
                            DateFormat(
                              'dd.MM.yyyy, HH:mm',
                              'pl_PL',
                            ).format(event.startsAtUtc.toLocal()),
                          ),
                          onChanged: (value) => setModalState(() {
                            if (value == true) {
                              selected.add(event.id);
                            } else {
                              selected.remove(event.id);
                            }
                          }),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(selected),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.journalBlockedRecordsDone),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null && mounted) {
      setState(() => _blockedScheduleEventIds = result);
    }
  }

  Widget _attachmentsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.journalAttachmentsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.journalAttachmentAdd,
              onPressed: _saving ? null : _addAttachment,
              icon: const Icon(Icons.attach_file_rounded),
            ),
          ],
        ),
        if (_attachmentIds.isEmpty)
          Text(l10n.journalNoContent)
        else
          ..._attachmentIds.map(
            (id) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(id, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                tooltip: l10n.journalAttachmentRemove,
                onPressed: _saving ? null : () => _removeAttachment(id),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickOccurredAt() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _occurredAt,
      helpText: AppLocalizations.of(context).journalDatePickerLabel,
    );
    if (pickedDate == null || !mounted) return;
    setState(
      () => _occurredAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _occurredAt.hour,
        _occurredAt.minute,
      ),
    );
  }

  Future<void> _pickDueAt() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _dueAt ?? DateTime.now(),
      helpText: AppLocalizations.of(context).journalDatePickerLabel,
    );
    if (pickedDate == null || !mounted) return;
    setState(() => _dueAt = pickedDate);
  }

  Future<void> _addAttachment() async {
    try {
      final picked = await ref.read(localAttachmentPickerProvider).pick();
      if (picked == null) return;
      final stager = await ref.read(localAttachmentStagerProvider.future);
      final attachment = await stager.stage(
        projectId: widget.project.id,
        pickedFile: picked,
      );
      if (!mounted) {
        await stager.discardIfUnlinked(
          projectId: widget.project.id,
          attachmentId: attachment.id,
        );
        return;
      }
      setState(() {
        _attachmentIds.add(attachment.id);
        _ownedAttachmentIds.add(attachment.id);
      });
    } on Object {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).journalAttachmentError);
      }
    }
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachmentIds.remove(id);
      if (_ownedAttachmentIds.remove(id)) return;
      _removedAttachmentIds.add(id);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      _showMessage(l10n.journalTitleRequiredError);
      return;
    }
    final isDecision =
        _type == JournalEntryType.decision ||
        _type == JournalEntryType.scopeChange;
    int? costDeltaMinorUnits;
    int? scheduleDeltaDays;
    if (isDecision) {
      try {
        costDeltaMinorUnits = parseJournalCostDelta(_costDelta.text);
        scheduleDeltaDays = parseJournalScheduleDelta(_scheduleDelta.text);
      } on Object {
        _showMessage(l10n.journalImpactInvalidError);
        return;
      }
    }
    setState(() => _saving = true);
    try {
      final scheduleEvents =
          ref.read(schedulePlanControllerProvider).value?.openEvents ??
          const <ScheduleEvent>[];
      final scheduleLabels = <String, String>{
        for (final event in scheduleEvents) event.id: event.title,
        for (final relation
            in widget.entry?.input.relations ?? const <JournalRelation>[])
          if (relation.type == JournalRelationType.schedule &&
              relation.label != null)
            relation.targetId: relation.label!,
      };
      final relations = <JournalRelation>[
        ..._preservedRelations,
        if (_stageId != null)
          JournalRelation(type: JournalRelationType.stage, targetId: _stageId!),
        if (_responsibleContactId != null)
          JournalRelation(
            type: JournalRelationType.contact,
            targetId: _responsibleContactId!,
          ),
        if (isDecision)
          ..._blockedScheduleEventIds.map(
            (id) => JournalRelation(
              type: JournalRelationType.schedule,
              targetId: id,
              purpose: JournalRelationPurpose.blocks,
              label: scheduleLabels[id],
            ),
          ),
      ];
      final input = JournalEntryInput(
        projectId: widget.project.id,
        type: _type,
        title: _title.text,
        occurredAt: _occurredAt,
        status: _status,
        body: _body.text,
        weather: _weather.text,
        people: _people.text,
        workPerformed: _work.text,
        deliveries: _deliveries.text,
        delays: _delays.text,
        nextSteps: _nextSteps.text,
        problem: isDecision ? _problem.text : null,
        variants: isDecision ? _variants.text : null,
        selectedOption: isDecision ? _selectedOption.text : null,
        rationale: isDecision ? _rationale.text : null,
        stageId: _stageId,
        responsibleContactId: _responsibleContactId,
        decisionMakerContactId: isDecision ? _decisionMakerContactId : null,
        defectSeverity: _type == JournalEntryType.defect
            ? widget.entry?.input.defectSeverity
            : null,
        roomLabel: _type == JournalEntryType.defect
            ? widget.entry?.input.roomLabel
            : null,
        requiresResolutionPhoto:
            _type == JournalEntryType.defect &&
            (widget.entry?.input.requiresResolutionPhoto ?? true),
        requiresSignedProtocol:
            _type == JournalEntryType.defect &&
            (widget.entry?.input.requiresSignedProtocol ?? false),
        dueAt: _dueAt,
        costDeltaMinorUnits: costDeltaMinorUnits,
        scheduleDeltaDays: scheduleDeltaDays,
        attachmentIds: _attachmentIds,
        relations: relations,
      );
      await ref
          .read(journalControllerProvider.notifier)
          .save(input, entryId: widget.entry?.id);
      final stager = await ref.read(localAttachmentStagerProvider.future);
      for (final id in _removedAttachmentIds) {
        await stager.discardIfUnlinked(
          projectId: widget.project.id,
          attachmentId: id,
        );
      }
      _ownedAttachmentIds.clear();
      if (!mounted) return;
      _showMessage(l10n.journalSavedMessage);
      Navigator.of(context).pop();
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        _showMessage(l10n.journalSaveError);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
