enum ProjectType { houseBuild, houseRenovation, apartmentRenovation }

enum ProjectTemplate { houseConstruction, renovation }

enum ProjectStageKey {
  planning,
  formalities,
  stateZero,
  shellOpen,
  shellClosed,
  demolition,
  installations,
  plaster,
  finishing,
  handover,
}

final class ProjectTemplateDefinition {
  const ProjectTemplateDefinition({
    required this.template,
    required this.compatibleTypes,
    required this.stages,
  });

  final ProjectTemplate template;
  final Set<ProjectType> compatibleTypes;
  final List<ProjectStageKey> stages;

  ProjectStageKey get initialStage => stages.first;

  bool supports(ProjectType type) => compatibleTypes.contains(type);
}

extension ProjectTemplateDefinitionLookup on ProjectTemplate {
  ProjectTemplateDefinition get definition => switch (this) {
    ProjectTemplate.houseConstruction => _houseConstruction,
    ProjectTemplate.renovation => _renovation,
  };
}

const _houseConstruction = ProjectTemplateDefinition(
  template: ProjectTemplate.houseConstruction,
  compatibleTypes: <ProjectType>{ProjectType.houseBuild},
  stages: <ProjectStageKey>[
    ProjectStageKey.formalities,
    ProjectStageKey.stateZero,
    ProjectStageKey.shellOpen,
    ProjectStageKey.shellClosed,
    ProjectStageKey.installations,
    ProjectStageKey.finishing,
    ProjectStageKey.handover,
  ],
);

const _renovation = ProjectTemplateDefinition(
  template: ProjectTemplate.renovation,
  compatibleTypes: <ProjectType>{
    ProjectType.houseRenovation,
    ProjectType.apartmentRenovation,
  },
  stages: <ProjectStageKey>[
    ProjectStageKey.planning,
    ProjectStageKey.demolition,
    ProjectStageKey.installations,
    ProjectStageKey.plaster,
    ProjectStageKey.finishing,
    ProjectStageKey.handover,
  ],
);
