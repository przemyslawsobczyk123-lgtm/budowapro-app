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
    StageGuidanceKey.windowShadingPreparation => StageGuidanceContent(
      title: l10n.guidanceWindowShadingPreparationTitle,
      timing: l10n.guidanceWindowShadingPreparationTiming,
      summary: l10n.guidanceWindowShadingPreparationSummary,
      checks: _lines(l10n.guidanceWindowShadingPreparationChecks),
      questions: _lines(l10n.guidanceWindowShadingPreparationQuestions),
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
