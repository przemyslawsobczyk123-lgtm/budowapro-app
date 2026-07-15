# BudowaPRO - implementation status

Last updated: 2026-07-15

## Current release

`R0 Fundament - complete`

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

## Verified baseline

```text
Flutter 3.44.4
Dart 3.12.2
flutter_riverpod 3.3.2
go_router 17.3.0
sqflite 2.4.3
sqflite_common_ffi 2.4.2
path_provider 2.1.6
```

Quality gate:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

All commands passed on 2026-07-15 with 58 tests. Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Next task

Task 2.1 from `IMPLEMENTATION_PLAN.md`:

1. Define the `Money` value object using minor units and project currency.
2. Add VAT rates, financial item types and lifecycle statuses.
3. Test net, VAT, gross, corrections and rounding boundaries.
4. Define repository contracts without adding the cost UI yet.
5. Pass the complete quality gate before Task 2.2.

Do not start OCR or dashboard modules before the manual cost flow is green.
