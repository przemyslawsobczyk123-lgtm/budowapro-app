# BudowaPRO 1.0 - raport kandydata do wydania

Stan: 2026-08-01.

## Werdykt

Kod i materiały repozytorium są technicznym kandydatem R1. Wszystkie prace,
które można było wykonać lokalnie bez podszywania się pod właściciela kont
sklepowych, zostały zamknięte. Aplikacja nie jest jeszcze publicznie wydana:
podpisy produkcyjne, formularze konsol, beta i decyzja rollout wymagają kont,
sekretów albo zgody właściciela.

## Dowody techniczne

| Kontrola                             | Wynik                                                                  |
| ------------------------------------ | ---------------------------------------------------------------------- |
| Wersja                               | `1.0.0+1`                                                              |
| `flutter analyze --no-pub`           | bez uwag                                                               |
| `flutter test --concurrency=1`       | 560/560 zaliczonych                                                    |
| `flutter build apk --debug --no-pub` | zaliczony                                                              |
| Android integration smoke            | zaliczony na emulatorze API 34                                         |
| GitHub mobile CI                     | zaliczone dla commita `545377b`: testy, APK, iOS 26, Android API 28/36 |
| Scenariusz smoke                     | świeża baza → projekt → koszt materiału → Budżet                       |
| Render stron prawnych                | Chromium desktop i mobilne 390 px                                      |
| Publiczne strony HTTPS               | opublikowane przez GitHub Pages, wszystkie adresy zwracają HTTP 200    |
| Google Play icon                     | 512 x 512                                                              |
| Google Play feature graphic          | 1024 x 500                                                             |
| Walidacyjny AAB                      | 89 798 971 B, podpis/manifest/16 KB zaliczone                          |

Walidacyjny AAB ma SHA-256
`8ec731de02fffc402171b938282b44416d38b56586c8593f14738015c3ec7ba4`.
Powstał z jednorazowym kluczem, testowymi URL-ami i `sourceWasDirty=true`, więc
jest dowodem pipeline'u, a nie plikiem do przesłania do Google Play.

Test urządzeniowy wykrył i zamknął trzy błędy, których same widget testy nie
ujawniły:

1. natywne SQLite odrzucało `PRAGMA secure_delete` wykonane niewłaściwym API;
2. dolny przycisk zapisu kosztu mógł znaleźć się pod systemową nawigacją;
3. opóźnione odświeżenie dashboardu próbowało zapisać stan po jego zamknięciu.

## Automatyzacja po wysłaniu do GitHub

- `mobile-ci.yml` uruchamia analizę, testy, debug APK, smoke Android API 28/36
  oraz unsigned iOS compile na macOS 26 z kontrolą Xcode/iOS SDK 26; cały
  workflow przeszedł dla commita `545377b`;
- `ios-testflight.yml` ma fail-closed walidację sekretów, podpisu, profilu i
  narzędzi Xcode 26 przed archiwizacją i uploadem;
- `legal-pages.yml` publikuje `site/` przez GitHub Pages;
- Android release helper nadal blokuje produkcyjny AAB bez prawdziwej
  tożsamości, URL-i i docelowego certyfikatu upload.

## Materiały gotowe

- publiczna polityka:
  `https://przemyslawsobczyk123-lgtm.github.io/budowapro-app/privacy/`;
- publiczne warunki:
  `https://przemyslawsobczyk123-lgtm.github.io/budowapro-app/terms/`;
- publiczne wsparcie:
  `https://przemyslawsobczyk123-lgtm.github.io/budowapro-app/support/`;
- listing Google Play: `store/google-play/listing-pl.md`;
- listing App Store: `store/app-store/listing-pl.md`;
- Data safety i App Privacy: `store/privacy/store-declarations.md`;
- checklista i kadry zrzutów: `store/RELEASE_ASSETS_CHECKLIST.md`;
- grafika promocyjna: `store/google-play/feature-graphic-1024x500.png`.

## Pozostałe blokady właściciela

Jedynym źródłem prawdy jest `OWNER_RELEASE_ACTIONS.md`. Najważniejsze blokady
to potwierdzenie danych prawnych wydawcy, konfiguracja kluczy podpisu, testy na
fizycznym Androidzie i iPhonie, finalne zrzuty z builda release, wypełnienie
formularzy sklepów oraz uruchomienie bety i rollout.

## Kontrolowany dług po R1

Flutter ostrzega, że część pluginów nadal stosuje klasyczny Kotlin Gradle
Plugin. Obecny build przechodzi. Przy najbliższym planowanym uaktualnieniu
Fluttera trzeba ponownie sprawdzić wersje pluginów i migrację Built-in Kotlin;
nie należy wykonywać zbiorowej aktualizacji tuż przed pierwszym wydaniem.
