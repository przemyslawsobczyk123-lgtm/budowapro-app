# BudowaPRO - prywatnosc i gotowosc Google Play

Stan audytu: 2026-07-28.

Ten dokument opisuje stan kodu i wymagane czynnosci publikacyjne. Nie zastepuje
indywidualnej opinii prawnej wydawcy.

## 1. Stan wdrozenia w aplikacji

- `Wiecej -> Prywatnosc i prawo` otwiera centrum prawne.
- Polityka prywatnosci, warunki uzytkowania i ustawienia prywatnosci sa dostepne
  bez konta, sieci i opuszczania aplikacji.
- Dokumenty opisuja lokalne dane, retencje, usuwanie, eksport, OCR, Google ML Kit,
  prawa uzytkownika, ograniczenia porad budowlanych i prawa konsumenta.
- Polityka ujawnia, ze tresc obrazu, tekst wejsciowy i wynik OCR sa przetwarzane
  na urzadzeniu, ale ML Kit moze wysylac Google techniczne metryki diagnostyczne
  i wykorzystania.
- Aplikacja nie zawiera reklam, Firebase Analytics, Firebase Crashlytics, konta
  ani wlasnego backendu.
- Automatyczna kopia Androida jest wylaczona. Reguly Android 11 i Android 12+
  wykluczaja prywatne katalogi z kopii chmurowej i transferu urzadzenie-urzadzenie.
- `compileSdk` i `targetSdk` sa ustawione na API 36.
- Zadanie `preReleaseBuild` zalezy od walidacji danych prawnych, wiec build
  release nie moze ominac kontroli przez uzycie innego zadania Gradle.

## 2. Wymagane dane wydawcy

Przed pierwszym buildem release wlasciciel produktu musi podac trzy prawdziwe
wartosci:

```text
BUDOWAPRO_PUBLISHER_NAME
BUDOWAPRO_PRIVACY_CONTACT_EMAIL
BUDOWAPRO_PRIVACY_POLICY_URL
```

Przyklad polecenia:

```powershell
flutter build appbundle --release `
  --dart-define="BUDOWAPRO_PUBLISHER_NAME=PELNA NAZWA WYDAWCY" `
  --dart-define="BUDOWAPRO_PRIVACY_CONTACT_EMAIL=privacy@example.pl" `
  --dart-define="BUDOWAPRO_PRIVACY_POLICY_URL=https://example.pl/budowapro/privacy"
```

Adres polityki musi uzywac HTTPS, byc publicznie dostepny bez logowania i nie
moze prowadzic do PDF. Publiczna kopia musi odpowiadac wersji w aplikacji.

Google Play wymaga publicznego URL polityki nawet wtedy, gdy aplikacja nie
zbiera danych uzytkownika. Sama zakladka w APK nie spelnia pola URL w Play
Console. Kod nie tworzy strony internetowej, zgodnie z decyzja produktowa.

Skladnia adresu jest sprawdzana w Gradle i aplikacji. Dostepnosc, odpowiedz
HTTPS oraz typ HTML trzeba sprawdzic w CI przed publikacja:

```powershell
dart run tool/check_privacy_policy_url.dart `
  "https://example.pl/budowapro/privacy"
```

## 3. Wstepna deklaracja Data safety

Deklaracje trzeba potwierdzic ponownie dla dokladnych wersji SDK w artefakcie
wysylanym do Google Play.

### Dane projektu

- Projekty, koszty, kontakty, dokumenty, zdjecia, skany i tekst OCR sa lokalne.
- Wydawca nie ma backendu i nie otrzymuje tych tresci.
- Eksport do pliku lub innej aplikacji jest transferem zainicjowanym przez
  uzytkownika do wybranego dostawcy.

### Google ML Kit

Wedlug dokumentacji Google dla aktualnych SDK nalezy przeanalizowac w formularzu:

- `Device or other IDs` - identyfikator instalacji, a dla niektorych wariantow
  rowniez identyfikator urzadzenia;
- `App info and performance` - dane urzadzenia i aplikacji, wydajnosc,
  konfiguracja funkcji i kody bledow;
- `App activity` - zdarzenia inicjalizacji, pobrania modelu, wykrycia i
  zwolnienia zasobow;
- cel: diagnostyka i analityka wykorzystania ML Kit;
- szyfrowanie w tranzycie: tak, HTTPS;
- udostepnianie stronom trzecim wedlug deklaracji Google dla tych danych: nie.

Nie deklarowac, ze BudowaPRO nie zbiera absolutnie zadnych danych, dopoki w
artefakcie pozostaje ML Kit i formularz Data safety nie uwzglednia jego metryk.
Nie deklarowac wysylania obrazu, tekstu dokumentu ani wyniku OCR do Google,
poniewaz dokumentacja ML Kit wskazuje przetwarzanie tych tresci na urzadzeniu.

## 4. Uprawnienia i dane wrazliwe

Manifest zrodlowy BudowaPRO deklaruje bezposrednio:

- `POST_NOTIFICATIONS` - lokalne przypomnienia;
- `RECEIVE_BOOT_COMPLETED` - odtworzenie lokalnie zaplanowanych przypomnien po
  ponownym uruchomieniu telefonu.

Scalony artefakt zawiera rowniez uprawnienia dostarczone przez biblioteki:
`INTERNET`, `ACCESS_NETWORK_STATE` i `VIBRATE`. Siec jest wykorzystywana przez
transport technicznych metryk i aktualizacji ML Kit opisany w polityce.
`VIBRATE` obsluguje lokalne powiadomienia.

Scalony manifest nie zawiera szerokiego odczytu kontaktow, pamieci, zdjec,
mikrofonu ani uprawnienia `CAMERA`. Pojedynczy kontakt i pliki sa wybierane
przez systemowe selektory. Skaner jest otwierany dopiero po jawnej akcji.
Przed kazdym wydaniem nalezy ponownie sprawdzic scalony manifest release,
poniewaz aktualizacja SDK moze dodac uprawnienia.

## 5. Play Console przed wyslaniem

1. Zweryfikowac prawna nazwe i dane konta dewelopera.
2. Wpisac publiczny URL polityki prywatnosci.
3. Wypelnic Data safety z uwzglednieniem dokladnych wersji ML Kit.
4. Ustawic deklaracje reklam na `Nie`.
5. Wypelnic grupe docelowa, klasyfikacje tresci i opis funkcji.
6. Podac publiczny e-mail wsparcia zgodny z dokumentami w aplikacji.
7. W sekcji dostepu dla recenzenta wskazac, ze aplikacja nie ma logowania.
8. Zweryfikowac wymagania testu zamknietego zalezne od typu i wieku konta.
9. Skonfigurowac prawdziwy klucz podpisu release poza repozytorium.
10. Zbudowac i przetestowac podpisany AAB na torze wewnetrznym.
11. Uruchomic sieciowy test publicznego URL polityki i potwierdzic odpowiedz HTML.

Brak konta uzytkownika oznacza, ze URL usuwania konta nie jest wymagany. Lokalne
dane usuwa sie w aplikacji, przez wyczyszczenie danych Androida lub odinstalowanie.

## 6. Oficjalne zrodla

- Google Play User Data:
  https://support.google.com/googleplay/android-developer/answer/17105854
- Google Play Data safety:
  https://support.google.com/googleplay/android-developer/answer/10787469
- Google ML Kit Terms and Privacy:
  https://developers.google.com/ml-kit/terms
- Google ML Kit data disclosure:
  https://developers.google.com/ml-kit/android-data-disclosure
- Target API level:
  https://developer.android.com/google/play/requirements/target-sdk
- Android Auto Backup:
  https://developer.android.com/identity/data/autobackup
- RODO:
  https://eur-lex.europa.eu/eli/reg/2016/679/oj
- UODO - skarga:
  https://uodo.gov.pl/pl/138/155
