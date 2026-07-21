import 'dart:collection';

import 'package:budowapro/features/costs/domain/vat_breakdown.dart';

enum ContractorQuoteStatus { received, accepted, rejected }

enum QuoteCostTarget { planned, ordered }

enum QuoteScopePresence { included, excluded, notSpecified }

final class QuoteScopeLine {
  factory QuoteScopeLine({required String label, String? details}) {
    final normalizedLabel = _requiredText(label, 'label', 160);
    return QuoteScopeLine._(
      label: normalizedLabel,
      comparisonKey: _comparisonKey(normalizedLabel),
      details: _optionalText(details, 'details', 600),
    );
  }

  const QuoteScopeLine._({
    required this.label,
    required this.comparisonKey,
    required this.details,
  });

  final String label;
  final String comparisonKey;
  final String? details;
}

final class ContractorQuoteDraft {
  factory ContractorQuoteDraft({
    required String contactId,
    required String title,
    required String variantName,
    required VatBreakdown amount,
    required DateTime receivedAt,
    required DateTime validUntil,
    required Iterable<QuoteScopeLine> includedScope,
    Iterable<QuoteScopeLine> excludedScope = const <QuoteScopeLine>[],
    Iterable<String> attachmentIds = const <String>[],
    String? stageId,
    String? note,
  }) {
    if (amount.gross.isNegative || amount.gross.isZero) {
      throw RangeError.value(
        amount.gross.minorUnits,
        'amount',
        'must be positive',
      );
    }
    final receivedAtUtc = receivedAt.toUtc();
    final validUntilUtc = validUntil.toUtc();
    if (validUntilUtc.isBefore(receivedAtUtc)) {
      throw ArgumentError.value(
        validUntil,
        'validUntil',
        'must not be before receivedAt',
      );
    }
    final included = _scopeLines(includedScope, 'includedScope');
    if (included.isEmpty) {
      throw ArgumentError.value(
        includedScope,
        'includedScope',
        'must not be empty',
      );
    }
    final excluded = _scopeLines(excludedScope, 'excludedScope');
    final overlap = included.map((line) => line.comparisonKey).toSet()
      ..retainAll(excluded.map((line) => line.comparisonKey));
    if (overlap.isNotEmpty) {
      throw ArgumentError('A scope item cannot be included and excluded');
    }
    return ContractorQuoteDraft._(
      contactId: _requiredText(contactId, 'contactId', 64),
      title: _requiredText(title, 'title', 120),
      variantName: _requiredText(variantName, 'variantName', 80),
      amount: amount,
      receivedAtUtc: receivedAtUtc,
      validUntilUtc: validUntilUtc,
      includedScope: included,
      excludedScope: excluded,
      attachmentIds: _ids(attachmentIds, 'attachmentIds'),
      stageId: _optionalText(stageId, 'stageId', 64),
      note: _optionalText(note, 'note', 2000),
    );
  }

  const ContractorQuoteDraft._({
    required this.contactId,
    required this.title,
    required this.variantName,
    required this.amount,
    required this.receivedAtUtc,
    required this.validUntilUtc,
    required this.includedScope,
    required this.excludedScope,
    required this.attachmentIds,
    required this.stageId,
    required this.note,
  });

  final String contactId;
  final String title;
  final String variantName;
  final VatBreakdown amount;
  final DateTime receivedAtUtc;
  final DateTime validUntilUtc;
  final UnmodifiableListView<QuoteScopeLine> includedScope;
  final UnmodifiableListView<QuoteScopeLine> excludedScope;
  final UnmodifiableListView<String> attachmentIds;
  final String? stageId;
  final String? note;
}

final class ContractorQuote {
  factory ContractorQuote({
    required String id,
    required String projectId,
    required ContractorQuoteDraft draft,
    required ContractorQuoteStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? acceptedCostEntryId,
  }) {
    final acceptedCostId = _optionalText(
      acceptedCostEntryId,
      'acceptedCostEntryId',
      64,
    );
    if ((status == ContractorQuoteStatus.accepted) !=
        (acceptedCostId != null)) {
      throw ArgumentError(
        'Only an accepted quote must reference its converted cost',
      );
    }
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return ContractorQuote._(
      id: _requiredText(id, 'id', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      draft: draft,
      status: status,
      acceptedCostEntryId: acceptedCostId,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const ContractorQuote._({
    required this.id,
    required this.projectId,
    required this.draft,
    required this.status,
    required this.acceptedCostEntryId,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String projectId;
  final ContractorQuoteDraft draft;
  final ContractorQuoteStatus status;
  final String? acceptedCostEntryId;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  bool isExpiredAt(DateTime instant) =>
      status == ContractorQuoteStatus.received &&
      draft.validUntilUtc.isBefore(instant.toUtc());
}

final class QuoteComparisonRow {
  QuoteComparisonRow({
    required this.label,
    required Map<String, QuoteScopePresence> presenceByQuoteId,
  }) : presenceByQuoteId = UnmodifiableMapView<String, QuoteScopePresence>(
         Map<String, QuoteScopePresence>.of(presenceByQuoteId),
       );

  final String label;
  final UnmodifiableMapView<String, QuoteScopePresence> presenceByQuoteId;
}

final class QuoteComparison {
  factory QuoteComparison(Iterable<ContractorQuote> source) {
    final quotes = source.toList(growable: false);
    if (quotes.length < 2) {
      throw ArgumentError.value(source, 'source', 'must contain two quotes');
    }
    final projectId = quotes.first.projectId;
    final currency = quotes.first.draft.amount.gross.currencyCode;
    if (quotes.any(
      (quote) =>
          quote.projectId != projectId ||
          quote.draft.amount.gross.currencyCode != currency,
    )) {
      throw ArgumentError('Compared quotes must share project and currency');
    }
    final labels = <String, String>{};
    for (final quote in quotes) {
      for (final line in <QuoteScopeLine>[
        ...quote.draft.includedScope,
        ...quote.draft.excludedScope,
      ]) {
        labels.putIfAbsent(line.comparisonKey, () => line.label);
      }
    }
    final sortedKeys = labels.keys.toList(growable: false)
      ..sort((left, right) => labels[left]!.compareTo(labels[right]!));
    final rows = sortedKeys.map((key) {
      final values = <String, QuoteScopePresence>{};
      for (final quote in quotes) {
        final included = quote.draft.includedScope.any(
          (line) => line.comparisonKey == key,
        );
        final excluded = quote.draft.excludedScope.any(
          (line) => line.comparisonKey == key,
        );
        values[quote.id] = included
            ? QuoteScopePresence.included
            : excluded
            ? QuoteScopePresence.excluded
            : QuoteScopePresence.notSpecified;
      }
      return QuoteComparisonRow(label: labels[key]!, presenceByQuoteId: values);
    });
    final lowestMinorUnits = quotes
        .map((quote) => quote.draft.amount.gross.minorUnits)
        .reduce((left, right) => left < right ? left : right);
    return QuoteComparison._(
      quotes: UnmodifiableListView<ContractorQuote>(quotes),
      rows: UnmodifiableListView<QuoteComparisonRow>(rows.toList()),
      lowestPriceQuoteIds: UnmodifiableSetView<String>(
        quotes
            .where(
              (quote) =>
                  quote.draft.amount.gross.minorUnits == lowestMinorUnits,
            )
            .map((quote) => quote.id)
            .toSet(),
      ),
    );
  }

  const QuoteComparison._({
    required this.quotes,
    required this.rows,
    required this.lowestPriceQuoteIds,
  });

  final UnmodifiableListView<ContractorQuote> quotes;
  final UnmodifiableListView<QuoteComparisonRow> rows;
  final UnmodifiableSetView<String> lowestPriceQuoteIds;
}

UnmodifiableListView<QuoteScopeLine> _scopeLines(
  Iterable<QuoteScopeLine> source,
  String name,
) {
  final values = source.toList(growable: false);
  final keys = values.map((line) => line.comparisonKey).toSet();
  if (keys.length != values.length) {
    throw ArgumentError.value(source, name, 'contains duplicate labels');
  }
  if (values.length > 100) {
    throw ArgumentError.value(source, name, 'must not exceed 100 lines');
  }
  return UnmodifiableListView<QuoteScopeLine>(values);
}

UnmodifiableListView<String> _ids(Iterable<String> source, String name) {
  final values = source
      .map((value) => _requiredText(value, name, 64))
      .toList(growable: false);
  if (values.toSet().length != values.length) {
    throw ArgumentError.value(source, name, 'contains duplicate ids');
  }
  return UnmodifiableListView<String>(values);
}

String _comparisonKey(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

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
  if (normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}
