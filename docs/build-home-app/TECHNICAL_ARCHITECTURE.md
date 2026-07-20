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
