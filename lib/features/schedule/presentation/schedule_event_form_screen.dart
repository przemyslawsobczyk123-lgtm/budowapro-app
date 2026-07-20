import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/presentation/schedule_editor_gateway.dart';
import 'package:budowapro/features/schedule/presentation/schedule_event_details_provider.dart';
import 'package:budowapro/features/schedule/presentation/schedule_plan_controller.dart';
import 'package:budowapro/features/schedule/presentation/schedule_ui_text.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_ui_text.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ScheduleEventFormScreen extends ConsumerStatefulWidget {
  const ScheduleEventFormScreen({
    required this.projectId,
    this.eventId,
    super.key,
  });

  final String projectId;
  final String? eventId;

  @override
  ConsumerState<ScheduleEventFormScreen> createState() =>
      _ScheduleEventFormScreenState();
}

class _ScheduleEventFormScreenState
    extends ConsumerState<ScheduleEventFormScreen> {
  static const _leadOptions = <int>[0, 15, 30, 60, 120, 1440, 2880, 10080];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _noteController = TextEditingController();
  final _reasonController = TextEditingController();
  ScheduleEventKind _kind = ScheduleEventKind.task;
  ScheduleEventStatus _status = ScheduleEventStatus.planned;
  DateTime? _wallDate;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  String? _stageId;
  String? _timeZoneId;
  bool _isAllDay = false;
  bool _reminderEnabled = false;
  int _leadMinutes = 60;
  bool _saving = false;
  String? _initializedFor;

  @override
  void dispose() {
    _titleController.dispose();
    _assigneeController.dispose();
    _noteController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsControllerProvider);
    final project = _project(projects.value?.projects);
    final stages = project == null
        ? const AsyncData<List<ProjectStage>>(<ProjectStage>[])
        : ref.watch(projectStagesProvider(project));
    final eventId = widget.eventId;
    if (eventId != null) {
      final details = ref.watch(
        scheduleEventDetailsProvider((
          projectId: widget.projectId,
          eventId: eventId,
        )),
      );
      return details.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(l10n.scheduleEditTitle)),
          body: AppLoadingState(label: l10n.scheduleLoading),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(title: Text(l10n.scheduleEditTitle)),
          body: AppErrorState(
            title: l10n.scheduleLoadError,
            retryLabel: l10n.retryAction,
            onRetry: () => ref.invalidate(
              scheduleEventDetailsProvider((
                projectId: widget.projectId,
                eventId: eventId,
              )),
            ),
          ),
        ),
        data: (details) {
          final event = details.event;
          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.scheduleEditTitle)),
              body: AppEmptyState(
                icon: Icons.event_busy_outlined,
                title: l10n.scheduleSourceMissingTitle,
                message: l10n.scheduleSourceMissingMessage,
              ),
            );
          }
          _initialize(event);
          return _formScaffold(l10n, stages.value ?? const <ProjectStage>[]);
        },
      );
    }
    _initialize(null);
    return _formScaffold(l10n, stages.value ?? const <ProjectStage>[]);
  }

  Scaffold _formScaffold(AppLocalizations l10n, List<ProjectStage> stages) {
    final dateFormat = DateFormat('d MMMM yyyy', 'pl');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eventId == null
              ? l10n.scheduleNewTitle
              : l10n.scheduleEditTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              TextFormField(
                key: const ValueKey('scheduleTitleField'),
                controller: _titleController,
                textInputAction: TextInputAction.next,
                maxLength: 160,
                decoration: InputDecoration(
                  labelText: l10n.scheduleTitleLabel,
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.scheduleTitleRequiredError
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ScheduleEventKind>(
                initialValue: _kind,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.scheduleKindLabel,
                  prefixIcon: Icon(scheduleKindIcon(_kind)),
                ),
                items: ScheduleEventKind.values
                    .map(
                      (kind) => DropdownMenuItem(
                        value: kind,
                        child: Text(scheduleKindLabel(l10n, kind)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _kind = value ?? _kind),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ScheduleEventStatus>(
                initialValue: _status,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.scheduleStatusLabel,
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: ScheduleEventStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(scheduleStatusLabel(l10n, status)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.scheduleAllDayLabel),
                secondary: const Icon(Icons.today_outlined),
                value: _isAllDay,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _isAllDay = value),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        _wallDate == null
                            ? l10n.scheduleDateLabel
                            : dateFormat.format(_wallDate!),
                      ),
                    ),
                  ),
                  if (!_isAllDay) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _pickTime,
                        icon: const Icon(Icons.schedule_outlined),
                        label: Text(_time.format(context)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _stageId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.scheduleStageLabel,
                  prefixIcon: const Icon(Icons.account_tree_outlined),
                ),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.scheduleNoStage),
                  ),
                  ...stages.map(
                    (stage) => DropdownMenuItem<String?>(
                      value: stage.id,
                      child: Text(stageName(l10n, stage)),
                    ),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _stageId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assigneeController,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: l10n.scheduleAssigneeLabel,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLength: 2000,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.scheduleNoteLabel,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
              if (widget.eventId != null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: l10n.scheduleRescheduleReasonLabel,
                    prefixIcon: const Icon(Icons.history_rounded),
                  ),
                ),
              ],
              const Divider(height: 32),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.scheduleReminderToggle),
                secondary: const Icon(Icons.notifications_active_outlined),
                value: _reminderEnabled,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _reminderEnabled = value),
              ),
              if (_reminderEnabled)
                DropdownButtonFormField<int>(
                  initialValue: _leadMinutes,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.scheduleReminderLeadLabel,
                    prefixIcon: const Icon(Icons.timer_outlined),
                  ),
                  items: _leadValues
                      .map(
                        (minutes) => DropdownMenuItem(
                          value: minutes,
                          child: Text(scheduleLeadLabel(l10n, minutes)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _saving
                      ? null
                      : (value) => setState(
                          () => _leadMinutes = value ?? _leadMinutes,
                        ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            key: const ValueKey('scheduleSaveButton'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(l10n.saveAction),
          ),
        ),
      ),
    );
  }

  Project? _project(List<Project>? projects) {
    if (projects == null) return null;
    for (final project in projects) {
      if (project.id == widget.projectId) return project;
    }
    return null;
  }

  void _initialize(ScheduleEvent? event) {
    final key = event?.id ?? 'new';
    if (_initializedFor == key) return;
    _initializedFor = key;
    final notifications = ref.read(scheduleNotificationGatewayProvider);
    if (event == null) {
      _timeZoneId = null;
      final now = DateTime.now().add(const Duration(hours: 1));
      _wallDate = DateTime(now.year, now.month, now.day);
      _time = TimeOfDay(hour: now.hour, minute: 0);
      notifications
          .currentTimeZoneId()
          .then((identifier) {
            if (mounted && _initializedFor == 'new') {
              setState(() => _timeZoneId = identifier);
            }
          })
          .onError((Object _, StackTrace _) {
            if (mounted && _initializedFor == 'new') {
              setState(() => _timeZoneId = 'Etc/UTC');
            }
          });
      ref
          .read(scheduleRepositoryProvider.future)
          .then((repository) => repository.getReminderPreferences())
          .then((preferences) {
            if (mounted && _initializedFor == 'new') {
              setState(() => _leadMinutes = preferences.defaultLeadMinutes);
            }
          })
          .onError((Object _, StackTrace _) {});
      return;
    }
    final local = notifications.toTimeZone(event.startsAtUtc, event.timeZoneId);
    _titleController.text = event.title;
    _assigneeController.text = event.assignee ?? '';
    _noteController.text = event.note ?? '';
    _kind = event.kind;
    _status = event.status;
    _wallDate = DateTime(local.year, local.month, local.day);
    _time = TimeOfDay(hour: local.hour, minute: local.minute);
    _stageId = event.stageId;
    _timeZoneId = event.timeZoneId;
    _isAllDay = event.isAllDay;
    _reminderEnabled = event.reminderEnabled;
    _leadMinutes = event.reminderLeadMinutes;
  }

  List<int> get _leadValues {
    final values = <int>{..._leadOptions, _leadMinutes}.toList()..sort();
    return values;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _wallDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _wallDate = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null) setState(() => _time = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _wallDate == null) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      final notifications = ref.read(scheduleNotificationGatewayProvider);
      final timeZoneId = _timeZoneId ?? await notifications.currentTimeZoneId();
      final wallTime = DateTime(
        _wallDate!.year,
        _wallDate!.month,
        _wallDate!.day,
        _isAllDay ? 0 : _time.hour,
        _isAllDay ? 0 : _time.minute,
      );
      final repository = await ref.read(scheduleRepositoryProvider.future);
      final preferences = await repository.getReminderPreferences();
      final event = await (await ref.read(scheduleEditorGatewayProvider.future))
          .save(
            projectId: widget.projectId,
            eventId: widget.eventId,
            input: ScheduleEventInput(
              title: _titleController.text,
              kind: _kind,
              status: _status,
              startsAt: notifications.fromWallTime(wallTime, timeZoneId),
              timeZoneId: timeZoneId,
              isAllDay: _isAllDay,
              stageId: _stageId,
              assignee: _assigneeController.text,
              note: _noteController.text,
              reminderEnabled: _reminderEnabled,
              reminderLeadMinutes: _leadMinutes,
            ),
            preferences: preferences,
            rescheduleReason: _reasonController.text,
            notificationBody: l10n.scheduleNotificationBody,
          );
      ref.invalidate(schedulePlanControllerProvider);
      ref.invalidate(
        scheduleEventDetailsProvider((
          projectId: widget.projectId,
          eventId: event.id,
        )),
      );
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.scheduleSaveError)));
        setState(() => _saving = false);
      }
    }
  }
}
