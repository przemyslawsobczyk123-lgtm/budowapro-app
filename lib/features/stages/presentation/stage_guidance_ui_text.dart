import 'package:budowapro/features/stages/domain/stage_guidance.dart';
import 'package:budowapro/l10n/app_localizations.dart';

final class StageGuidanceContent {
  const StageGuidanceContent({
    required this.title,
    required this.timing,
    required this.summary,
    required this.checks,
    required this.questions,
  });

  final String title;
  final String timing;
  final String summary;
  final List<String> checks;
  final List<String> questions;
}

StageGuidanceContent stageGuidanceContent(
  AppLocalizations l10n,
  StageGuidanceKey key,
) {
  return switch (key) {
    StageGuidanceKey.servicePenetrations => StageGuidanceContent(
      title: l10n.guidanceServicePenetrationsTitle,
      timing: l10n.guidanceServicePenetrationsTiming,
      summary: l10n.guidanceServicePenetrationsSummary,
      checks: _lines(l10n.guidanceServicePenetrationsChecks),
      questions: _lines(l10n.guidanceServicePenetrationsQuestions),
    ),
    StageGuidanceKey.foundationGrounding => StageGuidanceContent(
      title: l10n.guidanceFoundationGroundingTitle,
      timing: l10n.guidanceFoundationGroundingTiming,
      summary: l10n.guidanceFoundationGroundingSummary,
      checks: _lines(l10n.guidanceFoundationGroundingChecks),
      questions: _lines(l10n.guidanceFoundationGroundingQuestions),
    ),
    StageGuidanceKey.foundationWaterproofing => StageGuidanceContent(
      title: l10n.guidanceFoundationWaterproofingTitle,
      timing: l10n.guidanceFoundationWaterproofingTiming,
      summary: l10n.guidanceFoundationWaterproofingSummary,
      checks: _lines(l10n.guidanceFoundationWaterproofingChecks),
      questions: _lines(l10n.guidanceFoundationWaterproofingQuestions),
    ),
    StageGuidanceKey.drainageAndGroundLevels => StageGuidanceContent(
      title: l10n.guidanceDrainageAndGroundLevelsTitle,
      timing: l10n.guidanceDrainageAndGroundLevelsTiming,
      summary: l10n.guidanceDrainageAndGroundLevelsSummary,
      checks: _lines(l10n.guidanceDrainageAndGroundLevelsChecks),
      questions: _lines(l10n.guidanceDrainageAndGroundLevelsQuestions),
    ),
    StageGuidanceKey.concealedWorksEvidence => StageGuidanceContent(
      title: l10n.guidanceConcealedWorksEvidenceTitle,
      timing: l10n.guidanceConcealedWorksEvidenceTiming,
      summary: l10n.guidanceConcealedWorksEvidenceSummary,
      checks: _lines(l10n.guidanceConcealedWorksEvidenceChecks),
      questions: _lines(l10n.guidanceConcealedWorksEvidenceQuestions),
    ),
    StageGuidanceKey.windowShadingPreparation => StageGuidanceContent(
      title: l10n.guidanceWindowShadingPreparationTitle,
      timing: l10n.guidanceWindowShadingPreparationTiming,
      summary: l10n.guidanceWindowShadingPreparationSummary,
      checks: _lines(l10n.guidanceWindowShadingPreparationChecks),
      questions: _lines(l10n.guidanceWindowShadingPreparationQuestions),
    ),
  };
}

String stageGuidanceSourceTypeLabel(
  AppLocalizations l10n,
  StageGuidanceSourceType type,
) => switch (type) {
  StageGuidanceSourceType.regulation => l10n.stageGuidanceSourceRegulation,
  StageGuidanceSourceType.standard => l10n.stageGuidanceSourceStandard,
  StageGuidanceSourceType.officialGuidance =>
    l10n.stageGuidanceSourceOfficialGuidance,
  StageGuidanceSourceType.systemDocumentation =>
    l10n.stageGuidanceSourceSystemDocumentation,
};

String stageGuidanceSourceTitle(
  AppLocalizations l10n,
  StageGuidanceSourceKey key,
) => switch (key) {
  StageGuidanceSourceKey.technicalConditions =>
    l10n.stageGuidanceSourceTechnicalConditions,
  StageGuidanceSourceKey.lowVoltageEarthingStandard =>
    l10n.stageGuidanceSourceLowVoltageEarthing,
  StageGuidanceSourceKey.lightningConnectionStandard =>
    l10n.stageGuidanceSourceLightningConnections,
  StageGuidanceSourceKey.lightningConductorStandard =>
    l10n.stageGuidanceSourceLightningConductors,
  StageGuidanceSourceKey.itbBelowGroundWaterproofing =>
    l10n.stageGuidanceSourceItbWaterproofing,
  StageGuidanceSourceKey.pmbcStandard => l10n.stageGuidanceSourcePmbcStandard,
  StageGuidanceSourceKey.dehnFoundationEarthing =>
    l10n.stageGuidanceSourceDehnEarthing,
  StageGuidanceSourceKey.hauffBuildingEntries =>
    l10n.stageGuidanceSourceHauffEntries,
  StageGuidanceSourceKey.remmersWaterproofingSystem =>
    l10n.stageGuidanceSourceRemmersWaterproofing,
  StageGuidanceSourceKey.ursaFoundationInsulation =>
    l10n.stageGuidanceSourceUrsaInsulation,
  StageGuidanceSourceKey.aluprofShadingSystems =>
    l10n.stageGuidanceSourceAluprofShading,
};

List<String> _lines(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}
