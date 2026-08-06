# BudowaPRO - uruchomienie budowaproapp.pl

Stan: 2026-08-06.

Repozytorium zawiera gotowy pakiet `site/`, plik `site/CNAME` oraz workflow
`.github/workflows/legal-pages.yml`. Po wyslaniu zmian na `main` GitHub Pages
opublikuje:

- `https://budowaproapp.pl/privacy/`;
- `https://budowaproapp.pl/terms/`;
- `https://budowaproapp.pl/support/`;
- `https://budowaproapp.pl/data-deletion/`.

## Jednorazowa konfiguracja DNS

Aktualny rekord apex `budowaproapp.pl` wskazuje `213.186.33.5`, czyli adres
parkingowy operatora. W panelu DNS domeny trzeba usunac ten rekord i ustawic
cztery rekordy `A` dla hosta `@`:

```text
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

Dla hosta `www` ustaw rekord `CNAME`:

```text
przemyslawsobczyk123-lgtm.github.io
```

Nie dopisuj nazwy repozytorium do wartosci CNAME. Nie ustawiaj rekordu
wildcard `*`.

## GitHub Pages

W repozytorium `przemyslawsobczyk123-lgtm/budowapro-app` otworz
`Settings -> Pages`, ustaw `Custom domain` na `budowaproapp.pl` i po
wystawieniu certyfikatu wlacz `Enforce HTTPS`. Konto GitHub CLI na tym
komputerze nie jest zalogowane, wiec tego kroku nie wykonano automatycznie.

## Kontrola przed Play Console

Po propagacji DNS sprawdz, czy wszystkie cztery adresy zwracaja HTML przez
HTTPS bez logowania i bez ostrzezenia certyfikatu. Dopiero wtedy wpisz do Play
Console:

```text
Privacy policy: https://budowaproapp.pl/privacy/
Website/support: https://budowaproapp.pl/support/
Developer email: kontakt@budowaproapp.pl
```

Aplikacja nie ma kont, dlatego zewnetrzny URL usuwania konta nie jest wymagany.
Strona `/data-deletion/` dokumentuje jednak lokalne usuwanie projektow i moze
sluzyc recenzentowi sklepu.

Oficjalna instrukcja GitHub Pages:
https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site
