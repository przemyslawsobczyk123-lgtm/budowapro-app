import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/l10n/app_localizations.dart';

String technicalAlbumKindLabel(
  AppLocalizations l10n,
  TechnicalAlbumKind kind,
) => switch (kind) {
  TechnicalAlbumKind.beforeConcrete => l10n.technicalAlbumBeforeConcrete,
  TechnicalAlbumKind.beforeBackfill => l10n.technicalAlbumBeforeBackfill,
  TechnicalAlbumKind.beforePlaster => l10n.technicalAlbumBeforePlaster,
  TechnicalAlbumKind.beforeScreed => l10n.technicalAlbumBeforeScreed,
  TechnicalAlbumKind.beforeTiles => l10n.technicalAlbumBeforeTiles,
  TechnicalAlbumKind.asBuilt => l10n.technicalAlbumAsBuilt,
  TechnicalAlbumKind.custom => l10n.technicalAlbumCustom,
};

String technicalInstallationLabel(
  AppLocalizations l10n,
  TechnicalInstallationType type,
) => switch (type) {
  TechnicalInstallationType.structure => l10n.technicalInstallationStructure,
  TechnicalInstallationType.electrical => l10n.technicalInstallationElectrical,
  TechnicalInstallationType.water => l10n.technicalInstallationWater,
  TechnicalInstallationType.sewage => l10n.technicalInstallationSewage,
  TechnicalInstallationType.heating => l10n.technicalInstallationHeating,
  TechnicalInstallationType.ventilation =>
    l10n.technicalInstallationVentilation,
  TechnicalInstallationType.waterproofing =>
    l10n.technicalInstallationWaterproofing,
  TechnicalInstallationType.insulation => l10n.technicalInstallationInsulation,
  TechnicalInstallationType.grounding => l10n.technicalInstallationGrounding,
  TechnicalInstallationType.other => l10n.technicalInstallationOther,
};

String technicalPhotoLinkTypeLabel(
  AppLocalizations l10n,
  TechnicalPhotoLinkType type,
) => switch (type) {
  TechnicalPhotoLinkType.cost => l10n.technicalPhotoCostLink,
  TechnicalPhotoLinkType.decision => l10n.technicalPhotoDecisionLink,
  TechnicalPhotoLinkType.defect => l10n.technicalPhotoDefectLink,
  TechnicalPhotoLinkType.acceptanceProtocol => l10n.technicalPhotoProtocolLink,
};
