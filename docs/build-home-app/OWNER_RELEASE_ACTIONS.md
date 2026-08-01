# BudowaPRO - czynnosci wymagajace wlasciciela

Ta lista zawiera tylko kroki, ktorych agent nie moze wykonac uczciwie bez
tozsamosci, zgody, platnego konta albo sekretu nalezacego do wydawcy.

## Google Play

- zalozyc lub wskazac konto Play Console i potwierdzic dane prawne wydawcy;
- zaakceptowac umowy i uzupelnic wymagane informacje konta;
- wlaczyc Play App Signing i bezpiecznie zachowac docelowy klucz upload;
- podac prawdziwa nazwe wydawcy, e-mail prywatnosci, URL polityki i wsparcia;
- zatwierdzic Data safety, grupe docelowa, klasyfikacje tresci i deklaracje
  reklam dla konkretnego AAB;
- zapewnic 12 testerow przez 14 dni, jezeli wymaga tego typ i data konta;
- zatwierdzic rozpoczecie publicznego staged rollout.

## Apple

- dolaczyc do Apple Developer Program;
- zaakceptowac umowy, podatki i dane prawne App Store Connect;
- utworzyc App ID, rekord aplikacji, certyfikat i profil App Store;
- utworzyc oraz bezpiecznie przekazac do GitHub Secrets klucz API, certyfikat i
  profil bez publikowania ich w repozytorium ani czacie;
- zatwierdzic App Privacy, DSA/trader status, rating wieku i dane recenzenta;
- zaprosic testerow TestFlight i zatwierdzic wyslanie do App Review.

## Prawo i marka

- wskazac prawna nazwe wydawcy i monitorowany adres kontaktowy;
- potwierdzic, ze `Przemyslaw Sobczyk` i
  `przemyslawsobczyk123@gmail.com` sa wlasciwymi danymi do publicznej polityki;
- w ustawieniach repozytorium wlaczyc GitHub Pages ze zrodlem `GitHub Actions`;
- sprawdzic bez logowania przygotowane adresy
  `https://przemyslawsobczyk123-lgtm.github.io/budowapro-app/privacy/` i
  `https://przemyslawsobczyk123-lgtm.github.io/budowapro-app/support/`;
- zlecic finalny przeglad prawny polityki, warunkow i porad budowlanych;
- potwierdzic prawa do nazwy BudowaPRO, ikon, zrzutow i pozostalych materialow;
- zatwierdzic finalny zakres R1, opis sklepu, kraje dystrybucji i date wydania.

Wszystkie pozostale prace techniczne, testowe, dokumentacyjne i przygotowanie
plikow moga zostac wykonane w repozytorium bez dodatkowej ingerencji.

## Minimalna kolejnosc

1. Potwierdz dane publiczne i wlacz GitHub Pages.
2. Dodaj sekrety podpisu Android/iOS bez wysylania ich w czacie.
3. Uruchom zielone CI, Android internal test i TestFlight.
4. Wykonaj fizyczny smoke oraz finalne zrzuty z wersji release.
5. Zatwierdz formularze sklepow i rozpocznij etapowa bete/produkcje.
