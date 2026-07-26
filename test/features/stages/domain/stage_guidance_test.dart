import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/stages/domain/stage_guidance.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StageGuidanceCatalog', () {
    test('covers irreversible Stan 0 decisions without duplicate keys', () {
      final guidance = StageGuidanceCatalog.forStage(ProjectStageKey.stateZero);

      expect(guidance, hasLength(5));
      expect(
        guidance.map((item) => item.key).toSet(),
        hasLength(guidance.length),
      );
      expect(
        guidance.expand((item) => item.relatedChecklistKeys).toSet(),
        containsAll(<ChecklistTemplateKey>{
          ChecklistTemplateKey.underSlabSewerAndRisers,
          ChecklistTemplateKey.waterPenetration,
          ChecklistTemplateKey.powerPenetration,
          ChecklistTemplateKey.foundationGrounding,
          ChecklistTemplateKey.horizontalVerticalWaterproofing,
          ChecklistTemplateKey.drainage,
          ChecklistTemplateKey.concealedWorksPhotos,
        }),
      );
    });

    test('keeps the window shading decision in shell-open guidance', () {
      final guidance = StageGuidanceCatalog.forStage(ProjectStageKey.shellOpen);

      expect(guidance, hasLength(1));
      expect(guidance.single.key, StageGuidanceKey.windowShadingPreparation);
      expect(guidance.single.relatedChecklistKeys, isEmpty);
    });

    test('keeps formal and site guidance compact and source-backed', () {
      final formalities = StageGuidanceCatalog.forStage(
        ProjectStageKey.formalities,
      );
      final sitePreparation = StageGuidanceCatalog.forStage(
        ProjectStageKey.sitePreparation,
      );

      expect(formalities, hasLength(3));
      expect(sitePreparation, hasLength(3));
      expect(
        formalities.expand((item) => item.relatedChecklistKeys).toSet(),
        containsAll(<ChecklistTemplateKey>{
          ChecklistTemplateKey.planningPermissionBasis,
          ChecklistTemplateKey.soilResearch,
          ChecklistTemplateKey.buildingPermitOrNotification,
          ChecklistTemplateKey.constructionCommencementNotice,
        }),
      );
      expect(
        sitePreparation.expand((item) => item.relatedChecklistKeys).toSet(),
        containsAll(<ChecklistTemplateKey>{
          ChecklistTemplateKey.temporarySiteFence,
          ChecklistTemplateKey.stabilizedSiteEntrance,
          ChecklistTemplateKey.temporaryConstructionPower,
          ChecklistTemplateKey.portableToilet,
          ChecklistTemplateKey.siteSafetySetup,
        }),
      );
      expect(
        <StageGuidanceDefinition>[...formalities, ...sitePreparation].every(
          (item) => item.sources.isNotEmpty,
        ),
        isTrue,
      );
    });

    test('keeps auditable structured sources per recommendation', () {
      final guidance = StageGuidanceCatalog.forStage(ProjectStageKey.stateZero);
      final grounding = guidance.singleWhere(
        (item) => item.key == StageGuidanceKey.foundationGrounding,
      );

      expect(grounding.sources, isNotEmpty);
      expect(
        grounding.sources.map((source) => source.type).toSet(),
        containsAll(<StageGuidanceSourceType>{
          StageGuidanceSourceType.regulation,
          StageGuidanceSourceType.standard,
          StageGuidanceSourceType.systemDocumentation,
        }),
      );
      expect(
        grounding.sources.every(
          (source) =>
              source.revision.isNotEmpty &&
              source.url.isScheme('https') &&
              source.verifiedOnIso == StageGuidanceCatalog.verifiedOnIso,
        ),
        isTrue,
      );
    });

    test('returns no built-in advice for a custom stage', () {
      expect(StageGuidanceCatalog.forStage(null), isEmpty);
    });
  });
}
