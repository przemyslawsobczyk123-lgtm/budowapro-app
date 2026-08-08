# BudowaPRO 1.0.0 - deklaracja prywatności sklepów

Stan: 2026-08-08. Deklarację trzeba porównać z raportem finalnego podpisanego
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
| Google ML Kit | Zaszyfrowane metryki techniczne zbierane przez SDK po użyciu skanera/OCR |
| Kontakty | Pojedynczy wynik systemowego selektora |
| Powiadomienia | Lokalne przypomnienia |
| Systemowy backup | Android: wykluczony; iOS: prywatny katalog danych wyłączony z iCloud Backup |

## Odpowiedzi do formularza Google Play Data safety

Odpowiedzi dotyczą wersji 1.0.0 bez reklam, konta, backendu, Firebase Analytics
i Crashlytics. W Play Console wybierz:

- Does your app collect or share any of the required user data types: **Yes**.
- Is all of the user data collected by your app encrypted in transit: **Yes**.
- Do you provide a way for users to request that their collected off-device data
  is deleted: **No**. Wydawca nie ma zdalnego zbioru, a techniczne metryki ML
  Kit są obsługiwane przez Google. Lokalne dane użytkownik usuwa sam w aplikacji.
- Does the app create accounts: **No**. Internetowe usuwanie konta nie ma
  zastosowania.
- Data shared with other companies or organizations: **No**, zgodnie z
  aktualnym ujawnieniem ML Kit. Eksport uruchamiany przez użytkownika mieści się
  w wyjątku działania zainicjowanego przez użytkownika.

### Kategorie danych ML Kit

| Google Play data type | Handling |
| --- | --- |
| App activity > App interactions | Collected: Yes; Shared: No; Ephemeral: No; Required: No; Purpose: Analytics; Encrypted in transit: Yes |
| App info and performance > Diagnostics | Collected: Yes; Shared: No; Ephemeral: No; Required: No; Purpose: Analytics; Encrypted in transit: Yes |
| Device or other IDs > Device or other IDs | Collected: Yes; Shared: No; Ephemeral: No; Required: No; Purpose: Analytics; Encrypted in transit: Yes |

`Required: No` oznacza, że skaner/OCR jest funkcją opcjonalną i użytkownik może
prowadzić projekt bez jej uruchamiania. Po użyciu tej funkcji ML Kit nie oferuje
w BudowaPRO osobnego wyłączenia technicznych metryk. Jeśli finalny raport SDK
wykaże inicjalizację lub transmisję przed użyciem skanera, pole `Required` trzeba
zmienić na `Yes` przed wysłaniem formularza.

Nie zaznaczaj: zdjęć, plików i dokumentów, kontaktów, danych finansowych,
lokalizacji, danych osobowych, crash logs ani wiadomości. Te treści są
przetwarzane lokalnie albo przekazywane dopiero w ramach świadomego działania
eksportu. Obraz, tekst wejściowy i wynik OCR nie są wysyłane do Google.

Adresy do formularza:

- Privacy Policy URL: `https://budowaproapp.pl/privacy/`.
- Website/Support URL: `https://budowaproapp.pl/support/`.
- Publiczna instrukcja usuwania: `https://budowaproapp.pl/data-deletion/`.

Odpowiedzi muszą obejmować sumę praktyk wszystkich wersji aktywnych na
ścieżkach Google Play. Po wygenerowaniu finalnego AAB trzeba porównać jego
zależności i manifest z tym arkuszem; nie zmienia to powyższych odpowiedzi,
jeżeli zestaw SDK i funkcji jest identyczny.

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
- https://support.google.com/googleplay/android-developer/answer/10787469
- https://support.google.com/googleplay/android-developer/answer/10144311
- https://support.google.com/googleplay/android-developer/answer/13327111

## Kontrola przed zatwierdzeniem formularzy

1. Zbudować podpisany artefakt z finalnym SHA i finalnymi wersjami zależności.
2. Porównać Android merged manifest i iOS privacy report z tym arkuszem.
3. Sprawdzić aktualne ujawnienia Google ML Kit.
4. Potwierdzić identyczne praktyki w aplikacji, polityce online i listingach.
5. Zapisać datę, SHA commit i osobę zatwierdzającą w protokole wydania.
6. Powtórzyć audyt przed dodaniem reklam, konta, synchronizacji, płatności,
   analityki, raportowania awarii lub nowego SDK sieciowego.
