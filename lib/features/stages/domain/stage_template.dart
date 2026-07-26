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
              ProjectStageKey.formalities => formalitiesChecklist,
              ProjectStageKey.sitePreparation => sitePreparationChecklist,
              ProjectStageKey.stateZero => stateZeroChecklist,
              _ => const <ChecklistTemplateDefinition>[],
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
}
