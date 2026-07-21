# BudowaPRO - implementation status

Last updated: 2026-07-21

## Current release

`R1 MVP Core - in progress`

## Completed

### Task 0.1 - product specification

- Functional specification defines 163 unique requirements.
- Implementation plan maps all 17 target screens to phases.
- P0, P1 and P2 boundaries are explicit.

### Task 0.2 - repository and architecture baseline

- Git repository initialized on `main`.
- Project-specific `AGENTS.md` added.
- ADR 0001 accepts local-first Clean Architecture.
- ADR 0002 accepts `go_router`, `flutter_riverpod` and five stateful branches.
- CI remains pending until the remote repository target is selected.

### Task 1.1 - Flutter application shell

- Flutter Android project created with application ID `pl.budowapro`.
- Minimum Android version set to API 28 (Android 9).
- Polish localization generated from ARB resources.
- Five primary destinations implemented with `StatefulShellRoute.indexedStack`.
- Riverpod owns router composition and disposal.
- Material 3 theme and Android launcher label added.
- Navigation widget test covers all destinations and branch switching.

### Task 1.2 - SQLite, migrations and local files

- SQLite database factory and versioned schema `v1` added.
- New and existing unversioned databases are covered by migration tests.
- Foreign keys are enabled and metadata queries use bound arguments.
- Failed database transactions roll back all writes.
- UTC date codec, project context, audit metadata and pagination contracts added.
- Project files use local `originals`, `previews` and `exports` directories.
- Imports reject path traversal and symbolic-link escapes, serialize duplicate targets,
  recover stale partial files and never overwrite completed files.

### Task 1.3 - projects and templates

- Schema `v2` adds project persistence and a tested migration from `v1`.
- Project domain validates type, template, stage, currency, area, budget and UTC dates.
- House construction and renovation templates use stable persisted stage keys.
- SQLite repository covers CRUD, archive, pagination and selected-project persistence.
- Multiple projects remain isolated and the selected project survives database reopening.
- Global selector, create/edit form and compact project overview are implemented.
- Delete confirmation reports linked records and local files before removing the project.
- Interrupted file deletion is recoverable and never removes the project record first.
- Currency, date format, planned dates, budget and current stage are editable.
- R0 maps one versioned template to each compatible project type. Project-local
  stage variants and custom checklist records are implemented in Task 3.1.

### Task 2.1 - financial domain

- `Money` stores signed SQLite `int64` minor units and a validated project currency.
- Arithmetic and VAT use checked `BigInt` intermediates; no persisted amount uses `double`.
- VAT 0%, 8% and 23% share one tested half-up rounding rule for net and gross input.
- Cost, offer and planned entry types are separate from financial and draft statuses.
- Quantity uses an integer scale; unit, payment method, source and attachment IDs are preserved.
- Returns and price/VAT changes are append-only corrections; decision impacts remain separate deltas.
- Summary calculation excludes drafts and offers, applies approved impacts and reports
  `difference = actual - planned`.
- Repository contracts require project context, paginate lists and reserve summaries for aggregate SQL.

### Task 2.2 - add and edit cost

- Schema `v3` persists cost entries, generic attachment metadata, many-to-many cost links,
  append-only revisions and financial corrections.
- The manual form supports cost, offer and plan entries, Polish gross amounts, VAT 0/8/23,
  quantity with unit, supplier, category, stage, payment method, note and entry date.
- Entries can be saved as drafts or confirmed, then edited, copied to a new draft and moved
  through valid payment statuses. Any entry can be deleted after explicit confirmation.
- Drafts preserve their selected target status across database reopening while remaining excluded
  from every financial summary.
- Confirmed financial values are immutable; detail and status changes are recorded in local history.
- Project currency becomes immutable after the first cost entry, and project deletion impact counts
  linked cost records before the destructive confirmation.
- Stage selection comes from persisted project stages, including custom stages. Category and supplier fields suggest values
  already used in the project while still allowing a new value to be entered immediately.
- The Android system picker imports allowed documents into private project storage without loading
  complete files into UI memory or requesting broad storage permission.
- File staging is recoverable. Only available attachments can be linked, and cost rows, attachment
  links and revisions are committed in one SQLite transaction. Streaming byte limits and recovery
  cover interrupted `.part` files and interrupted deletions.
- The budget branch provides a compact summary and direct access to add, inspect and edit entries.
- Validation preserves all entered values, and SQLite reopening tests verify exact amounts and status.

### Task 2.3 - cost register, search and filters

- The budget branch now loads a stable 30-row page and fetches the next page near the scroll edge.
  Search and filter state remains in the screen session and survives result reloads.
- Combined parameterized filters cover text, type, status, stage, category, supplier, date range,
  payment method, source and data-quality warnings. Sorting supports date, amount and name.
- One shared SQL predicate drives the result list, total count and aggregate summary, so the active
  plan, actual and difference always represent the same filter set. Drafts remain excluded from KPI.
- Search treats `%`, `_` and `\` as literal user input. Filter values are normalized and bounded before
  reaching the repository, and every query remains scoped to one project.
- Rows visibly flag confirmed costs with no document, no description or non-zero gross using VAT 0%.
  Each warning is also available as a filter.
- Stage, category and supplier options are loaded as distinct project-local values. Project template
  stages remain available even before their first cost entry.
- Repository tests combine all supported filters and verify SQL summaries, warning predicates,
  deterministic sorting, literal wildcard search and lazy pages over a 10,000-entry fixture.
- Widget tests cover debounced search, applying a filter without losing text, lazy page loading and
  warning layout on a 320 px viewport.
- Tag and warranty filters intentionally remain deferred until their persisted document/warranty
  models are introduced; the register does not expose controls that cannot query real data.

### Task 3.1 - stages and checklist templates

- Schema `v4` persists ordered project stages, checklist items and many-to-many links to generic
  local attachments. Project deletion impact now counts stage and checklist records as well as costs.
- House and renovation templates are seeded idempotently. The house template contains all 18 required
  `Stan 0` items, including water, power, telecom and optional gas penetrations, reserves for external
  systems, foundation grounding, continuity measurement, waterproofing and concealed-work evidence.
- Users can add and rename project-local stages, reorder the complete stage timeline, and edit stage
  status, planned dates and planned budget. Stable stage IDs preserve existing cost assignments.
- The Plan branch provides a compact horizontal stage selector, derived progress, blocked-item count,
  stage metadata and a risk-focused checklist. Loading, no-project, empty-checklist and error states are
  implemented, including a tested 320 px layout.
- Checklist items support five statuses, four importance levels, due date, responsible person, notes,
  skip risk, status reason and evidence policy. Custom checklist items can be added to every stage.
- A skipped item requires a reason. A system item requiring evidence cannot be completed or downgraded
  without a compatible local attachment or a documented waiver. Photo requirements accept only
  `image/*` attachments.
- Checklist evidence reuses private project storage. Startup cleanup preserves files linked to either
  costs or checklist items, and failed linking removes only the unlinked staged file.
- Custom stages are available immediately in the cost form and budget filters; labels are resolved from
  persisted stage records rather than shown as raw IDs.

### Task 3.2 - seven-day plan and local reminders

- Schema `v5` persists five schedule record types, directed dependencies, optional decision deadlines,
  append-only date-change history and app-level reminder preferences. Project deletion impact includes
  schedule records and all SQL remains project-scoped and parameterized.
- The Plan branch now switches between a compact seven-day agenda and the existing stage workspace.
  Agenda rows show time, type, status, responsible person and the first unresolved blocker, with direct
  navigation to the exact source record.
- Users can create and edit tasks, visits, deliveries, acceptances and payments, attach them to a stage,
  set all-day or timed dates, assignee, note, status, reminder lead and reschedule reason.
- Dependencies reject self-links and graph cycles. Each blocker can carry a decision deadline, resolved
  blockers remain visible, and every real schedule change appends old/new UTC instants and IANA zones.
- Reminder settings control event types, default lead and all-day wall time. Existing open reminders are
  synchronized after preference changes or permission grant.
- Android local notifications use zone-aware scheduling and survive reboot. Permission is requested only
  after a user action; denial or adapter failure never rolls back the saved plan.
- Notification payloads contain only `projectId` and `eventId`. Foreground taps and cold starts open the
  source record through a validated typed route.
- DST behavior, corrupt payloads, reminder degradation, persistence, dependency cycles, exact routing and
  agenda/settings/form layouts are covered, including a 320 px Android viewport.

### Task 3.3 - investor Start dashboard

- Start is a read-only projection over the selected project, costs, persisted stages/checklists and schedule;
  it does not add a dashboard table or duplicate source values.
- The current stage prefers a persisted in-progress or blocked stage and falls back to the stage configured
  on the project. The timeline shows every completed, active and future stage with derived checklist progress.
- Budget shows confirmed paid costs against the project budget and preserves negative remaining value as an
  explicit overrun. The 30-day plan combines open planned and actual entries in local calendar boundaries.
- Unpaid amount and count use confirmed cost records in `due` or `disputed` status. Drafts remain excluded
  from financial values but make a fresh project an active project rather than an empty one.
- Critical work is derived from unresolved high/critical checklist source records. Today's agenda is ordered
  by source event time and opens the exact task, visit, delivery, acceptance or payment record.
- Start has separate loading, error, no-project, fresh-project and populated states. Quick actions open a new
  cost, the budget register, the stages tab or a new schedule record.
- Returning to Start invalidates the Riverpod projection. Cost and schedule forms also refresh Start after a
  successful save, so persisted changes are visible without restarting the application.
- Stage checklist loading is batched per project rather than queried once per stage. Dashboard, DST, routing,
  missing-budget and layout tests cover a 320 px Android viewport.
- SQLite cost restoration now accepts exact VAT components produced from either net or gross input. This fixes
  non-invertible one-grosz rounding boundaries without accepting inconsistent stored amounts.

### Task 4.1 - contacts and site visits

- Schema `v6` persists project-scoped contacts, many-to-many roles, stage assignments and site-visit details.
  Contact search matches name, phone, e-mail and tax ID with bound SQL arguments; role and stage filters use
  indexed relation tables. The controller loads every stable page instead of truncating projects at 100 contacts.
- Contacts store person/company kind, one or more trade roles, optional phone, e-mail, NIP, note and 1-5 rating.
  They can be edited, archived/restored or deleted while unused. A contact referenced by visit history is protected
  by a restrictive foreign key and must be archived instead of deleting its evidence trail.
- A site visit extends one persisted schedule event in the same transaction. It stores contact, purpose, expected
  result, optional stage, reminder, result, agreements and the statuses planned, completed, cancelled or no-show.
  Completed visits require a result; every resolved status remains in contact history.
- Visit dates reuse IANA timezone handling, local reminders and append-only schedule date-change history. A reminder
  adapter failure never rolls back a saved visit. New generic schedule records no longer offer the contact-visit kind;
  legacy generic visits remain readable and editable.
- The More branch opens the searchable contacts workspace. Contact details require an explicit confirmation before
  launching the system phone or e-mail app. Contact visits opened from Plan, Start or a notification retain their
  specialist status/result view and edit through the visit form rather than the generic schedule form.
- Start derives up to three open visits in the next 30 local calendar days from existing schedule records. It adds no
  duplicate dashboard or calendar table. Contact names, phone numbers, e-mails, results and agreements are not logged.
- List, filters, details and confirmation flows are covered at 320 px. Visit photos and durable links to follow-up
  tasks remain dependent on the shared document/relation work planned for phases 4.3 and 7.1.

### Task 4.2 - contractor quotes and scope comparison

- Schema `v7` persists contractor quotes, ordered included/excluded scope lines and links to the generic private
  attachment store. Every record remains project-scoped and uses restrictive contact, stage and accepted-cost links.
- Quotes store contractor, main scope, price variant, exact gross/net/VAT values, received date, inclusive validity
  deadline, optional stage and note. Received quotes can be edited; rejected and accepted quotes preserve history.
- The system picker imports local PDF and image originals without broad storage permission. Quote links participate
  in interrupted-import recovery and unlinked-file cleanup; deleting a quote immediately removes newly orphaned files.
- The comparison workspace accepts two to four quotes and shows gross price plus every scope row as included,
  excluded or unspecified. Lowest price is marked only as a fact and is never promoted to an automatic recommendation.
- Acceptance creates exactly one confirmed planned entry in either `planned` or `ordered` status. Cost creation,
  attachment links, revision history and `accepted_cost_entry_id` are one SQLite transaction; retries return the
  existing cost instead of duplicating budget truth.
- More opens the complete quote workspace. Contractor details show their quote history and preselect the contractor
  for a new quote. Accepted quotes open the exact converted cost in the budget register.
- Domain, migration, repository, rollback, amount parser and widget tests cover the flow. List, form and comparison
  layouts are verified at a 320 px Android viewport. File preview/opening remains part of the document library.

### Task 4.3 - project document library

- Schema `v8` adds project-scoped document metadata and typed context links over the existing private attachment
  identity. Cost, checklist and quote links remain canonical and are projected into the same document details.
- The catalog supports receipt, invoice, quote, contract, WZ, protocol, warranty, instruction, map, photo and other
  types. Search and combined filters cover type, explicit or inferred stage, room, date range and warranty state.
- The shared system picker accepts the configured PDF, image, text and office formats without broad storage
  permission. SHA-256 runs outside the UI isolate and warns before retaining an identical project-local file.
- Originals are imported once under opaque storage keys and never modified. Bounded image and first-page PDF
  previews are separate derivatives; decode, render, resize and encoding work does not run on the UI isolate.
- The Build branch provides a 30-row paginated library, import flow, compact filters, metadata editor, warranty dates,
  complete relation list, PDF/image viewer, Android share action and explicit deletion confirmation.
- Metadata and editable stage/contact/room links save atomically. Deletion reports all links, removes original and
  preview files, cascades native/context links and remains recoverable after interruption while preserving source costs.
- Existing cost, quote and checklist evidence rows open the same catalog document and refresh after deletion. List,
  filter and warranty form layouts are verified at 320 px; original preservation, rollback and link cleanup are tested.
- Warranty reminder dates are persisted and displayed. Scheduling their Android notifications is deliberately paired
  with source deep links and preferences in `NOTIF-002` during Task 10.2 rather than creating duplicate schedule rows.

### Task 5.1 - budget report

- The budget report is a read-only SQL projection over the project budget, confirmed cost entries and append-only
  corrections. It adds no report table and never calculates financial truth from a paginated UI list.
- Plan, commitments, paid amount and remaining budget use exact minor units. Remaining means plan minus commitments,
  stays unavailable without a project plan and remains negative as an explicit budget overrun.
- Drafts, offers and planned-only entries are excluded. The financial fixture verifies corrections, payment status,
  unassigned costs, empty totals and exact agreement between headline values and breakdown slices.
- SQL groups commitments, paid amounts and record counts by stage, category, supplier and local-calendar month.
  Empty projects show the budget summary and a dedicated empty state without a zero-value chart.
- The compact report screen supports pull-to-refresh and a horizontally scrollable segmented dimension control.
  Stage labels resolve from persisted project stages, and the layout is verified at 320 px.
- Every headline and breakdown row opens the existing cost register with validated project-local filters. Drill-down
  includes exact `IS NULL` handling for rows without stage, category or supplier assignment.
- The More branch exposes the report without adding a sixth primary navigation destination.

## Verified baseline

```text
Flutter 3.44.4
Dart 3.12.2
flutter_riverpod 3.3.2
go_router 17.3.0
sqflite 2.4.3
sqflite_common_ffi 2.4.2
path_provider 2.1.6
file_picker 11.0.2
flutter_local_notifications 22.1.0
flutter_timezone 5.1.0
timezone 0.11.1
url_launcher 6.3.2
pdfrx 2.4.7
image 4.9.1
crypto 3.0.7
share_plus 12.0.2
```

The Android build passes with the known Flutter forward-compatibility warning
for plugins that still apply the classic Kotlin Gradle plugin (`file_picker`,
`flutter_timezone` and `share_plus`). Re-evaluate this when a package or Flutter is upgraded.

Quality gate:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

All commands passed on 2026-07-21 with 272 tests. Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Next task

Task 5.2 from `IMPLEMENTATION_PLAN.md`:

1. Export the actively filtered cost register to a local CSV file.
2. Build a versioned ZIP backup with a manifest, checksums and project attachments.
3. Restore only through a validated temporary directory and reject path traversal.
4. Keep export and backup work outside the UI isolate and avoid logging private paths or content.
5. Cover E2E-07 with attachments and a corrupt-backup rejection fixture.
