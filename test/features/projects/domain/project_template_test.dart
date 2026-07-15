import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('house construction template is available only for a new house', () {
    final definition = ProjectTemplate.houseConstruction.definition;

    expect(definition.supports(ProjectType.houseBuild), isTrue);
    expect(definition.supports(ProjectType.houseRenovation), isFalse);
    expect(definition.supports(ProjectType.apartmentRenovation), isFalse);
    expect(definition.initialStage, ProjectStageKey.formalities);
    expect(definition.stages, contains(ProjectStageKey.stateZero));
    expect(definition.stages, contains(ProjectStageKey.shellClosed));
    expect(definition.stages.last, ProjectStageKey.handover);
  });

  test('renovation template supports houses and apartments', () {
    final definition = ProjectTemplate.renovation.definition;

    expect(definition.supports(ProjectType.houseBuild), isFalse);
    expect(definition.supports(ProjectType.houseRenovation), isTrue);
    expect(definition.supports(ProjectType.apartmentRenovation), isTrue);
    expect(definition.stages, contains(ProjectStageKey.demolition));
    expect(definition.stages, contains(ProjectStageKey.plaster));
    expect(definition.stages.last, ProjectStageKey.handover);
  });
}
