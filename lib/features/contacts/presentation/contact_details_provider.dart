import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/quotes/data/quote_providers.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/quotes/domain/quote_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ContactRecordKey = ({String projectId, String contactId});
typedef SiteVisitRecordKey = ({String projectId, String visitId});

final contactByIdProvider = FutureProvider.family<Contact?, ContactRecordKey>((
  ref,
  key,
) async {
  return (await ref.watch(
    contactRepositoryProvider.future,
  )).findById(projectId: key.projectId, contactId: key.contactId);
});

final siteVisitByIdProvider =
    FutureProvider.family<SiteVisit?, SiteVisitRecordKey>((ref, key) async {
      return (await ref.watch(
        siteVisitRepositoryProvider.future,
      )).findById(projectId: key.projectId, visitId: key.visitId);
    });

final contactDetailsProvider =
    FutureProvider.family<ContactDetails, ContactRecordKey>((ref, key) async {
      final contact = await ref.watch(contactByIdProvider(key).future);
      if (contact == null) return const ContactDetails.missing();
      final repository = await ref.watch(siteVisitRepositoryProvider.future);
      final visits = await repository.listForContact(
        projectId: key.projectId,
        contactId: key.contactId,
      );
      final quoteRepository = await ref.watch(quoteRepositoryProvider.future);
      final quotes = <ContractorQuote>[];
      var request = PageRequest(limit: PageRequest.maximumLimit);
      while (true) {
        final page = await quoteRepository.list(
          QuoteQuery(projectId: key.projectId, contactId: key.contactId),
          request,
        );
        quotes.addAll(page.items);
        final next = page.nextRequest;
        if (next == null) break;
        request = next;
      }
      return ContactDetails(contact: contact, visits: visits, quotes: quotes);
    });

final class ContactDetails {
  ContactDetails({
    required this.contact,
    required Iterable<SiteVisit> visits,
    Iterable<ContractorQuote> quotes = const <ContractorQuote>[],
  }) : visits = List<SiteVisit>.unmodifiable(visits),
       quotes = List<ContractorQuote>.unmodifiable(quotes);

  const ContactDetails.missing()
    : contact = null,
      visits = const <SiteVisit>[],
      quotes = const <ContractorQuote>[];

  final Contact? contact;
  final List<SiteVisit> visits;
  final List<ContractorQuote> quotes;

  List<SiteVisit> get plannedVisits {
    final result = visits
        .where((visit) => visit.status == SiteVisitStatus.planned)
        .toList(growable: false);
    result.sort((left, right) => left.startsAtUtc.compareTo(right.startsAtUtc));
    return result;
  }

  List<SiteVisit> get visitHistory {
    final result = visits
        .where((visit) => visit.isResolved)
        .toList(growable: false);
    result.sort((left, right) => right.startsAtUtc.compareTo(left.startsAtUtc));
    return result;
  }
}
