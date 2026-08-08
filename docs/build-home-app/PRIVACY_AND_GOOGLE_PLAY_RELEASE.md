# BudowaPRO - prywatnosc i wydanie Google Play

Stan audytu kodu: 2026-08-08.

Dokument opisuje wdrozone zabezpieczenia oraz czynnosci nalezace do wydawcy.
Nie zastepuje indywidualnej opinii prawnej ani konfiguracji Play Console.

## 1. Stan wdrozenia

- `Wiecej -> Prywatnosc i prawo` otwiera dostepne offline centrum prawne.
- Przy pierwszym uruchomieniu aplikacja udostepnia regulamin i polityke przed
  wlaczeniem funkcji projektu. Aktualna wersja regulaminu musi zostac jawnie
  potwierdzona; znacznik i czas pozostaja w lokalnej bazie urzadzenia.
- Polityka prywatnosci, warunki uzytkowania, licencje i ustawienia prywatnosci
  sa dostepne bez konta i bez opuszczania aplikacji.
- Publiczny regulamin zawiera rodzaje i zakres uslug, wymagania techniczne,
  zakaz tresci bezprawnych, zawarcie i zakonczenie korzystania oraz tryb
  reklamacyjny. Polityka opisuje podstawy prawne korespondencji, odbiorcow,
  transfery poza EOG, retencje i komplet praw osoby, ktorej dane dotycza.
- Dokumenty opisuja dane lokalne, retencje, usuwanie, eksport, OCR, konkretne
  metryki Google ML Kit, logi hostingu GitHub Pages, role dostawcow, prawa
  uzytkownika i granice porad budowlanych.
- Aplikacja nie ma reklam, konta, backendu, synchronizacji, Firebase Analytics
  ani Firebase Crashlytics.
- Automatyczna kopia Androida jest wylaczona. Reguly Android 11 i 12+
  wykluczaja prywatne pliki z backupu i transferu urzadzenie-urzadzenie.
- Ustawienia prywatnosci zawieraja jawna akcje usuniecia wszystkich danych.
  Wymaga ona wpisania frazy potwierdzajacej, usuwa baze, pliki projektow i
  lokalne cache, a po operacji odswieza aplikacje do stanu bez projektu.
- Prywatna baza uzywa `secure_delete`; katalogi tymczasowe OCR, eksportu,
  udostepniania, kopii i odtwarzania sa szybko odpinane przy starcie, a ich
  rekursywne kasowanie odbywa sie po pokazaniu pierwszej klatki aplikacji.
- Obrazy i PDF-y kierowane do OCR lub generatora podgladu przechodza kontrole
  typu, sygnatury, rozmiaru i limitu pikseli przed dekodowaniem. Oryginal
  ogolnego zalacznika jest sprawdzany jako zwykly plik, ograniczany rozmiarem
  i kopiowany z kontrola SHA-256, ale moze pozostac zapisany bez podgladu.
  Kopie ZIP sa sprawdzane przed atomowym odtworzeniem, a starszy obslugiwany
  schemat jest migrowany w pliku roboczym.
- Android blokuje cleartext HTTP, szeroki backup i niepotrzebne uprawnienia.
  `compileSdk` i `targetSdk` sa ustawione na API 36.
- Release uzywa R8, kurczenia zasobow, obfuskacji Dart i symboli debugowania.
  Reguly R8 dotycza wylacznie opcjonalnych modeli pisma ML Kit, ktorych
  BudowaPRO nie pakuje.

## 2. Dane wydawcy

Przed wydaniem trzeba podac prawdziwe wartosci:

```text
BUDOWAPRO_PUBLISHER_NAME
BUDOWAPRO_PRIVACY_CONTACT_EMAIL
BUDOWAPRO_PRIVACY_POLICY_URL
BUDOWAPRO_SUPPORT_URL
```

Aktualne wartosci BudowaPRO:

```text
BUDOWAPRO_PUBLISHER_NAME=Przemysław Sobczyk
BUDOWAPRO_PRIVACY_CONTACT_EMAIL=kontakt@budowaproapp.pl
BUDOWAPRO_PRIVACY_POLICY_URL=https://budowaproapp.pl/privacy/
BUDOWAPRO_SUPPORT_URL=https://budowaproapp.pl/support/
```

Publiczny regulamin ma staly produkcyjny adres
`https://budowaproapp.pl/terms/`. NIP i adres uslugodawcy sa stalymi danymi
prawnymi w konfiguracji domenowej. Wszystkie trzy elementy sa objete testem
kompletnosci konfiguracji release.

Zweryfikowane dane prawne wydawcy to `PRZEMYSŁAW SOBCZYK`, NIP
`6443558164`, adres `Przygraniczna 40, 41-203 Sosnowiec, Polska`. Zwykly ekran
kontaktowy aplikacji nie pokazuje nazwiska, NIP-u ani adresu. Dane te wystepuja
tylko w polityce prywatnosci i regulaminie, gdzie identyfikuja administratora i
uslugodawce. Publiczna marka aplikacji i nazwa dewelopera w sklepie to
`BudowaPRO`, a publiczny kontakt do aplikacji to wylacznie
`kontakt@budowaproapp.pl`.

Dane prawne zostaly sprawdzone 08.08.2026 w oficjalnym Wykazie podatnikow VAT
Ministerstwa Finansow dla NIP `6443558164`. Przed publikacja trzeba je jeszcze
porownac z dokumentami uzytymi do weryfikacji konta Google Play.

Strona nie laduje skryptow, formularzy, reklam ani wlasnej analityki. Statyczny
HTML ma restrykcyjna polityke CSP i `no-referrer`. Dodanie analityki, osadzonego
filmu, formularza lub technologii niekoniecznej wymaga osobnej oceny cookies i
zgod oraz aktualizacji tej dokumentacji.

Adres polityki musi:

- uzywac HTTPS;
- zwracac publiczny dokument HTML bez logowania;
- nie prowadzic do PDF;
- odpowiadac tresci polityki dostepnej w aplikacji.

`BUDOWAPRO_SUPPORT_URL` musi wskazywac publiczna strone HTTPS wsparcia bez
logowania. Jest wyswietlany w centrum prawnym aplikacji i sluzy jako dedykowany
adres pomocy w metadanych sklepu. Nie uzywaj adresu lokalnego ani tymczasowej
strony testowej.

Google Play wymaga publicznego URL nawet wtedy, gdy aplikacja przechowuje dane
projektu tylko lokalnie. Sama zakladka w APK nie wypelnia tego wymagania.
Skrypt release sprawdza skladnie, odpowiedz HTTPS i typ `text/html`, ale nie
moze potwierdzic tozsamosci wydawcy ani prawdziwosci wpisanych danych.

## 3. Klucz upload i podpis

Prawdziwego klucza ani hasel nie wolno dodawac do Git. Repozytorium ignoruje
`android/key.properties`, `*.jks` i `*.keystore`. Szablon konfiguracji znajduje
sie w `android/key.properties.example`.

Zalecany wariant CI korzysta ze zmiennych:

```text
BUDOWAPRO_UPLOAD_STORE_FILE
BUDOWAPRO_UPLOAD_STORE_PASSWORD
BUDOWAPRO_UPLOAD_KEY_ALIAS
BUDOWAPRO_UPLOAD_KEY_PASSWORD
BUDOWAPRO_UPLOAD_CERT_SHA256
```

Klucz upload nalezy utworzyc raz, przechowywac w menedzerze sekretow i wykonac
jego bezpieczna kopie. Odcisk SHA-256 nalezy odczytac przez `keytool -list -v`
i zapisac jako `BUDOWAPRO_UPLOAD_CERT_SHA256`. W Play Console trzeba wlaczyc
Play App Signing.

## 4. Kontrolowany build AAB

Po ustawieniu wszystkich dziewieciu zmiennych uruchom:

```powershell
dart run tool/release/build_android_release.dart
```

Domyslnie proces odrzuca brudne drzewo Git. `--allow-dirty` jest przeznaczone
wylacznie do lokalnej walidacji zmian, nie do artefaktu publikacyjnego.
`--validation` jawnie dopuszcza zarezerwowane dane testowe i oznacza wynik
jako testowy. Artefaktu z `validationOnly: true` nie wolno wysylac do Play.

Proces wykonuje:

1. sprawdzenie klucza, oczekiwanego odcisku certyfikatu upload, danych wydawcy,
   publicznego HTML polityki i publicznego URL wsparcia;
2. `flutter pub get`, generowanie lokalizacji, format, analize i wszystkie testy;
3. podpisany AAB release z obfuskacja i osobnymi symbolami Dart;
4. weryfikacje podpisu przez `jarsigner` i porownanie certyfikatu AAB;
5. kontrole `PAGE_ALIGNMENT_16K`, segmentow `LOAD` bibliotek 64-bit,
   uniwersalnego APK i `zipalign -P 16` przez przypiety `bundletool 1.18.3`;
6. odczyt scalonego manifestu i porownanie uprawnien ze scisla allowlista;
7. archiwizacje AAB, mapy R8, symboli Dart/native i metadanych z SHA-256.

Wynik trafia do:

```text
build/releases/<wersja>/<czas-UTC>/
```

Plik `release-metadata.json` jest dowodem wykonanych kontroli. Symbole i mapy
musza byc przechowywane razem z konkretnym AAB, aby mozna bylo analizowac bledy
tej wersji.

## 5. Data safety

Deklaracje trzeba potwierdzic dla dokladnych wersji SDK w wysylanym AAB.

### Dane projektu

- Projekty, koszty, kontakty, dokumenty, zdjecia, skany i tekst OCR sa lokalne.
- Wydawca nie ma backendu i nie otrzymuje tych tresci.
- Eksport jest transferem uruchomionym przez uzytkownika do wybranego odbiorcy.
- Reczna kopia ZIP nie jest szyfrowana i musi byc przechowywana w zaufanym
  miejscu.

### Google ML Kit

Formularz powinien uwzgledniac ujawnione przez Google techniczne dane SDK:

- `App activity > App interactions`: collected, not shared, not ephemeral,
  optional, purpose `Analytics`;
- `App info and performance > Diagnostics`: collected, not shared, not
  ephemeral, optional, purpose `Analytics`;
- `Device or other IDs > Device or other IDs`: collected, not shared, not
  ephemeral, optional, purpose `Analytics`;
- wszystkie trzy kategorie sa szyfrowane w tranzycie przez HTTPS.

`optional` wynika z tego, ze skaner/OCR nie jest wymagany do prowadzenia
projektu. Finalny AAB trzeba sprawdzic przed wyslaniem. Jezeli SDK transmituje
metryki przed swiadomym uzyciem skanera, pole trzeba ustawic jako required.

Nie nalezy deklarowac, ze aplikacja nie zbiera absolutnie zadnych danych,
dopoki w AAB pozostaje ML Kit. Nie nalezy tez deklarowac wysylania obrazu,
tekstu dokumentu ani wyniku OCR do Google, poniewaz te tresci sa przetwarzane
na urzadzeniu.

## 6. Uprawnienia

BudowaPRO deklaruje bezposrednio:

- `POST_NOTIFICATIONS` dla lokalnych przypomnien;
- `RECEIVE_BOOT_COMPLETED` dla ich odtworzenia po restarcie telefonu.

Scalony AAB zawiera tez uprawnienia bibliotek: `INTERNET`,
`ACCESS_NETWORK_STATE` i `VIBRATE`. Manifest nie zawiera szerokiego odczytu
kontaktow, pamieci, zdjec, mikrofonu, lokalizacji ani uprawnienia `CAMERA`.
Pojedynczy kontakt i pliki wybiera systemowy selektor.

Skrypt release wymaga dokladnie tego zestawu pieciu uprawnien Androida oraz
technicznego, lokalnego uprawnienia pakietu
`pl.budowapro.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. Aktualizacja SDK,
ktora doda lub usunie wpis `<uses-permission>`, zatrzyma wydanie do czasu
jawnego audytu i aktualizacji allowlisty.

## 7. Play Console przed publikacja

1. Potwierdz prawna nazwe `PRZEMYSŁAW SOBCZYK`, NIP `6443558164`, adres i
   pozostale dane konta dewelopera zgodnie z dokumentami firmy.
2. Wlacz Play App Signing i zarejestruj certyfikat klucza upload.
3. Ustaw publiczna nazwe dewelopera `BudowaPRO`, e-mail
   `kontakt@budowaproapp.pl`, witryne `https://budowaproapp.pl`, publiczny URL
   polityki i publiczny URL wsparcia.
4. Wypelnij Data safety dla dokladnego AAB i wersji ML Kit.
5. Ustaw deklaracje reklam na `Nie`.
6. Wypelnij grupe docelowa, klasyfikacje tresci i dostep dla recenzenta.
7. Dodaj opis, zrzuty ekranu i grafike funkcji. Gotowa ikona 512 px znajduje
   sie w `assets/store/google-play-icon-512.png`.
8. Wyslij AAB na tor wewnetrzny, wykonaj test instalacji i migracji danych.
9. Uruchom raport przedpremierowy na roznych wersjach Androida.
10. Przejdz wymagany test zamkniety, jesli dotyczy typu konta.
11. Opublikuj etapowo i zachowaj AAB, `release-metadata.json` oraz symbole.

Pola prawnej nazwy i adresu weryfikuje Google na podstawie profilu platnosci
lub danych organizacji. Nie wolno w nich wpisywac marki zamiast nazwy prawnej.
Kod aplikacji nie steruje tym, ktore zweryfikowane dane konta Google Play
pokazuje publicznie. Konto organizacji wymaga numeru D-U-N-S; sam NIP go nie
zastepuje.

Brak konta uzytkownika oznacza, ze URL usuwania konta nie jest wymagany.
Lokalne dane mozna usunac w aplikacji, ustawieniach Androida lub przez
odinstalowanie. Reczne kopie i eksporty trzeba usunac osobno.

## 8. Znane granice

- Prawdziwe dane wydawcy, publiczny URL, klucz upload i Play Console pozostaja
  czynnosciami wlasciciela produktu.
- Kopie ZIP sa swiadomie nieszyfrowane; aplikacja pokazuje to przed eksportem.
- Android moze udostepnic odbiorcy tymczasowa kopie ZIP/CSV. BudowaPRO planuje
  jej usuniecie po zakonczeniu wyboru aplikacji i ponawia sprzatanie przy
  kolejnym starcie; plik musi istniec wystarczajaco dlugo, aby odbiorca mogl
  go odczytac.
- Wtyczki Fluttera nadal emituja przyszlosciowe ostrzezenie o migracji do
  Built-in Kotlin. Biezacy release dziala, ale trzeba sprawdzic je przy kazdej
  aktualizacji Fluttera.
- Zaleznosci natywne powinny byc aktualizowane pojedynczo, z ponownym testem
  skanera, powiadomien, selektorow i podpisanego AAB.

## 9. Oficjalne zrodla

- Flutter Android release:
  https://docs.flutter.dev/deployment/android
- Flutter obfuscation:
  https://docs.flutter.dev/deployment/obfuscate
- Android app signing:
  https://developer.android.com/studio/publish/app-signing
- Android App Bundle:
  https://developer.android.com/studio/publish/upload-bundle
- Native debug symbols:
  https://developer.android.com/build/include-native-symbols
- Android 16 KB page sizes:
  https://developer.android.com/guide/practices/page-sizes
- Google Play User Data:
  https://support.google.com/googleplay/android-developer/answer/10144311
- Google Play developer identity verification:
  https://support.google.com/googleplay/android-developer/answer/10841920
- Google Play account information and public developer data:
  https://support.google.com/googleplay/android-developer/answer/13634081
- Google Play organization account and D-U-N-S:
  https://support.google.com/android-developer-console/answer/16641046
- Google Play Data safety:
  https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play pre-launch report:
  https://support.google.com/googleplay/android-developer/answer/9842757
- Google ML Kit data disclosure:
  https://developers.google.com/ml-kit/android-data-disclosure
- Android Auto Backup:
  https://developer.android.com/identity/data/autobackup
- RODO:
  https://eur-lex.europa.eu/eli/reg/2016/679/oj
- UODO:
  https://uodo.gov.pl/pl/138/155
- Wykaz podatnikow VAT Ministerstwa Finansow:
  https://wl-api.mf.gov.pl/api/search/nip/6443558164?date=2026-08-08
