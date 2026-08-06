# BudowaPRO 1.0.0 - robocza deklaracja prywatności sklepów

Stan: 2026-08-06. Deklarację trzeba porównać z raportem finalnego podpisanego
AAB/IPA. Zmiana SDK, uprawnień albo backendu unieważnia ten arkusz.

## Przepływy aplikacji

| Obszar | Stan R1 |
| --- | --- |
| Konto i logowanie | Brak |
| Własny backend/synchronizacja | Brak |
| Reklamy | Brak |
| Własna analityka/Crashlytics | Brak |
| Dane projektów | Prywatna pamięć urządzenia |
| Eksport/backup | Wyłącznie po akcji użytkownika |
| OCR obrazu i tekstu | Na urządzeniu |
| Google ML Kit | Możliwe zaszyfrowane metryki techniczne SDK |
| Kontakty | Pojedynczy wynik systemowego selektora |
| Powiadomienia | Lokalne przypomnienia |
| Systemowy backup | Android: wykluczony; iOS: prywatny katalog danych wyłączony z iCloud Backup |

## Google Play Data safety - rekomendowane odpowiedzi R1

- Zadeklarować zbieranie przez Google ML Kit, mimo że wydawca nie ma backendu.
- Kategorie do sprawdzenia w aktualnym formularzu: identyfikatory urządzenia
  lub inne identyfikatory, interakcje z aplikacją, diagnostyka i inne dane o
  wydajności aplikacji.
- Cele: analityka użycia SDK oraz diagnostyka. Dane nie służą reklamom,
  personalizacji ani marketingowemu śledzeniu.
- Udostępnianie osobom trzecim: według dokumentacji ML Kit nie; Google opisuje
  te dane jako zbierane przez SDK i przesyłane szyfrowanym HTTPS.
- Obraz, tekst wejściowy i wynik OCR nie są wysyłane do Google.
- Dane projektów, zdjęcia, dokumenty, dane kontaktowe i finanse nie są
  przesyłane do wydawcy.
- Dane lokalne można usunąć w aplikacji bez konta. Aplikacja nie ma własnego
  zdalnego zbioru, który wydawca mógłby usunąć na żądanie.

## Apple App Privacy - rekomendowane odpowiedzi R1

- Tracking: nie. Identyfikator reklamowy: brak.
- Dane zbierane przez własny backend wydawcy: brak.
- Dla ML Kit sprawdzić i zadeklarować odpowiedniki: Device ID, Product
  Interaction/Other Usage Data, Performance Data oraz Diagnostics/Error Data.
- Cele ML Kit: Analytics i diagnostyka działania SDK; dane nie są używane do
  reklam ani śledzenia między aplikacjami i witrynami.
- Powiązanie z tożsamością: metryki ML Kit korzystają z identyfikatora
  instalacji, który według Google nie ma jednoznacznie identyfikować użytkownika
  ani fizycznego urządzenia. Ostateczną odpowiedź porównać z aktualnym
  formularzem App Privacy i raportem finalnego archive.
- Dane wybrane do systemowego eksportu są przetwarzane na polecenie
  użytkownika, poza aplikacją docelową według zasad tego odbiorcy.

Źródła dostawcy:

- https://developers.google.com/ml-kit/terms
- https://developers.google.com/ml-kit/android-data-disclosure
- https://developers.google.com/ml-kit/ios-data-disclosure

## Kontrola przed zatwierdzeniem formularzy

1. Zbudować podpisany artefakt z finalnym SHA i finalnymi wersjami zależności.
2. Porównać Android merged manifest i iOS privacy report z tym arkuszem.
3. Sprawdzić aktualne ujawnienia Google ML Kit.
4. Potwierdzić identyczne praktyki w aplikacji, polityce online i listingach.
5. Zapisać datę, SHA commit i osobę zatwierdzającą w protokole wydania.
