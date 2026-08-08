# BudowaPRO - audyt dokumentow prawnych i Google Play

Stan: 2026-08-08. Zakres: aplikacja `1.0.0`, statyczne strony pod
`budowaproapp.pl`, Android/iOS local-first oraz zaleznosci obecne w repozytorium.

Ten dokument opisuje stan techniczny i informacyjny. Nie jest gwarancja
akceptacji przez Google Play ani zastepstwem indywidualnej porady prawnej.

## Wynik

- publiczna polityka, regulamin, wsparcie i instrukcja usuwania danych sa
  dostepne bez konta pod osobnymi adresami HTTPS;
- polityka w aplikacji i online opisuje lokalne dane, Google ML Kit,
  logi GitHub Pages, role dostawcow, korespondencje, podstawy prawne,
  transfery poza EOG, retencje, prawa RODO, bezpieczenstwo i usuwanie;
- regulamin obejmuje elementy art. 8 ustawy o swiadczeniu uslug droga
  elektroniczna: rodzaj i zakres, wymagania techniczne, zakaz tresci
  bezprawnych, zawarcie i rozwiazanie umowy oraz reklamacje;
- dane uslugodawcy sa widoczne tylko w dokumentach prawnych. Zwykly ekran
  kontaktowy pokazuje marke BudowaPRO i `kontakt@budowaproapp.pl`;
- strona nie ma skryptow, formularzy, reklam ani wlasnej analityki. Kazdy HTML
  ma restrykcyjna CSP i `no-referrer`;
- aplikacja nie ma konta ani backendu. Instrukcja usuwania nie udaje zdalnego
  mechanizmu usuwania konta i opisuje rzeczywista lokalna operacje.
- pierwsze uruchomienie blokuje funkcje projektu do czasu udostepnienia
  regulaminu i lokalnego potwierdzenia aktualnej wersji. Potwierdzenie i czas sa
  zapisywane tylko na urzadzeniu; starsza zaakceptowana wersja nie odblokuje
  zmienionego regulaminu;
- walidator Android release sprawdza dane wydawcy, kontakt, publiczny URL
  polityki i publiczny URL wsparcia. NIP, adres i URL regulaminu maja stale
  produkcyjne objete testami domenowymi.

## Zweryfikowana tozsamosc

Wykaz podatnikow VAT Ministerstwa Finansow potwierdzil 2026-08-08 dla NIP
`6443558164`: `PRZEMYSLAW SOBCZYK`, adres `PRZYGRANICZNA 40, 41-203
SOSNOWIEC`, status VAT czynny. Zapytanie kontrolne:

`https://wl-api.mf.gov.pl/api/search/nip/6443558164?date=2026-08-08`

Id zapytania MF: `tne7Q-987hf95`. Przed kazdym wydaniem dane trzeba porownac z
aktualnym wpisem i danymi konta deweloperskiego.

## Podstawy i zrodla

- Google Play User Data:
  https://support.google.com/googleplay/android-developer/answer/10144311
- Google Play Data safety:
  https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play - usuwanie kont:
  https://support.google.com/googleplay/android-developer/answer/13327111
- Google ML Kit - warunki i prywatnosc:
  https://developers.google.com/ml-kit/terms
- Google ML Kit - ujawnianie danych Android SDK:
  https://developers.google.com/ml-kit/android-data-disclosure
- RODO, art. 13:
  https://eur-lex.europa.eu/eli/reg/2016/679/oj
- UODO - obowiazek informacyjny i prawa:
  https://uodo.gov.pl/pl/645/4097
- ustawa o swiadczeniu uslug droga elektroniczna, w szczegolnosci art. 5 i 8:
  https://eli.gov.pl/eli/DU/2024/1513/ogl
- ustawa o prawach konsumenta, tresci i uslugi cyfrowe:
  https://eli.gov.pl/eli/DU/2024/1796/ogl

Polityka prywatnosci Google i warunki Play Console reguluja odpowiednio
przetwarzanie przez Google oraz relacje wydawcy z Google. Nie zastepuja
wlasnej polityki ani regulaminu BudowaPRO.

## Formularz Google Play

`store/privacy/store-declarations.md` zawiera konkretna mape odpowiedzi dla R1:
`App interactions`, `Diagnostics` oraz `Device or other IDs` sa zbierane przez
ML Kit dla `Analytics`, szyfrowane w tranzycie i wedlug Google nie sa
udostepniane. Skaner jest opcjonalny, dlatego arkusz wskazuje `Required: No`;
jezeli finalny artefakt wykaze transmisje przed uzyciem skanera, odpowiedz trzeba
zmienic na `Yes`.

Przed zatwierdzeniem Data safety trzeba porownac deklaracje z finalnym
podpisanym AAB, merged manifestem i aktualnymi ujawnieniami kazdego SDK.
Formularz obejmuje sume praktyk wszystkich wersji aktywnych w Google Play.

Obecny model wymaga ujawnienia technicznych danych zbieranych przez ML Kit.
Lokalne projekty, dokumenty, zdjecia, finanse i kontakty nie sa kolekcja
wydawcy, o ile nie opuszczaja urzadzenia w wyniku wyraznej akcji uzytkownika.

## Zdarzenia wymuszajace ponowny audyt

- reklamy lub identyfikator reklamowy;
- konto, logowanie, backend, synchronizacja lub chmura;
- platnosci, subskrypcja albo wersja PRO;
- analityka, Crashlytics, Sentry albo nowe logowanie sieciowe;
- formularz na stronie, cookies niekonieczne lub zewnetrzne osadzenia;
- zmiana ML Kit, nowy SDK, nowe uprawnienie albo nowy przeplyw eksportu;
- kierowanie aplikacji do dzieci lub przetwarzanie nowych kategorii danych.

## Bramy wlasciciela

1. Wprowadzic zgodne odpowiedzi w Play Console i zapisac ich eksport lub zrzut.
2. Podac URL `https://budowaproapp.pl/privacy/` w polu Privacy policy oraz
   `https://budowaproapp.pl/support/` jako website/support.
3. Sprawdzic publiczne odpowiedzi HTTPS po wdrozeniu konkretnego commita.
4. Porownac nazwe, adres i NIP z aktualnym rejestrem oraz profilem dewelopera.
5. Zlecic prawnikowi finalny przeglad przed monetyzacja, sprzedaza za granica
   albo zmiana modelu danych.

## Ograniczenia hostingu statycznego

GitHub Pages nie pozwala ustawic w repozytorium wszystkich naglowkow odpowiedzi
HTTP, takich jak naglowkowa CSP, HSTS, `frame-ancestors` i
`X-Content-Type-Options`. Wdrozenie stosuje meta-CSP, `no-referrer`, HTTPS oraz
brak skryptow i formularzy. Pelna kontrola naglowkow wymaga warstwy proxy/CDN,
np. Cloudflare, i osobnego audytu konfiguracji DNS/TLS. Nie jest to warunek
samego pola Privacy policy w Google Play, ale pozostaje zaleceniem hardeningu.
