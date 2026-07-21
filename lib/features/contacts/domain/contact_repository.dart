import 'package:budowapro/shared/models/page.dart';

import 'contact.dart';

abstract interface class ContactRepository {
  Future<Contact> create({
    required String projectId,
    required ContactDraft draft,
  });

  Future<Contact> update({
    required String projectId,
    required String contactId,
    required ContactDraft draft,
  });

  Future<Contact?> findById({
    required String projectId,
    required String contactId,
  });

  Future<Page<Contact>> list(ContactQuery query, PageRequest request);

  Future<Contact> setArchived({
    required String projectId,
    required String contactId,
    required bool isArchived,
  });

  Future<void> delete({required String projectId, required String contactId});
}

final class ContactNotFoundException implements Exception {
  const ContactNotFoundException();
}

final class ContactInUseException implements Exception {
  const ContactInUseException();
}
