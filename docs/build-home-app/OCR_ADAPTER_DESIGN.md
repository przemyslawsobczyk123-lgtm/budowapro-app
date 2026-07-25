# OCR adapter design

Status: Tasks `6.1` and `6.2` implemented and verified on `2026-07-25`.

## Objective

BudowaPRO captures one receipt page with the Android document scanner or
imports one local image/PDF, copies the original into project-private storage,
creates a bounded preview and runs Latin text recognition on the device.

The result is an untrusted proposal. It can become cost drafts only after the
Task `6.2` correction, confidence review, financial validation and explicit
save flow. It never posts a paid cost or updates a budget total directly.

## Dependencies

- `google_mlkit_document_scanner 0.5.0`: Android scanner UI, edge detection,
  crop, rotation, filters and gallery import.
- `google_mlkit_text_recognition 0.16.0`: bundled Latin OCR model.
- existing `pdfrx 2.4.7`: local rendering of the first imported PDF page to an
  OCR image.
- existing attachment stager and preview generator: private original,
  bounded preview, SHA-256 and interrupted-import recovery.

Do not add the `google_ml_kit` umbrella package. Both Flutter ML wrappers are
community-maintained bridges to native Google ML Kit APIs.

## Contracts

The domain owns:

- capture method (`scanner` or `file`),
- captured local-file metadata,
- recognized text with bounded lines and total size,
- provisional seller, date, document number, total, VAT and item candidates,
- stable failure kinds,
- a scan session that references the private attachment and preview.

The data layer owns:

- Flutter plugins and `PlatformException` mapping,
- file picker configuration,
- temporary scanner/PDF files,
- private attachment staging and cleanup,
- PDF rasterization,
- ML Kit conversion to domain text lines.

The presentation layer renders state and requests `scan`, `import`, `retry`,
`discard`, review edits or an explicit draft save.

## Lifecycle

1. No plugin opens during application or screen initialization.
2. A user action opens the scanner or file picker.
3. Cancellation returns no session and creates no database row.
4. A selected source is validated and copied to private project storage.
5. OCR reads the private original, never the external or scanner source.
6. Scanner and PDF temporary files are deleted.
7. A staging or preview failure discards the unlinked attachment.
8. An OCR failure keeps the private attachment in the current screen session so
   recognition can be retried.
9. An explicit discard or screen exit removes the private original and preview.
10. Startup recovery removes a session left unlinked after process death.

The attachment source records `scanner` or `file_picker`; no camera permission
is added because the Google scanner uses the Google Play services flow.

## OCR Boundary

OCR text is bounded before it reaches the UI. Candidate extraction does not
convert values to `Money`, infer VAT truth or affect duplicate detection.
Line-level ML Kit confidence is mapped to each retained seller, date, document
number, total and item candidate.

Imported PDFs are accepted, but Task `6.1` recognizes only the first page.
The UI states that the result is provisional and not added to the budget.

## Review And Posting Boundary

- confidence below `0.85` blocks save until the value is edited or confirmed,
- every OCR item requires explicit confirmation or selection of `0%`, `8%` or
  `23%` VAT; `23%` is never accepted silently,
- seller, valid date, positive receipt total and at least one valid positive
  item are required,
- seller/document/item text limits, 240 positions and aggregate amount bounds
  are validated before financial batch construction,
- item lines support add, remove, merge and split,
- receipt total and item total mismatch requires a separate acknowledgement,
- duplicate preflight checks attachment ID, SHA-256 and normalized
  seller/date/total/currency signature,
- hash and signature duplicates need a separate override; the same attachment
  is never accepted twice,
- one SQLite transaction creates `receipt_imports`, document metadata, every
  cost draft, shared attachment links and append-only revisions,
- a rollback or save error keeps the reviewed screen and does not expose
  private OCR content in logs.

Every resulting cost remains lifecycle `draft`, source `receiptOcr` and status
`planned`. Existing budget summaries exclude it until explicit draft approval.

## Errors And Fallback

- scanner cancellation: return to idle without an error,
- scanner unavailable/unsupported: show retry and local file fallback,
- unsupported or empty file: show a private validation error,
- no recognized text: allow OCR retry or discard before recapture/import,
- storage failure: discard partial data and show a private error,
- OCR failure: preserve the current private attachment and show retry/discard.

Google Document Scanner requires Google Play services, Android API 21+ and at
least 1.7 GB RAM. Its scanner component may need a first-use download. BudowaPRO
targets Android API 28+, and local file import remains available when the
scanner cannot start.

## Verification

- pure parser tests for Polish receipt candidates and hostile/empty text,
- adapter tests for cancellation, unsupported scanner and valid output,
- staging integration test proving `scanner` source and cleanup,
- gateway tests proving failure rollback and PDF/image OCR preparation,
- widget tests for idle, processing, review, low confidence, VAT, duplicate,
  lazy 240-line rendering, successful save and retryable error at 320 px,
  including 200% text scaling,
- repository tests for atomic multi-line posting, duplicate override,
  same-attachment rejection and complete rollback,
- project gate: `flutter analyze`, `flutter test`,
  `flutter build apk --debug`.

## Primary Sources

- Google ML Kit document scanner:
  <https://developers.google.com/ml-kit/vision/doc-scanner/android>
- Google ML Kit text recognition:
  <https://developers.google.com/ml-kit/vision/text-recognition/v2/android>
- Flutter document scanner wrapper:
  <https://pub.dev/packages/google_mlkit_document_scanner>
- Flutter text recognition wrapper:
  <https://pub.dev/packages/google_mlkit_text_recognition>
