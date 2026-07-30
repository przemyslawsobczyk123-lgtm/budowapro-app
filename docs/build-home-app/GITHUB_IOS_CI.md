# GitHub Actions dla Androida i iOS

## Co jest przygotowane

Workflow `.github/workflows/mobile-ci.yml` uruchamia się po pushu do `main`,
przy pull requestach oraz ręcznie z zakładki Actions. Wykonuje:

1. `flutter analyze` i wszystkie testy;
2. debug APK Androida jako artefakt;
3. kompilację iOS na macOS runnerze GitHub Actions bez podpisu jako artefakt.

Kompilacja bez podpisu sprawdza, czy kod Swift, pluginy i projekt Xcode budują
się poprawnie. Nie tworzy jeszcze aplikacji możliwej do zainstalowania na
Twoim iPhonie ani wysłania do TestFlight.

## Podpięcie repozytorium

Adres e-mail nie wystarcza do podłączenia repozytorium. Z lokalnego katalogu
projektu trzeba dodać adres repozytorium i wykonać push, używając logowania
GitHub lub tokenu przez menedżer poświadczeń:

```bash
git remote add origin https://github.com/<konto>/<repozytorium>.git
git push -u origin main
```

Przed push sprawdź, czy do repozytorium nie trafiają pliki z kluczami,
certyfikatami ani hasłami. Foldery `build/` i `.dart_tool/` są lokalnymi
artefaktami i nie są potrzebne w GitHub Actions.

## TestFlight i App Store

Do podpisanego wydania potrzebne są:

- Apple Developer Program;
- zarejestrowany Bundle ID `pl.budowapro`;
- certyfikat dystrybucyjny i provisioning profile albo podpisywanie przez
  App Store Connect API;
- sekrety GitHub Actions przechowujące dane podpisu.

Certyfikatów i kluczy nie wpisuj do YAML ani nie wysyłaj przez czat. GitHub
opisuje instalowanie certyfikatu i profilu na macOS runnerze w dokumentacji
[sign Xcode applications](https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications).

Po skonfigurowaniu podpisu można dodać osobny workflow release uruchamiany
wyłącznie ręcznie, który wykona `flutter build ipa --release` i opublikuje
artefakt do TestFlight. Nie uruchamiamy automatycznej publikacji bez Twojej
konfiguracji Apple, aby build nie wysyłał aplikacji przypadkowo.
