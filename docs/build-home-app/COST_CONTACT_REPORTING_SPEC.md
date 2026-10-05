# Cost contact assignment and reporting

## Goal

Allow one optional project contact (person or company) to be assigned to each
cost. Make the assignment visible in cost details and available as a budget
filter and report dimension, together with the existing stage, component and
payment-method dimensions.

## Functional contract

- A cost can reference zero or one contact from the same project.
- Both person and company contacts are selectable.
- Creating and editing a draft or confirmed cost preserves the assignment.
- Removing the selection removes only the cost-contact link.
- Archived contacts remain visible on costs already assigned to them.
- A contact referenced by a cost cannot be deleted; it can still be archived.
- The cost register can filter by a contact and by a missing contact.
- Budget reports group corrected effective amounts by contact and by payment
  method. Selecting a report row opens the matching cost register filter.
- Material, labor, mixed/unassigned, payment method, stage and supplier fields
  keep their existing meanings.

## Data design

Schema version 20 adds `cost_entry_contacts` with one row per cost and a
project-scoped foreign key to both `cost_entries` and `contacts`. The link uses
`ON DELETE CASCADE` for link cleanup when a cost, contact or complete project is
deleted. The contact repository rejects deleting a contact while the link is in
use, so users archive referenced contacts instead. Existing cost rows require no
migration or guessed assignment.

The domain exposes `contactId` on cost input. Repositories validate project
ownership, persist the link in the same transaction as the cost and resolve the
link in batches when reading pages.

## UX

- The cost form contains an optional `Osoba lub firma` selector populated from
  project contacts.
- Cost details show the current contact display name.
- The budget filter contains a contact selector and an unassigned-contact
  option.
- Reports add compact `Osoba / firma` and `Platnosc` dimensions.

## Acceptance tests

- Domain normalization and query propagation.
- Migration from schema 19 and fresh schema creation.
- Create, read, edit, filter, wrong-project rejection and delete protection.
- Report totals and drill-down for contact and payment method.
- Cost form selection and details rendering.
- Full `flutter analyze`, `flutter test` and `flutter build apk --debug` gates.
