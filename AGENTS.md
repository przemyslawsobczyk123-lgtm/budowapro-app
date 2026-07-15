# BudowaPRO - Agent Rules

## Product

- Polish Flutter application for Android.
- Local-first: no account, backend, synchronization, or document upload in MVP.
- Private project data, documents, and photos stay on the device unless the user explicitly exports them.

## Architecture

- Use feature-based Clean Architecture: presentation -> domain -> data.
- Views render state and dispatch actions. Keep business logic out of widgets.
- Domain has no Flutter, SQL, filesystem, or plugin dependencies.
- Data owns SQLite, filesystem, plugins, and Android services.
- Put user-facing text in localization files.

## Delivery

- Work module by module. Keep every module compilable.
- Do not start the next module until these gates pass:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

- If a gate fails, stop, diagnose, fix, and rerun it.
- Do not revert or overwrite unrelated changes. Other agents may work in parallel.
- Never commit secrets or log private project content, file names, paths, OCR text, contacts, addresses, or notes.
