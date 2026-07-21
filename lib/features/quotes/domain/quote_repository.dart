import 'package:budowapro/shared/models/page.dart';

import 'contractor_quote.dart';

abstract interface class QuoteRepository {
  Future<ContractorQuote> create({
    required String projectId,
    required ContractorQuoteDraft draft,
  });

  Future<ContractorQuote> update({
    required String projectId,
    required String quoteId,
    required ContractorQuoteDraft draft,
  });

  Future<ContractorQuote?> findById({
    required String projectId,
    required String quoteId,
  });

  Future<Page<ContractorQuote>> list(QuoteQuery query, PageRequest request);

  Future<ContractorQuote> reject({
    required String projectId,
    required String quoteId,
  });

  Future<QuoteAcceptanceResult> accept({
    required String projectId,
    required String quoteId,
    required QuoteCostTarget target,
  });

  Future<void> delete({required String projectId, required String quoteId});
}

final class QuoteQuery {
  factory QuoteQuery({
    required String projectId,
    String? searchTerm,
    String? contactId,
    String? stageId,
    Set<ContractorQuoteStatus> statuses = const <ContractorQuoteStatus>{},
  }) {
    return QuoteQuery._(
      projectId: _requiredText(projectId, 'projectId', 64),
      searchTerm: _optionalText(searchTerm, 'searchTerm', 120)?.toLowerCase(),
      contactId: _optionalText(contactId, 'contactId', 64),
      stageId: _optionalText(stageId, 'stageId', 64),
      statuses: Set<ContractorQuoteStatus>.unmodifiable(statuses),
    );
  }

  const QuoteQuery._({
    required this.projectId,
    required this.searchTerm,
    required this.contactId,
    required this.stageId,
    required this.statuses,
  });

  final String projectId;
  final String? searchTerm;
  final String? contactId;
  final String? stageId;
  final Set<ContractorQuoteStatus> statuses;
}

final class QuoteAcceptanceResult {
  const QuoteAcceptanceResult({
    required this.quote,
    required this.costEntryId,
    required this.createdCost,
  });

  final ContractorQuote quote;
  final String costEntryId;
  final bool createdCost;
}

final class QuoteNotFoundException implements Exception {
  const QuoteNotFoundException();
}

final class QuoteLockedException implements Exception {
  const QuoteLockedException();
}

String _requiredText(String value, String name, int maximumLength) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}

String? _optionalText(String? value, String name, int maximumLength) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return _requiredText(normalized, name, maximumLength);
}
