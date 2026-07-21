import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quote draft requires positive amount, validity and included scope', () {
    expect(
      () => _draft(included: const <QuoteScopeLine>[]),
      throwsArgumentError,
    );
    expect(
      () => _draft(
        receivedAt: DateTime.utc(2026, 7, 10),
        validUntil: DateTime.utc(2026, 7, 9),
      ),
      throwsArgumentError,
    );
    expect(
      () => _draft(amount: VatBreakdown.fromGross(_pln(0), VatRate.standard23)),
      throwsRangeError,
    );
  });

  test('same scope line cannot be both included and excluded', () {
    expect(
      () => _draft(
        included: <QuoteScopeLine>[
          QuoteScopeLine(label: 'Rozdzielnica elektryczna'),
        ],
        excluded: <QuoteScopeLine>[
          QuoteScopeLine(label: '  rozdzielnica   elektryczna '),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('accepted quote must reference exactly one converted cost', () {
    expect(
      () => _quote(status: ContractorQuoteStatus.accepted),
      throwsArgumentError,
    );
    expect(
      () => _quote(
        status: ContractorQuoteStatus.received,
        acceptedCostEntryId: 'cost-1',
      ),
      throwsArgumentError,
    );
    expect(
      _quote(
        status: ContractorQuoteStatus.accepted,
        acceptedCostEntryId: 'cost-1',
      ).acceptedCostEntryId,
      'cost-1',
    );
  });

  test('comparison shows included, excluded and unspecified scope', () {
    final first = _quote(
      id: 'quote-a',
      amountMinorUnits: 100000,
      included: <QuoteScopeLine>[
        QuoteScopeLine(label: 'Punkty elektryczne'),
        QuoteScopeLine(label: 'Rozdzielnica'),
      ],
      excluded: <QuoteScopeLine>[QuoteScopeLine(label: 'Pomiary koncowe')],
    );
    final second = _quote(
      id: 'quote-b',
      amountMinorUnits: 90000,
      included: <QuoteScopeLine>[QuoteScopeLine(label: 'punkty ELEKTRYCZNE')],
      excluded: <QuoteScopeLine>[QuoteScopeLine(label: 'Rozdzielnica')],
    );

    final comparison = QuoteComparison(<ContractorQuote>[first, second]);
    final rows = {for (final row in comparison.rows) row.label: row};

    expect(comparison.lowestPriceQuoteIds, <String>{'quote-b'});
    expect(
      rows['Punkty elektryczne']!.presenceByQuoteId,
      <String, QuoteScopePresence>{
        'quote-a': QuoteScopePresence.included,
        'quote-b': QuoteScopePresence.included,
      },
    );
    expect(
      rows['Rozdzielnica']!.presenceByQuoteId['quote-b'],
      QuoteScopePresence.excluded,
    );
    expect(
      rows['Pomiary koncowe']!.presenceByQuoteId['quote-b'],
      QuoteScopePresence.notSpecified,
    );
  });

  test('lowest price can be tied and is not treated as recommendation', () {
    final comparison = QuoteComparison(<ContractorQuote>[
      _quote(id: 'a'),
      _quote(id: 'b'),
    ]);

    expect(comparison.lowestPriceQuoteIds, <String>{'a', 'b'});
  });

  test('valid-until instant remains inclusive', () {
    final quote = ContractorQuote(
      id: 'quote-1',
      projectId: 'project-1',
      draft: ContractorQuoteDraft(
        contactId: 'contact-1',
        title: 'Elektryka',
        variantName: 'Standard',
        amount: VatBreakdown.fromGross(_pln(10000), VatRate.standard23),
        receivedAt: DateTime.utc(2026, 7, 1),
        validUntil: DateTime.utc(2026, 7, 31, 23, 59, 59, 999),
        includedScope: <QuoteScopeLine>[QuoteScopeLine(label: 'Okablowanie')],
      ),
      status: ContractorQuoteStatus.received,
      createdAt: DateTime.utc(2026, 7, 1),
      updatedAt: DateTime.utc(2026, 7, 1),
    );

    expect(quote.isExpiredAt(DateTime.utc(2026, 7, 31, 23)), isFalse);
    expect(quote.isExpiredAt(DateTime.utc(2026, 8, 1)), isTrue);
  });
}

ContractorQuoteDraft _draft({
  VatBreakdown? amount,
  DateTime? receivedAt,
  DateTime? validUntil,
  List<QuoteScopeLine>? included,
  List<QuoteScopeLine> excluded = const <QuoteScopeLine>[],
}) {
  return ContractorQuoteDraft(
    contactId: 'contact-1',
    title: 'Instalacja elektryczna',
    variantName: 'Standard',
    amount: amount ?? VatBreakdown.fromGross(_pln(100000), VatRate.standard23),
    receivedAt: receivedAt ?? DateTime.utc(2026, 7, 1),
    validUntil: validUntil ?? DateTime.utc(2026, 8, 1),
    includedScope:
        included ?? <QuoteScopeLine>[QuoteScopeLine(label: 'Robocizna')],
    excludedScope: excluded,
  );
}

ContractorQuote _quote({
  String id = 'quote-1',
  ContractorQuoteStatus status = ContractorQuoteStatus.received,
  String? acceptedCostEntryId,
  int amountMinorUnits = 100000,
  List<QuoteScopeLine>? included,
  List<QuoteScopeLine> excluded = const <QuoteScopeLine>[],
}) {
  return ContractorQuote(
    id: id,
    projectId: 'project-1',
    draft: ContractorQuoteDraft(
      contactId: 'contact-1',
      title: 'Instalacja elektryczna',
      variantName: id,
      amount: VatBreakdown.fromGross(
        _pln(amountMinorUnits),
        VatRate.standard23,
      ),
      receivedAt: DateTime.utc(2026, 7, 1),
      validUntil: DateTime.utc(2026, 8, 1),
      includedScope:
          included ?? <QuoteScopeLine>[QuoteScopeLine(label: 'Robocizna')],
      excludedScope: excluded,
    ),
    status: status,
    acceptedCostEntryId: acceptedCostEntryId,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}

Money _pln(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');
