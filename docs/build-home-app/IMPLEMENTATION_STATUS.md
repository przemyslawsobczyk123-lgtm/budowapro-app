# BudowaPRO - implementation status

Last updated: 2026-08-01

## Current release

`R1 MVP Core - production candidate`

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
- GitHub remote is configured and mobile CI is green for commit `545377b`.

### Task 1.1 - Flutter application shell

- Flutter Android/iOS project created with application ID/bundle identifier
  `pl.budowapro`.
- Minimum Android version set to API 28 (Android 9).
- Minimum iOS version set to 15.5 for the locked ML Kit iOS pods.
- BudowaPRO app icon is installed in Android launcher resources and the iOS
  `AppIcon.appiconset`.
- iOS `PrivacyInfo.xcprivacy` is bundled with declarations for local disk-space
  and file-metadata checks; the app declares no tracking or collected data.
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

### Cross-platform compatibility

- Android keeps its Kotlin system integrations for contacts, storage capacity
  and Google ML Kit document scanning.
- iOS uses `CNContactPickerViewController` for one explicitly selected phone
  contact, `FileManager` for free-space checks and VisionKit for receipt scans.
- OCR uses the locked ML Kit text-recognition adapter on both mobile platforms.
- Local reminders use the Android notification channel on Android and the
  Darwin notification implementation on iOS.
- File picker, SQLite, local project storage, PDF viewing, sharing and legal
  screens stay in the shared Flutter layer.
- iOS source/build verification is pending on a Mac with Xcode; Windows cannot
  compile or sign an iOS target.

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
- Every entry independently records its cost component: material, labor, mixed or unassigned.
  Existing records migrate to unassigned instead of being guessed from their name or category.
- Quantity uses an integer scale; unit, payment method, source and attachment IDs are preserved.
- Returns and price/VAT changes are append-only corrections; decision impacts remain separate deltas.
- Summary calculation excludes drafts and offers, applies approved impacts and reports
  `difference = actual - planned`.
- Repository contracts require project context, paginate lists and reserve summaries for aggregate SQL.

### Task 2.2 - add and edit cost

- Schema `v3` persists cost entries, generic attachment metadata, many-to-many cost links,
  append-only revisions and financial corrections.
- The manual form supports cost, offer and plan entries, material/labor/mixed classification,
  Polish gross amounts, VAT 0/8/23, quantity with unit, supplier, category, stage, payment method,
  note and entry date.
- Entries can be saved as drafts or confirmed, then edited, copied to a new draft and moved
  through valid payment statuses. Any entry can be deleted after explicit confirmation.
- Drafts preserve their selected target status across database reopening while remaining excluded
  from every financial summary.
- The original confirmed financial value remains immutable in history. Editing a confirmed gross amount
  now adds an append-only price correction, while the budget register, summaries and exports use the effective total.
- Project currency becomes immutable after the first cost entry, and project deletion impact counts
  linked cost records before the destructive confirmation.
- Stage selection comes from persisted project stages, including custom stages. Category and supplier fields suggest values
  already used in the project while still allowing a new value to be entered immediately.
- The Android system picker imports allowed documents into private project storage without loading
  complete files into UI memory or requesting broad storage permission.
- File staging is recoverable. Only available attachments can be linked, and cost rows, attachment
  links and revisions are committed in one SQLite transaction. Streaming byte limits and recovery
  cover interrupted `.part` files and interrupted deletions.
- The budget branch provides a compact summary with planned and actual material/labor totals and
  direct access to add, inspect and edit entries.
- Validation preserves all entered values, and SQLite reopening tests verify exact amounts and status.

### Task 2.3 - cost register, search and filters

- The budget branch now loads a stable 30-row page and fetches the next page near the scroll edge.
  Search and filter state remains in the screen session and survives result reloads.
- Combined parameterized filters cover text, type, cost component, status, stage, category, supplier,
  date range, payment method, source and data-quality warnings. Sorting supports date, amount and name.
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
- House and renovation templates are seeded idempotently. The house template has 15 formalities,
  12 site-preparation tasks, 16 `Stan 0` tasks, 4 open-shell tasks, 3 closed-shell tasks,
  6 installation tasks, 6 finishing tasks and 5 handover tasks. Renovation has dedicated planning,
  demolition, installation, plaster/screed, finishing and handover tasks. Ground investigation is kept
  with formalities, while access, fencing, site facilities and temporary utilities form a dedicated stage
  before foundations.
- Users can add and rename project-local stages, reorder the complete stage timeline, and edit stage
  status, planned dates and planned budget. Stable stage IDs preserve existing cost assignments.
- The selected stage can be set as the persisted current project stage with one action. A second action
  marks the stage complete or reopens it; completion warns about unresolved checklist points and keeps the
  decision explicit instead of silently closing work.
- The Plan branch provides a compact horizontal stage selector, derived progress, blocked-item count,
  stage metadata and a risk-focused checklist. Loading, no-project, empty-checklist and error states are
  implemented, including a tested 320 px layout.
- Checklist items support five statuses, four importance levels, due date, responsible person, notes,
  skip risk, status reason and evidence policy. Custom checklist items can be added to every stage.
- Multi-select mode uses accessible checkboxes, a live selection count and one atomic completion action.
  Items that still require evidence remain open and are reported instead of silently bypassing policy.
- A skipped item requires a reason. A system item requiring evidence cannot be completed or downgraded
  without a compatible local attachment or a documented waiver. Photo requirements accept only
  `image/*` attachments.
- Checklist evidence reuses private project storage. Startup cleanup preserves files linked to either
  costs or checklist items, and failed linking removes only the unlinked staged file.
- Custom stages are available immediately in the cost form and budget filters; labels are resolved from
  persisted stage records rather than shown as raw IDs.
- A versioned offline guidance catalog adds compact `Stan 0` decision guides for service penetrations,
  foundation earthing, waterproofing, drainage/ground levels and concealed-work evidence. Each detail shows
  when to decide, inspection points, specialist questions, structured source metadata, content version and a clear
  boundary that it is not an execution design.
- Foundation-earthing guidance content version `5` separates a foundation earth electrode from a ring earth
  electrode and vertical electrodes. It explains that ring or vertical electrodes can be designed after the
  foundation is complete, but their material, layout and quantity require ground conditions, system function,
  corrosion assessment and measured results. It deliberately provides no universal conductor size, electrode
  count or acceptance resistance.
- The grounding source set now links directly to `Warunki techniczne` section 184, PN-HD 60364-5-54,
  PN-HD 60364-6, the current PN-EN IEC 62305-3:2025-09 record, PN-EN IEC 62561-1/-2 and separate system
  documentation. Manufacturer guidance remains visibly distinct from Polish regulations and standards.
- Six additional source-backed guides cover planning and ground conditions, coordinated approvals, lawful
  construction start, site access and logistics, temporary utilities/facilities, and site safety/evidence.
  The content remains collapsed and task-oriented rather than becoming a wall of legal text.
- The shell-open stage has a guide and an operational checklist for agreeing the exact window/shading detail
  before lintels. The catalog explicitly treats `5 cm`, conductor dimensions, PMBC/KMB, XPS, dimpled membrane
  and drainage as project/system-dependent rather than universal instructions.
- Source-backed guides now cover every built-in stage in both workflows, including renovation planning and
  demolition, open/closed shell, installations, plaster/screed, finishing and handover. New checklist rows
  are additive and keyed by stable template identifiers, so existing progress, notes and evidence remain intact.
- Formalities now explicitly send ground-investigation results to the adapting/structural designer before the
  slab, footings or another foundation solution is selected. Site preparation explicitly covers a temporary
  fence, equipment-sized gate and hardened route, plus a stable, secured sheet-metal shed or container.
- Built-in checklist risk text is now shown in full in the item editor. A separate optional override remains
  editable and the localized catalog text is not persisted into SQLite when the user saves without changing it.
- Users can add their own local position with a responsible person, note, skip risk, importance and evidence
  policy in one form. Guidance opens related existing checklist items instead of creating duplicates. Idempotent
  `Stan 0` reseeding is regression-tested not to replace user edits or custom items.
- The guidance panel remains collapsed by default so the checklist stays visible. A scrollable near-full-screen
  detail is verified at `320 x 640`; sources and editorial rules are recorded in `STAGE_GUIDANCE_SOURCES.md`.
- Schema `v10` adds an additive current-stage compatibility field. Existing child records are never rebuilt.
  On catalog refresh, completed ground-research progress is moved to formalities with its notes and evidence,
  while only an untouched legacy road/power/water item is replaced by the detailed site-preparation checklist.

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
- A new contact can import one explicitly selected phone entry through Android's system contact picker. The picker
  fills the editable name and phone fields only, stores no device contact identifier and requests neither
  `READ_CONTACTS` nor `WRITE_CONTACTS`; cancellation and picker failures preserve all manual form input.
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
- SQL groups commitments, paid amounts and record counts by stage, category, supplier, cost component
  and local-calendar month.
  Empty projects show the budget summary and a dedicated empty state without a zero-value chart.
- The compact report screen supports pull-to-refresh and a horizontally scrollable segmented dimension control.
  Stage labels resolve from persisted project stages, and the layout is verified at 320 px.
- Every headline and breakdown row opens the existing cost register with validated project-local filters. Drill-down
  includes exact `IS NULL` handling for rows without stage, category or supplier assignment.
- The More branch exposes the report without adding a sixth primary navigation destination.

### Task 5.2 - CSV export and local backup

- The cost register exports the exact active SQL filters and user-selected columns to semicolon CSV with UTF-8 BOM.
  Export pages are streamed, effective gross includes corrections, and user-authored cells are neutralized against
  spreadsheet formula injection before the Android share panel opens.
- CSV includes the cost component, and receipt/invoice OCR review assigns it per detected line before drafts are saved.
- Backup format `budowapro-backup` version `1` contains a consistent `VACUUM INTO` snapshot at
  `database/budowapro.db`, project originals/previews/exports, an exact manifest and SHA-256 catalog. Hashing,
  ZIP creation, inspection and extraction run outside the UI isolate.
- Restore copies a selected ZIP into private storage once, verifies its full hash, preflights the central directory
  and rejects duplicate, encrypted, symbolic-link, traversal, unknown-compression and oversized entries. Extraction
  writes only allowlisted paths through byte-bounded streams and verifies every payload hash.
- Candidate SQLite validation requires the current schema version, exact schema fingerprint from a clean reference
  database, integrity, foreign keys, bounded project/attachment counts and safe attachment storage keys. Available
  attachment files must agree with both database sizes/hashes and the ZIP catalog.
- Android `StatFs` checks free application storage before extraction. Active SQLite and project files are swapped
  only under maintenance after staging passes. A checksummed two-slot journal retains old data through promotion,
  rolls back interrupted/corrupt states at startup and finalizes committed data only after another database check.
- The More branch opens the compact `Kopia zapasowa i dane` screen. It explains full local scope, opens system save
  and file-pick panels only on user action, previews date/version/project/file/size metadata and requires a separate
  destructive confirmation before restore. Loading, success and private error states fit a 320 px viewport.
- E2E-07 creates a project cost linked to a hashed image, backs it up, mutates database/file/external ZIP state and
  restores the original project, exact financial total, relation and attachment. Corrupt checksum, traversal,
  duplicate path, encrypted flag, excessive entry count, low-storage and interrupted-journal fixtures are rejected
  without replacing active data.

### Task 6.1 - scanner and local OCR adapter

- The Start quick actions open a project-scoped receipt screen. Opening it does not invoke a plugin; only explicit
  scan or import actions can start Google Document Scanner or the narrow JPG/PNG/WEBP/PDF file picker.
- `google_mlkit_document_scanner 0.5.0` is hidden behind a receipt source adapter. It requests one user-approved JPEG
  with edge detection, crop, rotation, filters and gallery import. Native cancellation returns to idle, and scanner
  startup failure exposes local file import without adding camera or broad storage permissions.
- `google_mlkit_text_recognition 0.16.0` uses the bundled Latin model. OCR runs on a private project original, never
  on the external picker/scanner source. The scanner temporary is removed after staging.
- Existing attachment storage keeps the unchanged original, SHA-256 and a bounded preview. Attachment rows now
  retain `scanner` or `file_picker`; missing preview or staging failure compensates the unlinked row and files.
- Image originals go directly to OCR. Imported PDFs render only the first page into a bounded temporary JPEG through
  existing `pdfrx`; the derivative is deleted after every success or failure.
- OCR output is normalized and bounded to 32,000 characters, 240 lines and 240 characters per line before reaching
  presentation. The provisional parser extracts seller, date, document number, final total, VAT lines and item lines
  as text only. It does not construct `Money`, infer financial truth or run duplicate detection.
- Recognition failure preserves the current private attachment for retry. Explicit discard or screen exit removes
  the unlinked original and preview; startup recovery handles process death. Cleanup failures remain private and
  become a controlled storage state.
- Idle, processing, result and fallback/error states are localized and tested at 320 px. The result is explicitly
  marked `Budżet bez zmian`; Task 6.1 never calls `CostRepository`, creates a cost or changes a report total.
- The package wrappers are community maintained and remain replaceable behind data-layer interfaces. Google Play
  services may download the scanner component on first use; local image/PDF import remains the supported fallback.

### Task 6.2 - reviewed OCR and financial drafts

- ML Kit line confidence is retained through candidate extraction. A non-empty field or item below `0.85` remains
  blocked until the user edits it or explicitly confirms the OCR value.
- The review screen supports seller, date, document number, receipt total, item name, gross amount and VAT correction.
  Users can add, remove, merge and split item lines. Dates and monetary values use strict domain parsers; persisted
  amounts remain integer minor units.
- OCR never assigns VAT silently. Every extracted item keeps VAT unreviewed until the user selects `0%`, `8%` or `23%`
  or explicitly confirms the visible rate. Review validation mirrors financial limits for text length, 240 positions
  and the combined `Money` range.
- The item sum must match the receipt total. A mismatch is visible and needs a separate acknowledgement that is reset
  after any relevant edit.
- Duplicate checks run before posting and again inside the write transaction. They compare the current attachment,
  SHA-256 and normalized seller/date/total/currency signature. Hash or signature matches can be saved only after a
  separate warning action; the same attachment can never be posted twice.
- Schema `v9` adds project-scoped `receipt_imports` as the durable receipt header and duplicate audit record. One
  transaction writes that header, receipt document metadata, every `draft` cost, attachment links and append-only cost
  revisions. Any line failure rolls back the complete batch.
- OCR-created costs use source `receiptOcr`, lifecycle `draft` and status `planned`. They do not affect actual or planned
  budget summaries until the existing draft approval flow publishes them.
- A successful save keeps one shared receipt document and opens the existing filtered drafts view. Save failures retain
  the corrected data and private source in the current session. No OCR text, seller, amount, hash or private path is
  logged.
- Item cards use a lazy sliver list up to the 240-position boundary. Widget coverage includes a 320 px viewport at
  200% text scaling, low-confidence and VAT confirmation, explicit save, duplicate override, merge refresh and saved
  state. Repository coverage proves multi-line atomicity, duplicate behavior and rollback.
- Real-world scan regressions are covered with anonymized OCR fixtures. The parser ignores system identifiers that
  resemble dates, joins product names with following quantity/price rows, reads totals split after `SUMA PLN`, and
  excludes payment/VAT summary rows from item candidates.
- The same local flow now accepts a one-page purchase invoice. It prefers the issue date, reads `FAKTURA Nr`, and ranks
  gross invoice totals above a paid `Pozostało do zapłaty: 0,00` balance. Imported multi-page PDFs still OCR only the
  first page, matching the Task 6.1 image-preparation boundary.
- Review now labels the document total separately from the calculated item sum and shows field-specific validation.
  An explicit action can copy a valid item sum into a missing document total or replace unreliable OCR rows with one
  editable document cost. VAT remains unconfirmed after replacement and still requires a user decision.
- Financial VAT storage currently supports only `0%`, `8%` and `23%`. Adding Polish `5%`, exempt and not-applicable
  rates requires a separate schema migration; OCR must not silently map those rates to `23%`.

### Task 6.3 - project capture inbox

- The local capture inbox accepts project-scoped photos, documents, voice files, notes, costs, tasks, decisions and
  defects. The global quick action waits for the selected project before opening the composer and also links directly
  to the existing receipt/invoice OCR flow.
- Attachments selected through the system picker are copied into private project storage before a capture row is
  created. Cancellation creates nothing; failed persistence compensates the staged file.
- Open and classified captures are paged independently, filterable by type and visible from Start and More with a
  derived open-count badge. Loading another page never materializes the complete inbox.
- Classification is transactional. Photos/documents become documentation records, costs become excluded cost drafts
  and tasks become local schedule events. Dashboard and destination providers are invalidated only after success.
- Notes, decisions and defects are promoted transactionally into the local journal module described below. The
  original capture remains the source record and the journal entry stores its source id, so the inbox history can
  be audited without duplicating a cost or schedule event.
- Merge is available only where all source data can be retained. Cost and task merge is rejected in both UI and the
  repository so a second amount or schedule cannot be lost.
- Reject removes the capture and then discards only attachments that are no longer linked. Rollback coverage proves
  that a failed status update cannot leave a target cost behind.
- The inbox, composer, editor and merge picker are localized, scrollable and covered at a 320 px viewport and 200%
  text scaling.

### Task 7.1 - local construction diary

- SQLite schema `v12` adds journal entries, attachments, typed links and immutable revision snapshots. Existing
  v11 and older databases migrate forward without losing project data; backup fixtures validate the new tables
  and older migration paths.
- The journal supports daily entries, notes, decisions, defects and scope changes. Each record has an occurrence
  date, type, status, optional stage/person, content fields, due date, attachments and optional cost/time delta.
- `/diary` is available from More. It provides a chronological, paged list with type filters and search, a focused
  form, detail view, status changes and revision history. The form is scrollable and supports local file staging.
- Classified note, decision and defect captures now create a journal record in the same SQLite transaction. Their
  local attachments are also catalogued as documentation records, so the same evidence can be opened from the
  document library without uploading it.
- Stage and contact references are validated against the active project before persistence. Journal text and revision
  snapshots remain local and are not sent to logs.

### Task 7.2 - decisions and auditable deltas

- SQLite schema `v13` adds the approving contact, approval time and a relation purpose that distinguishes context
  from records blocked by a decision. The v12 migration is covered directly; legacy approved/implemented rows without
  an auditable person and time return to `pending` instead of affecting reports silently.
- Decision and scope-change forms accept signed PLN and day deltas, an optional decision maker and multiple blocked
  schedule tasks. Blocked tasks remain typed project links and open from decision details.
- Approval is a dedicated action. It requires a selected option and an existing project contact, stores person/time,
  creates a revision and includes the decision in aggregates. A normal status edit cannot manufacture approval.
- Editing approval-sensitive data after approval appends another immutable revision, clears approval and returns the
  current version to `proposal`. The previously approved snapshot is preserved.
- The budget report keeps the project plan unchanged and shows approved decision delta plus adjusted plan separately.
  Committed and paid totals still contain only confirmed costs and corrections. Proposed/rejected decisions contribute
  zero; approved and implemented decisions contribute exactly once.

### Task 9.1 - technical evidence albums

- SQLite schema `v14` adds project-scoped technical albums, technical photo metadata and normalized tags. The direct
  v13 migration, current schema fingerprint and previous-schema backup restore are covered without losing data.
- The technical library is available from Build and More. It provides albums for evidence before concrete, backfill,
  plaster, screed and tiles, plus as-built and custom albums. Photos are paged in groups of 30 and searchable by title,
  description, zone or tag, with stage, installation and tag filters.
- Every technical photo indexes one existing private attachment instead of copying the image. Metadata includes capture
  date, stage, room/zone, installation type, contractor, description and up to 12 normalized tags.
- A photo can be linked as checklist evidence in the same SQLite transaction that writes document metadata, technical
  metadata and tags. When no stage is selected explicitly, the checklist stage becomes the photo stage so filtering
  and audit context remain consistent.
- Album creation, image import, metadata editing and details are localized and usable at 320 px and 200% text scaling.
  A physically missing original or preview has a controlled fallback while retained metadata remains readable.
- Repository coverage proves atomic rollback for invalid media and paginates a 500-photo fixture without materializing
  the complete collection. Startup attachment recovery now preserves files linked only to the journal or technical
  documentation.
- Task 9.1 intentionally completes checklist evidence first. Durable links from a photo to a cost, decision, defect and
  acceptance protocol remain in the next PUNCH/linking slice rather than being stored as misleading text labels.

### Task 9.2 - punch list, acceptance protocols and typed evidence links

- SQLite schema `v15` extends journal-backed defects with severity, room/zone and explicit closure evidence rules.
  It also adds resolution-photo links, acceptance protocols, protocol-defect links, signed protocol attachments and
  typed technical-photo links. The direct v14 migration, current fingerprint and previous-schema backup fixture are
  covered without deleting old journal defects.
- `/punch` is available from More and from project quick actions. It provides separate defect and protocol views,
  open/critical/overdue counters, search, multi-select status/severity filters and stage, room, responsible-person and
  overdue filters. Lists remain paged in groups of 30.
- Defects support severity, stage, room, responsible contact, report and resolution photos, due date and the statuses
  open, in progress, recheck, fixed and closed. Closure is rejected transactionally when a required after-photo or a
  linked signed protocol is missing. The older journal screen delegates defect saves/status changes to the same
  repository, so the evidence rule cannot be bypassed through that route.
- Acceptance protocols select multiple defects, stage, room and contractor; signed status requires a local PDF or
  image attachment. The app can generate and share a local PDF summary with embedded Roboto for Polish characters,
  defect rows and signature lines. The PDF states that an unsigned generated copy is not itself a signed protocol.
- Technical photos now link through validated typed relations to a cost, decision/scope change, defect and acceptance
  protocol. The edit form preserves existing links and details open the exact related record. Cross-project or wrong-
  type targets roll back the complete photo save.
- Attachment recovery recognizes report photos, resolution photos and signed protocols, so startup cleanup cannot
  remove live evidence. Punch UI coverage includes 320 px and 200% text scaling; PDF tests verify the `%PDF` artifact
  and deletion of temporary exports after sharing.

### Task 8.1 - rooms and finish choice cards

- SQLite schema `v17` adds project-scoped rooms, finish choices, price variants, durable choice outputs, typed source
  links and many-to-many contact links. The direct v16 migration, schema fingerprint, backup migration and project
  deletion impact are covered without inferring room identity from free-text labels.
- Rooms store a stable ID, name, floor/zone, finish standard, dimensions in integer millimetres, optional planned
  budget and note. The paged/searchable room list shows aggregate planned budget, linked actual cost and open choices.
- A room card shows plan, actual, remaining budget, open decisions, materials, teams, technical photos and open
  defects. Actual value reads confirmed source costs and corrections; planned costs and drafts do not inflate it.
- Choice cards store quantity as a scaled integer, unit, waste basis points, order deadline, note and up to eight
  variants with supplier, code and gross unit price. Quantity with waste and estimated gross use checked integer/
  `BigInt` arithmetic rather than floating point.
- Selecting a variant requires an explicit confirmation. A selected choice can separately create one local planned
  material-cost draft after the user selects VAT, and one journal decision. Durable output links prevent accidental
  duplicates; neither action places an order or changes actual spending.
- The relation manager uses compact tabs and checkboxes to link existing costs, decisions, technical photos, defects
  and contacts. Reassigning a source record from another room requires confirmation; source rows remain owned by
  their original modules and deleting a room removes only room cards and links.
- Forms, detail cards and relation tabs are localized and tested at 320 px and 200% text scaling. The `MAT` module
  now owns real material records, delivery/return statuses and creation of the material output.

### Task 8.2 - materials, deliveries and returns

- SQLite schema `v18` adds project-scoped material, partial-delivery and return records. Quantities use exact integer
  microunits, and money remains integer minor units; no floating-point values enter persistence or summaries.
- A material can be linked independently to a stage, room, supplier contact, cost and receipt/invoice document. The
  register supports search, status filters and pagination, and its summary shows ordered value, pending refunds,
  delayed items, overdue returns and open deliveries.
- Delivery records track expected and actual dates, quantity, WZ document, supplier contact, shortage, damage and a
  reminder preference. Overdelivery requires explicit user confirmation and raises the ordered quantity to the
  confirmed delivered total rather than silently corrupting stock state.
- Return records track quantity, deadline, expected and actual refund, receipt/document and a reminder preference.
  The repository normalizes a confirmed actual refund when no estimate existed and validates every linked record as
  belonging to the same project.
- A selected room variant can now create one explicit material proposal with waste-adjusted quantity, room link,
  estimated gross value and existing planned-cost link. Durable output identity prevents duplicate proposals; the
  action does not place an external order.
- OCR review now assigns one document stage and requires every saved row to be classified as material, labor or
  mixed. A bulk selector applies a component to all rows while preserving per-row edits. Stage and component are
  independent reporting dimensions; mixed values are never guessed into an artificial 50/50 split.
- Forms, details and the material register are localized and covered at 320 px with 200% text scaling. Database,
  backup-migration, repository, ROOM output and presentation tests cover the new records. Android notification
  scheduling for delivery and return reminders remains deliberately paired with deep links in `NOTIF-002`.

### Production privacy and legal readiness

- The More branch now exposes an offline `Privacy and law` center with an in-app privacy policy, terms of use,
  privacy status/controls and open-source licenses. Legal documents are split into expandable sections and remain
  usable at 320 px with 200% text scaling.
- The privacy policy describes actual local project data, user-initiated export, retention/deletion, the lack of an
  account/backend/ads/first-party analytics, and the ML Kit metrics exception. It does not claim that OCR text or
  document images are uploaded to Google.
- The terms include a construction-safety boundary, mandatory professional verification, OCR review, backup
  responsibility and a clause preserving mandatory consumer rights.
- Publisher name, privacy contact, public privacy-policy URL and public support URL are build-time values. Android `preReleaseBuild`
  depends on a validation task and fails when metadata is missing, malformed, local-only or points to a PDF; no legal
  fallback identity is injected into the app binary. The draft public pages use the owner data available for this
  release and must be confirmed against the store accounts. A separate CI utility verifies that the configured public
  URL responds with HTML.
- Android API 36 is the explicit compile/target level. Automatic cloud backup is disabled and both legacy and Android
  12+ extraction rules exclude private app files from cloud and device-transfer backups.
- Privacy settings now provide a phrase-confirmed action for deleting all local data. It clears the database, project
  files and private caches, then returns the app to an empty-project state.
- `PRIVACY_AND_GOOGLE_PLAY_RELEASE.md` records the provisional ML Kit Data safety mapping, permission inventory,
  merged-manifest distinction, unencrypted manual ZIP warning, release command and remaining Play Console/signing
  actions. Google Play still requires a public policy URL even though the complete policy is also available inside
  the APK.

### Production hardening and Android release

- Release signing is fail-closed. A complete `BUDOWAPRO_UPLOAD_*` environment set takes precedence over ignored
  `android/key.properties`; mixed sources cannot select a different key. The release helper also compares the
  configured certificate SHA-256 with the keystore and final AAB. No debug-key fallback is allowed.
- `tool/release/build_android_release.dart` provides one reproducible Android release path. It requires a clean Git
  worktree by default, verifies the public HTML policy and support page, runs all quality gates, builds a signed/obfuscated AAB,
  verifies its signature, enforces an exact permission allowlist and checks AAB configuration, 64-bit ELF LOAD
  segments, a universal APK and `zipalign -P 16` with a pinned SHA-256-checked bundletool.
- Each successful release archives the AAB SHA-256, commit, R8 mapping, Dart obfuscation map, split Dart symbols and
  available native symbol tables under `build/releases/<version>/<UTC timestamp>/`.
- Release R8 and resource shrinking are explicit. Narrow `-dontwarn` rules cover only the four optional ML Kit text
  script models that the Latin receipt recognizer does not package; the release helper has regression coverage for
  this configuration.
- The local database enables SQLite `secure_delete`. App-owned OCR, preview, export, share, backup and restore
  temporary directories are atomically detached at startup and recursively removed after the first frame, so a
  large interrupted restore cannot block app startup. Error logging never includes exception text, private paths or
  stack traces, and notification content is hidden from the lock screen.
- OCR images and local document previews now enforce regular-file, size, signature, format and decoded-pixel limits
  before native decoding. Imported private copies are hash-verified against the selected source.
- Backup restore accepts supported older schemas by migrating a validated staging database before atomic promotion;
  current data stays active until every migration and project/file consistency check passes. A synthetic backup
  with the exact v8 schema is covered through the complete v8 -> v13 migration chain; a historical device fixture
  remains part of pre-launch migration testing.
- The Google Play listing icon is generated deterministically at
  `assets/store/google-play-icon-512.png` and passes the 512 px / 1 MB constraints.
- A full signed validation build for `1.0.0+1` was completed with a disposable key and non-production legal data.
  The resulting test AAB was 89,798,971 bytes with SHA-256
  `8ec731de02fffc402171b938282b44416d38b56586c8593f14738015c3ec7ba4`; its signature, exact permission
  manifest, 10 native 64-bit libraries and universal APK passed, and bundletool reported `PAGE_ALIGNMENT_16K`.
  It is evidence of the pipeline only and must not be uploaded to Play.

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
flutter_local_notifications 22.2.0
flutter_timezone 5.1.0
google_mlkit_document_scanner 0.5.0
google_mlkit_text_recognition 0.16.0
timezone 0.11.1
url_launcher 6.3.2
pdfrx 2.4.7
pdf 3.13.0
image 4.9.1
crypto 3.0.7
archive 4.0.9
share_plus 12.0.2
package_info_plus 9.0.1
cupertino_icons 1.0.9
```

The Android build passes with the known Flutter forward-compatibility warning
for plugins that still apply the classic Kotlin Gradle plugin (`file_picker`,
`flutter_timezone`, `google_mlkit_commons`, `google_mlkit_document_scanner`,
`google_mlkit_text_recognition`, `package_info_plus` and `share_plus`).
Re-evaluate this when a package or Flutter is upgraded.

Quality gate:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

All commands passed on 2026-08-01. The full suite contains 560 passing tests. Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Production gap audit

The complete production-readiness review is recorded in
`docs/build-home-app/PRODUCTION_READINESS_SPEC.md`, with the shorter functional
gap summary in `PRODUCTION_GAP_AUDIT.md`. Version `1.0.0+1` is a technical R1
release candidate. The frozen P0 scope is complete, an Android integration
smoke passed on API 34, and CI passed it on API 28 and 36. The same workflow
also passed 560 tests, debug APK and unsigned iOS 26 compilation. Public legal
pages are live through GitHub Pages; store copy, privacy worksheets, icon and
Google Play feature graphic are ready. Store account declarations, signed
current artifacts, final screenshots and physical-device evidence remain owner
release gates.

## Next task

For R1, execute the owner-only release checklist in
`OWNER_RELEASE_ACTIONS.md`. Product development after R1 starts with Task 8.3
from `IMPLEMENTATION_PLAN.md`: quantity calculators, followed by expanded
delivery, return and warranty reminders.
