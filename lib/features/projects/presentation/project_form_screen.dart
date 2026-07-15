import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({this.projectId, super.key});

  final String? projectId;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _budgetController = TextEditingController();

  var _type = ProjectType.houseBuild;
  var _currencyCode = 'PLN';
  var _dateFormat = ProjectDateFormat.dayMonthYear;
  var _currentStage = ProjectStageKey.formalities;
  DateTime? _plannedStart;
  DateTime? _plannedEnd;
  bool _initialized = false;
  bool _isSubmitting = false;
  bool _isDirty = false;
  String? _submissionError;

  ProjectTemplate get _template => switch (_type) {
    ProjectType.houseBuild => ProjectTemplate.houseConstruction,
    ProjectType.houseRenovation ||
    ProjectType.apartmentRenovation => ProjectTemplate.renovation,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsControllerProvider);
    final localizations = AppLocalizations.of(context);

    if (_initialized && (_isSubmitting || _submissionError != null)) {
      return _buildFormScaffold(localizations);
    }

    return projects.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(_title(localizations))),
        body: AppLoadingState(label: localizations.projectsLoading),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(_title(localizations))),
        body: AppErrorState(
          title: localizations.projectsLoadError,
          retryLabel: localizations.retryAction,
          onRetry: () {
            ref.read(projectsControllerProvider.notifier).refresh();
          },
        ),
      ),
      data: (state) {
        final project = widget.projectId == null
            ? null
            : state.projects
                  .where((item) => item.id == widget.projectId)
                  .firstOrNull;
        if (widget.projectId != null && project == null) {
          return Scaffold(
            appBar: AppBar(title: Text(_title(localizations))),
            body: AppErrorState(
              title: localizations.projectNotFoundError,
              retryLabel: localizations.retryAction,
              onRetry: () {
                ref.read(projectsControllerProvider.notifier).refresh();
              },
            ),
          );
        }

        _initialize(project);
        return _buildFormScaffold(localizations);
      },
    );
  }

  Scaffold _buildFormScaffold(AppLocalizations localizations) {
    return Scaffold(
      appBar: AppBar(title: Text(_title(localizations))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          canPop: !_isDirty,
          onChanged: _markDirty,
          onPopInvokedWithResult: _handlePopInvoked,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isSubmitting) const LinearProgressIndicator(),
                if (_submissionError != null) ...[
                  _InlineError(message: _submissionError!),
                  const SizedBox(height: 16),
                ],
                _SectionTitle(text: localizations.projectBasicsSection),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('projectNameField'),
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizations.projectNameLabel,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    final normalized = value?.trim() ?? '';
                    if (normalized.isEmpty) {
                      return localizations.projectNameRequiredError;
                    }
                    if (normalized.length > 80) {
                      return localizations.projectNameTooLongError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('projectLocationField'),
                  controller: _locationController,
                  enabled: !_isSubmitting,
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizations.projectLocationLabel,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if ((value?.trim().length ?? 0) > 120) {
                      return localizations.projectLocationTooLongError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                _ProjectTypeField(
                  value: _type,
                  enabled: !_isSubmitting,
                  localizations: localizations,
                  onChanged: _changeType,
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: localizations.projectTemplateLabel,
                    prefixIcon: const Icon(Icons.account_tree_outlined),
                  ),
                  child: Text(_templateLabel(localizations, _template)),
                ),
                const SizedBox(height: 20),
                _SectionTitle(text: localizations.projectScheduleSection),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fields = [
                      DropdownButtonFormField<String>(
                        key: ValueKey('projectCurrency-$_currencyCode'),
                        initialValue: _currencyCode,
                        decoration: InputDecoration(
                          labelText: localizations.projectCurrencyLabel,
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                        items: const ['PLN', 'EUR', 'USD']
                            .map(
                              (code) => DropdownMenuItem<String>(
                                value: code,
                                child: Text(code),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _currencyCode = value);
                                }
                              },
                      ),
                      TextFormField(
                        key: const ValueKey('projectAreaField'),
                        controller: _areaController,
                        enabled: !_isSubmitting,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: localizations.projectAreaLabel,
                          prefixIcon: const Icon(Icons.square_foot_outlined),
                        ),
                        validator: (value) =>
                            _validateArea(value, localizations),
                      ),
                    ];
                    return _ResponsivePair(
                      isWide: constraints.maxWidth >= 520,
                      children: fields,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('projectBudgetField'),
                  controller: _budgetController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: localizations.projectBudgetLabel,
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    suffixText: _currencyCode,
                  ),
                  validator: (value) => _validateBudget(value, localizations),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) => _ResponsivePair(
                    isWide: constraints.maxWidth >= 520,
                    children: [
                      _DateField(
                        key: const ValueKey('projectStartField'),
                        label: localizations.projectPlannedStartLabel,
                        value: _dateText(_plannedStart),
                        clearTooltip: localizations.clearAction,
                        enabled: !_isSubmitting,
                        onTap: () => _pickDate(isStart: true),
                        onClear: _plannedStart == null
                            ? null
                            : () {
                                setState(() {
                                  _plannedStart = null;
                                  _isDirty = true;
                                });
                              },
                      ),
                      _DateField(
                        key: const ValueKey('projectEndField'),
                        label: localizations.projectPlannedEndLabel,
                        value: _dateText(_plannedEnd),
                        clearTooltip: localizations.clearAction,
                        enabled: !_isSubmitting,
                        onTap: () => _pickDate(isStart: false),
                        onClear: _plannedEnd == null
                            ? null
                            : () {
                                setState(() {
                                  _plannedEnd = null;
                                  _isDirty = true;
                                });
                              },
                      ),
                    ],
                  ),
                ),
                if (_plannedStart != null &&
                    _plannedEnd != null &&
                    _plannedEnd!.isBefore(_plannedStart!)) ...[
                  const SizedBox(height: 8),
                  Text(
                    localizations.projectDatesInvalidError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  localizations.projectDateFormatLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<ProjectDateFormat>(
                  segments: [
                    ButtonSegment(
                      value: ProjectDateFormat.dayMonthYear,
                      label: Text(localizations.projectDateFormatDmy),
                    ),
                    ButtonSegment(
                      value: ProjectDateFormat.yearMonthDay,
                      label: Text(localizations.projectDateFormatYmd),
                    ),
                  ],
                  selected: {_dateFormat},
                  showSelectedIcon: false,
                  onSelectionChanged: _isSubmitting
                      ? null
                      : (selection) {
                          setState(() {
                            _dateFormat = selection.single;
                            _isDirty = true;
                          });
                        },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProjectStageKey>(
                  key: ValueKey('projectStage-${_template.name}'),
                  initialValue: _currentStage,
                  decoration: InputDecoration(
                    labelText: localizations.projectCurrentStageLabel,
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                  items: _template.definition.stages
                      .map(
                        (stage) => DropdownMenuItem<ProjectStageKey>(
                          value: stage,
                          child: Text(_stageLabel(localizations, stage)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _currentStage = value);
                          }
                        },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const ValueKey('projectFormSave'),
                  onPressed: _isSubmitting ? null : _submit,
                  icon: Icon(
                    widget.projectId == null
                        ? Icons.add_rounded
                        : Icons.save_outlined,
                  ),
                  label: Text(
                    widget.projectId == null
                        ? localizations.projectCreateAction
                        : localizations.projectSaveChangesAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _initialize(Project? project) {
    if (_initialized) {
      return;
    }
    if (project != null) {
      _nameController.text = project.name;
      _locationController.text = project.locationLabel ?? '';
      _areaController.text = project.areaSquareMeters?.toString() ?? '';
      _budgetController.text = _formatMinorUnitsForInput(
        project.plannedBudgetMinorUnits,
      );
      _type = project.type;
      _currencyCode = project.currencyCode;
      _plannedStart = project.plannedStart;
      _plannedEnd = project.plannedEnd;
      _dateFormat = project.dateFormat;
      _currentStage = project.currentStage;
    }
    _initialized = true;
  }

  void _changeType(ProjectType type) {
    setState(() {
      _type = type;
      _currentStage = _template.definition.initialStage;
      _isDirty = true;
      _submissionError = null;
    });
  }

  void _markDirty() {
    if (!_initialized || _isDirty || _isSubmitting) {
      return;
    }
    setState(() => _isDirty = true);
  }

  Future<void> _handlePopInvoked(bool didPop, Object? result) async {
    if (didPop || !_isDirty || _isSubmitting) {
      return;
    }
    final localizations = AppLocalizations.of(context);
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.unsavedChangesTitle),
        content: Text(localizations.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.discardChangesAction),
          ),
        ],
      ),
    );
    if (shouldDiscard != true || !mounted) {
      return;
    }
    setState(() => _isDirty = false);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _plannedStart : _plannedEnd;
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: current?.toLocal() ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _plannedStart = selected;
      } else {
        _plannedEnd = selected;
      }
      _isDirty = true;
      _submissionError = null;
    });
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_plannedStart != null &&
        _plannedEnd != null &&
        _plannedEnd!.isBefore(_plannedStart!)) {
      setState(() {
        _submissionError = localizations.projectDatesInvalidError;
      });
      return;
    }

    final draft = ProjectDraft(
      name: _nameController.text,
      locationLabel: _locationController.text,
      type: _type,
      template: _template,
      currencyCode: _currencyCode,
      areaSquareMeters: _parseOptionalPositiveInt(_areaController.text),
      plannedBudgetMinorUnits: _parseMinorUnits(_budgetController.text),
      plannedStart: _plannedStart,
      plannedEnd: _plannedEnd,
      dateFormat: _dateFormat,
      currentStage: _currentStage,
    );

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });
    try {
      final controller = ref.read(projectsControllerProvider.notifier);
      final projectId = widget.projectId;
      if (projectId == null) {
        await controller.create(draft);
      } else {
        await controller.updateProject(projectId, draft);
      }
      if (!mounted) {
        return;
      }
      final navigator = Navigator.of(context);
      final shouldPop = navigator.canPop();
      setState(() {
        _isSubmitting = false;
        _isDirty = false;
      });
      if (shouldPop) {
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submissionError = localizations.projectSaveError;
        });
      }
    }
  }

  String _title(AppLocalizations localizations) => widget.projectId == null
      ? localizations.newProjectTitle
      : localizations.editProjectTitle;

  String _dateText(DateTime? date) {
    if (date == null) {
      return '';
    }
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return switch (_dateFormat) {
      ProjectDateFormat.dayMonthYear => '$day.$month.$year',
      ProjectDateFormat.yearMonthDay => '$year-$month-$day',
    };
  }
}

class _ProjectTypeField extends StatelessWidget {
  const _ProjectTypeField({
    required this.value,
    required this.enabled,
    required this.localizations,
    required this.onChanged,
  });

  final ProjectType value;
  final bool enabled;
  final AppLocalizations localizations;
  final ValueChanged<ProjectType> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return DropdownButtonFormField<ProjectType>(
            key: ValueKey('projectType-${value.name}'),
            initialValue: value,
            decoration: InputDecoration(
              labelText: localizations.projectTypeLabel,
              prefixIcon: const Icon(Icons.home_work_outlined),
            ),
            items: ProjectType.values
                .map(
                  (type) => DropdownMenuItem<ProjectType>(
                    value: type,
                    child: Text(_typeLabel(localizations, type)),
                  ),
                )
                .toList(growable: false),
            onChanged: enabled
                ? (type) {
                    if (type != null) {
                      onChanged(type);
                    }
                  }
                : null,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.projectTypeLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ProjectType>(
                segments: ProjectType.values
                    .map(
                      (type) => ButtonSegment<ProjectType>(
                        value: type,
                        label: Text(_typeLabel(localizations, type)),
                      ),
                    )
                    .toList(growable: false),
                selected: {value},
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                onSelectionChanged: enabled
                    ? (selection) => onChanged(selection.single)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.clearTooltip,
    required this.enabled,
    required this.onTap,
    required this.onClear,
    super.key,
  });

  final String label;
  final String value;
  final String clearTooltip;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(value),
      readOnly: true,
      enabled: enabled,
      initialValue: value,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                tooltip: clearTooltip,
                onPressed: onClear,
                icon: const Icon(Icons.clear_rounded),
              ),
      ),
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.isWide, required this.children});

  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [children.first, const SizedBox(height: 12), children.last],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children.first),
        const SizedBox(width: 12),
        Expanded(child: children.last),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

String? _validateArea(String? value, AppLocalizations localizations) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  final parsed = int.tryParse(text);
  return parsed == null || parsed < 1
      ? localizations.projectAreaInvalidError
      : null;
}

String? _validateBudget(String? value, AppLocalizations localizations) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  try {
    _parseMinorUnits(text);
    return null;
  } on FormatException {
    return localizations.projectBudgetInvalidError;
  }
}

int? _parseOptionalPositiveInt(String text) {
  final normalized = text.trim();
  return normalized.isEmpty ? null : int.parse(normalized);
}

int? _parseMinorUnits(String text) {
  final normalized = text.trim().replaceAll(RegExp(r'[\s\u00A0\u202F]'), '');
  if (normalized.isEmpty) {
    return null;
  }
  if (!RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(normalized)) {
    throw const FormatException();
  }
  final separatorIndex = normalized.indexOf(RegExp(r'[,.]'));
  final wholeText = separatorIndex < 0
      ? normalized
      : normalized.substring(0, separatorIndex);
  final fractionText = separatorIndex < 0
      ? ''
      : normalized.substring(separatorIndex + 1);
  final fraction = switch (fractionText.length) {
    0 => 0,
    1 => int.parse(fractionText) * 10,
    _ => int.parse(fractionText),
  };
  return int.parse(wholeText) * 100 + fraction;
}

String _formatMinorUnitsForInput(int? minorUnits) {
  if (minorUnits == null) {
    return '';
  }
  final whole = minorUnits ~/ 100;
  final fraction = (minorUnits % 100).toString().padLeft(2, '0');
  final digits = whole.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[index]);
  }
  return '$buffer,$fraction';
}

String _typeLabel(AppLocalizations localizations, ProjectType type) {
  return switch (type) {
    ProjectType.houseBuild => localizations.projectTypeHouseBuild,
    ProjectType.houseRenovation => localizations.projectTypeHouseRenovation,
    ProjectType.apartmentRenovation =>
      localizations.projectTypeApartmentRenovation,
  };
}

String _templateLabel(
  AppLocalizations localizations,
  ProjectTemplate template,
) {
  return switch (template) {
    ProjectTemplate.houseConstruction =>
      localizations.projectTemplateHouseConstruction,
    ProjectTemplate.renovation => localizations.projectTemplateRenovation,
  };
}

String _stageLabel(AppLocalizations localizations, ProjectStageKey stage) {
  return switch (stage) {
    ProjectStageKey.planning => localizations.projectStagePlanning,
    ProjectStageKey.formalities => localizations.projectStageFormalities,
    ProjectStageKey.stateZero => localizations.projectStageStateZero,
    ProjectStageKey.shellOpen => localizations.projectStageShellOpen,
    ProjectStageKey.shellClosed => localizations.projectStageShellClosed,
    ProjectStageKey.demolition => localizations.projectStageDemolition,
    ProjectStageKey.installations => localizations.projectStageInstallations,
    ProjectStageKey.plaster => localizations.projectStagePlaster,
    ProjectStageKey.finishing => localizations.projectStageFinishing,
    ProjectStageKey.handover => localizations.projectStageHandover,
  };
}
