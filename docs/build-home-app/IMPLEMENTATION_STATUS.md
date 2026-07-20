# BudowaPRO - implementation status

Last updated: 2026-07-15

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
- R0 maps one versioned template to each compatible project type. Multiple and
  custom templates remain deferred to Task 3.1, where stage checklists are added.

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
- Stage selection comes from the active project template. Category and supplier fields suggest values
  already used in the project while still allowing a new value to be entered immediately.
- The Android system picker imports allowed documents into private project storage without loading
  complete files into UI memory or requesting broad storage permission.
- File staging is recoverable. Only available attachments can be linked, and cost rows, attachment
  links and revisions are committed in one SQLite transaction. Streaming byte limits and recovery
  cover interrupted `.part` files and interrupted deletions.
- The budget branch provides a compact summary and direct access to add, inspect and edit entries.
- Validation preserves all entered values, and SQLite reopening tests verify exact amounts and status.

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
```

Quality gate:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

All commands passed on 2026-07-15 with 137 tests. Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Next task

Task 2.3 from `IMPLEMENTATION_PLAN.md`:

1. Build the paginated cost register with lazy loading.
2. Add combined search and filters for type, status, stage, category, supplier and date.
3. Calculate the active result summary in aggregate SQL.
4. Surface missing-document and missing-VAT warnings.
5. Verify combined filters and a fixture with 10,000 cost entries.

Do not start OCR or dashboard modules before the cost register is green.
