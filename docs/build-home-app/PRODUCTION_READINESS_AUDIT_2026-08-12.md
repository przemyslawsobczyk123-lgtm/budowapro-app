# BudowaPRO - audyt gotowosci produkcyjnej Android / Google Play

Data audytu: 2026-08-12.

Zakres: aktualny kod i konfiguracja repozytorium, istniejacy artefakt AAB,
automatyzacja release, manifest Androida, CI, dokumenty sklepowe i publiczne
strony prawne. Raport nie zawiera sekretow, odciskow certyfikatow ani prywatnych
danych wydawcy.

## Werdykt

**Nie znaleziono potwierdzonego blockera w konfiguracji Androida. Aktualny
refaktor przeszedl lokalnie analizator i 639 z 639 testow w konfiguracji CI.
Ostatni opublikowany commit nadal ma czerwony historyczny workflow (616/617),
dlatego przed finalnym release trzeba wyslac zmiany i uzyskac nowy zielony
przebieg. Aplikacja nie jest gotowa do wyslania jako finalny release do czasu
wykonania czynnosci wlasciciela i zbudowania nowego AAB.**

Najwazniejsze fakty:

- `applicationId` to `pl.budowapro`, a `compileSdk` i `targetSdk` maja wartosc
  36;
- release ma R8, shrinking zasobow, symbole natywne i fail-closed signing;
- istniejacy AAB `1.0.0+1` przeszedl kontrole podpisu, allowlisty uprawnien,
  konfiguracji 16 KB, ELF i `zipalign -P 16`;
- ten AAB zostal podpisany jednorazowym kluczem kontrolnym, ktorego nie wolno
  traktowac jako finalnego klucza upload;
- bieżący katalog roboczy zawiera zmiany nowsze niz istniejacy AAB, dlatego
  artefakt trzeba zbudowac ponownie po zatwierdzeniu kodu;
- publiczne strony `/privacy/`, `/support/`, `/terms/` i `/data-deletion/`
  odpowiadaja HTTP 200 i maja typ `text/html`;
- aktualna deklaracja Data Safety uwzglednia techniczne metryki Google ML Kit;
- GitHub CI dla aktualnego HEAD: analyze przeszedl, testy zakonczyly sie wynikiem
  616/617, a pozostale zalezne joby zostaly pominiete;
- aktualny lokalny refaktor: `flutter analyze` bez uwag oraz `flutter test
  --concurrency=1` z wynikiem 639/639 (potwierdzone 2026-08-13);
- finalne zmienne `BUDOWAPRO_UPLOAD_*` i pozostale zmienne release nie sa
  skonfigurowane w obecnym srodowisku.

## 1. Potwierdzone blokery kodowe

Nie znaleziono potwierdzonego bledu w konfiguracji Androida lub Gradle. Czerwony
workflow dotyczy ostatniego opublikowanego commita, ale jego pojedynczy blad nie
odtwarza sie w aktualnym katalogu roboczym: kompletna lokalna reprodukcja tej
samej komendy zakonczyla sie wynikiem 639/639. Przed finalnym AAB trzeba jednak
wyslac obecny kod i uzyskac zielony wynik w czystym srodowisku GitHub Actions.

Nie oznacza to zgody na publikacje obecnego pliku. Brak finalnego podpisu,
formularzy sklepowych i testow finalnego artefaktu to blokery wydaniowe, ale
nie blokery kodowe.

## 2. Blokery wydaniowe wymagajace wlasciciela

| Priorytet | Czynność | Dlaczego blokuje |
| --- | --- | --- |
| P0 | Utworzyc i bezpiecznie zachowac finalny klucz upload, wlaczyc Play App Signing oraz skonfigurowac komplet `BUDOWAPRO_UPLOAD_*`. | AAB musi byc podpisany kluczem upload rozpoznawanym przez Play. Obecny klucz kontrolny zostal usuniety. |
| P0 | Zatwierdzic aktualne zmiany w Git i uruchomic `dart run tool/release/build_android_release.dart` bez `--allow-dirty` oraz bez `--validation`. | Istniejacy AAB nie zawiera biezacych zmian. Helper celowo odrzuca brudne wydanie. |
| P0 | Uzupelnic i zatwierdzic App content w Play Console: Privacy policy, Data Safety, reklamy, dostep do aplikacji, grupa docelowa, rating, government, financial i health. | Formularzy nie da sie zatwierdzic na podstawie samego repozytorium. Sa oceniane razem z aktywnymi artefaktami. |
| P0 | Potwierdzic profil organizacji, telefon, dane prawne i publiczne dane dewelopera w Play Console. | Dane konta i strony musza nalezec do tego samego wydawcy. |
| P1 | Wyslac finalny AAB najpierw na Internal testing i wykonac smoke na fizycznym urzadzeniu. | Statyczna walidacja AAB nie wykrywa bledow OEM, selektora kontaktow, OCR, powiadomien i restartu procesu. |
| P1 | Sprawdzic w App bundle explorer, czy `versionCode=1` nie byl juz wykorzystany. | Google Play nie pozwala ponownie wyslac innego AAB z uzytym `versionCode`. W takim przypadku trzeba ustawic co najmniej `1.0.0+2`. |
| P1 | Zachowac poza ignorowanym katalogiem `build/` finalny AAB, metadata release, mapping R8, symbole Dart i symbole natywne. | Sa potrzebne do diagnostyki i odtworzenia dowodow wydania. |

## 3. Podpisywanie, AAB i release helper

Stan kodu jest dobry:

- `android/app/build.gradle.kts` nie podpina debugowego podpisu do release;
- brak wymaganych danych signing powoduje zatrzymanie release;
- sekrety i pliki keystore sa ignorowane przez Git;
- helper sprawdza odcisk certyfikatu, wynik `jarsigner`, manifest, R8, 16 KB,
  64-bitowe ELF-y oraz uniwersalny APK;
- helper uruchamia `pub get`, generowanie lokalizacji, format, analizator i pelny
  zestaw testow przed zbudowaniem AAB;
- wydanie jest obfuskowane, a mapy i symbole sa archiwizowane obok artefaktu;
- pobierany `bundletool 1.18.3` jest przypiety wersja i SHA-256.

Istnieje jedna niespojnosc dowodowa: metadata istniejacego AAB ma
`validationOnly=false`, ale raport wydania potwierdza jednorazowy klucz
kontrolny. Ten plik nalezy jednoznacznie oznaczyc jako **nie do wyslania na
test/production track**. Finalny raport musi wskazywac certyfikat finalnego
klucza upload.

Google wymaga podpisania AAB kluczem upload; Play App Signing przechowuje osobny
klucz podpisujacy APK dostarczane uzytkownikom:
<https://developer.android.com/studio/publish/app-signing>.

## 4. SDK, 16 KB i kompatybilnosc

| Kontrola | Wynik | Ocena |
| --- | --- | --- |
| `compileSdk = 36` | Potwierdzone w Gradle | OK |
| `targetSdk = 36` | Potwierdzone w Gradle | OK, spelnia wymaganie Android 16/API 36 obowiazujace nowe aplikacje i aktualizacje od 2026-08-31 |
| `minSdk = 28` | Potwierdzone | OK dla deklarowanego zakresu urzadzen |
| Java/Kotlin JVM 17 | Potwierdzone | OK |
| AGP 9.0.1 / Gradle 9.1 | Potwierdzone | Biezacy build przechodzi, ale patrz ryzyko Kotlin ponizej |
| 16 KB bundle config | `PAGE_ALIGNMENT_16K` w metadata | PASS |
| 16 KB native ELF | Sprawdzone dla AAB i uniwersalnego APK | PASS dla istniejacego AAB |
| 16 KB ZIP alignment | `zipalign -P 16` | PASS dla istniejacego AAB |

Od 2025-11-01 nowe aplikacje i aktualizacje targetujace Android 15+ musza
obslugiwac strony pamieci 16 KB:
<https://developer.android.com/guide/practices/page-sizes>.

PASS dotyczy konkretnego istniejacego AAB. Finalny AAB z aktualnego commita i
finalnego podpisu musi przejsc ten sam helper; dodatkowo nalezy uruchomic go na
emulatorze lub urzadzeniu 16 KB.

## 5. Manifest, uprawnienia i package visibility

Finalny merged manifest kontrolnego AAB zawieral tylko allowliste helpera:

- dostep do sieci wymagany przez zaleznosci ML Kit;
- stan sieci;
- powiadomienia;
- odbior zdarzenia restartu;
- wibracje;
- wewnetrzne uprawnienie dynamicznego receivera aplikacji.

Nie ma szerokiego dostepu do pamieci, lokalizacji, aparatu, mikrofonu, SMS,
historii polaczen ani `READ_CONTACTS`. Kontakt jest wybierany systemowym
`ACTION_PICK`, a aplikacja odczytuje tylko URI wskazane przez uzytkownika.
Powiadomienia prosza o zgode runtime, a harmonogram uzywa trybu niedokladnego,
wiec aplikacja nie deklaruje `SCHEDULE_EXACT_ALARM`.

`<queries>` zawiera tylko wpis `PROCESS_TEXT` dostarczany dla integracji
Fluttera. To jest poprawne. BudowaPRO uzywa bezposredniego `launchUrl`, a nie
`canLaunchUrl`/`queryIntentActivities`. Oficjalna dokumentacja Androida
potwierdza, ze bezposredni `startActivity()` nie wymaga widocznosci pakietu;
`<queries>` jest potrzebne dopiero do zapytania, czy obca aplikacja istnieje:
<https://developer.android.com/training/package-visibility/use-cases>.

## 6. Prywatnosc, Data Safety i dane wydawcy

Stan repozytorium jest spojny z lokalnym R1:

- brak konta, backendu, reklam, Firebase Analytics i Crashlytics;
- dane projektu pozostaja w prywatnej pamieci aplikacji;
- systemowy Android backup i transfer urzadzenia sa wylaczone oraz dodatkowo
  wykluczone regulami XML;
- reczna kopia ZIP jest jawnie opisana w aplikacji i polityce jako
  nieszyfrowana;
- aplikacja ma ekran polityki, warunkow, ustawien prywatnosci i usuwania
  wszystkich danych lokalnych;
- publiczne strony prawne i wsparcia sa dostepne pod produkcyjna domena;
- kod release wymaga publicznego HTTPS dla polityki i wsparcia;
- dane prawne w aplikacji i na stronie istnieja, ale ich zgodnosc z profilem
  organizacji musi zatwierdzic wlasciciel w Play Console.

`store/privacy/store-declarations.md` prawidlowo nie deklaruje "No data
collected". Ujawnia dla ML Kit kategorie odpowiadajace interakcjom aplikacji,
diagnostyce oraz identyfikatorom urzadzenia/instalacji, z celami diagnostyki i
analityki, szyfrowaniem HTTPS i bez udostepniania stronom trzecim. Oficjalny
opis ML Kit potwierdza lokalne przetwarzanie obrazu/tekstu oraz wysylanie
metryk technicznych:
<https://developers.google.com/ml-kit/android-data-disclosure>.

Formularz Data Safety trzeba wypelnic nawet wtedy, gdy aplikacja nie zbiera
innych danych. Dotyczy to takze closed/open/production track; sam internal
track jest wyjatkiem:
<https://support.google.com/googleplay/android-developer/answer/10787469>.

BudowaPRO nie tworzy kont, wiec obowiazek usuwania konta nie ma zastosowania.
Publiczna instrukcja usuwania danych jest mimo to przydatna i zgodna ze stanem
lokalnym. Przed dodaniem subskrypcji, reklam, backendu, logowania lub telemetryki
trzeba ponowic audyt i zaktualizowac polityke oraz Data Safety.

## 7. CI i testy sklepowe

Aktualny `mobile-ci.yml` zapewnia:

- `flutter analyze`;
- pelny `flutter test --concurrency=1`;
- debug APK;
- Android smoke na API 28 i 36;
- unsigned iOS compile.

Workflow ma minimalne `permissions: contents: read` i nie uzywa
`pull_request_target`. To dobra baza. Nie ma jednak joba budujacego i
sprawdzajacego release AAB z R8 ani automatycznego uploadu na Internal testing.
Nie jest to wymog Play, ale pozostaje najwazniejsza luka CI. Manualny helper
pokrywa walidacje release, pod warunkiem ze rzeczywiscie zostanie uruchomiony
przed kazdym uploadem.

Aktualny wynik GitHub Actions dla opublikowanego commita `f2a3a26` jest czerwony:

- analyze: **success**;
- test: **616/617**, jeden test nie przeszedl;
- pozostale joby zalezne: **skipped**.

Aktualny refaktor lokalny przeszedl natomiast `flutter analyze` oraz pelny
`flutter test --concurrency=1` z wynikiem 639/639. Historycznego czerwonego runu
nie mozna uznac za aktualny blad kodu, lecz zielony przebieg CI po wyslaniu zmian
pozostaje obowiazkowym dowodem przed release.

Konto organizacyjne nie jest co do zasady objete wymogiem 12 testerow przez 14
dni, ktory dotyczy nowych kont osobistych utworzonych po 2023-11-13. Ostateczny
stan pokazany przez Play Console ma pierwszenstwo. Niezaleznie od formalnego
wymogu rekomendowany jest Internal testing, a potem kontrolowany closed test:
<https://support.google.com/googleplay/android-developer/answer/9845334>.

## 8. Wersjonowanie, backup i rollback

- `pubspec.yaml` ma obecnie `1.0.0+1`.
- Jezeli kod `1` nie byl wyslany do zadnego zwyklego tracka, moze pozostac dla
  pierwszego finalnego AAB. Jezeli byl uzyty, trzeba go zwiekszyc.
- Kazda kolejna wersja musi miec wyzszy `versionCode`:
  <https://developer.android.com/studio/publish/versioning>.
- Lokalny backup/restore waliduje format, checksumy, sciezki, miejsce na dysku i
  wersje schematu; restore ma dziennik i rollback przerwanej operacji.
- Baza odrzuca downgrade schematu. Rollback produkcyjny oznacza zatrzymanie
  rollout i wydanie poprawki z wyzszym `versionCode`, a nie instalacje starszej
  bazy.
- Dla pierwszej publikacji staged rollout procentowy nie jest dostepny tak jak
  dla aktualizacji. Najpierw nalezy wykorzystac test tracks. Dla kolejnych
  wersji rollout mozna zatrzymac:
  <https://support.google.com/googleplay/android-developer/answer/6346149>.

## 9. Ostrzezenia pluginow Kotlin

Projekt uzywa AGP 9 z tymczasowym trybem zgodnosci:

- `android.builtInKotlin=false`;
- `android.newDsl=false`;
- lokalny workaround dla `file_picker`;
- czesc aktualnych pluginow nadal aplikuje klasyczny Kotlin Gradle Plugin.

Jest to **ryzyko utrzymaniowe, nie blocker obecnego wydania**. Flutter 3.44
zapewnia tymczasowa zgodnosc, ale zapowiada usuniecie wsparcia dla klasycznego
KGP w przyszlosci:
<https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin>.

Nie nalezy wykonywac zbiorowej migracji tuz przed R1. Po publikacji trzeba
utworzyc osobny etap: aktualizacja pluginow, usuniecie workaroundu, przejscie na
Built-in Kotlin, pelne testy i ponowny release smoke.

## 10. Ryzyka wymagajace urzadzenia lub Play Console

1. Finalny AAB na fizycznym Androidzie: start, migracja bazy, OCR paragonu i
   faktury, import PDF, selektor kontaktu, powiadomienie i restart telefonu.
2. Uruchomienie na srodowisku 16 KB, mimo statycznego PASS artefaktu.
3. Play pre-launch report: crashe, ANR, accessibility i problemy OEM.
4. App bundle explorer: wykorzystany `versionCode`, podpis, rozmiary pobierania,
   wspierane urzadzenia i ostrzezenia natywnych bibliotek.
5. App integrity: aktywne Play App Signing i zgodnosc finalnego upload
   certificate.
6. Policy/App content: brak oczekujacych deklaracji lub bledow formularzy.
7. Typ konta i ewentualny wymog closed test widoczny w konkretnym Play Console.
8. Odbior wiadomosci przez publiczny kanal wsparcia i gotowosc odpowiedzi na
   zgloszenia podczas testow.

## 11. Status starych findings z `CLAUDE_CODE_REVIEW.md`

| Finding | Aktualny status |
| --- | --- |
| `PROD-A-MAN-03` - brak `<queries>` dla URL-i | **ZAMKNIETY JAKO NIEZASADNY.** Kod uzywa `launchUrl`; oficjalna dokumentacja nie wymaga `<queries>` do bezposredniego startu aktywnosci. |
| `PROD-A-BUILD-04` / `Q-08` - niepotwierdzone 16 KB | **ZAMKNIETY DLA ISTNIEJACEGO AAB.** Bundle config, ELF i ZIP alignment maja PASS. Kontrole trzeba powtorzyc dla finalnego AAB. |
| `PROD-02` - brak finalnych danych wydawcy i stron | **NAPRAWIONY W KODZIE I NA STRONACH.** Pozostaje wlascicielska weryfikacja zgodnosci danych z Play Console. |
| `Q-06` - niepewny URL polityki | **ZAMKNIETY.** Produkcyjna domena i cztery strony odpowiadaja 200. |
| `PROD-01` - finalny signing | **OTWARTY, DZIALANIE WLASCICIELA.** Kod fail-closed jest poprawny; brak finalnego klucza i sekretow. |
| `PROD-R8-02` / `PROD-CI-04` - brak release AAB w CI | **OTWARTY, RYZYKO NIEBLOKUJACE.** Manualny helper istnieje, CI nadal buduje tylko debug APK. |
| `Q-05` - 12 testerow przez 14 dni | **NIE JEST DOMYSLNYM BLOCKEREM KONTA ORGANIZACYJNEGO.** Potwierdzic komunikat w konkretnym Play Console. |
| Ostrzezenie klasycznego KGP | **OTWARTE, NIEBLOKUJACE R1.** Zaplanowac osobna migracje po wydaniu. |

## 12. Minimalna kolejnosc do produkcji

1. Wyslac zweryfikowany refaktor i uzyskac zielone GitHub CI wraz z wykonaniem
   jobow zaleznych; lokalny punkt odniesienia to 639/639 testow.
2. Skonfigurowac finalny klucz upload i Play App Signing.
3. Sprawdzic zajetosc `versionCode`; w razie potrzeby zwiekszyc wersje.
4. Uruchomic finalny release helper na czystym commicie.
5. Zachowac AAB, metadata i komplet symboli w bezpiecznym archiwum.
6. Wyslac AAB do Internal testing i wykonac fizyczny smoke oraz pre-launch
   report.
7. Zatwierdzic wszystkie formularze App content i dane listingu.
8. Uruchomic closed test, jezeli wymaga go Play Console lub jako kontrolowana
   beta.
9. Po akceptacji wynikow wyslac pierwsza wersje produkcyjna; kolejne aktualizacje
   publikowac etapowo z przygotowanym hotfixem o wyzszym `versionCode`.
