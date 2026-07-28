# BudowaPRO - implementation status

Last updated: 2026-07-28

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
- House and renovation templates are seeded idempotently. The house template now has 15 formalities,
  12 site-preparation tasks and 16 `Stan 0` tasks. Ground investigation is kept with formalities, while
  access, fencing, site facilities and temporary utilities form a dedicated stage before foundations.
- Users can add and rename project-local stages, reorder the complete stage timeline, and edit stage
  status, planned dates and planned budget. Stable stage IDs preserve existing cost assignments.
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
- A versioned offline guidance catalog adds five compact `Stan 0` decision guides for service penetrations,
  foundation earthing, waterproofing, drainage/ground levels and concealed-work evidence. Each detail shows
  when to decide, inspection points, specialist questions, structured source metadata, content version and a clear
  boundary that it is not an execution design.
- Foundation-earthing guidance content version `4` separates a foundation earth electrode from a ring earth
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
- The shell-open stage has an informational guide for agreeing the exact window/shading detail before lintels.
  It does not seed a database row or change progress in existing projects. The content explicitly treats `5 cm`,
  conductor dimensions, PMBC/KMB, XPS, dimpled membrane and drainage as project/system-dependent rather than
  universal instructions.
- Eight additional source-backed guides cover structural and roof checks in the open shell, window/door
  installation and moisture control in the closed shell, coordinated routes and pre-covering tests for
  installations, and substrate readiness plus wet-room waterproofing during finishing. These guides are also
  read-only catalog content, so existing checklist progress and user data are not reseeded.
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
- SQL groups commitments, paid amounts and record counts by stage, category, supplier and local-calendar month.
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
- Notes, decisions and defects remain durable classified capture records until the dedicated diary and decision
  modules are implemented in Phase 7. They do not affect financial or schedule summaries.
- Merge is available only where all source data can be retained. Cost and task merge is rejected in both UI and the
  repository so a second amount or schedule cannot be lost.
- Reject removes the capture and then discards only attachments that are no longer linked. Rollback coverage proves
  that a failed status update cannot leave a target cost behind.
- The inbox, composer, editor and merge picker are localized, scrollable and covered at a 320 px viewport and 200%
  text scaling.

### Production privacy and legal readiness

- The More branch now exposes an offline `Privacy and law` center with an in-app privacy policy, terms of use,
  privacy status/controls and open-source licenses. Legal documents are split into expandable sections and remain
  usable at 320 px with 200% text scaling.
- The privacy policy describes actual local project data, user-initiated export, retention/deletion, the lack of an
  account/backend/ads/first-party analytics, and the ML Kit metrics exception. It does not claim that OCR text or
  document images are uploaded to Google.
- The terms include a construction-safety boundary, mandatory professional verification, OCR review, backup
  responsibility and a clause preserving mandatory consumer rights.
- Publisher name, privacy contact and public privacy-policy URL are build-time values. Android `preReleaseBuild`
  depends on a validation task and fails when metadata is missing, malformed, local-only or points to a PDF; no legal
  identity is invented in source. A separate CI utility verifies that the configured public URL responds with HTML.
- Android API 36 is the explicit compile/target level. Automatic cloud backup is disabled and both legacy and Android
  12+ extraction rules exclude private app files from cloud and device-transfer backups.
- `PRIVACY_AND_GOOGLE_PLAY_RELEASE.md` records the provisional ML Kit Data safety mapping, permission inventory,
  merged-manifest distinction, unencrypted manual ZIP warning, release command and remaining Play Console/signing
  actions. Google Play still requires a public policy URL even though the complete policy is also available inside
  the APK.

### Production hardening and Android release

- Release signing is fail-closed. A complete `BUDOWAPRO_UPLOAD_*` environment set takes precedence over ignored
  `android/key.properties`; mixed sources cannot select a different key. The release helper also compares the
  configured certificate SHA-256 with the keystore and final AAB. No debug-key fallback is allowed.
- `tool/release/build_android_release.dart` provides one reproducible Android release path. It requires a clean Git
  worktree by default, verifies the public HTML policy, runs all quality gates, builds a signed/obfuscated AAB,
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
  with the exact v8 schema is covered through the complete v8 -> v11 migration chain; a historical device fixture
  remains part of pre-launch migration testing.
- The Google Play listing icon is generated deterministically at
  `assets/store/google-play-icon-512.png` and passes the 512 px / 1 MB constraints.
- A full signed validation build was completed with a disposable key and non-production legal data. The resulting
  test AAB was 85,637,925 bytes, its signature and manifest passed, and bundletool reported
  `PAGE_ALIGNMENT_16K`. It is evidence of the pipeline only and must not be uploaded to Play.

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
google_mlkit_document_scanner 0.5.0
google_mlkit_text_recognition 0.16.0
timezone 0.11.1
url_launcher 6.3.2
pdfrx 2.4.7
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

All commands passed on 2026-07-28. The full suite contains 468 passing tests. Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Next task

Task 7.1 from `IMPLEMENTATION_PLAN.md`: implement the local daily site diary and
allow classified notes, decisions and defects to become chronological entries
without exposing their content to logs.
