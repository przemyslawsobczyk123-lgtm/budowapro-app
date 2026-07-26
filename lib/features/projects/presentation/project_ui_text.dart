import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/l10n/app_localizations.dart';

String projectTypeLabel(AppLocalizations localizations, ProjectType type) =>
    switch (type) {
      ProjectType.houseBuild => localizations.projectTypeHouseBuild,
      ProjectType.houseRenovation => localizations.projectTypeHouseRenovation,
      ProjectType.apartmentRenovation =>
        localizations.projectTypeApartmentRenovation,
    };

String projectTemplateLabel(
  AppLocalizations localizations,
  ProjectTemplate template,
) => switch (template) {
  ProjectTemplate.houseConstruction =>
    localizations.projectTemplateHouseConstruction,
  ProjectTemplate.renovation => localizations.projectTemplateRenovation,
};

String projectStageLabel(
  AppLocalizations localizations,
  ProjectStageKey stage,
) => switch (stage) {
  ProjectStageKey.planning => localizations.projectStagePlanning,
  ProjectStageKey.formalities => localizations.projectStageFormalities,
  ProjectStageKey.sitePreparation =>
    localizations.projectStageSitePreparation,
  ProjectStageKey.stateZero => localizations.projectStageStateZero,
  ProjectStageKey.shellOpen => localizations.projectStageShellOpen,
  ProjectStageKey.shellClosed => localizations.projectStageShellClosed,
  ProjectStageKey.demolition => localizations.projectStageDemolition,
  ProjectStageKey.installations => localizations.projectStageInstallations,
  ProjectStageKey.plaster => localizations.projectStagePlaster,
  ProjectStageKey.finishing => localizations.projectStageFinishing,
  ProjectStageKey.handover => localizations.projectStageHandover,
};

String formatProjectDate(DateTime value, ProjectDateFormat format) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return switch (format) {
    ProjectDateFormat.dayMonthYear => '$day.$month.$year',
    ProjectDateFormat.yearMonthDay => '$year-$month-$day',
  };
}

String formatProjectBudget(
  AppLocalizations localizations,
  int? minorUnits,
  String currencyCode,
) {
  if (minorUnits == null) {
    return localizations.projectValueNotProvided;
  }
  final whole = minorUnits ~/ 100;
  final fraction = (minorUnits % 100).toString().padLeft(2, '0');
  final digits = whole.toString();
  final grouped = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      grouped.write(' ');
    }
    grouped.write(digits[index]);
  }
  return '$grouped,$fraction $currencyCode';
}
