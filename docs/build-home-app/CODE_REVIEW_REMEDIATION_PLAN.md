# BudowaPRO - plan napraw po niezaleznym code review

## Cel

Plan obejmuje tylko problemy potwierdzone ponowna analiza kodu. Nie obejmuje
falszywych alarmow z `CLAUDE_CODE_REVIEW.md`, w szczegolnosci recznej
inicjalizacji polskich danych dat, dopisywania zbednych zapytan Android
`<queries>` ani duplikowania deklaracji API prywatnosci dostarczanych przez
Flutter i wtyczki iOS.

## Faza 1 - OCR i bezpieczne pliki

### Task R1.1 - faktury wielostronicowe

- [x] Skaner dokumentow przyjmuje do 20 stron i zachowuje wielostronicowy PDF.
- [x] Importowany PDF jest renderowany strona po stronie z jawnym limitem.
- [x] OCR laczy tekst stron w kolejnosci dokumentu i zwalnia kazdy obraz.
- [x] Test potwierdza odczyt co najmniej dwoch stron bez pozostawiania plikow
      tymczasowych.

### Task R1.2 - odporniejszy parser i reczna sciezka

- [x] Kwoty obsluguja zwykla spacje oraz NBSP jako separator tysiecy.
- [x] Rabat lub storno nie jest po cichu zamieniane na dodatnia pozycje.
- [x] Pusty wynik OCR pozwala przejsc do recznej edycji z zachowanym zalacznikiem.
- [x] Capture picker ogranicza formaty obrazu do formatow obslugiwanych przez
      preflight i podaje kontrolowany blad.

### Task R1.3 - pamiec obrazow

- [x] Duzy obraz jest skalowany przed przekazaniem do ML Kit.
- [x] Listy i male podglady uzywaja docelowego rozmiaru dekodowania.
- [x] Pelnoekranowy podglad zachowuje rozdzielczosc potrzebna do powiekszenia.

## Faza 2 - odpornosc stanu

### Task R2.1 - kontrolery Riverpod

- [x] Kazda operacja asynchroniczna sprawdza `ref.mounted` po `await`, zanim
      odczyta lub zapisze `state`.
- [x] Sekcje `catch` i `finally` nie dotykaja stanu po uniewaznieniu providera.
- [x] Test z opoznionym repozytorium potwierdza brak wyjatku po invalidacji.

## Faza 3 - integralnosc i prywatnosc danych

### Task R3.1 - atomowy reset danych

- [x] Reset zapisuje trwaly znacznik rozpoczecia operacji.
- [x] Restart aplikacji konczy przerwany reset bazy, plikow i cache.
- [x] Czesc danych nie moze ponownie stac sie widoczna po niepelnej operacji.

### Task R3.2 - relacje materialow

- [x] Migracja dodaje brakujace klucze obce do opcjonalnych powiazan.
- [x] Polityki `SET NULL`, `RESTRICT` i `CASCADE` odpowiadaja wlascicielom danych.
- [x] Usuniecie materialu z dostawami lub zwrotami wymaga jawnej decyzji zamiast
      cichego skasowania historii.
- [x] Migracja z v18 zachowuje istniejace rekordy.

### Task R3.3 - kopia systemowa iOS

- [x] Baza, dokumenty i zdjecia w Application Support maja ustawione
      `NSURLIsExcludedFromBackupKey`.
- [x] Blad ustawienia atrybutu nie powoduje ujawnienia danych bez komunikatu ani
      cichego uruchomienia aplikacji w nieznanym stanie.

## Faza 4 - UX i dostepnosc

### Task R4.1 - klawiatura i dolna nawigacja

- [x] Przycisk zapisu edytora etapu pozostaje widoczny przy otwartej klawiaturze.
- [x] Piec glownych zakladek nie powoduje overflow przy szerokosci 320 dp i
      skali tekstu 200%.
- [x] Zachowanie przycisku Wstecz miedzy glownymi zakladkami pozostaje swiadoma
      decyzja produktowa i nie jest zmieniane bez osobnej akceptacji.

### Task R4.2 - teksty gotowe do lokalizacji

- [x] Tytul udostepniania CSV trafia do etykiet przekazywanych z prezentacji.
- [x] Opisy rewizji zrodel pozostaja czescia polskiego pakietu merytorycznego;
      nie sa na sile przenoszone do ogolnego ARB przed wdrozeniem pakietow krajow.

## Bramka koncowa

- [x] `dart format --output=none --set-exit-if-changed lib test integration_test tool`
- [x] `flutter analyze`
- [x] `flutter test` - 587 testow.
- [x] `flutter build apk --debug`
- [ ] Test na emulatorze Android API 28 i 36.
- [ ] Audyt iOS oraz fizyczny iPhone pozostaja bramka wlasciciela/macOS.

## Dzialania wlasciciela poza kodem

- Produkcyjny Android upload keystore i Play App Signing.
- Dane wydawcy, publiczny e-mail, polityka prywatnosci i URL wsparcia.
- Apple Developer, App ID, certyfikat dystrybucyjny i profil App Store.
- Testy na fizycznym Androidzie i iPhonie.
- Potwierdzenie wymogu zamknietego testu Google Play dla danego konta.
