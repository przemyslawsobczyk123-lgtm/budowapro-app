import 'package:budowapro/features/projects/domain/project_template.dart';

import 'stage_plan.dart';

enum StageGuidanceKey {
  planningAndGroundConditions,
  designUtilitiesAndApprovals,
  legalConstructionStart,
  siteLogisticsAndAccess,
  temporaryUtilitiesAndFacilities,
  siteSafetyAndEvidence,
  servicePenetrations,
  foundationGrounding,
  foundationWaterproofing,
  drainageAndGroundLevels,
  concealedWorksEvidence,
  windowShadingPreparation,
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
  static const int contentVersion = 3;
  static const String verifiedOnIso = '2026-07-26';

  static List<StageGuidanceDefinition> forStage(ProjectStageKey? stageKey) {
    if (stageKey == null) return const <StageGuidanceDefinition>[];
    return _items
        .where((item) => item.stageKey == stageKey)
        .toList(growable: false);
  }

  static const List<StageGuidanceDefinition> _items = [
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
      key: StageGuidanceKey.windowShadingPreparation,
      stageKey: ProjectStageKey.shellOpen,
      relatedChecklistKeys: <ChecklistTemplateKey>[],
      sources: <StageGuidanceSourceReference>[_aluprofShadingSystems],
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
