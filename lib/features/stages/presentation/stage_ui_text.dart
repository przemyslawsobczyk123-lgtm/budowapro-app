import 'package:budowapro/features/projects/presentation/project_ui_text.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/l10n/app_localizations.dart';

String stageName(AppLocalizations l10n, ProjectStage stage) {
  final key = stage.templateKey;
  return key == null ? stage.customName! : projectStageLabel(l10n, key);
}

String stageStatusLabel(AppLocalizations l10n, StageStatus status) =>
    switch (status) {
      StageStatus.planned => l10n.stageStatusPlanned,
      StageStatus.inProgress => l10n.stageStatusInProgress,
      StageStatus.blocked => l10n.stageStatusBlocked,
      StageStatus.completed => l10n.stageStatusCompleted,
    };

String checklistStatusLabel(AppLocalizations l10n, ChecklistStatus status) =>
    switch (status) {
      ChecklistStatus.todo => l10n.checklistStatusTodo,
      ChecklistStatus.inProgress => l10n.checklistStatusInProgress,
      ChecklistStatus.blocked => l10n.checklistStatusBlocked,
      ChecklistStatus.completed => l10n.checklistStatusCompleted,
      ChecklistStatus.skipped => l10n.checklistStatusSkipped,
    };

String checklistImportanceLabel(
  AppLocalizations l10n,
  ChecklistImportance importance,
) => switch (importance) {
  ChecklistImportance.low => l10n.checklistImportanceLow,
  ChecklistImportance.normal => l10n.checklistImportanceNormal,
  ChecklistImportance.high => l10n.checklistImportanceHigh,
  ChecklistImportance.critical => l10n.checklistImportanceCritical,
};

String evidenceRequirementLabel(
  AppLocalizations l10n,
  EvidenceRequirement requirement,
) => switch (requirement) {
  EvidenceRequirement.none => l10n.checklistEvidenceNone,
  EvidenceRequirement.anyAttachment => l10n.checklistEvidenceAny,
  EvidenceRequirement.photo => l10n.checklistEvidencePhoto,
};

String checklistTitle(AppLocalizations l10n, ChecklistItem item) {
  final key = item.templateKey;
  return key == null ? item.customTitle! : checklistTemplateTitle(l10n, key);
}

String checklistRisk(AppLocalizations l10n, ChecklistItem item) {
  final customRisk = item.riskIfSkipped;
  if (customRisk != null) {
    return customRisk;
  }
  final key = item.templateKey;
  return key == null ? '' : checklistTemplateRisk(l10n, key);
}

String checklistTemplateTitle(
  AppLocalizations l10n,
  ChecklistTemplateKey key,
) => switch (key) {
  ChecklistTemplateKey.soilResearch => l10n.checklistSoilResearch,
  ChecklistTemplateKey.surveyorBuildingSetout =>
    l10n.checklistSurveyorBuildingSetout,
  ChecklistTemplateKey.siteRoadPowerWater => l10n.checklistSiteRoadPowerWater,
  ChecklistTemplateKey.excavationFoundationLevels =>
    l10n.checklistExcavationFoundationLevels,
  ChecklistTemplateKey.underSlabSewerAndRisers =>
    l10n.checklistUnderSlabSewerAndRisers,
  ChecklistTemplateKey.waterPenetration => l10n.checklistWaterPenetration,
  ChecklistTemplateKey.powerPenetration => l10n.checklistPowerPenetration,
  ChecklistTemplateKey.telecomPenetration => l10n.checklistTelecomPenetration,
  ChecklistTemplateKey.gasPenetration => l10n.checklistGasPenetration,
  ChecklistTemplateKey.gateIntercomGardenReserve =>
    l10n.checklistGateIntercomGardenReserve,
  ChecklistTemplateKey.heatPumpOutdoorReserve =>
    l10n.checklistHeatPumpOutdoorReserve,
  ChecklistTemplateKey.foundationGrounding => l10n.checklistFoundationGrounding,
  ChecklistTemplateKey.continuityMeasurement =>
    l10n.checklistContinuityMeasurement,
  ChecklistTemplateKey.horizontalVerticalWaterproofing =>
    l10n.checklistWaterproofing,
  ChecklistTemplateKey.drainage => l10n.checklistDrainage,
  ChecklistTemplateKey.concealedWorksPhotos =>
    l10n.checklistConcealedWorksPhotos,
  ChecklistTemplateKey.concreteDeliveryAndAcceptance =>
    l10n.checklistConcreteDeliveryAndAcceptance,
  ChecklistTemplateKey.postFoundationSurvey =>
    l10n.checklistPostFoundationSurvey,
};

String checklistTemplateRisk(
  AppLocalizations l10n,
  ChecklistTemplateKey key,
) => switch (key) {
  ChecklistTemplateKey.soilResearch => l10n.checklistSoilResearchRisk,
  ChecklistTemplateKey.surveyorBuildingSetout =>
    l10n.checklistSurveyorBuildingSetoutRisk,
  ChecklistTemplateKey.siteRoadPowerWater =>
    l10n.checklistSiteRoadPowerWaterRisk,
  ChecklistTemplateKey.excavationFoundationLevels =>
    l10n.checklistExcavationFoundationLevelsRisk,
  ChecklistTemplateKey.underSlabSewerAndRisers =>
    l10n.checklistUnderSlabSewerAndRisersRisk,
  ChecklistTemplateKey.waterPenetration => l10n.checklistWaterPenetrationRisk,
  ChecklistTemplateKey.powerPenetration => l10n.checklistPowerPenetrationRisk,
  ChecklistTemplateKey.telecomPenetration =>
    l10n.checklistTelecomPenetrationRisk,
  ChecklistTemplateKey.gasPenetration => l10n.checklistGasPenetrationRisk,
  ChecklistTemplateKey.gateIntercomGardenReserve =>
    l10n.checklistGateIntercomGardenReserveRisk,
  ChecklistTemplateKey.heatPumpOutdoorReserve =>
    l10n.checklistHeatPumpOutdoorReserveRisk,
  ChecklistTemplateKey.foundationGrounding =>
    l10n.checklistFoundationGroundingRisk,
  ChecklistTemplateKey.continuityMeasurement =>
    l10n.checklistContinuityMeasurementRisk,
  ChecklistTemplateKey.horizontalVerticalWaterproofing =>
    l10n.checklistWaterproofingRisk,
  ChecklistTemplateKey.drainage => l10n.checklistDrainageRisk,
  ChecklistTemplateKey.concealedWorksPhotos =>
    l10n.checklistConcealedWorksPhotosRisk,
  ChecklistTemplateKey.concreteDeliveryAndAcceptance =>
    l10n.checklistConcreteDeliveryAndAcceptanceRisk,
  ChecklistTemplateKey.postFoundationSurvey =>
    l10n.checklistPostFoundationSurveyRisk,
};
