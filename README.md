# BudowaPRO

Local-first Android application for managing a house build or renovation.

## Status

Implementation started from `R0` and `R1` in the approved plan. The current increment provides the Flutter foundation, Polish localization and five stateful primary navigation branches.

## Requirements

- Flutter 3.44.4 or compatible stable release,
- Dart 3.12.2 or compatible SDK,
- Java 17+,
- Android SDK with API 28+ support.

## Commands

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Product documentation

- `docs/build-home-app/SPEC.md`
- `docs/build-home-app/IMPLEMENTATION_PLAN.md`
- `docs/build-home-app/TECHNICAL_ARCHITECTURE.md`
- `docs/build-home-app-mockups/index.html`

## Privacy baseline

The MVP has no account, backend, synchronization or automatic upload. Project data and attachments remain on the device unless the user explicitly exports them.
