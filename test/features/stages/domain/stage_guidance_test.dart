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

    test(
      'covers later construction stages without seeding checklist items',
      () {
        final guidance = StageGuidanceCatalog.forStage(
          ProjectStageKey.shellOpen,
        );
        final shellClosed = StageGuidanceCatalog.forStage(
          ProjectStageKey.shellClosed,
        );
        final installations = StageGuidanceCatalog.forStage(
          ProjectStageKey.installations,
        );
        final finishing = StageGuidanceCatalog.forStage(
          ProjectStageKey.finishing,
        );

        expect(guidance, hasLength(3));
        expect(
          guidance.map((item) => item.key),
          contains(StageGuidanceKey.windowShadingPreparation),
        );
        expect(shellClosed, hasLength(2));
        expect(installations, hasLength(2));
        expect(finishing, hasLength(2));
        expect(
          shellClosed
              .singleWhere(
                (item) => item.key == StageGuidanceKey.windowDoorInstallation,
              )
              .sources
              .map((source) => source.key),
          contains(StageGuidanceSourceKey.itbWindowInstallation),
        );
        expect(
          installations
              .singleWhere(
                (item) =>
                    item.key == StageGuidanceKey.installationTestsAndEvidence,
              )
              .sources
              .map((source) => source.key),
          contains(StageGuidanceSourceKey.waterInstallationStandard),
        );
        expect(
          finishing
              .singleWhere(
                (item) => item.key == StageGuidanceKey.wetAreaWaterproofing,
              )
              .sources
              .map((source) => source.key),
          contains(StageGuidanceSourceKey.itbWetAreaWaterproofing),
        );
        expect(
          <StageGuidanceDefinition>[
            ...guidance,
            ...shellClosed,
            ...installations,
            ...finishing,
          ].every(
            (item) =>
                item.relatedChecklistKeys.isEmpty && item.sources.isNotEmpty,
          ),
          isTrue,
        );
      },
    );

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
        <StageGuidanceDefinition>[
          ...formalities,
          ...sitePreparation,
        ].every((item) => item.sources.isNotEmpty),
        isTrue,
      );
    });

    test('keeps auditable structured sources per recommendation', () {
      final guidance = StageGuidanceCatalog.forStage(ProjectStageKey.stateZero);
      final grounding = guidance.singleWhere(
        (item) => item.key == StageGuidanceKey.foundationGrounding,
      );

      expect(grounding.sources, isNotEmpty);
      expect(StageGuidanceCatalog.contentVersion, 4);
      expect(
        grounding.sources.map((source) => source.key),
        containsAll(<StageGuidanceSourceKey>{
          StageGuidanceSourceKey.technicalConditionsEarthing,
          StageGuidanceSourceKey.lowVoltageEarthingStandard,
          StageGuidanceSourceKey.electricalVerificationStandard,
          StageGuidanceSourceKey.lightningProtectionStandard,
          StageGuidanceSourceKey.lightningConnectionStandard,
          StageGuidanceSourceKey.lightningConductorStandard,
          StageGuidanceSourceKey.dehnFoundationEarthing,
        }),
      );
      expect(
        grounding.sources.map((source) => source.key).toSet(),
        hasLength(grounding.sources.length),
      );
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
