import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StageTemplateCatalog', () {
    test('seeds every required Stan 0 checklist item once', () {
      final template = StageTemplateCatalog.forProject(
        ProjectTemplate.houseConstruction,
      );
      final stateZero = template.singleWhere(
        (stage) => stage.stageKey == ProjectStageKey.stateZero,
      );

      expect(stateZero.checklistItems, hasLength(18));
      expect(
        stateZero.checklistItems.map((item) => item.key).toSet(),
        ChecklistTemplateKey.values.toSet(),
      );
      expect(
        stateZero.checklistItems
            .singleWhere(
              (item) => item.key == ChecklistTemplateKey.foundationGrounding,
            )
            .evidenceRequirement,
        EvidenceRequirement.photo,
      );
    });

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
