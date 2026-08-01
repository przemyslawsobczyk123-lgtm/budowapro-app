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
  ChecklistTemplateKey.planningScopeAndBudget =>
    l10n.checklistPlanningScopeAndBudget,
  ChecklistTemplateKey.existingBuildingSurvey =>
    l10n.checklistExistingBuildingSurvey,
  ChecklistTemplateKey.designDecisionsRegister =>
    l10n.checklistDesignDecisionsRegister,
  ChecklistTemplateKey.planningPermissionBasis =>
    l10n.checklistPlanningPermissionBasis,
  ChecklistTemplateKey.landTitleAndRoadAccess =>
    l10n.checklistLandTitleAndRoadAccess,
  ChecklistTemplateKey.designMap => l10n.checklistDesignMap,
  ChecklistTemplateKey.soilResearch => l10n.checklistSoilResearch,
  ChecklistTemplateKey.houseDesignSelection =>
    l10n.checklistHouseDesignSelection,
  ChecklistTemplateKey.readyDesignAdaptation =>
    l10n.checklistReadyDesignAdaptation,
  ChecklistTemplateKey.utilityConnectionConditions =>
    l10n.checklistUtilityConnectionConditions,
  ChecklistTemplateKey.coordinatedBuildingDesign =>
    l10n.checklistCoordinatedBuildingDesign,
  ChecklistTemplateKey.buildingPermitOrNotification =>
    l10n.checklistBuildingPermitOrNotification,
  ChecklistTemplateKey.constructionManagerAppointment =>
    l10n.checklistConstructionManagerAppointment,
  ChecklistTemplateKey.constructionLog => l10n.checklistConstructionLog,
  ChecklistTemplateKey.constructionCommencementNotice =>
    l10n.checklistConstructionCommencementNotice,
  ChecklistTemplateKey.managerDocumentationHandover =>
    l10n.checklistManagerDocumentationHandover,
  ChecklistTemplateKey.additionalPermitsAudit =>
    l10n.checklistAdditionalPermitsAudit,
  ChecklistTemplateKey.preStartDocumentAudit =>
    l10n.checklistPreStartDocumentAudit,
  ChecklistTemplateKey.siteLogisticsPlan => l10n.checklistSiteLogisticsPlan,
  ChecklistTemplateKey.temporarySiteFence => l10n.checklistTemporarySiteFence,
  ChecklistTemplateKey.heavyEquipmentGate => l10n.checklistHeavyEquipmentGate,
  ChecklistTemplateKey.stabilizedSiteEntrance =>
    l10n.checklistStabilizedSiteEntrance,
  ChecklistTemplateKey.toolStorageContainer =>
    l10n.checklistToolStorageContainer,
  ChecklistTemplateKey.temporaryConstructionPower =>
    l10n.checklistTemporaryConstructionPower,
  ChecklistTemplateKey.constructionWaterSupply =>
    l10n.checklistConstructionWaterSupply,
  ChecklistTemplateKey.portableToilet => l10n.checklistPortableToilet,
  ChecklistTemplateKey.siteUtilitiesAndHazardsMarking =>
    l10n.checklistSiteUtilitiesAndHazardsMarking,
  ChecklistTemplateKey.siteSafetySetup => l10n.checklistSiteSafetySetup,
  ChecklistTemplateKey.materialAndWasteZones =>
    l10n.checklistMaterialAndWasteZones,
  ChecklistTemplateKey.preConstructionPhotoRecord =>
    l10n.checklistPreConstructionPhotoRecord,
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
  ChecklistTemplateKey.demolitionHazardSurvey =>
    l10n.checklistDemolitionHazardSurvey,
  ChecklistTemplateKey.utilityDisconnectionAndProtection =>
    l10n.checklistUtilityDisconnectionAndProtection,
  ChecklistTemplateKey.demolitionPlanAndWaste =>
    l10n.checklistDemolitionPlanAndWaste,
  ChecklistTemplateKey.neighborAndCommonAreaProtection =>
    l10n.checklistNeighborAndCommonAreaProtection,
  ChecklistTemplateKey.demolitionCompletionInspection =>
    l10n.checklistDemolitionCompletionInspection,
  ChecklistTemplateKey.shellStructuralAcceptance =>
    l10n.checklistShellStructuralAcceptance,
  ChecklistTemplateKey.roofWeatherProtection =>
    l10n.checklistRoofWeatherProtection,
  ChecklistTemplateKey.openingAndShadingPreparation =>
    l10n.checklistOpeningAndShadingPreparation,
  ChecklistTemplateKey.shellSafetyAndAccess =>
    l10n.checklistShellSafetyAndAccess,
  ChecklistTemplateKey.windowDoorAcceptance =>
    l10n.checklistWindowDoorAcceptance,
  ChecklistTemplateKey.weatherTightnessAndMoisture =>
    l10n.checklistWeatherTightnessAndMoisture,
  ChecklistTemplateKey.temporaryVentilationAndHeating =>
    l10n.checklistTemporaryVentilationAndHeating,
  ChecklistTemplateKey.installationCoordination =>
    l10n.checklistInstallationCoordination,
  ChecklistTemplateKey.electricalInstallationRoutes =>
    l10n.checklistElectricalInstallationRoutes,
  ChecklistTemplateKey.waterSewerHeatingRoutes =>
    l10n.checklistWaterSewerHeatingRoutes,
  ChecklistTemplateKey.ventilationAndLowVoltageRoutes =>
    l10n.checklistVentilationAndLowVoltageRoutes,
  ChecklistTemplateKey.installationTests => l10n.checklistInstallationTests,
  ChecklistTemplateKey.concealedInstallationPhotos =>
    l10n.checklistConcealedInstallationPhotos,
  ChecklistTemplateKey.substrateInspection => l10n.checklistSubstrateInspection,
  ChecklistTemplateKey.plasterAndScreedExecution =>
    l10n.checklistPlasterAndScreedExecution,
  ChecklistTemplateKey.floorHeatingCommissioning =>
    l10n.checklistFloorHeatingCommissioning,
  ChecklistTemplateKey.plasterScreedAcceptance =>
    l10n.checklistPlasterScreedAcceptance,
  ChecklistTemplateKey.wetAreaWaterproofing =>
    l10n.checklistWetAreaWaterproofing,
  ChecklistTemplateKey.finishMaterialsAndSamples =>
    l10n.checklistFinishMaterialsAndSamples,
  ChecklistTemplateKey.floorsWallsCeilings => l10n.checklistFloorsWallsCeilings,
  ChecklistTemplateKey.joineryAndPainting => l10n.checklistJoineryAndPainting,
  ChecklistTemplateKey.systemsCommissioning =>
    l10n.checklistSystemsCommissioning,
  ChecklistTemplateKey.warrantiesAndManuals =>
    l10n.checklistWarrantiesAndManuals,
  ChecklistTemplateKey.asBuiltDocumentation =>
    l10n.checklistAsBuiltDocumentation,
  ChecklistTemplateKey.asBuiltSurvey => l10n.checklistAsBuiltSurvey,
  ChecklistTemplateKey.testsCertificates => l10n.checklistTestsCertificates,
  ChecklistTemplateKey.constructionCompletionNotice =>
    l10n.checklistConstructionCompletionNotice,
  ChecklistTemplateKey.defectsAndHandover => l10n.checklistDefectsAndHandover,
};

String checklistTemplateRisk(
  AppLocalizations l10n,
  ChecklistTemplateKey key,
) => switch (key) {
  ChecklistTemplateKey.planningScopeAndBudget =>
    l10n.checklistPlanningScopeAndBudgetRisk,
  ChecklistTemplateKey.existingBuildingSurvey =>
    l10n.checklistExistingBuildingSurveyRisk,
  ChecklistTemplateKey.designDecisionsRegister =>
    l10n.checklistDesignDecisionsRegisterRisk,
  ChecklistTemplateKey.planningPermissionBasis =>
    l10n.checklistPlanningPermissionBasisRisk,
  ChecklistTemplateKey.landTitleAndRoadAccess =>
    l10n.checklistLandTitleAndRoadAccessRisk,
  ChecklistTemplateKey.designMap => l10n.checklistDesignMapRisk,
  ChecklistTemplateKey.soilResearch => l10n.checklistSoilResearchRisk,
  ChecklistTemplateKey.houseDesignSelection =>
    l10n.checklistHouseDesignSelectionRisk,
  ChecklistTemplateKey.readyDesignAdaptation =>
    l10n.checklistReadyDesignAdaptationRisk,
  ChecklistTemplateKey.utilityConnectionConditions =>
    l10n.checklistUtilityConnectionConditionsRisk,
  ChecklistTemplateKey.coordinatedBuildingDesign =>
    l10n.checklistCoordinatedBuildingDesignRisk,
  ChecklistTemplateKey.buildingPermitOrNotification =>
    l10n.checklistBuildingPermitOrNotificationRisk,
  ChecklistTemplateKey.constructionManagerAppointment =>
    l10n.checklistConstructionManagerAppointmentRisk,
  ChecklistTemplateKey.constructionLog => l10n.checklistConstructionLogRisk,
  ChecklistTemplateKey.constructionCommencementNotice =>
    l10n.checklistConstructionCommencementNoticeRisk,
  ChecklistTemplateKey.managerDocumentationHandover =>
    l10n.checklistManagerDocumentationHandoverRisk,
  ChecklistTemplateKey.additionalPermitsAudit =>
    l10n.checklistAdditionalPermitsAuditRisk,
  ChecklistTemplateKey.preStartDocumentAudit =>
    l10n.checklistPreStartDocumentAuditRisk,
  ChecklistTemplateKey.siteLogisticsPlan => l10n.checklistSiteLogisticsPlanRisk,
  ChecklistTemplateKey.temporarySiteFence =>
    l10n.checklistTemporarySiteFenceRisk,
  ChecklistTemplateKey.heavyEquipmentGate =>
    l10n.checklistHeavyEquipmentGateRisk,
  ChecklistTemplateKey.stabilizedSiteEntrance =>
    l10n.checklistStabilizedSiteEntranceRisk,
  ChecklistTemplateKey.toolStorageContainer =>
    l10n.checklistToolStorageContainerRisk,
  ChecklistTemplateKey.temporaryConstructionPower =>
    l10n.checklistTemporaryConstructionPowerRisk,
  ChecklistTemplateKey.constructionWaterSupply =>
    l10n.checklistConstructionWaterSupplyRisk,
  ChecklistTemplateKey.portableToilet => l10n.checklistPortableToiletRisk,
  ChecklistTemplateKey.siteUtilitiesAndHazardsMarking =>
    l10n.checklistSiteUtilitiesAndHazardsMarkingRisk,
  ChecklistTemplateKey.siteSafetySetup => l10n.checklistSiteSafetySetupRisk,
  ChecklistTemplateKey.materialAndWasteZones =>
    l10n.checklistMaterialAndWasteZonesRisk,
  ChecklistTemplateKey.preConstructionPhotoRecord =>
    l10n.checklistPreConstructionPhotoRecordRisk,
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
  ChecklistTemplateKey.demolitionHazardSurvey =>
    l10n.checklistDemolitionHazardSurveyRisk,
  ChecklistTemplateKey.utilityDisconnectionAndProtection =>
    l10n.checklistUtilityDisconnectionAndProtectionRisk,
  ChecklistTemplateKey.demolitionPlanAndWaste =>
    l10n.checklistDemolitionPlanAndWasteRisk,
  ChecklistTemplateKey.neighborAndCommonAreaProtection =>
    l10n.checklistNeighborAndCommonAreaProtectionRisk,
  ChecklistTemplateKey.demolitionCompletionInspection =>
    l10n.checklistDemolitionCompletionInspectionRisk,
  ChecklistTemplateKey.shellStructuralAcceptance =>
    l10n.checklistShellStructuralAcceptanceRisk,
  ChecklistTemplateKey.roofWeatherProtection =>
    l10n.checklistRoofWeatherProtectionRisk,
  ChecklistTemplateKey.openingAndShadingPreparation =>
    l10n.checklistOpeningAndShadingPreparationRisk,
  ChecklistTemplateKey.shellSafetyAndAccess =>
    l10n.checklistShellSafetyAndAccessRisk,
  ChecklistTemplateKey.windowDoorAcceptance =>
    l10n.checklistWindowDoorAcceptanceRisk,
  ChecklistTemplateKey.weatherTightnessAndMoisture =>
    l10n.checklistWeatherTightnessAndMoistureRisk,
  ChecklistTemplateKey.temporaryVentilationAndHeating =>
    l10n.checklistTemporaryVentilationAndHeatingRisk,
  ChecklistTemplateKey.installationCoordination =>
    l10n.checklistInstallationCoordinationRisk,
  ChecklistTemplateKey.electricalInstallationRoutes =>
    l10n.checklistElectricalInstallationRoutesRisk,
  ChecklistTemplateKey.waterSewerHeatingRoutes =>
    l10n.checklistWaterSewerHeatingRoutesRisk,
  ChecklistTemplateKey.ventilationAndLowVoltageRoutes =>
    l10n.checklistVentilationAndLowVoltageRoutesRisk,
  ChecklistTemplateKey.installationTests => l10n.checklistInstallationTestsRisk,
  ChecklistTemplateKey.concealedInstallationPhotos =>
    l10n.checklistConcealedInstallationPhotosRisk,
  ChecklistTemplateKey.substrateInspection =>
    l10n.checklistSubstrateInspectionRisk,
  ChecklistTemplateKey.plasterAndScreedExecution =>
    l10n.checklistPlasterAndScreedExecutionRisk,
  ChecklistTemplateKey.floorHeatingCommissioning =>
    l10n.checklistFloorHeatingCommissioningRisk,
  ChecklistTemplateKey.plasterScreedAcceptance =>
    l10n.checklistPlasterScreedAcceptanceRisk,
  ChecklistTemplateKey.wetAreaWaterproofing =>
    l10n.checklistWetAreaWaterproofingRisk,
  ChecklistTemplateKey.finishMaterialsAndSamples =>
    l10n.checklistFinishMaterialsAndSamplesRisk,
  ChecklistTemplateKey.floorsWallsCeilings =>
    l10n.checklistFloorsWallsCeilingsRisk,
  ChecklistTemplateKey.joineryAndPainting =>
    l10n.checklistJoineryAndPaintingRisk,
  ChecklistTemplateKey.systemsCommissioning =>
    l10n.checklistSystemsCommissioningRisk,
  ChecklistTemplateKey.warrantiesAndManuals =>
    l10n.checklistWarrantiesAndManualsRisk,
  ChecklistTemplateKey.asBuiltDocumentation =>
    l10n.checklistAsBuiltDocumentationRisk,
  ChecklistTemplateKey.asBuiltSurvey => l10n.checklistAsBuiltSurveyRisk,
  ChecklistTemplateKey.testsCertificates => l10n.checklistTestsCertificatesRisk,
  ChecklistTemplateKey.constructionCompletionNotice =>
    l10n.checklistConstructionCompletionNoticeRisk,
  ChecklistTemplateKey.defectsAndHandover =>
    l10n.checklistDefectsAndHandoverRisk,
};
