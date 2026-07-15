# BudowaPRO - implementation status

Last updated: 2026-07-15

## Current release

`R0 Fundament`

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

## Verified baseline

```text
Flutter 3.44.4
Dart 3.12.2
flutter_riverpod 3.3.2
go_router 17.3.0
```

Quality gate:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

All commands passed on 2026-07-15. Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Next task

Task 1.2 from `IMPLEMENTATION_PLAN.md`:

1. Define database and file service contracts.
2. Write failing migration and transactional file tests.
3. Add SQLite `v1` foundation and project-scoped local file layout.
4. Pass the complete quality gate before Task 1.3.

Do not start cost, OCR or dashboard modules before Tasks 1.2 and 1.3 are green.
