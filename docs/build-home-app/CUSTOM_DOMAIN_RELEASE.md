# BudowaPRO - uruchomienie budowaproapp.pl

Stan: 2026-08-06.

Repozytorium zawiera gotowy pakiet `site/`, plik `site/CNAME` oraz workflow
`.github/workflows/legal-pages.yml`. Po wyslaniu zmian na `main` GitHub Pages
opublikuje:

- `https://budowaproapp.pl/privacy/`;
- `https://budowaproapp.pl/terms/`;
- `https://budowaproapp.pl/support/`;
- `https://budowaproapp.pl/data-deletion/`.

## Konfiguracja DNS

Rekord apex `budowaproapp.pl` ma skonfigurowane cztery rekordy `A` GitHub
Pages:

```text
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

Dla hosta `www` jest skonfigurowany rekord `CNAME`:

```text
przemyslawsobczyk123-lgtm.github.io
```

DNS nie wymaga dalszych zmian. Nie dopisuj nazwy repozytorium do wartosci
CNAME i nie ustawiaj rekordu wildcard `*`.

## GitHub Pages

W repozytorium `przemyslawsobczyk123-lgtm/budowapro-app` domena niestandardowa
jest ustawiona na `budowaproapp.pl`. Treść stron odpowiada przez GitHub Pages,
ale 2026-08-06 certyfikat nie obejmuje jeszcze domeny i zwykła walidacja HTTPS
kończy się błędem nazwy. Po wystawieniu certyfikatu trzeba włączyć
`Settings -> Pages -> Enforce HTTPS` i ponownie sprawdzić wszystkie adresy.

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
