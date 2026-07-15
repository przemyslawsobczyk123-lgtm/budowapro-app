# BudowaPRO - specyfikacja funkcjonalna

## 1. Status dokumentu

- Status: specyfikacja docelowa na podstawie 17 zatwierdzonych makiet.
- Platforma startowa: Android, Flutter.
- Model produktu: local-first, bez konta i backendu w MVP.
- Obslugiwane scenariusze: budowa domu, remont domu, remont mieszkania, okres po odbiorze.
- Powiazana makieta: `docs/build-home-app-mockups/index.html`.
- Powiazana architektura: `docs/build-home-app/TECHNICAL_ARCHITECTURE.md`.

Dokument opisuje zachowanie produktu. Szczegoly wizualne pozostaja w makietach, a kontrakty techniczne w dokumentacji architektury.

## 2. Cel produktu

BudowaPRO zastapi arkusze Excel, papierowe paragony, notatki, albumy zdjec i rozproszone wiadomosci jednym lokalnym miejscem kontroli inwestycji.

Uzytkownik moze:

- zapisac kazdy planowany i rzeczywisty koszt,
- kontrolowac budzet wedlug etapu, kategorii, pomieszczenia i wykonawcy,
- skanowac paragony i zatwierdzac wynik OCR,
- planowac etapy, wizyty, dostawy i decyzje,
- korzystac z checklist zaleznosci przed pracami nieodwracalnymi,
- dokumentowac instalacje i roboty przed ich zakryciem,
- rozliczac materialy, zwroty, usterki i gwarancje,
- po odbiorze zachowac kompletna karte domu.

## 3. Uzytkownicy i tryby

### 3.1 Inwestor budujacy dom

Pracuje etapami od formalnosci i `Stanu 0` do odbioru. Najwazniejsze sa zaleznosci, terminy ekip, koszty, dokumenty i dowody przed zakryciem prac.

### 3.2 Osoba remontujaca mieszkanie lub dom

Pracuje glownie pomieszczeniami. Najwazniejsze sa wybory materialow, oferty, budzety pokojow, dostawy i lista poprawek.

### 3.3 Wlasciciel po odbiorze

Korzysta z karty domu: instrukcji, numerow seryjnych, planow instalacji, gwarancji, serwisow i historii zmian.

## 4. Zakres wersji

Priorytet przy wymaganiu oznacza:

- `P0` - rdzen pierwszej uzywalnej wersji lokalnej,
- `P1` - komplet funkcjonalny pokazany w makietach,
- `P2` - rozszerzenie po stabilizacji wersji lokalnej.

### 4.1 Zakres P0

- projekty i szablony etapow,
- Start i podstawowe wskazniki,
- reczne koszty, oferty i plany,
- etapy, checklisty i plan 7 dni,
- kontakty, wizyty i oferty ekip,
- lokalne dokumenty i zdjecia,
- podstawowe raporty i lokalny backup.

### 4.2 Zakres P1

- OCR paragonow,
- szybki zapis i skrzynka szkicow,
- dokumentacja techniczna oraz pinezki na planie,
- dziennik, decyzje i ich wplyw na budzet oraz termin,
- pomieszczenia, materialy, dostawy i zwroty,
- odbiory i usterki,
- transparentna kondycja projektu i asystent offline,
- karta domu, gwarancje i przypomnienia serwisowe,
- pelne raporty CSV/PDF.

### 4.3 Zakres P2

- opcjonalny asystent chmurowy po osobnej zgodzie,
- synchronizacja wielu urzadzen,
- konta i wspoldzielenie projektu,
- portal ograniczonego dostepu dla ekip,
- integracje bankowe, sklepowe lub ksiegowe.

## 5. Architektura informacji i ekrany

Aplikacja ma piec glownych zakladek. Ekrany szczegolowe otwieraja sie kontekstowo.

| Zakladka | Odpowiedzialnosc | Ekrany z makiet |
| --- | --- | --- |
| Start | dzisiejsza sytuacja projektu i szybkie akcje | Start, Asystent |
| Plan | etapy, checklisty, terminy i decyzje | Etapy, Dziennik |
| Budzet | koszty, plan, oferty, OCR i prognoza | Koszty, Dodaj koszt, Skan OCR, Raporty |
| Budowa | dowody, dokumenty, plany i odbiory | Dokumenty, Techniczne, Odbiory |
| Wiecej | narzedzia zalezne od kontekstu | Wiecej, Ekipy, Pomieszczenia, Zakupy, Karta domu, Ustawienia |

Globalny wybor projektu jest dostepny z kazdego glownego ekranu. Zmiana projektu zmienia caly kontekst danych.

## 6. Reguly wspolne

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| SYS-001 | P0 | Aplikacja dziala bez konta i bez polaczenia z internetem. |
| SYS-002 | P0 | Kazdy rekord nalezy do projektu; etap, pomieszczenie, kontakt i inne powiazania sa opcjonalnym kontekstem. |
| SYS-003 | P0 | Wszystkie listy maja stan ladowania, pusty, bledu i dane. Blad ma akcje ponowienia. |
| SYS-004 | P0 | Dodanie, edycja i usuniecie pokazuja jednoznaczny wynik; utrata niezapisanego formularza wymaga potwierdzenia. |
| SYS-005 | P0 | Daty sa zapisywane w UTC i prezentowane w lokalnej strefie; kwoty sa zapisywane w groszach, bez `double`. |
| SYS-006 | P0 | Usuniecie rekordu finansowego lub dowodu wymaga potwierdzenia; rekord powiazany nie moze zniknac bez informacji o skutkach. |
| SYS-007 | P0 | Wyszukiwanie i filtry pamietaja stan w ramach biezacej sesji ekranu. |
| SYS-008 | P0 | Zalaczniki pozostaja lokalnie. Eksport, udostepnienie lub backup nastepuje tylko po akcji uzytkownika. |
| SYS-009 | P1 | Globalna akcja `+` tworzy szkic, ktory nie zmienia budzetu ani postepu do chwili zatwierdzenia. |
| SYS-010 | P1 | Kazde ostrzezenie o ryzyku prowadzi do rekordu zrodlowego i pokazuje proponowana nastepna akcje. |
| SYS-011 | P1 | Wazne zmiany maja historie: data, typ zmiany, wartosc przed/po i zrodlo. |
| SYS-012 | P0 | Wszystkie teksty interfejsu sa w plikach lokalizacji; pierwsza wersja jezykowa to polski. |

## 7. Projekty i konfiguracja inwestycji

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| PRJ-001 | P0 | Uzytkownik tworzy projekt typu: budowa domu, remont domu albo remont mieszkania. |
| PRJ-002 | P0 | Projekt zawiera nazwe, adres/etykiete, walute, powierzchnie, daty planowane, budzet i aktualny etap. |
| PRJ-003 | P0 | Uzytkownik wybiera szablon etapow i checklist odpowiedni dla typu projektu. |
| PRJ-004 | P0 | Szablon mozna dostosowac bez zmiany danych innych projektow. |
| PRJ-005 | P0 | Selektor projektu pozwala przelaczac wiele inwestycji. |
| PRJ-006 | P1 | Projekt mozna zarchiwizowac po odbiorze i przeksztalcic w karte domu. |
| PRJ-007 | P0 | Usuniecie projektu wymaga jawnego potwierdzenia i informacji o liczbie powiazanych plikow. |

## 8. Start - centrum inwestora

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| DASH-001 | P0 | Start pokazuje aktualny etap, budzet wykorzystany i pozostaly budzet. |
| DASH-002 | P0 | Wskazniki pokazuja: wydano, plan na 30 dni i nieoplacone pozycje. |
| DASH-003 | P1 | Pasek kondycji pokazuje poziom i konkretne przyczyny, bez ukrytego wyniku. |
| DASH-004 | P0 | Szybkie akcje otwieraja: dodanie kosztu, OCR, checklisty, zdjecia etapow, usterke i asystenta. |
| DASH-005 | P1 | Start pokazuje licznik szkicow szybkiego zapisu. |
| DASH-006 | P0 | Sekcja krytyczna pokazuje zadania konieczne przed najblizsza praca nieodwracalna. |
| DASH-007 | P0 | Osi czasu pokazuje zakonczone, aktywne i przyszle etapy. |
| DASH-008 | P0 | Agenda pokazuje dzisiejsze wizyty, odbiory, dostawy i zadania w kolejnosci czasu. |
| DASH-009 | P1 | Klikniecie wskaznika, ryzyka lub zdarzenia otwiera odpowiedni filtrowany modul. |

## 9. Budzet, koszty, oferty i plan

### 9.1 Rejestr kosztow

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| COST-001 | P0 | Rejestr obsluguje typy: koszt, oferta i planowana pozycja. |
| COST-002 | P0 | Pozycja zawiera nazwe, date, etap, kategorie, dostawce, ilosc, jednostke, netto, VAT, brutto, status, metode platnosci, zrodlo, notatke i zalaczniki. |
| COST-003 | P0 | Statusy finansowe to: planowany, zamowiony, do zaplaty, oplacony, zwrocony i sporny. |
| COST-004 | P0 | Kwota netto, VAT i brutto sa liczone wedlug jednej testowanej reguly zaokraglen. |
| COST-005 | P0 | Lista pokazuje nazwe, kontekst, zrodlo/status i kwote. |
| COST-006 | P0 | Uzytkownik wyszukuje po nazwie, wykonawcy, opisie i tagu. |
| COST-007 | P0 | Filtry obejmuja date, etap, kategorie, wykonawce, status, metode platnosci, zrodlo, gwarancje i tagi. |
| COST-008 | P0 | Podsumowanie filtrow pokazuje plan, wykonanie i roznice. |
| COST-009 | P0 | Szczegoly kosztu pokazuja powiazany dokument, decyzje, material, pomieszczenie i historie zmian. |
| COST-010 | P0 | Uzytkownik moze utworzyc, edytowac, skopiowac, oznaczyc platnosc, zapisac szkic i usunac pozycje. |
| COST-011 | P0 | Brakujacy dokument, niepelny opis albo podejrzany VAT sa widocznym ostrzezeniem. |
| COST-012 | P1 | Powiazana decyzja zapisuje delte kosztu bez kasowania pierwotnego planu. |

### 9.2 Formularz kosztu

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| COST-013 | P0 | Formularz waliduje pola wymagane i nie przyjmuje ujemnej kwoty poza kontrolowanym zwrotem/korekta. |
| COST-014 | P0 | Etap, kategoria i wykonawca sa wybierane z danych projektu, z mozliwoscia szybkiego dodania brakujacej wartosci. |
| COST-015 | P0 | Zalacznik moze pochodzic ze skanera, aparatu lub systemowego wyboru pliku. |
| COST-016 | P0 | `Zapisz szkic` nie wlicza pozycji do podsumowan. |
| COST-017 | P0 | `Zapisz koszt` wykonuje zapis kosztu i zalacznikow atomowo. |

## 10. Skan paragonu i OCR

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| OCR-001 | P1 | Uzytkownik skanuje dokument aparatem albo importuje istniejace zdjecie/PDF. |
| OCR-002 | P1 | Skaner wykonuje wykrycie krawedzi, kadrowanie i czytelny podglad dokumentu. |
| OCR-003 | P1 | OCR dziala na urzadzeniu, jezeli wspierany silnik jest dostepny. |
| OCR-004 | P1 | Wynik zawiera sprzedawce, date, numer dokumentu, kwoty, VAT i rozpoznane pozycje. |
| OCR-005 | P1 | Kazde pole ma poziom pewnosci; niepewne wartosci sa wyroznione do korekty. |
| OCR-006 | P1 | Uzytkownik moze laczyc, dzielic, usuwac i poprawiac linie przed zapisem. |
| OCR-007 | P1 | OCR nigdy nie zmienia budzetu bez jawnego potwierdzenia. |
| OCR-008 | P1 | Przed zapisem aplikacja sprawdza duplikat po skrocie pliku oraz kombinacji sprzedawca/data/suma. |
| OCR-009 | P1 | Oryginal skanu pozostaje zalacznikiem, a zatwierdzone linie tworza koszty w jednej transakcji. |
| OCR-010 | P1 | Blad skanu lub OCR jest ponawialny; reczne dodanie kosztu pozostaje dostepne. |

## 11. Plan, etapy i checklisty

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| PLAN-001 | P0 | Projekt ma uporzadkowane etapy z planowanymi datami, budzetem, statusem i postepem. |
| PLAN-002 | P0 | Dostepne sa szablony dla domu oraz remontu; uzytkownik moze dodac, nazwac i przestawic etap. |
| PLAN-003 | P0 | Etap grupuje checklisty, koszty, kontakty, terminy, dokumenty, zdjecia i ryzyka. |
| PLAN-004 | P0 | Checklista ma status: do zrobienia, w toku, zablokowana, zakonczona albo pominieta z powodem. |
| PLAN-005 | P0 | Element checklisty ma waznosc, termin, osobe, notatke, ryzyko pominiecia i wymagany dowod. |
| PLAN-006 | P0 | Wymagany element nie moze byc zamkniety bez dowodu albo jawnego odstapienia z komentarzem. |
| PLAN-007 | P0 | Postep etapu wynika z checklisty, nie z recznie wpisanego procentu. |
| PLAN-008 | P0 | Plan 7 dni laczy zadania, wizyty, dostawy, odbiory i prace blokowane. |
| PLAN-009 | P1 | Zaleznosci pokazuja, co blokuje nastepna prace i jaki jest termin decyzji. |
| PLAN-010 | P1 | Kalendarz pozwala przelozyc zdarzenie i zachowuje historie zmiany terminu. |

### 11.1 Minimalna checklista `Stan 0`

Szablon musi zawierac co najmniej:

- badania gruntu i warunki wodne,
- geodete oraz wytyczenie budynku,
- droge, prad i wode na budowe,
- poziomy wykopu, law i posadowienia,
- kanalizacje podposadzkowa i piony,
- przepust wody,
- przepust pradu,
- przepust internetu/teletechniki,
- przepust gazu, jezeli dotyczy,
- rezerwe do bramy, domofonu i ogrodu,
- rezerwe do pompy ciepla/jednostek zewnetrznych,
- bednarke i uziom fundamentowy,
- pomiar ciaglosci przed betonowaniem,
- izolacje pozioma/pionowa oraz hydroizolacje,
- odwodnienie i drenaz, jezeli wynika z projektu,
- zdjecia zbrojenia, przepustow i uziomu przed zakryciem,
- dokument WZ betonu i protokol odbioru,
- inwentaryzacje po wykonaniu fundamentow.

## 12. Kontakty, ekipy, oferty i wizyty

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| CNT-001 | P0 | Kontakt przechowuje osobe/firme, role, telefon, e-mail, NIP opcjonalny, notatke i ocene. |
| CNT-002 | P0 | Kontakt moze byc przypisany do wielu etapow, pomieszczen i zakresow. |
| CNT-003 | P0 | Uzytkownik dzwoni albo otwiera wiadomosc z poziomu kontaktu po potwierdzeniu akcji systemowej. |
| CNT-004 | P0 | Wizyta ma date, cel, etap, oczekiwany rezultat, przypomnienie i status. |
| CNT-005 | P0 | Po wizycie mozna dodac notatke, zdjecia, ustalenia i nowe zadania. |
| CNT-006 | P0 | Status wizyty to: planowana, wykonana, odwolana albo wykonawca nie przyjechal. |
| CNT-007 | P0 | Oferta zawiera zakres, kwote, wariant, termin waznosci, zalaczniki i wykluczenia. |
| CNT-008 | P1 | Porownanie ofert zestawia ceny oraz zakres, aby najtansza nie byla automatycznie oznaczona jako najlepsza. |

## 13. Dokumenty i zalaczniki

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| DOC-001 | P0 | Aplikacja importuje lokalnie PDF, obrazy i inne wspierane dokumenty przez systemowy picker. |
| DOC-002 | P0 | Typy dokumentow obejmuja paragon, fakture, oferte, umowe, WZ, protokol, gwarancje, instrukcje i mape. |
| DOC-003 | P0 | Dokument moze byc powiazany z kosztem, etapem, checklista, kontaktem, pomieszczeniem, decyzja, usterka i urzadzeniem. |
| DOC-004 | P0 | Lista ma wyszukiwanie oraz filtry typu, etapu, pomieszczenia, daty i waznosci gwarancji. |
| DOC-005 | P0 | Podglad pokazuje metadane, wszystkie powiazania i akcje: otworz, zmien opis, eksportuj, usun. |
| DOC-006 | P0 | Import zachowuje oryginal i tworzy osobna miniature/podglad. |
| DOC-007 | P1 | Aplikacja wykrywa potencjalny duplikat pliku po hashu. |
| DOC-008 | P1 | Gwarancja ma date rozpoczecia/zakonczenia i moze utworzyc przypomnienie. |

## 14. Dokumentacja techniczna i plan instalacji

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| TECH-001 | P1 | Zdjecie techniczne ma etap, pomieszczenie/strefe, typ instalacji, date, wykonawce, opis i tagi. |
| TECH-002 | P1 | Albumy grupuja dowody m.in. przed betonem, zasypaniem, tynkiem, wylewka i plytkami. |
| TECH-003 | P1 | Wyszukiwanie obejmuje opis, etap, pomieszczenie, instalacje i tag. |
| TECH-004 | P1 | Uzytkownik moze powiazac zdjecie z checklista, kosztem, protokolem, decyzja albo usterka. |
| TECH-005 | P1 | Projekt przyjmuje wersjonowany rzut jako obraz albo strone PDF. |
| TECH-006 | P1 | Pinezka zapisuje znormalizowana pozycje i typ: zdjecie, instalacja, usterka, pomiar, urzadzenie lub dowod. |
| TECH-007 | P1 | Pinezka otwiera powiazane rekordy; zmiana wersji planu nie przenosi jej automatycznie. |
| TECH-008 | P1 | Widok najpierw laduje ograniczony podglad, a pelny plik dopiero na zadanie. |

## 15. Pomieszczenia i wybory remontowe

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| ROOM-001 | P1 | Uzytkownik tworzy pomieszczenia i strefy z kondygnacja, wymiarami, standardem i budzetem. |
| ROOM-002 | P1 | Karta pomieszczenia pokazuje plan, koszt rzeczywisty, otwarte decyzje, materialy, ekipy, zdjecia i usterki. |
| ROOM-003 | P1 | Karta wyboru przechowuje warianty, ilosc, zapas, cene, termin zamowienia i wybrana opcje. |
| ROOM-004 | P1 | Wybor moze utworzyc planowany koszt, material i decyzje. |
| ROOM-005 | P1 | Podsumowanie pokazuje budzet wszystkich pomieszczen i liczbe otwartych wyborow. |

## 16. Materialy, dostawy, zwroty i kalkulatory

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| MAT-001 | P1 | Material zawiera nazwe, etap/pomieszczenie, dostawce, ilosc, jednostke, koszt i miejsce skladowania. |
| MAT-002 | P1 | Statusy to: planowany, zamowiony, czesciowo dostarczony, dostarczony, opozniony i zwrocony. |
| MAT-003 | P1 | Dostawa ma termin, dostarczona ilosc, dokument WZ, kontakt i notatke o brakach/uszkodzeniu. |
| MAT-004 | P1 | Uzytkownik zapisuje termin zwrotu, ilosc, przewidywana kwote i wymagany paragon. |
| MAT-005 | P1 | Dashboard materialow pokazuje wartosc zamowien, zwrotow i liczbe opoznien. |
| MAT-006 | P1 | Kalkulatory obejmuja co najmniej plytki z zapasem, farbe, objetosc betonu i izolacje dachu. |
| MAT-007 | P1 | Wynik kalkulatora jest propozycja i moze utworzyc szkic materialu; nie sklada zamowienia. |

## 17. Odbiory, usterki i poprawki

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| PUNCH-001 | P1 | Usterka ma tytul, etap/pomieszczenie, waznosc, odpowiedzialnego, termin, opis i zdjecia. |
| PUNCH-002 | P1 | Statusy to: otwarta, w trakcie, do ponownej kontroli, poprawiona i zamknieta. |
| PUNCH-003 | P1 | Zamkniecie moze wymagac zdjecia po poprawce i podpisanego protokolu. |
| PUNCH-004 | P1 | Lista filtruje po statusie, waznosci, terminie, osobie, etapie i pomieszczeniu. |
| PUNCH-005 | P1 | Liczniki pokazuja otwarte, krytyczne i przeterminowane usterki. |
| PUNCH-006 | P1 | Usterke mozna dodac z aparatu lub pinezki na planie. |
| PUNCH-007 | P1 | Wybrane pozycje trafiaja do lokalnego protokolu odbioru PDF. |

## 18. Szybki zapis i skrzynka szkicow

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| CAP-001 | P1 | Globalny szybki zapis przyjmuje paragon, zdjecie, PDF, notatke tekstowa, glos, koszt, zadanie, decyzje albo usterke. |
| CAP-002 | P1 | Przechwycony element od razu zapisuje sie jako lokalny szkic. |
| CAP-003 | P1 | Szkic ma typ proponowany, date, projekt, plik/tekst, status przetwarzania i brakujacy kontekst. |
| CAP-004 | P1 | Notatka glosowa zachowuje audio; transkrypcja, jezeli dostepna, jest tylko propozycja. |
| CAP-005 | P1 | Skrzynka pokazuje licznik, powod wymaganej kontroli oraz akcje: uzupelnij, zatwierdz, polacz, odrzuc. |
| CAP-006 | P1 | Zatwierdzenie klasyfikuje szkic i tworzy rekord docelowy w jednej transakcji. |
| CAP-007 | P1 | Szkice nie sa wliczane do budzetu, postepu ani raportow. |

## 19. Dziennik, decyzje i zmiany zakresu

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| DIARY-001 | P1 | Dzienny wpis zawiera date, pogode opcjonalna, osoby/ekipy, wykonane prace, dostawy, opoznienia i nastepne kroki. |
| DIARY-002 | P1 | Do wpisu mozna dolaczyc zdjecia, glos, dokumenty, checklisty i kontakty. |
| DIARY-003 | P1 | Decyzja przechowuje problem, warianty, wybrana opcje, powod, osobe decyzyjna, termin i status. |
| DIARY-004 | P1 | Statusy decyzji to: propozycja, oczekuje, zatwierdzona, odrzucona i wdrozona. |
| DIARY-005 | P1 | Decyzja pokazuje delte kosztu i terminu oraz rekordy, ktore blokuje. |
| DIARY-006 | P1 | Zatwierdzenie zapisuje date i osobe; pozniejsza korekta tworzy nowa wersje historii. |
| DIARY-007 | P1 | Historia zmian budzetu sumuje wplyw decyzji bez nadpisywania bazowego planu. |

## 20. Raporty i eksport

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| REP-001 | P0 | Raport budzetu pokazuje plan, koszt zobowiazany, zaplacony i pozostaly. |
| REP-002 | P0 | Przekroje obejmuja etap, kategorie, wykonawce i miesiac. |
| REP-003 | P1 | Raport pokazuje przyszle wydatki, nieoplacone pozycje, zwroty, decyzje kosztowe, OCR do korekty i gwarancje. |
| REP-004 | P0 | Klikniecie elementu raportu otwiera filtrowane rekordy zrodlowe. |
| REP-005 | P0 | Eksport CSV respektuje aktywne filtry i zawiera jawnie wskazane kolumny. |
| REP-006 | P1 | Eksport PDF tworzy czytelne podsumowanie dla inwestora, banku albo odbioru. |
| REP-007 | P0 | Przed eksportem aplikacja pokazuje zakres danych i lokalizacje docelowa. |
| REP-008 | P0 | Generowanie raportu nie blokuje interfejsu i nie zapisuje tresci do logow. |

## 21. Kondycja projektu i Asystent BudowaPRO

### 21.1 Deterministyczna kondycja projektu

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| HEALTH-001 | P1 | Silnik lokalny sprawdza budzet, terminy, checklisty, decyzje, dowody, platnosci, zwroty i usterki. |
| HEALTH-002 | P1 | Wynik ma poziom oraz liste nazwanych powodow; nie moze byc nieobjasniona liczba. |
| HEALTH-003 | P1 | Reguly uwzgledniaja prace nieodwracalne i brak wymaganych zdjec/protokolow. |
| HEALTH-004 | P1 | Ostrzezenie ma waznosc, termin, zrodlo i konkretna akcje. |
| HEALTH-005 | P1 | Reguly sa wersjonowane, deterministyczne i testowane na granicach dat oraz kwot. |

### 21.2 Asystent offline

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| AST-001 | P1 | Asystent offline wyjasnia ryzyka i znaczenie elementow checklisty na podstawie lokalnych regul. |
| AST-002 | P1 | Moze przygotowac pytania do kierownika albo wykonawcy dla wybranego etapu. |
| AST-003 | P1 | Moze podsumowac wskazane rekordy i utworzyc szkic zadania/notatki. |
| AST-004 | P1 | Nie moze odbierac prac, zatwierdzac kosztow, wykonywac platnosci ani usuwac danych. |
| AST-005 | P1 | Kazda sugestia wskazuje uzyte lokalne dane lub regule. |

### 21.3 Opcjonalny tryb AI

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| AI-001 | P2 | Tryb AI jest domyslnie wylaczony i wymaga osobnej decyzji produktowej oraz zgody uzytkownika. |
| AI-002 | P2 | Przed wyslaniem uzytkownik wybiera rekordy i widzi dokladny podglad danych. |
| AI-003 | P2 | Odpowiedz AI jest niezaufana i moze tylko utworzyc sugestie lub szkic. |
| AI-004 | P2 | Aplikacja pokazuje dostawce, cel, retencje i mozliwosc anulowania przed transmisja. |

## 22. Karta domu, gwarancje i serwis

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| HOME-001 | P1 | Po odbiorze dane projektu pozostaja dostepne jako trwala karta domu. |
| HOME-002 | P1 | Karta pokazuje kompletnosc dokumentacji oraz liste brakujacych protokolow, instrukcji i numerow seryjnych. |
| HOME-003 | P1 | Urzadzenie ma nazwe, model, numer seryjny, lokalizacje, wykonawce, montaz, gwarancje i instrukcje. |
| HOME-004 | P1 | Punkt instalacji moze miec pinezke na planie, zdjecia i protokol pomiarowy. |
| HOME-005 | P1 | Przypomnienie serwisowe ma date, cykl, wykonawce, warunek gwarancji i status. |
| HOME-006 | P1 | Historia przechowuje serwisy, naprawy, wymiany i kolejne remonty. |
| HOME-007 | P1 | Uzytkownik eksportuje wybrany pakiet domu dla serwisu, ubezpieczyciela albo kupujacego. |

## 23. Ustawienia, prywatnosc i backup

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| SET-001 | P0 | Ekran jasno pokazuje, ze dane sa lokalne oraz ze konto i backend nie sa wymagane. |
| SET-002 | P0 | Aparat, mikrofon i wybor pliku sa uruchamiane dopiero po akcji uzytkownika. |
| SET-003 | P0 | Uzytkownik moze zmienic szablon projektu, walute, format daty i ustawienia przypomnien. |
| SET-004 | P1 | Asystent offline moze byc wlaczony lub wylaczony bez utraty danych. |
| SET-005 | P2 | Opcjonalny AI ma oddzielny przelacznik, ekran zgody i historie cofniecia zgody. |
| SET-006 | P0 | Backup ZIP zawiera wersjonowany manifest, baze, pliki i sumy kontrolne. |
| SET-007 | P0 | Przywracanie sprawdza wersje, wolne miejsce, sumy i sciezki przed zmiana aktywnych danych. |
| SET-008 | P1 | Ekran pamieci pokazuje rozmiar zdjec, dokumentow, miniaturek i backupow. |

## 24. Powiadomienia

| ID | Priorytet | Wymaganie |
| --- | --- | --- |
| NOTIF-001 | P0 | Lokalne przypomnienia obejmuja wizyty, zadania i platnosci. |
| NOTIF-002 | P1 | Przypomnienia obejmuja decyzje blokujace, dostawy, zwroty, usterki, serwisy i koniec gwarancji. |
| NOTIF-003 | P0 | Kazde powiadomienie otwiera rekord zrodlowy. |
| NOTIF-004 | P0 | Uzytkownik ustawia typy, godziny i wyprzedzenie; brak zgody systemowej nie blokuje aplikacji. |

## 25. Model danych

Glowne encje:

- `Project`, `Stage`, `ChecklistItem`, `ScheduleEntry`,
- `CostItem`, `Budget`, `Receipt`, `ReceiptLine`,
- `Contact`, `Quote`, `Appointment`,
- `Attachment`, `TechnicalPhoto`, `Plan`, `PlanPin`,
- `Room`, `SelectionCard`,
- `Material`, `Delivery`, `Return`,
- `PunchItem`, `AcceptanceProtocol`,
- `CaptureDraft`, `DailyLog`, `Decision`, `ChangeImpact`,
- `Equipment`, `Warranty`, `ServiceReminder`,
- `HealthReason`, `AssistantSuggestion`, `NotificationRule`.

Wspolny kontekst rekordu zawiera obowiazkowy `projectId` oraz opcjonalne: `stageId`, `roomId`, `contactId`, `checklistItemId`, `costItemId` i `planPinId`.

Minimalne indeksy:

- koszty po projekcie+dacie, etapie, kategorii, wykonawcy i statusie,
- checklisty po projekcie+etapie+statusie,
- terminy po projekcie+dacie,
- szkice po projekcie+statusie+dacie,
- decyzje po projekcie+statusie+terminie,
- usterki po projekcie+statusie+terminie,
- zalaczniki po projekcie+etapie+pomieszczeniu+typie,
- pinezki po planie+typie.

## 26. Wymagania niefunkcjonalne

### 26.1 Wydajnosc

- zimny start ponizej 2 sekund na referencyjnym telefonie Android sredniej klasy,
- gotowy dashboard z cieplej bazy ponizej 500 ms,
- reakcja filtrow kosztow ponizej 200 ms dla 10 000 pozycji,
- listy stronicowane lub ladowane leniwie,
- OCR, miniatury, raporty i ZIP poza glownym watkiem UI,
- pelne zdjecia ladowane dopiero w szczegolach.

### 26.2 Bezpieczenstwo i prywatnosc

- brak automatycznego uploadu,
- zapytania SQL parametryzowane,
- walidacja typu, rozmiaru i sciezki importowanego pliku,
- ochrona przed path traversal przy odtwarzaniu backupu,
- brak tresci paragonow, dokumentow, kontaktow i notatek w logach,
- minimalne uprawnienia proszone just-in-time,
- sekrety poza repozytorium,
- opcjonalna blokada aplikacji i szyfrowany backup dopiero po analizie zagrozen.

### 26.3 Dostepnosc i UX

- maksymalnie dwa stukniecia od Startu do dodania kosztu albo skanu,
- maksymalnie trzy stukniecia do najwazniejszego rekordu,
- obszar dotyku minimum 48x48 dp,
- etykiety dla ikon i czytnikow ekranu,
- kontrast zgodny co najmniej z WCAG AA,
- formularze zachowuja dane po bledzie,
- animacje maksymalnie 250 ms,
- interfejs nie wymaga stalego internetu.

### 26.4 Obserwowalnosc

Dozwolone sa lokalne lub anonimowe zdarzenia techniczne: wersja aplikacji/schematu, nazwa funkcji, czas w przedziale, kategoria sukcesu/bledu. Zabroniona jest tresc dokumentow i dane osobowe. Telemetria produktu nie jest wymagana w MVP.

## 27. Kryteria akceptacji przeplywow end-to-end

### E2E-01 Reczny koszt

Uzytkownik tworzy projekt, dodaje oplacony koszt z faktura, odnajduje go filtrem i widzi poprawione podsumowanie budzetu po ponownym uruchomieniu aplikacji.

### E2E-02 Paragon OCR

Uzytkownik skanuje paragon, poprawia niepewna linie, zatwierdza trzy pozycje i otrzymuje jeden dokument powiazany z trzema kosztami bez duplikatu.

### E2E-03 Praca przed zakryciem

Uzytkownik widzi ostrzezenie przed betonowaniem, otwiera checkliste uziomu, dodaje zdjecie oraz potwierdzenie i zamyka element. Kondycja projektu aktualizuje sie z podaniem powodu.

### E2E-04 Decyzja zmieniajaca zakres

Uzytkownik zapisuje warianty przepustu, zatwierdza wybor z delta `+1250 zl`, a raport pokazuje zmiane bez utraty pierwotnego planu.

### E2E-05 Dokumentacja ukrytej instalacji

Uzytkownik dodaje zdjecia instalacji do kuchni, przypina je do rzutu i po odbiorze znajduje je przez karte domu oraz pinezke.

### E2E-06 Remont pomieszczenia

Uzytkownik tworzy lazienke, wpisuje budzet, porownuje wariant plytek, tworzy material, rejestruje dostawe i zamyka usterke zdjeciem po poprawce.

### E2E-07 Backup i odtworzenie

Uzytkownik tworzy lokalny backup, usuwa dane testowe, odtwarza backup i otrzymuje identyczne sumy, rekordy oraz zalaczniki po sprawdzeniu integralnosci.

## 28. Poza zakresem P0/P1

- prawnie obowiazujacy dziennik budowy,
- zastepowanie kierownika budowy, projektanta lub inspektora,
- platnosci i bankowosc,
- automatyczne zamawianie materialow,
- edycja CAD/BIM,
- automatyczny dostep ekip do prywatnych danych,
- ukryty scoring wykonawcow,
- automatyczne decyzje finansowe albo odbiory przez AI.

## 29. Otwarte decyzje przed implementacja

1. Czy selektor projektu ma byc stale widoczny, czy dopiero po utworzeniu drugiego projektu?
2. Czy paragon domyslnie tworzy jeden koszt zbiorczy, czy osobne linie?
3. Czy polski jest jedynym jezykiem pierwszego wydania?
4. Czy backup ma byc domyslnie nieszyfrowany, czy zabezpieczony haslem od pierwszej wersji?
5. Jaki model monetyzacji nie naruszy local-first: zakup jednorazowy, premium czy platne szablony?
