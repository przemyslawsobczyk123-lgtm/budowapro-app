# BudowaPRO - audyt brakow przed produkcja

Stan audytu: 2026-08-01.

Pelna, mierzalna specyfikacja wydania po module MAT znajduje sie w
`PRODUCTION_READINESS_SPEC.md`. Ten dokument pozostaje skroconym audytem luk
funkcjonalnych; specyfikacja produkcyjna jest zrodlem prawdy dla blokad sklepow,
testow urzadzen, dowodow i Definition of Done.

## Werdykt

BudowaPRO `1.0.0+1` jest technicznym kandydatem `R1 MVP Core`. Zamrozony
zakres P0 jest zamkniety, ale publiczne wydanie nadal wymaga podpisow,
formularzy sklepow, bety i testow fizycznych urzadzen nalezacych do wlasciciela.

Najwazniejsza czesc ostatniego zakresu jest wdrozona: szablony domu i remontu
maja wskazowki oraz checklisty dla formalnosci, przygotowania placu, Stanu 0,
stanu surowego otwartego i zamknietego, instalacji, wykonczenia, rozbiorki,
tynkow/wylewek i przekazania. Wbudowane wskazowki sa zrodlowane, offline i
nie udaja projektu budowlanego ani decyzji kierownika.

## Wykonane i nieblokujace

- 67 kontrolowanych punktow w szablonie domu; szablon remontu ma osobne
  punkty planowania, rozbiorki, instalacji, tynkow/wylewek, wykonczenia i
  przekazania.
- Uzytkownik moze ustawic biezacy etap, oznaczyc etap jako ukonczony, wznowic
  go i potwierdzic zakonczenie z otwartymi punktami. Otwarte punkty pozostaja
  widoczne.
- OCR paragonow i faktur dziala jako przegladany szkic. Zapis nie zmienia sumy,
  dopoki uzytkownik nie zatwierdzi kwoty, VAT i pozycji. Dostepny jest import
  pliku jako sciezka awaryjna.
- Koszt mozna ponownie otworzyc i poprawic, a historia zmian pozostaje
  zachowana.
- Koszt ma dwa niezalezne wymiary: etap oraz sklad (`material`, `robocizna`,
  `wspolna wycena`). Wspolna wycena nie jest automatycznie dzielona 50/50.
  Te same pola dzialaja w formularzu, OCR, filtrach, podsumowaniach, raporcie
  i eksporcie CSV.
- Pomieszczenia, wybory i materialy sa trwalymi rekordami. Material mozna
  powiazac z etapem, pomieszczeniem, wykonawca, kosztem i dokumentem; dostawy
  czesciowe, braki, uszkodzenia, opoznienia, zwroty i refundacje sa widoczne
  w lokalnym rejestrze MAT.
- Kontakt wykonawcy moze byc wybrany pojedynczo z systemowego selektora, bez
  szerokiego `READ_CONTACTS`.
- Dane projektow, dokumentow i skanow pozostaja lokalnie. Jest reczny backup,
  eksport, usuwanie wszystkich danych i ostrzezenie, ze ZIP nie jest
  szyfrowany.
- Android ma `compileSdk` i `targetSdk` 36, co spelnia obecny wymog target API
  dla nowych aplikacji i aktualizacji obowiazujacy od 2026-08-31.
- Android ma fail-closed release validation, podpisany AAB, kontrole manifestu,
  16 KB page alignment i archiwizacje symboli.
- Centrum prawne w aplikacji zawiera polityke, warunki, ustawienia prywatnosci
  i licencje. Dodano osobny publiczny URL wsparcia jako wymaganie wydania.
- Automatyczny Android smoke tworzy projekt i koszt na swiezej natywnej bazie,
  po czym sprawdza Budzet. Lokalnie przeszedl na API 34, a CI obejmuje API 28
  i 36. Pelny gate ma 560 testow, czysta analize i debug APK.
- Repozytorium zawiera gotowe strony prawne, listingi, arkusze Data safety/App
  Privacy, ikone 512 px i grafike Google Play 1024 x 500.

## Blokery prawdziwego wydania

To sa czynnosci wydawcy, a nie dane, ktore mozna bezpiecznie wymyslic w kodzie:

1. Ustaw prawdziwe `BUDOWAPRO_PUBLISHER_NAME`,
   `BUDOWAPRO_PRIVACY_CONTACT_EMAIL`,
   `BUDOWAPRO_PRIVACY_POLICY_URL` i `BUDOWAPRO_SUPPORT_URL`.
2. Uzyj docelowego klucza upload, wlacz Play App Signing i zachowaj sekret oraz
   kopie klucza poza repozytorium.
3. Wypelnij Play Console: Data safety, reklamy, grupe docelowa, klasyfikacje,
   dane kontaktowe, dostep recenzenta, listing, zrzuty i test zamkniety, gdy
   konto go wymaga.
4. Na Macu wykonaj `pod install`, build i test na fizycznym iPhonie. Sprawdz
   privacy manifest razem z manifestami SDK po instalacji CocoaPods; tego nie
   da sie wiarygodnie potwierdzic samym buildem Androida.
   Workflow TestFlight przekazuje do IPA cztery wartosci `BUDOWAPRO_*` jako
   sekrety GitHub Actions.
5. Wykonaj recenzje prawna polityki, warunkow, porad budowlanych, zdjec,
   kontaktow wykonawcow i retencji danych. Kod nie jest opinia prawna ani
   projektem budowlanym.

## Braki wzgledem pelnej specyfikacji

### Zamkniecie R1

Poprzednie luki `DASH-004`, `COST-006/007`, `COST-009`, `CNT-005`, `DOC-003`,
`SET-003` i `NOTIF-004` zostaly wdrozone w zakresie R1 albo jawnie przesuniete
do P1. Dokladne rozstrzygniecia sa w sekcji 5
`PRODUCTION_READINESS_SPEC.md`. Nie wolno rozszerzac listingu R1 o odlozone
warianty bez ponownego otwarcia wymagan, implementacji i testow.

### Odlozone moduly P1/P2

- Dziennik budowy i Task 7.2 sa wdrozone lokalnie: wpisy, decyzje, zmiany
  zakresu i usterki maja rewizje, zalaczniki i powiazania. Decyzja przechowuje
  wariant, osobe, termin, podpisane delty kosztu/terminu i blokowane zadania.
  Zatwierdzenie zapisuje kontakt oraz czas, a pozniejsza korekta wraca do
  propozycji bez utraty zatwierdzonej wersji. Raport pokazuje plan bazowy,
  zatwierdzone delty i plan po zmianach osobno (`DIARY-*`, `COST-012`,
  `SYS-011`).
- Dokumentacja techniczna ma juz albumy przed zakryciem, metadane zdjec,
  tagi, filtry, wykonawce, etap/strefe i atomowy dowod checklisty
  (`TECH-001`-`TECH-004`). Typowane linki do kosztu, decyzji, usterki i
  protokolu sa wdrozone. Nadal brakuje wersji rzutow, pinezek i pomiarow na
  planie (`TECH-005`-`TECH-008`).
- Lista usterek, ponowna kontrola, wymagane dowody, liczniki i lokalny protokol
  PDF sa wdrozone. Dodanie usterki z pinezki pozostaje zalezne od modulu
  wersjonowanych rzutow.
- Kalkulatory plytek, farby, betonu i izolacji (`MAT-006`, `MAT-007`).
- Karta domu, gwarancje urzadzen i serwisy (`HOME-*`, `NOTIF-002`).
- Deterministyczny skan zdrowia projektu oraz offline asystent (`HEALTH-*`,
  `AST-*`). AI pozostaje odroczone do osobnej decyzji prywatnosciowej.
- Raporty PDF i rozbudowane przypomnienia dla gwarancji, dostaw, zwrotow,
  decyzji i usterek.

## Rekomendowana kolejnosc dalszego wdrazania

1. **Kalkulatory MAT** - plytki, farba, beton i izolacja z jawnymi jednostkami,
   zapasem, zaokragleniem opakowan i potwierdzanym szkicem materialu.
2. **NOTIF + HOME** - dostawy, zwroty, gwarancje, serwisy, karta domu i
   lokalne przypomnienia otwierajace konkretny rekord.
3. **Pozostale linki TECH** - wersje rzutow, pinezki i pomiary na planie.
4. **Raporty i asystent offline** - dopiero po ustabilizowaniu modelu danych,
   zeby nie budowac rekomendacji na niepelnych rekordach.

## Braki testowe przed sklepami

- Testy na co najmniej jednym fizycznym Androidzie i iPhonie, w tym brak sieci,
  restart podczas OCR, anulowanie aparatu, duzy tekst, pelny dysk i niski stan
  baterii.
- Test migracji starego backupu na czystym urzadzeniu oraz odtworzenia zdjec,
  faktury, kosztu i historii po restarcie.
- Test pieciu zalaczonych przypadkow z zycia: paragon termiczny, faktura PDF,
  faktura wielostronicowa, nieczytelny skan i duplikat dokumentu.
- Test sklepowej wersji release z finalnym URL polityki i wsparcia, a nie z
  buildem walidacyjnym na danych testowych.
- Po kazdej aktualizacji Fluttera lub pluginu: analiza permission diff,
  Data safety, privacy manifest, OCR, selektor kontaktu i podpisany AAB/IPA.

## Zrodla urzedowe i techniczne

- Google Play target API: https://developer.android.com/google/play/requirements/target-sdk
- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play User Data: https://support.google.com/googleplay/android-developer/answer/10144311
- Android Contact Permissions: https://support.google.com/googleplay/android-developer/answer/16935362
- Apple App Review: https://developer.apple.com/app-store/review/
- Apple privacy manifest: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- Apple App Privacy: https://developer.apple.com/app-store/app-privacy-details/
- Polityka i zrodla porad budowlanych w aplikacji:
  `docs/build-home-app/STAGE_GUIDANCE_SOURCES.md`
- Pelna macierz wymagan:
  `docs/build-home-app/SPEC.md`
