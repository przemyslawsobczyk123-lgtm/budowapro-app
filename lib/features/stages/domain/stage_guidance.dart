import 'package:budowapro/features/projects/domain/project_template.dart';

import 'stage_plan.dart';

enum StageGuidanceKey {
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
  technicalConditions,
  lowVoltageEarthingStandard,
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
  static const int contentVersion = 1;
  static const String verifiedOnIso = '2026-07-25';

  static List<StageGuidanceDefinition> forStage(ProjectStageKey? stageKey) {
    if (stageKey == null) return const <StageGuidanceDefinition>[];
    return _items
        .where((item) => item.stageKey == stageKey)
        .toList(growable: false);
  }

  static const List<StageGuidanceDefinition> _items = [
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
        _technicalConditions,
        _lowVoltageEarthingStandard,
        _lightningConnectionStandard,
        _lightningConductorStandard,
        _dehnFoundationEarthing,
      ],
    ),
    StageGuidanceDefinition(
      key: StageGuidanceKey.foundationWaterproofing,
      stageKey: ProjectStageKey.stateZero,
      relatedChecklistKeys: <ChecklistTemplateKey>[
        ChecklistTemplateKey.soilResearch,
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
