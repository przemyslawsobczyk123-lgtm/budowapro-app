import 'package:budowapro/features/projects/domain/project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('draft normalizes text, dates and the initial template stage', () {
    final localStart = DateTime(2026, 9, 1);
    final draft = ProjectDraft(
      name: '  Dom pod lasem  ',
      locationLabel: '  Kraków  ',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currencyCode: 'PLN',
      areaSquareMeters: 132,
      plannedBudgetMinorUnits: 42000000,
      plannedStart: localStart,
      plannedEnd: DateTime(2027, 12, 1),
      dateFormat: ProjectDateFormat.dayMonthYear,
    );

    expect(draft.name, 'Dom pod lasem');
    expect(draft.locationLabel, 'Kraków');
    expect(draft.currentStage, ProjectStageKey.formalities);
    expect(draft.plannedStart, localStart.toUtc());
    expect(draft.plannedStart!.isUtc, isTrue);
  });

  test('draft rejects a template incompatible with project type', () {
    expect(
      () => ProjectDraft(
        name: 'Remont mieszkania',
        type: ProjectType.apartmentRenovation,
        template: ProjectTemplate.houseConstruction,
      ),
      throwsArgumentError,
    );
  });

  test('draft rejects a stage outside the selected template', () {
    expect(
      () => ProjectDraft(
        name: 'Remont mieszkania',
        type: ProjectType.apartmentRenovation,
        template: ProjectTemplate.renovation,
        currentStage: ProjectStageKey.stateZero,
      ),
      throwsArgumentError,
    );
  });

  test('draft validates currency, area, budget and date range', () {
    ProjectDraft validDraft({
      String currencyCode = 'PLN',
      int? areaSquareMeters = 58,
      int? plannedBudgetMinorUnits = 12000000,
      DateTime? plannedStart,
      DateTime? plannedEnd,
    }) {
      return ProjectDraft(
        name: 'Remont',
        type: ProjectType.apartmentRenovation,
        template: ProjectTemplate.renovation,
        currencyCode: currencyCode,
        areaSquareMeters: areaSquareMeters,
        plannedBudgetMinorUnits: plannedBudgetMinorUnits,
        plannedStart: plannedStart,
        plannedEnd: plannedEnd,
      );
    }

    expect(() => validDraft(currencyCode: 'pln'), throwsArgumentError);
    expect(() => validDraft(areaSquareMeters: 0), throwsRangeError);
    expect(() => validDraft(plannedBudgetMinorUnits: -1), throwsRangeError);
    expect(
      () => validDraft(
        plannedStart: DateTime.utc(2027, 1, 2),
        plannedEnd: DateTime.utc(2027, 1, 1),
      ),
      throwsArgumentError,
    );
  });

  test('project keeps identity and UTC audit dates around a valid draft', () {
    final draft = ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    );
    final project = Project(
      id: 'project-1',
      draft: draft,
      createdAt: DateTime(2026, 7, 15, 10),
      updatedAt: DateTime(2026, 7, 15, 11),
    );

    expect(project.id, 'project-1');
    expect(project.name, 'Dom');
    expect(project.createdAtUtc.isUtc, isTrue);
    expect(project.updatedAtUtc.isUtc, isTrue);
    expect(project.isArchived, isFalse);
    expect(project.templateVersion, 1);
  });
}
