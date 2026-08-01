# BudowaPRO - specyfikacja gotowosci produkcyjnej po MAT

Stan analizy: 2026-08-01.

## 1. Cel

Dokument definiuje, kiedy BudowaPRO moze zostac uznana za gotowa do pierwszego
publicznego wydania R1 w Google Play i App Store. Rozdziela:

- funkcje konieczne dla obiecanego MVP;
- jakosc i bezpieczenstwo artefaktu;
- wymagania sklepow i deklaracje prawne;
- czynnosci wlasciciela kont, ktorych nie wolno uzupelniac fikcyjnymi danymi;
- funkcje P1/P2, ktore moga zostac dostarczone po premierze.

Pierwsze R1 pozostaje aplikacja local-first bez konta, backendu, reklam,
synchronizacji i wysylania dokumentow. Uzytkownik sam uruchamia eksport lub
backup i sam wybiera odbiorce pliku.

## 2. Werdykt na dzis

| Obszar                      | Stan    | Wniosek                                                                                                                                |
| --------------------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Android debug               | zielony | Analiza, 560 testow i debug APK przeszly 2026-08-01.                                                                                   |
| Rdzen projektu i finansow   | zielony | Projekty, etapy, checklisty, koszty, OCR, dokumenty i backup dzialaja lokalnie.                                                        |
| ROOM i rdzen MAT            | zielony | Pomieszczenia, wybory, materialy, dostawy i zwroty maja trwale rekordy.                                                                |
| Android release             | zolty   | Pipeline AAB jest walidowany i fail-closed; docelowy klucz, Play App Signing i produkcyjny AAB wymagaja konta wlasciciela.             |
| iOS build                   | zolty   | CI na macOS/Xcode 26 zaliczylo unsigned compile; podpis, TestFlight i fizyczny iPhone wymagaja Apple Developer.                        |
| Sklepy i prawo              | zolty   | Tresci, publiczne strony HTTPS, listingi i arkusze deklaracji sa gotowe; prawdziwa tozsamosc i formularze konsol wymagaja wlasciciela. |
| Testy urzadzen              | zolty   | Android smoke przeszedl na API 34 lokalnie oraz API 28/36 w CI; fizyczny Android i iPhone pozostaja wymagane.                          |
| Zgodnosc z zamrozonym P0 R1 | zielony | Dawne luki rozstrzygnieto wdrozeniem albo jawnym przesunieciem do P1.                                                                  |

**Decyzja:** kod i materialy repozytorium sa technicznym kandydatem R1. Publiczna
produkcja i App Review pozostaja zablokowane wyłącznie przez dowody urzadzen,
tozsamosc, podpisy, formularze sklepow i decyzje wlasciciela.

## 3. Zakres R1, ktory moze zostac wydany

R1 moze byc publikowane bez kalkulatorow MAT, karty domu, asystenta offline i
rzutow z pinezkami, jezeli listing nie obiecuje tych funkcji. Minimalny zakres
R1 obejmuje:

1. projekty domu i remontu;
2. etapy, checklisty, wskazowki i dowody;
3. koszty, budzet, raport i CSV;
4. OCR jako szkic wymagajacy kontroli;
5. kontakty, wizyty i oferty;
6. dokumenty, dziennik, dokumentacje techniczna i usterki;
7. pomieszczenia, materialy, dostawy i zwroty;
8. lokalne przypomnienia podstawowego harmonogramu;
9. backup, odtworzenie, eksport i usuniecie wszystkich danych;
10. centrum prawne i jasne ograniczenia porad budowlanych.

## 4. Blokery publicznego wydania

### PROD-001 - zamrozony i identyfikowalny kod

Wymaganie:

- wszystkie zatwierdzone zmiany sa zapisane w Git i wyslane do `main`;
- drzewo release jest czyste;
- tag wskazuje dokladny commit uzyty do budowy;
- wersja bazowa wynosi `1.0.0+1`, a numer builda jest zwiekszany przy kazdym
  kolejnym uploadzie.

Dowod: tag Git, commit SHA oraz identyczny SHA w metadanych artefaktu.

### PROD-002 - prawdziwa tozsamosc wydawcy i publiczne strony

Wymaganie:

- ustawione sa prawdziwe `BUDOWAPRO_PUBLISHER_NAME` i
  `BUDOWAPRO_PRIVACY_CONTACT_EMAIL`;
- `BUDOWAPRO_PRIVACY_POLICY_URL` prowadzi do publicznego HTML HTTPS bez
  logowania;
- `BUDOWAPRO_SUPPORT_URL` prowadzi do dzialajacej strony kontaktu/wsparcia;
- polityka online, polityka w aplikacji, Data safety i App Privacy opisuja te
  same praktyki;
- nazwa aplikacji albo podmiot z listingu wystepuje w polityce.

Osobna domena nie jest wymagana. Istniejaca domena moze obslugiwac dedykowane
sciezki BudowaPRO, jezeli tresc jest publiczna, stabilna i zgodna z wydawca.

Dowod: release-check URL oraz reczna kontrola tresci na telefonie bez logowania.

### PROD-003 - produkcyjny Android App Bundle

Wymaganie:

- utworzony i zabezpieczony jest docelowy klucz upload;
- wlaczone jest Play App Signing;
- `dart run tool/release/build_android_release.dart` przechodzi na czystym
  tagu bez `--validation` i bez `--allow-dirty`;
- AAB ma zweryfikowany podpis, target API 36, 16 KB page alignment, scisla
  allowliste uprawnien, symbole i `release-metadata.json`;
- AAB jest instalowany z toru wewnetrznego Google Play, a nie tylko lokalnie.

Dowod: archiwum release, SHA-256, raport bundletool i test instalacji z Play.

### PROD-004 - produkcyjny iOS archive

Wymaganie:

- istnieje aktywne czlonkostwo Apple Developer Program, App ID `pl.budowapro`,
  rekord App Store Connect, certyfikat dystrybucyjny i profil App Store;
- build jest wykonany przez Xcode 26 lub nowszy z SDK iOS 26 lub nowszym;
- aktualny commit przechodzi `pod install`, kompilacje i archiwizacje;
- wynikowy IPA trafia do TestFlight i uruchamia sie na fizycznym iPhonie;
- raport prywatnosci archiwum nie pokazuje nieopisanych Required Reason APIs;
- Bundle ID, wersja, ikona, podpis i profil sa spojne.

Dowod: zielony workflow, numer builda w TestFlight i podpisany protokol smoke
testu na iPhonie.

### PROD-005 - deklaracje Google Play

Wymaganie:

- uzupelnione sa Privacy policy, Data safety, Ads, App access, Target audience,
  Content rating i pozostale aktywne deklaracje w `App content`;
- Data safety uwzglednia kod aplikacji oraz dokladne wersje wszystkich SDK;
- deklaracja ML Kit uwzglednia techniczne dane urzadzenia/aplikacji,
  diagnostyke i analityke uzycia SDK, ale nie deklaruje wysylania obrazu ani
  tekstu OCR, jezeli nadal sa przetwarzane wylacznie na urzadzeniu;
- aplikacja jest zadeklarowana jako niezawierajaca reklam;
- konfiguracja grupy docelowej nie sugeruje produktu dla dzieci.

Dowod: eksport/zrzuty zakonczonych deklaracji dla przeslanego AAB.

### PROD-006 - deklaracje App Store

Wymaganie:

- App Privacy odpowiada realnym praktykom aplikacji i zintegrowanych SDK;
- podany jest Privacy Policy URL i Support URL;
- uzupelnione sa kategoria, prawa do tresci, nowy formularz wieku, dane dla
  recenzenta, DSA/trader status dla dystrybucji w UE i pozostale pola widoczne
  jako wymagane w App Store Connect;
- notatka dla recenzenta wyjasnia brak konta, lokalne dane, OCR on-device,
  systemowy wybor kontaktu i sposob przetestowania kluczowych funkcji.

Dowod: kompletna karta wersji bez brakujacych pol przed `Submit for Review`.

### PROD-007 - listing i materialy sklepu

Wymaganie:

- finalna nazwa, krotki i pelny opis nie obiecuja funkcji odroczonych;
- gotowe sa zrzuty z realnego release builda dla wymaganych formatow obu
  sklepow, ikony i grafika funkcji Google Play;
- zrzuty nie zawieraja prywatnych dokumentow, danych wykonawcow ani danych
  wlasciciela;
- opis jasno informuje o local-first, recznym backupie i koniecznosci kontroli
  OCR;
- wszystkie prawa do grafik, fontow i tresci sa udokumentowane.

Dowod: zatwierdzony pakiet listingowy przechowywany obok release checklisty.

### PROD-008 - testy fizycznych urzadzen i E2E

Wymaganie:

- co najmniej jeden fizyczny Android i jeden fizyczny iPhone przechodza smoke
  test;
- emulator/symulator obejmuje Android API 28 i 36 oraz aktualny i starszy
  wspierany iOS;
- E2E-01 do E2E-07 ze `SPEC.md` maja protokol wykonania;
- osobno sprawdzone sa: aparat, anulowanie skanera, import PDF/obrazu, odmowa
  powiadomien, systemowy kontakt, deep link powiadomienia, udostepnienie,
  backup/restore, restart podczas OCR, niski stan miejsca i duzy tekst;
- test obejmuje co najmniej jeden prawdziwy paragon, fakture wielostronicowa,
  dokument slabej jakosci i reczna korekte OCR;
- brak awarii, utraty danych i bledow blokujacych.

Dowod: wersjonowany protokol urzadzen z modelem, OS, commitem i wynikiem.

### PROD-009 - migracja i odzyskanie danych

Wymaganie:

- aktualny schemat `v18` odtwarza syntetyczne backupy i co najmniej jeden
  zanonimizowany historyczny backup z rzeczywistego urzadzenia;
- przerwany restore pozostawia poprzednie dane aktywne;
- brak miejsca, uszkodzony ZIP, zly hash i nieznana wersja nie zmieniaja bazy;
- backup utworzony na Androidzie jest odtwarzany na iOS i odwrotnie, jezeli
  taka przenosnosc jest obiecywana w R1.

Dowod: protokol restore wraz z SHA-256 fixture, bez prywatnych danych.

### PROD-010 - bezpieczenstwo i prywatnosc artefaktu

Wymaganie:

- scalone manifesty Androida i iOS sa audytowane po zbudowaniu release;
- prywatne teksty OCR, kontakty, adresy, nazwy plikow i sciezki nie trafiaja do
  logow ani raportow awarii;
- import i restore zachowuja limity rozmiaru, sygnatur, pikseli i bezpieczne
  sciezki;
- `PrivacyInfo.xcprivacy` odpowiada raportowi z finalnego archive i manifestom
  wszystkich SDK;
- zewnetrzny przeglad prawny potwierdza polityke, warunki, retencje, porady
  budowlane i zastrzezenie, ze aplikacja nie zastepuje projektu ani kierownika.

Dowod: podpisana checklista security/privacy dla konkretnego SHA artefaktu.

### PROD-011 - obsluga wydania i rollback

Wymaganie:

- istnieje monitorowany adres wsparcia i procedura odpowiedzi;
- znany jest wlasciciel wydania oraz osoba podejmujaca decyzje o zatrzymaniu;
- Google Play uzywa wydania etapowego, a App Store phased release, jezeli
  dostepne;
- rollback oznacza zatrzymanie rollout i wyslanie wyzszej wersji naprawczej,
  bez downgrade schematu SQLite;
- zachowane sa AAB/IPA, mapy R8, symbole Dart/native, metadane i commit;
- po publikacji wykonywany jest smoke test instalacji, uruchomienia, kosztu,
  OCR, backupu i usuniecia danych.

Dowod: wypelniona checklista launch/rollback i archiwum konkretnej wersji.

### PROD-012 - beta sklepowa

Wymaganie:

- Android przechodzi internal test i pre-launch report;
- jezeli konto osobiste Google Play zostalo utworzone po 2023-11-13, closed
  test ma co najmniej 12 testerow zapisanych nieprzerwanie przez 14 dni, a
  nastepnie przyznany dostep do produkcji;
- iOS przechodzi TestFlight internal, a przed publicznym wydaniem rowniez
  rzeczywisty scenariusz testera spoza zespolu;
- feedback ma wlasciciela, status i kryterium zamkniecia.

Dowod: raporty torow testowych i zamkniete bledy krytyczne/wysokie.

## 5. Zamkniecie zakresu produktu R1

Zakres P0 zostal zamrozony. Funkcje ponizej sa wdrozone albo jawnie
przesuniete do P1, dlatego nie stanowia juz niejednoznacznych wymagan R1.

| ID             | Rozstrzygniecie R1                                                                                | Dowod zakresu                                              |
| -------------- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `DASH-004`     | Wdrozone szybkie akcje kosztu, OCR, checklist, harmonogramu, usterki i zdjec etapow.              | Asystent pozostaje P1 i nie jest obiecywany w listingu R1. |
| `COST-006/007` | Wdrozone wyszukiwanie oraz filtry daty, etapu, kategorii, wykonawcy, statusu, platnosci i zrodla. | Tagi i gwarancje pozostaja P1.                             |
| `COST-009`     | Szczegoly pokazuja dokumenty, materialy, pomieszczenia i historie bez kopiowania rekordow.        | Powiazanie z decyzja ma osobne wymaganie `COST-018` P1.    |
| `CNT-005`      | Wizyta zapisuje wynik, notatke i ustalenia.                                                       | Zdjecia i nowe zadania po wizycie sa `CNT-010` P1.         |
| `DOC-003`      | Dokument laczy sie z kosztem, etapem, checklista, kontaktem i pomieszczeniem.                     | Decyzja, usterka i urzadzenie sa `DOC-009` P1.             |
| `SET-003`      | Zmiany globalne ingerujace w istniejace dane nie naleza do R1.                                    | Bezpieczna migracja ustawien pozostaje P1.                 |
| `NOTIF-004`    | Zdarzenie ma wlaczenie przypomnienia i wyprzedzenie; odmowa zgody nie blokuje zapisu.             | Globalne typy i godziny pozostaja P1.                      |

## 6. Funkcje po R1

Ponizsze funkcje nie powinny zatrzymywac pierwszego wydania, jezeli listing ich
nie obiecuje:

1. kalkulatory plytek, farby, betonu i izolacji (`MAT-006/007`);
2. wersjonowane rzuty, pinezki i pomiary (`TECH-005`-`TECH-008`);
3. kompletne raporty PDF (`REP-003/006/008`);
4. karta domu, urzadzenia, serwisy i gwarancje (`HOME-*`);
5. powiadomienia decyzji, dostaw, zwrotow, usterek i serwisow (`NOTIF-002`);
6. kondycja projektu i asystent offline (`HEALTH-*`, `AST-*`);
7. opcjonalne AI, konto, backend i synchronizacja - dopiero po osobnym ADR,
   modelu prywatnosci, kosztu i usuwania danych.

## 7. Kolejnosc prac

1. `main`, CI Android/iOS i publikacja Pages zostaly potwierdzone dla commita
   `545377b`.
2. Potwierdzic prawdziwe dane wydawcy i dodac docelowe podpisy.
3. Zbudowac finalny AAB, IPA/TestFlight i wykonac testy fizycznych urzadzen.
4. Zrobic finalne zrzuty z podpisanych buildow i wypelnic deklaracje sklepow.
5. Przeprowadzic beta, ponowny pelny release gate i staged rollout.

## 8. Definition of Done produkcji

BudowaPRO jest gotowa do publicznego R1 dopiero, gdy jednoczesnie:

- `PROD-001` do `PROD-012` maja dowod i status zaliczony;
- nie ma otwartego bledu krytycznego ani wysokiego;
- wszystkie P0 sa wdrozone albo formalnie usuniete z R1;
- `flutter analyze`, pelny `flutter test`, Android release gate i aktualny iOS
  archive przechodza z tego samego oznaczonego commita;
- backup i restore przeszly na danych migracyjnych;
- polityka, deklaracje sklepow i zachowanie artefaktu sa zgodne;
- testy na fizycznym Androidzie i iPhonie sa udokumentowane;
- listing pokazuje tylko funkcje faktycznie obecne w przeslanej wersji;
- wlasciciel produktu zatwierdzil rollout i procedure wsparcia/rollbacku.

## 9. Aktualny stan konfiguracji repozytorium

W czasie zamkniecia technicznego:

- wersja wynosi `1.0.0+1`;
- commit `545377b` ma zielone zdalne CI: 560 testow, debug APK, unsigned iOS 26
  compile oraz smoke Android API 28 i 36;
- `integration_test/app_smoke_test.dart` przeszedl rowniez lokalnie na
  Androidzie API 34;
- grafika funkcji, ikona, listingi, strony prawne i arkusze prywatnosci sa w
  repozytorium;
- GitHub Pages publikuje polityke, warunki i wsparcie pod publicznym HTTPS;
- wymagane wartosci `BUDOWAPRO_*`, Apple i klucz upload pozostaja sekretami
  wlasciciela i sa sprawdzane fail-closed;
- finalne zrzuty musza pochodzic z podpisanych buildow bez prywatnych danych;
- finalny produkcyjny AAB i IPA nadal musza zostac przypisane do oznaczonego
  commita po dodaniu podpisow wlasciciela.

## 10. Oficjalne zrodla

Google Play:

- Target API requirements:
  https://support.google.com/googleplay/android-developer/answer/11926878
- Data safety:
  https://support.google.com/googleplay/android-developer/answer/10787469
- App content and review declarations:
  https://support.google.com/googleplay/android-developer/answer/9859455
- Tests for new personal accounts:
  https://support.google.com/googleplay/android-developer/answer/14151465
- Store listing assets:
  https://support.google.com/googleplay/android-developer/answer/9866151
- ML Kit disclosure:
  https://developers.google.com/ml-kit/android-data-disclosure

Apple:

- App Review Guidelines:
  https://developer.apple.com/app-store/review/guidelines/
- App privacy:
  https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
- Required App Store Connect properties:
  https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties/
- Privacy manifests:
  https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- Current SDK/Xcode requirements:
  https://developer.apple.com/news/upcoming-requirements/
- Apple Developer Program enrollment:
  https://developer.apple.com/help/account/membership/program-enrollment

Projekt:

- `SPEC.md`
- `IMPLEMENTATION_PLAN.md`
- `IMPLEMENTATION_STATUS.md`
- `PRIVACY_AND_GOOGLE_PLAY_RELEASE.md`
- `IOS_TESTFLIGHT_SETUP.md`
- `PRODUCTION_GAP_AUDIT.md`
