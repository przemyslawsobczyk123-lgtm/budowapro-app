import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 7, 21, 10);

  test('normalizes contact fields and keeps unique role and stage sets', () {
    final contact = Contact(
      id: ' contact-1 ',
      projectId: ' project-1 ',
      draft: ContactDraft(
        displayName: '  Instal-Pro Sp. z o.o. ',
        kind: ContactKind.company,
        roles: const <ContactRole>[
          ContactRole.electrician,
          ContactRole.electrician,
          ContactRole.generalContractor,
        ],
        stageIds: const <String>[' stage-2 ', 'stage-1', 'stage-2'],
        phone: ' +48 500 600 700 ',
        email: ' BIURO@INSTAL-PRO.PL ',
        taxId: ' 1234567890 ',
        note: '  Rozdzielnia i instalacja odgromowa. ',
        rating: 5,
      ),
      createdAt: now,
      updatedAt: now,
    );

    expect(contact.id, 'contact-1');
    expect(contact.displayName, 'Instal-Pro Sp. z o.o.');
    expect(contact.roles, <ContactRole>{
      ContactRole.electrician,
      ContactRole.generalContractor,
    });
    expect(contact.stageIds, <String>{'stage-1', 'stage-2'});
    expect(contact.email, 'biuro@instal-pro.pl');
    expect(contact.note, 'Rozdzielnia i instalacja odgromowa.');
  });

  test('requires at least one role and validates optional contact fields', () {
    expect(
      () => ContactDraft(
        displayName: 'Jan Kowalski',
        kind: ContactKind.person,
        roles: const <ContactRole>[],
      ),
      throwsArgumentError,
    );
    expect(
      () => ContactDraft(
        displayName: 'Jan Kowalski',
        kind: ContactKind.person,
        roles: const <ContactRole>[ContactRole.other],
        email: 'niepoprawny-adres',
      ),
      throwsArgumentError,
    );
    expect(
      () => ContactDraft(
        displayName: 'Jan Kowalski',
        kind: ContactKind.person,
        roles: const <ContactRole>[ContactRole.other],
        rating: 6,
      ),
      throwsRangeError,
    );
  });

  test('contact query normalizes search and requires a project', () {
    final query = ContactQuery(
      projectId: ' project-1 ',
      searchTerm: '  ELEKTRYK  ',
      role: ContactRole.electrician,
      stageId: ' stage-1 ',
    );

    expect(query.projectId, 'project-1');
    expect(query.searchTerm, 'elektryk');
    expect(query.stageId, 'stage-1');
    expect(() => ContactQuery(projectId: ' '), throwsArgumentError);
  });
}
