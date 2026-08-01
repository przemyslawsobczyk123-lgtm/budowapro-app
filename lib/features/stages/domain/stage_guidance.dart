import 'package:budowapro/features/projects/domain/project_template.dart';

import 'stage_plan.dart';

enum StageGuidanceKey {
  planningScopeAndSurvey,
  planningAndGroundConditions,
  designUtilitiesAndApprovals,
  legalConstructionStart,
  siteLogisticsAndAccess,
  temporaryUtilitiesAndFacilities,
  siteSafetyAndEvidence,
  demolitionSafetyAndUtilities,
  servicePenetrations,
  foundationGrounding,
  foundationWaterproofing,
  drainageAndGroundLevels,
  concealedWorksEvidence,
  structuralShellChecks,
  roofAndWeatherProtection,
  windowShadingPreparation,
  windowDoorInstallation,
  closedShellMoistureControl,
  installationRoutesAndAccess,
  installationTestsAndEvidence,
  plasterAndScreedExecution,
  finishSubstratesAndHeating,
  wetAreaWaterproofing,
  handoverAndOccupancy,
}

enum StageGuidanceSourceType {
  regulation,
  standard,
  officialGuidance,
  systemDocumentation,
}

enum StageGuidanceSourceKey {
  constructionLaw,
  gunbProcedures,
  gunbForms,
  spatialPlanningGuidance,
  geotechnicalRegulation,
  eurocodeGeotechnicalDesign,
  geodeticGuidance,
  electronicConstructionLog,
  constructionSafetyRegulation,
  pipConstructionChecklist,
  gddkiaSiteAccess,
  technicalConditions,
  technicalConditionsEarthing,
  lowVoltageEarthingStandard,
  electricalVerificationStandard,
  lightningProtectionStandard,
  lightningConnectionStandard,
  lightningConductorStandard,
  itbBelowGroundWaterproofing,
  pmbcStandard,
  concreteExecutionStandard,
  masonryExecutionStandard,
  itbRoofCoverings,
  windowPerformanceStandard,
  itbWindowInstallation,
  waterInstallationStandard,
  surfaceHeatingInstallationStandard,
  ventilationAcceptanceStandard,
  itbTileFinishes,
  liquidWaterproofingStandard,
  itbWetAreaWaterproofing,
  dehnFoundationEarthing,
  hauffBuildingEntries,
  remmersWaterproofingSystem,
  ursaFoundationInsulation,
  aluprofShadingSystems,
}

final class StageGuidanceSourceReference {
  const StageGuidanceSourceReference({
    required this.key,
    required this.type,
    required this.revision,
    required this.urlValue,
    required this.verifiedOnIso,
  });

  final StageGuidanceSourceKey key;
  final StageGuidanceSourceType type;
  final String revision;
  final String urlValue;
  final String verifiedOnIso;

  Uri get url => Uri.parse(urlValue);
}

final class StageGuidanceDefinition {
  const StageGuidanceDefinition({
    required this.key,
    required this.stageKey,
    required this.relatedChecklistKeys,
    required this.sources,
  });

  final StageGuidanceKey key;
  final ProjectStageKey stageKey;
  final List<ChecklistTemplateKey> relatedChecklistKeys;
  final List<StageGuidanceSourceReference> sources;
}

abstract final class StageGuidanceCatalog {
  static const int contentVersion = 5;
  static const String verifiedOnIso = '2026-07-30';

  static List<StageGuidanceDefinition> forStage(ProjectStageKey? stageKey) {
    if (stageKey == null) return const <StageGuidanceDefinition>[];
    return _items
        .where((item) => item.stageKey == stageKey)
        .toList(growable: false);
  }

  static const List<StageGuidanceDefinition> _items = [
    StageGuidanceDefinition(
      key: StageGuidanceKey.planningScopeAndSurvey,
      stageKey: ProjectStageKey.planning,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.planningScopeAndBudget,
        ChecklistTemplateKey.existingBuildingSurvey,
        ChecklistTemplateKey.designDecisionsRegister,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _geodeticGuidance,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.planningAndGroundConditions,
      stageKey: ProjectStageKey.formalities,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.planningPermissionBasis,
        ChecklistTemplateKey.landTitleAndRoadAccess,
        ChecklistTemplateKey.designMap,
        ChecklistTemplateKey.soilResearch,
      ],
      sources: <StageGuidanceSourceReference>[
        _spatialPlanningGuidance,
        _geodeticGuidance,
        _geotechnicalRegulation,
        _eurocodeGeotechnicalDesign,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.designUtilitiesAndApprovals,
      stageKey: ProjectStageKey.formalities,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.houseDesignSelection,
        ChecklistTemplateKey.readyDesignAdaptation,
        ChecklistTemplateKey.utilityConnectionConditions,
        ChecklistTemplateKey.coordinatedBuildingDesign,
        ChecklistTemplateKey.buildingPermitOrNotification,
        ChecklistTemplateKey.additionalPermitsAudit,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _gunbProcedures,
        _gunbForms,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.legalConstructionStart,
      stageKey: ProjectStageKey.formalities,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.constructionManagerAppointment,
        ChecklistTemplateKey.constructionLog,
        ChecklistTemplateKey.constructionCommencementNotice,
        ChecklistTemplateKey.managerDocumentationHandover,
        ChecklistTemplateKey.preStartDocumentAudit,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _gunbForms,
        _electronicConstructionLog,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.siteLogisticsAndAccess,
      stageKey: ProjectStageKey.sitePreparation,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.siteLogisticsPlan,
        ChecklistTemplateKey.temporarySiteFence,
        ChecklistTemplateKey.heavyEquipmentGate,
        ChecklistTemplateKey.stabilizedSiteEntrance,
        ChecklistTemplateKey.toolStorageContainer,
        ChecklistTemplateKey.materialAndWasteZones,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _constructionSafetyRegulation,
        _pipConstructionChecklist,
        _gddkiaSiteAccess,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.temporaryUtilitiesAndFacilities,
      stageKey: ProjectStageKey.sitePreparation,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.temporaryConstructionPower,
        ChecklistTemplateKey.constructionWaterSupply,
        ChecklistTemplateKey.portableToilet,
        ChecklistTemplateKey.siteUtilitiesAndHazardsMarking,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionSafetyRegulation,
        _pipConstructionChecklist,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.siteSafetyAndEvidence,
      stageKey: ProjectStageKey.sitePreparation,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.temporarySiteFence,
        ChecklistTemplateKey.siteUtilitiesAndHazardsMarking,
        ChecklistTemplateKey.siteSafetySetup,
        ChecklistTemplateKey.preConstructionPhotoRecord,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _constructionSafetyRegulation,
        _pipConstructionChecklist,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.demolitionSafetyAndUtilities,
      stageKey: ProjectStageKey.demolition,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.demolitionHazardSurvey,
        ChecklistTemplateKey.utilityDisconnectionAndProtection,
        ChecklistTemplateKey.demolitionPlanAndWaste,
        ChecklistTemplateKey.neighborAndCommonAreaProtection,
        ChecklistTemplateKey.demolitionCompletionInspection,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _constructionSafetyRegulation,
        _pipConstructionChecklist,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.servicePenetrations,
      stageKey: ProjectStageKey.stateZero,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.underSlabSewerAndRisers,
        ChecklistTemplateKey.waterPenetration,
        ChecklistTemplateKey.powerPenetration,
        ChecklistTemplateKey.telecomPenetration,
        ChecklistTemplateKey.gateIntercomGardenReserve,
        ChecklistTemplateKey.heatPumpOutdoorReserve,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _hauffBuildingEntries,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.foundationGrounding,
      stageKey: ProjectStageKey.stateZero,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.foundationGrounding,
        ChecklistTemplateKey.continuityMeasurement,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditionsEarthing,
        _lowVoltageEarthingStandard,
        _electricalVerificationStandard,
        _lightningProtectionStandard,
        _lightningConnectionStandard,
        _lightningConductorStandard,
        _dehnFoundationEarthing,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.foundationWaterproofing,
      stageKey: ProjectStageKey.stateZero,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.horizontalVerticalWaterproofing,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _itbBelowGroundWaterproofing,
        _pmbcStandard,
        _remmersWaterproofingSystem,
        _ursaFoundationInsulation,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.drainageAndGroundLevels,
      stageKey: ProjectStageKey.stateZero,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.excavationFoundationLevels,
        ChecklistTemplateKey.drainage,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _itbBelowGroundWaterproofing,
        _ursaFoundationInsulation,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.concealedWorksEvidence,
      stageKey: ProjectStageKey.stateZero,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.concealedWorksPhotos,
        ChecklistTemplateKey.concreteDeliveryAndAcceptance,
        ChecklistTemplateKey.postFoundationSurvey,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _itbBelowGroundWaterproofing,
        _dehnFoundationEarthing,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.structuralShellChecks,
      stageKey: ProjectStageKey.shellOpen,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.shellStructuralAcceptance,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _concreteExecutionStandard,
        _masonryExecutionStandard,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.roofAndWeatherProtection,
      stageKey: ProjectStageKey.shellOpen,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.roofWeatherProtection,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _itbRoofCoverings,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.windowShadingPreparation,
      stageKey: ProjectStageKey.shellOpen,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.openingAndShadingPreparation,
      ],
      sources: <StageGuidanceSourceReference>[_aluprofShadingSystems],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.windowDoorInstallation,
      stageKey: ProjectStageKey.shellClosed,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.windowDoorAcceptance,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _windowPerformanceStandard,
        _itbWindowInstallation,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.closedShellMoistureControl,
      stageKey: ProjectStageKey.shellClosed,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.weatherTightnessAndMoisture,
        ChecklistTemplateKey.temporaryVentilationAndHeating,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _itbRoofCoverings,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.installationRoutesAndAccess,
      stageKey: ProjectStageKey.installations,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.installationCoordination,
        ChecklistTemplateKey.electricalInstallationRoutes,
        ChecklistTemplateKey.waterSewerHeatingRoutes,
        ChecklistTemplateKey.ventilationAndLowVoltageRoutes,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _waterInstallationStandard,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.installationTestsAndEvidence,
      stageKey: ProjectStageKey.installations,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.installationTests,
        ChecklistTemplateKey.concealedInstallationPhotos,
      ],
      sources: <StageGuidanceSourceReference>[
        _waterInstallationStandard,
        _electricalVerificationStandard,
        _surfaceHeatingInstallationStandard,
        _ventilationAcceptanceStandard,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.plasterAndScreedExecution,
      stageKey: ProjectStageKey.plaster,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.substrateInspection,
        ChecklistTemplateKey.plasterAndScreedExecution,
        ChecklistTemplateKey.floorHeatingCommissioning,
        ChecklistTemplateKey.plasterScreedAcceptance,
      ],
      sources: <StageGuidanceSourceReference>[
        _surfaceHeatingInstallationStandard,
        _itbTileFinishes,
        _technicalConditions,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.finishSubstratesAndHeating,
      stageKey: ProjectStageKey.finishing,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.finishMaterialsAndSamples,
        ChecklistTemplateKey.floorsWallsCeilings,
        ChecklistTemplateKey.joineryAndPainting,
      ],
      sources: <StageGuidanceSourceReference>[
        _surfaceHeatingInstallationStandard,
        _itbTileFinishes,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.wetAreaWaterproofing,
      stageKey: ProjectStageKey.finishing,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.wetAreaWaterproofing,
        ChecklistTemplateKey.systemsCommissioning,
        ChecklistTemplateKey.warrantiesAndManuals,
      ],
      sources: <StageGuidanceSourceReference>[
        _technicalConditions,
        _itbTileFinishes,
        _liquidWaterproofingStandard,
        _itbWetAreaWaterproofing,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.handoverAndOccupancy,
      stageKey: ProjectStageKey.handover,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.asBuiltDocumentation,
        ChecklistTemplateKey.asBuiltSurvey,
        ChecklistTemplateKey.testsCertificates,
        ChecklistTemplateKey.constructionCompletionNotice,
        ChecklistTemplateKey.defectsAndHandover,
      ],
      sources: <StageGuidanceSourceReference>[
        _constructionLaw,
        _gunbProcedures,
        _gunbForms,
        _geodeticGuidance,
      ],
    ),
  ];

  static const StageGuidanceSourceReference _constructionLaw =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.constructionLaw,
        type: StageGuidanceSourceType.regulation,
        revision: 'Prawo budowlane, tekst jednolity Dz.U. 2026 poz. 524',
        urlValue: 'https://api.sejm.gov.pl/eli/acts/DU/2026/524/text.pdf',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _gunbProcedures =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.gunbProcedures,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'GUNB, procedury budowlane',
        urlValue: 'https://www.gunb.gov.pl/strona/procedury-budowlane',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _gunbForms =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.gunbForms,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'GUNB, aktualne wzory wniosków i zawiadomień',
        urlValue:
            'https://www.gov.pl/web/gunb/'
            'wzory-wnioskow-zgloszen-i-zawiadomien',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _spatialPlanningGuidance =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.spatialPlanningGuidance,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'MRiT, reforma planowania przestrzennego',
        urlValue:
            'https://www.gov.pl/web/rozwoj-technologia/'
            'reforma-planowania-przestrzennego-2',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _geotechnicalRegulation =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.geotechnicalRegulation,
        type: StageGuidanceSourceType.regulation,
        revision: 'Rozporządzenie Dz.U. 2012 poz. 463',
        urlValue: 'https://eli.gov.pl/api/acts/DU/2012/463/text.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _eurocodeGeotechnicalDesign =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.eurocodeGeotechnicalDesign,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 1997-1:2025-10 i PN-EN 1997-2:2025-10',
        urlValue: 'https://sklep.pkn.pl/pn-en-1997-1-2025-10e.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _geodeticGuidance =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.geodeticGuidance,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'Budowlane ABC, czynności i opracowania geodezyjne',
        urlValue:
            'https://budowlaneabc.gov.pl/praktyczny-przewodnik-inwestora/'
            'wnioski-elektroniczne/czynnosci-i-opracowania-geodezyjne/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _electronicConstructionLog =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.electronicConstructionLog,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'GUNB, Elektroniczny Dziennik Budowy',
        urlValue: 'https://e-dziennikbudowy.gunb.gov.pl/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _constructionSafetyRegulation =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.constructionSafetyRegulation,
        type: StageGuidanceSourceType.regulation,
        revision: 'BHP podczas robót budowlanych, Dz.U. 2003 poz. 401',
        urlValue: 'https://eli.gov.pl/eli/DU/2003/401/ogl',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _pipConstructionChecklist =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.pipConstructionChecklist,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'PIP, lista kontrolna dla budowy',
        urlValue:
            'https://www.pip.gov.pl/publikacje/'
            'publikacje-dla-pracodawcow/'
            'bezpiecznie-i-zgodnie-z-prawem-lista-kontrolna-z-komentarezem',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _gddkiaSiteAccess =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.gddkiaSiteAccess,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'GDDKiA, zasady dotyczące zjazdów',
        urlValue: 'https://www.gov.pl/web/gddkia/zjazdy',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _technicalConditions =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.technicalConditions,
        type: StageGuidanceSourceType.regulation,
        revision:
            'Tekst jednolity Dz.U. 2022 poz. 1225 i wykaz zmian MRiT 2023-2024',
        urlValue:
            'https://budowlaneabc.gov.pl/praktyczny-przewodnik-inwestora/'
            'najwazniejsze-przepisy/warunki-techniczne/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _technicalConditionsEarthing =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.technicalConditionsEarthing,
        type: StageGuidanceSourceType.regulation,
        revision:
            'Warunki techniczne, § 184; tekst jednolity Dz.U. 2022 poz. 1225',
        urlValue: 'https://eli.gov.pl/api/acts/DU/2022/1225/text.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _lowVoltageEarthingStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.lowVoltageEarthingStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-HD 60364-5-54:2011/A1:2023-04',
        urlValue:
            'https://sklep.pkn.pl/'
            'pn-hd-60364-5-54-2011-a1-2023-04p.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _electricalVerificationStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.electricalVerificationStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-HD 60364-6:2016-07 z elementami dodatkowymi',
        urlValue: 'https://sklep.pkn.pl/pn-hd-60364-6-2016-07p.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _lightningProtectionStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.lightningProtectionStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN IEC 62305-3:2025-09, wersja angielska',
        urlValue: 'https://sklep.pkn.pl/pn-en-iec-62305-3-2025-09e.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _lightningConnectionStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.lightningConnectionStandard,
        type: StageGuidanceSourceType.standard,
        revision:
            'PN-EN IEC 62561-1:2023-12; strona PKN pokazuje zastąpione wydanie',
        urlValue: 'https://sklep.pkn.pl/normy/pn-en-62561-1-2017-07p.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _lightningConductorStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.lightningConductorStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN IEC 62561-2:2018-04 z poprawką AC:2020-01',
        urlValue: 'https://sklep.pkn.pl/pn-en-iec-62561-2-2018-04p.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference
  _itbBelowGroundWaterproofing = StageGuidanceSourceReference(
    key: StageGuidanceSourceKey.itbBelowGroundWaterproofing,
    type: StageGuidanceSourceType.officialGuidance,
    revision: 'ITB, część C, zeszyt 5, wydanie 2025',
    urlValue:
        'https://www.itb.pl/aktualnosci/'
        'izolacje-przeciwwilgociowe-i-wodochronne-czesci-podziemnych-budynkow/',
    verifiedOnIso: verifiedOnIso,
  );
  static const StageGuidanceSourceReference _pmbcStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.pmbcStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 15814+A2:2015-02',
        urlValue: 'https://sklep.pkn.pl/pn-en-15814-a2-2015-02e.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _concreteExecutionStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.concreteExecutionStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 13670:2011 z poprawką Ap1:2026-04',
        urlValue: 'https://sklep.pkn.pl/pn-en-13670-2011p.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _masonryExecutionStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.masonryExecutionStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 1996-2:2010',
        urlValue: 'https://sklep.pkn.pl/pn-en-1996-2-2010p.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _itbRoofCoverings =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.itbRoofCoverings,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'ITB, część C, zeszyt 1, wydanie 2024',
        urlValue: 'https://www.itb.pl/aktualnosci/pokrycia-dachowe/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _windowPerformanceStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.windowPerformanceStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 14351-1+A2:2016-10, wersja angielska',
        urlValue: 'https://sklep.pkn.pl/pn-en-14351-1-a2-2016-10e.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _itbWindowInstallation =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.itbWindowInstallation,
        type: StageGuidanceSourceType.officialGuidance,
        revision:
            'ITB, część B, zeszyt 6, wydanie 2016; '
            'źródło wskazane przez ITB w 2026',
        urlValue: 'https://www.itb.pl/odbiory/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _waterInstallationStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.waterInstallationStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 806-4:2010, wersja angielska',
        urlValue: 'https://sklep.pkn.pl/pn-en-806-4-2010e.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference
  _surfaceHeatingInstallationStandard = StageGuidanceSourceReference(
    key: StageGuidanceSourceKey.surfaceHeatingInstallationStandard,
    type: StageGuidanceSourceType.standard,
    revision: 'PN-EN 1264-4:2021-10, wersja angielska',
    urlValue: 'https://sklep.pkn.pl/pn-en-1264-4-2021-10e.html',
    verifiedOnIso: verifiedOnIso,
  );
  static const StageGuidanceSourceReference _ventilationAcceptanceStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.ventilationAcceptanceStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 12599:2013-04, wersja angielska',
        urlValue: 'https://sklep.pkn.pl/normy/pn-en-12599-2013-04e.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _itbTileFinishes =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.itbTileFinishes,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'ITB, część B, zeszyt 5, wydanie 2023',
        urlValue:
            'https://www.itb.pl/aktualnosci/'
            'okladziny-i-posadzki-z-plytek-ceramicznych/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _liquidWaterproofingStandard =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.liquidWaterproofingStandard,
        type: StageGuidanceSourceType.standard,
        revision: 'PN-EN 14891:2017-03',
        urlValue: 'https://sklep.pkn.pl/pn-en-14891-2017-03p.html',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _itbWetAreaWaterproofing =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.itbWetAreaWaterproofing,
        type: StageGuidanceSourceType.officialGuidance,
        revision: 'ITB, część C, zeszyt 6, wydanie 2023',
        urlValue:
            'https://www.itb.pl/aktualnosci/'
            'zabezpieczenia-wodochronne-pomieszczen-mokrych/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _dehnFoundationEarthing =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.dehnFoundationEarthing,
        type: StageGuidanceSourceType.systemDocumentation,
        revision: 'Poradnik DS162; zawiera także odniesienia do DIN 18014',
        urlValue:
            'https://www.dehn.pl/sites/default/files/media/files/'
            'ds162_uziomy_fundamentowe_pl.pdf',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _hauffBuildingEntries =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.hauffBuildingEntries,
        type: StageGuidanceSourceType.systemDocumentation,
        revision: 'Katalog systemowych przepustów do budynków',
        urlValue:
            'https://www.hauff-technik.pl/pl/kategoria/'
            'przepusty-do-budynkow-3/przepusty-do-budynkow-59',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _remmersWaterproofingSystem =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.remmersWaterproofingSystem,
        type: StageGuidanceSourceType.systemDocumentation,
        revision: 'Instrukcja systemowa hydroizolacji zewnętrznej MB 2K',
        urlValue: 'https://www.remmers.pl/pl/hydroizolacja-zewnetrzna-MB2K',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _ursaFoundationInsulation =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.ursaFoundationInsulation,
        type: StageGuidanceSourceType.systemDocumentation,
        revision: 'Strona zastosowania: izolacja ścian fundamentowych',
        urlValue: 'https://www.ursa.pl/pl-pl/zastosowania/sciany-fundamentowe/',
        verifiedOnIso: verifiedOnIso,
      );
  static const StageGuidanceSourceReference _aluprofShadingSystems =
      StageGuidanceSourceReference(
        key: StageGuidanceSourceKey.aluprofShadingSystems,
        type: StageGuidanceSourceType.systemDocumentation,
        revision: 'Kompendium wiedzy o systemach ALUPROF',
        urlValue:
            'https://aluprof.com/files/downloads/'
            'kompendium_wiedzy_o_systemach_aluprof_PL.pdf',
        verifiedOnIso: verifiedOnIso,
      );
}
