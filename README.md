# BudowaPRO

Local-first Flutter application for managing a house build or renovation on
Android and iOS.

## Status

The local-first MVP covers projects, stages and source-backed checklists, costs,
receipt/invoice OCR review, contacts, schedule and reminders, documents,
photos, quotes, reports, capture inbox, backup/restore and in-app legal
documents. Privacy settings also provide a confirmed in-app deletion of all
local project data. Production release hardening and an audited Android AAB
pipeline are included; Play Console/App Store Connect configuration, signing
and final publisher data remain external.

## Requirements

- Flutter 3.44.4 or compatible stable release,
- Dart 3.12.2 or compatible SDK,
- Java 17+,
- Android SDK with API 28+ support,
- macOS with Xcode for iOS build, simulator and App Store distribution.

## Commands

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Production Android release, after configuring the private upload key and legal
environment values, including the expected upload-certificate SHA-256:

```bash
dart run tool/release/build_android_release.dart
```

## Product documentation

- `docs/build-home-app/SPEC.md`
- `docs/build-home-app/IMPLEMENTATION_PLAN.md`
- `docs/build-home-app/IMPLEMENTATION_STATUS.md`
- `docs/build-home-app/TECHNICAL_ARCHITECTURE.md`
- `docs/build-home-app/PRIVACY_AND_GOOGLE_PLAY_RELEASE.md`
- `docs/build-home-app/IOS_AND_ANDROID_COMPATIBILITY.md`
- `docs/build-home-app/GITHUB_IOS_CI.md`
- `docs/build-home-app-mockups/index.html`

## Privacy baseline

The MVP has no account, backend, synchronization or automatic upload. Project data and attachments remain on the device unless the user explicitly exports them.
