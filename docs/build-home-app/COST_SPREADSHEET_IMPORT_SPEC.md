# Import kosztow z arkusza

## Cel

Uzytkownik moze szybko przeniesc prosty kosztorys z Excela do BudowaPRO bez
przepisywania kazdej pozycji. Obslugiwane sa pliki CSV oraz XLSX zawierajace co
najmniej kolumne nazwy i kolumne kwoty brutto.

## Zakres R1

- Wejscie `Importuj arkusz` jest dostepne z ekranu budzetu.
- Obslugiwane formaty to `.csv` i `.xlsx`. Stary binarny format `.xls` nie jest
  obslugiwany.
- CSV moze uzywac przecinka, srednika albo tabulatora i moze zawierac BOM.
- XLSX korzysta z pierwszego niepustego arkusza. Nazwa arkusza jest widoczna w
  podgladzie.
- Pierwszy niepusty wiersz jest rozpoznawany jako naglowek, gdy zawiera typowe
  nazwy kolumn. Dla pliku bez naglowka aplikacja nadaje nazwy `Kolumna 1`,
  `Kolumna 2` itd.
- Przed zapisem uzytkownik wybiera kolumne nazwy i kwoty oraz rodzaj wpisow:
  plan budzetu, koszt rzeczywisty albo oferta.
- Uzytkownik wybiera klasyfikacje material/robocizna/wspolna/nieprzypisana,
  stawke VAT i opcjonalny etap.
- Domyslny import to plan budzetu, material i VAT 23%. Koszt rzeczywisty otrzymuje
  status `do zaplaty`; plan i oferta otrzymuja status `planowany`.
- Podglad pokazuje liczbe poprawnych i odrzuconych wierszy oraz pierwsze pozycje.
  Bledny wiersz nigdy nie jest pomijany bez widocznej informacji.
- Zapis poprawnych wierszy jest atomowy: powstaja wszystkie pozycje albo zadna.
  Kazda pozycja ma zrodlo `imported` i wlasna historie utworzenia.
- Po udanym imporcie budzet jest przeliczany i odswiezany.

## Walidacja i limity

- Maksymalnie 1000 wierszy danych oraz 50 kolumn.
- Maksymalny rozmiar CSV: 5 MB; XLSX: 10 MB.
- XLSX jest odrzucany, gdy rozpakowana zawartosc przekracza 50 MB albo archiwum
  zawiera wiecej niz 1000 elementow.
- Nazwa po przycieciu musi miec 1-120 znakow.
- Kwota musi byc dodatnia, miescic sie w limicie modelu `Money` i miec najwyzej
  dwie cyfry dziesietne. Akceptowane sa polskie i miedzynarodowe separatory, np.
  `1 234,56`, `1234.56`, `1.234,56` oraz `1,234.56`.
- Formuly arkusza bez zapisanej wartosci nie sa obliczane przez aplikacje i taki
  wiersz jest oznaczany jako bledny.
- Plik jest przetwarzany lokalnie. Nie jest wysylany ani trwale kopiowany do
  projektu.

## Architektura

- `domain`: format tabeli, mapowanie, podglad, bledy wierszy i wynik importu.
- `data`: systemowy wybor pliku, parser CSV/XLSX, limity oraz atomowy zapis w
  `SqliteCostRepository`.
- `presentation`: ekran wyboru, mapowania, podgladu i zatwierdzenia.
- Parsery pracuja poza izolatorem UI dla plikow wymagajacych dekodowania.

## Testy akceptacyjne

- CSV z naglowkiem `Nazwa;Koszt` tworzy oczekiwane pozycje.
- CSV bez naglowka pozwala zmapowac pierwsze dwie kolumny.
- XLSX z dwoma kolumnami daje taki sam podglad jak CSV.
- Kwoty z przecinkiem, kropka i separatorami tysiecy sa interpretowane poprawnie.
- Niepoprawne wiersze sa widoczne i nie trafiaja do bazy.
- Awaria jednego zapisu wycofuje cala paczke.
- Ekran miesci sie na szerokosci 320 px i ma stany wyboru, ladowania, bledu,
  podgladu oraz zapisu.

## Zrodla techniczne

- CSV 8.0.0: https://pub.dev/packages/csv/versions/8.0.0
- Excel Community 2.2.0: https://pub.dev/packages/excel_community/versions
- File Picker 11.0.2: https://pub.dev/packages/file_picker
