# BudowaPRO - czynnosci wymagajace wlasciciela

Ta lista zawiera tylko kroki, ktorych agent nie moze wykonac uczciwie bez
tozsamosci, zgody, platnego konta albo sekretu nalezacego do wydawcy.

## Google Play

- potwierdzic właściwy typ konta: organizacja tylko dla prawdziwej firmy z
  numerem D-U-N-S i dokumentami; w przeciwnym razie konto osobiste;
- zalozyc lub wskazac konto Play Console i potwierdzic dane prawne wydawcy;
- zaakceptowac umowy i uzupelnic wymagane informacje konta;
- wlaczyc Play App Signing i bezpiecznie zachowac docelowy klucz upload;
- potwierdzic w Play Console nazwe wydawcy `Przemyslaw Sobczyk`, e-mail
  `kontakt@budowaproapp.pl` oraz adresy `budowaproapp.pl`;
- zatwierdzic Data safety, grupe docelowa, klasyfikacje tresci i deklaracje
  reklam dla konkretnego AAB;
- zarejestrowac pakiet `pl.budowapro` po weryfikacji tozsamosci;
- zdecydowac przed pierwsza publikacja, czy pobranie pozostaje bezplatne;
- zapewnic 12 testerow przez 14 kolejnych dni, jezeli jest to nowe konto
  osobiste objete tym wymaganiem;
- sprawdzic odbior i odpowiedz ze skrzynki `kontakt@budowaproapp.pl`;
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
- potwierdzic, ze `Przemyslaw Sobczyk` jest wlasciwa nazwa prawna do publicznej
  polityki;
- sprawdzic tresc opublikowanych adresow
  `https://budowaproapp.pl/privacy/`, `https://budowaproapp.pl/terms/`,
  `https://budowaproapp.pl/support/` i
  `https://budowaproapp.pl/data-deletion/`;
- zlecic finalny przeglad prawny polityki, warunkow i porad budowlanych;
- potwierdzic prawa do nazwy BudowaPRO, ikon, zrzutow i pozostalych materialow;
- zatwierdzic finalny zakres R1, opis sklepu, kraje dystrybucji i date wydania.

Wszystkie pozostale prace techniczne, testowe, dokumentacyjne i przygotowanie
plikow moga zostac wykonane w repozytorium bez dodatkowej ingerencji.

## Minimalna kolejnosc

1. Potwierdz dane publiczne widoczne na opublikowanych stronach.
2. Dodaj sekrety podpisu Android/iOS bez wysylania ich w czacie.
3. Uruchom Android internal test i TestFlight; CI commita jest juz zielone.
4. Wykonaj fizyczny smoke oraz finalne zrzuty z wersji release.
5. Zatwierdz formularze sklepow i rozpocznij etapowa bete/produkcje.
