import 'package:budowapro/features/projects/domain/project_template.dart';

import 'stage_plan.dart';

final class StageTemplateDefinition {
  const StageTemplateDefinition({
    required this.stageKey,
    this.checklistItems = const <ChecklistTemplateDefinition>[],
  });

  final ProjectStageKey stageKey;
  final List<ChecklistTemplateDefinition> checklistItems;
}

final class ChecklistTemplateDefinition {
  const ChecklistTemplateDefinition({
    required this.key,
    this.importance = ChecklistImportance.normal,
    this.evidenceRequirement = EvidenceRequirement.none,
  });

  final ChecklistTemplateKey key;
  final ChecklistImportance importance;
  final EvidenceRequirement evidenceRequirement;
}

abstract final class StageTemplateCatalog {
  static List<StageTemplateDefinition> forProject(ProjectTemplate template) {
    return template.definition.stages
        .map(
          (stage) => StageTemplateDefinition(
            stageKey: stage,
            checklistItems: switch (stage) {
              ProjectStageKey.planning => planningChecklist,
              ProjectStageKey.formalities => formalitiesChecklist,
              ProjectStageKey.sitePreparation => sitePreparationChecklist,
              ProjectStageKey.stateZero => stateZeroChecklist,
              ProjectStageKey.shellOpen => shellOpenChecklist,
              ProjectStageKey.shellClosed => shellClosedChecklist,
              ProjectStageKey.demolition => demolitionChecklist,
              ProjectStageKey.installations => installationsChecklist,
              ProjectStageKey.plaster => plasterChecklist,
              ProjectStageKey.finishing => finishingChecklist,
              ProjectStageKey.handover => handoverChecklist,
            },
          ),
        )
        .toList(growable: false);
  }

  static const List<ChecklistTemplateDefinition> formalitiesChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.planningPermissionBasis,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.landTitleAndRoadAccess,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.designMap,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.soilResearch,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(key: ChecklistTemplateKey.houseDesignSelection),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.readyDesignAdaptation,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.utilityConnectionConditions,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.coordinatedBuildingDesign,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.buildingPermitOrNotification,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.constructionManagerAppointment,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.constructionLog,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.constructionCommencementNotice,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.managerDocumentationHandover,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.additionalPermitsAudit,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.preStartDocumentAudit,
      importance: ChecklistImportance.critical,
    ),
  ];

  static const List<ChecklistTemplateDefinition> planningChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.planningScopeAndBudget,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.existingBuildingSurvey,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.designDecisionsRegister,
      importance: ChecklistImportance.normal,
    ),
  ];

  static const List<ChecklistTemplateDefinition> sitePreparationChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.siteLogisticsPlan,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.temporarySiteFence,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(key: ChecklistTemplateKey.heavyEquipmentGate),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.stabilizedSiteEntrance,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(key: ChecklistTemplateKey.toolStorageContainer),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.temporaryConstructionPower,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.constructionWaterSupply,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.portableToilet,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.siteUtilitiesAndHazardsMarking,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.siteSafetySetup,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.materialAndWasteZones,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.preConstructionPhotoRecord,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
  ];

  static const List<ChecklistTemplateDefinition> stateZeroChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.surveyorBuildingSetout,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.excavationFoundationLevels,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.underSlabSewerAndRisers,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.waterPenetration,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.powerPenetration,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.telecomPenetration,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.gasPenetration,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.gateIntercomGardenReserve,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.heatPumpOutdoorReserve,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.foundationGrounding,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.continuityMeasurement,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.horizontalVerticalWaterproofing,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.drainage,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.concealedWorksPhotos,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.concreteDeliveryAndAcceptance,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.postFoundationSurvey,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
  ];

  static const List<ChecklistTemplateDefinition> shellOpenChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.shellStructuralAcceptance,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.roofWeatherProtection,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.openingAndShadingPreparation,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.shellSafetyAndAccess,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
  ];

  static const List<ChecklistTemplateDefinition> shellClosedChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.windowDoorAcceptance,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.weatherTightnessAndMoisture,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.temporaryVentilationAndHeating,
      importance: ChecklistImportance.normal,
    ),
  ];

  static const List<ChecklistTemplateDefinition> demolitionChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.demolitionHazardSurvey,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.utilityDisconnectionAndProtection,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.neighborAndCommonAreaProtection,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.demolitionPlanAndWaste,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.demolitionCompletionInspection,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
  ];

  static const List<ChecklistTemplateDefinition> installationsChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.installationCoordination,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.electricalInstallationRoutes,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.waterSewerHeatingRoutes,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.ventilationAndLowVoltageRoutes,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.installationTests,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.concealedInstallationPhotos,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
  ];

  static const List<ChecklistTemplateDefinition> plasterChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.substrateInspection,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.plasterAndScreedExecution,
      importance: ChecklistImportance.high,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.floorHeatingCommissioning,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.plasterScreedAcceptance,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
  ];

  static const List<ChecklistTemplateDefinition> finishingChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.wetAreaWaterproofing,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.finishMaterialsAndSamples,
      importance: ChecklistImportance.normal,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.floorsWallsCeilings,
      importance: ChecklistImportance.normal,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.joineryAndPainting,
      importance: ChecklistImportance.normal,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.systemsCommissioning,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.warrantiesAndManuals,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
  ];

  static const List<ChecklistTemplateDefinition> handoverChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.asBuiltDocumentation,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.asBuiltSurvey,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.testsCertificates,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.constructionCompletionNotice,
      importance: ChecklistImportance.critical,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.defectsAndHandover,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.photo,
    ),
  ];
}
