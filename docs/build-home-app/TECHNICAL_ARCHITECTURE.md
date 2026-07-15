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
  Future<CostItem> create(CostDraft draft);
  Future<CostItem> update(CostItemId id, CostPatch patch);
  Future<CostItem?> findById(CostItemId id);
  Future<Page<CostItem>> list(CostQuery query, PageRequest page);
  Future<CostSummary> summarize(CostQuery query);
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

## Money Contract

```dart
class Money {
  const Money(this.minorUnits, this.currencyCode);

  final int minorUnits;
  final String currencyCode;
}
```

Rules:

- no `double` for persisted monetary amounts,
- project has one base currency in MVP,
- gross/net/VAT rounding policy is centralized and tested,
- cost status separates `planned`, `committed`, `paid`, `returned` and `disputed`,
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

Each attachment has:

- content hash,
- original file name,
- MIME type verified from content when practical,
- byte size,
- created/imported timestamp,
- source: camera, scanner, picker, generated export,
- typed links through `RecordContext`,
- optional redacted preview for future sharing.

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
