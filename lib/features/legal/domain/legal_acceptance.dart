abstract final class LegalDocumentRevision {
  static const String current = '1.3';
}

abstract interface class LegalAcceptanceRepository {
  Future<bool> hasAcceptedCurrentTerms();

  Future<void> acceptCurrentTerms();
}
