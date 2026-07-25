import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<String?> showStageNameDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        _StageNameDialog(title: title, initialValue: initialValue),
  );
}

class _StageNameDialog extends StatefulWidget {
  const _StageNameDialog({required this.title, required this.initialValue});

  final String title;
  final String initialValue;

  @override
  State<_StageNameDialog> createState() => _StageNameDialogState();
}

class _StageNameDialogState extends State<_StageNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.stageNameLabel),
          validator: (value) => value == null || value.trim().isEmpty
              ? l10n.stageNameRequiredError
              : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.saveAction)),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }
}

Future<List<String>?> showStageReorderSheet(
  BuildContext context, {
  required List<ProjectStage> stages,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _StageReorderSheet(stages: stages),
  );
}

class _StageReorderSheet extends StatefulWidget {
  const _StageReorderSheet({required this.stages});

  final List<ProjectStage> stages;

  @override
  State<_StageReorderSheet> createState() => _StageReorderSheetState();
}

class _StageReorderSheetState extends State<_StageReorderSheet> {
  late final List<ProjectStage> _stages = List<ProjectStage>.of(widget.stages);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.stageReorderTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cancelAction,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemCount: _stages.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final stage = _stages.removeAt(oldIndex);
                    _stages.insert(newIndex, stage);
                  });
                },
                itemBuilder: (context, index) {
                  final stage = _stages[index];
                  return ListTile(
                    key: ValueKey<String>(stage.id),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(stageName(l10n, stage)),
                    subtitle: Text(stageStatusLabel(l10n, stage.status)),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.drag_handle_rounded),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  _stages.map((stage) => stage.id).toList(growable: false),
                ),
                child: Text(l10n.saveAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<StageDetailsInput?> showStageEditorSheet(
  BuildContext context, {
  required Project project,
  required ProjectStage stage,
}) {
  return showModalBottomSheet<StageDetailsInput>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _StageEditorSheet(project: project, stage: stage),
  );
}

class _StageEditorSheet extends StatefulWidget {
  const _StageEditorSheet({required this.project, required this.stage});

  final Project project;
  final ProjectStage stage;

  @override
  State<_StageEditorSheet> createState() => _StageEditorSheetState();
}

class _StageEditorSheetState extends State<_StageEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _budgetController;
  late StageStatus _status = widget.stage.status;
  late DateTime? _start = widget.stage.plannedStart;
  late DateTime? _end = widget.stage.plannedEnd;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: _formatMinorUnits(widget.stage.plannedBudgetMinorUnits),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _EditorSheet(
      title: l10n.stageEditTitle,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<StageStatus>(
              initialValue: _status,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.stageStatusLabel),
              items: StageStatus.values
                  .map(
                    (status) => DropdownMenuItem<StageStatus>(
                      value: status,
                      child: Text(stageStatusLabel(l10n, status)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 16),
            _DateField(
              label: l10n.stageStartDateLabel,
              value: _start,
              dateFormat: widget.project.dateFormat,
              onChanged: (value) => setState(() => _start = value),
            ),
            const SizedBox(height: 12),
            _DateField(
              label: l10n.stageEndDateLabel,
              value: _end,
              dateFormat: widget.project.dateFormat,
              firstDate: _start,
              errorText:
                  _start != null && _end != null && _end!.isBefore(_start!)
                  ? l10n.projectDatesInvalidError
                  : null,
              onChanged: (value) => setState(() => _end = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.stageBudgetLabel,
                suffixText: widget.project.currencyCode,
              ),
              validator: (value) {
                try {
                  _parseMinorUnits(value ?? '');
                  return null;
                } on FormatException {
                  return l10n.stageBudgetInvalidError;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_start != null && _end != null && _end!.isBefore(_start!)) {
      return;
    }
    Navigator.pop(
      context,
      StageDetailsInput(
        status: _status,
        plannedStart: _start,
        plannedEnd: _end,
        plannedBudgetMinorUnits: _parseMinorUnits(_budgetController.text),
      ),
    );
  }
}

final class NewChecklistItemInput {
  const NewChecklistItemInput({required this.title, required this.details});

  final String title;
  final ChecklistItemDetailsInput details;
}

Future<NewChecklistItemInput?> showAddChecklistDialog(BuildContext context) {
  return showDialog<NewChecklistItemInput>(
    context: context,
    builder: (context) => const _AddChecklistDialog(),
  );
}

class _AddChecklistDialog extends StatefulWidget {
  const _AddChecklistDialog();

  @override
  State<_AddChecklistDialog> createState() => _AddChecklistDialogState();
}

class _AddChecklistDialogState extends State<_AddChecklistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _noteController = TextEditingController();
  final _riskController = TextEditingController();
  var _importance = ChecklistImportance.normal;
  var _evidence = EvidenceRequirement.none;

  @override
  void dispose() {
    _titleController.dispose();
    _assigneeController.dispose();
    _noteController.dispose();
    _riskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.checklistAddTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: 160,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.checklistTitleLabel,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.checklistTitleRequiredError
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ChecklistImportance>(
                initialValue: _importance,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.checklistImportanceLabel,
                ),
                items: ChecklistImportance.values
                    .map(
                      (value) => DropdownMenuItem<ChecklistImportance>(
                        value: value,
                        child: Text(checklistImportanceLabel(l10n, value)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _importance = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assigneeController,
                maxLength: 120,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.checklistAssigneeLabel,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLength: 2000,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.checklistNoteLabel,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _riskController,
                maxLength: 500,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.checklistRiskLabel,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EvidenceRequirement>(
                initialValue: _evidence,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.checklistEvidenceLabel,
                ),
                items: EvidenceRequirement.values
                    .map(
                      (value) => DropdownMenuItem<EvidenceRequirement>(
                        value: value,
                        child: Text(evidenceRequirementLabel(l10n, value)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _evidence = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.saveAction)),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      NewChecklistItemInput(
        title: _titleController.text.trim(),
        details: ChecklistItemDetailsInput(
          status: ChecklistStatus.todo,
          importance: _importance,
          evidenceRequirement: _evidence,
          assignee: _assigneeController.text,
          note: _noteController.text,
          riskIfSkipped: _riskController.text,
        ),
      ),
    );
  }
}

Future<ChecklistItemDetailsInput?> showChecklistEditorSheet(
  BuildContext context, {
  required Project project,
  required ChecklistItem item,
}) {
  return showModalBottomSheet<ChecklistItemDetailsInput>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ChecklistEditorSheet(project: project, item: item),
  );
}

class _ChecklistEditorSheet extends StatefulWidget {
  const _ChecklistEditorSheet({required this.project, required this.item});

  final Project project;
  final ChecklistItem item;

  @override
  State<_ChecklistEditorSheet> createState() => _ChecklistEditorSheetState();
}

class _ChecklistEditorSheetState extends State<_ChecklistEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _assigneeController;
  late final TextEditingController _noteController;
  late final TextEditingController _riskController;
  late final TextEditingController _reasonController;
  late ChecklistStatus _status = widget.item.status;
  late ChecklistImportance _importance = widget.item.importance;
  late EvidenceRequirement _evidence = widget.item.evidenceRequirement;
  late DateTime? _dueDate = widget.item.dueDate;

  @override
  void initState() {
    super.initState();
    _assigneeController = TextEditingController(text: widget.item.assignee);
    _noteController = TextEditingController(text: widget.item.note);
    _riskController = TextEditingController(text: widget.item.riskIfSkipped);
    _reasonController = TextEditingController(text: widget.item.statusReason);
  }

  @override
  void dispose() {
    _assigneeController.dispose();
    _noteController.dispose();
    _riskController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _EditorSheet(
      title: l10n.checklistEditTitle,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                checklistTitle(l10n, widget.item),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChecklistStatus>(
              initialValue: _status,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.checklistStatusLabel),
              items: ChecklistStatus.values
                  .map(
                    (value) => DropdownMenuItem<ChecklistStatus>(
                      value: value,
                      child: Text(checklistStatusLabel(l10n, value)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ChecklistImportance>(
              initialValue: _importance,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.checklistImportanceLabel,
              ),
              items: ChecklistImportance.values
                  .map(
                    (value) => DropdownMenuItem<ChecklistImportance>(
                      value: value,
                      child: Text(checklistImportanceLabel(l10n, value)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _importance = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EvidenceRequirement>(
              initialValue: _evidence,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.checklistEvidenceLabel,
              ),
              items: EvidenceRequirement.values
                  .map(
                    (value) => DropdownMenuItem<EvidenceRequirement>(
                      value: value,
                      child: Text(evidenceRequirementLabel(l10n, value)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: widget.item.templateKey == null
                  ? (value) => setState(() => _evidence = value!)
                  : null,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: l10n.checklistDueDateLabel,
              value: _dueDate,
              dateFormat: widget.project.dateFormat,
              onChanged: (value) => setState(() => _dueDate = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _assigneeController,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: l10n.checklistAssigneeLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLength: 2000,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.checklistNoteLabel),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _riskController,
              maxLength: 500,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.checklistRiskLabel),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              maxLength: 500,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.checklistReasonLabel),
              validator: (value) {
                if (_status == ChecklistStatus.skipped &&
                    (value == null || value.trim().isEmpty)) {
                  return l10n.checklistReasonRequiredError;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.item.hasEvidenceWaiver
                    ? l10n.checklistEvidenceWaived
                    : l10n.checklistEvidenceCount(
                        widget.item.evidenceIds.length,
                      ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ChecklistItemDetailsInput(
        status: _status,
        importance: _importance,
        evidenceRequirement: _evidence,
        dueDate: _dueDate,
        assignee: _assigneeController.text,
        note: _noteController.text,
        riskIfSkipped: _riskController.text,
        statusReason: _reasonController.text,
        evidenceWaiverComment: widget.item.evidenceWaiverComment,
      ),
    );
  }
}

Future<String?> showEvidenceWaiverDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _EvidenceWaiverDialog(),
  );
}

class _EvidenceWaiverDialog extends StatefulWidget {
  const _EvidenceWaiverDialog();

  @override
  State<_EvidenceWaiverDialog> createState() => _EvidenceWaiverDialogState();
}

class _EvidenceWaiverDialogState extends State<_EvidenceWaiverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.checklistWaiverTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 500,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(labelText: l10n.checklistWaiverLabel),
          validator: (value) => value == null || value.trim().isEmpty
              ? l10n.checklistWaiverRequiredError
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: Text(l10n.saveAction),
        ),
      ],
    );
  }
}

class _EditorSheet extends StatelessWidget {
  const _EditorSheet({
    required this.title,
    required this.onSave,
    required this.child,
  });

  final String title;
  final VoidCallback onSave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final availableHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: SizedBox(
          height: availableHeight * 0.9,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.cancelAction,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: child,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSave,
                    child: Text(l10n.saveAction),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.dateFormat,
    required this.onChanged,
    this.firstDate,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ProjectDateFormat dateFormat;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '' : formatProjectDate(value!, dateFormat);
    return TextFormField(
      key: ValueKey<String?>('$label-${value?.toIso8601String()}'),
      initialValue: text,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: IconButton(
          tooltip: label,
          onPressed: () => _pick(context),
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
      onTap: () => _pick(context),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final earliest = firstDate ?? DateTime(now.year - 5);
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? (earliest.isAfter(now) ? earliest : now),
      firstDate: earliest,
      lastDate: DateTime(now.year + 20, 12, 31),
    );
    if (selected != null) onChanged(selected);
  }
}

int? _parseMinorUnits(String text) {
  final normalized = text.trim().replaceAll(RegExp(r'[\s\u00A0\u202F]'), '');
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) {
    throw const FormatException();
  }
  final parts = normalized.split(RegExp(r'[,.]'));
  final fraction = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
  return int.parse(parts.first) * 100 + fraction;
}

String _formatMinorUnits(int? minorUnits) {
  if (minorUnits == null) return '';
  return '${minorUnits ~/ 100},${(minorUnits % 100).toString().padLeft(2, '0')}';
}
