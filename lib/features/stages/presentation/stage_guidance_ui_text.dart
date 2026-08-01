import 'package:budowapro/features/stages/domain/stage_guidance.dart';
import 'package:budowapro/l10n/app_localizations.dart';

final class StageGuidanceContent {
  const StageGuidanceContent({
    required this.title,
    required this.timing,
    required this.summary,
    required this.checks,
    required this.questions,
  });

  final String title;
  final String timing;
  final String summary;
  final List<String> checks;
  final List<String> questions;
}

StageGuidanceContent stageGuidanceContent(
  AppLocalizations l10n,
  StageGuidanceKey key,
) {
  return switch (key) {
    StageGuidanceKey.planningScopeAndSurvey => StageGuidanceContent(
      title: l10n.guidancePlanningScopeAndSurveyTitle,
      timing: l10n.guidancePlanningScopeAndSurveyTiming,
      summary: l10n.guidancePlanningScopeAndSurveySummary,
      checks: _lines(l10n.guidancePlanningScopeAndSurveyChecks),
      questions: _lines(l10n.guidancePlanningScopeAndSurveyQuestions),
    ),
    StageGuidanceKey.planningAndGroundConditions => StageGuidanceContent(
      title: l10n.guidancePlanningAndGroundConditionsTitle,
      timing: l10n.guidancePlanningAndGroundConditionsTiming,
      summary: l10n.guidancePlanningAndGroundConditionsSummary,
      checks: _lines(l10n.guidancePlanningAndGroundConditionsChecks),
      questions: _lines(l10n.guidancePlanningAndGroundConditionsQuestions),
    ),
    StageGuidanceKey.designUtilitiesAndApprovals => StageGuidanceContent(
      title: l10n.guidanceDesignUtilitiesAndApprovalsTitle,
      timing: l10n.guidanceDesignUtilitiesAndApprovalsTiming,
      summary: l10n.guidanceDesignUtilitiesAndApprovalsSummary,
      checks: _lines(l10n.guidanceDesignUtilitiesAndApprovalsChecks),
      questions: _lines(l10n.guidanceDesignUtilitiesAndApprovalsQuestions),
    ),
    StageGuidanceKey.legalConstructionStart => StageGuidanceContent(
      title: l10n.guidanceLegalConstructionStartTitle,
      timing: l10n.guidanceLegalConstructionStartTiming,
      summary: l10n.guidanceLegalConstructionStartSummary,
      checks: _lines(l10n.guidanceLegalConstructionStartChecks),
      questions: _lines(l10n.guidanceLegalConstructionStartQuestions),
    ),
    StageGuidanceKey.siteLogisticsAndAccess => StageGuidanceContent(
      title: l10n.guidanceSiteLogisticsAndAccessTitle,
      timing: l10n.guidanceSiteLogisticsAndAccessTiming,
      summary: l10n.guidanceSiteLogisticsAndAccessSummary,
      checks: _lines(l10n.guidanceSiteLogisticsAndAccessChecks),
      questions: _lines(l10n.guidanceSiteLogisticsAndAccessQuestions),
    ),
    StageGuidanceKey.temporaryUtilitiesAndFacilities => StageGuidanceContent(
      title: l10n.guidanceTemporaryUtilitiesAndFacilitiesTitle,
      timing: l10n.guidanceTemporaryUtilitiesAndFacilitiesTiming,
      summary: l10n.guidanceTemporaryUtilitiesAndFacilitiesSummary,
      checks: _lines(l10n.guidanceTemporaryUtilitiesAndFacilitiesChecks),
      questions: _lines(l10n.guidanceTemporaryUtilitiesAndFacilitiesQuestions),
    ),
    StageGuidanceKey.siteSafetyAndEvidence => StageGuidanceContent(
      title: l10n.guidanceSiteSafetyAndEvidenceTitle,
      timing: l10n.guidanceSiteSafetyAndEvidenceTiming,
      summary: l10n.guidanceSiteSafetyAndEvidenceSummary,
      checks: _lines(l10n.guidanceSiteSafetyAndEvidenceChecks),
      questions: _lines(l10n.guidanceSiteSafetyAndEvidenceQuestions),
    ),
    StageGuidanceKey.demolitionSafetyAndUtilities => StageGuidanceContent(
      title: l10n.guidanceDemolitionSafetyAndUtilitiesTitle,
      timing: l10n.guidanceDemolitionSafetyAndUtilitiesTiming,
      summary: l10n.guidanceDemolitionSafetyAndUtilitiesSummary,
      checks: _lines(l10n.guidanceDemolitionSafetyAndUtilitiesChecks),
      questions: _lines(l10n.guidanceDemolitionSafetyAndUtilitiesQuestions),
    ),
    StageGuidanceKey.servicePenetrations => StageGuidanceContent(
      title: l10n.guidanceServicePenetrationsTitle,
      timing: l10n.guidanceServicePenetrationsTiming,
      summary: l10n.guidanceServicePenetrationsSummary,
      checks: _lines(l10n.guidanceServicePenetrationsChecks),
      questions: _lines(l10n.guidanceServicePenetrationsQuestions),
    ),
    StageGuidanceKey.foundationGrounding => StageGuidanceContent(
      title: l10n.guidanceFoundationGroundingTitle,
      timing: l10n.guidanceFoundationGroundingTiming,
      summary: l10n.guidanceFoundationGroundingSummary,
      checks: _lines(l10n.guidanceFoundationGroundingChecks),
      questions: _lines(l10n.guidanceFoundationGroundingQuestions),
    ),
    StageGuidanceKey.foundationWaterproofing => StageGuidanceContent(
      title: l10n.guidanceFoundationWaterproofingTitle,
      timing: l10n.guidanceFoundationWaterproofingTiming,
      summary: l10n.guidanceFoundationWaterproofingSummary,
      checks: _lines(l10n.guidanceFoundationWaterproofingChecks),
      questions: _lines(l10n.guidanceFoundationWaterproofingQuestions),
    ),
    StageGuidanceKey.drainageAndGroundLevels => StageGuidanceContent(
      title: l10n.guidanceDrainageAndGroundLevelsTitle,
      timing: l10n.guidanceDrainageAndGroundLevelsTiming,
      summary: l10n.guidanceDrainageAndGroundLevelsSummary,
      checks: _lines(l10n.guidanceDrainageAndGroundLevelsChecks),
      questions: _lines(l10n.guidanceDrainageAndGroundLevelsQuestions),
    ),
    StageGuidanceKey.concealedWorksEvidence => StageGuidanceContent(
      title: l10n.guidanceConcealedWorksEvidenceTitle,
      timing: l10n.guidanceConcealedWorksEvidenceTiming,
      summary: l10n.guidanceConcealedWorksEvidenceSummary,
      checks: _lines(l10n.guidanceConcealedWorksEvidenceChecks),
      questions: _lines(l10n.guidanceConcealedWorksEvidenceQuestions),
    ),
    StageGuidanceKey.structuralShellChecks => StageGuidanceContent(
      title: l10n.guidanceStructuralShellChecksTitle,
      timing: l10n.guidanceStructuralShellChecksTiming,
      summary: l10n.guidanceStructuralShellChecksSummary,
      checks: _lines(l10n.guidanceStructuralShellChecksChecks),
      questions: _lines(l10n.guidanceStructuralShellChecksQuestions),
    ),
    StageGuidanceKey.roofAndWeatherProtection => StageGuidanceContent(
      title: l10n.guidanceRoofAndWeatherProtectionTitle,
      timing: l10n.guidanceRoofAndWeatherProtectionTiming,
      summary: l10n.guidanceRoofAndWeatherProtectionSummary,
      checks: _lines(l10n.guidanceRoofAndWeatherProtectionChecks),
      questions: _lines(l10n.guidanceRoofAndWeatherProtectionQuestions),
    ),
    StageGuidanceKey.windowShadingPreparation => StageGuidanceContent(
      title: l10n.guidanceWindowShadingPreparationTitle,
      timing: l10n.guidanceWindowShadingPreparationTiming,
      summary: l10n.guidanceWindowShadingPreparationSummary,
      checks: _lines(l10n.guidanceWindowShadingPreparationChecks),
      questions: _lines(l10n.guidanceWindowShadingPreparationQuestions),
    ),
    StageGuidanceKey.windowDoorInstallation => StageGuidanceContent(
      title: l10n.guidanceWindowDoorInstallationTitle,
      timing: l10n.guidanceWindowDoorInstallationTiming,
      summary: l10n.guidanceWindowDoorInstallationSummary,
      checks: _lines(l10n.guidanceWindowDoorInstallationChecks),
      questions: _lines(l10n.guidanceWindowDoorInstallationQuestions),
    ),
    StageGuidanceKey.closedShellMoistureControl => StageGuidanceContent(
      title: l10n.guidanceClosedShellMoistureControlTitle,
      timing: l10n.guidanceClosedShellMoistureControlTiming,
      summary: l10n.guidanceClosedShellMoistureControlSummary,
      checks: _lines(l10n.guidanceClosedShellMoistureControlChecks),
      questions: _lines(l10n.guidanceClosedShellMoistureControlQuestions),
    ),
    StageGuidanceKey.installationRoutesAndAccess => StageGuidanceContent(
      title: l10n.guidanceInstallationRoutesAndAccessTitle,
      timing: l10n.guidanceInstallationRoutesAndAccessTiming,
      summary: l10n.guidanceInstallationRoutesAndAccessSummary,
      checks: _lines(l10n.guidanceInstallationRoutesAndAccessChecks),
      questions: _lines(l10n.guidanceInstallationRoutesAndAccessQuestions),
    ),
    StageGuidanceKey.installationTestsAndEvidence => StageGuidanceContent(
      title: l10n.guidanceInstallationTestsAndEvidenceTitle,
      timing: l10n.guidanceInstallationTestsAndEvidenceTiming,
      summary: l10n.guidanceInstallationTestsAndEvidenceSummary,
      checks: _lines(l10n.guidanceInstallationTestsAndEvidenceChecks),
      questions: _lines(l10n.guidanceInstallationTestsAndEvidenceQuestions),
    ),
    StageGuidanceKey.plasterAndScreedExecution => StageGuidanceContent(
      title: l10n.guidancePlasterAndScreedExecutionTitle,
      timing: l10n.guidancePlasterAndScreedExecutionTiming,
      summary: l10n.guidancePlasterAndScreedExecutionSummary,
      checks: _lines(l10n.guidancePlasterAndScreedExecutionChecks),
      questions: _lines(l10n.guidancePlasterAndScreedExecutionQuestions),
    ),
    StageGuidanceKey.finishSubstratesAndHeating => StageGuidanceContent(
      title: l10n.guidanceFinishSubstratesAndHeatingTitle,
      timing: l10n.guidanceFinishSubstratesAndHeatingTiming,
      summary: l10n.guidanceFinishSubstratesAndHeatingSummary,
      checks: _lines(l10n.guidanceFinishSubstratesAndHeatingChecks),
      questions: _lines(l10n.guidanceFinishSubstratesAndHeatingQuestions),
    ),
    StageGuidanceKey.wetAreaWaterproofing => StageGuidanceContent(
      title: l10n.guidanceWetAreaWaterproofingTitle,
      timing: l10n.guidanceWetAreaWaterproofingTiming,
      summary: l10n.guidanceWetAreaWaterproofingSummary,
      checks: _lines(l10n.guidanceWetAreaWaterproofingChecks),
      questions: _lines(l10n.guidanceWetAreaWaterproofingQuestions),
    ),
    StageGuidanceKey.handoverAndOccupancy => StageGuidanceContent(
      title: l10n.guidanceHandoverAndOccupancyTitle,
      timing: l10n.guidanceHandoverAndOccupancyTiming,
      summary: l10n.guidanceHandoverAndOccupancySummary,
      checks: _lines(l10n.guidanceHandoverAndOccupancyChecks),
      questions: _lines(l10n.guidanceHandoverAndOccupancyQuestions),
    ),
  };
}

String stageGuidanceSourceTypeLabel(
  AppLocalizations l10n,
  StageGuidanceSourceType type,
) => switch (type) {
  StageGuidanceSourceType.regulation => l10n.stageGuidanceSourceRegulation,
  StageGuidanceSourceType.standard => l10n.stageGuidanceSourceStandard,
  StageGuidanceSourceType.officialGuidance =>
    l10n.stageGuidanceSourceOfficialGuidance,
  StageGuidanceSourceType.systemDocumentation =>
    l10n.stageGuidanceSourceSystemDocumentation,
};

String stageGuidanceSourceTitle(
  AppLocalizations l10n,
  StageGuidanceSourceKey key,
) => switch (key) {
  StageGuidanceSourceKey.constructionLaw =>
    l10n.stageGuidanceSourceConstructionLaw,
  StageGuidanceSourceKey.gunbProcedures =>
    l10n.stageGuidanceSourceGunbProcedures,
  StageGuidanceSourceKey.gunbForms => l10n.stageGuidanceSourceGunbForms,
  StageGuidanceSourceKey.spatialPlanningGuidance =>
    l10n.stageGuidanceSourceSpatialPlanning,
  StageGuidanceSourceKey.geotechnicalRegulation =>
    l10n.stageGuidanceSourceGeotechnicalRegulation,
  StageGuidanceSourceKey.eurocodeGeotechnicalDesign =>
    l10n.stageGuidanceSourceEurocodeGeotechnical,
  StageGuidanceSourceKey.geodeticGuidance =>
    l10n.stageGuidanceSourceGeodeticGuidance,
  StageGuidanceSourceKey.electronicConstructionLog =>
    l10n.stageGuidanceSourceElectronicConstructionLog,
  StageGuidanceSourceKey.constructionSafetyRegulation =>
    l10n.stageGuidanceSourceConstructionSafety,
  StageGuidanceSourceKey.pipConstructionChecklist =>
    l10n.stageGuidanceSourcePipChecklist,
  StageGuidanceSourceKey.gddkiaSiteAccess =>
    l10n.stageGuidanceSourceGddkiaSiteAccess,
  StageGuidanceSourceKey.technicalConditions =>
    l10n.stageGuidanceSourceTechnicalConditions,
  StageGuidanceSourceKey.technicalConditionsEarthing =>
    l10n.stageGuidanceSourceTechnicalConditionsEarthing,
  StageGuidanceSourceKey.lowVoltageEarthingStandard =>
    l10n.stageGuidanceSourceLowVoltageEarthing,
  StageGuidanceSourceKey.electricalVerificationStandard =>
    l10n.stageGuidanceSourceElectricalVerification,
  StageGuidanceSourceKey.lightningProtectionStandard =>
    l10n.stageGuidanceSourceLightningProtection,
  StageGuidanceSourceKey.lightningConnectionStandard =>
    l10n.stageGuidanceSourceLightningConnections,
  StageGuidanceSourceKey.lightningConductorStandard =>
    l10n.stageGuidanceSourceLightningConductors,
  StageGuidanceSourceKey.itbBelowGroundWaterproofing =>
    l10n.stageGuidanceSourceItbWaterproofing,
  StageGuidanceSourceKey.pmbcStandard => l10n.stageGuidanceSourcePmbcStandard,
  StageGuidanceSourceKey.concreteExecutionStandard =>
    l10n.stageGuidanceSourceConcreteExecution,
  StageGuidanceSourceKey.masonryExecutionStandard =>
    l10n.stageGuidanceSourceMasonryExecution,
  StageGuidanceSourceKey.itbRoofCoverings =>
    l10n.stageGuidanceSourceItbRoofCoverings,
  StageGuidanceSourceKey.windowPerformanceStandard =>
    l10n.stageGuidanceSourceWindowPerformance,
  StageGuidanceSourceKey.itbWindowInstallation =>
    l10n.stageGuidanceSourceItbWindowInstallation,
  StageGuidanceSourceKey.waterInstallationStandard =>
    l10n.stageGuidanceSourceWaterInstallation,
  StageGuidanceSourceKey.surfaceHeatingInstallationStandard =>
    l10n.stageGuidanceSourceSurfaceHeating,
  StageGuidanceSourceKey.ventilationAcceptanceStandard =>
    l10n.stageGuidanceSourceVentilationAcceptance,
  StageGuidanceSourceKey.itbTileFinishes =>
    l10n.stageGuidanceSourceItbTileFinishes,
  StageGuidanceSourceKey.liquidWaterproofingStandard =>
    l10n.stageGuidanceSourceLiquidWaterproofing,
  StageGuidanceSourceKey.itbWetAreaWaterproofing =>
    l10n.stageGuidanceSourceItbWetAreaWaterproofing,
  StageGuidanceSourceKey.dehnFoundationEarthing =>
    l10n.stageGuidanceSourceDehnEarthing,
  StageGuidanceSourceKey.hauffBuildingEntries =>
    l10n.stageGuidanceSourceHauffEntries,
  StageGuidanceSourceKey.remmersWaterproofingSystem =>
    l10n.stageGuidanceSourceRemmersWaterproofing,
  StageGuidanceSourceKey.ursaFoundationInsulation =>
    l10n.stageGuidanceSourceUrsaInsulation,
  StageGuidanceSourceKey.aluprofShadingSystems =>
    l10n.stageGuidanceSourceAluprofShading,
};

List<String> _lines(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}
