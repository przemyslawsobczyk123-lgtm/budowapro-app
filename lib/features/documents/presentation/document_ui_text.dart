import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/l10n/app_localizations.dart';

String documentTypeLabel(AppLocalizations l10n, ProjectDocumentType type) =>
    switch (type) {
      ProjectDocumentType.receipt => l10n.documentTypeReceipt,
      ProjectDocumentType.invoice => l10n.documentTypeInvoice,
      ProjectDocumentType.quote => l10n.documentTypeQuote,
      ProjectDocumentType.contract => l10n.documentTypeContract,
      ProjectDocumentType.deliveryNote => l10n.documentTypeDeliveryNote,
      ProjectDocumentType.protocol => l10n.documentTypeProtocol,
      ProjectDocumentType.warranty => l10n.documentTypeWarranty,
      ProjectDocumentType.instruction => l10n.documentTypeInstruction,
      ProjectDocumentType.map => l10n.documentTypeMap,
      ProjectDocumentType.photo => l10n.documentTypePhoto,
      ProjectDocumentType.other => l10n.documentTypeOther,
    };

String documentWarrantyLabel(
  AppLocalizations l10n,
  DocumentWarrantyState state,
) => switch (state) {
  DocumentWarrantyState.withoutWarranty => l10n.documentWarrantyWithout,
  DocumentWarrantyState.active => l10n.documentWarrantyActive,
  DocumentWarrantyState.expiringSoon => l10n.documentWarrantyExpiring,
  DocumentWarrantyState.expired => l10n.documentWarrantyExpired,
};

String documentRelationLabel(
  AppLocalizations l10n,
  DocumentRelationType type,
) => switch (type) {
  DocumentRelationType.cost => l10n.documentRelationCost,
  DocumentRelationType.stage => l10n.documentRelationStage,
  DocumentRelationType.checklistItem => l10n.documentRelationChecklist,
  DocumentRelationType.contact => l10n.documentRelationContact,
  DocumentRelationType.room => l10n.documentRelationRoom,
  DocumentRelationType.quote => l10n.documentRelationQuote,
  DocumentRelationType.decision => l10n.documentRelationDecision,
  DocumentRelationType.defect => l10n.documentRelationDefect,
  DocumentRelationType.device => l10n.documentRelationDevice,
};

String normalizedRoomId(String label) {
  final normalized = label
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9ąćęłńóśźż]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return normalized.isEmpty ? 'room' : normalized;
}
