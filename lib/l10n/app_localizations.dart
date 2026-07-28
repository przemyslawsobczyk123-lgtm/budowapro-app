import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pl')];

  /// Nazwa aplikacji.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO'**
  String get appTitle;

  /// Etykieta glownej zakladki Start.
  ///
  /// In pl, this message translates to:
  /// **'Start'**
  String get navStart;

  /// Etykieta glownej zakladki Plan.
  ///
  /// In pl, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// Etykieta glownej zakladki Budzet.
  ///
  /// In pl, this message translates to:
  /// **'Budżet'**
  String get navBudget;

  /// Etykieta glownej zakladki Budowa.
  ///
  /// In pl, this message translates to:
  /// **'Budowa'**
  String get navBuild;

  /// Etykieta glownej zakladki Wiecej.
  ///
  /// In pl, this message translates to:
  /// **'Więcej'**
  String get navMore;

  /// Tytul ekranu Start.
  ///
  /// In pl, this message translates to:
  /// **'Centrum budowy'**
  String get startTitle;

  /// Opis pustego ekranu Start podczas pierwszego przyrostu.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnego projektu.'**
  String get startSubtitle;

  /// Tytul ekranu Plan.
  ///
  /// In pl, this message translates to:
  /// **'Plan budowy'**
  String get planTitle;

  /// Opis pustego ekranu Plan podczas pierwszego przyrostu.
  ///
  /// In pl, this message translates to:
  /// **'Brak etapów dla aktywnego projektu.'**
  String get planSubtitle;

  /// Tytul ekranu Budzet.
  ///
  /// In pl, this message translates to:
  /// **'Budżet inwestycji'**
  String get budgetTitle;

  /// Opis pustego ekranu Budzet podczas pierwszego przyrostu.
  ///
  /// In pl, this message translates to:
  /// **'Brak kosztów dla aktywnego projektu.'**
  String get budgetSubtitle;

  /// Tytul ekranu Budowa.
  ///
  /// In pl, this message translates to:
  /// **'Dokumentacja budowy'**
  String get buildTitle;

  /// Opis pustego ekranu Budowa podczas pierwszego przyrostu.
  ///
  /// In pl, this message translates to:
  /// **'Brak dokumentów dla aktywnego projektu.'**
  String get buildSubtitle;

  /// Tytul ekranu Wiecej.
  ///
  /// In pl, this message translates to:
  /// **'Narzędzia projektu'**
  String get moreTitle;

  /// Opis pustego ekranu Wiecej podczas pierwszego przyrostu.
  ///
  /// In pl, this message translates to:
  /// **'Brak dodatkowych danych projektu.'**
  String get moreSubtitle;

  /// Komunikat ladowania projektow.
  ///
  /// In pl, this message translates to:
  /// **'Ładowanie projektów…'**
  String get projectsLoading;

  /// Blad ladowania projektow.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać projektów.'**
  String get projectsLoadError;

  /// Etykieta akcji ponowienia.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get retryAction;

  /// Etykieta anulowania operacji.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancelAction;

  /// Tytul ostrzezenia o niezapisanym formularzu.
  ///
  /// In pl, this message translates to:
  /// **'Niezapisane zmiany'**
  String get unsavedChangesTitle;

  /// Pytanie przed odrzuceniem zmian formularza.
  ///
  /// In pl, this message translates to:
  /// **'Zmiany w formularzu nie zostały zapisane. Odrzucić je?'**
  String get unsavedChangesMessage;

  /// Etykieta potwierdzenia odrzucenia zmian formularza.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć zmiany'**
  String get discardChangesAction;

  /// Etykieta usuniecia.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get deleteAction;

  /// Etykieta wyczyszczenia pola.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść'**
  String get clearAction;

  /// Tytul formularza nowego projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nowy projekt'**
  String get newProjectTitle;

  /// Tytul formularza edycji projektu.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj projekt'**
  String get editProjectTitle;

  /// Naglowek podstawowych danych projektu.
  ///
  /// In pl, this message translates to:
  /// **'Podstawowe dane'**
  String get projectBasicsSection;

  /// Naglowek terminow i ustawien projektu.
  ///
  /// In pl, this message translates to:
  /// **'Plan i ustawienia'**
  String get projectScheduleSection;

  /// Etykieta nazwy projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa projektu'**
  String get projectNameLabel;

  /// Etykieta adresu albo etykiety projektu.
  ///
  /// In pl, this message translates to:
  /// **'Adres lub etykieta'**
  String get projectLocationLabel;

  /// Etykieta typu projektu.
  ///
  /// In pl, this message translates to:
  /// **'Typ projektu'**
  String get projectTypeLabel;

  /// Etykieta szablonu projektu.
  ///
  /// In pl, this message translates to:
  /// **'Szablon etapów'**
  String get projectTemplateLabel;

  /// Etykieta waluty projektu.
  ///
  /// In pl, this message translates to:
  /// **'Waluta'**
  String get projectCurrencyLabel;

  /// Etykieta powierzchni projektu.
  ///
  /// In pl, this message translates to:
  /// **'Powierzchnia (m²)'**
  String get projectAreaLabel;

  /// Etykieta planowanego budzetu.
  ///
  /// In pl, this message translates to:
  /// **'Planowany budżet'**
  String get projectBudgetLabel;

  /// Etykieta planowanej daty rozpoczecia.
  ///
  /// In pl, this message translates to:
  /// **'Planowany start'**
  String get projectPlannedStartLabel;

  /// Etykieta planowanej daty zakonczenia.
  ///
  /// In pl, this message translates to:
  /// **'Planowane zakończenie'**
  String get projectPlannedEndLabel;

  /// Etykieta formatu daty.
  ///
  /// In pl, this message translates to:
  /// **'Format daty'**
  String get projectDateFormatLabel;

  /// Etykieta polskiego formatu daty.
  ///
  /// In pl, this message translates to:
  /// **'DD.MM.RRRR'**
  String get projectDateFormatDmy;

  /// Etykieta formatu daty rok-miesiac-dzien.
  ///
  /// In pl, this message translates to:
  /// **'RRRR-MM-DD'**
  String get projectDateFormatYmd;

  /// Etykieta aktualnego etapu projektu.
  ///
  /// In pl, this message translates to:
  /// **'Bieżący etap'**
  String get projectCurrentStageLabel;

  /// Akcja utworzenia projektu.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz projekt'**
  String get projectCreateAction;

  /// Akcja zapisania zmian projektu.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get projectSaveChangesAction;

  /// Walidacja wymaganej nazwy projektu.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę projektu.'**
  String get projectNameRequiredError;

  /// Walidacja dlugosci nazwy projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa może mieć maksymalnie 80 znaków.'**
  String get projectNameTooLongError;

  /// Walidacja dlugosci lokalizacji projektu.
  ///
  /// In pl, this message translates to:
  /// **'Adres lub etykieta może mieć maksymalnie 120 znaków.'**
  String get projectLocationTooLongError;

  /// Walidacja powierzchni projektu.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz dodatnią liczbę całkowitą.'**
  String get projectAreaInvalidError;

  /// Walidacja budzetu projektu.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kwotę z maksymalnie dwiema cyframi po przecinku.'**
  String get projectBudgetInvalidError;

  /// Walidacja zakresu dat projektu.
  ///
  /// In pl, this message translates to:
  /// **'Data zakończenia nie może być wcześniejsza niż data rozpoczęcia.'**
  String get projectDatesInvalidError;

  /// Blad zapisu projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać projektu.'**
  String get projectSaveError;

  /// Komunikat blokady zmiany waluty projektu z kosztami.
  ///
  /// In pl, this message translates to:
  /// **'Nie można zmienić waluty po zapisaniu pierwszego kosztu.'**
  String get projectCurrencyLockedError;

  /// Blad braku projektu podczas edycji.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono projektu.'**
  String get projectNotFoundError;

  /// Typ projektu: budowa domu.
  ///
  /// In pl, this message translates to:
  /// **'Budowa domu'**
  String get projectTypeHouseBuild;

  /// Typ projektu: remont domu.
  ///
  /// In pl, this message translates to:
  /// **'Remont domu'**
  String get projectTypeHouseRenovation;

  /// Typ projektu: remont mieszkania.
  ///
  /// In pl, this message translates to:
  /// **'Remont mieszkania'**
  String get projectTypeApartmentRenovation;

  /// Szablon etapow budowy domu.
  ///
  /// In pl, this message translates to:
  /// **'Budowa domu'**
  String get projectTemplateHouseConstruction;

  /// Szablon etapow remontu.
  ///
  /// In pl, this message translates to:
  /// **'Remont'**
  String get projectTemplateRenovation;

  /// Etap projektu: planowanie.
  ///
  /// In pl, this message translates to:
  /// **'Planowanie'**
  String get projectStagePlanning;

  /// Etap projektu: formalnosci.
  ///
  /// In pl, this message translates to:
  /// **'Formalności'**
  String get projectStageFormalities;

  /// Etap projektu: przygotowanie placu budowy.
  ///
  /// In pl, this message translates to:
  /// **'Przygotowanie placu'**
  String get projectStageSitePreparation;

  /// Etap projektu: stan zero.
  ///
  /// In pl, this message translates to:
  /// **'Stan zero'**
  String get projectStageStateZero;

  /// Etap projektu: stan surowy otwarty.
  ///
  /// In pl, this message translates to:
  /// **'Stan surowy otwarty'**
  String get projectStageShellOpen;

  /// Etap projektu: stan surowy zamkniety.
  ///
  /// In pl, this message translates to:
  /// **'Stan surowy zamknięty'**
  String get projectStageShellClosed;

  /// Etap projektu: rozbiorka.
  ///
  /// In pl, this message translates to:
  /// **'Rozbiórka'**
  String get projectStageDemolition;

  /// Etap projektu: instalacje.
  ///
  /// In pl, this message translates to:
  /// **'Instalacje'**
  String get projectStageInstallations;

  /// Etap projektu: tynki i wylewki.
  ///
  /// In pl, this message translates to:
  /// **'Tynki i wylewki'**
  String get projectStagePlaster;

  /// Etap projektu: wykonczenie.
  ///
  /// In pl, this message translates to:
  /// **'Wykończenie'**
  String get projectStageFinishing;

  /// Etap projektu: odbior.
  ///
  /// In pl, this message translates to:
  /// **'Odbiór'**
  String get projectStageHandover;

  /// Tytul przegladu aktywnego projektu.
  ///
  /// In pl, this message translates to:
  /// **'Projekt'**
  String get projectOverviewTitle;

  /// Tytul pustego przegladu projektu.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnego projektu'**
  String get projectOverviewEmptyTitle;

  /// Opis pustego przegladu projektu.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz pierwszy projekt, aby rozpocząć pracę.'**
  String get projectOverviewEmptyMessage;

  /// Akcja edycji projektu.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get projectEditAction;

  /// Etykieta lokalizacji w przegladzie projektu.
  ///
  /// In pl, this message translates to:
  /// **'Lokalizacja'**
  String get projectLocationOverviewLabel;

  /// Etykieta budzetu w przegladzie projektu.
  ///
  /// In pl, this message translates to:
  /// **'Budżet'**
  String get projectBudgetOverviewLabel;

  /// Etykieta terminow w przegladzie projektu.
  ///
  /// In pl, this message translates to:
  /// **'Terminy'**
  String get projectDatesOverviewLabel;

  /// Wartosc powierzchni projektu.
  ///
  /// In pl, this message translates to:
  /// **'{area} m²'**
  String projectAreaValue(int area);

  /// Zakres planowanych dat projektu.
  ///
  /// In pl, this message translates to:
  /// **'{start} – {end}'**
  String projectDateRangeValue(String start, String end);

  /// Brak opcjonalnej wartosci projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nie podano'**
  String get projectValueNotProvided;

  /// Tytul potwierdzenia usuniecia projektu.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć projekt „{projectName}”?'**
  String projectDeleteDialogTitle(String projectName);

  /// Ostrzezenie w potwierdzeniu usuniecia projektu.
  ///
  /// In pl, this message translates to:
  /// **'Tej operacji nie można cofnąć.'**
  String get projectDeleteWarning;

  /// Liczba plikow powiazanych z projektem.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane pliki: {count}'**
  String projectLinkedFilesCount(int count);

  /// Liczba rekordow powiazanych z projektem.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane rekordy: {count}'**
  String projectLinkedRecordsCount(int count);

  /// Komunikat pobierania skutkow usuniecia projektu.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdzanie powiązań…'**
  String get projectDeletionImpactLoading;

  /// Blad pobierania skutkow usuniecia projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się sprawdzić skutków usunięcia.'**
  String get projectDeletionImpactError;

  /// Blad usuwania projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć projektu.'**
  String get projectDeleteError;

  /// Etykieta globalnego selektora projektu.
  ///
  /// In pl, this message translates to:
  /// **'Projekt'**
  String get projectSelectorLabel;

  /// Tytul listy wyboru projektu.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get projectSelectorChoose;

  /// Akcja przejscia do nowego projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nowy projekt'**
  String get projectSelectorNewAction;

  /// Blad globalnego selektora projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać selektora projektu.'**
  String get projectSelectorError;

  /// Blad zmiany aktywnego projektu.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zmienić projektu.'**
  String get projectSelectorSelectError;

  /// No description provided for @costFormNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wpis'**
  String get costFormNewTitle;

  /// No description provided for @costFormEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj wpis'**
  String get costFormEditTitle;

  /// No description provided for @costDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły wpisu'**
  String get costDetailsTitle;

  /// No description provided for @costBudgetAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wpis'**
  String get costBudgetAddTooltip;

  /// No description provided for @costBudgetEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów'**
  String get costBudgetEmptyTitle;

  /// No description provided for @costBudgetEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy koszt, ofertę lub plan.'**
  String get costBudgetEmptyMessage;

  /// No description provided for @costBudgetNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get costBudgetNoProjectTitle;

  /// No description provided for @costBudgetNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Koszty są przypisane do projektu.'**
  String get costBudgetNoProjectMessage;

  /// No description provided for @costBudgetLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać kosztów.'**
  String get costBudgetLoadError;

  /// No description provided for @costBudgetPlannedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Plan'**
  String get costBudgetPlannedLabel;

  /// No description provided for @costBudgetActualLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki'**
  String get costBudgetActualLabel;

  /// No description provided for @costBudgetDifferenceLabel.
  ///
  /// In pl, this message translates to:
  /// **'Różnica'**
  String get costBudgetDifferenceLabel;

  /// No description provided for @costRegisterSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj nazwy, dostawcy lub opisu'**
  String get costRegisterSearchHint;

  /// No description provided for @costRegisterFilterTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Filtruj i sortuj'**
  String get costRegisterFilterTooltip;

  /// No description provided for @costRegisterResultCount.
  ///
  /// In pl, this message translates to:
  /// **'Wyniki: {count}'**
  String costRegisterResultCount(int count);

  /// No description provided for @costRegisterNoResultsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak pasujących wpisów'**
  String get costRegisterNoResultsTitle;

  /// No description provided for @costRegisterNoResultsMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zmień wyszukiwanie lub usuń część filtrów.'**
  String get costRegisterNoResultsMessage;

  /// No description provided for @costRegisterClearFilters.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść filtry'**
  String get costRegisterClearFilters;

  /// No description provided for @costRegisterFilterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Filtry kosztów'**
  String get costRegisterFilterTitle;

  /// No description provided for @costRegisterApplyFilters.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż wyniki'**
  String get costRegisterApplyFilters;

  /// No description provided for @costRegisterResetFilters.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść'**
  String get costRegisterResetFilters;

  /// No description provided for @costRegisterTypeSection.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj wpisu'**
  String get costRegisterTypeSection;

  /// No description provided for @costRegisterStatusSection.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get costRegisterStatusSection;

  /// No description provided for @costRegisterContextSection.
  ///
  /// In pl, this message translates to:
  /// **'Etap i wykonawca'**
  String get costRegisterContextSection;

  /// No description provided for @costRegisterPaymentSection.
  ///
  /// In pl, this message translates to:
  /// **'Płatność i źródło'**
  String get costRegisterPaymentSection;

  /// No description provided for @costRegisterDateSection.
  ///
  /// In pl, this message translates to:
  /// **'Zakres dat'**
  String get costRegisterDateSection;

  /// No description provided for @costRegisterQualitySection.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga uzupełnienia'**
  String get costRegisterQualitySection;

  /// No description provided for @costRegisterSortSection.
  ///
  /// In pl, this message translates to:
  /// **'Sortowanie'**
  String get costRegisterSortSection;

  /// No description provided for @costRegisterIncludeDrafts.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż szkice'**
  String get costRegisterIncludeDrafts;

  /// No description provided for @costRegisterAllOption.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get costRegisterAllOption;

  /// No description provided for @costRegisterDateFrom.
  ///
  /// In pl, this message translates to:
  /// **'Od'**
  String get costRegisterDateFrom;

  /// No description provided for @costRegisterDateTo.
  ///
  /// In pl, this message translates to:
  /// **'Do'**
  String get costRegisterDateTo;

  /// No description provided for @costRegisterLoadingMore.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie kolejnych wpisów'**
  String get costRegisterLoadingMore;

  /// No description provided for @costRegisterLoadMoreError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać kolejnych wpisów.'**
  String get costRegisterLoadMoreError;

  /// No description provided for @costRegisterSortNewest.
  ///
  /// In pl, this message translates to:
  /// **'Najnowsze'**
  String get costRegisterSortNewest;

  /// No description provided for @costRegisterSortOldest.
  ///
  /// In pl, this message translates to:
  /// **'Najstarsze'**
  String get costRegisterSortOldest;

  /// No description provided for @costRegisterSortAmountDescending.
  ///
  /// In pl, this message translates to:
  /// **'Kwota: malejąco'**
  String get costRegisterSortAmountDescending;

  /// No description provided for @costRegisterSortAmountAscending.
  ///
  /// In pl, this message translates to:
  /// **'Kwota: rosnąco'**
  String get costRegisterSortAmountAscending;

  /// No description provided for @costRegisterSortName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa: A-Z'**
  String get costRegisterSortName;

  /// No description provided for @costCsvExportTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Eksportuj CSV'**
  String get costCsvExportTooltip;

  /// No description provided for @costCsvExportTitle.
  ///
  /// In pl, this message translates to:
  /// **'Eksport kosztów do CSV'**
  String get costCsvExportTitle;

  /// No description provided for @costCsvExportScope.
  ///
  /// In pl, this message translates to:
  /// **'Rekordy w zakresie: {count}, aktywne filtry: {filterCount}'**
  String costCsvExportScope(int count, int filterCount);

  /// No description provided for @costCsvExportDestinationLabel.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce docelowe'**
  String get costCsvExportDestinationLabel;

  /// No description provided for @costCsvExportDestinationValue.
  ///
  /// In pl, this message translates to:
  /// **'Wybierzesz je w systemowym panelu po utworzeniu pliku.'**
  String get costCsvExportDestinationValue;

  /// No description provided for @costCsvExportColumnsHeading.
  ///
  /// In pl, this message translates to:
  /// **'Kolumny w pliku'**
  String get costCsvExportColumnsHeading;

  /// No description provided for @costCsvExportAction.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz i udostępnij'**
  String get costCsvExportAction;

  /// No description provided for @costCsvExportSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Wyeksportowane rekordy: {count}.'**
  String costCsvExportSuccess(int count);

  /// No description provided for @costCsvExportError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się utworzyć pliku CSV.'**
  String get costCsvExportError;

  /// No description provided for @costCsvLifecycleColumn.
  ///
  /// In pl, this message translates to:
  /// **'Tryb wpisu'**
  String get costCsvLifecycleColumn;

  /// No description provided for @costCsvConfirmedValue.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdzony'**
  String get costCsvConfirmedValue;

  /// No description provided for @costCsvEffectiveGrossColumn.
  ///
  /// In pl, this message translates to:
  /// **'Brutto po korektach'**
  String get costCsvEffectiveGrossColumn;

  /// No description provided for @costCsvOriginalGrossColumn.
  ///
  /// In pl, this message translates to:
  /// **'Brutto pierwotne'**
  String get costCsvOriginalGrossColumn;

  /// No description provided for @costCsvCurrencyColumn.
  ///
  /// In pl, this message translates to:
  /// **'Waluta'**
  String get costCsvCurrencyColumn;

  /// No description provided for @costCsvSourceColumn.
  ///
  /// In pl, this message translates to:
  /// **'Źródło'**
  String get costCsvSourceColumn;

  /// No description provided for @costCsvAttachmentCountColumn.
  ///
  /// In pl, this message translates to:
  /// **'Liczba dokumentów'**
  String get costCsvAttachmentCountColumn;

  /// No description provided for @costCsvEmptyValue.
  ///
  /// In pl, this message translates to:
  /// **'Brak'**
  String get costCsvEmptyValue;

  /// No description provided for @costWarningMissingDocument.
  ///
  /// In pl, this message translates to:
  /// **'Brak dokumentu'**
  String get costWarningMissingDocument;

  /// No description provided for @costWarningMissingDescription.
  ///
  /// In pl, this message translates to:
  /// **'Brak opisu'**
  String get costWarningMissingDescription;

  /// No description provided for @costWarningVatToReview.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź VAT 0%'**
  String get costWarningVatToReview;

  /// No description provided for @costSourceManual.
  ///
  /// In pl, this message translates to:
  /// **'Ręcznie'**
  String get costSourceManual;

  /// No description provided for @costSourceReceiptOcr.
  ///
  /// In pl, this message translates to:
  /// **'Paragon OCR'**
  String get costSourceReceiptOcr;

  /// No description provided for @costSourceInvoiceOcr.
  ///
  /// In pl, this message translates to:
  /// **'Faktura OCR'**
  String get costSourceInvoiceOcr;

  /// No description provided for @costSourceImported.
  ///
  /// In pl, this message translates to:
  /// **'Import'**
  String get costSourceImported;

  /// No description provided for @costSourceOfferConversion.
  ///
  /// In pl, this message translates to:
  /// **'Z oferty'**
  String get costSourceOfferConversion;

  /// No description provided for @costFormBasicsSection.
  ///
  /// In pl, this message translates to:
  /// **'Wpis'**
  String get costFormBasicsSection;

  /// No description provided for @costFormFinancialSection.
  ///
  /// In pl, this message translates to:
  /// **'Kwota'**
  String get costFormFinancialSection;

  /// No description provided for @costFormDetailsSection.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły'**
  String get costFormDetailsSection;

  /// No description provided for @costFormDocumentsSection.
  ///
  /// In pl, this message translates to:
  /// **'Dokumenty'**
  String get costFormDocumentsSection;

  /// No description provided for @costNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get costNameLabel;

  /// No description provided for @costTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj'**
  String get costTypeLabel;

  /// No description provided for @costGrossAmountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kwota brutto'**
  String get costGrossAmountLabel;

  /// No description provided for @costVatRateLabel.
  ///
  /// In pl, this message translates to:
  /// **'VAT'**
  String get costVatRateLabel;

  /// No description provided for @costNetAmountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Netto'**
  String get costNetAmountLabel;

  /// No description provided for @costVatAmountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kwota VAT'**
  String get costVatAmountLabel;

  /// No description provided for @costDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get costDateLabel;

  /// No description provided for @costStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get costStageLabel;

  /// No description provided for @costCategoryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get costCategoryLabel;

  /// No description provided for @costSupplierLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dostawca'**
  String get costSupplierLabel;

  /// No description provided for @costQuantityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość'**
  String get costQuantityLabel;

  /// No description provided for @costUnitLabel.
  ///
  /// In pl, this message translates to:
  /// **'Jednostka'**
  String get costUnitLabel;

  /// No description provided for @costStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get costStatusLabel;

  /// No description provided for @costPaymentMethodLabel.
  ///
  /// In pl, this message translates to:
  /// **'Metoda płatności'**
  String get costPaymentMethodLabel;

  /// No description provided for @costNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get costNoteLabel;

  /// No description provided for @costTypeCost.
  ///
  /// In pl, this message translates to:
  /// **'Koszt'**
  String get costTypeCost;

  /// No description provided for @costTypeOffer.
  ///
  /// In pl, this message translates to:
  /// **'Oferta'**
  String get costTypeOffer;

  /// No description provided for @costTypePlanned.
  ///
  /// In pl, this message translates to:
  /// **'Plan'**
  String get costTypePlanned;

  /// No description provided for @costStatusPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Planowany'**
  String get costStatusPlanned;

  /// No description provided for @costStatusOrdered.
  ///
  /// In pl, this message translates to:
  /// **'Zamówiony'**
  String get costStatusOrdered;

  /// No description provided for @costStatusDue.
  ///
  /// In pl, this message translates to:
  /// **'Do zapłaty'**
  String get costStatusDue;

  /// No description provided for @costStatusPaid.
  ///
  /// In pl, this message translates to:
  /// **'Opłacony'**
  String get costStatusPaid;

  /// No description provided for @costStatusReturned.
  ///
  /// In pl, this message translates to:
  /// **'Zwrot'**
  String get costStatusReturned;

  /// No description provided for @costStatusDisputed.
  ///
  /// In pl, this message translates to:
  /// **'Sporne'**
  String get costStatusDisputed;

  /// No description provided for @costPaymentCash.
  ///
  /// In pl, this message translates to:
  /// **'Gotówka'**
  String get costPaymentCash;

  /// No description provided for @costPaymentCard.
  ///
  /// In pl, this message translates to:
  /// **'Karta'**
  String get costPaymentCard;

  /// No description provided for @costPaymentBankTransfer.
  ///
  /// In pl, this message translates to:
  /// **'Przelew'**
  String get costPaymentBankTransfer;

  /// No description provided for @costPaymentBlik.
  ///
  /// In pl, this message translates to:
  /// **'BLIK'**
  String get costPaymentBlik;

  /// No description provided for @costPaymentOther.
  ///
  /// In pl, this message translates to:
  /// **'Inna'**
  String get costPaymentOther;

  /// No description provided for @costVatZero.
  ///
  /// In pl, this message translates to:
  /// **'0%'**
  String get costVatZero;

  /// No description provided for @costVatReduced.
  ///
  /// In pl, this message translates to:
  /// **'8%'**
  String get costVatReduced;

  /// No description provided for @costVatStandard.
  ///
  /// In pl, this message translates to:
  /// **'23%'**
  String get costVatStandard;

  /// No description provided for @costAddDocumentAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj dokument'**
  String get costAddDocumentAction;

  /// No description provided for @costNoDocumentsWarning.
  ///
  /// In pl, this message translates to:
  /// **'Brak dokumentu do wpisu.'**
  String get costNoDocumentsWarning;

  /// No description provided for @costDocumentCount.
  ///
  /// In pl, this message translates to:
  /// **'Dokumenty: {count}'**
  String costDocumentCount(int count);

  /// No description provided for @costSaveDraftAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz szkic'**
  String get costSaveDraftAction;

  /// No description provided for @costSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz koszt'**
  String get costSaveAction;

  /// No description provided for @costSaveChangesAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get costSaveChangesAction;

  /// No description provided for @costSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać wpisu.'**
  String get costSaveError;

  /// No description provided for @costLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać wpisu.'**
  String get costLoadError;

  /// No description provided for @costNotFoundError.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono wpisu.'**
  String get costNotFoundError;

  /// No description provided for @costNameRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę wpisu.'**
  String get costNameRequiredError;

  /// No description provided for @costNameTooLongError.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa może mieć maksymalnie 120 znaków.'**
  String get costNameTooLongError;

  /// No description provided for @costAmountRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj kwotę brutto.'**
  String get costAmountRequiredError;

  /// No description provided for @costAmountInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kwotę z maksymalnie dwiema cyframi po przecinku.'**
  String get costAmountInvalidError;

  /// No description provided for @costAmountTooLargeError.
  ///
  /// In pl, this message translates to:
  /// **'Kwota jest za duża.'**
  String get costAmountTooLargeError;

  /// No description provided for @costQuantityUnitRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj ilość i jednostkę.'**
  String get costQuantityUnitRequiredError;

  /// No description provided for @costQuantityInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz dodatnią ilość.'**
  String get costQuantityInvalidError;

  /// No description provided for @costNoteTooLongError.
  ///
  /// In pl, this message translates to:
  /// **'Notatka może mieć maksymalnie 2000 znaków.'**
  String get costNoteTooLongError;

  /// No description provided for @costStatusInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Ten status nie pasuje do rodzaju wpisu.'**
  String get costStatusInvalidError;

  /// No description provided for @costFinancialFieldsLocked.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdzone dane finansowe są zablokowane.'**
  String get costFinancialFieldsLocked;

  /// No description provided for @costDetailsEditAction.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get costDetailsEditAction;

  /// No description provided for @costDetailsCopyDraftAction.
  ///
  /// In pl, this message translates to:
  /// **'Kopiuj do szkicu'**
  String get costDetailsCopyDraftAction;

  /// No description provided for @costDetailsMarkPaidAction.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako opłacony'**
  String get costDetailsMarkPaidAction;

  /// No description provided for @costDetailsDeleteAction.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pozycję'**
  String get costDetailsDeleteAction;

  /// No description provided for @costDeleteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć pozycję?'**
  String get costDeleteTitle;

  /// No description provided for @costDeleteMessage.
  ///
  /// In pl, this message translates to:
  /// **'Koszt, jego historia i nieużywane dokumenty zostaną trwale usunięte.'**
  String get costDeleteMessage;

  /// No description provided for @costDeleteError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć szkicu.'**
  String get costDeleteError;

  /// No description provided for @costDetailsActionError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wykonać akcji.'**
  String get costDetailsActionError;

  /// No description provided for @costHistorySection.
  ///
  /// In pl, this message translates to:
  /// **'Historia'**
  String get costHistorySection;

  /// No description provided for @costHistoryEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak historii.'**
  String get costHistoryEmpty;

  /// No description provided for @costHistoryCreated.
  ///
  /// In pl, this message translates to:
  /// **'Utworzono wpis'**
  String get costHistoryCreated;

  /// No description provided for @costHistoryDraftSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano szkic'**
  String get costHistoryDraftSaved;

  /// No description provided for @costHistoryDraftReplaced.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano szkic'**
  String get costHistoryDraftReplaced;

  /// No description provided for @costHistoryConfirmed.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdzono wpis'**
  String get costHistoryConfirmed;

  /// No description provided for @costHistoryDetailsUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano szczegóły'**
  String get costHistoryDetailsUpdated;

  /// No description provided for @costHistoryStatusChanged.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniono status'**
  String get costHistoryStatusChanged;

  /// No description provided for @costHistoryCorrectionAdded.
  ///
  /// In pl, this message translates to:
  /// **'Dodano korektę'**
  String get costHistoryCorrectionAdded;

  /// No description provided for @costDraftLabel.
  ///
  /// In pl, this message translates to:
  /// **'Szkic'**
  String get costDraftLabel;

  /// No description provided for @costAttachmentsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak dokumentów.'**
  String get costAttachmentsEmpty;

  /// No description provided for @costRemoveDocumentTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń dokument'**
  String get costRemoveDocumentTooltip;

  /// No description provided for @costDatePickerTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę'**
  String get costDatePickerTooltip;

  /// No description provided for @saveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get saveAction;

  /// No description provided for @stagePlanLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie etapów i checklisty'**
  String get stagePlanLoading;

  /// No description provided for @stagePlanLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać planu projektu.'**
  String get stagePlanLoadError;

  /// No description provided for @stagePlanNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw utwórz projekt'**
  String get stagePlanNoProjectTitle;

  /// No description provided for @stagePlanNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Etapy i checklisty zostaną dopasowane do budowy domu albo remontu.'**
  String get stagePlanNoProjectMessage;

  /// No description provided for @stagePlanEyebrow.
  ///
  /// In pl, this message translates to:
  /// **'Etapy i checklisty'**
  String get stagePlanEyebrow;

  /// No description provided for @stageAddAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj etap'**
  String get stageAddAction;

  /// No description provided for @stageReorderAction.
  ///
  /// In pl, this message translates to:
  /// **'Zmień kolejność etapów'**
  String get stageReorderAction;

  /// No description provided for @stageEditAction.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj etap'**
  String get stageEditAction;

  /// No description provided for @stageRenameAction.
  ///
  /// In pl, this message translates to:
  /// **'Zmień nazwę'**
  String get stageRenameAction;

  /// No description provided for @stageNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa etapu'**
  String get stageNameLabel;

  /// No description provided for @stageNameRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę etapu.'**
  String get stageNameRequiredError;

  /// No description provided for @stageAddTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy etap'**
  String get stageAddTitle;

  /// No description provided for @stageRenameTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa etapu'**
  String get stageRenameTitle;

  /// No description provided for @stageReorderTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kolejność etapów'**
  String get stageReorderTitle;

  /// No description provided for @stageEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Plan etapu'**
  String get stageEditTitle;

  /// No description provided for @stageStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status etapu'**
  String get stageStatusLabel;

  /// No description provided for @stageStatusPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Planowany'**
  String get stageStatusPlanned;

  /// No description provided for @stageStatusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W realizacji'**
  String get stageStatusInProgress;

  /// No description provided for @stageStatusBlocked.
  ///
  /// In pl, this message translates to:
  /// **'Zablokowany'**
  String get stageStatusBlocked;

  /// No description provided for @stageStatusCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Zakończony'**
  String get stageStatusCompleted;

  /// No description provided for @stageStartDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Planowany start'**
  String get stageStartDateLabel;

  /// No description provided for @stageEndDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Planowany koniec'**
  String get stageEndDateLabel;

  /// No description provided for @stageBudgetLabel.
  ///
  /// In pl, this message translates to:
  /// **'Budżet etapu'**
  String get stageBudgetLabel;

  /// No description provided for @stageBudgetInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawną kwotę z maksymalnie dwiema cyframi po przecinku.'**
  String get stageBudgetInvalidError;

  /// No description provided for @stageProgressLabel.
  ///
  /// In pl, this message translates to:
  /// **'{resolved} z {total}'**
  String stageProgressLabel(int resolved, int total);

  /// No description provided for @stageProgressPercent.
  ///
  /// In pl, this message translates to:
  /// **'Postęp {percent}%'**
  String stageProgressPercent(int percent);

  /// No description provided for @stageBlockedCount.
  ///
  /// In pl, this message translates to:
  /// **'Zablokowane: {count}'**
  String stageBlockedCount(int count);

  /// No description provided for @stageNoChecklistTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ten etap nie ma jeszcze checklisty'**
  String get stageNoChecklistTitle;

  /// No description provided for @stageNoChecklistMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj własny punkt, termin i osobę odpowiedzialną.'**
  String get stageNoChecklistMessage;

  /// No description provided for @stageMutationError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać zmiany.'**
  String get stageMutationError;

  /// No description provided for @stageGuidanceHeading.
  ///
  /// In pl, this message translates to:
  /// **'Wskazówki dla tego etapu'**
  String get stageGuidanceHeading;

  /// No description provided for @stageGuidanceCount.
  ///
  /// In pl, this message translates to:
  /// **'Porady: {count}'**
  String stageGuidanceCount(int count);

  /// No description provided for @stageGuidanceAddOwnAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj własną pozycję'**
  String get stageGuidanceAddOwnAction;

  /// No description provided for @stageGuidanceDisclaimerTitle.
  ///
  /// In pl, this message translates to:
  /// **'To nie jest projekt wykonawczy'**
  String get stageGuidanceDisclaimerTitle;

  /// No description provided for @stageGuidanceDisclaimerMessage.
  ///
  /// In pl, this message translates to:
  /// **'To ogólna lista kontrolna do rozmowy z projektantem, kierownikiem budowy, wykonawcą branżowym lub właściwym urzędem. Aktualne wymogi, wymiary, materiały i układ zawsze potwierdź dla swojej działki i dokumentacji.'**
  String get stageGuidanceDisclaimerMessage;

  /// No description provided for @stageGuidanceCheckHeading.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź przed pracą'**
  String get stageGuidanceCheckHeading;

  /// No description provided for @stageGuidanceQuestionsHeading.
  ///
  /// In pl, this message translates to:
  /// **'Pytania do fachowca'**
  String get stageGuidanceQuestionsHeading;

  /// No description provided for @stageGuidanceSourcesHeading.
  ///
  /// In pl, this message translates to:
  /// **'Źródła i podstawa'**
  String get stageGuidanceSourcesHeading;

  /// No description provided for @stageGuidanceVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja treści {version} • sprawdzono {date}'**
  String stageGuidanceVersion(int version, String date);

  /// No description provided for @stageGuidanceCloseAction.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij wskazówkę'**
  String get stageGuidanceCloseAction;

  /// No description provided for @stageGuidanceEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak gotowych wskazówek dla tego etapu. Możesz dodać własną pozycję do checklisty.'**
  String get stageGuidanceEmpty;

  /// No description provided for @stageGuidanceRelatedChecklistHeading.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane punkty checklisty'**
  String get stageGuidanceRelatedChecklistHeading;

  /// No description provided for @stageGuidanceSourceRegulation.
  ///
  /// In pl, this message translates to:
  /// **'Przepis'**
  String get stageGuidanceSourceRegulation;

  /// No description provided for @stageGuidanceSourceStandard.
  ///
  /// In pl, this message translates to:
  /// **'Norma'**
  String get stageGuidanceSourceStandard;

  /// No description provided for @stageGuidanceSourceOfficialGuidance.
  ///
  /// In pl, this message translates to:
  /// **'Wytyczne techniczne'**
  String get stageGuidanceSourceOfficialGuidance;

  /// No description provided for @stageGuidanceSourceSystemDocumentation.
  ///
  /// In pl, this message translates to:
  /// **'Dokumentacja systemowa'**
  String get stageGuidanceSourceSystemDocumentation;

  /// No description provided for @stageGuidanceSourceRevision.
  ///
  /// In pl, this message translates to:
  /// **'Wydanie: {revision}'**
  String stageGuidanceSourceRevision(String revision);

  /// No description provided for @stageGuidanceSourceVerifiedOn.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdzono: {date}'**
  String stageGuidanceSourceVerifiedOn(String date);

  /// No description provided for @stageGuidanceSourceTechnicalConditions.
  ///
  /// In pl, this message translates to:
  /// **'Warunki techniczne budynków i wykaz zmian MRiT'**
  String get stageGuidanceSourceTechnicalConditions;

  /// No description provided for @stageGuidanceSourceTechnicalConditionsEarthing.
  ///
  /// In pl, this message translates to:
  /// **'Warunki techniczne § 184 - uziomy instalacji elektrycznej'**
  String get stageGuidanceSourceTechnicalConditionsEarthing;

  /// No description provided for @stageGuidanceSourceLowVoltageEarthing.
  ///
  /// In pl, this message translates to:
  /// **'PN-HD 60364-5-54 - uziemienia i przewody ochronne'**
  String get stageGuidanceSourceLowVoltageEarthing;

  /// No description provided for @stageGuidanceSourceElectricalVerification.
  ///
  /// In pl, this message translates to:
  /// **'PN-HD 60364-6 - sprawdzanie instalacji elektrycznych'**
  String get stageGuidanceSourceElectricalVerification;

  /// No description provided for @stageGuidanceSourceLightningProtection.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN IEC 62305-3 - projektowanie i sprawdzanie LPS'**
  String get stageGuidanceSourceLightningProtection;

  /// No description provided for @stageGuidanceSourceLightningConnections.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN IEC 62561-1 - elementy połączeniowe'**
  String get stageGuidanceSourceLightningConnections;

  /// No description provided for @stageGuidanceSourceLightningConductors.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN IEC 62561-2 - przewody i uziomy'**
  String get stageGuidanceSourceLightningConductors;

  /// No description provided for @stageGuidanceSourceItbWaterproofing.
  ///
  /// In pl, this message translates to:
  /// **'ITB - izolacje części podziemnych budynków'**
  String get stageGuidanceSourceItbWaterproofing;

  /// No description provided for @stageGuidanceSourcePmbcStandard.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 15814 - grubowarstwowe powłoki asfaltowe PMBC'**
  String get stageGuidanceSourcePmbcStandard;

  /// No description provided for @stageGuidanceSourceDehnEarthing.
  ///
  /// In pl, this message translates to:
  /// **'DEHN - poradnik uziomów fundamentowych'**
  String get stageGuidanceSourceDehnEarthing;

  /// No description provided for @stageGuidanceSourceHauffEntries.
  ///
  /// In pl, this message translates to:
  /// **'Hauff-Technik - systemowe przepusty do budynków'**
  String get stageGuidanceSourceHauffEntries;

  /// No description provided for @stageGuidanceSourceRemmersWaterproofing.
  ///
  /// In pl, this message translates to:
  /// **'Remmers - system hydroizolacji MB 2K'**
  String get stageGuidanceSourceRemmersWaterproofing;

  /// No description provided for @stageGuidanceSourceUrsaInsulation.
  ///
  /// In pl, this message translates to:
  /// **'URSA - termoizolacja fundamentów i cokołów'**
  String get stageGuidanceSourceUrsaInsulation;

  /// No description provided for @stageGuidanceSourceAluprofShading.
  ///
  /// In pl, this message translates to:
  /// **'ALUPROF - kompendium systemów osłonowych'**
  String get stageGuidanceSourceAluprofShading;

  /// No description provided for @stageGuidanceSourceConstructionLaw.
  ///
  /// In pl, this message translates to:
  /// **'Prawo budowlane - aktualny tekst ustawy'**
  String get stageGuidanceSourceConstructionLaw;

  /// No description provided for @stageGuidanceSourceGunbProcedures.
  ///
  /// In pl, this message translates to:
  /// **'GUNB - procedury budowlane'**
  String get stageGuidanceSourceGunbProcedures;

  /// No description provided for @stageGuidanceSourceGunbForms.
  ///
  /// In pl, this message translates to:
  /// **'GUNB - aktualne formularze budowlane'**
  String get stageGuidanceSourceGunbForms;

  /// No description provided for @stageGuidanceSourceSpatialPlanning.
  ///
  /// In pl, this message translates to:
  /// **'MRiT - planowanie przestrzenne'**
  String get stageGuidanceSourceSpatialPlanning;

  /// No description provided for @stageGuidanceSourceGeotechnicalRegulation.
  ///
  /// In pl, this message translates to:
  /// **'Rozporządzenie - geotechniczne warunki posadowienia'**
  String get stageGuidanceSourceGeotechnicalRegulation;

  /// No description provided for @stageGuidanceSourceEurocodeGeotechnical.
  ///
  /// In pl, this message translates to:
  /// **'Eurokod 7 - projektowanie i badania geotechniczne'**
  String get stageGuidanceSourceEurocodeGeotechnical;

  /// No description provided for @stageGuidanceSourceGeodeticGuidance.
  ///
  /// In pl, this message translates to:
  /// **'Budowlane ABC - opracowania geodezyjne'**
  String get stageGuidanceSourceGeodeticGuidance;

  /// No description provided for @stageGuidanceSourceElectronicConstructionLog.
  ///
  /// In pl, this message translates to:
  /// **'GUNB - Elektroniczny Dziennik Budowy'**
  String get stageGuidanceSourceElectronicConstructionLog;

  /// No description provided for @stageGuidanceSourceConstructionSafety.
  ///
  /// In pl, this message translates to:
  /// **'Rozporządzenie BHP podczas robót budowlanych'**
  String get stageGuidanceSourceConstructionSafety;

  /// No description provided for @stageGuidanceSourcePipChecklist.
  ///
  /// In pl, this message translates to:
  /// **'PIP - lista kontrolna bezpieczeństwa budowy'**
  String get stageGuidanceSourcePipChecklist;

  /// No description provided for @stageGuidanceSourceGddkiaSiteAccess.
  ///
  /// In pl, this message translates to:
  /// **'GDDKiA - zasady dotyczące zjazdów'**
  String get stageGuidanceSourceGddkiaSiteAccess;

  /// No description provided for @stageGuidanceSourceConcreteExecution.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 13670 - wykonywanie konstrukcji z betonu'**
  String get stageGuidanceSourceConcreteExecution;

  /// No description provided for @stageGuidanceSourceMasonryExecution.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 1996-2 - wykonanie konstrukcji murowych'**
  String get stageGuidanceSourceMasonryExecution;

  /// No description provided for @stageGuidanceSourceItbRoofCoverings.
  ///
  /// In pl, this message translates to:
  /// **'ITB - wykonanie i odbiór pokryć dachowych'**
  String get stageGuidanceSourceItbRoofCoverings;

  /// No description provided for @stageGuidanceSourceWindowPerformance.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 14351-1+A2 - właściwości okien i drzwi zewnętrznych'**
  String get stageGuidanceSourceWindowPerformance;

  /// No description provided for @stageGuidanceSourceItbWindowInstallation.
  ///
  /// In pl, this message translates to:
  /// **'ITB WTWiORB B6 - montaż okien i drzwi balkonowych'**
  String get stageGuidanceSourceItbWindowInstallation;

  /// No description provided for @stageGuidanceSourceWaterInstallation.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 806-4 - wykonanie instalacji wodociągowych'**
  String get stageGuidanceSourceWaterInstallation;

  /// No description provided for @stageGuidanceSourceSurfaceHeating.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 1264-4 - instalowanie ogrzewania płaszczyznowego'**
  String get stageGuidanceSourceSurfaceHeating;

  /// No description provided for @stageGuidanceSourceVentilationAcceptance.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 12599 - odbiór wentylacji i klimatyzacji'**
  String get stageGuidanceSourceVentilationAcceptance;

  /// No description provided for @stageGuidanceSourceItbTileFinishes.
  ///
  /// In pl, this message translates to:
  /// **'ITB - okładziny i posadzki z płytek ceramicznych'**
  String get stageGuidanceSourceItbTileFinishes;

  /// No description provided for @stageGuidanceSourceLiquidWaterproofing.
  ///
  /// In pl, this message translates to:
  /// **'PN-EN 14891 - ciekłe wyroby wodochronne pod płytki'**
  String get stageGuidanceSourceLiquidWaterproofing;

  /// No description provided for @stageGuidanceSourceItbWetAreaWaterproofing.
  ///
  /// In pl, this message translates to:
  /// **'ITB WTWiORB C6 - zabezpieczenia wodochronne pomieszczeń mokrych'**
  String get stageGuidanceSourceItbWetAreaWaterproofing;

  /// No description provided for @checklistHeading.
  ///
  /// In pl, this message translates to:
  /// **'Lista kontrolna'**
  String get checklistHeading;

  /// No description provided for @checklistBulkSelectAction.
  ///
  /// In pl, this message translates to:
  /// **'Zaznacz wiele'**
  String get checklistBulkSelectAction;

  /// No description provided for @checklistBulkSelectedCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} zaznaczonych'**
  String checklistBulkSelectedCount(int count);

  /// No description provided for @checklistBulkSelectAllAction.
  ///
  /// In pl, this message translates to:
  /// **'Zaznacz wszystkie otwarte'**
  String get checklistBulkSelectAllAction;

  /// No description provided for @checklistBulkCancelAction.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ wybieranie'**
  String get checklistBulkCancelAction;

  /// No description provided for @checklistBulkCompleteAction.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako wykonane'**
  String get checklistBulkCompleteAction;

  /// No description provided for @checklistBulkCompletedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Oznaczono jako wykonane: {count}.'**
  String checklistBulkCompletedMessage(int count);

  /// No description provided for @checklistBulkEvidencePendingMessage.
  ///
  /// In pl, this message translates to:
  /// **'Oznaczono: {completed}. Pozostałe wymagają dowodu: {pending}.'**
  String checklistBulkEvidencePendingMessage(int completed, int pending);

  /// No description provided for @checklistBulkOnlyEvidencePendingMessage.
  ///
  /// In pl, this message translates to:
  /// **'Wybrane punkty wymagają najpierw dodania dowodu lub zapisanego odstępstwa.'**
  String get checklistBulkOnlyEvidencePendingMessage;

  /// No description provided for @checklistAddAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj punkt'**
  String get checklistAddAction;

  /// No description provided for @checklistAddTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy punkt checklisty'**
  String get checklistAddTitle;

  /// No description provided for @checklistEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły punktu'**
  String get checklistEditTitle;

  /// No description provided for @checklistTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa punktu'**
  String get checklistTitleLabel;

  /// No description provided for @checklistTitleRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę punktu.'**
  String get checklistTitleRequiredError;

  /// No description provided for @checklistStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get checklistStatusLabel;

  /// No description provided for @checklistStatusTodo.
  ///
  /// In pl, this message translates to:
  /// **'Do zrobienia'**
  String get checklistStatusTodo;

  /// No description provided for @checklistStatusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie'**
  String get checklistStatusInProgress;

  /// No description provided for @checklistStatusBlocked.
  ///
  /// In pl, this message translates to:
  /// **'Zablokowane'**
  String get checklistStatusBlocked;

  /// No description provided for @checklistStatusCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Zakończone'**
  String get checklistStatusCompleted;

  /// No description provided for @checklistStatusSkipped.
  ///
  /// In pl, this message translates to:
  /// **'Pominięte'**
  String get checklistStatusSkipped;

  /// No description provided for @checklistImportanceLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ważność'**
  String get checklistImportanceLabel;

  /// No description provided for @checklistImportanceLow.
  ///
  /// In pl, this message translates to:
  /// **'Niska'**
  String get checklistImportanceLow;

  /// No description provided for @checklistImportanceNormal.
  ///
  /// In pl, this message translates to:
  /// **'Normalna'**
  String get checklistImportanceNormal;

  /// No description provided for @checklistImportanceHigh.
  ///
  /// In pl, this message translates to:
  /// **'Wysoka'**
  String get checklistImportanceHigh;

  /// No description provided for @checklistImportanceCritical.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczna'**
  String get checklistImportanceCritical;

  /// No description provided for @checklistDueDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Termin'**
  String get checklistDueDateLabel;

  /// No description provided for @checklistAssigneeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Osoba odpowiedzialna'**
  String get checklistAssigneeLabel;

  /// No description provided for @checklistNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get checklistNoteLabel;

  /// No description provided for @checklistRiskLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ryzyko pominięcia'**
  String get checklistRiskLabel;

  /// No description provided for @checklistBuiltInRiskTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dlaczego ten punkt jest ważny'**
  String get checklistBuiltInRiskTitle;

  /// No description provided for @checklistRiskOverrideLabel.
  ///
  /// In pl, this message translates to:
  /// **'Własny opis ryzyka'**
  String get checklistRiskOverrideLabel;

  /// No description provided for @checklistRiskOverrideHint.
  ///
  /// In pl, this message translates to:
  /// **'Pozostaw puste, aby używać opisu BudowaPRO.'**
  String get checklistRiskOverrideHint;

  /// No description provided for @checklistReasonLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powód blokady lub pominięcia'**
  String get checklistReasonLabel;

  /// No description provided for @checklistReasonRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Pominięcie punktu wymaga podania powodu.'**
  String get checklistReasonRequiredError;

  /// No description provided for @checklistEvidenceLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wymagany dowód'**
  String get checklistEvidenceLabel;

  /// No description provided for @checklistEvidenceNone.
  ///
  /// In pl, this message translates to:
  /// **'Bez dowodu'**
  String get checklistEvidenceNone;

  /// No description provided for @checklistEvidenceAny.
  ///
  /// In pl, this message translates to:
  /// **'Dokument lub zdjęcie'**
  String get checklistEvidenceAny;

  /// No description provided for @checklistEvidencePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie'**
  String get checklistEvidencePhoto;

  /// No description provided for @checklistEvidenceCount.
  ///
  /// In pl, this message translates to:
  /// **'Dowody: {count}'**
  String checklistEvidenceCount(int count);

  /// No description provided for @checklistOpenEvidenceAction.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz dokumenty dowodowe'**
  String get checklistOpenEvidenceAction;

  /// No description provided for @checklistEvidenceItemLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dowód {number}'**
  String checklistEvidenceItemLabel(int number);

  /// No description provided for @checklistEvidenceWaived.
  ///
  /// In pl, this message translates to:
  /// **'Udokumentowane odstępstwo'**
  String get checklistEvidenceWaived;

  /// No description provided for @checklistEvidenceRequiredTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brakuje wymaganego dowodu'**
  String get checklistEvidenceRequiredTitle;

  /// No description provided for @checklistEvidenceRequiredMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj lokalne zdjęcie lub dokument. Możesz też jawnie odstąpić od dowodu i zapisać uzasadnienie.'**
  String get checklistEvidenceRequiredMessage;

  /// No description provided for @checklistAddEvidenceAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj dowód'**
  String get checklistAddEvidenceAction;

  /// No description provided for @checklistWaiveEvidenceAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz odstępstwo'**
  String get checklistWaiveEvidenceAction;

  /// No description provided for @checklistWaiverTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odstępstwo od dowodu'**
  String get checklistWaiverTitle;

  /// No description provided for @checklistWaiverLabel.
  ///
  /// In pl, this message translates to:
  /// **'Uzasadnienie odstępstwa'**
  String get checklistWaiverLabel;

  /// No description provided for @checklistWaiverRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz konkretne uzasadnienie odstępstwa.'**
  String get checklistWaiverRequiredError;

  /// No description provided for @checklistEvidenceImportError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dodać dowodu. Sprawdź typ pliku i spróbuj ponownie.'**
  String get checklistEvidenceImportError;

  /// No description provided for @checklistPlanningPermissionBasis.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź MPZP albo uzyskaj warunki zabudowy'**
  String get checklistPlanningPermissionBasis;

  /// No description provided for @checklistPlanningPermissionBasisRisk.
  ///
  /// In pl, this message translates to:
  /// **'Projekt niezgodny z ustaleniami planistycznymi może nie uzyskać zgody albo wymagać kosztownych zmian.'**
  String get checklistPlanningPermissionBasisRisk;

  /// No description provided for @checklistLandTitleAndRoadAccess.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź prawo do działki i dostęp do drogi'**
  String get checklistLandTitleAndRoadAccess;

  /// No description provided for @checklistLandTitleAndRoadAccessRisk.
  ///
  /// In pl, this message translates to:
  /// **'Niejasne granice, służebności lub brak prawnego dojazdu mogą zablokować projekt i dostawy.'**
  String get checklistLandTitleAndRoadAccessRisk;

  /// No description provided for @checklistDesignMap.
  ///
  /// In pl, this message translates to:
  /// **'Zleć mapę do celów projektowych'**
  String get checklistDesignMap;

  /// No description provided for @checklistDesignMapRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieaktualna lub nieprawidłowa mapa może pominąć uzbrojenie i wymusić korektę projektu.'**
  String get checklistDesignMapRisk;

  /// No description provided for @checklistHouseDesignSelection.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt domu zgodny z działką'**
  String get checklistHouseDesignSelection;

  /// No description provided for @checklistHouseDesignSelectionRisk.
  ///
  /// In pl, this message translates to:
  /// **'Zakup projektu przed sprawdzeniem MPZP lub WZ, stron świata, gruntu i budżetu często kończy się zmianami.'**
  String get checklistHouseDesignSelectionRisk;

  /// No description provided for @checklistReadyDesignAdaptation.
  ///
  /// In pl, this message translates to:
  /// **'Zaadaptuj projekt gotowy do działki, jeżeli dotyczy'**
  String get checklistReadyDesignAdaptation;

  /// No description provided for @checklistReadyDesignAdaptationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Projekt gotowy bez adaptacji nie uwzględnia konkretnej działki, gruntu, otoczenia ani lokalnych wymagań.'**
  String get checklistReadyDesignAdaptationRisk;

  /// No description provided for @checklistUtilityConnectionConditions.
  ///
  /// In pl, this message translates to:
  /// **'Uzyskaj warunki przyłączenia planowanych mediów'**
  String get checklistUtilityConnectionConditions;

  /// No description provided for @checklistUtilityConnectionConditionsRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak uzgodnień z operatorami może zmienić trasy, koszty i terminy przyłączy.'**
  String get checklistUtilityConnectionConditionsRisk;

  /// No description provided for @checklistCoordinatedBuildingDesign.
  ///
  /// In pl, this message translates to:
  /// **'Skompletuj i skoordynuj projekt budowlany oraz techniczny'**
  String get checklistCoordinatedBuildingDesign;

  /// No description provided for @checklistCoordinatedBuildingDesignRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieskoordynowane branże powodują kolizje instalacji, konstrukcji i przyłączy już na budowie.'**
  String get checklistCoordinatedBuildingDesignRisk;

  /// No description provided for @checklistBuildingPermitOrNotification.
  ///
  /// In pl, this message translates to:
  /// **'Uzyskaj pozwolenie albo skutecznie zgłoś budowę'**
  String get checklistBuildingPermitOrNotification;

  /// No description provided for @checklistBuildingPermitOrNotificationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Rozpoczęcie bez właściwej podstawy prawnej grozi wstrzymaniem robót i postępowaniem naprawczym.'**
  String get checklistBuildingPermitOrNotificationRisk;

  /// No description provided for @checklistConstructionManagerAppointment.
  ///
  /// In pl, this message translates to:
  /// **'Ustanów kierownika budowy, jeżeli jest wymagany'**
  String get checklistConstructionManagerAppointment;

  /// No description provided for @checklistConstructionManagerAppointmentRisk.
  ///
  /// In pl, this message translates to:
  /// **'Bez osoby z właściwymi uprawnieniami nie wolno rozpoczynać robót wymagających kierownika.'**
  String get checklistConstructionManagerAppointmentRisk;

  /// No description provided for @checklistConstructionLog.
  ///
  /// In pl, this message translates to:
  /// **'Uzyskaj i uruchom dziennik budowy'**
  String get checklistConstructionLog;

  /// No description provided for @checklistConstructionLogRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak wymaganego dziennika utrudnia legalne rozpoczęcie i rzetelne dokumentowanie robót.'**
  String get checklistConstructionLogRisk;

  /// No description provided for @checklistConstructionCommencementNotice.
  ///
  /// In pl, this message translates to:
  /// **'Zawiadom nadzór i projektanta o rozpoczęciu robót'**
  String get checklistConstructionCommencementNotice;

  /// No description provided for @checklistConstructionCommencementNoticeRisk.
  ///
  /// In pl, this message translates to:
  /// **'Zagospodarowanie placu i przyłącza mogą być pracami przygotowawczymi, więc zawiadomienie złóż wcześniej.'**
  String get checklistConstructionCommencementNoticeRisk;

  /// No description provided for @checklistManagerDocumentationHandover.
  ///
  /// In pl, this message translates to:
  /// **'Przekaż kierownikowi projekt i dokumentację'**
  String get checklistManagerDocumentationHandover;

  /// No description provided for @checklistManagerDocumentationHandoverRisk.
  ///
  /// In pl, this message translates to:
  /// **'Kierownik bez kompletnego projektu, decyzji i uzgodnień nie może bezpiecznie zorganizować robót.'**
  String get checklistManagerDocumentationHandoverRisk;

  /// No description provided for @checklistAdditionalPermitsAudit.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź dodatkowe zgody i ograniczenia'**
  String get checklistAdditionalPermitsAudit;

  /// No description provided for @checklistAdditionalPermitsAuditRisk.
  ///
  /// In pl, this message translates to:
  /// **'Drzewa, zabytki, grunty rolne lub leśne, wody i zjazd z drogi mogą wymagać osobnych decyzji.'**
  String get checklistAdditionalPermitsAuditRisk;

  /// No description provided for @checklistPreStartDocumentAudit.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź komplet dokumentów przed pierwszą pracą'**
  String get checklistPreStartDocumentAudit;

  /// No description provided for @checklistPreStartDocumentAuditRisk.
  ///
  /// In pl, this message translates to:
  /// **'Jedna brakująca decyzja, data ważności lub podpis może zatrzymać rozpoczęcie budowy.'**
  String get checklistPreStartDocumentAuditRisk;

  /// No description provided for @checklistSiteLogisticsPlan.
  ///
  /// In pl, this message translates to:
  /// **'Uzgodnij z kierownikiem logistykę placu'**
  String get checklistSiteLogisticsPlan;

  /// No description provided for @checklistSiteLogisticsPlanRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak planu wjazdu, składowania i pracy maszyn zwiększa ryzyko kolizji, szkód i przestojów.'**
  String get checklistSiteLogisticsPlanRisk;

  /// No description provided for @checklistTemporarySiteFence.
  ///
  /// In pl, this message translates to:
  /// **'Przygotuj tymczasowe ogrodzenie działki'**
  String get checklistTemporarySiteFence;

  /// No description provided for @checklistTemporarySiteFenceRisk.
  ///
  /// In pl, this message translates to:
  /// **'Niezabezpieczony teren naraża osoby postronne na wejście w strefę robót.'**
  String get checklistTemporarySiteFenceRisk;

  /// No description provided for @checklistHeavyEquipmentGate.
  ///
  /// In pl, this message translates to:
  /// **'Przygotuj szeroką bramę i bezpieczne wejście piesze'**
  String get checklistHeavyEquipmentGate;

  /// No description provided for @checklistHeavyEquipmentGateRisk.
  ///
  /// In pl, this message translates to:
  /// **'Zbyt wąski wjazd lub wspólna trasa pieszych i maszyn utrudni dostawy i zwiększy ryzyko wypadku.'**
  String get checklistHeavyEquipmentGateRisk;

  /// No description provided for @checklistStabilizedSiteEntrance.
  ///
  /// In pl, this message translates to:
  /// **'Przygotuj legalny i utwardzony wjazd'**
  String get checklistStabilizedSiteEntrance;

  /// No description provided for @checklistStabilizedSiteEntranceRisk.
  ///
  /// In pl, this message translates to:
  /// **'Grząski albo nieuzgodniony zjazd może zatrzymać ciężki sprzęt, uszkodzić drogę i nanosić błoto.'**
  String get checklistStabilizedSiteEntranceRisk;

  /// No description provided for @checklistToolStorageContainer.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw blaszak lub kontener na narzędzia'**
  String get checklistToolStorageContainer;

  /// No description provided for @checklistToolStorageContainerRisk.
  ///
  /// In pl, this message translates to:
  /// **'Źle ustawione lub niezabezpieczone zaplecze utrudnia pracę i zwiększa ryzyko kradzieży albo pożaru.'**
  String get checklistToolStorageContainerRisk;

  /// No description provided for @checklistTemporaryConstructionPower.
  ///
  /// In pl, this message translates to:
  /// **'Zapewnij bezpieczny prąd budowlany'**
  String get checklistTemporaryConstructionPower;

  /// No description provided for @checklistTemporaryConstructionPowerRisk.
  ///
  /// In pl, this message translates to:
  /// **'Prowizoryczne zasilanie bez zabezpieczeń i pomiarów grozi porażeniem, pożarem oraz przestojem.'**
  String get checklistTemporaryConstructionPowerRisk;

  /// No description provided for @checklistConstructionWaterSupply.
  ///
  /// In pl, this message translates to:
  /// **'Zapewnij wodę do robót, higieny i picia'**
  String get checklistConstructionWaterSupply;

  /// No description provided for @checklistConstructionWaterSupplyRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak rozdzielenia wody technologicznej i pitnej utrudnia roboty oraz bezpieczne zaplecze pracowników.'**
  String get checklistConstructionWaterSupplyRisk;

  /// No description provided for @checklistPortableToilet.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw toaletę przenośną i punkt mycia'**
  String get checklistPortableToilet;

  /// No description provided for @checklistPortableToiletRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnego i regularnie serwisowanego zaplecza sanitarnego narusza podstawowe warunki pracy.'**
  String get checklistPortableToiletRisk;

  /// No description provided for @checklistSiteUtilitiesAndHazardsMarking.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz uzbrojenie, drzewa i strefy niebezpieczne'**
  String get checklistSiteUtilitiesAndHazardsMarking;

  /// No description provided for @checklistSiteUtilitiesAndHazardsMarkingRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieoznaczone sieci i strefy pracy maszyn zwiększają ryzyko uszkodzeń, porażenia i wypadków.'**
  String get checklistSiteUtilitiesAndHazardsMarkingRisk;

  /// No description provided for @checklistSiteSafetySetup.
  ///
  /// In pl, this message translates to:
  /// **'Przygotuj tablicę, BIOZ i wyposażenie bezpieczeństwa'**
  String get checklistSiteSafetySetup;

  /// No description provided for @checklistSiteSafetySetupRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak oznakowania, apteczki, gaśnicy lub wymaganej dokumentacji utrudni reakcję na zagrożenie.'**
  String get checklistSiteSafetySetupRisk;

  /// No description provided for @checklistMaterialAndWasteZones.
  ///
  /// In pl, this message translates to:
  /// **'Wyznacz miejsca materiałów, dostaw i odpadów'**
  String get checklistMaterialAndWasteZones;

  /// No description provided for @checklistMaterialAndWasteZonesRisk.
  ///
  /// In pl, this message translates to:
  /// **'Chaotyczne składowanie blokuje przejazdy, niszczy materiały i utrudnia legalne przekazanie odpadów.'**
  String get checklistMaterialAndWasteZonesRisk;

  /// No description provided for @checklistPreConstructionPhotoRecord.
  ///
  /// In pl, this message translates to:
  /// **'Zrób dokumentację stanu przed budową'**
  String get checklistPreConstructionPhotoRecord;

  /// No description provided for @checklistPreConstructionPhotoRecordRisk.
  ///
  /// In pl, this message translates to:
  /// **'Bez zdjęć granic, drogi, drzew i sąsiednich ogrodzeń trudno później rozstrzygnąć odpowiedzialność za szkody.'**
  String get checklistPreConstructionPhotoRecordRisk;

  /// No description provided for @checklistSoilResearch.
  ///
  /// In pl, this message translates to:
  /// **'Badania gruntu i warunki wodne'**
  String get checklistSoilResearch;

  /// No description provided for @checklistSoilResearchRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieznane warunki gruntowe mogą wymusić zmianę posadowienia i zwiększyć koszt fundamentów.'**
  String get checklistSoilResearchRisk;

  /// No description provided for @checklistSurveyorBuildingSetout.
  ///
  /// In pl, this message translates to:
  /// **'Geodeta i wytyczenie budynku'**
  String get checklistSurveyorBuildingSetout;

  /// No description provided for @checklistSurveyorBuildingSetoutRisk.
  ///
  /// In pl, this message translates to:
  /// **'Błąd położenia budynku może naruszyć odległości projektowe i granice działki.'**
  String get checklistSurveyorBuildingSetoutRisk;

  /// No description provided for @checklistSiteRoadPowerWater.
  ///
  /// In pl, this message translates to:
  /// **'Droga, prąd i woda na budowę'**
  String get checklistSiteRoadPowerWater;

  /// No description provided for @checklistSiteRoadPowerWaterRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak mediów lub dojazdu zatrzyma ekipy i dostawy ciężkich materiałów.'**
  String get checklistSiteRoadPowerWaterRisk;

  /// No description provided for @checklistExcavationFoundationLevels.
  ///
  /// In pl, this message translates to:
  /// **'Poziomy wykopu, ław i posadowienia'**
  String get checklistExcavationFoundationLevels;

  /// No description provided for @checklistExcavationFoundationLevelsRisk.
  ///
  /// In pl, this message translates to:
  /// **'Błędna rzędna wpływa na wysokość budynku, spadki i odwodnienie działki.'**
  String get checklistExcavationFoundationLevelsRisk;

  /// No description provided for @checklistUnderSlabSewerAndRisers.
  ///
  /// In pl, this message translates to:
  /// **'Kanalizacja podposadzkowa i piony'**
  String get checklistUnderSlabSewerAndRisers;

  /// No description provided for @checklistUnderSlabSewerAndRisersRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak lub zła lokalizacja podejść wymaga kucia posadzki i fundamentu.'**
  String get checklistUnderSlabSewerAndRisersRisk;

  /// No description provided for @checklistWaterPenetration.
  ///
  /// In pl, this message translates to:
  /// **'Przepust wody'**
  String get checklistWaterPenetration;

  /// No description provided for @checklistWaterPenetrationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Późniejsze wykonanie przepustu może uszkodzić hydroizolację i konstrukcję.'**
  String get checklistWaterPenetrationRisk;

  /// No description provided for @checklistPowerPenetration.
  ///
  /// In pl, this message translates to:
  /// **'Przepust prądu'**
  String get checklistPowerPenetration;

  /// No description provided for @checklistPowerPenetrationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak trasy zasilania oznacza wiercenie w gotowym fundamencie.'**
  String get checklistPowerPenetrationRisk;

  /// No description provided for @checklistTelecomPenetration.
  ///
  /// In pl, this message translates to:
  /// **'Przepust internetu i teletechniki'**
  String get checklistTelecomPenetration;

  /// No description provided for @checklistTelecomPenetrationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Bez rezerwy operator może poprowadzić kabel po elewacji lub przez część mieszkalną.'**
  String get checklistTelecomPenetrationRisk;

  /// No description provided for @checklistGasPenetration.
  ///
  /// In pl, this message translates to:
  /// **'Przepust gazu, jeżeli dotyczy'**
  String get checklistGasPenetration;

  /// No description provided for @checklistGasPenetrationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak uzgodnionego przepustu utrudni wykonanie przyłącza zgodnie z projektem.'**
  String get checklistGasPenetrationRisk;

  /// No description provided for @checklistGateIntercomGardenReserve.
  ///
  /// In pl, this message translates to:
  /// **'Rezerwa do bramy, domofonu i ogrodu'**
  String get checklistGateIntercomGardenReserve;

  /// No description provided for @checklistGateIntercomGardenReserveRisk.
  ///
  /// In pl, this message translates to:
  /// **'Później potrzebne będą wykopy w gotowym podjeździe i ogrodzie.'**
  String get checklistGateIntercomGardenReserveRisk;

  /// No description provided for @checklistHeatPumpOutdoorReserve.
  ///
  /// In pl, this message translates to:
  /// **'Rezerwa do pompy ciepła i jednostek zewnętrznych'**
  String get checklistHeatPumpOutdoorReserve;

  /// No description provided for @checklistHeatPumpOutdoorReserveRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak zasilania i tras instalacyjnych ograniczy miejsce urządzeń albo wymusi przeróbki.'**
  String get checklistHeatPumpOutdoorReserveRisk;

  /// No description provided for @checklistFoundationGrounding.
  ///
  /// In pl, this message translates to:
  /// **'Bednarka i uziom fundamentowy'**
  String get checklistFoundationGrounding;

  /// No description provided for @checklistFoundationGroundingRisk.
  ///
  /// In pl, this message translates to:
  /// **'Po betonowaniu nie da się poprawić ciągłości i połączeń uziomu fundamentowego.'**
  String get checklistFoundationGroundingRisk;

  /// No description provided for @checklistContinuityMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Pomiar ciągłości przed betonowaniem'**
  String get checklistContinuityMeasurement;

  /// No description provided for @checklistContinuityMeasurementRisk.
  ///
  /// In pl, this message translates to:
  /// **'Niewykryta przerwa w uziomie pozostanie ukryta w konstrukcji.'**
  String get checklistContinuityMeasurementRisk;

  /// No description provided for @checklistWaterproofing.
  ///
  /// In pl, this message translates to:
  /// **'Izolacje poziome, pionowe i hydroizolacje'**
  String get checklistWaterproofing;

  /// No description provided for @checklistWaterproofingRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieszczelności mogą powodować trwałe zawilgocenie ścian i podłogi.'**
  String get checklistWaterproofingRisk;

  /// No description provided for @checklistDrainage.
  ///
  /// In pl, this message translates to:
  /// **'Odwodnienie i drenaż, jeżeli wynika z projektu'**
  String get checklistDrainage;

  /// No description provided for @checklistDrainageRisk.
  ///
  /// In pl, this message translates to:
  /// **'Woda przy fundamencie zwiększa ryzyko przecieków i uszkodzeń izolacji.'**
  String get checklistDrainageRisk;

  /// No description provided for @checklistConcealedWorksPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia zbrojenia, przepustów i uziomu przed zakryciem'**
  String get checklistConcealedWorksPhotos;

  /// No description provided for @checklistConcealedWorksPhotosRisk.
  ///
  /// In pl, this message translates to:
  /// **'Po zasypaniu nie będzie wiadomo, gdzie przebiegają instalacje i jak wykonano elementy ukryte.'**
  String get checklistConcealedWorksPhotosRisk;

  /// No description provided for @checklistConcreteDeliveryAndAcceptance.
  ///
  /// In pl, this message translates to:
  /// **'Dokument WZ betonu i protokół odbioru'**
  String get checklistConcreteDeliveryAndAcceptance;

  /// No description provided for @checklistConcreteDeliveryAndAcceptanceRisk.
  ///
  /// In pl, this message translates to:
  /// **'Bez dokumentów trudno potwierdzić klasę betonu, dostawę i odbiór robót.'**
  String get checklistConcreteDeliveryAndAcceptanceRisk;

  /// No description provided for @checklistPostFoundationSurvey.
  ///
  /// In pl, this message translates to:
  /// **'Inwentaryzacja po wykonaniu fundamentów'**
  String get checklistPostFoundationSurvey;

  /// No description provided for @checklistPostFoundationSurveyRisk.
  ///
  /// In pl, this message translates to:
  /// **'Odchyłki położenia mogą ujawnić się dopiero przy kolejnych etapach lub odbiorze.'**
  String get checklistPostFoundationSurveyRisk;

  /// No description provided for @guidancePlanningAndGroundConditionsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Plan miejscowy, mapa i grunt'**
  String get guidancePlanningAndGroundConditionsTitle;

  /// No description provided for @guidancePlanningAndGroundConditionsTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed ostatecznym wyborem lub adaptacją projektu i posadowienia'**
  String get guidancePlanningAndGroundConditionsTiming;

  /// No description provided for @guidancePlanningAndGroundConditionsSummary.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw potwierdź w gminie aktualną podstawę planistyczną dla działki: MPZP albo potrzebę uzyskania WZ. Mapa i wyniki rozpoznania gruntu powinny trafić do projektanta adaptującego i konstruktora, zanim zaprojektują płytę, ławy albo inne posadowienie. Kierownik budowy realizuje zatwierdzony projekt, nie zastępuje projektanta konstrukcji.'**
  String get guidancePlanningAndGroundConditionsSummary;

  /// No description provided for @guidancePlanningAndGroundConditionsChecks.
  ///
  /// In pl, this message translates to:
  /// **'Pobierz aktualne ustalenia MPZP albo potwierdź tryb uzyskania WZ i wymagane załączniki.\nSprawdź tytuł prawny, dostęp do drogi oraz ograniczenia widoczne w dokumentach działki.\nZleć mapę do celów projektowych uprawnionemu geodecie.\nUzgodnij z projektantem zakres rozpoznania geotechnicznego i przekaż wyniki projektantowi konstrukcji przed doborem posadowienia.\nPrzed robotami ziemnymi przekaż kierownikowi zatwierdzony projekt i opinię geotechniczną; rozbieżności ujawnione w wykopie konsultuj z projektantem przed dalszymi pracami.'**
  String get guidancePlanningAndGroundConditionsChecks;

  /// No description provided for @guidancePlanningAndGroundConditionsQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy urząd potwierdził aktualną ścieżkę planistyczną dla tej działki?\nCzy mapa obejmuje potrzebny teren i uzbrojenie?\nCzy projektant konstrukcji otrzymał wyniki badań przed doborem płyty, ław lub innego posadowienia?\nCo zrobić, jeśli warunki w wykopie różnią się od rozpoznanych?'**
  String get guidancePlanningAndGroundConditionsQuestions;

  /// No description provided for @guidanceDesignUtilitiesAndApprovalsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Spójny projekt i zgody'**
  String get guidanceDesignUtilitiesAndApprovalsTitle;

  /// No description provided for @guidanceDesignUtilitiesAndApprovalsTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed złożeniem wniosku lub zgłoszenia i przed zamówieniem robót'**
  String get guidanceDesignUtilitiesAndApprovalsTiming;

  /// No description provided for @guidanceDesignUtilitiesAndApprovalsSummary.
  ///
  /// In pl, this message translates to:
  /// **'Projekt gotowy wymaga adaptacji do działki. Warunki przyłączenia i projekty branżowe skoordynuj z architekturą oraz konstrukcją, a właściwy tryb pozwolenia albo zgłoszenia potwierdź dla konkretnej inwestycji.'**
  String get guidanceDesignUtilitiesAndApprovalsSummary;

  /// No description provided for @guidanceDesignUtilitiesAndApprovalsChecks.
  ///
  /// In pl, this message translates to:
  /// **'Porównaj projekt z MPZP albo WZ, mapą, geotechniką i warunkami przyłączenia.\nZbierz uzgodnione rozwiązania prądu, wody, kanalizacji, gazu i teletechniki.\nSprawdź komplet projektu zagospodarowania działki, projektu architektoniczno-budowlanego i wymaganej dokumentacji technicznej.\nUżyj aktualnego formularza GUNB i sprawdź, czy potrzebne są dodatkowe decyzje lub uzgodnienia.'**
  String get guidanceDesignUtilitiesAndApprovalsChecks;

  /// No description provided for @guidanceDesignUtilitiesAndApprovalsQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy adaptujący projektant potwierdził komplet i zgodność wszystkich branż?\nCzy każde przyłącze ma ustaloną trasę, punkt wejścia i odpowiedzialnego wykonawcę?\nCzy urząd wskazał dodatkowe załączniki właściwe dla lokalizacji?'**
  String get guidanceDesignUtilitiesAndApprovalsQuestions;

  /// No description provided for @guidanceLegalConstructionStartTitle.
  ///
  /// In pl, this message translates to:
  /// **'Legalny start budowy'**
  String get guidanceLegalConstructionStartTitle;

  /// No description provided for @guidanceLegalConstructionStartTiming.
  ///
  /// In pl, this message translates to:
  /// **'Zanim rozpoczną się roboty przygotowawcze na działce'**
  String get guidanceLegalConstructionStartTiming;

  /// No description provided for @guidanceLegalConstructionStartSummary.
  ///
  /// In pl, this message translates to:
  /// **'Zagospodarowanie terenu budowy, obiekty tymczasowe, przyłącza i wytyczenie geodezyjne mogą stanowić rozpoczęcie budowy. Najpierw zapewnij skuteczną podstawę realizacji, kierownika, dziennik i wymagane zawiadomienie o rozpoczęciu robót.'**
  String get guidanceLegalConstructionStartSummary;

  /// No description provided for @guidanceLegalConstructionStartChecks.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź z kierownikiem, że pozwolenie jest wykonalne albo zgłoszenie pozwala rozpocząć roboty.\nUstal kierownika budowy i uzyskaj wymagane oświadczenia.\nZałóż właściwy dziennik budowy: papierowy albo elektroniczny.\nZłóż aktualne zawiadomienie o rozpoczęciu robót wraz z wymaganymi załącznikami.\nPrzekaż kierownikowi zatwierdzony projekt, dokumentację techniczną, decyzje i warunki przyłączy.'**
  String get guidanceLegalConstructionStartChecks;

  /// No description provided for @guidanceLegalConstructionStartQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy kierownik pisemnie potwierdził gotowość do przejęcia budowy?\nCzy zawiadomienie obejmuje właściwy organ i komplet załączników?\nCzy na budowie jest aktualna dokumentacja do kontroli i prowadzenia robót?'**
  String get guidanceLegalConstructionStartQuestions;

  /// No description provided for @guidanceSiteLogisticsAndAccessTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dojazd i logistyka placu'**
  String get guidanceSiteLogisticsAndAccessTitle;

  /// No description provided for @guidanceSiteLogisticsAndAccessTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed pierwszą dostawą, koparką i ustawieniem zaplecza'**
  String get guidanceSiteLogisticsAndAccessTiming;

  /// No description provided for @guidanceSiteLogisticsAndAccessSummary.
  ///
  /// In pl, this message translates to:
  /// **'Tymczasowe ogrodzenie, szeroka brama dla pojazdów, utwardzony wjazd oraz bezpiecznie ustawiony blaszak lub kontener tworzą podstawę sprawnej logistyki. Wymiary przejazdu i nośność trasy dobierz do rzeczywistego ciężkiego sprzętu, nie do jednej uniwersalnej liczby.'**
  String get guidanceSiteLogisticsAndAccessSummary;

  /// No description provided for @guidanceSiteLogisticsAndAccessChecks.
  ///
  /// In pl, this message translates to:
  /// **'Zabezpiecz teren tymczasowym ogrodzeniem o wysokości co najmniej 1,5 m albo innym rozwiązaniem dopuszczonym przez przepisy, gdy ogrodzenie nie jest możliwe.\nZaplanuj szeroką bramę dla pojazdów oraz osobne, bezpieczne wejście piesze.\nUzgodnij szerokość, wysokość przejazdu, promień skrętu i nośność utwardzonego wjazdu z dostawcą betonu, pompą, HDS-em i innym planowanym sprzętem.\nSprawdź uzbrojenie podziemne, odwodnienie oraz formalności istniejącego lub tymczasowego zjazdu z drogi.\nUstaw blaszak lub kontener na stabilnym podłożu, poza drogami transportowymi, wykopem i strefami niebezpiecznymi; zapewnij zamknięcie i wentylację.\nPrzed ustawieniem zaplecza potwierdź z projektantem lub urzędem, czy sposób i czas użytkowania wymagają dodatkowej formalności.'**
  String get guidanceSiteLogisticsAndAccessChecks;

  /// No description provided for @guidanceSiteLogisticsAndAccessQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy betoniarka, pompa, HDS lub dźwig wjadą i wyjadą bez cofania w niebezpieczną strefę?\nCzy podłoże wytrzyma ruch po deszczu i umożliwi oczyszczenie kół przed wyjazdem?\nCzy brama, blaszak i składowiska nie kolidują z przyłączami ani docelowym zagospodarowaniem?\nKto codziennie sprawdza ogrodzenie, zamknięcie bramy i porządek dróg?'**
  String get guidanceSiteLogisticsAndAccessQuestions;

  /// No description provided for @guidanceTemporaryUtilitiesAndFacilitiesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prąd, woda i zaplecze'**
  String get guidanceTemporaryUtilitiesAndFacilitiesTitle;

  /// No description provided for @guidanceTemporaryUtilitiesAndFacilitiesTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed uruchomieniem elektronarzędzi i stałej pracy ekip'**
  String get guidanceTemporaryUtilitiesAndFacilitiesTiming;

  /// No description provided for @guidanceTemporaryUtilitiesAndFacilitiesSummary.
  ///
  /// In pl, this message translates to:
  /// **'Tymczasowe instalacje są częścią organizacji bezpiecznej budowy. Zasilanie powinien przygotować i sprawdzić uprawniony elektryk, a woda i toaleta muszą odpowiadać rzeczywistemu składowi ekip oraz zakresowi robót.'**
  String get guidanceTemporaryUtilitiesAndFacilitiesSummary;

  /// No description provided for @guidanceTemporaryUtilitiesAndFacilitiesChecks.
  ///
  /// In pl, this message translates to:
  /// **'Ustal legalny punkt poboru, moc i trasę zasilania bez kabli leżących w przejeździe lub wodzie.\nZleć elektrykowi rozdzielnicę, ochronę przeciwporażeniową, uziemienie i wymagane pomiary.\nZapewnij wodę do robót oraz osobno wodę zdatną do picia, jeśli źródło techniczne jej nie gwarantuje.\nUstaw i regularnie serwisuj toaletę w dostępnym, stabilnym miejscu.\nOznacz istniejące sieci i zabezpiecz punkty poboru przed uszkodzeniem oraz dostępem osób postronnych.'**
  String get guidanceTemporaryUtilitiesAndFacilitiesChecks;

  /// No description provided for @guidanceTemporaryUtilitiesAndFacilitiesQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy protokół instalacji tymczasowej i zabezpieczenia są aktualne?\nCzy zapas mocy wystarczy dla planowanego sprzętu?\nKto odpowiada za wodę, opróżnianie toalety i porządek zaplecza?'**
  String get guidanceTemporaryUtilitiesAndFacilitiesQuestions;

  /// No description provided for @guidanceSiteSafetyAndEvidenceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Bezpieczeństwo i stan początkowy'**
  String get guidanceSiteSafetyAndEvidenceTitle;

  /// No description provided for @guidanceSiteSafetyAndEvidenceTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed przekazaniem placu ekipie i przed pierwszym wykopem'**
  String get guidanceSiteSafetyAndEvidenceTiming;

  /// No description provided for @guidanceSiteSafetyAndEvidenceSummary.
  ///
  /// In pl, this message translates to:
  /// **'Kierownik organizuje zabezpieczenie terenu i ocenia obowiązki dotyczące planu BIOZ oraz tablicy informacyjnej. Zdjęcia stanu początkowego pomagają później rozstrzygać uszkodzenia drogi, granic i sąsiedniego terenu.'**
  String get guidanceSiteSafetyAndEvidenceSummary;

  /// No description provided for @guidanceSiteSafetyAndEvidenceChecks.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz granice, uzbrojenie, strefy niebezpieczne, wykopy i miejsca o ograniczonym dostępie.\nPotwierdź z kierownikiem wymagane zabezpieczenia, plan BIOZ, tablicę informacyjną i instrukcje dla ekip.\nZapewnij oświetlenie, dojścia, porządek oraz bezpieczne magazynowanie materiałów i odpadów.\nWykonaj datowane zdjęcia drogi, zjazdu, ogrodzeń, punktów granicznych, zieleni i istniejących sieci.\nZapisz odbiór placu i osoby odpowiedzialne za codzienną kontrolę zabezpieczeń.'**
  String get guidanceSiteSafetyAndEvidenceChecks;

  /// No description provided for @guidanceSiteSafetyAndEvidenceQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy każda ekipa zna zasady ruchu, składowania i zgłaszania zagrożeń?\nCzy zdjęcia pokazują skalę, lokalizację i cały obszar możliwych uszkodzeń?\nKto kontroluje ogrodzenie, rozdzielnicę i strefy niebezpieczne po pracy?'**
  String get guidanceSiteSafetyAndEvidenceQuestions;

  /// No description provided for @guidanceServicePenetrationsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przepusty i instalacje przed betonowaniem'**
  String get guidanceServicePenetrationsTitle;

  /// No description provided for @guidanceServicePenetrationsTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed zbrojeniem, szalowaniem i betonowaniem ław lub płyty'**
  String get guidanceServicePenetrationsTiming;

  /// No description provided for @guidanceServicePenetrationsSummary.
  ///
  /// In pl, this message translates to:
  /// **'Zbierz elektryka, instalatora sanitarnego i konstruktora nad jednym rysunkiem przejść. Po betonowaniu brakująca trasa zwykle oznacza przewiert przez konstrukcję lub hydroizolację.'**
  String get guidanceServicePenetrationsSummary;

  /// No description provided for @guidanceServicePenetrationsChecks.
  ///
  /// In pl, this message translates to:
  /// **'Ustal osie, rzędne, średnice i sposób uszczelnienia z projektów branżowych.\nSprawdź kanalizację, wodę, prąd, teletechnikę oraz rezerwy do bramy, domofonu, ogrodu, pompy ciepła, PV i ładowarki auta.\nZweryfikuj spadki kanalizacji, miejsca pionów, rewizji i pierwszej studzienki.\nZabezpiecz i oznacz tuleje przed przesunięciem oraz dostaniem się betonu.\nZrób zdjęcia z miarą i odniesieniem do stałych osi budynku przed zakryciem.'**
  String get guidanceServicePenetrationsChecks;

  /// No description provided for @guidanceServicePenetrationsQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy wszystkie branże zatwierdziły wspólny rysunek przejść?\nKtóre przepusty mają być wodo- lub gazoszczelne?\nCzy później da się wymienić kabel bez kucia?\nJak przejście zachowa ciągłość hydroizolacji i nie osłabi zbrojenia?'**
  String get guidanceServicePenetrationsQuestions;

  /// No description provided for @guidanceFoundationGroundingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Uziom fundamentowy bez zgadywania'**
  String get guidanceFoundationGroundingTitle;

  /// No description provided for @guidanceFoundationGroundingTiming.
  ///
  /// In pl, this message translates to:
  /// **'Projekt przed zbrojeniem; odbiór przed betonowaniem; pomiar po wykonaniu układu'**
  String get guidanceFoundationGroundingTiming;

  /// No description provided for @guidanceFoundationGroundingSummary.
  ///
  /// In pl, this message translates to:
  /// **'Nie istnieje jedna właściwa bednarka, liczba szpilek ani uniwersalna rezystancja dla każdego domu. Projektant instalacji elektrycznej dobiera układ do ochrony przeciwporażeniowej, fundamentu i gruntu, a przy LPS także do PN-EN IEC 62305-3. Po wykonaniu fundamentu można zaprojektować uziom otokowy lub pionowe elektrody uziemiające, lecz nie zastępuje to projektu i pomiarów.'**
  String get guidanceFoundationGroundingSummary;

  /// No description provided for @guidanceFoundationGroundingChecks.
  ///
  /// In pl, this message translates to:
  /// **'Przed betonowaniem potwierdź projekt uziomu fundamentowego: przebieg, materiał, przekrój, połączenia ze zbrojeniem, wypusty i ochronę przed korozją.\nSprawdź, czy fundament zachowa trwały kontakt elektryczny z gruntem. Przy pełnej izolacji obwodowej, płycie izolowanej lub betonie wodoszczelnym projekt może wymagać uziomu otokowego w gruncie oraz przewodu wyrównania potencjałów w fundamencie.\nJeżeli fundament jest już wykonany, projektant może dobrać zamknięty uziom otokowy albo uziomy pionowe, nazywane szpilkami. Ich materiał, długość, liczba i rozstaw wynikają z warunków gruntu, ryzyka korozji, funkcji układu i wyników pomiarów.\nUstal połączenie z główną szyną uziemiającą oraz wypusty dla LPS, PV i innych projektowanych instalacji. Użyj elementów połączeniowych i uziomów o potwierdzonej zgodności z właściwym środowiskiem pracy.\nPrzed betonowaniem wykonaj oględziny, zdjęcia z miarą i sprawdzenie ciągłości. Po ukończeniu układu zleć pomiary oraz protokół; kryterium odbioru wynika z projektu i zastosowanego środka ochrony, nie z jednej liczby znalezionej w internecie.'**
  String get guidanceFoundationGroundingChecks;

  /// No description provided for @guidanceFoundationGroundingQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Jaką funkcję ma pełnić układ: ochronną, funkcjonalną, odgromową czy kilka naraz?\nCzy hydroizolacja, termoizolacja lub beton wodoszczelny odizolują fundament od gruntu?\nCzy projekt przewiduje uziom fundamentowy, otokowy, pionowy lub układ łączony i na jakiej podstawie?\nGdzie będą główna szyna uziemiająca, wypusty i dostępne złącza kontrolne?\nKto wykona odbiór przed betonowaniem, pomiary końcowe i podpisze protokół?'**
  String get guidanceFoundationGroundingQuestions;

  /// No description provided for @guidanceFoundationWaterproofingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Hydroizolacja dobrana do wody, nie do nazwy produktu'**
  String get guidanceFoundationWaterproofingTitle;

  /// No description provided for @guidanceFoundationWaterproofingTiming.
  ///
  /// In pl, this message translates to:
  /// **'Po rozpoznaniu warunków gruntowo-wodnych, przed zakupem materiałów i zasypaniem'**
  String get guidanceFoundationWaterproofingTiming;

  /// No description provided for @guidanceFoundationWaterproofingSummary.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw określ obciążenie wodą i oczekiwaną zdolność mostkowania rys. Dysperbit może być gruntem lub powłoką przeciwwilgociową zgodnie z kartą konkretnego produktu, lecz nie należy zakładać, że zastąpi izolację przeciwwodną przy naporze wody. KMB/PMBC 2K także musi być dobrane i wykonane jako kompletny system.'**
  String get guidanceFoundationWaterproofingSummary;

  /// No description provided for @guidanceFoundationWaterproofingChecks.
  ///
  /// In pl, this message translates to:
  /// **'Oprzyj rozwiązanie na geotechnice, maksymalnym poziomie wody i projekcie hydroizolacji.\nSprawdź przeznaczenie produktu, deklarację właściwości, wymaganą suchą grubość, liczbę cykli i czas wysychania.\nDopracuj podłoże, fasety, naroża, połączenie izolacji poziomej z pionową oraz każde przejście instalacyjne.\nPo odbiorze hydroizolacji zastosuj kompatybilne mocowanie XPS lub innej termoizolacji i warstwę ochronną przewidzianą w systemie.\nNie przebijaj powłoki mocowaniem i nie zasypuj jej przed wymaganym utwardzeniem.'**
  String get guidanceFoundationWaterproofingChecks;

  /// No description provided for @guidanceFoundationWaterproofingQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy występuje tylko wilgoć gruntowa, woda zalegająca czy parcie hydrostatyczne?\nJaka jest minimalna grubość suchej warstwy i jak będzie kontrolowana?\nCzy klej, XPS i membrana ochronna są zgodne z wybraną masą?\nKto odbierze detale przed ich zakryciem?'**
  String get guidanceFoundationWaterproofingQuestions;

  /// No description provided for @guidanceDrainageAndGroundLevelsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Drenaż, odpływ i docelowe poziomy terenu'**
  String get guidanceDrainageAndGroundLevelsTitle;

  /// No description provided for @guidanceDrainageAndGroundLevelsTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed zasypaniem fundamentów i wykonaniem docelowego terenu'**
  String get guidanceDrainageAndGroundLevelsTiming;

  /// No description provided for @guidanceDrainageAndGroundLevelsSummary.
  ///
  /// In pl, this message translates to:
  /// **'Drenaż nie jest automatycznym dodatkiem do każdego domu. Musi wynikać z warunków wodnych i projektu oraz mieć legalne, drożne miejsce odprowadzenia. Folia kubełkowa może pełnić funkcję ochronną lub drenażową w danym systemie, ale sama nie jest hydroizolacją.'**
  String get guidanceDrainageAndGroundLevelsSummary;

  /// No description provided for @guidanceDrainageAndGroundLevelsChecks.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź zasadność drenażu, poziomy, spadki, obsypkę, studzienki i możliwość czyszczenia.\nUstal odbiornik wody oraz zabezpieczenie przed cofaniem i zamuleniem.\nSprawdź docelowe rzędne tarasów, podjazdu i gruntu przy cokole.\nZaplanuj swobodny spływ wody opadowej od budynku.\nChroń hydroizolację podczas zasypywania zgodnie z wybranym systemem.'**
  String get guidanceDrainageAndGroundLevelsChecks;

  /// No description provided for @guidanceDrainageAndGroundLevelsQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Dokąd woda ma odpływać i czy jest na to zgoda?\nCzy drenaż może działać grawitacyjnie przez cały rok?\nJak będzie kontrolowany i czyszczony?\nCzy docelowe poziomy nie zasłonią cokołu ani wejść do budynku?'**
  String get guidanceDrainageAndGroundLevelsQuestions;

  /// No description provided for @guidanceConcealedWorksEvidenceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odbiór i zdjęcia zanim beton lub grunt wszystko zakryje'**
  String get guidanceConcealedWorksEvidenceTitle;

  /// No description provided for @guidanceConcealedWorksEvidenceTiming.
  ///
  /// In pl, this message translates to:
  /// **'Bezpośrednio przed każdym betonowaniem, zasypaniem lub zakryciem'**
  String get guidanceConcealedWorksEvidenceTiming;

  /// No description provided for @guidanceConcealedWorksEvidenceSummary.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia bez skali i lokalizacji są mało użyteczne. Udokumentuj elementy ukryte tak, aby po latach można było znaleźć trasę, połączenie i punkt przejścia bez zgadywania.'**
  String get guidanceConcealedWorksEvidenceSummary;

  /// No description provided for @guidanceConcealedWorksEvidenceChecks.
  ///
  /// In pl, this message translates to:
  /// **'Zrób ujęcie ogólne i zbliżenia z miarą oraz odniesieniem do osi lub narożnika.\nFotografuj zbrojenie, uziom, wypusty, przepusty, kanalizację, detale hydroizolacji i naprawy.\nZapisz odbiór kierownika lub branżysty oraz wymagane protokoły i wyniki prób.\nZachowaj dokument WZ betonu i potwierdzenie jego parametrów.\nPo wykonaniu fundamentów dołącz inwentaryzację geodezyjną.'**
  String get guidanceConcealedWorksEvidenceChecks;

  /// No description provided for @guidanceConcealedWorksEvidenceQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy ze zdjęć da się odtworzyć dokładne położenie elementu?\nCzy wymagane próby i pomiary mają podpisany protokół?\nCzy kierownik zaakceptował roboty przed zgodą na zakrycie?'**
  String get guidanceConcealedWorksEvidenceQuestions;

  /// No description provided for @guidanceStructuralShellChecksTitle.
  ///
  /// In pl, this message translates to:
  /// **'Konstrukcja przed betonem i zakryciem'**
  String get guidanceStructuralShellChecksTitle;

  /// No description provided for @guidanceStructuralShellChecksTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed każdym betonowaniem, zakryciem połączeń i usunięciem podpór'**
  String get guidanceStructuralShellChecksTiming;

  /// No description provided for @guidanceStructuralShellChecksSummary.
  ///
  /// In pl, this message translates to:
  /// **'Odbieraj elementy konstrukcyjne według projektu przed ich zakryciem. Nie istnieje jedna liczba dni, po której zawsze wolno rozszalować strop: decydują projekt, technologia, warunki dojrzewania i osiągnięta wytrzymałość.'**
  String get guidanceStructuralShellChecksSummary;

  /// No description provided for @guidanceStructuralShellChecksChecks.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź zbrojenie, otuliny, deskowanie, przepusty, kotwy i elementy osadzane przed betonowaniem.\nPorównaj z projektem geometrię ścian, stropów, otworów, nadproży, wieńców, schodów i konstrukcji dachu.\nPotwierdź stateczność tymczasową, stężenia i sposób podparcia; nie zmieniaj otworów ani elementów nośnych bez projektanta.\nZabezpiecz świeży beton i mur zgodnie z projektem, pogodą i instrukcją zastosowanej technologii.\nZapisz odbiór robót zanikających i wykonaj zdjęcia z miarą przed zakryciem.'**
  String get guidanceStructuralShellChecksChecks;

  /// No description provided for @guidanceStructuralShellChecksQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy kierownik odebrał element przed betonowaniem lub zakryciem?\nCzy wszystkie otwory i przepusty są zgodne ze skoordynowanymi projektami branżowymi?\nNa jakiej podstawie ustalono termin usunięcia podpór?\nCzy zmiana wykonawcza ma akceptację właściwego projektanta?'**
  String get guidanceStructuralShellChecksQuestions;

  /// No description provided for @guidanceRoofAndWeatherProtectionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dach i ochrona stanu otwartego przed wodą'**
  String get guidanceRoofAndWeatherProtectionTitle;

  /// No description provided for @guidanceRoofAndWeatherProtectionTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed pierwszym opadem i przed zakryciem każdej warstwy dachu'**
  String get guidanceRoofAndWeatherProtectionTiming;

  /// No description provided for @guidanceRoofAndWeatherProtectionSummary.
  ///
  /// In pl, this message translates to:
  /// **'Pokrycie jest częścią zaprojektowanego przekrycia dachowego. Szczelność zależy także od podłoża, warstwy wstępnego krycia, obróbek, przejść, odwodnienia i montażu zgodnego z wybranym systemem.'**
  String get guidanceRoofAndWeatherProtectionSummary;

  /// No description provided for @guidanceRoofAndWeatherProtectionChecks.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź podłoże, spadki, warstwę wstępnego krycia i wymagane szczeliny wentylacyjne przed pokryciem.\nOdbierz obróbki kominów, okien dachowych, koszy, kalenicy, okapu i wszystkich przejść instalacyjnych.\nZapewnij drożne odwodnienie oraz kontrolowany odpływ z dala od niezabezpieczonych ścian i fundamentów.\nZabezpieczaj tymczasowo otwory i przerwane roboty przed opadem oraz silnym wiatrem.\nUdokumentuj warstwy ukryte i użyte materiały przed ich zakryciem.'**
  String get guidanceRoofAndWeatherProtectionChecks;

  /// No description provided for @guidanceRoofAndWeatherProtectionQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy detal każdego przejścia pochodzi z projektu i instrukcji wybranego systemu?\nDokąd odpłynie woda podczas budowy i po wykonaniu rynien?\nCzy połączenia będą dostępne do kontroli przed ociepleniem lub zabudową?\nKto odbiera pokrycie i obróbki przed zamknięciem kolejnych warstw?'**
  String get guidanceRoofAndWeatherProtectionQuestions;

  /// No description provided for @guidanceWindowShadingPreparationTitle.
  ///
  /// In pl, this message translates to:
  /// **'Detal nadproża pod rolety lub żaluzje'**
  String get guidanceWindowShadingPreparationTitle;

  /// No description provided for @guidanceWindowShadingPreparationTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed wykonaniem nadproży, zamówieniem okien i zamknięciem projektu elewacji'**
  String get guidanceWindowShadingPreparationTiming;

  /// No description provided for @guidanceWindowShadingPreparationSummary.
  ///
  /// In pl, this message translates to:
  /// **'Nie ma uniwersalnego cofnięcia o 5 cm. Potrzebna wnęka zależy od wybranego systemu, wymiaru skrzynki, pakietu lameli, prowadnic, położenia okna, ocieplenia i konstrukcji nadproża.'**
  String get guidanceWindowShadingPreparationSummary;

  /// No description provided for @guidanceWindowShadingPreparationChecks.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz typ osłony i konkretny system dla każdego otworu.\nUzyskaj detal z wymiarami skrzynki, wnęki, prowadnic, mocowań i dostępu serwisowego.\nUzgodnij detal z architektem i konstruktorem przed zmianą geometrii nadproża.\nSprawdź ciągłość ocieplenia, szczelność połączenia okna oraz ryzyko mostka cieplnego.\nDoprowadź zasilanie i sterowanie do właściwej strony, zachowując dostęp do napędu.'**
  String get guidanceWindowShadingPreparationChecks;

  /// No description provided for @guidanceWindowShadingPreparationQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Roleta czy żaluzja fasadowa i w jakim systemie zabudowy?\nJakie są rzeczywiste wymiary skrzynki i pakietu dla tego okna?\nGdzie będzie rewizja serwisowa, przewód i napęd?\nCzy detal nie osłabia nadproża i mieści projektowaną grubość elewacji?'**
  String get guidanceWindowShadingPreparationQuestions;

  /// No description provided for @guidanceWindowDoorInstallationTitle.
  ///
  /// In pl, this message translates to:
  /// **'Stolarka: podparcie, mocowanie i szczelność'**
  String get guidanceWindowDoorInstallationTitle;

  /// No description provided for @guidanceWindowDoorInstallationTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed zamówieniem stolarki, montażem i zakryciem złączy'**
  String get guidanceWindowDoorInstallationTiming;

  /// No description provided for @guidanceWindowDoorInstallationSummary.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź parametry wyrobu oraz indywidualny detal montażu do muru, progu i elewacji. Sama piana nie zastępuje mechanicznego mocowania ani kompletnego uszczelnienia zaprojektowanego połączenia.'**
  String get guidanceWindowDoorInstallationSummary;

  /// No description provided for @guidanceWindowDoorInstallationChecks.
  ///
  /// In pl, this message translates to:
  /// **'Zmierz otwory i potwierdź poziomy gotowych posadzek, parapetów, progów, rolet i elewacji przed zamówieniem.\nDobierz położenie, podparcie, łączniki i uszczelnienie do projektu, rodzaju muru oraz instrukcji producenta stolarki i systemu montażowego.\nSprawdź mechaniczne mocowanie, stabilne podparcie, ciągłość uszczelnień i zabezpieczenie piany przed wilgocią oraz promieniowaniem UV.\nZachowaj drożność odwodnień profili, parapetów i progów; sprawdź spadki oraz zakończenia.\nPrzed zakryciem złączy sprawdź działanie skrzydeł, okucia, uszkodzenia i wykonaj zdjęcia detali.'**
  String get guidanceWindowDoorInstallationChecks;

  /// No description provided for @guidanceWindowDoorInstallationQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy zamówienie podaje uzgodnione właściwości i wymiary każdego wyrobu?\nKto przygotował detal mocowania i uszczelnienia dla tego muru oraz progu?\nCzy rolety, parapety i ocieplenie nie przerwą ciągłości połączenia?\nCzy złącze można jeszcze odebrać przed jego zakryciem?'**
  String get guidanceWindowDoorInstallationQuestions;

  /// No description provided for @guidanceClosedShellMoistureControlTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięty budynek bez uwięzionej wilgoci'**
  String get guidanceClosedShellMoistureControlTitle;

  /// No description provided for @guidanceClosedShellMoistureControlTiming.
  ///
  /// In pl, this message translates to:
  /// **'Po montażu stolarki, przed tynkami, wylewkami i szczelną zabudową'**
  String get guidanceClosedShellMoistureControlTiming;

  /// No description provided for @guidanceClosedShellMoistureControlSummary.
  ///
  /// In pl, this message translates to:
  /// **'Po zamknięciu budynku woda opadowa i wilgoć technologiczna nie mogą pozostać bez kontroli. Zapewnij szczelność zewnętrzną, odpływ wody oraz planowane wietrzenie, osuszanie i ogrzewanie zgodne z technologią robót.'**
  String get guidanceClosedShellMoistureControlSummary;

  /// No description provided for @guidanceClosedShellMoistureControlChecks.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź dach, obróbki, rynny, parapety, progi i przejścia po opadzie, zanim połączenia zostaną zabudowane.\nUsuń źródła przecieków oraz wodę stojącą; nie przykrywaj zawilgoconych przegród.\nUstal kontrolowane wietrzenie lub osuszanie podczas mokrych robót i zapisuj warunki wymagane przez materiały.\nChroń budynek przed niekontrolowanym wychłodzeniem, kondensacją i zamarzaniem świeżych warstw.\nJeżeli wymaga tego projekt, umowa lub standard energetyczny, zaplanuj badanie szczelności przed końcowym zakryciem złączy.'**
  String get guidanceClosedShellMoistureControlChecks;

  /// No description provided for @guidanceClosedShellMoistureControlQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy po deszczu widać przecieki albo wodę w progach i narożach?\nJak będzie usuwana wilgoć z tynków i wylewek?\nKtóre połączenia trzeba sprawdzić przed ich zabudową?\nCzy badanie szczelności jest wymagane i na jakim etapie będzie najbardziej użyteczne?'**
  String get guidanceClosedShellMoistureControlQuestions;

  /// No description provided for @guidanceInstallationRoutesAndAccessTitle.
  ///
  /// In pl, this message translates to:
  /// **'Koordynacja tras i dostęp serwisowy'**
  String get guidanceInstallationRoutesAndAccessTitle;

  /// No description provided for @guidanceInstallationRoutesAndAccessTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed bruzdowaniem, przewiertami, zabudową i wykonaniem posadzek'**
  String get guidanceInstallationRoutesAndAccessTiming;

  /// No description provided for @guidanceInstallationRoutesAndAccessSummary.
  ///
  /// In pl, this message translates to:
  /// **'Elektrykę, wodę, kanalizację, ogrzewanie, wentylację, internet, alarm, PV i automatykę sprawdź na jednym skoordynowanym planie. Kolizje rozwiązuj przed wykonaniem, a nie przez przypadkowe osłabianie konstrukcji.'**
  String get guidanceInstallationRoutesAndAccessSummary;

  /// No description provided for @guidanceInstallationRoutesAndAccessChecks.
  ///
  /// In pl, this message translates to:
  /// **'Uzgodnij trasy, poziomy, przejścia, strefy montażowe i odpowiedzialność każdej branży.\nNie wykonuj bruzd ani przewiertów w elementach konstrukcyjnych bez zgody właściwego projektanta.\nSprawdź rozdział instalacji, izolacje, spadki kanalizacji oraz ochronę przewodów w miejscach skrzyżowań i przejść.\nZapewnij dostęp do rozdzielaczy, zaworów, filtrów, syfonów, rewizji, urządzeń i elementów wymagających czyszczenia.\nPrzed zakryciem sfotografuj trasy z miarą i odniesieniem do stałych krawędzi pomieszczeń.'**
  String get guidanceInstallationRoutesAndAccessChecks;

  /// No description provided for @guidanceInstallationRoutesAndAccessQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy wszystkie branże pracują na aktualnej, wspólnej wersji rysunków?\nKtóre elementy muszą pozostać dostępne po wykończeniu?\nCzy przewiert lub bruzda ma akceptację konstruktora, jeśli dotyka elementu nośnego?\nCzy zdjęcia pozwolą później bezpiecznie wiercić i serwisować instalacje?'**
  String get guidanceInstallationRoutesAndAccessQuestions;

  /// No description provided for @guidanceInstallationTestsAndEvidenceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Próby i pomiary przed zakryciem'**
  String get guidanceInstallationTestsAndEvidenceTitle;

  /// No description provided for @guidanceInstallationTestsAndEvidenceTiming.
  ///
  /// In pl, this message translates to:
  /// **'Po wykonaniu instalacji, zanim przykryją ją tynk, wylewka, izolacja lub zabudowa'**
  String get guidanceInstallationTestsAndEvidenceTiming;

  /// No description provided for @guidanceInstallationTestsAndEvidenceSummary.
  ///
  /// In pl, this message translates to:
  /// **'Każda branża ma własny zakres prób i kryteria odbioru. Nie stosuj jednego internetowego ciśnienia ani czasu do wszystkich systemów: parametry wynikają z projektu, normy właściwej dla instalacji i instrukcji użytego systemu.'**
  String get guidanceInstallationTestsAndEvidenceSummary;

  /// No description provided for @guidanceInstallationTestsAndEvidenceChecks.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj i zapisz właściwe próby szczelności instalacji wodnych, kanalizacyjnych, grzewczych i innych przewodów przed zakryciem.\nZleć osobie z wymaganymi kwalifikacjami oględziny, próby i pomiary instalacji elektrycznej wraz z protokołem.\nSprawdź obiegi ogrzewania płaszczyznowego przed wylewką, oznacz pętle i zachowaj wymagane ciśnienie robocze lub kontrolne zgodnie z systemem.\nSprawdź wentylację przed zabudową: drożność, mocowanie, izolację, dostęp do czyszczenia, a przy odbiorze także wymagane pomiary.\nDołącz zdjęcia, wyniki, datę, użyte urządzenie pomiarowe i podpis odpowiedzialnej osoby.'**
  String get guidanceInstallationTestsAndEvidenceChecks;

  /// No description provided for @guidanceInstallationTestsAndEvidenceQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Jaki dokument określa parametry próby dla tej konkretnej instalacji?\nKto ma uprawnienia lub kwalifikacje do wykonania i podpisania pomiarów?\nCzy wynik zapisano przed zakryciem oraz powiązano z właściwym obiegiem lub pomieszczeniem?\nCzy usterkę usunięto i próbę powtórzono po naprawie?'**
  String get guidanceInstallationTestsAndEvidenceQuestions;

  /// No description provided for @guidanceFinishSubstratesAndHeatingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podłoże gotowe przed wykończeniem'**
  String get guidanceFinishSubstratesAndHeatingTitle;

  /// No description provided for @guidanceFinishSubstratesAndHeatingTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed gruntowaniem, malowaniem, klejeniem płytek i układaniem podłóg'**
  String get guidanceFinishSubstratesAndHeatingTiming;

  /// No description provided for @guidanceFinishSubstratesAndHeatingSummary.
  ///
  /// In pl, this message translates to:
  /// **'Nośność, równość, czystość i wilgotność podłoża sprawdzaj metodą oraz limitem wymaganym przez konkretny podkład, klej i okładzinę. Jedna wartość procentowa nie jest poprawna dla wszystkich materiałów i metod pomiaru.'**
  String get guidanceFinishSubstratesAndHeatingSummary;

  /// No description provided for @guidanceFinishSubstratesAndHeatingChecks.
  ///
  /// In pl, this message translates to:
  /// **'Zidentyfikuj rodzaj podłoża i sprawdź jego nośność, spękania, równość, czystość oraz warunki powierzchniowe.\nZapisz pomiar wilgotności z datą, miejscem, metodą i rodzajem podkładu; porównaj wynik z wymaganiem wybranego systemu.\nPrzed montażem podłogi wykonaj wymagane uruchomienie lub wygrzewanie ogrzewania podłogowego i zachowaj protokół.\nPrzenieś przewidziane dylatacje oraz sprawdź ich zgodność z układem pomieszczeń, ogrzewaniem i formatem okładziny.\nZapewnij temperaturę, wentylację i czas dojrzewania warstw zgodne z kartami technicznymi.'**
  String get guidanceFinishSubstratesAndHeatingChecks;

  /// No description provided for @guidanceFinishSubstratesAndHeatingQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Jaką metodą zmierzono wilgotność i jaki limit podaje producent systemu?\nCzy podłoże ma pęknięcia lub dylatacje wymagające rozwiązania przed okładziną?\nCzy istnieje podpisany protokół uruchomienia ogrzewania podłogowego?\nCzy warunki w pomieszczeniu pozwalają na wykonanie i dojrzewanie wybranych materiałów?'**
  String get guidanceFinishSubstratesAndHeatingQuestions;

  /// No description provided for @guidanceWetAreaWaterproofingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie mokre jako kompletny system'**
  String get guidanceWetAreaWaterproofingTitle;

  /// No description provided for @guidanceWetAreaWaterproofingTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed klejeniem płytek i zakryciem narożników, odpływów oraz przejść'**
  String get guidanceWetAreaWaterproofingTiming;

  /// No description provided for @guidanceWetAreaWaterproofingSummary.
  ///
  /// In pl, this message translates to:
  /// **'Płytki i fuga nie są samodzielną hydroizolacją. Dobierz kompletny, kompatybilny system do podłoża i przewidywanego obciążenia wodą; sama nazwa „folia w płynie” nie potwierdza przydatności w każdym miejscu.'**
  String get guidanceWetAreaWaterproofingSummary;

  /// No description provided for @guidanceWetAreaWaterproofingChecks.
  ///
  /// In pl, this message translates to:
  /// **'Określ strefy narażone na wodę, rodzaj podłoża, ogrzewanie i wymagany zakres hydroizolacji.\nSprawdź deklarowane zastosowanie wyrobu, przygotowanie podłoża, wymaganą liczbę warstw, zużycie i czas schnięcia.\nWykonaj systemowe uszczelnienia narożników, dylatacji, odpływów, progów i wszystkich przejść instalacyjnych.\nUżyj kompatybilnych gruntów, taśm, manszet, hydroizolacji, kleju i fugi bez mieszania przypadkowych systemów.\nOdbierz i sfotografuj ciągłość izolacji przed ułożeniem płytek; wymagane próby wykonaj zgodnie z projektem i systemem.'**
  String get guidanceWetAreaWaterproofingChecks;

  /// No description provided for @guidanceWetAreaWaterproofingQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Jakie obciążenie wodą przewidziano w tej strefie?\nCzy produkt jest przeznaczony pod płytki i zgodny z podłożem oraz ogrzewaniem?\nJak rozwiązano odpływ, spadki, narożniki i przejścia rurowe?\nKto odbierze hydroizolację przed jej zakryciem?'**
  String get guidanceWetAreaWaterproofingQuestions;

  /// No description provided for @scheduleWeekTab.
  ///
  /// In pl, this message translates to:
  /// **'7 dni'**
  String get scheduleWeekTab;

  /// No description provided for @scheduleStagesTab.
  ///
  /// In pl, this message translates to:
  /// **'Etapy'**
  String get scheduleStagesTab;

  /// No description provided for @scheduleLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie planu na 7 dni'**
  String get scheduleLoading;

  /// No description provided for @scheduleLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać terminów.'**
  String get scheduleLoadError;

  /// No description provided for @scheduleEyebrow.
  ///
  /// In pl, this message translates to:
  /// **'Terminy i blokady'**
  String get scheduleEyebrow;

  /// No description provided for @schedulePreviousWeekTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Poprzednie 7 dni'**
  String get schedulePreviousWeekTooltip;

  /// No description provided for @scheduleNextWeekTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Następne 7 dni'**
  String get scheduleNextWeekTooltip;

  /// No description provided for @scheduleReminderSettingsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia przypomnień'**
  String get scheduleReminderSettingsTooltip;

  /// No description provided for @scheduleAddEventTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj termin'**
  String get scheduleAddEventTooltip;

  /// No description provided for @scheduleItemsSummary.
  ///
  /// In pl, this message translates to:
  /// **'Terminy: {count}'**
  String scheduleItemsSummary(int count);

  /// No description provided for @scheduleBlockedSummary.
  ///
  /// In pl, this message translates to:
  /// **'Blokowane: {count}'**
  String scheduleBlockedSummary(int count);

  /// No description provided for @scheduleEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak terminów w tych 7 dniach'**
  String get scheduleEmptyTitle;

  /// No description provided for @scheduleEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zadanie, wizytę, dostawę, odbiór albo płatność.'**
  String get scheduleEmptyMessage;

  /// No description provided for @scheduleTodayLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj'**
  String get scheduleTodayLabel;

  /// No description provided for @scheduleAllDayLabel.
  ///
  /// In pl, this message translates to:
  /// **'Cały dzień'**
  String get scheduleAllDayLabel;

  /// No description provided for @scheduleKindLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj'**
  String get scheduleKindLabel;

  /// No description provided for @scheduleKindTask.
  ///
  /// In pl, this message translates to:
  /// **'Zadanie'**
  String get scheduleKindTask;

  /// No description provided for @scheduleKindVisit.
  ///
  /// In pl, this message translates to:
  /// **'Wizyta'**
  String get scheduleKindVisit;

  /// No description provided for @scheduleKindDelivery.
  ///
  /// In pl, this message translates to:
  /// **'Dostawa'**
  String get scheduleKindDelivery;

  /// No description provided for @scheduleKindAcceptance.
  ///
  /// In pl, this message translates to:
  /// **'Odbiór'**
  String get scheduleKindAcceptance;

  /// No description provided for @scheduleKindPayment.
  ///
  /// In pl, this message translates to:
  /// **'Płatność'**
  String get scheduleKindPayment;

  /// No description provided for @scheduleStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get scheduleStatusLabel;

  /// No description provided for @scheduleStatusPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Planowane'**
  String get scheduleStatusPlanned;

  /// No description provided for @scheduleStatusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie'**
  String get scheduleStatusInProgress;

  /// No description provided for @scheduleStatusBlocked.
  ///
  /// In pl, this message translates to:
  /// **'Zablokowane'**
  String get scheduleStatusBlocked;

  /// No description provided for @scheduleStatusCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Zakończone'**
  String get scheduleStatusCompleted;

  /// No description provided for @scheduleStatusCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Odwołane'**
  String get scheduleStatusCancelled;

  /// No description provided for @scheduleBlockedBy.
  ///
  /// In pl, this message translates to:
  /// **'Blokuje: {title}'**
  String scheduleBlockedBy(String title);

  /// No description provided for @scheduleDecisionDue.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja do {date}'**
  String scheduleDecisionDue(String date);

  /// No description provided for @schedulePermissionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia są wyłączone'**
  String get schedulePermissionTitle;

  /// No description provided for @schedulePermissionMessage.
  ///
  /// In pl, this message translates to:
  /// **'Plan działa bez zgody. Włącz powiadomienia, aby dostawać lokalne przypomnienia.'**
  String get schedulePermissionMessage;

  /// No description provided for @schedulePermissionAction.
  ///
  /// In pl, this message translates to:
  /// **'Włącz'**
  String get schedulePermissionAction;

  /// No description provided for @scheduleSettingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia'**
  String get scheduleSettingsTitle;

  /// No description provided for @scheduleSettingsTypesHeading.
  ///
  /// In pl, this message translates to:
  /// **'Typy terminów'**
  String get scheduleSettingsTypesHeading;

  /// No description provided for @scheduleDefaultLeadLabel.
  ///
  /// In pl, this message translates to:
  /// **'Domyślne wyprzedzenie'**
  String get scheduleDefaultLeadLabel;

  /// No description provided for @scheduleAllDayTimeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Godzina dla całego dnia'**
  String get scheduleAllDayTimeLabel;

  /// No description provided for @schedulePermissionGranted.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia systemowe są włączone.'**
  String get schedulePermissionGranted;

  /// No description provided for @schedulePermissionDenied.
  ///
  /// In pl, this message translates to:
  /// **'Brak zgody systemowej. Plan nadal działa.'**
  String get schedulePermissionDenied;

  /// No description provided for @schedulePermissionUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Status powiadomień jest niedostępny.'**
  String get schedulePermissionUnavailable;

  /// No description provided for @scheduleLeadAtTime.
  ///
  /// In pl, this message translates to:
  /// **'O czasie'**
  String get scheduleLeadAtTime;

  /// No description provided for @scheduleLeadMinutes.
  ///
  /// In pl, this message translates to:
  /// **'{count} min wcześniej'**
  String scheduleLeadMinutes(int count);

  /// No description provided for @scheduleLeadHours.
  ///
  /// In pl, this message translates to:
  /// **'{count} godz. wcześniej'**
  String scheduleLeadHours(int count);

  /// No description provided for @scheduleLeadDays.
  ///
  /// In pl, this message translates to:
  /// **'{count} dni wcześniej'**
  String scheduleLeadDays(int count);

  /// No description provided for @scheduleNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy termin'**
  String get scheduleNewTitle;

  /// No description provided for @scheduleEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj termin'**
  String get scheduleEditTitle;

  /// No description provided for @scheduleTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get scheduleTitleLabel;

  /// No description provided for @scheduleTitleRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę terminu.'**
  String get scheduleTitleRequiredError;

  /// No description provided for @scheduleDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get scheduleDateLabel;

  /// No description provided for @scheduleTimeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Godzina'**
  String get scheduleTimeLabel;

  /// No description provided for @scheduleStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get scheduleStageLabel;

  /// No description provided for @scheduleNoStage.
  ///
  /// In pl, this message translates to:
  /// **'Bez etapu'**
  String get scheduleNoStage;

  /// No description provided for @scheduleAssigneeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Osoba lub ekipa'**
  String get scheduleAssigneeLabel;

  /// No description provided for @scheduleNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get scheduleNoteLabel;

  /// No description provided for @scheduleReminderToggle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie lokalne'**
  String get scheduleReminderToggle;

  /// No description provided for @scheduleReminderLeadLabel.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnij'**
  String get scheduleReminderLeadLabel;

  /// No description provided for @scheduleRescheduleReasonLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powód przełożenia'**
  String get scheduleRescheduleReasonLabel;

  /// No description provided for @scheduleSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać terminu.'**
  String get scheduleSaveError;

  /// No description provided for @scheduleNotificationBody.
  ///
  /// In pl, this message translates to:
  /// **'Nadchodzi termin w planie budowy.'**
  String get scheduleNotificationBody;

  /// No description provided for @scheduleDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły terminu'**
  String get scheduleDetailsTitle;

  /// No description provided for @scheduleSourceMissingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono terminu'**
  String get scheduleSourceMissingTitle;

  /// No description provided for @scheduleSourceMissingMessage.
  ///
  /// In pl, this message translates to:
  /// **'Rekord mógł zostać usunięty albo należy do innego projektu.'**
  String get scheduleSourceMissingMessage;

  /// No description provided for @scheduleEditAction.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj termin'**
  String get scheduleEditAction;

  /// No description provided for @scheduleDependenciesHeading.
  ///
  /// In pl, this message translates to:
  /// **'Blokady i zależności'**
  String get scheduleDependenciesHeading;

  /// No description provided for @scheduleDependenciesEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak blokujących terminów.'**
  String get scheduleDependenciesEmpty;

  /// No description provided for @scheduleDependenciesEditAction.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw zależności'**
  String get scheduleDependenciesEditAction;

  /// No description provided for @scheduleDependencySheetTitle.
  ///
  /// In pl, this message translates to:
  /// **'Co blokuje ten termin?'**
  String get scheduleDependencySheetTitle;

  /// No description provided for @scheduleDependencyDeadlineTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw termin decyzji'**
  String get scheduleDependencyDeadlineTooltip;

  /// No description provided for @scheduleDependencyCycleError.
  ///
  /// In pl, this message translates to:
  /// **'Ta zależność utworzyłaby zamknięty cykl.'**
  String get scheduleDependencyCycleError;

  /// No description provided for @scheduleHistoryHeading.
  ///
  /// In pl, this message translates to:
  /// **'Historia terminów'**
  String get scheduleHistoryHeading;

  /// No description provided for @scheduleHistoryEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Termin nie był jeszcze przekładany.'**
  String get scheduleHistoryEmpty;

  /// No description provided for @scheduleHistoryMoved.
  ///
  /// In pl, this message translates to:
  /// **'Z {from} na {to}'**
  String scheduleHistoryMoved(String from, String to);

  /// No description provided for @scheduleReminderEnabled.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie włączone'**
  String get scheduleReminderEnabled;

  /// No description provided for @scheduleReminderDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie wyłączone'**
  String get scheduleReminderDisabled;

  /// No description provided for @scheduleMutationError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać zmiany.'**
  String get scheduleMutationError;

  /// No description provided for @dashboardLoading.
  ///
  /// In pl, this message translates to:
  /// **'Ładowanie Startu…'**
  String get dashboardLoading;

  /// No description provided for @dashboardLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać podsumowania projektu.'**
  String get dashboardLoadError;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Projekt gotowy do uzupełnienia'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy koszt, termin albo rozpocznij checklistę etapu.'**
  String get dashboardEmptyMessage;

  /// No description provided for @dashboardStartWithCost.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy koszt'**
  String get dashboardStartWithCost;

  /// No description provided for @dashboardCurrentStage.
  ///
  /// In pl, this message translates to:
  /// **'Aktualny etap'**
  String get dashboardCurrentStage;

  /// No description provided for @dashboardBudgetTitle.
  ///
  /// In pl, this message translates to:
  /// **'Budżet projektu'**
  String get dashboardBudgetTitle;

  /// No description provided for @dashboardSpentOfBudget.
  ///
  /// In pl, this message translates to:
  /// **'{spent} z {budget}'**
  String dashboardSpentOfBudget(String spent, String budget);

  /// No description provided for @dashboardRemaining.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało'**
  String get dashboardRemaining;

  /// No description provided for @dashboardOverBudget.
  ///
  /// In pl, this message translates to:
  /// **'Przekroczenie'**
  String get dashboardOverBudget;

  /// No description provided for @dashboardBudgetNotSet.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij budżet projektu'**
  String get dashboardBudgetNotSet;

  /// No description provided for @dashboardSpent.
  ///
  /// In pl, this message translates to:
  /// **'Wydano'**
  String get dashboardSpent;

  /// No description provided for @dashboardPlan30.
  ///
  /// In pl, this message translates to:
  /// **'Plan 30 dni'**
  String get dashboardPlan30;

  /// No description provided for @dashboardUnpaid.
  ///
  /// In pl, this message translates to:
  /// **'Nieopłacone'**
  String get dashboardUnpaid;

  /// No description provided for @dashboardUnpaidItems.
  ///
  /// In pl, this message translates to:
  /// **'{count} pozycji'**
  String dashboardUnpaidItems(int count);

  /// No description provided for @dashboardQuickActions.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie akcje'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardAddCost.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj koszt'**
  String get dashboardAddCost;

  /// No description provided for @dashboardOpenBudget.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz budżet'**
  String get dashboardOpenBudget;

  /// No description provided for @dashboardScanReceipt.
  ///
  /// In pl, this message translates to:
  /// **'Skanuj paragon'**
  String get dashboardScanReceipt;

  /// No description provided for @dashboardOpenChecklists.
  ///
  /// In pl, this message translates to:
  /// **'Checklisty etapów'**
  String get dashboardOpenChecklists;

  /// No description provided for @dashboardAddSchedule.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj termin'**
  String get dashboardAddSchedule;

  /// No description provided for @dashboardCritical.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczne zadania'**
  String get dashboardCritical;

  /// No description provided for @dashboardCriticalCount.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte: {count}'**
  String dashboardCriticalCount(int count);

  /// No description provided for @dashboardCriticalEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak otwartych zadań wysokiego ryzyka.'**
  String get dashboardCriticalEmpty;

  /// No description provided for @dashboardStages.
  ///
  /// In pl, this message translates to:
  /// **'Oś etapów'**
  String get dashboardStages;

  /// No description provided for @dashboardAgenda.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj na budowie'**
  String get dashboardAgenda;

  /// No description provided for @dashboardAgendaCount.
  ///
  /// In pl, this message translates to:
  /// **'Wpisy: {count}'**
  String dashboardAgendaCount(int count);

  /// No description provided for @dashboardAgendaEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak zadań, wizyt, dostaw i odbiorów na dziś.'**
  String get dashboardAgendaEmpty;

  /// No description provided for @dashboardUpcomingVisits.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe wizyty'**
  String get dashboardUpcomingVisits;

  /// No description provided for @dashboardUpcomingVisitsCount.
  ///
  /// In pl, this message translates to:
  /// **'Wizyty: {count}'**
  String dashboardUpcomingVisitsCount(int count);

  /// No description provided for @dashboardUpcomingVisitsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak wizyt zaplanowanych na najbliższe 30 dni.'**
  String get dashboardUpcomingVisitsEmpty;

  /// No description provided for @dashboardProjectActionsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzaj projektem'**
  String get dashboardProjectActionsTooltip;

  /// No description provided for @dashboardStageProgress.
  ///
  /// In pl, this message translates to:
  /// **'Postęp checklisty: {percent}%'**
  String dashboardStageProgress(int percent);

  /// No description provided for @contactsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ekipy i kontakty'**
  String get contactsTitle;

  /// No description provided for @contactsAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj kontakt'**
  String get contactsAddTooltip;

  /// No description provided for @contactsSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj osoby, firmy, telefonu lub e-maila'**
  String get contactsSearchHint;

  /// No description provided for @contactsRoleFilterLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rola'**
  String get contactsRoleFilterLabel;

  /// No description provided for @contactsStageFilterLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get contactsStageFilterLabel;

  /// No description provided for @contactsAllRoles.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie role'**
  String get contactsAllRoles;

  /// No description provided for @contactsAllStages.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie etapy'**
  String get contactsAllStages;

  /// No description provided for @contactsResultCount.
  ///
  /// In pl, this message translates to:
  /// **'Kontakty: {count}'**
  String contactsResultCount(int count);

  /// No description provided for @contactsNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get contactsNoProjectTitle;

  /// No description provided for @contactsNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Kontakty i wizyty są przypisane do projektu.'**
  String get contactsNoProjectMessage;

  /// No description provided for @contactsEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak kontaktów'**
  String get contactsEmptyTitle;

  /// No description provided for @contactsEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszą ekipę, wykonawcę lub dostawcę.'**
  String get contactsEmptyMessage;

  /// No description provided for @contactsNoResultsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak pasujących kontaktów'**
  String get contactsNoResultsTitle;

  /// No description provided for @contactsNoResultsMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zmień wyszukiwanie albo filtry roli i etapu.'**
  String get contactsNoResultsMessage;

  /// No description provided for @contactsLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać kontaktów.'**
  String get contactsLoadError;

  /// No description provided for @contactNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy kontakt'**
  String get contactNewTitle;

  /// No description provided for @contactImportFromPhoneAction.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz z kontaktów telefonu'**
  String get contactImportFromPhoneAction;

  /// No description provided for @contactImportFromPhoneError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć kontaktów telefonu.'**
  String get contactImportFromPhoneError;

  /// No description provided for @contactEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj kontakt'**
  String get contactEditTitle;

  /// No description provided for @contactDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły kontaktu'**
  String get contactDetailsTitle;

  /// No description provided for @contactNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Osoba lub firma'**
  String get contactNameLabel;

  /// No description provided for @contactKindLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj kontaktu'**
  String get contactKindLabel;

  /// No description provided for @contactKindPerson.
  ///
  /// In pl, this message translates to:
  /// **'Osoba'**
  String get contactKindPerson;

  /// No description provided for @contactKindCompany.
  ///
  /// In pl, this message translates to:
  /// **'Firma'**
  String get contactKindCompany;

  /// No description provided for @contactRolesHeading.
  ///
  /// In pl, this message translates to:
  /// **'Role i branże'**
  String get contactRolesHeading;

  /// No description provided for @contactStagesHeading.
  ///
  /// In pl, this message translates to:
  /// **'Przypisane etapy'**
  String get contactStagesHeading;

  /// No description provided for @contactNoStagesAvailable.
  ///
  /// In pl, this message translates to:
  /// **'Projekt nie ma jeszcze etapów.'**
  String get contactNoStagesAvailable;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In pl, this message translates to:
  /// **'Telefon'**
  String get contactPhoneLabel;

  /// No description provided for @contactEmailLabel.
  ///
  /// In pl, this message translates to:
  /// **'E-mail'**
  String get contactEmailLabel;

  /// No description provided for @contactTaxIdLabel.
  ///
  /// In pl, this message translates to:
  /// **'NIP'**
  String get contactTaxIdLabel;

  /// No description provided for @contactNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get contactNoteLabel;

  /// No description provided for @contactRatingLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get contactRatingLabel;

  /// No description provided for @contactNoRating.
  ///
  /// In pl, this message translates to:
  /// **'Bez oceny'**
  String get contactNoRating;

  /// No description provided for @contactSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać kontaktu.'**
  String get contactSaveError;

  /// No description provided for @contactNameRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj osobę albo nazwę firmy.'**
  String get contactNameRequiredError;

  /// No description provided for @contactRoleRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz co najmniej jedną rolę.'**
  String get contactRoleRequiredError;

  /// No description provided for @contactEmailInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawny adres e-mail.'**
  String get contactEmailInvalidError;

  /// No description provided for @contactLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać kontaktu.'**
  String get contactLoadError;

  /// No description provided for @contactNotFoundTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono kontaktu'**
  String get contactNotFoundTitle;

  /// No description provided for @contactNotFoundMessage.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt mógł zostać usunięty lub należy do innego projektu.'**
  String get contactNotFoundMessage;

  /// No description provided for @contactCallTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zadzwoń'**
  String get contactCallTooltip;

  /// No description provided for @contactEmailTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Napisz e-mail'**
  String get contactEmailTooltip;

  /// No description provided for @contactEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj kontakt'**
  String get contactEditTooltip;

  /// No description provided for @contactCallConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zadzwonić do kontaktu?'**
  String get contactCallConfirmTitle;

  /// No description provided for @contactCallConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'Telefon otworzy systemową aplikację połączeń dla numeru {phone}.'**
  String contactCallConfirmMessage(String phone);

  /// No description provided for @contactCallAction.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz telefon'**
  String get contactCallAction;

  /// No description provided for @contactEmailConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Napisać do kontaktu?'**
  String get contactEmailConfirmTitle;

  /// No description provided for @contactEmailConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'E-mail otworzy systemową aplikację pocztową dla adresu {email}.'**
  String contactEmailConfirmMessage(String email);

  /// No description provided for @contactEmailAction.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz pocztę'**
  String get contactEmailAction;

  /// No description provided for @contactActionError.
  ///
  /// In pl, this message translates to:
  /// **'Na tym urządzeniu nie znaleziono odpowiedniej aplikacji.'**
  String get contactActionError;

  /// No description provided for @contactArchiveAction.
  ///
  /// In pl, this message translates to:
  /// **'Archiwizuj'**
  String get contactArchiveAction;

  /// No description provided for @contactRestoreAction.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć'**
  String get contactRestoreAction;

  /// No description provided for @contactArchiveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zmienić stanu kontaktu.'**
  String get contactArchiveError;

  /// No description provided for @contactDeleteConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć kontakt?'**
  String get contactDeleteConfirmTitle;

  /// No description provided for @contactDeleteConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt bez historii wizyt i ofert zostanie trwale usunięty.'**
  String get contactDeleteConfirmMessage;

  /// No description provided for @contactDeleteInUseError.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt ma historię wizyt lub ofert. Zamiast usuwać, zarchiwizuj go.'**
  String get contactDeleteInUseError;

  /// No description provided for @contactDeleteError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć kontaktu.'**
  String get contactDeleteError;

  /// No description provided for @contactAboutHeading.
  ///
  /// In pl, this message translates to:
  /// **'Dane kontaktowe'**
  String get contactAboutHeading;

  /// No description provided for @contactVisitHeading.
  ///
  /// In pl, this message translates to:
  /// **'Wizyty na budowie'**
  String get contactVisitHeading;

  /// No description provided for @contactAddVisitAction.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanuj wizytę'**
  String get contactAddVisitAction;

  /// No description provided for @contactUpcomingVisits.
  ///
  /// In pl, this message translates to:
  /// **'Nadchodzące'**
  String get contactUpcomingVisits;

  /// No description provided for @contactVisitHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia'**
  String get contactVisitHistory;

  /// No description provided for @contactUpcomingEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak zaplanowanych wizyt.'**
  String get contactUpcomingEmpty;

  /// No description provided for @contactVisitHistoryEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak zakończonych i odwołanych wizyt.'**
  String get contactVisitHistoryEmpty;

  /// No description provided for @contactRoleGeneralContractor.
  ///
  /// In pl, this message translates to:
  /// **'Generalny wykonawca'**
  String get contactRoleGeneralContractor;

  /// No description provided for @contactRoleSiteManager.
  ///
  /// In pl, this message translates to:
  /// **'Kierownik budowy'**
  String get contactRoleSiteManager;

  /// No description provided for @contactRoleArchitect.
  ///
  /// In pl, this message translates to:
  /// **'Architekt'**
  String get contactRoleArchitect;

  /// No description provided for @contactRoleElectrician.
  ///
  /// In pl, this message translates to:
  /// **'Elektryk'**
  String get contactRoleElectrician;

  /// No description provided for @contactRolePlumber.
  ///
  /// In pl, this message translates to:
  /// **'Hydraulik'**
  String get contactRolePlumber;

  /// No description provided for @contactRoleHeatingVentilation.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie i wentylacja'**
  String get contactRoleHeatingVentilation;

  /// No description provided for @contactRoleSurveyor.
  ///
  /// In pl, this message translates to:
  /// **'Geodeta'**
  String get contactRoleSurveyor;

  /// No description provided for @contactRoleRoofer.
  ///
  /// In pl, this message translates to:
  /// **'Dekarz'**
  String get contactRoleRoofer;

  /// No description provided for @contactRoleCarpenter.
  ///
  /// In pl, this message translates to:
  /// **'Cieśla / stolarz'**
  String get contactRoleCarpenter;

  /// No description provided for @contactRolePlasterer.
  ///
  /// In pl, this message translates to:
  /// **'Tynkarz'**
  String get contactRolePlasterer;

  /// No description provided for @contactRoleTiler.
  ///
  /// In pl, this message translates to:
  /// **'Glazurnik'**
  String get contactRoleTiler;

  /// No description provided for @contactRolePainter.
  ///
  /// In pl, this message translates to:
  /// **'Malarz'**
  String get contactRolePainter;

  /// No description provided for @contactRoleSupplier.
  ///
  /// In pl, this message translates to:
  /// **'Dostawca'**
  String get contactRoleSupplier;

  /// No description provided for @contactRoleInspector.
  ///
  /// In pl, this message translates to:
  /// **'Inspektor'**
  String get contactRoleInspector;

  /// No description provided for @contactRoleOther.
  ///
  /// In pl, this message translates to:
  /// **'Inna rola'**
  String get contactRoleOther;

  /// No description provided for @siteVisitNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowa wizyta'**
  String get siteVisitNewTitle;

  /// No description provided for @siteVisitEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj wizytę'**
  String get siteVisitEditTitle;

  /// No description provided for @siteVisitPurposeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Cel wizyty'**
  String get siteVisitPurposeLabel;

  /// No description provided for @siteVisitExpectedResultLabel.
  ///
  /// In pl, this message translates to:
  /// **'Oczekiwany rezultat'**
  String get siteVisitExpectedResultLabel;

  /// No description provided for @siteVisitStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status wizyty'**
  String get siteVisitStatusLabel;

  /// No description provided for @siteVisitStatusPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Planowana'**
  String get siteVisitStatusPlanned;

  /// No description provided for @siteVisitStatusCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Wykonana'**
  String get siteVisitStatusCompleted;

  /// No description provided for @siteVisitStatusCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Odwołana'**
  String get siteVisitStatusCancelled;

  /// No description provided for @siteVisitStatusNoShow.
  ///
  /// In pl, this message translates to:
  /// **'Wykonawca nie przyjechał'**
  String get siteVisitStatusNoShow;

  /// No description provided for @siteVisitDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get siteVisitDateLabel;

  /// No description provided for @siteVisitTimeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Godzina'**
  String get siteVisitTimeLabel;

  /// No description provided for @siteVisitAllDayLabel.
  ///
  /// In pl, this message translates to:
  /// **'Cały dzień'**
  String get siteVisitAllDayLabel;

  /// No description provided for @siteVisitStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get siteVisitStageLabel;

  /// No description provided for @siteVisitNoStage.
  ///
  /// In pl, this message translates to:
  /// **'Bez etapu'**
  String get siteVisitNoStage;

  /// No description provided for @siteVisitReminderToggle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie'**
  String get siteVisitReminderToggle;

  /// No description provided for @siteVisitReminderLeadLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wyprzedzenie'**
  String get siteVisitReminderLeadLabel;

  /// No description provided for @siteVisitResultLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rezultat i notatka po wizycie'**
  String get siteVisitResultLabel;

  /// No description provided for @siteVisitAgreementsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ustalenia'**
  String get siteVisitAgreementsLabel;

  /// No description provided for @siteVisitRescheduleReasonLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powód zmiany terminu'**
  String get siteVisitRescheduleReasonLabel;

  /// No description provided for @siteVisitPurposeRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj cel wizyty.'**
  String get siteVisitPurposeRequiredError;

  /// No description provided for @siteVisitExpectedResultRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj oczekiwany rezultat.'**
  String get siteVisitExpectedResultRequiredError;

  /// No description provided for @siteVisitResultRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz rezultat wykonanej wizyty.'**
  String get siteVisitResultRequiredError;

  /// No description provided for @siteVisitSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać wizyty.'**
  String get siteVisitSaveError;

  /// No description provided for @siteVisitLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać wizyty.'**
  String get siteVisitLoadError;

  /// No description provided for @siteVisitNotificationBody.
  ///
  /// In pl, this message translates to:
  /// **'Nadchodzi wizyta zaplanowana na budowie.'**
  String get siteVisitNotificationBody;

  /// No description provided for @siteVisitResultHeading.
  ///
  /// In pl, this message translates to:
  /// **'Wynik wizyty'**
  String get siteVisitResultHeading;

  /// No description provided for @siteVisitAgreementsHeading.
  ///
  /// In pl, this message translates to:
  /// **'Ustalenia'**
  String get siteVisitAgreementsHeading;

  /// No description provided for @quotesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Oferty wykonawców'**
  String get quotesTitle;

  /// No description provided for @quotesSearchLabel.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj oferty lub wykonawcy'**
  String get quotesSearchLabel;

  /// No description provided for @quotesStatusAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie statusy'**
  String get quotesStatusAll;

  /// No description provided for @quoteStatusReceived.
  ///
  /// In pl, this message translates to:
  /// **'Otrzymana'**
  String get quoteStatusReceived;

  /// No description provided for @quoteStatusAccepted.
  ///
  /// In pl, this message translates to:
  /// **'Przyjęta'**
  String get quoteStatusAccepted;

  /// No description provided for @quoteStatusRejected.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucona'**
  String get quoteStatusRejected;

  /// No description provided for @quoteStatusExpired.
  ///
  /// In pl, this message translates to:
  /// **'Po terminie'**
  String get quoteStatusExpired;

  /// No description provided for @quotesCompareAction.
  ///
  /// In pl, this message translates to:
  /// **'Porównaj ({count})'**
  String quotesCompareAction(int count);

  /// No description provided for @quotesCompareLimit.
  ///
  /// In pl, this message translates to:
  /// **'Możesz porównać maksymalnie 4 oferty.'**
  String get quotesCompareLimit;

  /// No description provided for @quotesResultCount.
  ///
  /// In pl, this message translates to:
  /// **'Oferty: {count}'**
  String quotesResultCount(int count);

  /// No description provided for @quotesNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get quotesNoProjectTitle;

  /// No description provided for @quotesNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Oferty są przypisane do projektu.'**
  String get quotesNoProjectMessage;

  /// No description provided for @quotesEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak ofert'**
  String get quotesEmptyTitle;

  /// No description provided for @quotesEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszą ofertę wykonawcy z ceną i zakresem.'**
  String get quotesEmptyMessage;

  /// No description provided for @quotesNoResultsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak pasujących ofert'**
  String get quotesNoResultsTitle;

  /// No description provided for @quotesNoResultsMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zmień wyszukiwanie albo filtr statusu.'**
  String get quotesNoResultsMessage;

  /// No description provided for @quotesLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać ofert.'**
  String get quotesLoadError;

  /// No description provided for @quoteNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowa oferta'**
  String get quoteNewTitle;

  /// No description provided for @quoteEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj ofertę'**
  String get quoteEditTitle;

  /// No description provided for @quoteDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły oferty'**
  String get quoteDetailsTitle;

  /// No description provided for @quoteContractorLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wykonawca'**
  String get quoteContractorLabel;

  /// No description provided for @quoteTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zakres główny'**
  String get quoteTitleLabel;

  /// No description provided for @quoteVariantLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wariant'**
  String get quoteVariantLabel;

  /// No description provided for @quoteGrossAmountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kwota brutto'**
  String get quoteGrossAmountLabel;

  /// No description provided for @quoteVatRateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Stawka VAT'**
  String get quoteVatRateLabel;

  /// No description provided for @quoteReceivedDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data otrzymania'**
  String get quoteReceivedDateLabel;

  /// No description provided for @quoteValidUntilLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ważna do'**
  String get quoteValidUntilLabel;

  /// No description provided for @quoteStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get quoteStageLabel;

  /// No description provided for @quoteNoStage.
  ///
  /// In pl, this message translates to:
  /// **'Bez etapu'**
  String get quoteNoStage;

  /// No description provided for @quoteIncludedScopeHeading.
  ///
  /// In pl, this message translates to:
  /// **'W cenie'**
  String get quoteIncludedScopeHeading;

  /// No description provided for @quoteExcludedScopeHeading.
  ///
  /// In pl, this message translates to:
  /// **'Wykluczenia'**
  String get quoteExcludedScopeHeading;

  /// No description provided for @quoteScopeLineLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja zakresu'**
  String get quoteScopeLineLabel;

  /// No description provided for @quoteAddScopeLineTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pozycję'**
  String get quoteAddScopeLineTooltip;

  /// No description provided for @quoteRemoveScopeLineTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pozycję'**
  String get quoteRemoveScopeLineTooltip;

  /// No description provided for @quoteAttachmentsHeading.
  ///
  /// In pl, this message translates to:
  /// **'Załączniki'**
  String get quoteAttachmentsHeading;

  /// No description provided for @quoteAddAttachmentAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj PDF lub zdjęcie'**
  String get quoteAddAttachmentAction;

  /// No description provided for @quoteNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get quoteNoteLabel;

  /// No description provided for @quoteRequiredFieldsError.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij wykonawcę, nazwę, wariant, kwotę i zakres.'**
  String get quoteRequiredFieldsError;

  /// No description provided for @quoteInvalidAmountError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawną kwotę większą od zera.'**
  String get quoteInvalidAmountError;

  /// No description provided for @quoteInvalidValidityError.
  ///
  /// In pl, this message translates to:
  /// **'Termin ważności nie może być przed datą otrzymania.'**
  String get quoteInvalidValidityError;

  /// No description provided for @quoteSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać oferty.'**
  String get quoteSaveError;

  /// No description provided for @quoteLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać oferty.'**
  String get quoteLoadError;

  /// No description provided for @quoteNotFoundTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono oferty'**
  String get quoteNotFoundTitle;

  /// No description provided for @quoteNotFoundMessage.
  ///
  /// In pl, this message translates to:
  /// **'Oferta mogła zostać usunięta lub należy do innego projektu.'**
  String get quoteNotFoundMessage;

  /// No description provided for @quoteAttachmentError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zaimportować załącznika.'**
  String get quoteAttachmentError;

  /// No description provided for @quoteValidUntilValue.
  ///
  /// In pl, this message translates to:
  /// **'Ważna do {date}'**
  String quoteValidUntilValue(String date);

  /// No description provided for @quoteExpiredOnValue.
  ///
  /// In pl, this message translates to:
  /// **'Termin minął {date}'**
  String quoteExpiredOnValue(String date);

  /// No description provided for @quoteAcceptAction.
  ///
  /// In pl, this message translates to:
  /// **'Przyjmij ofertę'**
  String get quoteAcceptAction;

  /// No description provided for @quoteRejectAction.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć ofertę'**
  String get quoteRejectAction;

  /// No description provided for @quoteAcceptTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodać ofertę do budżetu?'**
  String get quoteAcceptTitle;

  /// No description provided for @quoteAcceptPlannedAction.
  ///
  /// In pl, this message translates to:
  /// **'Jako planowany koszt'**
  String get quoteAcceptPlannedAction;

  /// No description provided for @quoteAcceptOrderedAction.
  ///
  /// In pl, this message translates to:
  /// **'Jako zamówiony koszt'**
  String get quoteAcceptOrderedAction;

  /// No description provided for @quoteAcceptError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się przyjąć oferty.'**
  String get quoteAcceptError;

  /// No description provided for @quoteRejectConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucić ofertę?'**
  String get quoteRejectConfirmTitle;

  /// No description provided for @quoteRejectConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'Oferta pozostanie w historii ze statusem odrzuconej.'**
  String get quoteRejectConfirmMessage;

  /// No description provided for @quoteRejectError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odrzucić oferty.'**
  String get quoteRejectError;

  /// No description provided for @quoteDeleteConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć ofertę?'**
  String get quoteDeleteConfirmTitle;

  /// No description provided for @quoteDeleteConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'Nieprzyjęta oferta i jej powiązania zostaną usunięte.'**
  String get quoteDeleteConfirmMessage;

  /// No description provided for @quoteDeleteError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć oferty.'**
  String get quoteDeleteError;

  /// No description provided for @quoteViewCostAction.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz koszt w budżecie'**
  String get quoteViewCostAction;

  /// No description provided for @quoteAcceptedCostHeading.
  ///
  /// In pl, this message translates to:
  /// **'Koszt w budżecie'**
  String get quoteAcceptedCostHeading;

  /// No description provided for @quoteComparisonTitle.
  ///
  /// In pl, this message translates to:
  /// **'Porównanie ofert'**
  String get quoteComparisonTitle;

  /// No description provided for @quoteComparisonPriceHeading.
  ///
  /// In pl, this message translates to:
  /// **'Cena brutto'**
  String get quoteComparisonPriceHeading;

  /// No description provided for @quoteComparisonScopeHeading.
  ///
  /// In pl, this message translates to:
  /// **'Różnice zakresu'**
  String get quoteComparisonScopeHeading;

  /// No description provided for @quoteLowestPriceLabel.
  ///
  /// In pl, this message translates to:
  /// **'Najniższa cena'**
  String get quoteLowestPriceLabel;

  /// No description provided for @quotePresenceIncluded.
  ///
  /// In pl, this message translates to:
  /// **'W cenie'**
  String get quotePresenceIncluded;

  /// No description provided for @quotePresenceExcluded.
  ///
  /// In pl, this message translates to:
  /// **'Wykluczone'**
  String get quotePresenceExcluded;

  /// No description provided for @quotePresenceNotSpecified.
  ///
  /// In pl, this message translates to:
  /// **'Brak informacji'**
  String get quotePresenceNotSpecified;

  /// No description provided for @quoteComparisonNeedsTwo.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz co najmniej 2 oferty.'**
  String get quoteComparisonNeedsTwo;

  /// No description provided for @contactQuotesHeading.
  ///
  /// In pl, this message translates to:
  /// **'Oferty'**
  String get contactQuotesHeading;

  /// No description provided for @contactAddQuoteAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj ofertę'**
  String get contactAddQuoteAction;

  /// No description provided for @contactQuotesEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak ofert tego wykonawcy.'**
  String get contactQuotesEmpty;

  /// No description provided for @documentsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dokumenty'**
  String get documentsTitle;

  /// No description provided for @documentsSearchLabel.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj nazwy lub opisu'**
  String get documentsSearchLabel;

  /// No description provided for @documentsFiltersAction.
  ///
  /// In pl, this message translates to:
  /// **'Filtry'**
  String get documentsFiltersAction;

  /// No description provided for @documentsFiltersCount.
  ///
  /// In pl, this message translates to:
  /// **'Filtry ({count})'**
  String documentsFiltersCount(int count);

  /// No description provided for @documentsFilterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Filtruj dokumenty'**
  String get documentsFilterTitle;

  /// No description provided for @documentsFilterTypeAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie typy'**
  String get documentsFilterTypeAll;

  /// No description provided for @documentsFilterStageAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie etapy'**
  String get documentsFilterStageAll;

  /// No description provided for @documentsFilterRoomAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie pomieszczenia'**
  String get documentsFilterRoomAll;

  /// No description provided for @documentsFilterWarrantyAll.
  ///
  /// In pl, this message translates to:
  /// **'Każdy stan gwarancji'**
  String get documentsFilterWarrantyAll;

  /// No description provided for @documentsFilterFromDate.
  ///
  /// In pl, this message translates to:
  /// **'Od daty'**
  String get documentsFilterFromDate;

  /// No description provided for @documentsFilterToDate.
  ///
  /// In pl, this message translates to:
  /// **'Do daty'**
  String get documentsFilterToDate;

  /// No description provided for @documentsApplyFiltersAction.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż wyniki'**
  String get documentsApplyFiltersAction;

  /// No description provided for @documentsResultCount.
  ///
  /// In pl, this message translates to:
  /// **'Dokumenty: {count}'**
  String documentsResultCount(int count);

  /// No description provided for @documentsLoadMoreAction.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj kolejne'**
  String get documentsLoadMoreAction;

  /// No description provided for @documentsNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get documentsNoProjectTitle;

  /// No description provided for @documentsNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dokumenty są przechowywane osobno dla każdego projektu.'**
  String get documentsNoProjectMessage;

  /// No description provided for @documentsEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak dokumentów'**
  String get documentsEmptyTitle;

  /// No description provided for @documentsEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj fakturę, umowę, gwarancję, instrukcję albo zdjęcie.'**
  String get documentsEmptyMessage;

  /// No description provided for @documentsNoResultsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak pasujących dokumentów'**
  String get documentsNoResultsTitle;

  /// No description provided for @documentsNoResultsMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zmień wyszukiwanie albo aktywne filtry.'**
  String get documentsNoResultsMessage;

  /// No description provided for @documentsLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać dokumentów.'**
  String get documentsLoadError;

  /// No description provided for @documentImportAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj dokument'**
  String get documentImportAction;

  /// No description provided for @documentImportError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zaimportować dokumentu.'**
  String get documentImportError;

  /// No description provided for @documentDuplicateTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ten plik może już być zapisany'**
  String get documentDuplicateTitle;

  /// No description provided for @documentDuplicateMessage.
  ///
  /// In pl, this message translates to:
  /// **'Znaleziono {count} dokumentów z identyczną zawartością. Możesz mimo to zachować osobną pozycję.'**
  String documentDuplicateMessage(int count);

  /// No description provided for @documentDuplicateContinueAction.
  ///
  /// In pl, this message translates to:
  /// **'Zachowaj mimo to'**
  String get documentDuplicateContinueAction;

  /// No description provided for @documentNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy dokument'**
  String get documentNewTitle;

  /// No description provided for @documentEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj dokument'**
  String get documentEditTitle;

  /// No description provided for @documentDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły dokumentu'**
  String get documentDetailsTitle;

  /// No description provided for @documentViewerTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd dokumentu'**
  String get documentViewerTitle;

  /// No description provided for @documentTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa dokumentu'**
  String get documentTitleLabel;

  /// No description provided for @documentTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Typ dokumentu'**
  String get documentTypeLabel;

  /// No description provided for @documentDescriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis'**
  String get documentDescriptionLabel;

  /// No description provided for @documentDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data dokumentu'**
  String get documentDateLabel;

  /// No description provided for @documentStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get documentStageLabel;

  /// No description provided for @documentNoStage.
  ///
  /// In pl, this message translates to:
  /// **'Bez etapu'**
  String get documentNoStage;

  /// No description provided for @documentRoomLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie lub strefa'**
  String get documentRoomLabel;

  /// No description provided for @documentContactLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt'**
  String get documentContactLabel;

  /// No description provided for @documentNoContact.
  ///
  /// In pl, this message translates to:
  /// **'Bez kontaktu'**
  String get documentNoContact;

  /// No description provided for @documentWarrantySection.
  ///
  /// In pl, this message translates to:
  /// **'Gwarancja i termin'**
  String get documentWarrantySection;

  /// No description provided for @documentWarrantyEnabledLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dokument zawiera gwarancję'**
  String get documentWarrantyEnabledLabel;

  /// No description provided for @documentWarrantyStartLabel.
  ///
  /// In pl, this message translates to:
  /// **'Początek gwarancji'**
  String get documentWarrantyStartLabel;

  /// No description provided for @documentWarrantyEndLabel.
  ///
  /// In pl, this message translates to:
  /// **'Koniec gwarancji'**
  String get documentWarrantyEndLabel;

  /// No description provided for @documentWarrantyReminderLabel.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie'**
  String get documentWarrantyReminderLabel;

  /// No description provided for @documentWarrantyReminderHint.
  ///
  /// In pl, this message translates to:
  /// **'Data pojawi się w informacjach o terminie gwarancji.'**
  String get documentWarrantyReminderHint;

  /// No description provided for @documentRequiredFieldsError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę i typ dokumentu.'**
  String get documentRequiredFieldsError;

  /// No description provided for @documentWarrantyDatesError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj prawidłowy początek i koniec gwarancji.'**
  String get documentWarrantyDatesError;

  /// No description provided for @documentSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać dokumentu.'**
  String get documentSaveError;

  /// No description provided for @documentLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać dokumentu.'**
  String get documentLoadError;

  /// No description provided for @documentNotFoundTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono dokumentu'**
  String get documentNotFoundTitle;

  /// No description provided for @documentNotFoundMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dokument mógł zostać usunięty albo należy do innego projektu.'**
  String get documentNotFoundMessage;

  /// No description provided for @documentOpenAction.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz'**
  String get documentOpenAction;

  /// No description provided for @documentShareAction.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get documentShareAction;

  /// No description provided for @documentShareError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się udostępnić pliku.'**
  String get documentShareError;

  /// No description provided for @documentDeleteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć dokument?'**
  String get documentDeleteTitle;

  /// No description provided for @documentDeleteMessage.
  ///
  /// In pl, this message translates to:
  /// **'Plik oraz {count} powiązanych rekordów zostaną odłączone. Tej operacji nie można cofnąć.'**
  String documentDeleteMessage(int count);

  /// No description provided for @documentDeleteError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć dokumentu.'**
  String get documentDeleteError;

  /// No description provided for @documentRelationsHeading.
  ///
  /// In pl, this message translates to:
  /// **'Powiązania'**
  String get documentRelationsHeading;

  /// No description provided for @documentRelationsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak powiązanych rekordów.'**
  String get documentRelationsEmpty;

  /// No description provided for @documentFileHeading.
  ///
  /// In pl, this message translates to:
  /// **'Plik źródłowy'**
  String get documentFileHeading;

  /// No description provided for @documentFileNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa pliku'**
  String get documentFileNameLabel;

  /// No description provided for @documentFileSizeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rozmiar'**
  String get documentFileSizeLabel;

  /// No description provided for @documentImportedAtLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zaimportowano'**
  String get documentImportedAtLabel;

  /// No description provided for @documentOriginalPreservedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Oryginał zachowany bez zmian'**
  String get documentOriginalPreservedLabel;

  /// No description provided for @documentPreviewUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd tego formatu nie jest dostępny w aplikacji.'**
  String get documentPreviewUnavailable;

  /// No description provided for @documentPreviewUnavailableMessage.
  ///
  /// In pl, this message translates to:
  /// **'Oryginał pozostaje zapisany i możesz go udostępnić z ekranu szczegółów.'**
  String get documentPreviewUnavailableMessage;

  /// No description provided for @documentTypeReceipt.
  ///
  /// In pl, this message translates to:
  /// **'Paragon'**
  String get documentTypeReceipt;

  /// No description provided for @documentTypeInvoice.
  ///
  /// In pl, this message translates to:
  /// **'Faktura'**
  String get documentTypeInvoice;

  /// No description provided for @documentTypeQuote.
  ///
  /// In pl, this message translates to:
  /// **'Oferta'**
  String get documentTypeQuote;

  /// No description provided for @documentTypeContract.
  ///
  /// In pl, this message translates to:
  /// **'Umowa'**
  String get documentTypeContract;

  /// No description provided for @documentTypeDeliveryNote.
  ///
  /// In pl, this message translates to:
  /// **'WZ'**
  String get documentTypeDeliveryNote;

  /// No description provided for @documentTypeProtocol.
  ///
  /// In pl, this message translates to:
  /// **'Protokół'**
  String get documentTypeProtocol;

  /// No description provided for @documentTypeWarranty.
  ///
  /// In pl, this message translates to:
  /// **'Gwarancja'**
  String get documentTypeWarranty;

  /// No description provided for @documentTypeInstruction.
  ///
  /// In pl, this message translates to:
  /// **'Instrukcja'**
  String get documentTypeInstruction;

  /// No description provided for @documentTypeMap.
  ///
  /// In pl, this message translates to:
  /// **'Mapa lub rzut'**
  String get documentTypeMap;

  /// No description provided for @documentTypePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie'**
  String get documentTypePhoto;

  /// No description provided for @documentTypeOther.
  ///
  /// In pl, this message translates to:
  /// **'Inny dokument'**
  String get documentTypeOther;

  /// No description provided for @documentWarrantyWithout.
  ///
  /// In pl, this message translates to:
  /// **'Bez gwarancji'**
  String get documentWarrantyWithout;

  /// No description provided for @documentWarrantyActive.
  ///
  /// In pl, this message translates to:
  /// **'Aktywna'**
  String get documentWarrantyActive;

  /// No description provided for @documentWarrantyExpiring.
  ///
  /// In pl, this message translates to:
  /// **'Wygasa w ciągu 30 dni'**
  String get documentWarrantyExpiring;

  /// No description provided for @documentWarrantyExpired.
  ///
  /// In pl, this message translates to:
  /// **'Wygasła'**
  String get documentWarrantyExpired;

  /// No description provided for @documentWarrantyUntilValue.
  ///
  /// In pl, this message translates to:
  /// **'Gwarancja do {date}'**
  String documentWarrantyUntilValue(String date);

  /// No description provided for @documentRelationCost.
  ///
  /// In pl, this message translates to:
  /// **'Koszt'**
  String get documentRelationCost;

  /// No description provided for @documentRelationStage.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get documentRelationStage;

  /// No description provided for @documentRelationChecklist.
  ///
  /// In pl, this message translates to:
  /// **'Checklista'**
  String get documentRelationChecklist;

  /// No description provided for @documentRelationContact.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt'**
  String get documentRelationContact;

  /// No description provided for @documentRelationRoom.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie'**
  String get documentRelationRoom;

  /// No description provided for @documentRelationQuote.
  ///
  /// In pl, this message translates to:
  /// **'Oferta'**
  String get documentRelationQuote;

  /// No description provided for @documentRelationDecision.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja'**
  String get documentRelationDecision;

  /// No description provided for @documentRelationDefect.
  ///
  /// In pl, this message translates to:
  /// **'Usterka'**
  String get documentRelationDefect;

  /// No description provided for @documentRelationDevice.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie'**
  String get documentRelationDevice;

  /// No description provided for @budgetReportTitle.
  ///
  /// In pl, this message translates to:
  /// **'Raport budżetowy'**
  String get budgetReportTitle;

  /// No description provided for @budgetReportLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie raportu...'**
  String get budgetReportLoading;

  /// No description provided for @budgetReportNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get budgetReportNoProjectTitle;

  /// No description provided for @budgetReportNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Raport budżetowy jest liczony osobno dla każdego projektu.'**
  String get budgetReportNoProjectMessage;

  /// No description provided for @budgetReportLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać raportu budżetowego.'**
  String get budgetReportLoadError;

  /// No description provided for @budgetReportRemainingHeading.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało do rozdysponowania'**
  String get budgetReportRemainingHeading;

  /// No description provided for @budgetReportOverBudgetHeading.
  ///
  /// In pl, this message translates to:
  /// **'Przekroczenie budżetu'**
  String get budgetReportOverBudgetHeading;

  /// No description provided for @budgetReportNoPlan.
  ///
  /// In pl, this message translates to:
  /// **'Nie ustawiono'**
  String get budgetReportNoPlan;

  /// No description provided for @budgetReportPlanLabel.
  ///
  /// In pl, this message translates to:
  /// **'Plan'**
  String get budgetReportPlanLabel;

  /// No description provided for @budgetReportCommittedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zobowiązania'**
  String get budgetReportCommittedLabel;

  /// No description provided for @budgetReportPaidLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zapłacono'**
  String get budgetReportPaidLabel;

  /// No description provided for @budgetReportRemainingLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało'**
  String get budgetReportRemainingLabel;

  /// No description provided for @budgetReportBreakdownHeading.
  ///
  /// In pl, this message translates to:
  /// **'Struktura kosztów'**
  String get budgetReportBreakdownHeading;

  /// No description provided for @budgetReportDimensionStage.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get budgetReportDimensionStage;

  /// No description provided for @budgetReportDimensionCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get budgetReportDimensionCategory;

  /// No description provided for @budgetReportDimensionSupplier.
  ///
  /// In pl, this message translates to:
  /// **'Wykonawca'**
  String get budgetReportDimensionSupplier;

  /// No description provided for @budgetReportDimensionMonth.
  ///
  /// In pl, this message translates to:
  /// **'Miesiąc'**
  String get budgetReportDimensionMonth;

  /// No description provided for @budgetReportNoAssignment.
  ///
  /// In pl, this message translates to:
  /// **'Bez przypisania'**
  String get budgetReportNoAssignment;

  /// No description provided for @budgetReportPaidDetail.
  ///
  /// In pl, this message translates to:
  /// **'Zapłacono {amount}'**
  String budgetReportPaidDetail(String amount);

  /// No description provided for @budgetReportRecordCount.
  ///
  /// In pl, this message translates to:
  /// **'Pozycji: {count}'**
  String budgetReportRecordCount(int count);

  /// No description provided for @budgetReportEmptyCostsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak kosztów do raportu'**
  String get budgetReportEmptyCostsTitle;

  /// No description provided for @budgetReportEmptyCostsMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zatwierdzony koszt, aby zobaczyć strukturę wydatków.'**
  String get budgetReportEmptyCostsMessage;

  /// No description provided for @backupTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kopia zapasowa i dane'**
  String get backupTitle;

  /// No description provided for @backupScopeHeading.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie dane w jednym pliku'**
  String get backupScopeHeading;

  /// No description provided for @backupScopeDescription.
  ///
  /// In pl, this message translates to:
  /// **'Kopia obejmuje projekty, koszty, etapy, harmonogram, kontakty, dokumenty, zdjęcia i pozostałe pliki.'**
  String get backupScopeDescription;

  /// No description provided for @backupLocalOnlyDescription.
  ///
  /// In pl, this message translates to:
  /// **'Dane pozostają lokalne do chwili eksportu. Kopia ZIP nie jest szyfrowana i może zawierać dokumenty, kontakty oraz zdjęcia, dlatego zapisz ją w zaufanym miejscu.'**
  String get backupLocalOnlyDescription;

  /// No description provided for @backupCreateHeading.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz kopię'**
  String get backupCreateHeading;

  /// No description provided for @backupCreateDescription.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz aktualny stan aplikacji przed ważną zmianą, remontem urządzenia lub odtworzeniem starszej kopii.'**
  String get backupCreateDescription;

  /// No description provided for @backupCreateAction.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz i zapisz kopię'**
  String get backupCreateAction;

  /// No description provided for @backupCreating.
  ///
  /// In pl, this message translates to:
  /// **'Tworzenie i sprawdzanie kopii…'**
  String get backupCreating;

  /// No description provided for @backupCreateSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Kopia została utworzona.'**
  String get backupCreateSuccess;

  /// No description provided for @backupCreateError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się utworzyć kopii. Dane w aplikacji nie zostały zmienione.'**
  String get backupCreateError;

  /// No description provided for @backupRestoreHeading.
  ///
  /// In pl, this message translates to:
  /// **'Odtwórz dane'**
  String get backupRestoreHeading;

  /// No description provided for @backupRestoreDescription.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw sprawdzimy format, sumy kontrolne, bazę danych i wymagane miejsce. Aktualne dane zostaną zastąpione dopiero po potwierdzeniu.'**
  String get backupRestoreDescription;

  /// No description provided for @backupPickAction.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz plik ZIP'**
  String get backupPickAction;

  /// No description provided for @backupInspecting.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdzanie wybranej kopii…'**
  String get backupInspecting;

  /// No description provided for @backupInspectError.
  ///
  /// In pl, this message translates to:
  /// **'Nie można użyć tego pliku. Kopia jest uszkodzona, nieobsługiwana albo nie pochodzi z BudowaPRO.'**
  String get backupInspectError;

  /// No description provided for @backupCandidateHeading.
  ///
  /// In pl, this message translates to:
  /// **'Wybrana kopia'**
  String get backupCandidateHeading;

  /// No description provided for @backupCreatedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Utworzono'**
  String get backupCreatedLabel;

  /// No description provided for @backupSchemaLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wersja danych'**
  String get backupSchemaLabel;

  /// No description provided for @backupProjectsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Projekty'**
  String get backupProjectsLabel;

  /// No description provided for @backupFilesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pliki'**
  String get backupFilesLabel;

  /// No description provided for @backupSizeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rozmiar danych'**
  String get backupSizeLabel;

  /// No description provided for @backupRestoreAction.
  ///
  /// In pl, this message translates to:
  /// **'Odtwórz tę kopię'**
  String get backupRestoreAction;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zastąpić wszystkie dane?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'Aktualne projekty, koszty, dokumenty i zdjęcia zostaną zastąpione zawartością wybranej kopii. Tej operacji nie można cofnąć bez innej kopii zapasowej.'**
  String get backupRestoreConfirmMessage;

  /// No description provided for @backupRestoreConfirmAction.
  ///
  /// In pl, this message translates to:
  /// **'Zastąp dane'**
  String get backupRestoreConfirmAction;

  /// No description provided for @backupRestoring.
  ///
  /// In pl, this message translates to:
  /// **'Odtwarzanie i końcowe sprawdzanie danych…'**
  String get backupRestoring;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Dane zostały bezpiecznie odtworzone.'**
  String get backupRestoreSuccess;

  /// No description provided for @backupRestoreError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odtworzyć kopii. Poprzednie dane zostały zachowane.'**
  String get backupRestoreError;

  /// No description provided for @backupBytesValue.
  ///
  /// In pl, this message translates to:
  /// **'{value} B'**
  String backupBytesValue(String value);

  /// No description provided for @backupKilobytesValue.
  ///
  /// In pl, this message translates to:
  /// **'{value} KB'**
  String backupKilobytesValue(String value);

  /// No description provided for @backupMegabytesValue.
  ///
  /// In pl, this message translates to:
  /// **'{value} MB'**
  String backupMegabytesValue(String value);

  /// No description provided for @backupGigabytesValue.
  ///
  /// In pl, this message translates to:
  /// **'{value} GB'**
  String backupGigabytesValue(String value);

  /// No description provided for @receiptScanTitle.
  ///
  /// In pl, this message translates to:
  /// **'Skan dokumentu zakupu'**
  String get receiptScanTitle;

  /// No description provided for @receiptScanIdleTitle.
  ///
  /// In pl, this message translates to:
  /// **'Paragon lub faktura'**
  String get receiptScanIdleTitle;

  /// No description provided for @receiptScanIdleMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj paragon lub jednostronicową fakturę albo wybierz plik.'**
  String get receiptScanIdleMessage;

  /// No description provided for @receiptScanLocalOnly.
  ///
  /// In pl, this message translates to:
  /// **'Oryginał i OCR pozostają na tym urządzeniu.'**
  String get receiptScanLocalOnly;

  /// No description provided for @receiptScanAction.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj dokument'**
  String get receiptScanAction;

  /// No description provided for @receiptImportAction.
  ///
  /// In pl, this message translates to:
  /// **'Importuj obraz lub PDF'**
  String get receiptImportAction;

  /// No description provided for @receiptCaptureProcessing.
  ///
  /// In pl, this message translates to:
  /// **'Zabezpieczanie oryginału…'**
  String get receiptCaptureProcessing;

  /// No description provided for @receiptRecognitionProcessing.
  ///
  /// In pl, this message translates to:
  /// **'Odczytywanie dokumentu…'**
  String get receiptRecognitionProcessing;

  /// No description provided for @receiptResultTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odczyt z dokumentu'**
  String get receiptResultTitle;

  /// No description provided for @receiptBudgetUnchangedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Budżet bez zmian'**
  String get receiptBudgetUnchangedTitle;

  /// No description provided for @receiptBudgetUnchangedMessage.
  ///
  /// In pl, this message translates to:
  /// **'To propozycja do sprawdzenia. Nie dodano kosztu.'**
  String get receiptBudgetUnchangedMessage;

  /// No description provided for @receiptSellerLabel.
  ///
  /// In pl, this message translates to:
  /// **'Sprzedawca'**
  String get receiptSellerLabel;

  /// No description provided for @receiptDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get receiptDateLabel;

  /// No description provided for @receiptDocumentNumberLabel.
  ///
  /// In pl, this message translates to:
  /// **'Numer dokumentu'**
  String get receiptDocumentNumberLabel;

  /// No description provided for @receiptTotalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Razem na dokumencie'**
  String get receiptTotalLabel;

  /// No description provided for @receiptItemsTotalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Suma pozycji'**
  String get receiptItemsTotalLabel;

  /// No description provided for @receiptUseItemsTotalAction.
  ///
  /// In pl, this message translates to:
  /// **'Użyj sumy pozycji'**
  String get receiptUseItemsTotalAction;

  /// No description provided for @receiptReplaceItemsAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz jako jedną pozycję'**
  String get receiptReplaceItemsAction;

  /// No description provided for @receiptSingleItemDefaultName.
  ///
  /// In pl, this message translates to:
  /// **'Zakup z dokumentu'**
  String get receiptSingleItemDefaultName;

  /// No description provided for @receiptVatLinesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Odczytane linie VAT'**
  String get receiptVatLinesLabel;

  /// No description provided for @receiptItemLinesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Odczytane pozycje'**
  String get receiptItemLinesLabel;

  /// No description provided for @receiptRawTextLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pełny tekst OCR'**
  String get receiptRawTextLabel;

  /// No description provided for @receiptDiscardAction.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć wynik'**
  String get receiptDiscardAction;

  /// No description provided for @receiptRetryOcrAction.
  ///
  /// In pl, this message translates to:
  /// **'Ponów odczyt'**
  String get receiptRetryOcrAction;

  /// No description provided for @receiptScannerUnavailableTitle.
  ///
  /// In pl, this message translates to:
  /// **'Skaner jest niedostępny'**
  String get receiptScannerUnavailableTitle;

  /// No description provided for @receiptScannerUnavailableMessage.
  ///
  /// In pl, this message translates to:
  /// **'Możesz zaimportować zdjęcie dokumentu albo PDF z pamięci telefonu.'**
  String get receiptScannerUnavailableMessage;

  /// No description provided for @receiptUnsupportedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nieobsługiwany plik'**
  String get receiptUnsupportedTitle;

  /// No description provided for @receiptUnsupportedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz czytelny plik JPG, PNG, WEBP albo PDF.'**
  String get receiptUnsupportedMessage;

  /// No description provided for @receiptEmptyTextTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie odczytano tekstu'**
  String get receiptEmptyTextTitle;

  /// No description provided for @receiptEmptyTextMessage.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie lub użyj wyraźniejszego zdjęcia.'**
  String get receiptEmptyTextMessage;

  /// No description provided for @receiptStorageErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zabezpieczyć skanu'**
  String get receiptStorageErrorTitle;

  /// No description provided for @receiptStorageErrorMessage.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź wolne miejsce i spróbuj ponownie.'**
  String get receiptStorageErrorMessage;

  /// No description provided for @receiptRecognitionErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać dokumentu'**
  String get receiptRecognitionErrorTitle;

  /// No description provided for @receiptRecognitionErrorMessage.
  ///
  /// In pl, this message translates to:
  /// **'Oryginał jest zachowany w tej sesji. Możesz ponowić odczyt.'**
  String get receiptRecognitionErrorMessage;

  /// No description provided for @receiptPreviewUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd jest niedostępny.'**
  String get receiptPreviewUnavailable;

  /// No description provided for @receiptGatewayLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się przygotować lokalnego skanera.'**
  String get receiptGatewayLoadError;

  /// No description provided for @receiptSaveProcessing.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie szkiców kosztów…'**
  String get receiptSaveProcessing;

  /// No description provided for @receiptReviewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź dane przed zapisem'**
  String get receiptReviewTitle;

  /// No description provided for @receiptConfidenceNeedsReview.
  ///
  /// In pl, this message translates to:
  /// **'Niepewny odczyt. Popraw wartość albo potwierdź ją ręcznie.'**
  String get receiptConfidenceNeedsReview;

  /// No description provided for @receiptConfirmFieldTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź odczytaną wartość'**
  String get receiptConfirmFieldTooltip;

  /// No description provided for @receiptSellerRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę sprzedawcy.'**
  String get receiptSellerRequiredError;

  /// No description provided for @receiptSellerInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa sprzedawcy jest nieprawidłowa.'**
  String get receiptSellerInvalidError;

  /// No description provided for @receiptDateRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz datę z dokumentu.'**
  String get receiptDateRequiredError;

  /// No description provided for @receiptDateInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz prawidłową datę, np. 25.07.2026.'**
  String get receiptDateInvalidError;

  /// No description provided for @receiptDocumentNumberInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Numer dokumentu jest za długi lub nieprawidłowy.'**
  String get receiptDocumentNumberInvalidError;

  /// No description provided for @receiptTotalRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kwotę razem albo użyj sumy pozycji.'**
  String get receiptTotalRequiredError;

  /// No description provided for @receiptTotalInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz dodatnią kwotę, np. 19,40.'**
  String get receiptTotalInvalidError;

  /// No description provided for @receiptItemVatNeedsReview.
  ///
  /// In pl, this message translates to:
  /// **'OCR nie ustala pewnej stawki VAT. Wybierz stawkę albo potwierdź widoczną wartość.'**
  String get receiptItemVatNeedsReview;

  /// No description provided for @receiptItemNeedsReview.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź nazwę, kwotę i stawkę VAT, a następnie potwierdź pozycję.'**
  String get receiptItemNeedsReview;

  /// No description provided for @receiptConfirmItemTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź pozycję i stawkę VAT'**
  String get receiptConfirmItemTooltip;

  /// No description provided for @receiptItemNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa pozycji'**
  String get receiptItemNameLabel;

  /// No description provided for @receiptGrossAmountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kwota brutto'**
  String get receiptGrossAmountLabel;

  /// No description provided for @receiptItemNameRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę pozycji.'**
  String get receiptItemNameRequiredError;

  /// No description provided for @receiptItemNameInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa pozycji jest za długa lub nieprawidłowa.'**
  String get receiptItemNameInvalidError;

  /// No description provided for @receiptItemAmountInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz dodatnią kwotę brutto.'**
  String get receiptItemAmountInvalidError;

  /// No description provided for @receiptVatRateLabel.
  ///
  /// In pl, this message translates to:
  /// **'VAT'**
  String get receiptVatRateLabel;

  /// No description provided for @receiptAddItemAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pozycję'**
  String get receiptAddItemAction;

  /// No description provided for @receiptMergeNextTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Połącz z następną pozycją'**
  String get receiptMergeNextTooltip;

  /// No description provided for @receiptSplitTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Podziel pozycję'**
  String get receiptSplitTooltip;

  /// No description provided for @receiptRemoveItemTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pozycję'**
  String get receiptRemoveItemTooltip;

  /// No description provided for @receiptSaveDraftsAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz szkice kosztów'**
  String get receiptSaveDraftsAction;

  /// No description provided for @receiptValidationMessage.
  ///
  /// In pl, this message translates to:
  /// **'Popraw pola oznaczone błędem i potwierdź niepewne odczyty oraz stawki VAT.'**
  String get receiptValidationMessage;

  /// No description provided for @receiptTotalMismatchTitle.
  ///
  /// In pl, this message translates to:
  /// **'Suma pozycji różni się od dokumentu'**
  String get receiptTotalMismatchTitle;

  /// No description provided for @receiptTotalMismatchMessage.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź pozycje i kwotę razem. Zapis z różnicą wymaga osobnego potwierdzenia.'**
  String get receiptTotalMismatchMessage;

  /// No description provided for @receiptTotalMismatchAction.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdzam różnicę'**
  String get receiptTotalMismatchAction;

  /// No description provided for @receiptDuplicateTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ten dokument może już być zapisany'**
  String get receiptDuplicateTitle;

  /// No description provided for @receiptDuplicateMessage.
  ///
  /// In pl, this message translates to:
  /// **'Znaleziono zgodność pliku albo sprzedawcy, daty i sumy. Sprawdź dane przed utworzeniem kolejnych szkiców.'**
  String get receiptDuplicateMessage;

  /// No description provided for @receiptDuplicateFileReason.
  ///
  /// In pl, this message translates to:
  /// **'Identyczna zawartość pliku'**
  String get receiptDuplicateFileReason;

  /// No description provided for @receiptDuplicateSignatureReason.
  ///
  /// In pl, this message translates to:
  /// **'Ten sam sprzedawca, data i suma'**
  String get receiptDuplicateSignatureReason;

  /// No description provided for @receiptDuplicateSameAttachmentReason.
  ///
  /// In pl, this message translates to:
  /// **'Ten dokument jest już zapisany'**
  String get receiptDuplicateSameAttachmentReason;

  /// No description provided for @receiptDuplicateAlreadySavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Ten sam dokument został już zapisany. Usuń bieżący skan albo wróć do istniejących szkiców kosztów.'**
  String get receiptDuplicateAlreadySavedMessage;

  /// No description provided for @receiptDuplicateContinueAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz mimo duplikatu'**
  String get receiptDuplicateContinueAction;

  /// No description provided for @receiptSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać szkiców. Dane korekty i skan pozostały w tej sesji.'**
  String get receiptSaveError;

  /// No description provided for @receiptSavedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szkice kosztów zapisane'**
  String get receiptSavedTitle;

  /// No description provided for @receiptSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Liczba zapisanych szkiców kosztów: {count}. Utworzono też jeden dokument zakupu. Budżet zmieni się dopiero po zatwierdzeniu kosztów.'**
  String receiptSavedMessage(int count);

  /// No description provided for @receiptOpenDraftsAction.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz szkice w budżecie'**
  String get receiptOpenDraftsAction;

  /// No description provided for @receiptDoneAction.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get receiptDoneAction;

  /// No description provided for @receiptSplitTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podziel pozycję'**
  String get receiptSplitTitle;

  /// No description provided for @receiptSplitFirstHeading.
  ///
  /// In pl, this message translates to:
  /// **'Pierwsza pozycja'**
  String get receiptSplitFirstHeading;

  /// No description provided for @receiptSplitSecondHeading.
  ///
  /// In pl, this message translates to:
  /// **'Druga pozycja'**
  String get receiptSplitSecondHeading;

  /// No description provided for @receiptSplitApplyAction.
  ///
  /// In pl, this message translates to:
  /// **'Podziel'**
  String get receiptSplitApplyAction;

  /// No description provided for @captureInboxTitle.
  ///
  /// In pl, this message translates to:
  /// **'Skrzynka szybkich zapisów'**
  String get captureInboxTitle;

  /// No description provided for @captureInboxOpenTab.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte ({count})'**
  String captureInboxOpenTab(int count);

  /// No description provided for @captureInboxHistoryTab.
  ///
  /// In pl, this message translates to:
  /// **'Historia ({count})'**
  String captureInboxHistoryTab(int count);

  /// No description provided for @captureInboxNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get captureInboxNoProjectTitle;

  /// No description provided for @captureInboxNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie zapisy są zawsze przypisane do konkretnej budowy lub remontu.'**
  String get captureInboxNoProjectMessage;

  /// No description provided for @captureInboxEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Skrzynka jest pusta'**
  String get captureInboxEmptyTitle;

  /// No description provided for @captureInboxEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie, dokument, notatkę, koszt lub zadanie przyciskiem plus.'**
  String get captureInboxEmptyMessage;

  /// No description provided for @captureInboxHistoryEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak uporządkowanych zapisów'**
  String get captureInboxHistoryEmptyTitle;

  /// No description provided for @captureInboxHistoryEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Tutaj pojawią się pozycje po zatwierdzeniu.'**
  String get captureInboxHistoryEmptyMessage;

  /// No description provided for @captureInboxLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać skrzynki.'**
  String get captureInboxLoadError;

  /// No description provided for @captureAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj szybki zapis'**
  String get captureAddTooltip;

  /// No description provided for @captureAddTitle.
  ///
  /// In pl, this message translates to:
  /// **'Co chcesz zapisać?'**
  String get captureAddTitle;

  /// No description provided for @captureLoadMoreAction.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj kolejne'**
  String get captureLoadMoreAction;

  /// No description provided for @captureLoadingMore.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie…'**
  String get captureLoadingMore;

  /// No description provided for @captureTypeReceiptInvoice.
  ///
  /// In pl, this message translates to:
  /// **'Paragon lub faktura'**
  String get captureTypeReceiptInvoice;

  /// No description provided for @captureTypeAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get captureTypeAll;

  /// No description provided for @captureTypePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie'**
  String get captureTypePhoto;

  /// No description provided for @captureTypeDocument.
  ///
  /// In pl, this message translates to:
  /// **'Dokument'**
  String get captureTypeDocument;

  /// No description provided for @captureTypeNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get captureTypeNote;

  /// No description provided for @captureTypeVoice.
  ///
  /// In pl, this message translates to:
  /// **'Nagranie'**
  String get captureTypeVoice;

  /// No description provided for @captureTypeCost.
  ///
  /// In pl, this message translates to:
  /// **'Koszt'**
  String get captureTypeCost;

  /// No description provided for @captureTypeTask.
  ///
  /// In pl, this message translates to:
  /// **'Zadanie'**
  String get captureTypeTask;

  /// No description provided for @captureTypeDecision.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja'**
  String get captureTypeDecision;

  /// No description provided for @captureTypeDefect.
  ///
  /// In pl, this message translates to:
  /// **'Usterka'**
  String get captureTypeDefect;

  /// No description provided for @captureStatusReady.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe do zatwierdzenia'**
  String get captureStatusReady;

  /// No description provided for @captureStatusNeedsReview.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga uzupełnienia'**
  String get captureStatusNeedsReview;

  /// No description provided for @captureStatusClassified.
  ///
  /// In pl, this message translates to:
  /// **'Uporządkowane'**
  String get captureStatusClassified;

  /// No description provided for @captureMissingFields.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij: {fields}'**
  String captureMissingFields(String fields);

  /// No description provided for @captureMissingTitle.
  ///
  /// In pl, this message translates to:
  /// **'tytuł'**
  String get captureMissingTitle;

  /// No description provided for @captureMissingContent.
  ///
  /// In pl, this message translates to:
  /// **'opis'**
  String get captureMissingContent;

  /// No description provided for @captureMissingAttachment.
  ///
  /// In pl, this message translates to:
  /// **'plik'**
  String get captureMissingAttachment;

  /// No description provided for @captureMissingGrossAmount.
  ///
  /// In pl, this message translates to:
  /// **'kwotę brutto'**
  String get captureMissingGrossAmount;

  /// No description provided for @captureMissingVatRate.
  ///
  /// In pl, this message translates to:
  /// **'stawkę VAT'**
  String get captureMissingVatRate;

  /// No description provided for @captureMissingScheduledAt.
  ///
  /// In pl, this message translates to:
  /// **'termin'**
  String get captureMissingScheduledAt;

  /// No description provided for @captureEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij lub popraw'**
  String get captureEditTooltip;

  /// No description provided for @captureApproveTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź i przypisz'**
  String get captureApproveTooltip;

  /// No description provided for @captureMergeTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Połącz podobne zapisy'**
  String get captureMergeTooltip;

  /// No description provided for @captureRejectTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć zapis'**
  String get captureRejectTooltip;

  /// No description provided for @captureRejectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucić szybki zapis?'**
  String get captureRejectTitle;

  /// No description provided for @captureRejectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Niepowiązany plik lokalny także zostanie usunięty. Tej operacji nie można cofnąć.'**
  String get captureRejectMessage;

  /// No description provided for @captureMergeTitle.
  ///
  /// In pl, this message translates to:
  /// **'Połącz z podobnym zapisem'**
  String get captureMergeTitle;

  /// No description provided for @captureMergeEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak innego otwartego zapisu tego typu.'**
  String get captureMergeEmpty;

  /// No description provided for @captureEditorNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy szybki zapis'**
  String get captureEditorNewTitle;

  /// No description provided for @captureEditorEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij zapis'**
  String get captureEditorEditTitle;

  /// No description provided for @captureTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get captureTitleLabel;

  /// No description provided for @captureContentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis lub ustalenia'**
  String get captureContentLabel;

  /// No description provided for @captureGrossAmountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kwota brutto ({currencyCode})'**
  String captureGrossAmountLabel(String currencyCode);

  /// No description provided for @captureVatRateLabel.
  ///
  /// In pl, this message translates to:
  /// **'VAT'**
  String get captureVatRateLabel;

  /// No description provided for @captureDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get captureDateLabel;

  /// No description provided for @captureTimeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Godzina'**
  String get captureTimeLabel;

  /// No description provided for @captureChooseDateAction.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę'**
  String get captureChooseDateAction;

  /// No description provided for @captureChooseTimeAction.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz godzinę'**
  String get captureChooseTimeAction;

  /// No description provided for @captureSaveDraftAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz w skrzynce'**
  String get captureSaveDraftAction;

  /// No description provided for @captureUpdateAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get captureUpdateAction;

  /// No description provided for @captureValidationTitle.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij wymagane pola'**
  String get captureValidationTitle;

  /// No description provided for @captureValidationMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zapis może pozostać niekompletny, ale tytuł ułatwi jego późniejsze odnalezienie.'**
  String get captureValidationMessage;

  /// No description provided for @captureActionError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wykonać operacji.'**
  String get captureActionError;

  /// No description provided for @capturePickCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Nie wybrano pliku.'**
  String get capturePickCancelled;

  /// No description provided for @captureClassifiedDocument.
  ///
  /// In pl, this message translates to:
  /// **'Dokumentacja'**
  String get captureClassifiedDocument;

  /// No description provided for @captureClassifiedCost.
  ///
  /// In pl, this message translates to:
  /// **'Szkic kosztu'**
  String get captureClassifiedCost;

  /// No description provided for @captureClassifiedTask.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram'**
  String get captureClassifiedTask;

  /// No description provided for @captureClassifiedNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get captureClassifiedNote;

  /// No description provided for @captureClassifiedDecision.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja'**
  String get captureClassifiedDecision;

  /// No description provided for @captureClassifiedDefect.
  ///
  /// In pl, this message translates to:
  /// **'Usterka'**
  String get captureClassifiedDefect;

  /// No description provided for @captureCostDraftNotice.
  ///
  /// In pl, this message translates to:
  /// **'Po zatwierdzeniu powstanie szkic kosztu. Suma budowy zmieni się dopiero po jego potwierdzeniu.'**
  String get captureCostDraftNotice;

  /// No description provided for @captureVoiceNotice.
  ///
  /// In pl, this message translates to:
  /// **'Nagranie zostanie zachowane lokalnie. Transkrypcja nie jest wymagana.'**
  String get captureVoiceNotice;

  /// No description provided for @captureFileNotice.
  ///
  /// In pl, this message translates to:
  /// **'Plik jest kopiowany do prywatnej pamięci projektu.'**
  String get captureFileNotice;

  /// No description provided for @captureSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zapis dodano do skrzynki.'**
  String get captureSavedMessage;

  /// No description provided for @captureApprovedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zapis został uporządkowany.'**
  String get captureApprovedMessage;

  /// No description provided for @legalCenterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prywatność i prawo'**
  String get legalCenterTitle;

  /// No description provided for @legalCenterTileSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Polityka, warunki i kontrola danych'**
  String get legalCenterTileSubtitle;

  /// No description provided for @legalDocumentsSection.
  ///
  /// In pl, this message translates to:
  /// **'Dokumenty i ustawienia'**
  String get legalDocumentsSection;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyTileSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak aplikacja przechowuje i przetwarza dane'**
  String get privacyPolicyTileSubtitle;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In pl, this message translates to:
  /// **'Warunki użytkowania'**
  String get termsOfUseTitle;

  /// No description provided for @termsOfUseTileSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zasady korzystania i granice porad budowlanych'**
  String get termsOfUseTileSubtitle;

  /// No description provided for @privacySettingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia prywatności'**
  String get privacySettingsTitle;

  /// No description provided for @privacySettingsTileSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Status usług, uprawnień i kopii danych'**
  String get privacySettingsTileSubtitle;

  /// No description provided for @openSourceLicensesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Licencje open source'**
  String get openSourceLicensesTitle;

  /// No description provided for @legalPublisherSection.
  ///
  /// In pl, this message translates to:
  /// **'Wydawca i kontakt'**
  String get legalPublisherSection;

  /// No description provided for @legalPublisherLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wydawca aplikacji'**
  String get legalPublisherLabel;

  /// No description provided for @legalContactLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt w sprawach prywatności'**
  String get legalContactLabel;

  /// No description provided for @legalNotConfiguredValue.
  ///
  /// In pl, this message translates to:
  /// **'Nie skonfigurowano do wydania'**
  String get legalNotConfiguredValue;

  /// No description provided for @legalEmailSubject.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO — prywatność'**
  String get legalEmailSubject;

  /// No description provided for @legalPublicPolicyLabel.
  ///
  /// In pl, this message translates to:
  /// **'Publiczna kopia polityki'**
  String get legalPublicPolicyLabel;

  /// No description provided for @legalDocumentVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja 1.0 · obowiązuje od 28.07.2026'**
  String get legalDocumentVersion;

  /// No description provided for @legalIntroTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prywatność dostępna w aplikacji'**
  String get legalIntroTitle;

  /// No description provided for @legalIntroMessage.
  ///
  /// In pl, this message translates to:
  /// **'W jednym miejscu sprawdzisz zasady, faktyczne przepływy danych i sposoby zarządzania lokalną zawartością.'**
  String get legalIntroMessage;

  /// No description provided for @legalReleaseConfigMissingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wydanie wymaga uzupełnienia'**
  String get legalReleaseConfigMissingTitle;

  /// No description provided for @legalReleaseConfigMissingMessage.
  ///
  /// In pl, this message translates to:
  /// **'Brakuje: {fields}. Kompilacja release pozostaje zablokowana, aby nie opublikować niepełnych danych prawnych.'**
  String legalReleaseConfigMissingMessage(String fields);

  /// No description provided for @legalMissingPublisherRequirement.
  ///
  /// In pl, this message translates to:
  /// **'nazwa wydawcy'**
  String get legalMissingPublisherRequirement;

  /// No description provided for @legalMissingEmailRequirement.
  ///
  /// In pl, this message translates to:
  /// **'prawidłowy e-mail'**
  String get legalMissingEmailRequirement;

  /// No description provided for @legalMissingPublicUrlRequirement.
  ///
  /// In pl, this message translates to:
  /// **'publiczny adres HTTPS polityki'**
  String get legalMissingPublicUrlRequirement;

  /// No description provided for @legalOpenLinkError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć odnośnika.'**
  String get legalOpenLinkError;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In pl, this message translates to:
  /// **'Poniższe sekcje opisują rzeczywiste działanie BudowaPRO. Rozwiń temat, aby przeczytać szczegóły.'**
  String get privacyPolicyIntro;

  /// No description provided for @termsOfUseIntro.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO pomaga organizować budowę lub remont, ale nie zastępuje projektu, kierownika budowy ani uprawnionego specjalisty.'**
  String get termsOfUseIntro;

  /// No description provided for @legalOfficialSourcesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Oficjalne źródła'**
  String get legalOfficialSourcesTitle;

  /// No description provided for @legalSourceMlKitTerms.
  ///
  /// In pl, this message translates to:
  /// **'Google ML Kit — warunki i prywatność'**
  String get legalSourceMlKitTerms;

  /// No description provided for @legalSourceMlKitDisclosure.
  ///
  /// In pl, this message translates to:
  /// **'Google ML Kit — ujawnianie danych w Google Play'**
  String get legalSourceMlKitDisclosure;

  /// No description provided for @legalSourceGooglePrivacy.
  ///
  /// In pl, this message translates to:
  /// **'Google — polityka prywatności'**
  String get legalSourceGooglePrivacy;

  /// No description provided for @legalSourceGdpr.
  ///
  /// In pl, this message translates to:
  /// **'RODO — rozporządzenie (UE) 2016/679'**
  String get legalSourceGdpr;

  /// No description provided for @legalSourceUodo.
  ///
  /// In pl, this message translates to:
  /// **'UODO — prawo do złożenia skargi'**
  String get legalSourceUodo;

  /// No description provided for @privacySectionPublisherTitle.
  ///
  /// In pl, this message translates to:
  /// **'1. Wydawca i zakres polityki'**
  String get privacySectionPublisherTitle;

  /// No description provided for @privacySectionPublisherBody.
  ///
  /// In pl, this message translates to:
  /// **'Podmiot wskazany jako wydawca BudowaPRO: {publisher}. Kontakt w sprawach prywatności: {contact}. Aplikacja nie wymaga konta i nie ma serwera BudowaPRO. Wydawca nie ma zdalnego dostępu do treści zapisanych wyłącznie w prywatnej pamięci aplikacji.'**
  String privacySectionPublisherBody(String publisher, String contact);

  /// No description provided for @privacySectionLocalDataTitle.
  ///
  /// In pl, this message translates to:
  /// **'2. Dane przechowywane lokalnie'**
  String get privacySectionLocalDataTitle;

  /// No description provided for @privacySectionLocalDataBody.
  ///
  /// In pl, this message translates to:
  /// **'Na urządzeniu mogą być zapisane dane projektów, budżetów, kosztów, wykonawców i kontaktów, terminów, notatek, decyzji, usterek, dokumentów, zdjęć, skanów, wyników OCR oraz ręcznych kopii zapasowych. BudowaPRO zapisuje je w prywatnej pamięci aplikacji. Nie przesyła tych treści do własnego backendu, ponieważ taki backend nie istnieje.'**
  String get privacySectionLocalDataBody;

  /// No description provided for @privacySectionPurposeTitle.
  ///
  /// In pl, this message translates to:
  /// **'3. Cel i sposób przetwarzania'**
  String get privacySectionPurposeTitle;

  /// No description provided for @privacySectionPurposeBody.
  ///
  /// In pl, this message translates to:
  /// **'Lokalne operacje uruchamiasz samodzielnie, aby prowadzić projekt, liczyć koszty, planować prace, przechowywać dokumentację i tworzyć kopie. BudowaPRO nie używa danych do reklam, profilowania, sprzedaży danych ani marketingu. Nie ma automatycznych decyzji wywołujących skutki prawne.'**
  String get privacySectionPurposeBody;

  /// No description provided for @privacySectionOcrTitle.
  ///
  /// In pl, this message translates to:
  /// **'4. Skaner i Google ML Kit'**
  String get privacySectionOcrTitle;

  /// No description provided for @privacySectionOcrBody.
  ///
  /// In pl, this message translates to:
  /// **'Rozpoznawanie obrazu i tekstu odbywa się na urządzeniu. Zgodnie z dokumentacją Google obrazy, tekst wejściowy i wynik OCR nie są wysyłane do serwerów Google. Biblioteki ML Kit mogą jednak kontaktować się z Google po aktualizacje i wysyłać zaszyfrowane metryki techniczne: informacje o urządzeniu i aplikacji, identyfikator instalacji, parametry i wydajność funkcji, typy zdarzeń oraz kody błędów. Google używa ich do diagnostyki i analityki wykorzystania ML Kit.'**
  String get privacySectionOcrBody;

  /// No description provided for @privacySectionSharingTitle.
  ///
  /// In pl, this message translates to:
  /// **'5. Odbiorcy i udostępnianie'**
  String get privacySectionSharingTitle;

  /// No description provided for @privacySectionSharingBody.
  ///
  /// In pl, this message translates to:
  /// **'Poza technicznymi metrykami ML Kit BudowaPRO nie udostępnia danych automatycznie. Eksport CSV, kopia ZIP, telefon, e-mail albo systemowe udostępnianie uruchamiają się dopiero po Twojej akcji i przekazują wybraną zawartość do wskazanej przez Ciebie aplikacji lub dostawcy. Ręczna kopia ZIP nie jest szyfrowana i może zawierać dokumenty, kontakty oraz zdjęcia. Dalsze przetwarzanie podlega zasadom wybranego odbiorcy.'**
  String get privacySectionSharingBody;

  /// No description provided for @privacySectionRetentionTitle.
  ///
  /// In pl, this message translates to:
  /// **'6. Okres przechowywania i usuwanie'**
  String get privacySectionRetentionTitle;

  /// No description provided for @privacySectionRetentionBody.
  ///
  /// In pl, this message translates to:
  /// **'Dane pozostają w aplikacji do czasu usunięcia rekordu lub projektu, wyczyszczenia danych BudowaPRO w ustawieniach Androida albo odinstalowania aplikacji. Ręcznie wyeksportowane pliki pozostają w wybranej lokalizacji do czasu, aż usuniesz je osobno. Automatyczny backup danych aplikacji jest wyłączony i wykluczony w regułach Androida.'**
  String get privacySectionRetentionBody;

  /// No description provided for @privacySectionRightsTitle.
  ///
  /// In pl, this message translates to:
  /// **'7. Kontrola danych i prawa'**
  String get privacySectionRightsTitle;

  /// No description provided for @privacySectionRightsBody.
  ///
  /// In pl, this message translates to:
  /// **'Dane lokalne możesz przeglądać, poprawiać, eksportować i usuwać w aplikacji. Ponieważ wydawca nie posiada ich zdalnej kopii, nie może zwrócić ani usunąć jej za Ciebie. Pytania dotyczące działania aplikacji kieruj na: {contact}. W zakresie objętym RODO możesz realizować prawa wobec właściwego administratora danych i złożyć skargę do Prezesa UODO.'**
  String privacySectionRightsBody(String contact);

  /// No description provided for @privacySectionSecurityTitle.
  ///
  /// In pl, this message translates to:
  /// **'8. Bezpieczeństwo'**
  String get privacySectionSecurityTitle;

  /// No description provided for @privacySectionSecurityBody.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO używa prywatnych katalogów aplikacji, weryfikuje kopie i ogranicza uprawnienia systemowe. Chroń telefon blokadą ekranu i przechowuj ręczne kopie w zaufanym miejscu. Żadne zabezpieczenie nie usuwa ryzyka utraty danych po uszkodzeniu urządzenia, złośliwym oprogramowaniu lub udostępnieniu odblokowanego telefonu.'**
  String get privacySectionSecurityBody;

  /// No description provided for @privacySectionChangesTitle.
  ///
  /// In pl, this message translates to:
  /// **'9. Zmiany polityki'**
  String get privacySectionChangesTitle;

  /// No description provided for @privacySectionChangesBody.
  ///
  /// In pl, this message translates to:
  /// **'Istotna zmiana funkcji, dostawcy SDK lub przepływu danych wymaga aktualizacji tej polityki i sekcji Bezpieczeństwo danych w Google Play. Aktualna wersja pozostaje dostępna w aplikacji oraz pod publicznym adresem wskazanym w Google Play.'**
  String get privacySectionChangesBody;

  /// No description provided for @termsSectionProviderTitle.
  ///
  /// In pl, this message translates to:
  /// **'1. Usługodawca'**
  String get termsSectionProviderTitle;

  /// No description provided for @termsSectionProviderBody.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO udostępnia: {publisher}. Kontakt: {contact}. Korzystanie z aplikacji nie wymaga utworzenia konta ani zawarcia odpłatnej subskrypcji w tej wersji.'**
  String termsSectionProviderBody(String publisher, String contact);

  /// No description provided for @termsSectionPurposeTitle.
  ///
  /// In pl, this message translates to:
  /// **'2. Przeznaczenie aplikacji'**
  String get termsSectionPurposeTitle;

  /// No description provided for @termsSectionPurposeBody.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja służy do prywatnego organizowania budowy lub remontu: kosztów, etapów, kontaktów, dokumentów, terminów, zdjęć i notatek. Użytkownik może korzystać z niej wyłącznie zgodnie z prawem i prawami osób trzecich.'**
  String get termsSectionPurposeBody;

  /// No description provided for @termsSectionSafetyTitle.
  ///
  /// In pl, this message translates to:
  /// **'3. Informacje budowlane i bezpieczeństwo'**
  String get termsSectionSafetyTitle;

  /// No description provided for @termsSectionSafetyBody.
  ///
  /// In pl, this message translates to:
  /// **'Checklisty i wskazówki mają charakter organizacyjny i informacyjny. Nie są projektem budowlanym, opinią techniczną ani indywidualnym doborem rozwiązania. Przed wykonaniem robót zweryfikuj aktualne przepisy, projekt, warunki gruntowe, instrukcje producenta i ustalenia z projektantem, kierownikiem budowy lub osobą z wymaganymi uprawnieniami.'**
  String get termsSectionSafetyBody;

  /// No description provided for @termsSectionUserDataTitle.
  ///
  /// In pl, this message translates to:
  /// **'4. Dane użytkownika i kopie'**
  String get termsSectionUserDataTitle;

  /// No description provided for @termsSectionUserDataBody.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiadasz za legalność wprowadzanych kontaktów, zdjęć i dokumentów oraz za posiadanie prawa do ich użycia. Dane są lokalne. Regularnie twórz ręczną kopię i sprawdzaj możliwość jej odtworzenia. Usunięcie projektu, wyczyszczenie pamięci lub utrata telefonu może być nieodwracalne bez poprawnej kopii.'**
  String get termsSectionUserDataBody;

  /// No description provided for @termsSectionOcrTitle.
  ///
  /// In pl, this message translates to:
  /// **'5. OCR i obliczenia'**
  String get termsSectionOcrTitle;

  /// No description provided for @termsSectionOcrBody.
  ///
  /// In pl, this message translates to:
  /// **'OCR może błędnie odczytać nazwę, datę, pozycję, VAT lub kwotę. Każdy wynik trzeba sprawdzić przed zapisem i zatwierdzeniem kosztu. Podsumowania zależą od poprawności danych wprowadzonych lub zaakceptowanych przez użytkownika.'**
  String get termsSectionOcrBody;

  /// No description provided for @termsSectionAvailabilityTitle.
  ///
  /// In pl, this message translates to:
  /// **'6. Dostępność i aktualizacje'**
  String get termsSectionAvailabilityTitle;

  /// No description provided for @termsSectionAvailabilityBody.
  ///
  /// In pl, this message translates to:
  /// **'Nie gwarantuje się nieprzerwanego działania na każdym urządzeniu ani zgodności ze wszystkimi formatami dokumentów. Aktualizacje mogą poprawiać bezpieczeństwo, zgodność z Androidem i zakres funkcji, z zachowaniem lokalnych danych w ramach obsługiwanych migracji.'**
  String get termsSectionAvailabilityBody;

  /// No description provided for @termsSectionLiabilityTitle.
  ///
  /// In pl, this message translates to:
  /// **'7. Odpowiedzialność'**
  String get termsSectionLiabilityTitle;

  /// No description provided for @termsSectionLiabilityBody.
  ///
  /// In pl, this message translates to:
  /// **'Wydawca odpowiada w granicach bezwzględnie obowiązującego prawa. Warunki nie wyłączają ani nie ograniczają ustawowych praw konsumenta. Użytkownik odpowiada za decyzje budowlane podjęte bez wymaganej weryfikacji specjalisty oraz za skutki podania nieprawidłowych danych.'**
  String get termsSectionLiabilityBody;

  /// No description provided for @termsSectionLawTitle.
  ///
  /// In pl, this message translates to:
  /// **'8. Prawo i spory'**
  String get termsSectionLawTitle;

  /// No description provided for @termsSectionLawBody.
  ///
  /// In pl, this message translates to:
  /// **'Stosuje się prawo polskie, bez uszczerbku dla bezwzględnie obowiązujących praw konsumenta wynikających z prawa miejsca jego zamieszkania. Spór można najpierw zgłosić wydawcy na podany adres kontaktowy.'**
  String get termsSectionLawBody;

  /// No description provided for @termsSectionChangesTitle.
  ///
  /// In pl, this message translates to:
  /// **'9. Zmiany warunków'**
  String get termsSectionChangesTitle;

  /// No description provided for @termsSectionChangesBody.
  ///
  /// In pl, this message translates to:
  /// **'Nowa wersja warunków powinna otrzymać nową datę i być dostępna przed publikacją aktualizacji, jeżeli zmiana wpływa na prawa użytkownika lub sposób działania aplikacji.'**
  String get termsSectionChangesBody;

  /// No description provided for @privacySettingsIntro.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO nie ma konta, reklam ani własnej analityki. Ten ekran pokazuje realne ustawienia i wyjątek techniczny związany z Google ML Kit.'**
  String get privacySettingsIntro;

  /// No description provided for @privacyStatusSection.
  ///
  /// In pl, this message translates to:
  /// **'Bieżący status'**
  String get privacyStatusSection;

  /// No description provided for @privacyStatusLocalTitle.
  ///
  /// In pl, this message translates to:
  /// **'Treści projektu pozostają lokalnie'**
  String get privacyStatusLocalTitle;

  /// No description provided for @privacyStatusLocalSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Baza, zdjęcia, dokumenty i OCR są zapisywane w prywatnej pamięci aplikacji.'**
  String get privacyStatusLocalSubtitle;

  /// No description provided for @privacyStatusAccountTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak konta i synchronizacji'**
  String get privacyStatusAccountTitle;

  /// No description provided for @privacyStatusAccountSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO nie ma logowania, profilu użytkownika ani własnego backendu.'**
  String get privacyStatusAccountSubtitle;

  /// No description provided for @privacyStatusTrackingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak reklam i śledzenia marketingowego'**
  String get privacyStatusTrackingTitle;

  /// No description provided for @privacyStatusTrackingSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja nie używa reklam, Firebase Analytics ani Crashlytics. Metryki techniczne ML Kit opisano osobno.'**
  String get privacyStatusTrackingSubtitle;

  /// No description provided for @privacyStatusMlKitTitle.
  ///
  /// In pl, this message translates to:
  /// **'Techniczne metryki Google ML Kit'**
  String get privacyStatusMlKitTitle;

  /// No description provided for @privacyStatusMlKitSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Po użyciu skanera lub OCR Google może otrzymać metryki urządzenia, aplikacji, wydajności i błędów — bez obrazu, tekstu dokumentu i wyniku OCR.'**
  String get privacyStatusMlKitSubtitle;

  /// No description provided for @privacyPermissionsSection.
  ///
  /// In pl, this message translates to:
  /// **'Uprawnienia i usługi Androida'**
  String get privacyPermissionsSection;

  /// No description provided for @privacyPermissionNotificationsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get privacyPermissionNotificationsTitle;

  /// No description provided for @privacyPermissionNotificationsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Służą wyłącznie lokalnym przypomnieniom i są uruchamiane po decyzji użytkownika.'**
  String get privacyPermissionNotificationsSubtitle;

  /// No description provided for @privacyPermissionContactsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kontakty'**
  String get privacyPermissionContactsTitle;

  /// No description provided for @privacyPermissionContactsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierasz pojedynczy kontakt przez systemowy selektor. Aplikacja nie żąda szerokiego odczytu książki kontaktów.'**
  String get privacyPermissionContactsSubtitle;

  /// No description provided for @privacyPermissionFilesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia, pliki i aparat'**
  String get privacyPermissionFilesTitle;

  /// No description provided for @privacyPermissionFilesSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Systemowy selektor lub skaner otwiera się dopiero po Twojej akcji. Manifest nie żąda szerokiego dostępu do pamięci ani kontaktów.'**
  String get privacyPermissionFilesSubtitle;

  /// No description provided for @privacyAutomaticBackupTitle.
  ///
  /// In pl, this message translates to:
  /// **'Automatyczny backup Androida wyłączony'**
  String get privacyAutomaticBackupTitle;

  /// No description provided for @privacyAutomaticBackupSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO deklaruje wykluczenie prywatnych plików z kopii chmurowej i przenoszenia urządzenie–urządzenie. Ręczna kopia ZIP nie jest szyfrowana.'**
  String get privacyAutomaticBackupSubtitle;

  /// No description provided for @privacyDataControlSection.
  ///
  /// In pl, this message translates to:
  /// **'Kontrola danych'**
  String get privacyDataControlSection;

  /// No description provided for @privacyCreateBackupTitle.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz lub odtwórz kopię'**
  String get privacyCreateBackupTitle;

  /// No description provided for @privacyCreateBackupSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Sam wybierasz lokalizację. Plik ZIP nie jest szyfrowany, dlatego przechowuj go w zaufanym miejscu.'**
  String get privacyCreateBackupSubtitle;

  /// No description provided for @privacyDeleteDataHelp.
  ///
  /// In pl, this message translates to:
  /// **'Pojedynczy projekt usuń z jego ustawień. Wszystkie dane prywatne usuniesz przez „Wyczyść dane” w ustawieniach Androida albo odinstalowanie aplikacji. Ręczne kopie i eksporty trzeba usunąć osobno.'**
  String get privacyDeleteDataHelp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
