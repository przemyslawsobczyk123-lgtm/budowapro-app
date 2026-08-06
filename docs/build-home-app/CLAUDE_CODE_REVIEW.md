# BudowaPRO — niezależny code review

- Repozytorium: `C:\Users\Przemyslaw\BudowaPRO`
- Gałąź / HEAD: `main` @ `7b9d823 feat: refresh app navigation icons`
- Working tree: czyste (`git status` → nothing to commit)
- Data audytu: 2026-08-06
- Metoda: analiza równolegle 6 wyspecjalizowanych agentów; wszystkie znaleziska mają cytaty (plik:linia). Nie modyfikowano żadnego pliku, nie robiono commitów, nie odczytywano sekretów.

Raport opisuje wyniki niezależnego review i **nie zastępuje weryfikacji właściciela** — każde znalezisko należy potwierdzić przed wdrożeniem poprawki.

---

## 1. Werdykt

| Ścieżka wydania | Ocena | Uzasadnienie |
|---|---|---|
| Testy zamknięte (internal / closed track Play) | ⚠️ **Warunkowo gotowe** | Kod przechodzi wszystkie bramki (format, analyze, 565 testów, debug APK). Krytyczny blocker prawny/formalny: podpisany keystore + realne dane wydawcy. |
| TestFlight | ⛔ **Nie gotowe** | Brak podpisu iOS (kod OK), niekompletny `PrivacyInfo.xcprivacy`, nie zweryfikowano manifestów prywatności podów. |
| Google Play — produkcja | ⛔ **Nie gotowe** | (a) brak `<queries>` dla `url_launcher` psuje "zadzwoń / e-mail / polityka" na Android 11+ (b) OCR wielostronicowych faktur nieskuteczny (c) brak realnych danych wydawcy i keystore (d) 16 KB alignment wymaga potwierdzenia lokalnym uruchomieniem `tool/release/build_android_release.dart`. |
| App Store — produkcja | ⛔ **Nie gotowe** | (a) niekompletne deklaracje `NSPrivacyAccessedAPI*` (ryzyko ITMS-91053) (b) brak testów na fizycznym iPhonie (c) blokery TestFlight nierozwiązane. |

**Poziom ryzyka wydania w obecnym stanie:** wysoki. Odblokowanie wymaga ~2–3 dni pracy inżynierskiej + działań właściciela (klucze, dane wydawcy, testy na urządzeniach).

---

## 2. Znalezione problemy

Legenda: **P0** = blocker wydania · **P1** = wysoki · **P2** = średni · **P3** = niski · **Confidence** = high (dowód w kodzie), medium (wymaga potwierdzenia), low (podejrzenie).

### P0 — blokery

#### [OCR-01] Wielostronicowe faktury/paragony: OCR tylko pierwszej strony
- Confidence: high
- Files: `lib/features/receipt_scan/data/receipt_capture_adapters.dart:87`, `lib/features/receipt_scan/data/receipt_ocr_image_preparer.dart:116-155`
- Evidence: `pageLimit: 1` w `DocumentScannerOptions`; `_renderFirstPdfPage` używa `document.pages.first.ensureLoaded()` — pozostałe strony PDF-a są ignorowane.
- Scenariusz: użytkownik importuje 3-stronicową fakturę PDF; totale, VAT i pozycje ze stron 2–3 nie są rozpoznawane.
- Wpływ: faktury wielostronicowe zapisywane bez części pozycji i (potencjalnie) bez totalu, walidacja mismatch nie zostaje odpalona.
- Rekomendacja: podnieść `pageLimit` do konfigurowalnego limitu (np. 20), iterować `document.pages`, scalać `RecognizedReceiptLine` z każdej strony w jednym `RecognizedReceiptText`, total szukać na ostatniej stronie.
- Brakujący test: integracja PDF ≥2 stronicowej — asercja, że `recognizedText` zawiera fragmenty każdej strony.

#### [I18N-01 / W-26] `DateFormat('LLLL yyyy', 'pl_PL')` bez `initializeDateFormatting`
- Confidence: high (do weryfikacji na urządzeniu — patrz sekcja 3)
- Files: `lib/features/reports/presentation/budget_report_screen.dart:607`, `lib/features/schedule/presentation/schedule_plan_screen.dart:159,354-355`, `lib/features/schedule/presentation/schedule_event_form_screen.dart:119`, `lib/features/schedule/presentation/schedule_event_details_screen.dart:94-95`, `lib/features/contacts/presentation/site_visit_form_screen.dart:128`
- Evidence: brak `initializeDateFormatting('pl_PL', null)` w `main.dart`; wywołania z pełnym patternem `LLLL`, `EEEE`, `MMMM` wymagają symboli locale.
- Scenariusz: otwarcie Raportu → miesiąc lub Harmonogramu.
- Wpływ: potencjalny `LocaleDataException: Locale data has not been initialized`.
- Rekomendacja: w `main.dart` przed `runApp`:
  ```dart
  import 'package:intl/date_symbol_data_local.dart';
  await initializeDateFormatting('pl_PL', null);
  ```
- Brakujący test: smoke test uruchomienia Reports i Schedule.

#### [PROD-01 / A-BUILD-01] Signing release wymaga sekretu właściciela
- Confidence: high (formalny blocker, kod OK)
- Files: `android/app/build.gradle.kts:12-71,74-83`, `android/key.properties.example`
- Evidence: `signingConfigs { if (missingReleaseSigningValues.isEmpty()) create("release") { … } }`; `validateProductionReleaseConfig` (linia 105-174) fail-closed bez `BUDOWAPRO_UPLOAD_*` lub `key.properties`.
- Scenariusz: bez zmiennych `BUDOWAPRO_UPLOAD_*` (5 sekretów) release AAB w ogóle się nie zbierze.
- Wpływ: blokada dostarczenia AAB do Play Console.
- Rekomendacja (działanie właściciela): keystore RSA 4096, ważność ≥25 lat, kopia offline, 5 sekretów GitHub, `dart run tool/release/build_android_release.dart`, włączyć Play App Signing.

#### [PROD-02 / S-05] Dane wydawcy nie są ostateczne
- Confidence: high (blocker właściciela)
- Files: `docs/build-home-app/OWNER_RELEASE_ACTIONS.md:29-37`, `PRIVACY_AND_GOOGLE_PLAY_RELEASE.md:40-63`
- Evidence: `BUDOWAPRO_PUBLISHER_NAME`, `BUDOWAPRO_PRIVACY_CONTACT_EMAIL`, `BUDOWAPRO_PRIVACY_POLICY_URL`, `BUDOWAPRO_SUPPORT_URL` — obecne w kodzie jako runtime defines, ale wartości wymagają formalnej decyzji (osoba fizyczna vs działalność, publiczna domena, adres e-mail do korespondencji GDPR/DSAR).
- Rekomendacja: właściciel zatwierdza dane + weryfikacja tożsamości wydawcy Google/Apple.

---

### P1 — wysoki priorytet

#### [ARCH-R1] Post-`dispose` przypisanie `state = AsyncData(...)` w kilkunastu kontrolerach Riverpod 3
- Confidence: high
- Files: `lib/features/documents/presentation/documents_controller.dart:170`, `captures_controller.dart:123,250`, `punch_controller.dart:263,289`, `contacts_controller.dart:171`, `technical_photos_controller.dart:206,258`, `journal_controller.dart:161,315`, `stage_plan_controller.dart:84,205`, `materials_controller.dart:133,141`, `schedule_plan_controller.dart:216`, `quotes_controller.dart:163`, `rooms_controller.dart:102`, `projects_controller.dart:94`
- Evidence: `state = AsyncData(...)` bezpośrednio po `await ref.read(...).future` bez `if (!ref.mounted) return;`. Wyjątek: `dashboard_controller.dart:41` (poprawnie).
- Scenariusz: użytkownik jest w Documents, klika `loadNext()`, po czym natychmiast przełącza projekt → `documentsControllerProvider` jest disposowany, poprzedni `Future` kończy się i próbuje ustawić state → `StateError: Cannot use "state" after "dispose"`.
- Wpływ: crash zgłaszany do `PlatformDispatcher.onError`; użytkownik traci ekran (w release ogólny komunikat).
- Rekomendacja: `if (!ref.mounted) return;` po każdym `await` przed przypisaniem do `state`; rozważyć `AsyncValue.guard` + helper.
- Brakujący test: unit test kontrolera z `ProviderContainer` — wywołać `loadNext()`, natychmiast `container.invalidate(...)` przed rozstrzygnięciem future, asertować brak wyjątku.

#### [ARCH-R2] `pickAndStage` — `state.requireValue` w `finally` po dispose
- Confidence: high
- Files: `lib/features/documents/presentation/documents_controller.dart:197`, `lib/features/technical_photos/presentation/technical_photos_controller.dart:256`
- Evidence: `finally { if (state.hasValue) { state = AsyncData(state.requireValue.copyWith(isImporting: false)); } }` — `state.hasValue` po dispose też rzuca.
- Rekomendacja: `if (!ref.mounted) return;` w `finally`.

#### [ARCH-N1] Brak `PopScope` w `AppShell` — hardware back wychodzi z aplikacji
- Confidence: high
- File: `lib/features/shell/presentation/app_shell.dart:60-70`
- Evidence: `Scaffold` z `NavigationBar` bez `PopScope`; `StatefulShellRoute.indexedStack` nie ma logiki `canPop`.
- Scenariusz: user wchodzi w tab „Budget", klika back → aplikacja się zamyka zamiast wracać do „Start".
- Rekomendacja: `PopScope(canPop: navigationShell.currentIndex == 0, onPopInvokedWithResult: (didPop, _) { if (!didPop) navigationShell.goBranch(0); })`.
- Brakujący test: widget test wysyłający `WidgetsBinding.instance.handleSystemMessage({'method':'popRoute'})` w tabie ≠ 0.

#### [PERF-P1] `Image.file` bez `cacheWidth/cacheHeight` w galeriach zdjęć i podglądach
- Confidence: high
- Files: `lib/features/technical_photos/presentation/technical_photos_screen.dart:398`, `technical_photo_details_screen.dart:95`, `technical_photo_form_screen.dart:383`, `lib/features/receipt_scan/presentation/receipt_scan_screen.dart:1376`, `lib/features/documents/presentation/document_viewer_screen.dart:87`
- Evidence: `Image.file(previewFile!, fit: BoxFit.cover)` bez `cacheWidth`. `document_details_screen.dart:413` ma `cacheWidth: 720` — reszta nie.
- Scenariusz: 50 zdjęć 12 MP w gridzie → 200+ MB w decoderze → OOM na średnich Androidach.
- Rekomendacja: `cacheWidth: MediaQuery.of(context).devicePixelRatio * cellWidth`.

#### [OCR-02] Wybór totalu — `<` zamiast `<=` daje niedeterminizm
- Confidence: high
- File: `lib/features/receipt_scan/domain/receipt_ocr.dart:313`
- Evidence: `if (score == null || score < bestScore) continue;` — przy równych wynikach ostatnia linia wygrywa.
- Scenariusz: dwa markery „RAZEM"/„SUMA PLN" na długim paragonie.
- Wpływ: niepoprawny total → mismatch z pozycjami.
- Rekomendacja: `<=` lub jawnie preferować pierwsze wystąpienie.

#### [OCR-05] `total_gross_minor_units` zapisywany z OCR mimo `totalMismatchAcknowledged`
- Confidence: high
- Files: `lib/features/receipt_scan/domain/receipt_financial.dart:89-96`, `receipt_review.dart:501-503`
- Evidence: gdy user akceptuje mismatch, do bazy trafia total z OCR, mimo że suma pozycji jest inna.
- Wpływ: sygnatura duplikatu trafia w zły klucz; ponowny import z korektą nie wykryje duplikatu → księgowość w rozjazd.
- Rekomendacja: przy `totalMismatchAccepted` zapisywać `lineTotal`; `documentTotalOcr` trzymać oddzielnie do audytu.
- Brakujący test: sprawdzić, że przy accepted mismatch sygnatura duplikatu korzysta z sumy pozycji.

#### [OCR-DUP-01] `normalizeReceiptSellerKey` zwija znaki — fałszywe duplikaty
- Confidence: high
- File: `lib/features/receipt_scan/domain/receipt_financial.dart:201-221`
- Evidence: `Ż`/`ź`→`z`, wszystko poza `[a-z0-9]`→spacja; sygnatura = seller_key + purchase_date + total.
- Scenariusz: dwa różne paragony Żabka tego samego dnia na tę samą kwotę → drugi zapisany jako `receiptSignature` duplikat.
- Rekomendacja: dołączyć `documentNumber` do sygnatury; alternatywnie `time` z paragonu, nie tylko `date`.

#### [OCR-EXT-01] `FilePicker(type: FileType.image)` w captures pomija whitelistę
- Confidence: high
- File: `lib/features/captures/data/capture_attachment_picker.dart:18-22`
- Evidence: brak `allowedExtensions`; `_mediaTypeFor` zwraca `null` dla `.gif`, `.bmp`, `.tiff`, `.svg`; `LocalAttachmentStager.stage` rzuca generyczny `UnsupportedError` po wybraniu.
- Rekomendacja: `type: FileType.custom, allowedExtensions: const ['jpg','jpeg','png','webp','heic']`.

#### [OCR-LIM-01] `maximumAttachmentBytes = 512 MB` za dużo dla telefonu
- Confidence: high
- Files: `lib/core/config/storage_policy.dart:2`, `lib/core/files/project_file_store.dart:145-163`
- Scenariusz: user importuje film 400 MB w `.mp3` — kopiowany do private storage, OOM/kill.
- Rekomendacja: limity per-typ (image 32 MB, PDF 64 MB, audio 100 MB, doc 32 MB); progress bar dla plików > 20 MB.

#### [OCR-LIM-02] `maximumDecodedImagePixels = 48 MP` → 192 MB RAM po dekodzie
- Confidence: high
- File: `lib/core/files/local_file_preflight.dart:21`
- Scenariusz: JPG 8000×6000 mieści się w limicie, bitmap 192 MB → OOM na 2 GB urządzeniach.
- Rekomendacja: obniżyć do 16 MP dla OCR i 8 MP dla preview.

#### [UI-W-04] Sheet edytora etapu — CTA znika za klawiaturą
- Confidence: high
- File: `lib/features/stages/presentation/stage_editor_dialogs.dart:788-836`
- Evidence: `availableHeight = MediaQuery.sizeOf(context).height - viewInsets.bottom` + `SizedBox(height: availableHeight * 0.9)` w `SafeArea` z `padding: EdgeInsets.only(bottom: viewInsets.bottom)` — łączna wysokość > H po otwarciu klawiatury.
- Scenariusz: Etapy → edytuj etap → pole budżetu → klawiatura zakrywa „Zapisz".
- Rekomendacja: `DraggableScrollableSheet` lub usunąć jedno z dwóch źródeł offsetu.

#### [UI-W-05] Bottom nav 72 dp obcina etykiety przy 200% skali tekstu
- Confidence: high
- Files: `lib/core/theme/app_theme.dart:35-50`, `lib/features/shell/presentation/app_shell.dart:60-79`
- Evidence: `NavigationBarThemeData(height: 72, labelTextStyle: fontSize: 12)`. Przy 2x → label 24 sp + ikona 26 + indykator 32 > 72.
- Rekomendacja: usunąć `height: 72` lub obliczyć przez `MediaQuery.textScalerOf(context)`.

#### [I18N-W-23] `stage_guidance.dart` — polskie stringi `revision:` w UI, nie przez ARB
- Confidence: high
- Files: `lib/features/stages/domain/stage_guidance.dart:486,506,522,540,559,614,622,630,648,664,681,682,714,732,742,752,762,770`
- Evidence: `revision: 'GUNB, aktualne wzory wniosków i zawiadomień'` używane w `stage_guidance_sheet.dart:153`.
- Rekomendacja: przenieść `revision` do ARB przez klucz-enum.

#### [I18N-W-24] `local_cost_csv_export_gateway.dart:165` — tytuł share hardcoded PL
- Confidence: high
- File: `lib/features/exports/data/local_cost_csv_export_gateway.dart:165`
- Evidence: `title: 'BudowaPRO - eksport kosztów'` — nie przez ARB.

#### [I18N-W-28] VAT enum tylko PL: `zero(0)`, `reduced8(800)`, `standard23(2300)`
- Confidence: high
- File: `lib/features/costs/domain/vat_breakdown.dart:3-11`
- Scenariusz: dodanie języka angielskiego + użycie w innej jurysdykcji (CZ 21%/15%, DE 19%/7%) niemożliwe.
- Rekomendacja: `List<VatRate>` konfigurowalna per Project/lokalizacja.

#### [I18N-W-31] Brak ARB dla EN — `supportedLocales = [Locale('pl')]`
- Confidence: high
- Files: `lib/l10n/` (tylko `app_pl.arb`), `l10n.yaml`, `lib/l10n/app_localizations.dart:95`
- Wpływ: EN nie zadziała nawet po dodaniu Locale.
- Rekomendacja: `app_en.arb`, usunąć `preferred-supported-locales`, dodać `Locale('en')`.

#### [I18N-W-33] OCR paragonów sprzężony z polskimi tokenami
- Confidence: high
- File: `lib/features/receipt_scan/domain/receipt_ocr.dart:179-202,441-464`
- Evidence: `_sellerExcludedMarkers = ['PARAGON','FAKTURA','NIP','DATA','NUMER','SUMA','RAZEM','TOTAL','DO ZAP','GOTÓW',…]`; separator dziesiętny sztywno.
- Rekomendacja: `Map<Locale, Set<String>>` lub serwis per-locale.

#### [PROD-A-MAN-03] Brak `<queries>` dla `url_launcher` (tel/mailto/https)
- Confidence: high
- Files: `android/app/src/main/AndroidManifest.xml:59-64`, `lib/features/legal/data/legal_link_gateway.dart:12`, `lib/features/contacts/data/contact_action_gateway.dart:21-27`
- Evidence: `<queries>` zawiera wyłącznie `PROCESS_TEXT`. Na Android 11+ `Intent.resolveActivity` dla `tel:`, `mailto:`, `https:` wymaga jawnego wpisu w `<queries>` w kliencie.
- Scenariusz: user Android 12+ klika „Zadzwoń wykonawcy" → `canLaunchUrl` zwraca `false` → `ContactActionUnavailableException`. Otwarcie polityki prywatności → `PlatformException`.
- Wpływ: krytyczne UX; recenzent Play prawdopodobnie wykryje na pre-launch report.
- Rekomendacja:
  ```xml
  <queries>
    <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
    <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
    <intent><action android:name="android.intent.action.SENDTO"/><data android:scheme="mailto"/></intent>
  </queries>
  ```
  Uzupełnić `tool/release/release_support.dart` allowlist.

#### [PROD-I-PRIV-01] `PrivacyInfo.xcprivacy` — brak `NSPrivacyAccessedAPICategoryUserDefaults` i `SystemBootTime`
- Confidence: high
- File: `ios/Runner/PrivacyInfo.xcprivacy:11-29`
- Evidence: obecne tylko `DiskSpace` (`E174.1`) i `FileTimestamp` (`C617.1`). Flutter / `shared_preferences` / `package_info_plus` wołają `NSUserDefaults`; `flutter_timezone` / `flutter_local_notifications` mogą używać `SystemBootTime`.
- Scenariusz: App Store Connect wysyła e-mail ITMS-91053 „Missing API declaration" po uploadzie IPA.
- Wpływ: odrzut TestFlight / App Review.
- Rekomendacja: dodać `NSPrivacyAccessedAPICategoryUserDefaults` → `CA92.1` oraz `NSPrivacyAccessedAPICategorySystemBootTime` → `35F9.1`. Zweryfikować manifesty podów.

#### [PROD-I-PRIV-02] Manifesty prywatności SDK — nie potwierdzone (środowisko Windows)
- Confidence: low (blokada środowiska)
- Evidence: `docs/build-home-app/PRODUCTION_GAP_AUDIT.md:73` — „Sprawdź privacy manifest razem z manifestami SDK po instalacji CocoaPods". Nie da się potwierdzić bez macOS.
- Rekomendacja: `pod install` + audit `ios/Pods/*/PrivacyInfo.xcprivacy` dla `MLKitTextRecognition`, `GoogleMLKit`, `sqflite`, `flutter_local_notifications`, `path_provider_ios`, `file_picker`, `share_plus`.

#### [PROD-A-BUILD-04] 16 KB page alignment — wymaga potwierdzenia lokalnym build tool
- Confidence: medium
- Files: `android/app/build.gradle.kts:44`, `tool/release/build_android_release.dart:258-263`
- Evidence: release helper waliduje alignment przez `bundletool 1.18.3` + `zipalign -P 16`. Wartość `flutter.ndkVersion` — zależna od toolchain.
- Wpływ: brak alignment = odrzucenie Play (obowiązek od 1.11.2025).
- Rekomendacja: uruchomić `tool/release/build_android_release.dart` na docelowej gałęzi tuż przed wysyłką; przechować `release-metadata.json`. Rozważyć jawne przypięcie `ndkVersion = "27.x"`.

#### [DATA-TX-2] Legal reset — usuwa pliki przed bazą, poza transakcją
- Confidence: high
- File: `lib/features/legal/data/local_data_deletion_service.dart:24-52`
- Evidence: `deleteAll()` najpierw wywołuje `_fileStore.deleteAllProjectFiles()`, potem `databaseFile.delete()`. Jeśli krok drugi padnie, w bazie zostają wiersze pokazujące pliki, których już nie ma.
- Scenariusz: user wybiera „usuń wszystkie dane" (GDPR), storage rzuca I/O error po skasowaniu plików.
- Wpływ: user myśli, że wyczyścił dane, ale w bazie widzi historię bez plików; przy próbie otwarcia załącznika 404.
- Rekomendacja: odwrócić kolejność (DB przed plikami) lub tombstone `.pending-wipe` + recovery na starcie.

#### [DATA-REL-1] Kolumny materiałów bez FOREIGN KEY
- Confidence: high
- File: `lib/core/database/app_database.dart:2248-2252,2306-2307,2360`
- Evidence: `materials.stage_id/room_id/supplier_contact_id/cost_entry_id/receipt_document_id`, `material_deliveries.document_id/contact_id`, `material_returns.receipt_document_id` — brak FK. Walidacja tylko przy INSERT/UPDATE materiału (`_validateInputRelations:507-560`).
- Scenariusz: usunięcie kosztu lub kontaktu → materiał trzyma wskaźnik na nieistniejący rekord.
- Wpływ: raporty i joiny pomijają materiał lub pokazują NULL.
- Rekomendacja: migracja v19 z FK ON DELETE SET NULL (dla soft-linków) lub ON DELETE RESTRICT (dla twardych). W SQLite wymaga `ALTER TABLE RENAME + CREATE + INSERT SELECT`.

#### [PROD-S-06] Brak testów na fizycznych urządzeniach (Android + iPhone)
- Confidence: high (informacja z docs)
- File: `docs/build-home-app/PRODUCTION_GAP_AUDIT.md:127-137`
- Rekomendacja: przed wydaniem: brak baterii, brak sieci, restart podczas OCR, duplikaty PDF, TestFlight na iPhonie.

---

### P2 — średni priorytet

#### [OCR-03] Regex kwot nie akceptuje NBSP (` `)
- File: `lib/features/receipt_scan/domain/receipt_ocr.dart:169-171`, `receipt_review.dart:598-600`
- Evidence: `_moneyPattern` zawiera `\d{1,3}(?:[ .]\d{3})*` — tylko zwykła spacja/kropka. NBSP z ML Kit rozrywa dopasowanie.
- Wpływ: total zaniżony (np. `1 234,56` → dopasuje tylko `234,56`).
- Rekomendacja: dodać ` ` do klasy separatorów.

#### [OCR-04] Ujemne kwoty (rabat/storno) nie są parsowane
- File: `lib/features/receipt_scan/domain/receipt_review.dart:540-550`
- Rekomendacja: świadome pomijanie lub wsparcie ujemnych jako korekt.

#### [OCR-06] Empty OCR — brak fallbacku ręcznego utworzenia z załącznika
- Files: `lib/features/receipt_scan/data/local_receipt_scan_gateway.dart:176-178`, `presentation/receipt_scan_controller.dart:334-350`
- Rekomendacja: w `emptyText` opcja „przejdź do edycji ręcznej" — pusty draft z zachowaniem `attachmentId`.

#### [OCR-07] `LocalReceiptOcrImagePreparer` nie downscale'uje dużych obrazów przed ML Kit
- File: `lib/features/receipt_scan/data/receipt_ocr_image_preparer.dart:63-79`
- Rekomendacja: downscale do 1600 px na krótszym boku przed OCR.

#### [FS-02] `display_name` bez sanitizacji w bazie i w Share
- Files: `lib/features/documents/data/local_attachment_stager.dart:157-161`, `receipt_capture_adapters.dart:141-144`, `document_details_screen.dart:314-317`
- Scenariusz: import z nazwą `../../evil.pdf` — przekazane do `SharePlus.share(fileNameOverrides: [displayName])`.
- Wpływ: potencjalny path traversal po stronie odbiorcy udziału.
- Rekomendacja: sanitizacja `displayName`: strip `[\/\\:*?"<>|\0]`, `..`, Windows-reserved.

#### [FS-01] `deleteAfterStaging=true` dla skanera — brak assert kontenera
- File: `lib/features/receipt_scan/data/receipt_capture_adapters.dart:64-73`
- Rekomendacja: `assert(sourceUri` w `Directory.systemTemp)` przed usunięciem.

#### [FS-06] Temp directory dla PDF preview / OCR PDF — brak cleanup po kill
- Files: `receipt_ocr_image_preparer.dart:92-113`, `local_document_preview_generator.dart:61-93`
- Wpływ: wyciek dysku + prywatność (skany paragonów w cache po crashu).
- Rekomendacja: startowa faza aplikacji czyści `budowapro_receipt_ocr_*`, `budowapro_preview_*` w `LocalPrivateCacheCleaner`.

#### [DUP-02] Brak dedup po SHA-256 przy imporcie tego samego pliku pod różnymi nazwami
- File: `lib/features/documents/data/local_attachment_stager.dart:145-260`
- Rekomendacja: pre-check w `stage` — jeśli hash już istnieje, zaoferować „użyj istniejącego".

#### [SEC-C-2] Backup ZIP nieszyfrowany (zawiera SQLite + kontakty + kwoty)
- Files: `lib/features/backup/data/local_backup_gateway.dart:96-115`, `backup_providers.dart:19-22`
- Evidence: ZIP w `getTemporaryDirectory()/budowapro-backups`, share przez `share_plus` z FileProvider; po zakończeniu `LocalPrivateCacheCleaner.scheduleShareCacheCleanup()`.
- Wpływ: kopia przekazywana odbiorcy w plaintext.
- Rekomendacja: opcjonalne szyfrowanie AES-256 z hasłem (`archive` lub natywnie) lub mocne ostrzeżenie UX.

#### [SEC-I-2] `NSPhotoLibraryUsageDescription` deklarowane, kod może nie wywoływać `PHPhotoLibrary`
- File: `ios/Runner/Info.plist:33-34`
- Evidence: `file_picker 11.0.2` na iOS 14+ używa `PHPickerViewController` (nie wymaga zgody). Deklarowanie klucza bez uzasadnienia → ryzyko App Review rejection.
- Rekomendacja: zweryfikować wersję pickera; jeśli PHPicker — usunąć klucz.

#### [ARCH-B1] `DateTime.now()` w `build()` — niedeterministyczne stany gwarancji
- File: `lib/features/documents/presentation/document_details_screen.dart:95`
- Evidence: `final warranty = metadata.warrantyStateAt(DateTime.now());` w `_content(...)` z `build()`.
- Rekomendacja: przenieść wyliczenie do gateway/state z jawnym `now`.

#### [ARCH-N2] Deep link `/quotes/compare?ids=...` nie waliduje id
- File: `lib/core/routing/app_router.dart:329-338`
- Evidence: nieznane id psuje `Future.wait` — cały widok pokazuje error.
- Rekomendacja: `Future.wait(..., eagerError: false)` + `null` filter.

#### [ARCH-A1] Global error guard w release tylko `debugPrint`
- File: `lib/core/errors/app_error_guard.dart:15-31`
- Wpływ: crashy nie zostawiają śladu do diagnozy.
- Rekomendacja: rotacyjny log w app documents dir (release), `FlutterError.presentError(details)` w debug.

#### [ARCH-A2] 102 wystąpień `on Object { }` bez `debugPrint`/logu w 55 plikach
- Przykład: `lib/features/schedule/data/schedule_providers.dart:37-46`
- Rekomendacja: konwencja `catch (error, stack) { AppErrorGuard.report(error, stack); }` tam, gdzie user nie dostaje sygnału.

#### [ARCH-A4] Debounce timery — brak spójnej ochrony po dispose
- File: `lib/features/costs/presentation/cost_budget_screen.dart:344-347`, `contacts_screen.dart:172`
- Rekomendacja: helper `_debounce.cancel(); _debounce = Timer(...);` + `mounted` guard w callbacku.

#### [UI-W-01] Bottom nav 5 zakładek na 320 dp — ryzyko obcięcia etykiet
- File: `lib/features/shell/presentation/app_shell.dart:60-79`
- Rekomendacja: `labelBehavior: NavigationDestinationLabelBehavior.alwaysShow` + krótsze etykiety.

#### [UI-W-02] `_QuickActions` GridView `childAspectRatio: 2.15` — overflow przy dłuższych PL etykietach na 320 dp
- File: `lib/features/dashboard/presentation/dashboard_screen.dart:503-509`
- Rekomendacja: `Wrap` lub `LayoutBuilder` z aspect uwzględniającym textScaler.

#### [UI-W-07] FAB + `bottomNavigationBar` shell — sprawdzić render z gesture nav
- Files: `captures_screen.dart:30-33`, `documents_screen.dart:57-59`, `schedule_plan_screen.dart:61-63`
- Ryzyko: możliwy biały pas pod gesture bar.

#### [UI-W-08] `_selectCaptureType` sheet 82% wysokości bez uwzględnienia `viewInsets`
- File: `lib/features/captures/presentation/captures_screen.dart:776-777`

#### [UI-W-11] Brak `Semantics(label:)` dla ikonografii dashboardu
- File: `lib/features/dashboard/presentation/dashboard_screen.dart` — `_CriticalRow`, ikony `Icons.warning_amber_rounded`.

#### [UI-W-16] `PopScope(canPop: !state.isBusy)` na iOS bez feedbacku
- File: `lib/features/receipt_scan/presentation/receipt_scan_screen.dart:89`
- Rekomendacja: snackbar w `onPopInvokedWithResult`.

#### [UI-W-17] Font Roboto shipped jako asset, nie deklarowany w `fonts:`
- File: `pubspec.yaml:48-50`
- Wpływ: asset ignorowany, na iOS SF jest fallbackiem — TTF bezużyteczny.
- Rekomendacja: albo usunąć asset, albo dodać `fonts:` + przypisanie w `ThemeData`.

#### [I18N-W-27] `_money()` ręczne formatowanie z hardcoded „zł"
- File: `lib/features/dashboard/presentation/dashboard_screen.dart:1029-1040`
- Rekomendacja: `NumberFormat.currency(locale: 'pl_PL', symbol: 'zł')`.

#### [PROD-R8-02] Brak testu release AAB w CI
- File: `.github/workflows/mobile-ci.yml:65`
- Evidence: CI robi tylko `flutter build apk --debug` — R8/shrink nie są testowane w CI.
- Rekomendacja: dedykowany `workflow_dispatch` z podpisem test-keystore + smoke test na release APK.

#### [PROD-CI-04] Brak jobów budujących podpisany AAB w CI (świadome)
- File: `.github/workflows/mobile-ci.yml`
- Rekomendacja: rozważyć osobny `workflow_dispatch` Android-TestTrack analogiczny do `ios-testflight.yml`.

#### [DATA-TX-1] `SqliteProjectRepository.delete()` — pliki poza transakcją, `deletion_pending` może wisieć do restartu
- File: `lib/features/projects/data/sqlite_project_repository.dart:206-231`
- Rekomendacja: mikroraport w UI, recovery także w `onResume`.

#### [DATA-MON-1] `strftime(..., 'localtime')` w raportach budżetowych
- File: `lib/features/reports/data/sqlite_budget_report_repository.dart:82-93`
- Scenariusz: podróż / restore na innym urządzeniu przesuwa koszty do innego miesiąca fiskalnego.
- Rekomendacja: `time_zone_id` na projekcie lub grupowanie po UTC.

#### [DATA-REL-3] Rzutowanie `SUM(...) as int` — potencjalny crash raportu
- Files: `lib/features/costs/data/sqlite_cost_repository.dart:458,460`, `lib/features/reports/data/sqlite_budget_report_repository.dart:178`
- Evidence: SQLite `SUM(INTEGER)` promuje do REAL przy przepełnieniu → `TypeError`.
- Rekomendacja: przez `BigInt.from(row['planned'] as num).toInt()` z guard-em lub agregacja podpaczkowa.

#### [DATA-BR-1] Backup ZIP w tmp — usuwany po Share Cancel
- Files: `lib/features/backup/data/backup_providers.dart:19-22`, `local_backup_gateway.dart:39-48`
- Scenariusz: user klika „Utwórz i udostępnij", zamyka arkusz Cancel → ZIP skasowany, user nie ma kopii.
- Rekomendacja: sprawdzać wynik `SharePlus.share`; traktować `dismissed` jako brak zapisu; opcja „zapisz lokalnie" (Downloads).

---

### P3 — niski priorytet (skrót)

- **[OCR-08]** `TextRecognitionScript.latin` — bez cyrylicy/CJK (poza scope PL).
- **[FS-03]** Fallback `.jpg → image/jpeg` — niespójne z pozostałymi switch.
- **[FS-04]** `Uri.file(...)` bez flagi `windows:` w `captures/receipt_scan` (Windows-only ryzyko).
- **[FS-05]** `ProjectFileStore._validatePathSegment` nie odrzuca Windows-reserved (CON/PRN/NUL) — desktop only.
- **[LIM-03]** `RecognizedReceiptText.maximumCharacters = 32000` — brak sygnału truncation w API.
- **[LIM-04]** Brak `page.dispose()` w pdfrx pętli — obecnie n/a (1 strona), regres przy fix OCR-01.
- **[EXT-02]** Brak preview dla `.docx/.xlsx/…` — kosmetyka.
- **[EXT-03]** `p.extension()` bierze tylko ostatni token (`raport.PDF.exe` → `.exe`).
- **[EXT-04]** ML Kit iOS ścieżka zwraca `.png`, mediaType twardo `image/jpeg` — metadana kłamie.
- **[SEC-S-1..S-3]** Brak sekretów w drzewie — CONFIRMED-clean.
- **[SEC-S-2]** `android/local.properties` w repo z lokalnymi ścieżkami dev — minor leak.
- **[SEC-L-1..L-2]** `debugPrint` w `app_error_guard.dart:29` — bezpieczny (tylko `runtimeType`); brak logu PII.
- **[SEC-A-1..A-2]** Manifest minimalny, `allowBackup=false`, `dataExtractionRules` wykluczają całość — wzorcowo.
- **[SEC-I-3]** `NSUserNotificationsUsageDescription` — klucz nieoficjalny, usunąć.
- **[SEC-I-4]** PrivacyInfo minimalne — wygenerować Privacy Report w Xcode po archive.
- **[SEC-C-4]** iOS `Library/Application Support/` nie wykluczony z iCloud (`NSURLIsExcludedFromBackupKey=true`).
- **[SEC-Z-1..Z-6]** Brak sieci, brak analytics/crash — CONFIRMED (`pubspec.yaml` bez `http/dio/firebase/sentry`); ML Kit poprawnie NIE deklarowane jako „no data" w Data Safety.
- **[ARCH-R3]** `appDatabaseProvider` bez `autoDispose` — świadome.
- **[ARCH-N3]** Router nie waliduje istnienia zasobu przed budową ekranu — dodatkowy flash loading→error.
- **[ARCH-A3]** `unawaited(_reload())` w `initState` — jeśli notifier pęknie, wyjątek znika (patrz A1).
- **[UI-W-03]** `_MetricStrip` — 3 komórki w Row bez fallbacku dla wąskich ekranów.
- **[UI-W-06]** `NavigationDestination.selectedIcon` size 26 hard-coded.
- **[UI-W-10]** `bodyLarge #53605A` — WCAG AA OK, ale `outlineVariant` na `bodySmall` może zejść poniżej.
- **[UI-W-12/13]** Brak `Semantics(button:true)`, brak `excludeSemantics` dla accent-icon w quick actions.
- **[UI-W-19]** Bottom-nav etykiety z ARB — OK.
- **[UI-W-20]** Ikona „Stages" Material vs reszta Lucide 300 — niespójne.
- **[UI-W-21]** `MoreToolsScreen` — bez sekcji/dividerów.
- **[UI-W-25]** Regex sanitizacji nazwy pliku z polskimi znakami — poprawne dla PL.
- **[UI-W-29]** `toStringAsFixed(1)` dla KB/MB — PL powinno być `,`.
- **[I18N-W-34]** Persistencja po zmianie języka bezpieczna (minor units + UTC).
- **[PROD-A-BUILD-05]** `ndkVersion = flutter.ndkVersion` — rozważyć przypięcie.
- **[PROD-A-MAN-07]** `RECEIVE_BOOT_COMPLETED` + receivers `exported=false` — poprawnie.
- **[PROD-I-BUILD-03]** Brak `Runner.entitlements` — OK dla R1.
- **[PROD-A-ROLL-01]** Downgrade SQLite jawnie zabroniony (`onDowngrade` throws) — świadome.
- **[PROD-A-ROLL-02]** Hotfix bez zmiany schematu możliwy (`versionCode` z pubspec).
- **[DATA-MIG-1]** `updated_at_utc_ms = 0` w `app_metadata` po migracji.
- **[DATA-MIG-2]** `current_stage_key` vs `current_stage_key_v2` — dwa równoczesne pola.
- **[DATA-TX-3]** Brak transakcji przy `SqliteMaterialRepository.delete()` + brak `MaterialInUseException`.
- **[DATA-BR-2]** Fingerprint schematu wrażliwy na kolejność definicji indeksów.
- **[DATA-BR-3]** `LocalRestoreJournal._read` — uszkodzony pending cicho ignorowany.
- **[DATA-REL-2]** `recoverUnlinkedAttachments` nie sprawdza `receipt_imports` (obecnie bezpieczne).
- **[DATA-REL-4]** `deleteRoom` cicho kaskaduje `room_record_links` — brak preflight impact.
- **[DATA-MON-3]** `cost_entry_revisions` bez `updated_by` — audyt niepełny.
- **[DATA-MON-4]** VAT `fromStoredValues` walidacja `matchesNet || matchesGross` — mikro-rozjazd grosza.

---

## 3. Ryzyka wymagające potwierdzenia

Znaleziska, których nie da się rozstrzygnąć bez urządzenia, sekretów lub konta sklepowego:

| # | Ryzyko | Kto potwierdza |
|---|---|---|
| Q-01 | Czy `initializeDateFormatting('pl_PL')` jest naprawdę wymagane przy `Locale('pl')` w `supportedLocales` — Flutter potrafi to zainicjalizować automatycznie dla wybranych locale. Wymaga uruchomienia Raportu na urządzeniu i sprawdzenia, czy pada `LocaleDataException`. | Deweloper na urządzeniu |
| Q-02 | Czy `google_mlkit_document_scanner 0.5.0` rzeczywiście ma `pageLimit` konfigurowalny dla wielu stron (patrz OCR-01). | Deweloper w kodzie API |
| Q-03 | Czy po `pod install` na macOS `PrivacyInfo.xcprivacy` z SDK ML Kit / sqflite / notif faktycznie deklaruje `NSUserDefaults`/`SystemBootTime`. | Deweloper na macOS |
| Q-04 | Czy branch protection na `main` wymaga wszystkich 4 checków CI (`quality`, `android`, `android-smoke`, `ios`). | Właściciel repo (Settings → Branches) |
| Q-05 | Czy właściciel konta Play Console podlega wymogowi 12 testerów × 14 dni (nowe konta personalne od listopada 2023). | Właściciel w Play Console |
| Q-06 | Czy `https://przemyslawsobczyk123-lgtm.github.io/budowapro-app/privacy/` jest realnie zaakceptowany jako publiczna polityka R1. | Właściciel |
| Q-07 | Czy `file_picker 11.0.2` na iOS 14+ używa `PHPickerViewController` — jeśli tak, `NSPhotoLibraryUsageDescription` można usunąć (SEC-I-2). | Deweloper w kodzie pluginu |
| Q-08 | Czy wygenerowany release AAB przechodzi `bundletool build-apks --check-16k-alignment` z aktualnymi wersjami ML Kit / sqflite / `flutter_local_notifications`. | Deweloper lokalnie (Windows/Linux) |
| Q-09 | Czy realny `NUL.pdf` / `CON.pdf` na Windowsie powoduje faktyczny błąd — obecnie desktop nie jest platformą docelową. | Nie do testu na Android/iOS |
| Q-10 | Czy 512 MB attachment rzeczywiście prowadzi do OOM/killa na urządzeniach 3 GB RAM — wymaga testu obciążeniowego. | Deweloper na urządzeniu |

---

## 4. Braki testowe

Konkretne testy do dopisania (nie zalecenia ogólne):

1. **`ReceiptOcr` multi-page PDF integration** — PDF ≥2 stron; asercja że `recognizedText.value` zawiera fragmenty każdej strony (OCR-01).
2. **`ReceiptOcr` total tie-break** — wejście z dwoma „RAZEM" o równym score; oczekiwać pierwszego (OCR-02).
3. **`parseReceiptMinorUnits` NBSP** — `"1 234,56"` → `123456` (OCR-03).
4. **`_checkDuplicates` seller-key collision** — dwa różne paragony „Żabka" tego samego dnia na tę samą kwotę z różnymi `documentNumber` → NIE duplikat (DUP-01).
5. **`LocalReceiptOcrImagePreparer.prepare` downscale** — wejście 8000×6000 → wyjściowy plik ≤1600 px na krótszym boku (OCR-07).
6. **`LocalFilePreflight.inspectImage` 48 MP** — oczekiwać `FormatException` „obraz za duży" po obniżeniu limitu (LIM-02).
7. **`CaptureAttachmentPicker.photo` .svg** — asercja przyjaznego błędu (nie `UnsupportedError`) (EXT-01).
8. **`LocalAttachmentStager.stage` path traversal** — `displayName="../../evil.pdf"` → sanityzowany lub rzucony błąd (FS-02).
9. **`LocalPrivateCacheCleaner`** — po restarcie usuwa `budowapro_receipt_ocr_*`, `budowapro_preview_*` (FS-06).
10. **`SqliteMaterialRepository.delete` z otwartą dostawą** → `MaterialInUseException` (DATA-TX-3).
11. **`LocalDataDeletionService.deleteAll`** z mockowaną porażką `databaseFile.delete()` → brak niespójnego stanu widocznego użytkownikowi po restarcie (TX-2).
12. **Kontrolery Riverpod post-dispose** — dla każdego z 13 kontrolerów: wywołać `loadNext()`, natychmiast `container.invalidate(...)`, asertować brak wyjątku (R1/R2).
13. **`AppShell` hardware back** — widget test wysyłający `popRoute` w tabie ≠ 0 → oczekiwać przejścia do tab 0, nie zamknięcia (N1).
14. **`/projects/:id/quotes/compare?ids=nope,valid`** — widget test; missing id filtrowany, nie psuje całego ekranu (N2).
15. **`AppErrorGuard.report`** — po throw w microtasku plik rotacyjnego logu ma wpis (A1).
16. **Golden bottom-nav @ 320 dp, textScaler 1x/2x** — brak overflow (W-01/W-05).
17. **Widget test edytora etapu z otwartą klawiaturą** — CTA „Zapisz" widoczny (W-04).
18. **Smoke Reports/Schedule** — Uruchomienie `BudgetReportScreen` i `SchedulePlanScreen` z polskim locale → brak crash (I18N-01).
19. **Downgrade SQLite** — asercja `StateError` z `_migrate` przy sztucznym `onDowngrade` (A-ROLL-01).
20. **Migracja v17 → v18** — na realnej próbce danych; round-trip nie gubi wierszy.
21. **`_schemaFingerprint` fresh vs step-by-step** — dla każdej migracji powinny być równe (BR-2).
22. **Instrumented test API 33/34** — `canLaunchUrl(Uri.parse('tel:...'))`, `mailto:`, `https:` = `true` (A-MAN-03).
23. **CI Xcode step** — `xcodebuild archive` + `xcrun altool --validate-app` sprawdzający kompletność deklaracji `NSPrivacyAccessedAPI*` (I-PRIV-01).
24. **CI release AAB smoke** — obfuscated release APK, integration test na emulatorze API 28 i 36 (R8-02).
25. **VAT fuzzing** — zapis → odczyt → zapis nie zmienia kwot (MON-4).
26. **Fixture SUM > 2^62 grosze** — nie crashuje (REL-3/MON-2).
27. **Test integracyjny „ubij proces w trakcie `deleteProjectFiles`"** — po restarcie pending znika (TX-1).
28. **Symulacja `SharePlus.share` = `dismissed`** — UI komunikuje „nie zapisano" (BR-1).

---

## 5. Zgodność produkcyjna

### 5.1 Android — Google Play

| Element | Stan | Uwaga |
|---|---|---|
| `applicationId` = `pl.budowapro` | ✅ | `build.gradle.kts:38` |
| `compileSdk = 36`, `targetSdk = 36`, `minSdk = 28` | ✅ | Spełnia politykę Play (target 35+ obowiązuje od sierpnia 2025) |
| `versionCode/Name` z pubspec (`1.0.0+1`) | ✅ | `build.gradle.kts:56-57` |
| ProGuard/R8 + shrinkResources | ✅ | `build.gradle.kts:74-88` |
| NDK debug symbols | ✅ | `SYMBOL_TABLE` |
| Keystore + `BUDOWAPRO_UPLOAD_*` | ⛔ | **P0 blocker właściciela** — patrz PROD-01 |
| 16 KB alignment (obowiązek od 1.11.2025) | ⚠️ | wymaga uruchomienia `tool/release/build_android_release.dart` — patrz PROD-A-BUILD-04 |
| Manifest `allowBackup=false`, `dataExtractionRules` | ✅ | wzorcowo |
| Manifest `<queries>` dla `tel/mailto/https` | ⛔ | **P1** — patrz PROD-A-MAN-03 |
| `POST_NOTIFICATIONS` + runtime request | ✅ | `local_schedule_notification_gateway.dart:101-128` |
| Brak `SCHEDULE_EXACT_ALARM` (`inexactAllowWhileIdle`) | ✅ | zgodne z Play |
| CI (`mobile-ci.yml`) — analyze/test/debug APK/smoke API 28+36 | ✅ | 4 joby, brak `pull_request_target`, brak sekretów |
| Release AAB smoke w CI | ⛔ | **P2** — patrz R8-02 |
| Data Safety — deklaracja dla ML Kit | ✅ | `PRIVACY_AND_GOOGLE_PLAY_RELEASE.md:133-146` |
| Dane wydawcy | ⛔ | **P0** — patrz PROD-02 |
| Testy na fizycznym Androidzie | ⛔ | **P1** — patrz S-06 |

### 5.2 iOS — App Store / TestFlight

| Element | Stan | Uwaga |
|---|---|---|
| `PRODUCT_BUNDLE_IDENTIFIER = pl.budowapro` | ✅ | `project.pbxproj:367,389,493,544,568,590` |
| `IPHONEOS_DEPLOYMENT_TARGET = 15.5` | ✅ | zgodne z ML Kit 0.16.0/0.5.0 |
| `ITSAppUsesNonExemptEncryption=false` | ✅ | `Info.plist:37-38` |
| `PrivacyInfo.xcprivacy` istnieje | ⚠️ | **P1** — brak `UserDefaults`/`SystemBootTime` (PROD-I-PRIV-01) |
| SDK privacy manifesty | ⚠️ | **P1** — niepotwierdzone bez macOS (PROD-I-PRIV-02) |
| `NSPhotoLibraryUsageDescription` | ⚠️ | **P2** — może być niepotrzebne przy PHPicker (SEC-I-2) |
| `NSUserNotificationsUsageDescription` | ⚠️ | **P3** — klucz nieoficjalny, usunąć (SEC-I-3) |
| App ID + cert dystrybucji + profil App Store | ⛔ | **P0 blocker właściciela** — 7 sekretów TestFlight (`IOS_TESTFLIGHT_SETUP.md:20-40`) |
| CI `ios-testflight.yml` — walidacja 10 sekretów, `workflow_dispatch`, `manual` signing | ✅ | fail-closed, brak wycieku |
| CI `mobile-ci.yml ios` job — `macos-26`, Xcode 26/iOS SDK 26 unsigned compile | ✅ | |
| Testy na fizycznym iPhonie | ⛔ | **P1** — patrz S-06 |
| Splash / LaunchScreen storyboard | ✅ | `ios/Runner/Base.lproj/LaunchScreen.storyboard` |
| Zestaw ikon | ✅ | 15 PNG + `Contents.json` |

### 5.3 Prywatność

| Aspekt | Stan | Uwaga |
|---|---|---|
| Brak sieci (`http`/`dio`/Firebase/Sentry) | ✅ CONFIRMED | grep w `pubspec.yaml` |
| Brak logowania PII | ✅ CONFIRMED | 1 `debugPrint` (`app_error_guard.dart:29`) — tylko `runtimeType` |
| Manifest Android minimalny | ✅ | tylko `POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED` |
| `allowBackup=false` + reguły wykluczające | ✅ | wzorcowo |
| Sekrety w drzewie | ✅ CONFIRMED-clean | `.gitignore` chroni `key.properties`, `*.jks`, `*.keystore` |
| Backup ZIP nieszyfrowany | ⚠️ | **P2** — patrz SEC-C-2 |
| iOS `Library/Application Support` w iCloud backup | ⚠️ | **P3** — dodać `NSURLIsExcludedFromBackupKey=true` (SEC-C-4) |
| `local.properties` w repo (ścieżki dev) | ⚠️ | **P3** — dodać do `.gitignore` (SEC-S-2) |
| Deklaracje Data Safety vs kod | ✅ | Spójne (ML Kit nie zadeklarowane jako "no data") |

### 5.4 Prawo / dokumentacja

- Polityka prywatności — wersja szkicowa istnieje w `docs/PRIVACY_POLICY_DRAFT.md`, publikacja na GitHub Pages (`site/`) w pipeline (`legal-pages.yml`). Wymaga formalnej publikacji + wpisu URL w konfiguracji release.
- Regulamin/EULA — nie znaleziono osobnego dokumentu (może nie być wymagane w tej klasie aplikacji, ale App Store często pyta).
- Wskazówki budowlane w `stage_guidance.dart` — treści zawierają odniesienia do przepisów (GUNB, wzory zawiadomień). Wymaga jednorazowej weryfikacji prawnika przed produkcją, aby uniknąć wrażenia „porady prawnej"/„projektu technicznego".

### 5.5 Sklepowe deklaracje

- Play Data Safety — poprawnie NIE deklaruje „No data collected" (`PRIVACY_AND_GOOGLE_PLAY_RELEASE.md:133-146`).
- App Store App Privacy — do wypełnienia w Xcode/App Store Connect w oparciu o `PrivacyInfo.xcprivacy` po dodaniu brakujących kategorii (PROD-I-PRIV-01).

---

## 6. Mocne strony (utrzymać, nie przebudowywać)

- **Migracje SQLite (`app_database.dart`)** — przyrostowe, idempotentne (`PRAGMA table_info` przed `ALTER TABLE ADD COLUMN`), FK włączone globalnie, WAL sprzątany przy restore.
- **Backup/restore** — wzorcowo defensywny: dziennik z sekwencjami stanu (`prepared → oldMoved → newMoved → committed`), SHA-256 dla katalogu przed atomowym `rename`, weryfikacja miejsca (`restoreSafetyMarginBytes = 64 MiB`), sanityzacja ścieżek ZIP, odmowa kopii z nowszą wersją schematu, izolaty.
- **Pieniądze i VAT** — konsekwentnie `int` grosze + `BigInt` do arytmetyki + `_divideRoundedHalfAwayFromZero` half-away-from-zero. Zero `double` w polach kwotowych.
- **Granice warstw** — `domain/` nie importuje Fluttera/SQL/pluginów; `data/` nie zna `presentation/`. Zero naruszeń w 226 plikach `.dart`.
- **Riverpod cleanup** — providery zamykają zasoby (`ref.onDispose(() => database.close())`), dashboard controller robi poprawny `ref.mounted` guard (wzorzec do przeniesienia na pozostałych 13 kontrolerów).
- **Off-main-thread OCR / PDF / backup** — `Isolate.run` w backupie (`local_backup_service.dart:304,351,420`), pdfrx z `document.dispose()` w `finally`, ML Kit zamykany w `finally`.
- **Wzorce loading/error/empty** — `AppLoadingState`, `AppErrorState`, `AppEmptyState` używane konsekwentnie z retry.
- **Kontakt picker** — używa systemowego `ACTION_PICK` (Android) / `CNContactPickerViewController` (iOS) **bez** żądania `READ_CONTACTS` / bez zgody CNContactStore. Wzorcowe.
- **CI security** — brak `pull_request_target`, walidacja obecności/formatu sekretów TestFlight (10 sekretów), `workflow_dispatch` na wydania, `permissions: contents: read`.
- **Release tooling (`tool/release/`)** — 30 testów (`release_support_test.dart`) waliduje 16 KB alignment, allowlist uprawnień, SHA-256 fingerprint cert, R8 rules, jarsigner. Fail-closed.
- **Sanityzacja `ProjectFileStore`** — `_ensureContainedDirectory` chroni przed path traversal i symlinkami.
- **`.part` sufiks + `rename` atomowy** — import pliku bez ryzyka połowicznych plików po crashu.
- **Brak sieci / analytics / crash SDK** — decyzja architektoniczna konsekwentnie egzekwowana; wzmacnia zaufanie do „local-first".

---

## 7. Plan napraw

### 7.1 Blokery wydania (obowiązkowe przed jakimkolwiek roll-out)

1. **PROD-01** Właściciel: keystore + 5 sekretów `BUDOWAPRO_UPLOAD_*` + Play App Signing.
2. **PROD-02** Właściciel: zatwierdzenie danych wydawcy (nazwa, e-mail, URL polityki, URL wsparcia).
3. **PROD-A-BUILD-04** Uruchomienie `tool/release/build_android_release.dart` na docelowej gałęzi tuż przed wysyłką; potwierdzenie 16 KB alignment.
4. **PROD-A-MAN-03** Dodanie `<queries>` dla `tel/mailto/https` w `AndroidManifest.xml` + rozszerzenie `tool/release/release_support.dart` allowlist.
5. **PROD-I-PRIV-01** Uzupełnienie `PrivacyInfo.xcprivacy` o `UserDefaults` (`CA92.1`) i `SystemBootTime` (`35F9.1`).
6. **PROD-I-PRIV-02** `pod install` + audyt manifestów prywatności podów (macOS).
7. **iOS App ID + certyfikat + profil App Store + 7 sekretów TestFlight** (`IOS_TESTFLIGHT_SETUP.md:20-40`).
8. **OCR-01** Multi-page OCR — usunąć `pageLimit: 1` i iterować `document.pages`.
9. **I18N-01** `initializeDateFormatting('pl_PL')` w `main.dart` (po weryfikacji na urządzeniu — patrz Q-01).
10. **Testy na fizycznym Androidzie i iPhonie** (S-06) — smoke: brak baterii, brak sieci, restart podczas OCR, TestFlight.

### 7.2 Przed pierwszą produkcją (recommended)

1. **ARCH-R1/R2** — `ref.mounted` guardy w 13 kontrolerach (systemowe).
2. **ARCH-N1** — `PopScope` w `AppShell`.
3. **PERF-P1** — `cacheWidth` w galeriach zdjęć.
4. **OCR-02/05/DUP-01** — poprawki totalu, mismatch persistence, sygnatura duplikatu.
5. **OCR-LIM-01/02** — obniżenie limitów bytes i pikseli.
6. **OCR-EXT-01** — `allowedExtensions` w `capture_attachment_picker.dart`.
7. **UI-W-04/W-05** — sheet klawiatura + bottom nav 2x scale.
8. **I18N-W-23/W-24** — `revision` do ARB, CSV title do ARB.
9. **DATA-TX-2** — legal reset: odwrócić kolejność DB → files, tombstone.
10. **DATA-REL-1** — migracja v19: FK ON DELETE dla `materials.*`.
11. **DATA-MON-1** — usunąć `'localtime'` z raportów; time_zone_id per projekt.
12. **DATA-REL-3** — bezpieczne rzutowanie `SUM(...)`.
13. **SEC-C-2** — opcjonalne szyfrowanie ZIP backupu.
14. **PROD-R8-02** — release AAB smoke w CI (workflow_dispatch z test-keystore).

### 7.3 Po wydaniu (nice-to-have)

1. **I18N-W-28/W-31/W-33** — pełne EN: ARB, VAT konfigurowalny, tokens OCR per locale.
2. **FS-02** — sanityzacja `display_name` (path traversal).
3. **FS-06** — `LocalPrivateCacheCleaner` obejmujący prefixy OCR/preview.
4. **ARCH-A1** — rotacyjny log crashów w release.
5. **DUP-02** — pre-check SHA-256 przy imporcie.
6. **UI-W-01/W-02** — golden testy 320 dp + textScaler 2x.
7. **SEC-I-3** — usunąć klucz `NSUserNotificationsUsageDescription`.
8. **SEC-C-4** — `NSURLIsExcludedFromBackupKey=true` na `Library/Application Support/`.
9. **DATA-BR-1** — Share Cancel handling + opcja „zapisz lokalnie".
10. **DATA-MIG-2** — migracja finalna łącząca `current_stage_key` / `_v2`.

---

## 8. Wykonane polecenia

Wszystkie polecenia uruchomione w `C:\Users\Przemyslaw\BudowaPRO`.

### `dart format --output=none --set-exit-if-changed lib test integration_test tool`
- Exit code: **0**
- Wynik: `Formatted 343 files (0 changed) in 14.22 seconds.`

### `flutter analyze --no-pub`
- Exit code: **0**
- Wynik: `No issues found! (ran in 237.8s)`
- Uwaga: dostępna nowsza wersja Flutter (info-print, bez wpływu na wynik).

### `flutter test --concurrency=1 --no-pub`
- Exit code: **0**
- Wynik: `All tests passed!` — łącznie **565 testów** (`+565` — ostatni licznik: `+565`).
- Pokrycie obejmuje m.in. `local_private_cache_cleaner_test.dart` (5 testów), `app_content_states_test.dart` (3), `release_support_test.dart` (14 — walidacja allowlisty uprawnień, 16 KB alignment, R8, jarsigner).

### `flutter build apk --debug --no-pub`
- Exit code: **0**
- Wynik: `Built build\app\outputs\flutter-apk\app-debug.apk` (240,8 s).
- Ostrzeżenie (nieblokujące):
  > WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): file_picker, flutter_timezone, google_mlkit_commons, google_mlkit_document_scanner, google_mlkit_text_recognition, package_info_plus, share_plus
  > Future versions of Flutter will fail to build if your app uses plugins that apply KGP.

  Docelowo (przyszłe wersje Fluttera) wymagana będzie migracja tych wtyczek na Built-in Kotlin. Obecnie nie jest to blocker, ale wpłynie na przyszłe aktualizacje Fluttera → sekcja 7.3.

### Otoczenie
- Git HEAD: `7b9d823 feat: refresh app navigation icons`
- Working tree: czyste.
- pubspec `1.0.0+1`, Dart SDK constraint `^3.12.2`.
- 226 plików `.dart` w `lib/`, 113 w `test/` + `integration_test/`.

---

## Załącznik — kluczowe pliki do dalszej pracy

Pliki najczęściej wymieniane w znaleziskach (posortowane malejąco po liczbie referencji):

- `lib/core/database/app_database.dart` (schemat, migracje, FK)
- `lib/features/receipt_scan/domain/receipt_ocr.dart` (parser)
- `lib/features/receipt_scan/domain/receipt_financial.dart` (dedup, sygnatury)
- `lib/features/receipt_scan/domain/receipt_review.dart` (draft, mismatch)
- `lib/features/receipt_scan/data/receipt_capture_adapters.dart` (skaner, PDF, MIME)
- `lib/features/receipt_scan/data/receipt_ocr_image_preparer.dart` (downscale, temp)
- `lib/features/receipt_scan/data/local_receipt_scan_gateway.dart` (empty state)
- `lib/features/documents/data/local_attachment_stager.dart` (sanityzacja, hash, GC)
- `lib/features/documents/presentation/documents_controller.dart` (Riverpod pattern)
- `lib/features/shell/presentation/app_shell.dart` (bottom nav, PopScope)
- `lib/features/stages/presentation/stage_editor_dialogs.dart` (klawiatura)
- `lib/features/stages/domain/stage_guidance.dart` (hardcoded PL)
- `lib/features/costs/domain/vat_breakdown.dart` (VAT stawki)
- `lib/features/costs/domain/money.dart` (referencyjny wzorzec kwot)
- `lib/features/costs/data/sqlite_cost_repository.dart` (SUM, delete)
- `lib/features/reports/data/sqlite_budget_report_repository.dart` (localtime, SUM)
- `lib/features/reports/presentation/budget_report_screen.dart` (DateFormat)
- `lib/features/materials/data/sqlite_material_repository.dart` (brak FK, brak MaterialInUseException)
- `lib/features/legal/data/local_data_deletion_service.dart` (kolejność files → DB)
- `lib/features/backup/data/local_backup_service.dart` (wzorcowa robota)
- `lib/features/backup/data/local_backup_gateway.dart` (Share/cleanup)
- `lib/features/exports/data/local_cost_csv_export_gateway.dart` (share title PL)
- `lib/features/captures/data/capture_attachment_picker.dart` (whitelist)
- `lib/core/files/project_file_store.dart` (path validation)
- `lib/core/files/local_file_preflight.dart` (48 MP → 192 MB)
- `lib/core/config/storage_policy.dart` (512 MB limit)
- `lib/core/errors/app_error_guard.dart` (rotacyjny log w release)
- `lib/core/routing/app_router.dart` (deep links)
- `lib/core/theme/app_theme.dart` (bottom nav height, textScaler)
- `lib/l10n/app_pl.arb`, `lib/l10n/app_localizations.dart` (EN, initializeDateFormatting)
- `android/app/src/main/AndroidManifest.xml` (`<queries>`)
- `android/app/build.gradle.kts` (signing, sdk)
- `android/app/proguard-rules.pro`
- `ios/Runner/Info.plist` (klucze prywatności)
- `ios/Runner/PrivacyInfo.xcprivacy` (kategorie API)
- `tool/release/release_support.dart` (allowlist manifest / queries)
- `.github/workflows/mobile-ci.yml` (release AAB smoke)
- `.github/workflows/ios-testflight.yml`

---

**Koniec raportu.** Wszystkie znaleziska pochodzą z analizy statycznej — właściciel powinien zweryfikować każde ustalenie w kodzie przed wdrożeniem poprawki.
