# BudowaPRO - implementation status

Last updated: 2026-07-20

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

All commands passed on 2026-07-20 with 166 tests. Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Next task

Task 3.2 from `IMPLEMENTATION_PLAN.md`:

1. Persist events, tasks, dependencies and due-date change history.
2. Build the seven-day plan over source records.
3. Add local notification scheduling with permission-denied fallback.
4. Preserve correct local dates across timezone and daylight-saving changes.

Do not start the dashboard module before the seven-day plan and local reminder behavior are green.
