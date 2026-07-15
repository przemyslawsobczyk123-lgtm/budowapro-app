# BudowaPRO - etapowy plan wdrozenia

## 1. Cel planu

Plan realizuje wymagania z `SPEC.md` pionowymi przyrostami. Po kazdym module aplikacja musi sie kompilowac, przechodzic testy i pozostawac uzywalna. Nie wdrazamy wszystkich ekranow jednoczesnie.

## 2. Zasady realizacji

- Flutter Android, Clean Architecture wedlug funkcji.
- `flutter_riverpod`, `go_router`, lokalne SQLite i lokalny system plikow.
- UI nie zna SQL ani sciezek platformowych.
- Domeny finansowe uzywaja kwot w groszach.
- OCR, import, AI i pliki sa niezaufanym wejsciem.
- Najpierw logika i testy, potem widok i integracja.
- Kazdy ekran otrzymuje stan ladowania, pusty, bledu i dane.
- Wszystkie teksty uzytkownika trafiaja do lokalizacji.
- Pakiety sa dodawane dopiero po weryfikacji aktualnej dokumentacji oficjalnej.

## 3. Bramka jakosci po kazdym zadaniu

Przed rozpoczeciem kolejnego zadania:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Gdy bramka jest czerwona, praca zatrzymuje sie na diagnozie i naprawie. Nie wolno kumulowac kolejnych modulow na niedzialajacej bazie.

Minimalna definicja ukonczenia zadania:

- kryteria akceptacji sa spelnione,
- testy domeny i repozytorium przechodza,
- widok ma wszystkie wymagane stany,
- nawigacja i cofanie dzialaja,
- brak danych prywatnych w logach,
- migracja bazy jest przetestowana,
- debug APK buduje sie poprawnie,
- dokumentacja zostala zaktualizowana.

## 4. Wersje produktu

| Wersja | Cel | Fazy |
| --- | --- | --- |
| R0 Fundament | kompilowalna baza techniczna | 0-1 |
| R1 MVP Core | uzywalny zamiennik Excela dla kosztow i etapow | 2-5 |
| R2 MVP Complete | kompletna lokalna aplikacja z makiet | 6-10 |
| R3 Release | bezpieczenstwo, wydajnosc i publikacja beta | 11 |
| R4 Rozszerzenia | opcjonalny AI, sync i wspolpraca | osobna decyzja |

## 5. Kolejnosc zaleznosci

```text
Fundament techniczny
  -> Projekt i kontekst
    -> Koszty reczne
      -> Etapy i harmonogram
        -> Kontakty i dokumenty
          -> OCR i szybki zapis
            -> Dziennik i decyzje
              -> Pomieszczenia i materialy
                -> Techniczne, plany i odbiory
                  -> Raporty i karta domu
                    -> Kondycja i asystent
```

## 6. Faza 0 - zamkniecie produktu i przygotowanie repozytorium

### 0.1 Zamrozenie specyfikacji P0

Zakres:

- potwierdzenie otwartych decyzji z `SPEC.md`,
- zatwierdzenie pieciu zakladek i 17 ekranow,
- oznaczenie P0/P1/P2 w backlogu,
- spisanie ADR dla local-first, SQLite, plikow i OCR.

Kryteria odbioru:

- kazdy ekran ma przypisane wymagania i faze,
- P0 nie zawiera backendu, kont ani AI,
- brak wymagan bez wlasciciela i kryterium odbioru.

Powiazania: `SYS-*`, cala specyfikacja.

### 0.2 Utworzenie repozytorium i zasad pracy

Zakres:

- inicjalizacja Git dopiero po zgodzie wlasciciela,
- `AGENTS.md`, `.gitignore`, konwencja galezi i commitow,
- katalog dokumentacji decyzji `docs/adr/`,
- workflow CI dla analyze, test i debug build.

Kryteria odbioru:

- czyste repo nie zawiera sekretow ani artefaktow build,
- lokalna i CI-owa bramka uruchamia te same komendy.

## 7. Faza 1 - fundament Flutter i dane lokalne

### 1.1 Szkielet aplikacji

Zakres:

- utworzenie projektu Flutter,
- katalogi `core`, `features`, `shared`,
- routing pieciu zakladek,
- motyw z makiet, lokalizacja polska i obsluga bledow,
- podstawowe komponenty: topbar, lista, filtr, formularz, empty/error/loading.

Kryteria odbioru:

- piec pustych zakladek dziala na telefonie,
- nawigacja zachowuje stan zakladek,
- widget test obejmuje loading, empty i error.

Powiazania: `SYS-001`, `SYS-003`, `SYS-004`, `SYS-012`.

### 1.2 SQLite, migracje i system plikow

Zakres:

- fabryka bazy i migracja `v1`,
- bazowe identyfikatory, daty, audyt i stronicowanie,
- serwis lokalnych plikow z `originals`, `previews`, `exports`,
- transakcje oraz repozytoria testowe.

Kryteria odbioru:

- migracja nowej oraz istniejacej bazy przechodzi test,
- zapytania sa parametryzowane,
- zapis przerwany w polowie nie zostawia osieroconych rekordow/pliku.

Powiazania: `SYS-002`, `SYS-005`, `SYS-006`, `SYS-008`.

### 1.3 Projekt i szablony

Zakres:

- CRUD projektu,
- selektor projektu,
- szablon budowy domu i remontu,
- ustawienia waluty, dat oraz aktualnego etapu.

Kryteria odbioru:

- po restarcie wybrany projekt i jego dane pozostaja,
- zmiana projektu nie miesza rekordow,
- usuniecie projektu pokazuje skutki i wymaga potwierdzenia.

Powiazania: `PRJ-001` - `PRJ-007`, `SET-003`.

Zakres R0: zmiana typu projektu przelacza przypisany, wersjonowany szablon
`Budowa domu` albo `Remont`. Niezalezne warianty i szablony wlasne sa wdrazane
w Task 3.1 razem z edytorem etapow i checklist.

Punkt kontrolny R0: aplikacja sie instaluje, dziala offline i przechowuje wiele pustych projektow.

## 8. Faza 2 - budzet i koszty reczne

### 2.1 Domena finansowa

Zakres:

- `Money`, VAT, statusy i typ koszt/oferta/plan,
- obliczenia netto/brutto, plan/wykonanie/roznica,
- encje, use case i kontrakty repozytoriow.

Kryteria odbioru:

- testy graniczne zaokraglen, VAT 0/8/23 i korekt,
- brak `double` w utrwalanych kwotach,
- szkic nie trafia do sum.

Powiazania: `COST-001` - `COST-004`, `COST-012`, `COST-016`.

### 2.2 Dodaj i edytuj koszt

Zakres:

- formularz z makiety `Dodaj koszt`,
- zapis szkicu i zatwierdzonego kosztu,
- edycja, kopiowanie, status platnosci i usuwanie,
- lokalny zalacznik przez picker.

Kryteria odbioru:

- walidacja nie kasuje wpisanych danych,
- koszt i zalacznik zapisuja sie atomowo,
- po restarcie pozycja ma identyczne kwoty i status.

Powiazania: `COST-009` - `COST-017`, `DOC-001`, `DOC-006`.

### 2.3 Rejestr, wyszukiwanie i filtry

Zakres:

- lista kosztow,
- wyszukiwanie i komplet filtrow,
- podsumowanie aktywnego wyniku,
- ostrzezenia o brakujacym dokumencie lub VAT.

Kryteria odbioru:

- podsumowanie jest liczone zapytaniem SQL,
- filtry sa testowane na laczonych warunkach,
- lista 10 000 rekordow jest leniwa.

Powiazania: `COST-005` - `COST-011`, `SYS-007`.

## 9. Faza 3 - Start, etapy, checklisty i kalendarz

### 3.1 Etapy i szablony checklist

Zakres:

- encje etapow i checklist,
- szablon `Stan 0` z przepustami i uziomem,
- postep, statusy, waznosc i wymagany dowod,
- ekran Etapy.

Kryteria odbioru:

- postep wynika z checklisty,
- wymagany punkt nie zamyka sie bez dowodu lub jawnego odstapienia,
- wszystkie elementy minimalnej checklisty ze specyfikacji sa zasiane.

Powiazania: `PLAN-001` - `PLAN-007`.

### 3.2 Plan 7 dni i lokalne powiadomienia

Zakres:

- zdarzenia, zadania i zaleznosci,
- plan 7 dni,
- przypomnienia systemowe,
- zmiana terminu z historia.

Kryteria odbioru:

- zdarzenie otwiera rekord zrodlowy,
- brak zgody na powiadomienia nie blokuje planu,
- terminy poprawnie zachowuja sie po zmianie strefy/czasu.

Powiazania: `PLAN-008` - `PLAN-010`, `NOTIF-001`, `NOTIF-003`, `NOTIF-004`.

### 3.3 Start - pierwszy pionowy dashboard

Zakres:

- aktualny etap, budzet, plan 30 dni, nieoplacone,
- os etapow, krytyczne zadania i dzisiejsza agenda,
- szybkie przejscia do kosztow i checklist.

Kryteria odbioru:

- dane dashboardu sa zgodne z repozytoriami,
- dodanie kosztu lub zamkniecie checklisty aktualizuje Start,
- brak projektu i pusty projekt maja osobne stany.

Powiazania: `DASH-001`, `DASH-002`, `DASH-004`, `DASH-006` - `DASH-008`.

## 10. Faza 4 - kontakty, oferty, wizyty i dokumenty

### 4.1 Kontakty i wizyty

Zakres:

- CRUD kontaktow,
- przypisanie rol i etapow,
- wizyty, cel, rezultat i status,
- wpis po wizycie i agenda na Start.

Kryteria odbioru:

- filtr roli oraz etapu dziala,
- zakonczona/odwolana wizyta pozostaje w historii,
- telefon/e-mail otwiera systemowa akcje dopiero po kliknieciu.

Powiazania: `CNT-001` - `CNT-006`.

### 4.2 Oferty i porownanie zakresu

Zakres:

- oferta wykonawcy z zakresem i wykluczeniami,
- zalacznik PDF/zdjecie,
- porownanie wariantow cenowych.

Kryteria odbioru:

- porownanie pokazuje cene i roznice zakresu,
- zaakceptowana oferta moze utworzyc planowany/zamowiony koszt.

Powiazania: `CNT-007`, `CNT-008`, `COST-001`.

### 4.3 Biblioteka dokumentow

Zakres:

- import i indeks lokalnych dokumentow,
- typy, powiazania, filtry i podglad,
- gwarancje i terminy,
- miniatury poza watkiem UI.

Kryteria odbioru:

- ten sam dokument jest widoczny ze wszystkich powiazanych rekordow,
- usuniecie pokazuje powiazania,
- oryginal nie jest modyfikowany.

Powiazania: `DOC-001` - `DOC-008`.

## 11. Faza 5 - raport podstawowy, eksport i backup

### 5.1 Raport budzetowy

Zakres:

- plan, zobowiazania, zaplacone i pozostale,
- przekroje etap/kategoria/wykonawca/miesiac,
- drill-down do filtrowanej listy kosztow.

Kryteria odbioru:

- raport zgadza sie z fixture finansowym,
- agregacje wykonuja sie w SQL,
- pusty projekt ma sensowny stan bez wykresu zer.

Powiazania: `REP-001`, `REP-002`, `REP-004`.

### 5.2 CSV i backup ZIP

Zakres:

- lokalny eksport filtrowanych kosztow CSV,
- wersjonowany backup z manifestem i sumami,
- bezpieczne odtwarzanie przez katalog tymczasowy.

Kryteria odbioru:

- E2E-07 przechodzi na danych z zalacznikami,
- uszkodzony ZIP albo path traversal sa odrzucane,
- eksport i backup nie blokuja UI i nie loguja sciezek/tresci.

Powiazania: `REP-005`, `REP-007`, `REP-008`, `SET-006`, `SET-007`.

Punkt kontrolny R1 MVP Core: inwestor moze prowadzic projekt, koszty, etapy, ekipy, dokumenty i backup bez Excela.

## 12. Faza 6 - OCR i uniwersalny szybki zapis

### 6.1 Adapter skanera i OCR

Zakres:

- interfejs skanera ukrywajacy konkretny plugin,
- capture/import, kadrowanie, OCR i stany bledow,
- oryginal oraz podglad.

Kryteria odbioru:

- aparat uruchamia sie tylko po akcji,
- brak wspieranego skanera ma fallback do galerii/pliku,
- anulowanie nie zostawia polrekordu.

Powiazania: `OCR-001` - `OCR-004`, `OCR-010`, `SET-002`.

### 6.2 Korekta OCR i zapis finansowy

Zakres:

- confidence per pole,
- korekta, laczenie i dzielenie linii,
- wykrycie duplikatu,
- transakcyjne utworzenie kosztow.

Kryteria odbioru:

- E2E-02 przechodzi,
- niepewne pola wymagaja kontroli,
- OCR nigdy nie omija potwierdzenia.

Powiazania: `OCR-005` - `OCR-009`.

### 6.3 Skrzynka szkicow

Zakres:

- szybki zapis zdjecia, dokumentu, notatki, glosu, kosztu, decyzji i usterki,
- klasyfikacja oraz brakujacy kontekst,
- licznik szkicow na Start i Wiecej.

Kryteria odbioru:

- kazdy typ tworzy szkic offline,
- szkic nie zmienia zadnego podsumowania,
- zatwierdzenie albo odrzucenie nie pozostawia osieroconego pliku.

Powiazania: `CAP-001` - `CAP-007`, `DASH-005`, `SYS-009`.

## 13. Faza 7 - dziennik, decyzje i historia zmian

### 7.1 Dziennik dzienny

Zakres:

- wpis dnia, pogoda opcjonalna, ekipy, prace, opoznienia i kolejne kroki,
- zdjecia, glos i powiazania,
- lista chronologiczna.

Kryteria odbioru:

- wpis powstaje takze ze szkicu,
- powiazane prace i kontakty otwieraja sie z dziennika,
- tresc dziennika nie trafia do logow.

Powiazania: `DIARY-001`, `DIARY-002`.

### 7.2 Decyzje i delty

Zakres:

- warianty, termin, zatwierdzenie i status,
- wplyw kosztowy oraz harmonogramowy,
- blokowane rekordy i wersjonowana historia.

Kryteria odbioru:

- E2E-04 przechodzi,
- edycja nie nadpisuje poprzedniej decyzji,
- suma delt jest zgodna z raportem.

Powiazania: `DIARY-003` - `DIARY-007`, `COST-012`, `SYS-011`.

## 14. Faza 8 - tryb remontu, materialy i dostawy

### 8.1 Pomieszczenia i karty wyborow

Zakres:

- CRUD pomieszczen,
- budzet i koszty pomieszczenia,
- warianty wyboru oraz otwarte decyzje.

Kryteria odbioru:

- suma pomieszczen jest zgodna z kosztami powiazanymi,
- wybor tworzy tylko jawnie zatwierdzony szkic kosztu/materialu.

Powiazania: `ROOM-001` - `ROOM-005`.

### 8.2 Materialy, dostawy i zwroty

Zakres:

- zamowienia, dostawy czesciowe, braki i skladowanie,
- terminy zwrotow i powiazanie paragonu,
- lokalne przypomnienia.

Kryteria odbioru:

- ilosc dostarczona nie moze przekroczyc zamowionej bez potwierdzonej korekty,
- opoznienia i zwroty sa widoczne na dashboardzie materialow,
- powiadomienie otwiera konkretny material/zwrot.

Powiazania: `MAT-001` - `MAT-005`, `NOTIF-002`.

### 8.3 Kalkulatory ilosci

Zakres:

- plytki, farba, beton i izolacja,
- jawne jednostki, zapas oraz zaokraglenie opakowan,
- utworzenie szkicu materialu.

Kryteria odbioru:

- testy jednostek i granic,
- wynik nigdy nie sklada zamowienia ani nie tworzy kosztu bez potwierdzenia.

Powiazania: `MAT-006`, `MAT-007`.

## 15. Faza 9 - dokumentacja techniczna, plany i odbiory

### 9.1 Albumy techniczne

Zakres:

- zdjecia etapow, pomieszczen i instalacji,
- tagowanie, wyszukiwanie i laczenie z checklista,
- pipeline miniaturek.

Kryteria odbioru:

- E2E-03 przechodzi dla dowodu uziomu,
- 500 zdjec nie blokuje listy ani Startu,
- brakujace/usuniete pliki maja kontrolowany blad.

Powiazania: `TECH-001` - `TECH-004`.

### 9.2 Rzuty i pinezki

Zakres:

- import obrazu/strony PDF,
- wersje rzutu,
- pinezki i powiazane rekordy.

Kryteria odbioru:

- pozycja pinezki jest stabilna na roznych ekranach,
- zmiana wersji rzutu wymaga jawnego mapowania,
- E2E-05 przechodzi.

Powiazania: `TECH-005` - `TECH-008`.

### 9.3 Odbiory i lista poprawek

Zakres:

- usterki, odpowiedzialni, terminy i dowody,
- ponowna kontrola,
- protokol PDF.

Kryteria odbioru:

- zamkniecie wymagajace dowodu jest walidowane,
- liczniki otwarte/krytyczne/przeterminowane sa zgodne,
- E2E-06 przechodzi w czesci usterki.

Powiazania: `PUNCH-001` - `PUNCH-007`.

## 16. Faza 10 - pelne raporty, karta domu i asystent

### 10.1 Raporty kompletne i PDF

Zakres:

- przyszle wydatki, OCR do korekty, zwroty, gwarancje i delty decyzji,
- lokalny raport PDF dla banku/inwestora/odbioru.

Kryteria odbioru:

- dane raportu sa identyczne z rekordami zrodlowymi,
- generowanie duzego raportu jest poza UI thread,
- uzytkownik wybiera zakres przed zapisem.

Powiazania: `REP-003`, `REP-006`, `REP-008`.

### 10.2 Karta domu i serwisy

Zakres:

- urzadzenia, numery seryjne, instrukcje i gwarancje,
- punkty instalacji, serwis i historia,
- pakiet eksportowy domu.

Kryteria odbioru:

- kompletnosc wskazuje realne braki,
- przypomnienie serwisowe dziala offline,
- dane budowy sa dostepne po archiwizacji projektu.

Powiazania: `HOME-001` - `HOME-007`, `PRJ-006`, `NOTIF-002`.

### 10.3 Kondycja projektu

Zakres:

- deterministyczne reguly budzetu, terminu, checklist, decyzji, dowodow, zwrotow i usterek,
- pasek kondycji na Start,
- lista powodow i deep link.

Kryteria odbioru:

- kazdy wynik ma co najmniej jeden powod albo jawne `brak problemow`,
- testy obejmuja prace nieodwracalne i granice terminu,
- po naprawie zrodla ostrzezenie znika deterministycznie.

Powiazania: `HEALTH-001` - `HEALTH-005`, `DASH-003`, `DASH-009`, `SYS-010`.

### 10.4 Asystent offline i ustawienia

Zakres:

- wyjasnienia regul,
- pytania dla kierownika/wykonawcy,
- szkice notatek i zadan,
- ekran prywatnosci, pamieci oraz przelaczniki.

Kryteria odbioru:

- dziala w trybie samolotowym,
- nie wykonuje zadnej akcji finansowej lub odbiorowej,
- wskazuje regule/zrodlo sugestii,
- wylaczenie nie usuwa danych projektu.

Powiazania: `AST-001` - `AST-005`, `SET-001` - `SET-004`, `SET-008`.

Punkt kontrolny R2 MVP Complete: wszystkie 17 ekranow makiet ma dzialajacy odpowiednik i przechodzi przeplywy E2E-01 - E2E-07.

## 17. Faza 11 - hardening i beta Android

### 11.1 Bezpieczenstwo i prywatnosc

- przeglad importu, sciezek, SQLite, backupu i uprawnien,
- test braku uploadu oraz tresci prywatnej w logach,
- model zagrozen dla lokalnych dokumentow,
- decyzja o szyfrowanym backupie i blokadzie aplikacji.

### 11.2 Wydajnosc i stabilnosc

- pomiary startu, dashboardu, filtrow, OCR, miniaturek, PDF i ZIP,
- fixture z 10 000 kosztow i 500 zdjec,
- Android 9+ na urzadzeniu slabszym i referencyjnym,
- test migracji, braku miejsca, przerwanego importu i uszkodzonego backupu.

### 11.3 Dostepnosc i testy urzadzen

- TalkBack, skalowanie tekstu i kontrast,
- male i duze ekrany, orientacja, tryb ciemny jezeli wdrozony,
- cofanie systemowe, utrata procesu i przywrocenie formularza,
- aparat, picker i powiadomienia na realnym Androidzie.

### 11.4 Beta i wydanie

- prywatna beta z danymi testowymi, bez prywatnych dokumentow zespolu,
- checklista publikacji, polityka prywatnosci i listing,
- podpisany build release, plan migracji i rollbacku,
- znane ograniczenia OCR i jasne zastrzezenie asystenta.

Punkt kontrolny R3: kandydat do pierwszego wydania bez krytycznych bledow, z odtworzonym backupem i pomiarami celow wydajnosci.

## 18. Faza 12 - rozszerzenia wymagajace osobnej decyzji

Nie rozpoczynac razem z MVP.

### 12.1 Opcjonalny AI

Najpierw ADR dotyczacy dostawcy, kosztu, retencji, zakresu danych i zgody. Implementacja musi spelniac `AI-001` - `AI-004`; lokalny asystent pozostaje domyslny.

### 12.2 Synchronizacja i wspolpraca

Wymaga modelu konta, konfliktow, uprawnien, szyfrowania, usuwania danych i kosztu backendu. Eksport pliku pozostaje wystarczajacym mechanizmem MVP.

## 19. Macierz ekran -> faza

| Ekran makiety | Glowna faza | Wymagania |
| --- | --- | --- |
| Start | 3, 10 | `DASH-*`, `HEALTH-*` |
| Koszty | 2 | `COST-001` - `COST-012` |
| Dodaj koszt | 2 | `COST-013` - `COST-017` |
| Skan OCR | 6 | `OCR-*` |
| Etapy | 3 | `PLAN-*` |
| Ekipy | 4 | `CNT-*` |
| Dokumenty | 4 | `DOC-*` |
| Techniczne | 9 | `TECH-*` |
| Pomieszczenia | 8 | `ROOM-*` |
| Zakupy | 8 | `MAT-*` |
| Odbiory | 9 | `PUNCH-*` |
| Raporty | 5, 10 | `REP-*` |
| Wiecej | 6 | `CAP-*`, nawigacja kontekstowa |
| Dziennik | 7 | `DIARY-*` |
| Asystent | 10 | `HEALTH-*`, `AST-*` |
| Karta domu | 10 | `HOME-*` |
| Ustawienia | 1, 5, 10 | `SET-*` |

## 20. Kolejnosc pierwszych prac implementacyjnych

1. Rozstrzygnac piec otwartych decyzji ze specyfikacji.
2. Utworzyc repozytorium Git i projekt Flutter.
3. Dostarczyc Faze 1 z bramka APK.
4. Dostarczyc Faze 2 jako pierwszy pelny pion: baza -> domena -> UI -> test.
5. Dopiero po poprawnych sumach finansowych rozpoczac etapy i OCR.

## 21. Glowne ryzyka

| Ryzyko | Wplyw | Ograniczenie |
| --- | --- | --- |
| Bledny OCR zmienia budzet | wysoki | szkic, confidence i obowiazkowe potwierdzenie |
| Rozrost do ERP | wysoki | piec zakladek, P0/P1/P2 i pionowe przyrosty |
| Utrata lokalnych danych | wysoki | transakcje, wersjonowane migracje, backup i test restore |
| Duze zdjecia blokuja UI | sredni | miniatury, lazy decode i praca poza UI thread |
| Zbyt wczesny backend | sredni | lokalny eksport i osobna decyzja R4 |
| AI mylone ze specjalista | wysoki | asystent offline, zrodla, szkice i jawne ograniczenia |
| Niespojny budzet | wysoki | `Money`, SQL aggregates i E2E fixtures |
| Zaleznosc od jednego skanera | sredni | adapter i fallback do pliku/recznego kosztu |
