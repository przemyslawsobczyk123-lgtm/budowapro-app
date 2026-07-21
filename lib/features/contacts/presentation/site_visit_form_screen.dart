import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/contacts/presentation/contact_details_provider.dart';
import 'package:budowapro/features/contacts/presentation/contact_ui_text.dart';
import 'package:budowapro/features/contacts/presentation/site_visit_editor_gateway.dart';
import 'package:budowapro/features/dashboard/presentation/dashboard_controller.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
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

class SiteVisitFormScreen extends ConsumerStatefulWidget {
  const SiteVisitFormScreen({
    required this.projectId,
    required this.contactId,
    this.visitId,
    super.key,
  });

  final String projectId;
  final String contactId;
  final String? visitId;

  @override
  ConsumerState<SiteVisitFormScreen> createState() =>
      _SiteVisitFormScreenState();
}

class _SiteVisitFormScreenState extends ConsumerState<SiteVisitFormScreen> {
  static const _leadOptions = <int>[0, 15, 30, 60, 120, 1440, 2880, 10080];

  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _expectedResultController = TextEditingController();
  final _resultController = TextEditingController();
  final _agreementsController = TextEditingController();
  final _reasonController = TextEditingController();
  SiteVisitStatus _status = SiteVisitStatus.planned;
  DateTime? _wallDate;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  String? _stageId;
  String? _timeZoneId;
  bool _isAllDay = false;
  bool _reminderEnabled = true;
  int _leadMinutes = 60;
  bool _saving = false;
  String? _initializedFor;

  @override
  void dispose() {
    _purposeController.dispose();
    _expectedResultController.dispose();
    _resultController.dispose();
    _agreementsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final project = _project(
      ref.watch(projectsControllerProvider).value?.projects,
    );
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.siteVisitNewTitle)),
        body: AppEmptyState(
          icon: Icons.folder_off_outlined,
          title: l10n.contactsNoProjectTitle,
          message: l10n.contactsNoProjectMessage,
        ),
      );
    }
    final stages = ref.watch(projectStagesProvider(project));
    final visitId = widget.visitId;
    if (visitId == null) {
      _initialize(null);
      return _scaffold(l10n, stages.value ?? const <ProjectStage>[]);
    }
    final visit = ref.watch(
      siteVisitByIdProvider((projectId: widget.projectId, visitId: visitId)),
    );
    return visit.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.siteVisitEditTitle)),
        body: AppLoadingState(label: l10n.projectsLoading),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.siteVisitEditTitle)),
        body: AppErrorState(
          title: l10n.siteVisitLoadError,
          retryLabel: l10n.retryAction,
          onRetry: () => ref.invalidate(
            siteVisitByIdProvider((
              projectId: widget.projectId,
              visitId: visitId,
            )),
          ),
        ),
      ),
      data: (visit) {
        if (visit == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.siteVisitEditTitle)),
            body: AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: l10n.scheduleSourceMissingTitle,
              message: l10n.scheduleSourceMissingMessage,
            ),
          );
        }
        _initialize(visit);
        return _scaffold(l10n, stages.value ?? const <ProjectStage>[]);
      },
    );
  }

  Scaffold _scaffold(AppLocalizations l10n, List<ProjectStage> stages) {
    final dateFormat = DateFormat('d MMMM yyyy', 'pl');
    final contact = ref
        .watch(
          contactByIdProvider((
            projectId: widget.projectId,
            contactId: widget.contactId,
          )),
        )
        .value;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.visitId == null
              ? l10n.siteVisitNewTitle
              : l10n.siteVisitEditTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              if (contact != null) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  title: Text(contact.displayName),
                  subtitle: Text(contactRoleLabel(l10n, contact.roles.first)),
                ),
                const Divider(height: 24),
              ],
              TextFormField(
                key: const ValueKey('siteVisitPurposeField'),
                controller: _purposeController,
                maxLength: 160,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.siteVisitPurposeLabel,
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.siteVisitPurposeRequiredError
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expectedResultController,
                maxLength: 2000,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.siteVisitExpectedResultLabel,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.fact_check_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.siteVisitExpectedResultRequiredError
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SiteVisitStatus>(
                initialValue: _status,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.siteVisitStatusLabel,
                  prefixIcon: const Icon(Icons.outlined_flag_rounded),
                ),
                items: SiteVisitStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(siteVisitStatusLabel(l10n, status)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.siteVisitAllDayLabel),
                secondary: const Icon(Icons.today_outlined),
                value: _isAllDay,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _isAllDay = value),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        _wallDate == null
                            ? l10n.siteVisitDateLabel
                            : dateFormat.format(_wallDate!),
                        overflow: TextOverflow.ellipsis,
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
                  labelText: l10n.siteVisitStageLabel,
                  prefixIcon: const Icon(Icons.account_tree_outlined),
                ),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.siteVisitNoStage),
                  ),
                  ...stages.map(
                    (stage) => DropdownMenuItem(
                      value: stage.id,
                      child: Text(stageName(l10n, stage)),
                    ),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _stageId = value),
              ),
              const Divider(height: 32),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.siteVisitReminderToggle),
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
                    labelText: l10n.siteVisitReminderLeadLabel,
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
              if (_status != SiteVisitStatus.planned) ...[
                const Divider(height: 32),
                TextFormField(
                  key: const ValueKey('siteVisitResultField'),
                  controller: _resultController,
                  maxLength: 4000,
                  minLines: 3,
                  maxLines: 7,
                  decoration: InputDecoration(
                    labelText: l10n.siteVisitResultLabel,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.assignment_turned_in_outlined),
                  ),
                  validator: (value) {
                    if (_status != SiteVisitStatus.completed) return null;
                    return value == null || value.trim().isEmpty
                        ? l10n.siteVisitResultRequiredError
                        : null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _agreementsController,
                  maxLength: 4000,
                  minLines: 2,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.siteVisitAgreementsLabel,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.handshake_outlined),
                  ),
                ),
              ],
              if (widget.visitId != null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: l10n.siteVisitRescheduleReasonLabel,
                    prefixIcon: const Icon(Icons.history_rounded),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            key: const ValueKey('siteVisitSaveButton'),
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

  void _initialize(SiteVisit? visit) {
    final key = visit?.id ?? 'new';
    if (_initializedFor == key) return;
    _initializedFor = key;
    final notifications = ref.read(scheduleNotificationGatewayProvider);
    if (visit == null) {
      final nextHour = DateTime.now().add(const Duration(hours: 1));
      _wallDate = DateTime(nextHour.year, nextHour.month, nextHour.day);
      _time = TimeOfDay(hour: nextHour.hour, minute: 0);
      notifications
          .currentTimeZoneId()
          .then((value) {
            if (mounted && _initializedFor == 'new') {
              setState(() => _timeZoneId = value);
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
    final local = notifications.toTimeZone(visit.startsAtUtc, visit.timeZoneId);
    _purposeController.text = visit.purpose;
    _expectedResultController.text = visit.expectedResult;
    _resultController.text = visit.result ?? '';
    _agreementsController.text = visit.agreements ?? '';
    _status = visit.status;
    _wallDate = DateTime(local.year, local.month, local.day);
    _time = TimeOfDay(hour: local.hour, minute: local.minute);
    _stageId = visit.stageId;
    _timeZoneId = visit.timeZoneId;
    _isAllDay = visit.isAllDay;
    _reminderEnabled = visit.reminderEnabled;
    _leadMinutes = visit.reminderLeadMinutes;
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
      final visit =
          await (await ref.read(siteVisitEditorGatewayProvider.future)).save(
            projectId: widget.projectId,
            visitId: widget.visitId,
            draft: SiteVisitDraft(
              contactId: widget.contactId,
              purpose: _purposeController.text,
              expectedResult: _expectedResultController.text,
              status: _status,
              startsAt: notifications.fromWallTime(wallTime, timeZoneId),
              timeZoneId: timeZoneId,
              isAllDay: _isAllDay,
              stageId: _stageId,
              reminderEnabled: _reminderEnabled,
              reminderLeadMinutes: _leadMinutes,
              result: _resultController.text,
              agreements: _agreementsController.text,
            ),
            preferences: preferences,
            notificationBody: l10n.siteVisitNotificationBody,
            rescheduleReason: _reasonController.text,
          );
      ref.invalidate(schedulePlanControllerProvider);
      ref.invalidate(dashboardControllerProvider);
      ref.invalidate(
        contactDetailsProvider((
          projectId: widget.projectId,
          contactId: widget.contactId,
        )),
      );
      ref.invalidate(
        siteVisitByIdProvider((projectId: widget.projectId, visitId: visit.id)),
      );
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.siteVisitSaveError)));
      setState(() => _saving = false);
    }
  }
}
