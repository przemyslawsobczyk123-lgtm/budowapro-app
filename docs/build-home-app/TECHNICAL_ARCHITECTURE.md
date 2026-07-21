# Technical Architecture: BudowaPRO

## Status

Target architecture for the future Flutter Android app. Package versions are intentionally not pinned before the Flutter project exists. At scaffold time, versions must be verified against current official documentation and locked in `pubspec.lock`.

Official foundations:

- Flutter architecture guide: https://docs.flutter.dev/app-architecture/guide
- Flutter SQLite recipe: https://docs.flutter.dev/cookbook/persistence/sqlite
- Flutter concurrency and isolates: https://docs.flutter.dev/perf/isolates
- ML Kit document scanner: https://developers.google.com/ml-kit/vision/doc-scanner/android
- ML Kit text recognition: https://developers.google.com/ml-kit/vision/text-recognition/v2/android
- sqflite package: https://pub.dev/packages/sqflite

## Architecture Shape

```text
Presentation (views + view models/providers)
        |
        v
Domain (entities, value objects, use cases, repository contracts)
        |
        v
Data (SQLite repositories, filesystem, OCR, export, backup)
        |
        v
Android device services
```

Rules:

- views render state and dispatch intent,
- view models coordinate use cases and immutable UI state,
- domain owns money, status transitions, health reasons and validation rules,
- data layer owns SQL, file paths, OCR plugins and Android integrations,
- optional cloud AI is an adapter behind an explicit consent boundary,
- local rule engine is the default assistant and has no network dependency.

## Feature Modules

```text
lib/
  core/
    config/
    database/
    errors/
    files/
    localization/
    money/
    routing/
    security/
    theme/
  features/
    projects/
    capture/
    costs/
    receipts/
    stages/
    schedule/
    diary/
    decisions/
    contacts/
    quotes/
    rooms/
    materials/
    documents/
    technical_photos/
    plans/
    punch_list/
    home_record/
    assistant/
    reports/
    backup/
    settings/
  shared/
    models/
    repositories/
    services/
    widgets/
```

## Shared Linking Model

Do not force every feature into one generic table. Keep typed feature records, but use a common link model so the same receipt/photo/document can be found from its context.

```dart
typedef ProjectId = String;
typedef StageId = String;
typedef RoomId = String;
typedef ContactId = String;
typedef AttachmentId = String;

class RecordContext {
  const RecordContext({
    required this.projectId,
    this.stageId,
    this.roomId,
    this.contactId,
    this.checklistItemId,
    this.costItemId,
    this.planPinId,
  });

  final ProjectId projectId;
  final StageId? stageId;
  final RoomId? roomId;
  final ContactId? contactId;
  final String? checklistItemId;
  final String? costItemId;
  final String? planPinId;
}
```

At least `projectId` is required. Other links are additive and optional.

## Repository Contracts

Contracts are defined in domain and implemented in data.

```dart
abstract interface class CostRepository {
  Future<CostEntry> create(ConfirmedCostEntryInput input);
  Future<CostEntry> saveDraft(CostDraftInput input);
  Future<CostEntry> replaceDraft(...);
  Future<CostEntry> confirmDraft(...);
  Future<CostEntry> changeStatus(...);
  Future<CostEntry> updateDetails(...);
  Future<CostCorrection> addCorrection(CostCorrectionInput input);
  Future<CostEntry?> findById(...);
  Future<Page<CostEntry>> list(CostQuery query, PageRequest page);
  Future<CostSummary> summarize(CostSummaryQuery query);
  Future<CostFilterOptions> filterOptions({required String projectId});
  Future<Page<CostHistoryEntry>> history(...);
  Future<void> delete(...);
}

abstract interface class CaptureDraftRepository {
  Future<CaptureDraft> create(CaptureInput input);
  Future<CaptureDraft> classify(CaptureDraftId id, CaptureClassification classification);
  Future<Page<CaptureDraft>> listPending(ProjectId projectId, PageRequest page);
  Future<void> discard(CaptureDraftId id);
}

abstract interface class AttachmentRepository {
  Future<Attachment> importLocalFile(AttachmentImport request);
  Future<Attachment?> findById(AttachmentId id);
  Future<Page<Attachment>> list(AttachmentQuery query, PageRequest page);
  Future<void> remove(AttachmentId id);
}

abstract interface class QuoteRepository {
  Future<ContractorQuote> create(...);
  Future<ContractorQuote> update(...);
  Future<ContractorQuote?> findById(...);
  Future<Page<ContractorQuote>> list(QuoteQuery query, PageRequest page);
  Future<QuoteAcceptanceResult> accept(...);
  Future<ContractorQuote> reject(...);
  Future<void> delete(...);
}
```

List queries are paginated from the first implementation. Summaries are aggregate SQL queries, not totals calculated after loading every row.

`CostQuery` owns normalized search, set-based filters, an inclusive/exclusive UTC date range,
warning predicates and stable sorting. `CostSummaryQuery.fromCostQuery` copies the active filters but
always removes draft inclusion. The SQLite repository builds one bound-argument predicate and reuses
it for the page query, total count, base totals and correction totals.

The cost register requests 30 rows at a time and never materializes its total result. Attachment IDs
for one page are fetched in a single bounded follow-up query. Data-quality filters use `EXISTS` or
`NOT EXISTS`; list rows derive the same warning rules from loaded domain data. Text search escapes SQL
wildcards before adding its own contains-search delimiters.

## Money Contract

```dart
final class Money {
  factory Money({required int minorUnits, required String currencyCode});

  final int minorUnits;
  final String currencyCode;
}
```

Rules:

- no `double` for persisted monetary amounts,
- calculations use checked `BigInt` intermediates before returning SQLite `int64`,
- project has one base currency in MVP,
- project currency cannot change after its first cost entry,
- gross/net/VAT rounding is centralized and uses half-up to full minor units,
- cost status separates `planned`, `ordered`, `due`, `paid`, `returned` and `disputed`,
- drafts and offers never contribute to financial summaries,
- corrections and approved decision impacts are append-only deltas,
- OCR data enters as a draft and cannot directly create a paid cost.

## Capture And OCR State Machine

```text
captured
  -> processing
  -> review_required
  -> confirmed
  -> posted

processing -> failed_retryable
review_required -> duplicate_suspected
any draft state -> discarded
```

Required behavior:

- original file remains unchanged,
- derived crop/preview is a separate file,
- low-confidence fields carry field-level confidence,
- duplicate suspicion uses vendor/date/total/document hash,
- posting cost lines and linking receipt is one database transaction,
- cancellation leaves no partially posted financial records.

## Attachment Storage

Suggested local layout:

```text
app_data/
  projects/<project-id>/
    originals/
    previews/
    exports/
```

SQLite stores metadata and relative references. Absolute platform paths are resolved by a file service.

Schema `v3` separates `attachments` from `cost_entry_attachments`. A single
receipt or invoice can therefore link to multiple cost lines without copying
the original. Cost rows, links and append-only revisions are published in one
SQLite transaction.

Picker import uses a recoverable file-first protocol:

1. create an `importing` metadata placeholder with a generated storage key,
2. stream the source to `<storage-key>.part`, flush it and rename it,
3. mark the attachment `available`,
4. link only `available` attachments while saving the cost transaction,
5. remove interrupted imports, interrupted deletions and unlinked staging records during recovery.

The filesystem cannot share a transaction with SQLite. The database commit is
the visibility boundary; cleanup handles files prepared before a failed or
interrupted commit. User-provided names are metadata only and never become
storage paths.

The stream enforces the configured byte limit while copying. Recovery removes
both final and `.part` files for interrupted imports, and resumes rows marked
`deleting` before clearing their metadata.

`file_picker 11.0.2` is pinned for its Android path-traversal fix. Until its
stable AGP 9 script detects `android.builtInKotlin=false`, the root Gradle build
applies Kotlin and JVM 17 only to the `file_picker` subproject.

Each attachment has or reserves:

- an optional content hash slot, populated by a later document/OCR module,
- original file name,
- MIME type verified from content when practical,
- byte size,
- created/imported timestamp,
- source: camera, scanner, picker, generated export,
- typed links through `RecordContext`,
- optional redacted preview for future sharing.

## Stage And Checklist Storage

Schema `v4` adds three project-scoped tables:

- `project_stages` keeps a stable stage ID, template key or user-defined name,
  order, status, planned dates and planned budget,
- `checklist_items` keeps status, importance, due date, assignee label, notes,
  skip risk, reason, evidence requirement and an optional documented waiver,
- `checklist_item_attachments` links the generic local `attachments` table to
  checklist evidence without copying a file.

Template stages retain the same storage IDs used by `cost_entries.stage_id`.
Custom stages receive generated IDs and are exposed to the cost form and cost
filters as soon as they are created. Renaming a template stage changes its
display name but not its ID, so existing cost links remain valid.

Stage progress is derived at read time from checklist statuses. `completed` and
explicitly `skipped` items count as resolved; no progress percentage is stored.
Skipping requires a reason. Completing a template item that requires evidence
is validated in the repository transaction and succeeds only when a compatible
available attachment is linked or a non-empty waiver comment is stored. A
system photo requirement cannot be downgraded through the editor.

The `Stan 0` catalog is code-versioned and seeded idempotently on first plan
access. It contains all 18 minimum specification items. User-created stages and
checklist items are project records and are never overwritten by template
seeding.

## Seven-Day Schedule And Reminders

Schema `v5` adds four local tables:

- `schedule_events` stores tasks, visits, deliveries, acceptances and payments,
  including status, optional stage and assignee, reminder policy and an absolute
  UTC instant paired with its IANA time-zone identifier,
- `schedule_dependencies` stores directed blockers and an optional decision
  deadline; replacement rejects self-dependencies and graph cycles before write,
- `schedule_date_changes` is append-only and records previous/new UTC instants,
  time zones and an optional reason in the same transaction as rescheduling,
- `reminder_preferences` stores enabled event types, default lead and the local
  reminder time for all-day records.

The seven-day query uses an inclusive start and exclusive end derived from local
calendar boundaries. It therefore permits a 167- or 169-hour UTC range when DST
changes without losing or duplicating a local day. Event forms convert wall-clock
input through the stored IANA zone before persistence.

Local reminders use `flutter_local_notifications` with `timezone` and
`flutter_timezone`. Android scheduling uses `inexactAllowWhileIdle`, so the app
does not request exact-alarm access. `POST_NOTIFICATIONS` is requested only from
an explicit user action; denial never rolls back or blocks a schedule write.
Scheduled reminders are restored after reboot by the plugin receivers.

Flutter 3.44 still reports a forward-compatibility warning because
`flutter_timezone 5.1.0` applies the classic Kotlin Gradle plugin while this
project explicitly keeps built-in Kotlin disabled for plugin compatibility. The
current AGP 9 debug build passes; re-check both this package and `file_picker`
before the next Flutter toolchain upgrade.

Notification payloads contain only validated `projectId` and `eventId` values.
Foreground taps and cold launches resolve to the typed schedule details route.
Titles and notes are never serialized into navigation payloads or logs.

## Start Dashboard Projection

Start owns no persisted table. `DashboardReader` accepts the selected `Project`
and exact UTC boundaries for the current local day and 30-day forecast, then
returns one immutable `DashboardSnapshot`. The repository implementation reads
cost, stage/checklist and schedule source repositories in parallel.

Financial rules are explicit:

- `spent` is the corrected actual total of confirmed `cost` entries with status
  `paid`,
- `plannedNext30Days` is the combined planned and actual total of confirmed
  `planned` or `cost` entries with open statuses between the inclusive local-day
  start and exclusive day-30 boundary,
- `unpaid` and `unpaidCount` use confirmed `cost` entries in `due` or `disputed`
  status,
- project remaining budget is `plannedBudget - spent`; an overrun remains a
  negative domain value and is only formatted as an absolute warning in UI.

Calendar boundaries are produced through the schedule timezone gateway. A day
may therefore span 23 or 25 UTC hours at DST transitions while still representing
one complete local calendar day. The forecast advances by 30 wall-calendar days.

The stage repository exposes one project-scoped checklist query for dashboard
use. This keeps the number of SQLite calls fixed when users add custom stages.
Critical rows are unresolved high/critical checklist records sorted by importance,
status, due date, stage order and checklist order. Agenda rows retain source event
IDs and navigate to typed schedule detail routes.

The dashboard controller watches selected-project state and is explicitly
invalidated when the user returns to the Start branch. Successful cost/schedule
forms and returning from an agenda source also refresh the projection. No source
title, note, contact value or financial value is emitted to logs or telemetry.

Exact VAT components loaded from SQLite are validated against both supported
calculation directions. This preserves valid gross-originated rounding boundaries
that cannot be reconstructed by recalculating from net, while malformed component
triples still fail closed.

## Contacts And Site Visits

Schema `v6` adds four local tables:

- `contacts` owns project-scoped person/company data and archive state,
- `contact_roles` stores one or more validated trade roles per contact,
- `contact_stage_assignments` links a contact to multiple persisted project stages,
- `site_visits` extends a schedule event with contact, expected result, dedicated
  visit status, result and agreements.

Contact list queries bind every search/filter value. Role and stage predicates use
indexed `EXISTS` subqueries, while roles and stages for each result page are loaded
in two batched queries. The controller follows `Page.nextRequest` until the complete
filtered result is loaded. Project deletion cascades through contact data. Direct
contact deletion is restricted when `site_visits` still references it, preserving
completed, cancelled and no-show history.

A contact visit and its schedule event share the event ID and are created or updated
inside one SQLite transaction. Purpose, date, timezone, stage and reminder remain in
the schedule source; visit-specific values remain in `site_visits`. Rescheduling also
appends the existing schedule date-change record in that transaction. `no_show` is a
dedicated visit status and projects to a resolved/cancelled schedule state only where
the generic agenda needs a binary open/resolved decision.

The generic schedule form does not create new contact visits. A schedule details read
checks for a matching `site_visits` extension; when present it renders expected result,
result and agreements and routes edits to the specialized visit form. This prevents
generic schedule updates from bypassing visit invariants. Older standalone schedule
visits remain supported.

System phone and e-mail actions use `url_launcher` with `tel:` and `mailto:` URIs only
after a visible confirmation dialog. A failed platform launch produces a local UI
error and does not mutate contact data. The adapter receives no automatic background
trigger, and contact values are excluded from logs and telemetry.

The Start dashboard derives at most three open visit events between the inclusive
local-day start and exclusive day-30 boundary from the existing open schedule query.
It persists no contact or visit copy. Visit reminders use the same IANA timezone,
permission and payload rules as every other schedule event.

## Contractor Quotes

Schema `v7` adds three project-scoped tables:

- `contractor_quotes` owns contractor, stage, variant, validity, exact VAT components,
  status and the optional accepted cost ID,
- `quote_scope_lines` stores ordered included and excluded scope rows with normalized
  comparison keys,
- `quote_attachments` links quotes to the existing private `attachments` store without
  copying originals.

A quote is editable only while received. Accepted quotes reference exactly one confirmed
planned cost. Rejected quotes remain history records and can be deleted explicitly. The
database enforces project-local contact, stage, attachment and accepted-cost relations.
The attachment recovery query treats quote links as live references, so startup cleanup
cannot remove a PDF or image still used by a quote.

Comparison is a domain projection over at least two quotes from one project and currency.
It creates a union of normalized scope keys and returns `included`, `excluded` or
`notSpecified` per quote. Lowest price is factual metadata only; the model has no automatic
best-quote or recommendation field.

Acceptance is idempotent and transactional. `SqliteQuoteRepository` invokes the existing
cost transaction writer on the same SQLite executor, then changes the quote to `accepted`
and stores `accepted_cost_entry_id`. Any failure rolls back the cost, its attachment links,
its revision and the quote change. Repeating acceptance returns the existing cost ID. The
created cost keeps project, contractor, stage, amount, VAT, note and attachment references,
uses source `offer_conversion`, and enters either `planned` or `ordered` status.

The quote workspace is reachable from More and from each contractor. Routes are typed by
project and record ID. The form imports PDF/images through the shared system picker and private
file stager. The document catalog below owns opening, thumbnailing and cross-feature metadata.

## Project Document Catalog

Schema `v8` turns the existing private attachment store into one project document catalog
without copying any original. `document_metadata` owns title, type, description, document
date and warranty dates. `document_context_links` owns editable stage, contact and room links;
decision, defect and device link kinds are reserved until their source modules exist. Native
cost, checklist and quote attachment tables remain their source of truth and are projected as
typed document relations by one repository query.

`SqliteDocumentRepository` scopes every operation to one project. Search and filters use bound
SQL values and cover type, inferred or explicit stage, room, effective document date and the
shared 30-day warranty boundary. Lists are paginated in 30-row pages. Relations for each page
are loaded in one batched union instead of one query per document. Metadata and editable links
are saved in one transaction, so an invalid target cannot leave a partial edit.

The system picker imports supported local files under an opaque generated storage key. The
original stays byte-for-byte unchanged in `originals`; SHA-256 is calculated in an isolate and
used only to warn about potential duplicates. Image and first-page PDF previews are bounded
derivatives in `previews`. Decode, resize and JPEG encoding run outside the UI isolate, and a
preview failure never removes a valid original.

The Build branch exposes the searchable document workspace. Details show all native and context
relations and can open PDF/images, edit metadata, share the private original through the Android
share sheet or delete after reporting the relation count. Cost, quote and checklist evidence UI
opens the same document ID. Deletion first marks the attachment as deleting, removes its private
files and then removes the attachment row; foreign-key cascades clear every link and startup
recovery completes interrupted deletion.

Warranty start, inclusive end and optional reminder dates are persisted and filterable. Creating
the actual Android warranty notification remains part of `NOTIF-002` with the home/service module,
where notification preferences and a source deep link can be implemented without duplicating a
schedule record.

## Plan Pins

Plans are versioned images/PDF pages. Pins use normalized coordinates so they survive device-size changes:

```dart
class NormalizedPoint {
  const NormalizedPoint({required this.x, required this.y});

  final double x; // 0.0..1.0
  final double y; // 0.0..1.0
}
```

A pin references exactly one plan version and can link to photos, defects, measurements, equipment or checklist evidence. Moving a pin between plan versions is an explicit user action.

## Decisions And Change Impact

A decision is separate from a cost. One decision can create multiple cost changes and schedule effects.

```text
Decision
  -> selected option
  -> approval event
  -> zero or more CostImpact records
  -> zero or more ScheduleImpact records
  -> linked documents/photos/quotes
```

Impact values are auditable deltas. Editing the current budget does not erase the original decision history.

## Project Health Engine

The engine returns reasons, not a mystery score:

```dart
class ProjectHealth {
  const ProjectHealth({required this.level, required this.reasons});

  final HealthLevel level;
  final List<HealthReason> reasons;
}
```

Reason examples:

- critical checklist item due before scheduled concrete pour,
- unresolved decision blocks a task starting in three days,
- stage committed cost exceeds stage budget,
- required technical photo missing,
- material return window closes tomorrow,
- acceptance defect is overdue.

Rules are deterministic, individually tested and open the exact source record.

## Assistant Boundary

```dart
abstract interface class ProjectAssistant {
  Future<List<AssistantSuggestion>> evaluate(AssistantContext context);
}
```

Implementations:

- `LocalRuleAssistant`: offline, deterministic, default,
- `CloudAiAssistant`: future optional adapter, disabled by default.

AI request contract must contain:

- explicit user action,
- selected record IDs only,
- generated preview of data to be sent,
- purpose and retention notice,
- cancellation before transmission.

Assistant output is untrusted. It creates suggestions or drafts and cannot execute acceptance, payment or destructive file actions.

## Backup Contract

Backup is a user-triggered ZIP with a versioned manifest:

```json
{
  "format": "budowapro-backup",
  "version": 1,
  "createdAt": "2026-07-13T12:00:00Z",
  "database": "budowapro.sqlite",
  "attachments": "projects/",
  "checksums": "checksums.json"
}
```

Restore validates manifest version, paths, hashes and available space before changing local data. Restore runs into a staging directory and swaps only after full validation.

## Security Model

Trust boundaries:

- camera/gallery/document picker input,
- OCR result,
- imported CSV/backup,
- optional AI response,
- exported file destination.

Controls:

- validate type, size and path at import,
- reject path traversal in backups,
- parameterized SQL only,
- no sensitive content in logs or analytics,
- just-in-time permissions,
- explicit export and share actions,
- optional app lock and encrypted backup after threat-model review,
- no account, backend or upload in MVP.

## Performance Budgets

- cold start under 2 seconds on a mid-range Android device,
- warm project dashboard under 500 ms,
- filter feedback under 200 ms for 10,000 cost items,
- paginated lists with stable page size,
- image thumbnails generated outside the UI thread,
- full-resolution photos decoded only for detail view/export,
- OCR and ZIP/report generation outside the UI thread,
- plan view loads a bounded-resolution preview before original media.

## Privacy-Safe Observability

On-call/product questions:

1. Does local database migration succeed?
2. Does scan processing complete, fail or get cancelled?
3. Does export/restore complete without corrupting local state?
4. Which screens crash or exceed performance budgets?

Allowed event fields:

- stable event name,
- app version and schema version,
- duration bucket,
- success/failure category,
- non-content feature name.

Forbidden fields:

- receipt/OCR text,
- vendor/contact names,
- phone/email/address,
- notes and assistant prompts,
- file names/paths,
- plan labels, serial numbers and photo metadata.

Telemetry is disabled in the local prototype. Production telemetry requires a separate product decision and privacy review.

## Test Strategy

- unit: money, VAT, health rules, status transitions, duplicate detection and plan coordinates,
- repository: migrations, transactions, pagination and aggregate queries,
- parser fixtures: receipts, invoices and backup manifests,
- widget: loading, empty, error and review-required states,
- golden: five primary tabs and key detailed screens,
- integration: capture -> review -> posted cost; defect -> evidence -> sign-off; backup -> restore,
- Android manual/device: scanner, permissions, large photos, offline mode and low storage.

Module gate:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Do not start the next module while any gate is red.
