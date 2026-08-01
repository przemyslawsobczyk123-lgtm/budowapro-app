# Kompatybilnosc Android i iOS

## Stan wdrozenia

BudowaPRO pozostaje jedna aplikacja Flutter z lokalnym storage. Dodany zostal
target iOS obok istniejacego Androida:

- Android: `pl.budowapro`, minimum API 28 / Android 9.
- iOS: `pl.budowapro`, minimum iOS 15.5.
- Nazwa aplikacji: BudowaPRO.
- Ikona: `assets/branding/budowapro_launcher_icon.png` przeskalowana do
  katalogu `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
- Manifest prywatności iOS: `ios/Runner/PrivacyInfo.xcprivacy`, bez śledzenia i
  bez deklarowanych danych zbieranych poza urządzeniem.
- Dane, SQLite i zalaczniki pozostaja lokalne; nie dodano konta ani backendu.

## Funkcje platformowe

| Funkcja | Android | iOS |
| --- | --- | --- |
| Skan paragonu/faktury | Google ML Kit Document Scanner | Apple VisionKit `VNDocumentCameraViewController` |
| OCR | Google ML Kit Text Recognition | Google ML Kit Text Recognition |
| Import pliku | systemowy file picker | systemowy file picker |
| Kontakt wykonawcy | Android Contacts Picker przez Kotlin channel | `CNContactPickerViewController` |
| Wolne miejsce | Android `StatFs` | `FileManager.attributesOfFileSystem` |
| Przypomnienia | lokalny kanal Android | lokalne powiadomienia Darwin/iOS |
| Budzet, etapy, dokumenty, raporty | wspolny kod Flutter | wspolny kod Flutter |

Wersja `google_mlkit_document_scanner 0.5.0` nie udostepnia dzialajacego
skanera iOS, mimo obecnosci deklaracji platformy w paczce. Dlatego na iOS
przycisk skanowania korzysta z VisionKit, a wynik trafia do tego samego
lokalnego OCR i formularza weryfikacji co na Androidzie. Import pliku nadal
jest dostepny jako druga sciezka.

## Uprawnienia

`ios/Runner/Info.plist` zawiera opisy dla aparatu, kontaktow, biblioteki zdjec
i powiadomien. Picker kontaktu pokazuje tylko systemowy wybor i nie wymaga
szerokiego importu ksiazki adresowej. Android nie ma uprawnien
`READ_CONTACTS` ani `WRITE_CONTACTS`.

## Weryfikacja wykonana w repo

```text
flutter analyze                 No issues found
flutter test                    477 tests passed
flutter build apk --debug       Built build/app/outputs/flutter-apk/app-debug.apk
```

## Weryfikacja iOS na Macu

Flutter wymaga macOS i Xcode do kompilacji, uruchomienia symulatora oraz
podpisania aplikacji iOS. Na Macu uruchom:

```bash
flutter doctor -v
flutter pub get
cd ios && pod install && cd ..
flutter run -d ios
flutter build ipa --release
```

Przed TestFlight sprawdz na fizycznym iPhonie:

1. skan paragonu i faktury, anulowanie oraz blad aparatu;
2. OCR i reczna korekta kwoty, VAT i pozycji;
3. wybor kontaktu wykonawcy i anulowanie wyboru;
4. zgode na powiadomienia oraz otwarcie terminu z powiadomienia;
5. import/eksport kopii zapasowej, udostepnianie PDF/CSV i brak dostepu do sieci;
6. zdjecia etapow, dokumenty i odtworzenie danych po restarcie aplikacji;
7. wyglad przy duzym rozmiarze tekstu i orientacji portretowej.

## Wydanie

Konfiguracja podpisu, Bundle ID w Apple Developer, App Store Connect,
uprawnienia zespolu, privacy manifest/review oraz finalne metadane sklepu
pozostaja operacjami wydawniczymi poza kodem. Build iOS musi zostac sprawdzony
na macOS, a kazdy upload do App Store Connect wymaga unikalnego numeru builda.
Workflow TestFlight wymaga dodatkowo sekretow GitHub Actions:
`BUDOWAPRO_PUBLISHER_NAME`, `BUDOWAPRO_PRIVACY_CONTACT_EMAIL`,
`BUDOWAPRO_PRIVACY_POLICY_URL` i `BUDOWAPRO_SUPPORT_URL`, aby IPA mial te same
dane prawne co Android.

## Zrodla

- Flutter: [Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
- Flutter: [Set up iOS development](https://docs.flutter.dev/platform-integration/ios/setup)
- Flutter: [Swift Package Manager in Flutter 3.44](https://docs.flutter.dev/add-to-app/ios/project-setup)
- Apple: [`VNDocumentCameraViewController`](https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller)
- Apple: [privacy manifest i required reason APIs](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- Plugin: [google_mlkit_document_scanner 0.5.0](https://pub.dev/packages/google_mlkit_document_scanner)
