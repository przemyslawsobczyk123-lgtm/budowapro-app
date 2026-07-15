import 'project_template.dart';

export 'project_template.dart';

enum ProjectDateFormat { dayMonthYear, yearMonthDay }

final class ProjectDraft {
  factory ProjectDraft({
    required String name,
    required ProjectType type,
    required ProjectTemplate template,
    String? locationLabel,
    String currencyCode = 'PLN',
    int? areaSquareMeters,
    int? plannedBudgetMinorUnits,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    ProjectDateFormat dateFormat = ProjectDateFormat.dayMonthYear,
    ProjectStageKey? currentStage,
  }) {
    final definition = template.definition;
    if (!definition.supports(type)) {
      throw ArgumentError.value(
        template,
        'template',
        'is not compatible with the project type',
      );
    }

    final normalizedStage = currentStage ?? definition.initialStage;
    if (!definition.stages.contains(normalizedStage)) {
      throw ArgumentError.value(
        normalizedStage,
        'currentStage',
        'does not belong to the selected template',
      );
    }

    final normalizedStart = plannedStart?.toUtc();
    final normalizedEnd = plannedEnd?.toUtc();
    if (normalizedStart != null &&
        normalizedEnd != null &&
        normalizedEnd.isBefore(normalizedStart)) {
      throw ArgumentError.value(
        plannedEnd,
        'plannedEnd',
        'must not be before plannedStart',
      );
    }

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'must be a three-letter uppercase code',
      );
    }
    if (areaSquareMeters != null && areaSquareMeters < 1) {
      throw RangeError.value(
        areaSquareMeters,
        'areaSquareMeters',
        'must be greater than zero',
      );
    }
    if (plannedBudgetMinorUnits != null && plannedBudgetMinorUnits < 0) {
      throw RangeError.value(
        plannedBudgetMinorUnits,
        'plannedBudgetMinorUnits',
        'must be zero or greater',
      );
    }

    return ProjectDraft._(
      name: _requiredText(name, 'name', maximumLength: 80),
      locationLabel: _optionalText(
        locationLabel,
        'locationLabel',
        maximumLength: 120,
      ),
      type: type,
      template: template,
      currencyCode: currencyCode,
      areaSquareMeters: areaSquareMeters,
      plannedBudgetMinorUnits: plannedBudgetMinorUnits,
      plannedStart: normalizedStart,
      plannedEnd: normalizedEnd,
      dateFormat: dateFormat,
      currentStage: normalizedStage,
    );
  }

  const ProjectDraft._({
    required this.name,
    required this.locationLabel,
    required this.type,
    required this.template,
    required this.currencyCode,
    required this.areaSquareMeters,
    required this.plannedBudgetMinorUnits,
    required this.plannedStart,
    required this.plannedEnd,
    required this.dateFormat,
    required this.currentStage,
  });

  final String name;
  final String? locationLabel;
  final ProjectType type;
  final ProjectTemplate template;
  final String currencyCode;
  final int? areaSquareMeters;
  final int? plannedBudgetMinorUnits;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final ProjectDateFormat dateFormat;
  final ProjectStageKey currentStage;
}

final class Project {
  factory Project({
    required String id,
    required ProjectDraft draft,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isArchived = false,
    int templateVersion = 1,
  }) {
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(
        updatedAt,
        'updatedAt',
        'must not be before createdAt',
      );
    }
    if (templateVersion < 1) {
      throw RangeError.value(
        templateVersion,
        'templateVersion',
        'must be greater than zero',
      );
    }

    return Project._(
      id: _requiredText(id, 'id', maximumLength: 64),
      draft: draft,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
      isArchived: isArchived,
      templateVersion: templateVersion,
    );
  }

  const Project._({
    required this.id,
    required this.draft,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.isArchived,
    required this.templateVersion,
  });

  final String id;
  final ProjectDraft draft;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final bool isArchived;
  final int templateVersion;

  String get name => draft.name;
  String? get locationLabel => draft.locationLabel;
  ProjectType get type => draft.type;
  ProjectTemplate get template => draft.template;
  String get currencyCode => draft.currencyCode;
  int? get areaSquareMeters => draft.areaSquareMeters;
  int? get plannedBudgetMinorUnits => draft.plannedBudgetMinorUnits;
  DateTime? get plannedStart => draft.plannedStart;
  DateTime? get plannedEnd => draft.plannedEnd;
  ProjectDateFormat get dateFormat => draft.dateFormat;
  ProjectStageKey get currentStage => draft.currentStage;
}

String _requiredText(
  String value,
  String argumentName, {
  required int maximumLength,
}) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(
      value,
      argumentName,
      'must contain between 1 and $maximumLength characters',
    );
  }
  return normalized;
}

String? _optionalText(
  String? value,
  String argumentName, {
  required int maximumLength,
}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return _requiredText(value, argumentName, maximumLength: maximumLength);
}
