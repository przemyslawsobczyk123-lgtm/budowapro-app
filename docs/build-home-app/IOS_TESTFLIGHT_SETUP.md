# BudowaPRO - TestFlight setup

Repozytorium ma osobny workflow `.github/workflows/ios-testflight.yml`.
Workflow jest reczny i nie uruchamia sie po zwyklym pushu. Po poprawnej
konfiguracji buduje podpisany plik IPA, zapisuje go jako artefakt i wysyla do
TestFlight.

## Co musi zrobic wlasciciel konta Apple

1. Dolacz do Apple Developer Program.
2. W Apple Developer zarejestruj identyfikator aplikacji `pl.budowapro`.
3. Utworz certyfikat `Apple Distribution` i profil `App Store` dla tego ID.
4. W App Store Connect utworz rekord aplikacji z Bundle ID `pl.budowapro`.
5. Utworz klucz App Store Connect API z rola co najmniej `App Manager`.

Konto Apple, umowy i rekord aplikacji musza byc skonfigurowane przez
wlasciciela konta. Nie przekazuj klucza `.p8`, certyfikatu ani hasla przez
czat.

## GitHub Secrets

W repozytorium wejdz w `Settings -> Secrets and variables -> Actions` i dodaj
nastepujace sekrety:

| Nazwa | Zawartosc |
| --- | --- |
| `APPLE_TEAM_ID` | 10-znakowy Team ID z Apple Developer |
| `APPSTORE_ISSUER_ID` | Issuer ID klucza App Store Connect API |
| `APPSTORE_API_KEY_ID` | Key ID klucza App Store Connect API |
| `APPSTORE_API_PRIVATE_KEY` | Pelna zawartosc pliku `AuthKey_<KEY_ID>.p8` |
| `IOS_CERTIFICATE_P12_BASE64` | Certyfikat `Apple Distribution` jako Base64 |
| `IOS_CERTIFICATE_PASSWORD` | Haslo eksportu pliku `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Profil `App Store` jako Base64 |

Do konwersji plikow na Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('.\\ios_distribution.p12')) | Set-Clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes('.\\BudowaPRO.mobileprovision')) | Set-Clipboard
```

Prywatny klucz `.p8` wklej jako zwykly tekst z zachowaniem naglowka i stopki.
Nie umieszczaj tych danych w repozytorium, workflow ani pliku `.env`.

## Uruchomienie

1. Otworz zakladke `Actions` w repozytorium.
2. Wybierz `BudowaPRO iOS TestFlight`.
3. Kliknij `Run workflow`.
4. Puste `build_number` uzyje numeru uruchomienia GitHub Actions. Przy kolejnym
   wydaniu numer musi byc wiekszy niz numer ostatniego builda w App Store
   Connect.
5. Po zakonczeniu otworz App Store Connect -> aplikacja -> `TestFlight`.

Na iPhonie zainstaluj aplikacje TestFlight i zaakceptuj zaproszenie testera.
Build jest podpisany i dystrybuowany przez Apple; artefakt pobrany z GitHub
Actions jest kopia techniczna, nie instalatorem do bezposredniego otwarcia na
iPhonie.

## Bezpieczenstwo

Workflow ma `workflow_dispatch`, waliduje komplet sekretow, sprawdza Bundle ID
profilu oraz odrzuca profil deweloperski (`get-task-allow=true`). Nie wykonuje
uploadu przy pushu do `main`.

## Zrodla

- Apple TestFlight: https://developer.apple.com/testflight/
- Apple TestFlight overview: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/
- Apple App Store Connect workflow: https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-workflow
- GitHub: instalowanie certyfikatu Apple w runnerze macOS: https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications
