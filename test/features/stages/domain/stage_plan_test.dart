import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StageTemplateCatalog', () {
    test(
      'seeds formalities, site preparation and Stan 0 without duplicates',
      () {
        final template = StageTemplateCatalog.forProject(
          ProjectTemplate.houseConstruction,
        );
        final formalities = template.singleWhere(
          (stage) => stage.stageKey == ProjectStageKey.formalities,
        );
        final sitePreparation = template.singleWhere(
          (stage) => stage.stageKey == ProjectStageKey.sitePreparation,
        );
        final stateZero = template.singleWhere(
          (stage) => stage.stageKey == ProjectStageKey.stateZero,
        );

        expect(formalities.checklistItems, hasLength(15));
        expect(sitePreparation.checklistItems, hasLength(12));
        expect(stateZero.checklistItems, hasLength(16));
        expect(
          template
              .expand((stage) => stage.checklistItems)
              .map((item) => item.key)
              .toSet(),
          ChecklistTemplateKey.values
              .where((key) => key != ChecklistTemplateKey.siteRoadPowerWater)
              .toSet(),
        );
        expect(
          template.expand((stage) => stage.checklistItems),
          hasLength(
            template
                .expand((stage) => stage.checklistItems)
                .map((item) => item.key)
                .toSet()
                .length,
          ),
        );
        expect(
          formalities.checklistItems.map((item) => item.key),
          containsAll(<ChecklistTemplateKey>{
            ChecklistTemplateKey.planningPermissionBasis,
            ChecklistTemplateKey.designMap,
            ChecklistTemplateKey.soilResearch,
            ChecklistTemplateKey.buildingPermitOrNotification,
            ChecklistTemplateKey.constructionCommencementNotice,
            ChecklistTemplateKey.preStartDocumentAudit,
          }),
        );
        expect(
          sitePreparation.checklistItems.map((item) => item.key),
          containsAll(<ChecklistTemplateKey>{
            ChecklistTemplateKey.temporarySiteFence,
            ChecklistTemplateKey.heavyEquipmentGate,
            ChecklistTemplateKey.stabilizedSiteEntrance,
            ChecklistTemplateKey.toolStorageContainer,
            ChecklistTemplateKey.temporaryConstructionPower,
            ChecklistTemplateKey.constructionWaterSupply,
            ChecklistTemplateKey.portableToilet,
          }),
        );
        expect(
          stateZero.checklistItems
              .singleWhere(
                (item) => item.key == ChecklistTemplateKey.foundationGrounding,
              )
              .evidenceRequirement,
          EvidenceRequirement.photo,
        );

        final shellOpen = template.singleWhere(
          (stage) => stage.stageKey == ProjectStageKey.shellOpen,
        );
        expect(shellOpen.checklistItems, isEmpty);
      },
    );

    test('uses independent ordered stages for renovation projects', () {
      final template = StageTemplateCatalog.forProject(
        ProjectTemplate.renovation,
      );

      expect(
        template.map((stage) => stage.stageKey),
        ProjectTemplate.renovation.definition.stages,
      );
      expect(template.expand((stage) => stage.checklistItems), isEmpty);
    });
  });

  group('StageProgress', () {
    test('derives progress from completed and explicitly skipped items', () {
      final progress = StageProgress.fromStatuses(const <ChecklistStatus>[
        ChecklistStatus.completed,
        ChecklistStatus.skipped,
        ChecklistStatus.inProgress,
        ChecklistStatus.blocked,
      ]);

      expect(progress.resolvedItems, 2);
      expect(progress.totalItems, 4);
      expect(progress.fraction, 0.5);
      expect(progress.percent, 50);
    });

    test('reports zero progress for an empty checklist', () {
      final progress = StageProgress.fromStatuses(const <ChecklistStatus>[]);

      expect(progress.fraction, 0);
      expect(progress.percent, 0);
    });
  });

  group('Checklist resolution', () {
    test('rejects completion without required evidence or waiver', () {
      expect(
        () => validateChecklistResolution(
          status: ChecklistStatus.completed,
          evidenceRequirement: EvidenceRequirement.photo,
          evidenceCount: 0,
        ),
        throwsA(isA<ChecklistEvidenceRequiredException>()),
      );
    });

    test('accepts evidence or an explicit documented waiver', () {
      expect(
        () => validateChecklistResolution(
          status: ChecklistStatus.completed,
          evidenceRequirement: EvidenceRequirement.photo,
          evidenceCount: 1,
        ),
        returnsNormally,
      );
      expect(
        () => validateChecklistResolution(
          status: ChecklistStatus.completed,
          evidenceRequirement: EvidenceRequirement.photo,
          evidenceCount: 0,
          evidenceWaiverComment: 'Kierownik potwierdzil odbior w dzienniku.',
        ),
        returnsNormally,
      );
    });

    test('requires a reason when an item is skipped', () {
      expect(
        () => validateChecklistResolution(
          status: ChecklistStatus.skipped,
          evidenceRequirement: EvidenceRequirement.none,
          evidenceCount: 0,
        ),
        throwsA(isA<ChecklistSkipReasonRequiredException>()),
      );
      expect(
        () => validateChecklistResolution(
          status: ChecklistStatus.skipped,
          evidenceRequirement: EvidenceRequirement.none,
          evidenceCount: 0,
          statusReason: 'Gaz nie jest przewidziany w projekcie.',
        ),
        returnsNormally,
      );
    });
  });
}
