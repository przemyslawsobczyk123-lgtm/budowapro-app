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
            checklistItems: stage == ProjectStageKey.stateZero
                ? stateZeroChecklist
                : const <ChecklistTemplateDefinition>[],
          ),
        )
        .toList(growable: false);
  }

  static const List<ChecklistTemplateDefinition> stateZeroChecklist = [
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.soilResearch,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(
      key: ChecklistTemplateKey.surveyorBuildingSetout,
      importance: ChecklistImportance.high,
      evidenceRequirement: EvidenceRequirement.anyAttachment,
    ),
    ChecklistTemplateDefinition(key: ChecklistTemplateKey.siteRoadPowerWater),
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
