import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
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
      return ContactDetails(contact: contact, visits: visits);
    });

final class ContactDetails {
  ContactDetails({required this.contact, required Iterable<SiteVisit> visits})
    : visits = List<SiteVisit>.unmodifiable(visits);

  const ContactDetails.missing() : contact = null, visits = const <SiteVisit>[];

  final Contact? contact;
  final List<SiteVisit> visits;

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
