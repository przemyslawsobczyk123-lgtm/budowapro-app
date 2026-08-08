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

  /// Etykieta glownej zakladki Etapy.
  ///
  /// In pl, this message translates to:
  /// **'Etapy'**
  String get navStages;

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
  /// **'Brak terminów dla aktywnego projektu.'**
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

  /// No description provided for @costRegisterComponentSection.
  ///
  /// In pl, this message translates to:
  /// **'Skład kosztu'**
  String get costRegisterComponentSection;

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

  /// No description provided for @costCsvShareTitle.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO - eksport kosztów'**
  String get costCsvShareTitle;

  /// No description provided for @costCsvLifecycleColumn.
  ///
  /// In pl, this message translates to:
  /// **'Tryb wpisu'**
  String get costCsvLifecycleColumn;

  /// No description provided for @costCsvComponentColumn.
  ///
  /// In pl, this message translates to:
  /// **'Skład kosztu'**
  String get costCsvComponentColumn;

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

  /// No description provided for @costComponentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Skład kosztu'**
  String get costComponentLabel;

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

  /// No description provided for @costComponentMaterial.
  ///
  /// In pl, this message translates to:
  /// **'Materiał'**
  String get costComponentMaterial;

  /// No description provided for @costComponentLabor.
  ///
  /// In pl, this message translates to:
  /// **'Robocizna'**
  String get costComponentLabor;

  /// No description provided for @costComponentMixed.
  ///
  /// In pl, this message translates to:
  /// **'Wspólna wycena: materiał + robocizna'**
  String get costComponentMixed;

  /// No description provided for @costComponentUnassigned.
  ///
  /// In pl, this message translates to:
  /// **'Nieprzypisane'**
  String get costComponentUnassigned;

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
  /// **'Rodzaj i status zatwierdzonego wpisu są zablokowane.'**
  String get costFinancialFieldsLocked;

  /// No description provided for @costAmountCorrectionHint.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana kwoty zapisze korektę i zachowa pierwotną wartość w historii.'**
  String get costAmountCorrectionHint;

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

  /// No description provided for @costRelationsSection.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane dane'**
  String get costRelationsSection;

  /// No description provided for @costRelationRoomLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie'**
  String get costRelationRoomLabel;

  /// No description provided for @costRelationMaterialLabel.
  ///
  /// In pl, this message translates to:
  /// **'Materiał'**
  String get costRelationMaterialLabel;

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

  /// No description provided for @stagesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Etapy budowy'**
  String get stagesTitle;

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

  /// No description provided for @stageCurrentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Bieżący etap'**
  String get stageCurrentLabel;

  /// No description provided for @stageSetCurrentAction.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw jako bieżący'**
  String get stageSetCurrentAction;

  /// No description provided for @stageCompleteAction.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako ukończony'**
  String get stageCompleteAction;

  /// No description provided for @stageReopenAction.
  ///
  /// In pl, this message translates to:
  /// **'Wznów etap'**
  String get stageReopenAction;

  /// No description provided for @stageCompleteWithOpenItemsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Etap ma otwarte punkty'**
  String get stageCompleteWithOpenItemsTitle;

  /// No description provided for @stageCompleteWithOpenItemsMessage.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało otwartych punktów: {count}. Możesz mimo to oznaczyć etap jako ukończony, jeśli świadomie przenosisz je poza zakres albo rozliczysz je później.'**
  String stageCompleteWithOpenItemsMessage(int count);

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
  /// **'Zalecana dokumentacja'**
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
  /// **'Zapisana notatka o braku dokumentacji'**
  String get checklistEvidenceWaived;

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

  /// No description provided for @checklistPlanningScopeAndBudget.
  ///
  /// In pl, this message translates to:
  /// **'Ustal zakres remontu, budżet i rezerwę'**
  String get checklistPlanningScopeAndBudget;

  /// No description provided for @checklistPlanningScopeAndBudgetRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak zakresu i rezerwy utrudnia porównanie ofert oraz zwiększa ryzyko kosztownych zmian w trakcie robót.'**
  String get checklistPlanningScopeAndBudgetRisk;

  /// No description provided for @checklistExistingBuildingSurvey.
  ///
  /// In pl, this message translates to:
  /// **'Zrób inwentaryzację istniejącego stanu'**
  String get checklistExistingBuildingSurvey;

  /// No description provided for @checklistExistingBuildingSurveyRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieudokumentowane wymiary, instalacje i uszkodzenia mogą prowadzić do kolizji oraz sporów przy remoncie.'**
  String get checklistExistingBuildingSurveyRisk;

  /// No description provided for @checklistDesignDecisionsRegister.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz decyzje materiałowe i wykonawcze'**
  String get checklistDesignDecisionsRegister;

  /// No description provided for @checklistDesignDecisionsRegisterRisk.
  ///
  /// In pl, this message translates to:
  /// **'Ustalenia ustne łatwo się rozchodzą, a późniejsze zmiany zwiększają koszt i opóźnienie.'**
  String get checklistDesignDecisionsRegisterRisk;

  /// No description provided for @checklistDemolitionHazardSurvey.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź zagrożenia przed rozbiórką'**
  String get checklistDemolitionHazardSurvey;

  /// No description provided for @checklistDemolitionHazardSurveyRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany azbest, szkło, instalacje pod napięciem lub niestabilne elementy mogą zagrozić zdrowiu i konstrukcji.'**
  String get checklistDemolitionHazardSurveyRisk;

  /// No description provided for @checklistUtilityDisconnectionAndProtection.
  ///
  /// In pl, this message translates to:
  /// **'Odłącz i zabezpiecz istniejące instalacje'**
  String get checklistUtilityDisconnectionAndProtection;

  /// No description provided for @checklistUtilityDisconnectionAndProtectionRisk.
  ///
  /// In pl, this message translates to:
  /// **'Pozostawione zasilanie, gaz, woda lub kanalizacja może spowodować porażenie, zalanie albo pożar.'**
  String get checklistUtilityDisconnectionAndProtectionRisk;

  /// No description provided for @checklistDemolitionPlanAndWaste.
  ///
  /// In pl, this message translates to:
  /// **'Ustal kolejność rozbiórki i odbiór odpadów'**
  String get checklistDemolitionPlanAndWaste;

  /// No description provided for @checklistDemolitionPlanAndWasteRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak kolejności może naruszyć stateczność budynku, a odpady bez segregacji utrudnią legalne przekazanie.'**
  String get checklistDemolitionPlanAndWasteRisk;

  /// No description provided for @checklistNeighborAndCommonAreaProtection.
  ///
  /// In pl, this message translates to:
  /// **'Zabezpiecz sąsiadów i części wspólne'**
  String get checklistNeighborAndCommonAreaProtection;

  /// No description provided for @checklistNeighborAndCommonAreaProtectionRisk.
  ///
  /// In pl, this message translates to:
  /// **'Pył, hałas, drgania i uszkodzenia komunikacji wspólnej mogą zatrzymać prace i wywołać roszczenia.'**
  String get checklistNeighborAndCommonAreaProtectionRisk;

  /// No description provided for @checklistDemolitionCompletionInspection.
  ///
  /// In pl, this message translates to:
  /// **'Odbierz stan po rozbiórce'**
  String get checklistDemolitionCompletionInspection;

  /// No description provided for @checklistDemolitionCompletionInspectionRisk.
  ///
  /// In pl, this message translates to:
  /// **'Pozostawione odpady, otwarte przejścia lub niezinwentaryzowane uszkodzenia utrudnią bezpieczny kolejny etap.'**
  String get checklistDemolitionCompletionInspectionRisk;

  /// No description provided for @checklistShellStructuralAcceptance.
  ///
  /// In pl, this message translates to:
  /// **'Odbierz konstrukcję i elementy przed zakryciem'**
  String get checklistShellStructuralAcceptance;

  /// No description provided for @checklistShellStructuralAcceptanceRisk.
  ///
  /// In pl, this message translates to:
  /// **'Błąd zbrojenia, geometrii lub otworu po zakryciu jest trudny do wykrycia i naprawy.'**
  String get checklistShellStructuralAcceptanceRisk;

  /// No description provided for @checklistRoofWeatherProtection.
  ///
  /// In pl, this message translates to:
  /// **'Zabezpiecz dach i odwodnienie przed opadami'**
  String get checklistRoofWeatherProtection;

  /// No description provided for @checklistRoofWeatherProtectionRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieszczelne przejścia, obróbki lub rynny mogą zawilgocić konstrukcję i wnętrze.'**
  String get checklistRoofWeatherProtectionRisk;

  /// No description provided for @checklistOpeningAndShadingPreparation.
  ///
  /// In pl, this message translates to:
  /// **'Uzgodnij otwory pod okna i osłony'**
  String get checklistOpeningAndShadingPreparation;

  /// No description provided for @checklistOpeningAndShadingPreparationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak detalu rolety lub żaluzji przed nadprożem może wymusić mostek cieplny albo przeróbkę konstrukcji.'**
  String get checklistOpeningAndShadingPreparationRisk;

  /// No description provided for @checklistShellSafetyAndAccess.
  ///
  /// In pl, this message translates to:
  /// **'Zabezpiecz otwory, schody i komunikację'**
  String get checklistShellSafetyAndAccess;

  /// No description provided for @checklistShellSafetyAndAccessRisk.
  ///
  /// In pl, this message translates to:
  /// **'Niezabezpieczone krawędzie, otwory i tymczasowe schody są bezpośrednim ryzykiem wypadku.'**
  String get checklistShellSafetyAndAccessRisk;

  /// No description provided for @checklistWindowDoorAcceptance.
  ///
  /// In pl, this message translates to:
  /// **'Odbierz montaż okien i drzwi zewnętrznych'**
  String get checklistWindowDoorAcceptance;

  /// No description provided for @checklistWindowDoorAcceptanceRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak podparcia, mocowania lub ciągłości uszczelnienia powoduje nieszczelności i problemy z użytkowaniem.'**
  String get checklistWindowDoorAcceptanceRisk;

  /// No description provided for @checklistWeatherTightnessAndMoisture.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź szczelność budynku i wilgoć'**
  String get checklistWeatherTightnessAndMoisture;

  /// No description provided for @checklistWeatherTightnessAndMoistureRisk.
  ///
  /// In pl, this message translates to:
  /// **'Zakrycie przecieków lub mokrych przegród utrwala zawilgocenie, pleśń i odspojenia wykończenia.'**
  String get checklistWeatherTightnessAndMoistureRisk;

  /// No description provided for @checklistTemporaryVentilationAndHeating.
  ///
  /// In pl, this message translates to:
  /// **'Ustal wietrzenie, osuszanie i ogrzewanie technologiczne'**
  String get checklistTemporaryVentilationAndHeating;

  /// No description provided for @checklistTemporaryVentilationAndHeatingRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowe suszenie lub wychłodzenie może uszkodzić świeże warstwy i materiały.'**
  String get checklistTemporaryVentilationAndHeatingRisk;

  /// No description provided for @checklistInstallationCoordination.
  ///
  /// In pl, this message translates to:
  /// **'Skoordynuj wszystkie trasy instalacji'**
  String get checklistInstallationCoordination;

  /// No description provided for @checklistInstallationCoordinationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak wspólnego planu prowadzi do kolizji, kucia i przypadkowego osłabiania konstrukcji.'**
  String get checklistInstallationCoordinationRisk;

  /// No description provided for @checklistElectricalInstallationRoutes.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj i sprawdź trasy elektryczne'**
  String get checklistElectricalInstallationRoutes;

  /// No description provided for @checklistElectricalInstallationRoutesRisk.
  ///
  /// In pl, this message translates to:
  /// **'Błędne trasy, brak ochrony lub niewłaściwe przepusty mogą uniemożliwić bezpieczny odbiór instalacji.'**
  String get checklistElectricalInstallationRoutesRisk;

  /// No description provided for @checklistWaterSewerHeatingRoutes.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj trasy wody, kanalizacji i ogrzewania'**
  String get checklistWaterSewerHeatingRoutes;

  /// No description provided for @checklistWaterSewerHeatingRoutesRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak spadków, rewizji, izolacji lub dostępu serwisowego często oznacza kucie po wykończeniu.'**
  String get checklistWaterSewerHeatingRoutesRisk;

  /// No description provided for @checklistVentilationAndLowVoltageRoutes.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj wentylację i teletechnikę'**
  String get checklistVentilationAndLowVoltageRoutes;

  /// No description provided for @checklistVentilationAndLowVoltageRoutesRisk.
  ///
  /// In pl, this message translates to:
  /// **'Zgniecione kanały, brak izolacji lub rezerw ograniczy działanie wentylacji i późniejszą rozbudowę.'**
  String get checklistVentilationAndLowVoltageRoutesRisk;

  /// No description provided for @checklistInstallationTests.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj próby i pomiary instalacji'**
  String get checklistInstallationTests;

  /// No description provided for @checklistInstallationTestsRisk.
  ///
  /// In pl, this message translates to:
  /// **'Zakrycie instalacji bez protokołu utrudnia wykrycie nieszczelności, błędów ochrony i wad działania.'**
  String get checklistInstallationTestsRisk;

  /// No description provided for @checklistConcealedInstallationPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zdjęcia instalacji przed zakryciem'**
  String get checklistConcealedInstallationPhotos;

  /// No description provided for @checklistConcealedInstallationPhotosRisk.
  ///
  /// In pl, this message translates to:
  /// **'Bez zdjęć z miarą późniejsze wiercenie, serwis i znalezienie trasy są obarczone zgadywaniem.'**
  String get checklistConcealedInstallationPhotosRisk;

  /// No description provided for @checklistSubstrateInspection.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź podłoża przed tynkami i wylewkami'**
  String get checklistSubstrateInspection;

  /// No description provided for @checklistSubstrateInspectionRisk.
  ///
  /// In pl, this message translates to:
  /// **'Wilgotne, słabe lub zabrudzone podłoże może spowodować pękanie i odspajanie warstw.'**
  String get checklistSubstrateInspectionRisk;

  /// No description provided for @checklistPlasterAndScreedExecution.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj tynki i wylewki według technologii'**
  String get checklistPlasterAndScreedExecution;

  /// No description provided for @checklistPlasterAndScreedExecutionRisk.
  ///
  /// In pl, this message translates to:
  /// **'Zła temperatura, pielęgnacja lub dylatacje zwiększają ryzyko pęknięć i nierówności.'**
  String get checklistPlasterAndScreedExecutionRisk;

  /// No description provided for @checklistFloorHeatingCommissioning.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj próbę i wygrzewanie ogrzewania podłogowego'**
  String get checklistFloorHeatingCommissioning;

  /// No description provided for @checklistFloorHeatingCommissioningRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak próby przed wylewką ukrywa nieszczelność, a brak wygrzewania może uszkodzić późniejszą podłogę.'**
  String get checklistFloorHeatingCommissioningRisk;

  /// No description provided for @checklistPlasterScreedAcceptance.
  ///
  /// In pl, this message translates to:
  /// **'Odbierz równość, wilgotność i dylatacje'**
  String get checklistPlasterScreedAcceptance;

  /// No description provided for @checklistPlasterScreedAcceptanceRisk.
  ///
  /// In pl, this message translates to:
  /// **'Wykończenie na nieodebranym podłożu przenosi wady na płytki, panele i farby.'**
  String get checklistPlasterScreedAcceptanceRisk;

  /// No description provided for @checklistWetAreaWaterproofing.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj hydroizolację pomieszczeń mokrych'**
  String get checklistWetAreaWaterproofing;

  /// No description provided for @checklistWetAreaWaterproofingRisk.
  ///
  /// In pl, this message translates to:
  /// **'Płytki i fuga nie zastępują systemowej hydroizolacji, a nieszczelne detale mogą uszkodzić przegrody.'**
  String get checklistWetAreaWaterproofingRisk;

  /// No description provided for @checklistFinishMaterialsAndSamples.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź materiały, próbki i układy'**
  String get checklistFinishMaterialsAndSamples;

  /// No description provided for @checklistFinishMaterialsAndSamplesRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak próbki i zatwierdzonego układu kończy się różnicami koloru, formatu lub zakresu dostawy.'**
  String get checklistFinishMaterialsAndSamplesRisk;

  /// No description provided for @checklistFloorsWallsCeilings.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj i odbierz podłogi, ściany oraz sufity'**
  String get checklistFloorsWallsCeilings;

  /// No description provided for @checklistFloorsWallsCeilingsRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieodebrane powierzchnie mogą mieć wady widoczne dopiero po montażu wyposażenia i oświetlenia.'**
  String get checklistFloorsWallsCeilingsRisk;

  /// No description provided for @checklistJoineryAndPainting.
  ///
  /// In pl, this message translates to:
  /// **'Zamontuj stolarkę wewnętrzną i wykonaj malowanie'**
  String get checklistJoineryAndPainting;

  /// No description provided for @checklistJoineryAndPaintingRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak ochrony i kolejności robót zwiększa ryzyko uszkodzeń, zabrudzeń i poprawek.'**
  String get checklistJoineryAndPaintingRisk;

  /// No description provided for @checklistSystemsCommissioning.
  ///
  /// In pl, this message translates to:
  /// **'Uruchom i wyreguluj urządzenia'**
  String get checklistSystemsCommissioning;

  /// No description provided for @checklistSystemsCommissioningRisk.
  ///
  /// In pl, this message translates to:
  /// **'Bez uruchomienia i regulacji ogrzewanie, wentylacja, alarm lub automatyka mogą nie działać zgodnie z założeniami.'**
  String get checklistSystemsCommissioningRisk;

  /// No description provided for @checklistWarrantiesAndManuals.
  ///
  /// In pl, this message translates to:
  /// **'Zbierz gwarancje, instrukcje i karty serwisowe'**
  String get checklistWarrantiesAndManuals;

  /// No description provided for @checklistWarrantiesAndManualsRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak dokumentów utrudnia serwis, reklamację i późniejszą bezpieczną obsługę urządzeń.'**
  String get checklistWarrantiesAndManualsRisk;

  /// No description provided for @checklistAsBuiltDocumentation.
  ///
  /// In pl, this message translates to:
  /// **'Skompletuj dokumentację powykonawczą'**
  String get checklistAsBuiltDocumentation;

  /// No description provided for @checklistAsBuiltDocumentationRisk.
  ///
  /// In pl, this message translates to:
  /// **'Nieaktualna dokumentacja utrudnia odbiór, serwis i potwierdzenie zgodności wykonania.'**
  String get checklistAsBuiltDocumentationRisk;

  /// No description provided for @checklistAsBuiltSurvey.
  ///
  /// In pl, this message translates to:
  /// **'Zleć geodezyjną inwentaryzację powykonawczą'**
  String get checklistAsBuiltSurvey;

  /// No description provided for @checklistAsBuiltSurveyRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak inwentaryzacji może zablokować prawidłowe zakończenie procesu i ujawnić błędne położenie sieci lub obiektu.'**
  String get checklistAsBuiltSurveyRisk;

  /// No description provided for @checklistTestsCertificates.
  ///
  /// In pl, this message translates to:
  /// **'Zbierz protokoły prób, pomiarów i certyfikaty'**
  String get checklistTestsCertificates;

  /// No description provided for @checklistTestsCertificatesRisk.
  ///
  /// In pl, this message translates to:
  /// **'Bez protokołów trudno potwierdzić bezpieczeństwo i poprawne uruchomienie instalacji.'**
  String get checklistTestsCertificatesRisk;

  /// No description provided for @checklistConstructionCompletionNotice.
  ///
  /// In pl, this message translates to:
  /// **'Zweryfikuj tryb zakończenia budowy i użytkowania'**
  String get checklistConstructionCompletionNotice;

  /// No description provided for @checklistConstructionCompletionNoticeRisk.
  ///
  /// In pl, this message translates to:
  /// **'Przystąpienie do użytkowania bez właściwego zawiadomienia lub pozwolenia może naruszać procedurę budowlaną.'**
  String get checklistConstructionCompletionNoticeRisk;

  /// No description provided for @checklistDefectsAndHandover.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij listę usterek i przekazanie domu'**
  String get checklistDefectsAndHandover;

  /// No description provided for @checklistDefectsAndHandoverRisk.
  ///
  /// In pl, this message translates to:
  /// **'Brak protokołu odbioru, terminów i odpowiedzialności utrudnia egzekwowanie poprawek.'**
  String get checklistDefectsAndHandoverRisk;

  /// No description provided for @guidancePlanningScopeAndSurveyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zakres remontu i stan istniejący'**
  String get guidancePlanningScopeAndSurveyTitle;

  /// No description provided for @guidancePlanningScopeAndSurveyTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed zamówieniem ofert, materiałów i pierwszych prac'**
  String get guidancePlanningScopeAndSurveyTiming;

  /// No description provided for @guidancePlanningScopeAndSurveySummary.
  ///
  /// In pl, this message translates to:
  /// **'W remoncie zacznij od inwentaryzacji, zakresu i budżetu, a nie od przypadkowego zakupu materiałów. Ustal, które ściany, instalacje i elementy są istniejące, a które mają zostać zmienione; w budynku wielorodzinnym sprawdź zasady zarządcy i części wspólne.'**
  String get guidancePlanningScopeAndSurveySummary;

  /// No description provided for @guidancePlanningScopeAndSurveyChecks.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz pomiary, zdjęcia, istniejące uszkodzenia, trasy instalacji i miejsca wymagające odkrywek.\nPodziel zakres na roboty konieczne, warianty i wyposażenie; dodaj rezerwę budżetową oraz terminy decyzji.\nSprawdź, czy zmiana układu, instalacji, elewacji, wentylacji lub elementów konstrukcyjnych wymaga projektanta, zgody właściciela albo zarządcy.\nZbierz próbki i karty techniczne materiałów, zanim wykonawca wyceni rozwiązanie.\nUtwórz jedną wersję rysunków, ustaleń i zdjęć dla ekip.'**
  String get guidancePlanningScopeAndSurveyChecks;

  /// No description provided for @guidancePlanningScopeAndSurveyQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy zakres obejmuje także demontaż, wywóz, zabezpieczenia i odtworzenie?\nCzy znamy przebieg instalacji, grubości przegród i stan podłoży?\nCzy planowana zmiana dotyka konstrukcji, części wspólnych, elewacji lub dróg ewakuacji?\nKto zatwierdza każdą zmianę przed wykonaniem?'**
  String get guidancePlanningScopeAndSurveyQuestions;

  /// No description provided for @guidanceDemolitionSafetyAndUtilitiesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Rozbiórka bez niespodzianek'**
  String get guidanceDemolitionSafetyAndUtilitiesTitle;

  /// No description provided for @guidanceDemolitionSafetyAndUtilitiesTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed pierwszym skuciem, cięciem lub demontażem'**
  String get guidanceDemolitionSafetyAndUtilitiesTiming;

  /// No description provided for @guidanceDemolitionSafetyAndUtilitiesSummary.
  ///
  /// In pl, this message translates to:
  /// **'Rozbiórkę planuj od rozpoznania zagrożeń i odłączenia mediów. Nie zakładaj, że ściana jest działowa, a instalacja nieczynna; elementy konstrukcyjne, materiały zawierające azbest i instalacje wymagają właściwej oceny oraz fachowego wykonania.'**
  String get guidanceDemolitionSafetyAndUtilitiesSummary;

  /// No description provided for @guidanceDemolitionSafetyAndUtilitiesChecks.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź z projektantem lub kierownikiem, które elementy są nośne i w jakiej kolejności można je usuwać.\nZidentyfikuj azbest, szkło, stare izolacje, pyły, substancje niebezpieczne i miejsca o podwyższonym ryzyku.\nOdłącz, sprawdź i zabezpiecz prąd, gaz, wodę, ogrzewanie, kanalizację oraz teletechnikę.\nZabezpiecz sąsiadów, części wspólne, okna, drzwi, wentylację i drogi ewakuacji przed pyłem i gruzem.\nUstal segregację, transport i legalne przekazanie odpadów; po rozbiórce wykonaj odbiór odkrytych podłoży i instalacji.'**
  String get guidanceDemolitionSafetyAndUtilitiesChecks;

  /// No description provided for @guidanceDemolitionSafetyAndUtilitiesQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Kto potwierdzi odłączenie każdej instalacji?\nCzy w budynku występują materiały wymagające specjalistycznego usunięcia?\nCzy rozbiórka może zmienić stateczność lub ochronę przeciwpożarową?\nJak udokumentujemy stan sąsiadujących lokali i części wspólnych przed pracą?'**
  String get guidanceDemolitionSafetyAndUtilitiesQuestions;

  /// No description provided for @guidancePlasterAndScreedExecutionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tynki, wylewki i dojrzewanie'**
  String get guidancePlasterAndScreedExecutionTitle;

  /// No description provided for @guidancePlasterAndScreedExecutionTiming.
  ///
  /// In pl, this message translates to:
  /// **'Po próbach instalacji, przed montażem podłóg i szczelną zabudową'**
  String get guidancePlasterAndScreedExecutionTiming;

  /// No description provided for @guidancePlasterAndScreedExecutionSummary.
  ///
  /// In pl, this message translates to:
  /// **'Tynki i wylewki wykonuj dopiero po zamknięciu tras oraz udokumentowaniu prób. O wyniku decydują rodzaj podłoża, materiał, warunki w pomieszczeniu, dylatacje i czas dojrzewania, a nie jedna uniwersalna recepta.'**
  String get guidancePlasterAndScreedExecutionSummary;

  /// No description provided for @guidancePlasterAndScreedExecutionChecks.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź nośność, czystość, wilgotność i przygotowanie podłoża zgodnie z kartą systemu.\nPrzed wylewką potwierdź próby ogrzewania podłogowego, oznaczenie pętli, osłony rur i taśmy brzegowe.\nZachowaj dylatacje konstrukcyjne i zaprojektuj podział pól zgodnie z pomieszczeniami, ogrzewaniem i okładziną.\nUstal temperaturę, wentylację, ochronę przed przeciągiem, mrozem i zbyt szybkim wysychaniem.\nPo dojrzewaniu zmierz równość i wilgotność metodą wymaganą przez planowaną podłogę.'**
  String get guidancePlasterAndScreedExecutionChecks;

  /// No description provided for @guidancePlasterAndScreedExecutionQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Czy każda warstwa ma kartę techniczną i wymagany czas dojrzewania?\nCzy przejścia i dylatacje są zgodne z projektem podłóg?\nCzy protokół ogrzewania podłogowego jest kompletny przed wylewką?\nJakie kryteria odbioru przyjmujemy dla równości, wilgotności i spękań?'**
  String get guidancePlasterAndScreedExecutionQuestions;

  /// No description provided for @guidanceHandoverAndOccupancyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dokumenty, odbiór i użytkowanie'**
  String get guidanceHandoverAndOccupancyTitle;

  /// No description provided for @guidanceHandoverAndOccupancyTiming.
  ///
  /// In pl, this message translates to:
  /// **'Przed przekazaniem domu i przed rozpoczęciem użytkowania'**
  String get guidanceHandoverAndOccupancyTiming;

  /// No description provided for @guidanceHandoverAndOccupancySummary.
  ///
  /// In pl, this message translates to:
  /// **'Odbiór to nie tylko oględziny pomieszczeń. Zamknij dokumentację powykonawczą, geodezję, protokoły, instrukcje, listę usterek i właściwą procedurę zakończenia lub użytkowania. Dla remontu zakres formalny może być inny niż dla budowy domu, więc potwierdź go dla konkretnej inwestycji.'**
  String get guidanceHandoverAndOccupancySummary;

  /// No description provided for @guidanceHandoverAndOccupancyChecks.
  ///
  /// In pl, this message translates to:
  /// **'Zbierz aktualny projekt, zmiany zaakceptowane przez właściwe osoby, zdjęcia robót zakrytych i dokumentację powykonawczą.\nDołącz geodezyjną inwentaryzację powykonawczą, jeżeli wynika z zakresu inwestycji i przepisów.\nSkompletuj protokoły instalacji, prób, pomiarów, uruchomień, kominiarskie i inne wymagane dla obiektu.\nSprawdź z kierownikiem lub urzędem, czy potrzebne jest zawiadomienie o zakończeniu budowy czy pozwolenie na użytkowanie; nie przenoś tej procedury automatycznie na zwykły remont.\nPodpisz protokół przekazania z listą usterek, terminami, gwarancjami, instrukcjami i stanami liczników.'**
  String get guidanceHandoverAndOccupancyChecks;

  /// No description provided for @guidanceHandoverAndOccupancyQuestions.
  ///
  /// In pl, this message translates to:
  /// **'Jaki tryb zakończenia i użytkowania dotyczy tej inwestycji?\nCzy dokumentacja powykonawcza pokazuje rzeczywiste trasy i zmiany?\nCzy wszystkie próby, pomiary i uruchomienia mają podpisane protokoły?\nKto i do kiedy usuwa każdą usterkę z protokołu przekazania?'**
  String get guidanceHandoverAndOccupancyQuestions;

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

  /// No description provided for @budgetReportBasePlanLabel.
  ///
  /// In pl, this message translates to:
  /// **'Plan bazowy'**
  String get budgetReportBasePlanLabel;

  /// No description provided for @budgetReportDecisionDeltaLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdzone zmiany'**
  String get budgetReportDecisionDeltaLabel;

  /// No description provided for @budgetReportAdjustedPlanLabel.
  ///
  /// In pl, this message translates to:
  /// **'Plan po zmianach'**
  String get budgetReportAdjustedPlanLabel;

  /// No description provided for @budgetReportDecisionImpactHeading.
  ///
  /// In pl, this message translates to:
  /// **'Wpływ decyzji'**
  String get budgetReportDecisionImpactHeading;

  /// No description provided for @budgetReportDecisionImpactMessage.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =1{1 zatwierdzona decyzja} few{{count} zatwierdzone decyzje} many{{count} zatwierdzonych decyzji} other{{count} zatwierdzonych decyzji}} · termin {days} dni'**
  String budgetReportDecisionImpactMessage(int count, String days);

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

  /// No description provided for @budgetReportDimensionComponent.
  ///
  /// In pl, this message translates to:
  /// **'Skład kosztu'**
  String get budgetReportDimensionComponent;

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
  /// **'Zeskanuj paragon lub fakturę wielostronicową albo wybierz plik.'**
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

  /// No description provided for @receiptManualEntryAction.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz dane ręcznie'**
  String get receiptManualEntryAction;

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
  /// **'Ponów odczyt albo wpisz dane ręcznie. Oryginał pozostanie dołączony do kosztu.'**
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

  /// No description provided for @legalApplicationSection.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja'**
  String get legalApplicationSection;

  /// No description provided for @legalAppVersionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wersja aplikacji'**
  String get legalAppVersionLabel;

  /// No description provided for @legalAppPackageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Identyfikator pakietu'**
  String get legalAppPackageLabel;

  /// No description provided for @legalAppVersionLoading.
  ///
  /// In pl, this message translates to:
  /// **'Odczytywanie wersji'**
  String get legalAppVersionLoading;

  /// No description provided for @legalAppVersionUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Wersja niedostępna'**
  String get legalAppVersionUnavailable;

  /// No description provided for @legalPublisherSection.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt i pomoc'**
  String get legalPublisherSection;

  /// No description provided for @legalContactLabel.
  ///
  /// In pl, this message translates to:
  /// **'Skontaktuj się z nami'**
  String get legalContactLabel;

  /// No description provided for @legalNotConfiguredValue.
  ///
  /// In pl, this message translates to:
  /// **'Nie skonfigurowano do wydania'**
  String get legalNotConfiguredValue;

  /// No description provided for @legalEmailSubject.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO - kontakt'**
  String get legalEmailSubject;

  /// No description provided for @legalPublicPolicyLabel.
  ///
  /// In pl, this message translates to:
  /// **'Publiczna kopia polityki'**
  String get legalPublicPolicyLabel;

  /// No description provided for @legalSupportUrlLabel.
  ///
  /// In pl, this message translates to:
  /// **'Publiczna strona wsparcia'**
  String get legalSupportUrlLabel;

  /// No description provided for @legalDocumentVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja 1.3 · obowiązuje od 08.08.2026'**
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

  /// No description provided for @legalMissingPublisherAddressRequirement.
  ///
  /// In pl, this message translates to:
  /// **'adres usługodawcy'**
  String get legalMissingPublisherAddressRequirement;

  /// No description provided for @legalMissingTaxIdRequirement.
  ///
  /// In pl, this message translates to:
  /// **'prawidłowy NIP wydawcy'**
  String get legalMissingTaxIdRequirement;

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

  /// No description provided for @legalMissingSupportUrlRequirement.
  ///
  /// In pl, this message translates to:
  /// **'publiczny adres HTTPS wsparcia'**
  String get legalMissingSupportUrlRequirement;

  /// No description provided for @legalMissingTermsUrlRequirement.
  ///
  /// In pl, this message translates to:
  /// **'publiczny adres HTTPS regulaminu'**
  String get legalMissingTermsUrlRequirement;

  /// No description provided for @legalOpenLinkError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć odnośnika.'**
  String get legalOpenLinkError;

  /// No description provided for @legalAcceptanceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zanim zaczniesz'**
  String get legalAcceptanceTitle;

  /// No description provided for @legalAcceptanceIntro.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO działa lokalnie i nie wymaga konta. Przed rozpoczęciem zapoznaj się z regulaminem oraz informacją o prywatności.'**
  String get legalAcceptanceIntro;

  /// No description provided for @legalAcceptanceLocalNotice.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdzenie zostanie zapisane tylko na tym urządzeniu. Nie tworzy konta i nie jest wysyłane do wydawcy.'**
  String get legalAcceptanceLocalNotice;

  /// No description provided for @legalAcceptanceCheckbox.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdzam, że otrzymałem regulamin i akceptuję jego treść.'**
  String get legalAcceptanceCheckbox;

  /// No description provided for @legalAcceptanceOpenTerms.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz regulamin'**
  String get legalAcceptanceOpenTerms;

  /// No description provided for @legalAcceptanceOpenPrivacy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get legalAcceptanceOpenPrivacy;

  /// No description provided for @legalAcceptanceContinue.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij korzystanie'**
  String get legalAcceptanceContinue;

  /// No description provided for @legalAcceptanceSaving.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie potwierdzenia'**
  String get legalAcceptanceSaving;

  /// No description provided for @legalAcceptanceLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się sprawdzić potwierdzenia regulaminu.'**
  String get legalAcceptanceLoadError;

  /// No description provided for @legalAcceptanceSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać potwierdzenia. Spróbuj ponownie.'**
  String get legalAcceptanceSaveError;

  /// No description provided for @legalAcceptanceRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get legalAcceptanceRetry;

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

  /// No description provided for @legalSourceGithubPrivacy.
  ///
  /// In pl, this message translates to:
  /// **'GitHub — polityka prywatności i transfery'**
  String get legalSourceGithubPrivacy;

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

  /// No description provided for @legalSourceElectronicServicesAct.
  ///
  /// In pl, this message translates to:
  /// **'ELI — ustawa o świadczeniu usług drogą elektroniczną'**
  String get legalSourceElectronicServicesAct;

  /// No description provided for @legalSourceConsumerRightsAct.
  ///
  /// In pl, this message translates to:
  /// **'ELI — ustawa o prawach konsumenta'**
  String get legalSourceConsumerRightsAct;

  /// No description provided for @legalSourceTaxpayerList.
  ///
  /// In pl, this message translates to:
  /// **'Ministerstwo Finansów — wykaz podatników VAT'**
  String get legalSourceTaxpayerList;

  /// No description provided for @privacySectionPublisherTitle.
  ///
  /// In pl, this message translates to:
  /// **'1. Wydawca i zakres polityki'**
  String get privacySectionPublisherTitle;

  /// No description provided for @privacySectionPublisherBody.
  ///
  /// In pl, this message translates to:
  /// **'Administratorem danych przekazanych podczas kontaktu z BudowaPRO jest {publisher}, NIP {taxId}, adres: {address}. Kontakt w sprawach prywatności: {contact}. Aplikacja nie wymaga konta i nie ma serwera BudowaPRO. Wydawca nie otrzymuje i nie ma zdalnego dostępu do treści zapisanych wyłącznie w prywatnej pamięci aplikacji.'**
  String privacySectionPublisherBody(
    String publisher,
    String taxId,
    String address,
    String contact,
  );

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
  /// **'Rozpoznawanie obrazu i tekstu odbywa się na urządzeniu. Zgodnie z dokumentacją Google obrazy, tekst wejściowy i wynik OCR nie są wysyłane do serwerów Google. Po uruchomieniu skanera lub OCR biblioteki ML Kit zbierają jednak i wysyłają przez HTTPS metryki techniczne obejmujące informacje o urządzeniu i aplikacji, identyfikator instalacji, konfigurację API, rozmiar wejścia i wyjścia, wersję funkcji, metryki wydajności, typy zdarzeń oraz kody błędów. Google używa ich do diagnostyki i analityki wykorzystania ML Kit.'**
  String get privacySectionOcrBody;

  /// No description provided for @privacySectionPermissionsTitle.
  ///
  /// In pl, this message translates to:
  /// **'5. Uprawnienia urządzenia'**
  String get privacySectionPermissionsTitle;

  /// No description provided for @privacySectionPermissionsBody.
  ///
  /// In pl, this message translates to:
  /// **'Skaner dokumentów i selektor plików uruchamiają się dopiero po działaniu użytkownika; aplikacja nie żąda szerokiego dostępu do pamięci. Systemowy selektor kontaktu przekazuje tylko kontakt wybrany przez użytkownika, bez szerokiego odczytu książki adresowej. Powiadomienia służą lokalnym przypomnieniom i wymagają zgody systemowej.'**
  String get privacySectionPermissionsBody;

  /// No description provided for @privacySectionSharingTitle.
  ///
  /// In pl, this message translates to:
  /// **'6. Odbiorcy danych, logi strony i przekazywanie poza EOG'**
  String get privacySectionSharingTitle;

  /// No description provided for @privacySectionSharingBody.
  ///
  /// In pl, this message translates to:
  /// **'Google jako niezależny administrator zbiera opisane metryki ML Kit do diagnostyki i analityki. GitHub, Inc. lub GitHub B.V. jako niezależny administrator hostingu strony automatycznie otrzymuje adres IP, informacje o urządzeniu i przeglądarce, datę i czas żądania, stronę odsyłającą, odwiedzone podstrony i kliknięte odnośniki; wydawca nie ma dostępu do tych logów i nie używa własnej analityki. Operator poczty działa jako dostawca obsługujący korespondencję na rzecz wydawcy. GitHub wskazuje standardowe klauzule umowne Komisji Europejskiej oraz EU-US Data Privacy Framework; Google stosuje mechanizmy opisane w swojej polityce transferów. Informację lub kopię zabezpieczeń transferu można uzyskać z podlinkowanych polityk dostawców albo pisząc do wydawcy. Eksport, kopia ZIP, telefon, e-mail i systemowe udostępnianie przekazują wybraną zawartość dopiero do odbiorcy wskazanego przez użytkownika. Ręczna kopia ZIP nie jest szyfrowana.'**
  String get privacySectionSharingBody;

  /// No description provided for @privacySectionCorrespondenceTitle.
  ///
  /// In pl, this message translates to:
  /// **'7. Korespondencja i podstawy prawne'**
  String get privacySectionCorrespondenceTitle;

  /// No description provided for @privacySectionCorrespondenceBody.
  ///
  /// In pl, this message translates to:
  /// **'Po napisaniu na {contact} wydawca przetwarza adres e-mail, treść wiadomości, dane podane dobrowolnie i ewentualne załączniki, aby odpowiedzieć, obsłużyć zgłoszenie lub reklamację i chronić przed roszczeniami. Podstawą jest podjęcie działań na żądanie użytkownika lub wykonanie umowy (art. 6 ust. 1 lit. b RODO), obowiązek prawny, gdy ma zastosowanie (lit. c), oraz prawnie uzasadniony interes polegający na obsłudze, bezpieczeństwie i obronie roszczeń (lit. f). Podanie danych jest dobrowolne, ale bez adresu i treści zgłoszenia odpowiedź może być niemożliwa. Korespondencja jest przechowywana do zakończenia sprawy, a następnie do upływu właściwego okresu przedawnienia lub obowiązkowej retencji; dane zbędne są usuwane wcześniej.'**
  String privacySectionCorrespondenceBody(String contact);

  /// No description provided for @privacySectionRetentionTitle.
  ///
  /// In pl, this message translates to:
  /// **'8. Okres przechowywania i usuwanie'**
  String get privacySectionRetentionTitle;

  /// No description provided for @privacySectionRetentionBody.
  ///
  /// In pl, this message translates to:
  /// **'Dane pozostają w aplikacji do czasu usunięcia rekordu lub projektu, wyczyszczenia danych aplikacji albo jej odinstalowania. Ręcznie wyeksportowane pliki pozostają w wybranej lokalizacji do czasu, aż usuniesz je osobno. Android wyklucza prywatne pliki BudowaPRO z kopii chmurowej i transferu urządzenie–urządzenie. Na iOS prywatny katalog danych BudowaPRO jest oznaczony jako wyłączony z kopii iCloud.'**
  String get privacySectionRetentionBody;

  /// No description provided for @privacySectionRightsTitle.
  ///
  /// In pl, this message translates to:
  /// **'9. Kontrola danych i prawa'**
  String get privacySectionRightsTitle;

  /// No description provided for @privacySectionRightsBody.
  ///
  /// In pl, this message translates to:
  /// **'Dane lokalne możesz przeglądać, poprawiać, eksportować i usuwać w aplikacji. Ponieważ wydawca nie posiada ich zdalnej kopii, nie może zwrócić ani usunąć jej za Ciebie. W odniesieniu do danych korespondencji, zależnie od podstawy i okoliczności, przysługuje prawo dostępu, sprostowania, usunięcia, ograniczenia przetwarzania, przenoszenia danych oraz wniesienia sprzeciwu. Żądanie wyślij na {contact}. Możesz też złożyć skargę do Prezesa UODO. BudowaPRO nie podejmuje wobec użytkownika decyzji opartych wyłącznie na zautomatyzowanym przetwarzaniu.'**
  String privacySectionRightsBody(String contact);

  /// No description provided for @privacySectionSecurityTitle.
  ///
  /// In pl, this message translates to:
  /// **'10. Bezpieczeństwo'**
  String get privacySectionSecurityTitle;

  /// No description provided for @privacySectionSecurityBody.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO używa prywatnych katalogów aplikacji, weryfikuje kopie i ogranicza uprawnienia systemowe. Chroń telefon blokadą ekranu i przechowuj ręczne kopie w zaufanym miejscu. Żadne zabezpieczenie nie usuwa ryzyka utraty danych po uszkodzeniu urządzenia, złośliwym oprogramowaniu lub udostępnieniu odblokowanego telefonu.'**
  String get privacySectionSecurityBody;

  /// No description provided for @privacySectionChangesTitle.
  ///
  /// In pl, this message translates to:
  /// **'11. Zmiany polityki'**
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
  /// **'Usługodawcą i wydawcą BudowaPRO jest {publisher}, NIP {taxId}, adres: {address}. Kontakt elektroniczny i adres do reklamacji: {contact}. Świadczenie usługi nie wymaga zezwolenia. Korzystanie z aplikacji nie wymaga konta ani odpłatnej subskrypcji w tej wersji.'**
  String termsSectionProviderBody(
    String publisher,
    String taxId,
    String address,
    String contact,
  );

  /// No description provided for @termsSectionPurposeTitle.
  ///
  /// In pl, this message translates to:
  /// **'2. Rodzaje i zakres usług'**
  String get termsSectionPurposeTitle;

  /// No description provided for @termsSectionPurposeBody.
  ///
  /// In pl, this message translates to:
  /// **'BudowaPRO świadczy lokalną usługę organizowania budowy lub remontu: prowadzenie etapów, kosztów, kontaktów, terminów, dokumentów, zdjęć, notatek, kopii zapasowych, OCR oraz generowanie lokalnych raportów. Strona wsparcia udostępnia dokumenty prawne i kontakt. Zakres konkretnej wersji wynika z opisu w sklepie i funkcji dostępnych w aplikacji.'**
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

  /// No description provided for @termsSectionTechnicalTitle.
  ///
  /// In pl, this message translates to:
  /// **'4. Wymagania techniczne i zagrożenia'**
  String get termsSectionTechnicalTitle;

  /// No description provided for @termsSectionTechnicalBody.
  ///
  /// In pl, this message translates to:
  /// **'Potrzebne są: kompatybilne urządzenie i wersja Androida lub iOS wskazana w sklepie, wolna pamięć, legalne oprogramowanie systemowe oraz dostęp do internetu przy instalacji, aktualizacjach, pobieraniu składników ML Kit, otwieraniu stron lub wysyłaniu e-maila. Podstawowe dane projektu działają lokalnie. Zagrożenia obejmują utratę telefonu lub danych, złośliwe oprogramowanie, nieuprawniony dostęp do odblokowanego urządzenia, nieszyfrowany eksport ZIP i błędny OCR.'**
  String get termsSectionTechnicalBody;

  /// No description provided for @termsSectionContractTitle.
  ///
  /// In pl, this message translates to:
  /// **'5. Zawarcie i rozwiązanie umowy'**
  String get termsSectionContractTitle;

  /// No description provided for @termsSectionContractBody.
  ///
  /// In pl, this message translates to:
  /// **'Regulamin jest dostępny bezpłatnie przed rozpoczęciem korzystania na stronie BudowaPRO i przy pierwszym uruchomieniu aplikacji, w formie umożliwiającej zapisanie i odtworzenie. Umowa o nieodpłatne korzystanie zostaje zawarta na czas nieoznaczony po zaznaczeniu potwierdzenia i wybraniu „Rozpocznij korzystanie”. Użytkownik może zakończyć ją w każdej chwili przez zaprzestanie korzystania i odinstalowanie aplikacji; wcześniej może usunąć dane lub wykonać eksport. Brak konta oznacza brak osobnej procedury zamykania konta.'**
  String get termsSectionContractBody;

  /// No description provided for @termsSectionUserDataTitle.
  ///
  /// In pl, this message translates to:
  /// **'6. Dane użytkownika i dozwolone korzystanie'**
  String get termsSectionUserDataTitle;

  /// No description provided for @termsSectionUserDataBody.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiadasz za legalność wprowadzanych kontaktów, zdjęć i dokumentów oraz za posiadanie prawa do ich użycia. Zakazane jest dostarczanie treści o charakterze bezprawnym, naruszającym prawa osób trzecich lub bezpieczeństwo aplikacji. Dane są lokalne. Regularnie twórz ręczną kopię i sprawdzaj możliwość jej odtworzenia.'**
  String get termsSectionUserDataBody;

  /// No description provided for @termsSectionOcrTitle.
  ///
  /// In pl, this message translates to:
  /// **'7. OCR i obliczenia'**
  String get termsSectionOcrTitle;

  /// No description provided for @termsSectionOcrBody.
  ///
  /// In pl, this message translates to:
  /// **'OCR może błędnie odczytać nazwę, datę, pozycję, VAT lub kwotę. Każdy wynik trzeba sprawdzić przed zapisem i zatwierdzeniem kosztu. Podsumowania zależą od poprawności danych wprowadzonych lub zaakceptowanych przez użytkownika.'**
  String get termsSectionOcrBody;

  /// No description provided for @termsSectionAvailabilityTitle.
  ///
  /// In pl, this message translates to:
  /// **'8. Zgodność, dostępność i aktualizacje'**
  String get termsSectionAvailabilityTitle;

  /// No description provided for @termsSectionAvailabilityBody.
  ///
  /// In pl, this message translates to:
  /// **'Wydawca dostarcza aplikację i wymagane aktualizacje zgodnie z bezwzględnie obowiązującym prawem, w tym ustawowymi prawami konsumenta dotyczącymi treści lub usług cyfrowych. Nie gwarantuje zgodności ze wszystkimi urządzeniami i formatami poza zadeklarowanym zakresem. Aktualizacje mogą poprawiać bezpieczeństwo, kompatybilność i funkcje; użytkownik powinien instalować aktualizacje udostępnione dla jego systemu.'**
  String get termsSectionAvailabilityBody;

  /// No description provided for @termsSectionComplaintsTitle.
  ///
  /// In pl, this message translates to:
  /// **'9. Reklamacje'**
  String get termsSectionComplaintsTitle;

  /// No description provided for @termsSectionComplaintsBody.
  ///
  /// In pl, this message translates to:
  /// **'Reklamację dotyczącą działania BudowaPRO można wysłać na {contact}. Podaj dane umożliwiające odpowiedź, wersję aplikacji i systemu, opis problemu, oczekiwane rozwiązanie oraz — jeśli to bezpieczne — kroki odtworzenia błędu. Nie wysyłaj nieocenzurowanych dokumentów ani danych osób trzecich, jeśli nie są konieczne. Reklamacja zostanie rozpatrzona bez zbędnej zwłoki, nie później niż w 14 dni. Postępowanie reklamacyjne nie ogranicza ustawowych praw konsumenta.'**
  String termsSectionComplaintsBody(String contact);

  /// No description provided for @termsSectionLicenseTitle.
  ///
  /// In pl, this message translates to:
  /// **'10. Licencja i własność intelektualna'**
  String get termsSectionLicenseTitle;

  /// No description provided for @termsSectionLicenseBody.
  ///
  /// In pl, this message translates to:
  /// **'Wydawca udziela użytkownikowi niewyłącznego, niezbywalnego prawa do korzystania z aplikacji na obsługiwanych urządzeniach zgodnie z regulaminem i zasadami sklepu. Prawa do aplikacji i jej treści należą do wydawcy lub licencjodawców. Użytkownik zachowuje prawa do własnych danych i materiałów.'**
  String get termsSectionLicenseBody;

  /// No description provided for @termsSectionLiabilityTitle.
  ///
  /// In pl, this message translates to:
  /// **'11. Odpowiedzialność'**
  String get termsSectionLiabilityTitle;

  /// No description provided for @termsSectionLiabilityBody.
  ///
  /// In pl, this message translates to:
  /// **'Wydawca odpowiada w granicach bezwzględnie obowiązującego prawa. Warunki nie wyłączają ani nie ograniczają ustawowych praw konsumenta. Użytkownik odpowiada za decyzje budowlane podjęte bez wymaganej weryfikacji specjalisty oraz za skutki podania nieprawidłowych danych.'**
  String get termsSectionLiabilityBody;

  /// No description provided for @termsSectionLawTitle.
  ///
  /// In pl, this message translates to:
  /// **'12. Prawo i spory'**
  String get termsSectionLawTitle;

  /// No description provided for @termsSectionLawBody.
  ///
  /// In pl, this message translates to:
  /// **'Stosuje się prawo polskie, bez uszczerbku dla bezwzględnie obowiązujących praw konsumenta wynikających z prawa miejsca jego zamieszkania. Spór można najpierw zgłosić wydawcy na podany adres kontaktowy.'**
  String get termsSectionLawBody;

  /// No description provided for @termsSectionChangesTitle.
  ///
  /// In pl, this message translates to:
  /// **'13. Zmiany regulaminu'**
  String get termsSectionChangesTitle;

  /// No description provided for @termsSectionChangesBody.
  ///
  /// In pl, this message translates to:
  /// **'Regulamin może zostać zmieniony z ważnej przyczyny, takiej jak zmiana prawa, bezpieczeństwa, zakresu usługi, modelu płatności albo wykorzystywanego SDK. Nowa wersja otrzymuje datę i jest udostępniana przed wejściem w życie zmiany wpływającej na prawa użytkownika. Prawa nabyte i bezwzględnie obowiązujące prawa konsumenta pozostają nienaruszone.'**
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
  /// **'Kopie systemowe urządzenia'**
  String get privacyAutomaticBackupTitle;

  /// No description provided for @privacyAutomaticBackupSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Android wyklucza prywatne pliki BudowaPRO z kopii chmurowej i transferu na nowe urządzenie. Na iOS prywatny katalog danych BudowaPRO jest wyłączony z kopii iCloud. Ręczna kopia ZIP nie jest szyfrowana.'**
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

  /// No description provided for @privacyDeleteDataSection.
  ///
  /// In pl, this message translates to:
  /// **'Trwałe usuwanie'**
  String get privacyDeleteDataSection;

  /// No description provided for @privacyDeleteDataHelp.
  ///
  /// In pl, this message translates to:
  /// **'Możesz usunąć wszystkie dane zapisane przez BudowaPRO bezpośrednio tutaj. Eksporty i ręczne kopie zapisane poza aplikacją trzeba usunąć osobno.'**
  String get privacyDeleteDataHelp;

  /// No description provided for @privacyDeleteAllTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wszystkie dane BudowaPRO'**
  String get privacyDeleteAllTitle;

  /// No description provided for @privacyDeleteAllSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Projekty, koszty, kontakty, dokumenty, zdjęcia, OCR i szkice zostaną trwale usunięte.'**
  String get privacyDeleteAllSubtitle;

  /// No description provided for @privacyDeleteAllWarning.
  ///
  /// In pl, this message translates to:
  /// **'Tej operacji nie można cofnąć. Przed usunięciem utwórz kopię, jeśli chcesz zachować dane.'**
  String get privacyDeleteAllWarning;

  /// No description provided for @privacyDeleteAllConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć wszystkie dane?'**
  String get privacyDeleteAllConfirmTitle;

  /// No description provided for @privacyDeleteAllConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zostanie usunięta baza BudowaPRO oraz wszystkie lokalne pliki projektów. Aby potwierdzić, wpisz dokładnie poniższą frazę.'**
  String get privacyDeleteAllConfirmMessage;

  /// No description provided for @privacyDeleteAllPhraseLabel.
  ///
  /// In pl, this message translates to:
  /// **'Fraza potwierdzająca'**
  String get privacyDeleteAllPhraseLabel;

  /// No description provided for @privacyDeleteAllConfirmationPhrase.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ DANE'**
  String get privacyDeleteAllConfirmationPhrase;

  /// No description provided for @privacyDeleteAllConfirmAction.
  ///
  /// In pl, this message translates to:
  /// **'Usuń bezpowrotnie'**
  String get privacyDeleteAllConfirmAction;

  /// No description provided for @privacyDeleteAllError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dokończyć usuwania danych. Spróbuj ponownie.'**
  String get privacyDeleteAllError;

  /// No description provided for @journalTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik budowy'**
  String get journalTitle;

  /// No description provided for @journalSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Notatki, decyzje, usterki i zmiany zakresu w jednym miejscu.'**
  String get journalSubtitle;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik jest pusty'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy wpis dnia, notatkę, decyzję albo usterkę.'**
  String get journalEmptyMessage;

  /// No description provided for @journalNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get journalNoProjectTitle;

  /// No description provided for @journalNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik jest przypisany do wybranej budowy lub remontu.'**
  String get journalNoProjectMessage;

  /// No description provided for @journalLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać dziennika.'**
  String get journalLoadError;

  /// No description provided for @journalAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wpis'**
  String get journalAddTooltip;

  /// No description provided for @journalAllFilter.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get journalAllFilter;

  /// No description provided for @journalSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj po tytule i treści'**
  String get journalSearchHint;

  /// No description provided for @journalLoadMore.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż starsze wpisy'**
  String get journalLoadMore;

  /// No description provided for @journalTypeDaily.
  ///
  /// In pl, this message translates to:
  /// **'Wpis dnia'**
  String get journalTypeDaily;

  /// No description provided for @journalTypeNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get journalTypeNote;

  /// No description provided for @journalTypeDecision.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja'**
  String get journalTypeDecision;

  /// No description provided for @journalTypeDefect.
  ///
  /// In pl, this message translates to:
  /// **'Usterka'**
  String get journalTypeDefect;

  /// No description provided for @journalTypeScopeChange.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana zakresu'**
  String get journalTypeScopeChange;

  /// No description provided for @journalStatusDraft.
  ///
  /// In pl, this message translates to:
  /// **'Szkic'**
  String get journalStatusDraft;

  /// No description provided for @journalStatusOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte'**
  String get journalStatusOpen;

  /// No description provided for @journalStatusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W toku'**
  String get journalStatusInProgress;

  /// No description provided for @journalStatusProposal.
  ///
  /// In pl, this message translates to:
  /// **'Propozycja'**
  String get journalStatusProposal;

  /// No description provided for @journalStatusPending.
  ///
  /// In pl, this message translates to:
  /// **'Do decyzji'**
  String get journalStatusPending;

  /// No description provided for @journalStatusApproved.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdzone'**
  String get journalStatusApproved;

  /// No description provided for @journalStatusRejected.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucone'**
  String get journalStatusRejected;

  /// No description provided for @journalStatusImplemented.
  ///
  /// In pl, this message translates to:
  /// **'Wdrożone'**
  String get journalStatusImplemented;

  /// No description provided for @journalStatusRecheck.
  ///
  /// In pl, this message translates to:
  /// **'Do sprawdzenia'**
  String get journalStatusRecheck;

  /// No description provided for @journalStatusFixed.
  ///
  /// In pl, this message translates to:
  /// **'Naprawione'**
  String get journalStatusFixed;

  /// No description provided for @journalStatusClosed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięte'**
  String get journalStatusClosed;

  /// No description provided for @journalNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wpis'**
  String get journalNewTitle;

  /// No description provided for @journalEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj wpis'**
  String get journalEditTitle;

  /// No description provided for @journalDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły wpisu'**
  String get journalDetailsTitle;

  /// No description provided for @journalTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get journalTitleLabel;

  /// No description provided for @journalDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data wpisu'**
  String get journalDateLabel;

  /// No description provided for @journalStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get journalStageLabel;

  /// No description provided for @journalStageNone.
  ///
  /// In pl, this message translates to:
  /// **'Bez przypisanego etapu'**
  String get journalStageNone;

  /// No description provided for @journalPersonLabel.
  ///
  /// In pl, this message translates to:
  /// **'Osoba odpowiedzialna'**
  String get journalPersonLabel;

  /// No description provided for @journalPersonNone.
  ///
  /// In pl, this message translates to:
  /// **'Bez przypisanej osoby'**
  String get journalPersonNone;

  /// No description provided for @journalDecisionMakerLabel.
  ///
  /// In pl, this message translates to:
  /// **'Osoba decyzyjna'**
  String get journalDecisionMakerLabel;

  /// No description provided for @journalDecisionMakerNone.
  ///
  /// In pl, this message translates to:
  /// **'Nie wskazano osoby decyzyjnej'**
  String get journalDecisionMakerNone;

  /// No description provided for @journalStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get journalStatusLabel;

  /// No description provided for @journalBodyLabel.
  ///
  /// In pl, this message translates to:
  /// **'Treść'**
  String get journalBodyLabel;

  /// No description provided for @journalWeatherLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pogoda'**
  String get journalWeatherLabel;

  /// No description provided for @journalPeopleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ekipa / osoby na budowie'**
  String get journalPeopleLabel;

  /// No description provided for @journalWorkLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wykonane prace'**
  String get journalWorkLabel;

  /// No description provided for @journalDeliveriesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dostawy'**
  String get journalDeliveriesLabel;

  /// No description provided for @journalDelaysLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opóźnienia i przeszkody'**
  String get journalDelaysLabel;

  /// No description provided for @journalNextStepsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kolejne kroki'**
  String get journalNextStepsLabel;

  /// No description provided for @journalProblemLabel.
  ///
  /// In pl, this message translates to:
  /// **'Problem lub pytanie'**
  String get journalProblemLabel;

  /// No description provided for @journalVariantsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rozważane warianty'**
  String get journalVariantsLabel;

  /// No description provided for @journalSelectedOptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wybrany wariant'**
  String get journalSelectedOptionLabel;

  /// No description provided for @journalRationaleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Uzasadnienie'**
  String get journalRationaleLabel;

  /// No description provided for @journalDueDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Termin sprawdzenia / realizacji'**
  String get journalDueDateLabel;

  /// No description provided for @journalClearDueDate.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść termin'**
  String get journalClearDueDate;

  /// No description provided for @journalSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wpis'**
  String get journalSaveAction;

  /// No description provided for @journalSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Wpis zapisany.'**
  String get journalSavedMessage;

  /// No description provided for @journalSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać wpisu. Sprawdź pola i spróbuj ponownie.'**
  String get journalSaveError;

  /// No description provided for @journalEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj wpis'**
  String get journalEditTooltip;

  /// No description provided for @journalChangeStatusTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zmień status'**
  String get journalChangeStatusTooltip;

  /// No description provided for @journalHistoryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Historia zmian'**
  String get journalHistoryTitle;

  /// No description provided for @journalHistoryCount.
  ///
  /// In pl, this message translates to:
  /// **'Wersje: {count}'**
  String journalHistoryCount(int count);

  /// No description provided for @journalAttachmentsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Załączniki'**
  String get journalAttachmentsTitle;

  /// No description provided for @journalAttachmentAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj plik'**
  String get journalAttachmentAdd;

  /// No description provided for @journalAttachmentRemove.
  ///
  /// In pl, this message translates to:
  /// **'Usuń załącznik'**
  String get journalAttachmentRemove;

  /// No description provided for @journalAttachmentCount.
  ///
  /// In pl, this message translates to:
  /// **'Załączniki: {count}'**
  String journalAttachmentCount(int count);

  /// No description provided for @journalRelatedRecordsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane rekordy'**
  String get journalRelatedRecordsTitle;

  /// No description provided for @journalStageLink.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz etap'**
  String get journalStageLink;

  /// No description provided for @journalContactLink.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz osobę'**
  String get journalContactLink;

  /// No description provided for @journalRevisionCreated.
  ///
  /// In pl, this message translates to:
  /// **'Utworzono'**
  String get journalRevisionCreated;

  /// No description provided for @journalRevisionUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniono'**
  String get journalRevisionUpdated;

  /// No description provided for @journalRevisionStatusChanged.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniono status'**
  String get journalRevisionStatusChanged;

  /// No description provided for @journalNoContent.
  ///
  /// In pl, this message translates to:
  /// **'Brak dodatkowej treści.'**
  String get journalNoContent;

  /// No description provided for @journalTypeRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz typ wpisu.'**
  String get journalTypeRequiredError;

  /// No description provided for @journalTitleRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz tytuł.'**
  String get journalTitleRequiredError;

  /// No description provided for @journalBodyRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj treść wpisu.'**
  String get journalBodyRequiredError;

  /// No description provided for @journalDatePickerLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę'**
  String get journalDatePickerLabel;

  /// No description provided for @journalAttachmentError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dodać pliku.'**
  String get journalAttachmentError;

  /// No description provided for @journalAttachmentRemoveConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć załącznik z wpisu?'**
  String get journalAttachmentRemoveConfirm;

  /// No description provided for @journalCostImpactLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wpływ kosztowy'**
  String get journalCostImpactLabel;

  /// No description provided for @journalScheduleImpactLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wpływ na termin'**
  String get journalScheduleImpactLabel;

  /// No description provided for @journalCostImpactHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 1250,00 lub -300,00'**
  String get journalCostImpactHint;

  /// No description provided for @journalScheduleImpactHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 2 lub -1'**
  String get journalScheduleImpactHint;

  /// No description provided for @journalImpactInvalidError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawną kwotę i pełną liczbę dni.'**
  String get journalImpactInvalidError;

  /// No description provided for @journalBlockedRecordsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Blokowane zadania'**
  String get journalBlockedRecordsTitle;

  /// No description provided for @journalBlockedRecordsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Ta decyzja nie blokuje żadnego zadania z harmonogramu.'**
  String get journalBlockedRecordsEmpty;

  /// No description provided for @journalBlockedRecordsSelect.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz zadania'**
  String get journalBlockedRecordsSelect;

  /// No description provided for @journalBlockedRecordsDone.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get journalBlockedRecordsDone;

  /// No description provided for @journalApproveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź decyzję'**
  String get journalApproveAction;

  /// No description provided for @journalApprovalTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdzenie'**
  String get journalApprovalTitle;

  /// No description provided for @journalApprovalPersonLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdził(a)'**
  String get journalApprovalPersonLabel;

  /// No description provided for @journalApprovalDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data zatwierdzenia'**
  String get journalApprovalDateLabel;

  /// No description provided for @journalApprovalDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź wybrany wariant'**
  String get journalApprovalDialogTitle;

  /// No description provided for @journalApprovalDialogMessage.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź osobę zatwierdzającą. Od tej chwili delta decyzji będzie widoczna w raporcie budżetu.'**
  String get journalApprovalDialogMessage;

  /// No description provided for @journalApprovalContactRequired.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj kontakt lub wskaż osobę, która zatwierdza decyzję.'**
  String get journalApprovalContactRequired;

  /// No description provided for @journalApprovalOptionRequired.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw wpisz wybrany wariant.'**
  String get journalApprovalOptionRequired;

  /// No description provided for @journalApprovalSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja zatwierdzona i uwzględniona w raporcie.'**
  String get journalApprovalSuccess;

  /// No description provided for @journalApprovalError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zatwierdzić decyzji.'**
  String get journalApprovalError;

  /// No description provided for @journalApprovalManagedInDetails.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdzenie i wdrożenie zmienisz w szczegółach wpisu.'**
  String get journalApprovalManagedInDetails;

  /// No description provided for @journalDaysSuffix.
  ///
  /// In pl, this message translates to:
  /// **'dni'**
  String get journalDaysSuffix;

  /// No description provided for @technicalPhotosTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dokumentacja techniczna'**
  String get technicalPhotosTitle;

  /// No description provided for @technicalPhotosSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia robót zanikających, instalacji i odbiorów'**
  String get technicalPhotosSubtitle;

  /// No description provided for @technicalPhotosLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie dokumentacji technicznej'**
  String get technicalPhotosLoading;

  /// No description provided for @technicalPhotosLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać dokumentacji technicznej.'**
  String get technicalPhotosLoadError;

  /// No description provided for @technicalPhotosNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get technicalPhotosNoProjectTitle;

  /// No description provided for @technicalPhotosNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia techniczne są przypisane do wybranej budowy lub remontu.'**
  String get technicalPhotosNoProjectMessage;

  /// No description provided for @technicalPhotosEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak zdjęć technicznych'**
  String get technicalPhotosEmptyTitle;

  /// No description provided for @technicalPhotosEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie przed zakryciem instalacji, zalaniem betonu albo wykonaniem kolejnej warstwy.'**
  String get technicalPhotosEmptyMessage;

  /// No description provided for @technicalPhotosSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj po nazwie, opisie, strefie lub tagu'**
  String get technicalPhotosSearchHint;

  /// No description provided for @technicalPhotosAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie techniczne'**
  String get technicalPhotosAddTooltip;

  /// No description provided for @technicalPhotosAlbumAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz album'**
  String get technicalPhotosAlbumAddTooltip;

  /// No description provided for @technicalPhotosFilterTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Filtry zdjęć'**
  String get technicalPhotosFilterTooltip;

  /// No description provided for @technicalPhotosAllAlbums.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get technicalPhotosAllAlbums;

  /// No description provided for @technicalPhotosCount.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia: {count}'**
  String technicalPhotosCount(int count);

  /// No description provided for @technicalPhotosLoadMore.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj kolejne zdjęcia'**
  String get technicalPhotosLoadMore;

  /// No description provided for @technicalPhotosMissingPreview.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd pliku jest niedostępny'**
  String get technicalPhotosMissingPreview;

  /// No description provided for @technicalPhotosImportError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dodać zdjęcia.'**
  String get technicalPhotosImportError;

  /// No description provided for @technicalPhotosUnsupportedFile.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz plik obrazu, np. JPG, PNG lub HEIC.'**
  String get technicalPhotosUnsupportedFile;

  /// No description provided for @technicalAlbumNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy album techniczny'**
  String get technicalAlbumNewTitle;

  /// No description provided for @technicalAlbumTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa albumu'**
  String get technicalAlbumTitleLabel;

  /// No description provided for @technicalAlbumKindLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj albumu'**
  String get technicalAlbumKindLabel;

  /// No description provided for @technicalAlbumDescriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Cel i zakres albumu'**
  String get technicalAlbumDescriptionLabel;

  /// No description provided for @technicalAlbumCreateAction.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz album'**
  String get technicalAlbumCreateAction;

  /// No description provided for @technicalAlbumCreateError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się utworzyć albumu.'**
  String get technicalAlbumCreateError;

  /// No description provided for @technicalAlbumRequiredError.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw utwórz album techniczny.'**
  String get technicalAlbumRequiredError;

  /// No description provided for @technicalAlbumBeforeConcrete.
  ///
  /// In pl, this message translates to:
  /// **'Przed betonowaniem'**
  String get technicalAlbumBeforeConcrete;

  /// No description provided for @technicalAlbumBeforeBackfill.
  ///
  /// In pl, this message translates to:
  /// **'Przed zasypaniem'**
  String get technicalAlbumBeforeBackfill;

  /// No description provided for @technicalAlbumBeforePlaster.
  ///
  /// In pl, this message translates to:
  /// **'Przed tynkowaniem'**
  String get technicalAlbumBeforePlaster;

  /// No description provided for @technicalAlbumBeforeScreed.
  ///
  /// In pl, this message translates to:
  /// **'Przed wylewką'**
  String get technicalAlbumBeforeScreed;

  /// No description provided for @technicalAlbumBeforeTiles.
  ///
  /// In pl, this message translates to:
  /// **'Przed płytkami'**
  String get technicalAlbumBeforeTiles;

  /// No description provided for @technicalAlbumAsBuilt.
  ///
  /// In pl, this message translates to:
  /// **'Stan powykonawczy'**
  String get technicalAlbumAsBuilt;

  /// No description provided for @technicalAlbumCustom.
  ///
  /// In pl, this message translates to:
  /// **'Własny album'**
  String get technicalAlbumCustom;

  /// No description provided for @technicalFiltersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Filtry dokumentacji'**
  String get technicalFiltersTitle;

  /// No description provided for @technicalFilterAlbumLabel.
  ///
  /// In pl, this message translates to:
  /// **'Album'**
  String get technicalFilterAlbumLabel;

  /// No description provided for @technicalFilterStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get technicalFilterStageLabel;

  /// No description provided for @technicalFilterInstallationLabel.
  ///
  /// In pl, this message translates to:
  /// **'Instalacja lub zakres'**
  String get technicalFilterInstallationLabel;

  /// No description provided for @technicalFilterTagLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tag'**
  String get technicalFilterTagLabel;

  /// No description provided for @technicalFilterAllStages.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie etapy'**
  String get technicalFilterAllStages;

  /// No description provided for @technicalFilterAllInstallations.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie instalacje'**
  String get technicalFilterAllInstallations;

  /// No description provided for @technicalFilterAllTags.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie tagi'**
  String get technicalFilterAllTags;

  /// No description provided for @technicalPhotoNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Opisz zdjęcie techniczne'**
  String get technicalPhotoNewTitle;

  /// No description provided for @technicalPhotoEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj zdjęcie techniczne'**
  String get technicalPhotoEditTitle;

  /// No description provided for @technicalPhotoDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły zdjęcia'**
  String get technicalPhotoDetailsTitle;

  /// No description provided for @technicalPhotoTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa zdjęcia'**
  String get technicalPhotoTitleLabel;

  /// No description provided for @technicalPhotoDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data wykonania zdjęcia'**
  String get technicalPhotoDateLabel;

  /// No description provided for @technicalPhotoZoneLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie lub strefa'**
  String get technicalPhotoZoneLabel;

  /// No description provided for @technicalPhotoContractorLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wykonawca'**
  String get technicalPhotoContractorLabel;

  /// No description provided for @technicalPhotoChecklistLabel.
  ///
  /// In pl, this message translates to:
  /// **'Punkt checklisty jako dowód'**
  String get technicalPhotoChecklistLabel;

  /// No description provided for @technicalPhotoDescriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis tego, co widać'**
  String get technicalPhotoDescriptionLabel;

  /// No description provided for @technicalPhotoTagsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tagi oddzielone przecinkami'**
  String get technicalPhotoTagsLabel;

  /// No description provided for @technicalPhotoNoContact.
  ///
  /// In pl, this message translates to:
  /// **'Bez wykonawcy'**
  String get technicalPhotoNoContact;

  /// No description provided for @technicalPhotoNoChecklist.
  ///
  /// In pl, this message translates to:
  /// **'Bez powiązania z checklistą'**
  String get technicalPhotoNoChecklist;

  /// No description provided for @technicalPhotoNoStage.
  ///
  /// In pl, this message translates to:
  /// **'Bez przypisanego etapu'**
  String get technicalPhotoNoStage;

  /// No description provided for @technicalPhotoSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zdjęcie'**
  String get technicalPhotoSaveAction;

  /// No description provided for @technicalPhotoSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać zdjęcia. Sprawdź wymagane pola.'**
  String get technicalPhotoSaveError;

  /// No description provided for @technicalPhotoSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie zapisane w dokumentacji technicznej.'**
  String get technicalPhotoSavedMessage;

  /// No description provided for @technicalPhotoNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie nie istnieje albo zostało usunięte.'**
  String get technicalPhotoNotFound;

  /// No description provided for @technicalPhotoOpenFile.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz pełne zdjęcie'**
  String get technicalPhotoOpenFile;

  /// No description provided for @technicalPhotoEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj opis zdjęcia'**
  String get technicalPhotoEditTooltip;

  /// No description provided for @technicalPhotoLinkedChecklist.
  ///
  /// In pl, this message translates to:
  /// **'Dowód do checklisty'**
  String get technicalPhotoLinkedChecklist;

  /// No description provided for @technicalInstallationStructure.
  ///
  /// In pl, this message translates to:
  /// **'Konstrukcja'**
  String get technicalInstallationStructure;

  /// No description provided for @technicalInstallationElectrical.
  ///
  /// In pl, this message translates to:
  /// **'Elektryka'**
  String get technicalInstallationElectrical;

  /// No description provided for @technicalInstallationWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda'**
  String get technicalInstallationWater;

  /// No description provided for @technicalInstallationSewage.
  ///
  /// In pl, this message translates to:
  /// **'Kanalizacja'**
  String get technicalInstallationSewage;

  /// No description provided for @technicalInstallationHeating.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie'**
  String get technicalInstallationHeating;

  /// No description provided for @technicalInstallationVentilation.
  ///
  /// In pl, this message translates to:
  /// **'Wentylacja'**
  String get technicalInstallationVentilation;

  /// No description provided for @technicalInstallationWaterproofing.
  ///
  /// In pl, this message translates to:
  /// **'Hydroizolacja'**
  String get technicalInstallationWaterproofing;

  /// No description provided for @technicalInstallationInsulation.
  ///
  /// In pl, this message translates to:
  /// **'Izolacja termiczna'**
  String get technicalInstallationInsulation;

  /// No description provided for @technicalInstallationGrounding.
  ///
  /// In pl, this message translates to:
  /// **'Uziemienie i połączenia wyrównawcze'**
  String get technicalInstallationGrounding;

  /// No description provided for @technicalInstallationOther.
  ///
  /// In pl, this message translates to:
  /// **'Inny zakres'**
  String get technicalInstallationOther;

  /// No description provided for @punchTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usterki i odbiory'**
  String get punchTitle;

  /// No description provided for @punchSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Usterki, poprawki i protokoły odbioru'**
  String get punchSubtitle;

  /// No description provided for @punchDefectsTab.
  ///
  /// In pl, this message translates to:
  /// **'Usterki'**
  String get punchDefectsTab;

  /// No description provided for @punchProtocolsTab.
  ///
  /// In pl, this message translates to:
  /// **'Protokoły'**
  String get punchProtocolsTab;

  /// No description provided for @punchLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie usterek i protokołów'**
  String get punchLoading;

  /// No description provided for @punchLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać usterek i protokołów.'**
  String get punchLoadError;

  /// No description provided for @punchNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get punchNoProjectTitle;

  /// No description provided for @punchNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Usterki i odbiory są przypisane do wybranej budowy lub remontu.'**
  String get punchNoProjectMessage;

  /// No description provided for @punchSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj usterki lub protokołu'**
  String get punchSearchHint;

  /// No description provided for @punchFilterTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Filtry usterek'**
  String get punchFilterTooltip;

  /// No description provided for @punchFiltersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Filtry usterek'**
  String get punchFiltersTitle;

  /// No description provided for @punchOpenCounter.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte'**
  String get punchOpenCounter;

  /// No description provided for @punchCriticalCounter.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczne'**
  String get punchCriticalCounter;

  /// No description provided for @punchOverdueCounter.
  ///
  /// In pl, this message translates to:
  /// **'Po terminie'**
  String get punchOverdueCounter;

  /// No description provided for @punchDefectCount.
  ///
  /// In pl, this message translates to:
  /// **'Usterki: {count}'**
  String punchDefectCount(int count);

  /// No description provided for @punchProtocolCount.
  ///
  /// In pl, this message translates to:
  /// **'Protokoły: {count}'**
  String punchProtocolCount(int count);

  /// No description provided for @punchLoadMore.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj kolejne'**
  String get punchLoadMore;

  /// No description provided for @punchDefectsEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak usterek'**
  String get punchDefectsEmptyTitle;

  /// No description provided for @punchDefectsEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszą usterkę i przypisz termin, etap oraz osobę odpowiedzialną.'**
  String get punchDefectsEmptyMessage;

  /// No description provided for @punchProtocolsEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak protokołów'**
  String get punchProtocolsEmptyTitle;

  /// No description provided for @punchProtocolsEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz protokół odbioru i powiąż z nim sprawdzane usterki.'**
  String get punchProtocolsEmptyMessage;

  /// No description provided for @punchAddDefectTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj usterkę'**
  String get punchAddDefectTooltip;

  /// No description provided for @punchAddProtocolTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj protokół odbioru'**
  String get punchAddProtocolTooltip;

  /// No description provided for @punchStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get punchStatusLabel;

  /// No description provided for @punchStatusOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwarta'**
  String get punchStatusOpen;

  /// No description provided for @punchStatusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W naprawie'**
  String get punchStatusInProgress;

  /// No description provided for @punchStatusRecheck.
  ///
  /// In pl, this message translates to:
  /// **'Do ponownej kontroli'**
  String get punchStatusRecheck;

  /// No description provided for @punchStatusFixed.
  ///
  /// In pl, this message translates to:
  /// **'Naprawiona'**
  String get punchStatusFixed;

  /// No description provided for @punchStatusClosed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięta'**
  String get punchStatusClosed;

  /// No description provided for @punchSeverityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ważność'**
  String get punchSeverityLabel;

  /// No description provided for @punchSeverityLow.
  ///
  /// In pl, this message translates to:
  /// **'Niska'**
  String get punchSeverityLow;

  /// No description provided for @punchSeverityMedium.
  ///
  /// In pl, this message translates to:
  /// **'Średnia'**
  String get punchSeverityMedium;

  /// No description provided for @punchSeverityHigh.
  ///
  /// In pl, this message translates to:
  /// **'Wysoka'**
  String get punchSeverityHigh;

  /// No description provided for @punchSeverityCritical.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczna'**
  String get punchSeverityCritical;

  /// No description provided for @punchOverdueOnly.
  ///
  /// In pl, this message translates to:
  /// **'Tylko po terminie'**
  String get punchOverdueOnly;

  /// No description provided for @punchAllStages.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie etapy'**
  String get punchAllStages;

  /// No description provided for @punchAllContacts.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie osoby'**
  String get punchAllContacts;

  /// No description provided for @punchRoomFilterLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie lub strefa'**
  String get punchRoomFilterLabel;

  /// No description provided for @punchClearFilters.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść filtry'**
  String get punchClearFilters;

  /// No description provided for @punchApplyFilters.
  ///
  /// In pl, this message translates to:
  /// **'Zastosuj'**
  String get punchApplyFilters;

  /// No description provided for @defectNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowa usterka'**
  String get defectNewTitle;

  /// No description provided for @defectEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj usterkę'**
  String get defectEditTitle;

  /// No description provided for @defectDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły usterki'**
  String get defectDetailsTitle;

  /// No description provided for @defectTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa usterki'**
  String get defectTitleLabel;

  /// No description provided for @defectDescriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis i oczekiwany sposób poprawy'**
  String get defectDescriptionLabel;

  /// No description provided for @defectOccurredAtLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data zgłoszenia'**
  String get defectOccurredAtLabel;

  /// No description provided for @defectDueAtLabel.
  ///
  /// In pl, this message translates to:
  /// **'Termin poprawy'**
  String get defectDueAtLabel;

  /// No description provided for @defectClearDueAt.
  ///
  /// In pl, this message translates to:
  /// **'Usuń termin'**
  String get defectClearDueAt;

  /// No description provided for @defectStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get defectStageLabel;

  /// No description provided for @defectNoStage.
  ///
  /// In pl, this message translates to:
  /// **'Bez przypisanego etapu'**
  String get defectNoStage;

  /// No description provided for @defectRoomLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie lub strefa'**
  String get defectRoomLabel;

  /// No description provided for @defectResponsibleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Osoba odpowiedzialna'**
  String get defectResponsibleLabel;

  /// No description provided for @defectNoResponsible.
  ///
  /// In pl, this message translates to:
  /// **'Bez przypisanej osoby'**
  String get defectNoResponsible;

  /// No description provided for @defectRequiresPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Wymagaj zdjęcia po naprawie przed zamknięciem'**
  String get defectRequiresPhoto;

  /// No description provided for @defectRequiresProtocol.
  ///
  /// In pl, this message translates to:
  /// **'Wymagaj podpisanego protokołu przed zamknięciem'**
  String get defectRequiresProtocol;

  /// No description provided for @defectReportEvidenceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia przy zgłoszeniu'**
  String get defectReportEvidenceTitle;

  /// No description provided for @defectResolutionEvidenceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia po naprawie'**
  String get defectResolutionEvidenceTitle;

  /// No description provided for @defectAddEvidence.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie'**
  String get defectAddEvidence;

  /// No description provided for @defectRemoveEvidence.
  ///
  /// In pl, this message translates to:
  /// **'Usuń załącznik'**
  String get defectRemoveEvidence;

  /// No description provided for @defectNoEvidence.
  ///
  /// In pl, this message translates to:
  /// **'Brak zdjęć'**
  String get defectNoEvidence;

  /// No description provided for @defectUnsupportedEvidence.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz plik obrazu, np. JPG, PNG lub HEIC.'**
  String get defectUnsupportedEvidence;

  /// No description provided for @defectSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz usterkę'**
  String get defectSaveAction;

  /// No description provided for @defectSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Usterka została zapisana.'**
  String get defectSavedMessage;

  /// No description provided for @defectSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać usterki. Sprawdź wymagane pola.'**
  String get defectSaveError;

  /// No description provided for @defectNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Usterka nie istnieje albo została usunięta.'**
  String get defectNotFound;

  /// No description provided for @defectEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj usterkę'**
  String get defectEditTooltip;

  /// No description provided for @defectCloseAction.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij usterkę'**
  String get defectCloseAction;

  /// No description provided for @defectSetStatusAction.
  ///
  /// In pl, this message translates to:
  /// **'Zmień status'**
  String get defectSetStatusAction;

  /// No description provided for @defectClosureReady.
  ///
  /// In pl, this message translates to:
  /// **'Komplet dowodów do zamknięcia'**
  String get defectClosureReady;

  /// No description provided for @defectClosureMissingPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie po naprawie.'**
  String get defectClosureMissingPhoto;

  /// No description provided for @defectClosureMissingProtocol.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj podpisany protokół powiązany z usterką.'**
  String get defectClosureMissingProtocol;

  /// No description provided for @defectStatusChangeError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zmienić statusu usterki.'**
  String get defectStatusChangeError;

  /// No description provided for @defectAttachmentError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dodać załącznika.'**
  String get defectAttachmentError;

  /// No description provided for @protocolNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy protokół odbioru'**
  String get protocolNewTitle;

  /// No description provided for @protocolEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj protokół'**
  String get protocolEditTitle;

  /// No description provided for @protocolDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły protokołu'**
  String get protocolDetailsTitle;

  /// No description provided for @protocolTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa protokołu'**
  String get protocolTitleLabel;

  /// No description provided for @protocolDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data odbioru'**
  String get protocolDateLabel;

  /// No description provided for @protocolStatusLabel.
  ///
  /// In pl, this message translates to:
  /// **'Status protokołu'**
  String get protocolStatusLabel;

  /// No description provided for @protocolStatusDraft.
  ///
  /// In pl, this message translates to:
  /// **'Szkic'**
  String get protocolStatusDraft;

  /// No description provided for @protocolStatusFinalized.
  ///
  /// In pl, this message translates to:
  /// **'Gotowy do podpisu'**
  String get protocolStatusFinalized;

  /// No description provided for @protocolStatusSigned.
  ///
  /// In pl, this message translates to:
  /// **'Podpisany'**
  String get protocolStatusSigned;

  /// No description provided for @protocolStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get protocolStageLabel;

  /// No description provided for @protocolRoomLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie lub strefa'**
  String get protocolRoomLabel;

  /// No description provided for @protocolContractorLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wykonawca'**
  String get protocolContractorLabel;

  /// No description provided for @protocolNotesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ustalenia i uwagi z odbioru'**
  String get protocolNotesLabel;

  /// No description provided for @protocolDefectsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usterki w protokole'**
  String get protocolDefectsTitle;

  /// No description provided for @protocolSelectDefects.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz usterki'**
  String get protocolSelectDefects;

  /// No description provided for @protocolNoDefects.
  ///
  /// In pl, this message translates to:
  /// **'Brak powiązanych usterek'**
  String get protocolNoDefects;

  /// No description provided for @protocolSignedFilesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podpisany dokument'**
  String get protocolSignedFilesTitle;

  /// No description provided for @protocolAddSignedFile.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj skan lub PDF'**
  String get protocolAddSignedFile;

  /// No description provided for @protocolNoSignedFile.
  ///
  /// In pl, this message translates to:
  /// **'Brak podpisanego dokumentu'**
  String get protocolNoSignedFile;

  /// No description provided for @protocolSignedFileRequired.
  ///
  /// In pl, this message translates to:
  /// **'Status „Podpisany” wymaga skanu lub pliku PDF.'**
  String get protocolSignedFileRequired;

  /// No description provided for @protocolUnsupportedFile.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz obraz albo plik PDF.'**
  String get protocolUnsupportedFile;

  /// No description provided for @protocolSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz protokół'**
  String get protocolSaveAction;

  /// No description provided for @protocolSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Protokół został zapisany.'**
  String get protocolSavedMessage;

  /// No description provided for @protocolSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać protokołu. Sprawdź wymagane pola.'**
  String get protocolSaveError;

  /// No description provided for @protocolNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Protokół nie istnieje albo został usunięty.'**
  String get protocolNotFound;

  /// No description provided for @protocolEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj protokół'**
  String get protocolEditTooltip;

  /// No description provided for @protocolGeneratePdf.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz PDF protokołu'**
  String get protocolGeneratePdf;

  /// No description provided for @protocolSelectDefectsDone.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get protocolSelectDefectsDone;

  /// No description provided for @protocolPdfTitle.
  ///
  /// In pl, this message translates to:
  /// **'Protokół odbioru'**
  String get protocolPdfTitle;

  /// No description provided for @protocolPdfProjectLabel.
  ///
  /// In pl, this message translates to:
  /// **'Projekt'**
  String get protocolPdfProjectLabel;

  /// No description provided for @protocolPdfDefectTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Usterka'**
  String get protocolPdfDefectTitleLabel;

  /// No description provided for @protocolPdfDeadlineLabel.
  ///
  /// In pl, this message translates to:
  /// **'Termin'**
  String get protocolPdfDeadlineLabel;

  /// No description provided for @protocolPdfSignaturesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdzenie odbioru'**
  String get protocolPdfSignaturesTitle;

  /// No description provided for @protocolPdfInvestorSignature.
  ///
  /// In pl, this message translates to:
  /// **'Podpis inwestora'**
  String get protocolPdfInvestorSignature;

  /// No description provided for @protocolPdfContractorSignature.
  ///
  /// In pl, this message translates to:
  /// **'Podpis wykonawcy'**
  String get protocolPdfContractorSignature;

  /// No description provided for @protocolPdfGeneratedNotice.
  ///
  /// In pl, this message translates to:
  /// **'Dokument wygenerowany lokalnie w BudowaPRO. Sam wydruk nie zastępuje podpisanego protokołu.'**
  String get protocolPdfGeneratedNotice;

  /// No description provided for @protocolPdfShareError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się utworzyć lub udostępnić pliku PDF.'**
  String get protocolPdfShareError;

  /// No description provided for @technicalPhotoLinksTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiązania zdjęcia'**
  String get technicalPhotoLinksTitle;

  /// No description provided for @technicalPhotoNoLink.
  ///
  /// In pl, this message translates to:
  /// **'Bez powiązania'**
  String get technicalPhotoNoLink;

  /// No description provided for @technicalPhotoCostLink.
  ///
  /// In pl, this message translates to:
  /// **'Koszt'**
  String get technicalPhotoCostLink;

  /// No description provided for @technicalPhotoDecisionLink.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja lub zmiana zakresu'**
  String get technicalPhotoDecisionLink;

  /// No description provided for @technicalPhotoDefectLink.
  ///
  /// In pl, this message translates to:
  /// **'Usterka'**
  String get technicalPhotoDefectLink;

  /// No description provided for @technicalPhotoProtocolLink.
  ///
  /// In pl, this message translates to:
  /// **'Protokół odbioru'**
  String get technicalPhotoProtocolLink;

  /// No description provided for @dashboardAddDefect.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj usterkę'**
  String get dashboardAddDefect;

  /// No description provided for @dashboardOpenPunch.
  ///
  /// In pl, this message translates to:
  /// **'Usterki i odbiory'**
  String get dashboardOpenPunch;

  /// No description provided for @dashboardOpenTechnicalPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia etapów'**
  String get dashboardOpenTechnicalPhotos;

  /// No description provided for @roomsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenia'**
  String get roomsTitle;

  /// No description provided for @roomsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Budżety, wybory i postęp każdego pomieszczenia'**
  String get roomsSubtitle;

  /// No description provided for @roomsLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie pomieszczeń'**
  String get roomsLoading;

  /// No description provided for @roomsLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać pomieszczeń.'**
  String get roomsLoadError;

  /// No description provided for @roomsNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get roomsNoProjectTitle;

  /// No description provided for @roomsNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenia są przypisane do wybranej budowy lub remontu.'**
  String get roomsNoProjectMessage;

  /// No description provided for @roomsEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomieszczeń'**
  String get roomsEmptyTitle;

  /// No description provided for @roomsEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwsze pomieszczenie, aby osobno pilnować budżetu, wyborów i usterek.'**
  String get roomsEmptyMessage;

  /// No description provided for @roomsSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj pomieszczenia lub kondygnacji'**
  String get roomsSearchHint;

  /// No description provided for @roomsSearchAction.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj'**
  String get roomsSearchAction;

  /// No description provided for @roomsClearSearch.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść wyszukiwanie'**
  String get roomsClearSearch;

  /// No description provided for @roomsAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pomieszczenie'**
  String get roomsAddTooltip;

  /// No description provided for @roomsLoadMore.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj kolejne'**
  String get roomsLoadMore;

  /// No description provided for @roomsRoomCount.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenia: {count}'**
  String roomsRoomCount(int count);

  /// No description provided for @roomsPlannedTotal.
  ///
  /// In pl, this message translates to:
  /// **'Budżet pomieszczeń'**
  String get roomsPlannedTotal;

  /// No description provided for @roomsActualTotal.
  ///
  /// In pl, this message translates to:
  /// **'Koszt przypisany'**
  String get roomsActualTotal;

  /// No description provided for @roomsOpenChoices.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte wybory'**
  String get roomsOpenChoices;

  /// No description provided for @roomNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowe pomieszczenie'**
  String get roomNewTitle;

  /// No description provided for @roomEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj pomieszczenie'**
  String get roomEditTitle;

  /// No description provided for @roomDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Karta pomieszczenia'**
  String get roomDetailsTitle;

  /// No description provided for @roomNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa pomieszczenia lub strefy'**
  String get roomNameLabel;

  /// No description provided for @roomFloorLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kondygnacja lub część budynku'**
  String get roomFloorLabel;

  /// No description provided for @roomStandardLabel.
  ///
  /// In pl, this message translates to:
  /// **'Standard wykończenia'**
  String get roomStandardLabel;

  /// No description provided for @roomStandardBasic.
  ///
  /// In pl, this message translates to:
  /// **'Podstawowy'**
  String get roomStandardBasic;

  /// No description provided for @roomStandardStandard.
  ///
  /// In pl, this message translates to:
  /// **'Standardowy'**
  String get roomStandardStandard;

  /// No description provided for @roomStandardElevated.
  ///
  /// In pl, this message translates to:
  /// **'Podwyższony'**
  String get roomStandardElevated;

  /// No description provided for @roomStandardCustom.
  ///
  /// In pl, this message translates to:
  /// **'Indywidualny'**
  String get roomStandardCustom;

  /// No description provided for @roomDimensionsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wymiary pomieszczenia'**
  String get roomDimensionsTitle;

  /// No description provided for @roomLengthLabel.
  ///
  /// In pl, this message translates to:
  /// **'Długość'**
  String get roomLengthLabel;

  /// No description provided for @roomWidthLabel.
  ///
  /// In pl, this message translates to:
  /// **'Szerokość'**
  String get roomWidthLabel;

  /// No description provided for @roomHeightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość'**
  String get roomHeightLabel;

  /// No description provided for @roomMetersSuffix.
  ///
  /// In pl, this message translates to:
  /// **'m'**
  String get roomMetersSuffix;

  /// No description provided for @roomBudgetLabel.
  ///
  /// In pl, this message translates to:
  /// **'Planowany budżet'**
  String get roomBudgetLabel;

  /// No description provided for @roomNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get roomNoteLabel;

  /// No description provided for @roomSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz pomieszczenie'**
  String get roomSaveAction;

  /// No description provided for @roomSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie zostało zapisane.'**
  String get roomSavedMessage;

  /// No description provided for @roomSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać pomieszczenia. Sprawdź wymagane pola.'**
  String get roomSaveError;

  /// No description provided for @roomConflictError.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie o tej nazwie już istnieje na wskazanej kondygnacji.'**
  String get roomConflictError;

  /// No description provided for @roomNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie nie istnieje albo zostało usunięte.'**
  String get roomNotFound;

  /// No description provided for @roomEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj pomieszczenie'**
  String get roomEditTooltip;

  /// No description provided for @roomDeleteTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pomieszczenie'**
  String get roomDeleteTooltip;

  /// No description provided for @roomDeleteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć pomieszczenie?'**
  String get roomDeleteTitle;

  /// No description provided for @roomDeleteMessage.
  ///
  /// In pl, this message translates to:
  /// **'Usunięte zostaną karty wyborów i przypisania. Koszty, zdjęcia, kontakty i usterki pozostaną w projekcie.'**
  String get roomDeleteMessage;

  /// No description provided for @roomDeleteAction.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pomieszczenie'**
  String get roomDeleteAction;

  /// No description provided for @roomDeleteError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć pomieszczenia.'**
  String get roomDeleteError;

  /// No description provided for @roomBudgetPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Plan'**
  String get roomBudgetPlanned;

  /// No description provided for @roomBudgetActual.
  ///
  /// In pl, this message translates to:
  /// **'Wydano'**
  String get roomBudgetActual;

  /// No description provided for @roomBudgetRemaining.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało'**
  String get roomBudgetRemaining;

  /// No description provided for @roomNoBudget.
  ///
  /// In pl, this message translates to:
  /// **'Nie ustawiono budżetu'**
  String get roomNoBudget;

  /// No description provided for @roomChoicesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybory i warianty'**
  String get roomChoicesTitle;

  /// No description provided for @roomAddChoiceAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wybór'**
  String get roomAddChoiceAction;

  /// No description provided for @roomNoChoices.
  ///
  /// In pl, this message translates to:
  /// **'Brak kart wyborów'**
  String get roomNoChoices;

  /// No description provided for @roomNoChoicesMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj np. płytki, drzwi, armaturę lub kolor farby i porównaj warianty.'**
  String get roomNoChoicesMessage;

  /// No description provided for @roomChoiceStatusOpen.
  ///
  /// In pl, this message translates to:
  /// **'Do wyboru'**
  String get roomChoiceStatusOpen;

  /// No description provided for @roomChoiceStatusSelected.
  ///
  /// In pl, this message translates to:
  /// **'Wybrano'**
  String get roomChoiceStatusSelected;

  /// No description provided for @roomChoiceStatusCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Anulowano'**
  String get roomChoiceStatusCancelled;

  /// No description provided for @roomChoiceSelectAction.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz wariant'**
  String get roomChoiceSelectAction;

  /// No description provided for @roomChoiceReopenAction.
  ///
  /// In pl, this message translates to:
  /// **'Zmień wybór'**
  String get roomChoiceReopenAction;

  /// No description provided for @roomChoiceCancelAction.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj wybór'**
  String get roomChoiceCancelAction;

  /// No description provided for @roomChoiceEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj kartę wyboru'**
  String get roomChoiceEditTooltip;

  /// No description provided for @roomChoiceDeleteTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń kartę wyboru'**
  String get roomChoiceDeleteTooltip;

  /// No description provided for @roomChoiceEstimatedTotal.
  ///
  /// In pl, this message translates to:
  /// **'Szacunkowo: {amount}'**
  String roomChoiceEstimatedTotal(String amount);

  /// No description provided for @roomChoiceQuantityWithWaste.
  ///
  /// In pl, this message translates to:
  /// **'Ilość z zapasem: {quantity} {unit}'**
  String roomChoiceQuantityWithWaste(String quantity, String unit);

  /// No description provided for @roomChoiceOrderDue.
  ///
  /// In pl, this message translates to:
  /// **'Zamów do: {date}'**
  String roomChoiceOrderDue(String date);

  /// No description provided for @roomChoiceNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowa karta wyboru'**
  String get roomChoiceNewTitle;

  /// No description provided for @roomChoiceEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj kartę wyboru'**
  String get roomChoiceEditTitle;

  /// No description provided for @roomChoiceTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Co wybierasz?'**
  String get roomChoiceTitleLabel;

  /// No description provided for @roomChoiceQuantityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość'**
  String get roomChoiceQuantityLabel;

  /// No description provided for @roomChoiceUnitLabel.
  ///
  /// In pl, this message translates to:
  /// **'Jednostka'**
  String get roomChoiceUnitLabel;

  /// No description provided for @roomChoiceWasteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zapas'**
  String get roomChoiceWasteLabel;

  /// No description provided for @roomChoiceWasteSuffix.
  ///
  /// In pl, this message translates to:
  /// **'%'**
  String get roomChoiceWasteSuffix;

  /// No description provided for @roomChoiceOrderDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Termin zamówienia'**
  String get roomChoiceOrderDateLabel;

  /// No description provided for @roomChoiceNoOrderDate.
  ///
  /// In pl, this message translates to:
  /// **'Bez terminu zamówienia'**
  String get roomChoiceNoOrderDate;

  /// No description provided for @roomChoiceClearOrderDate.
  ///
  /// In pl, this message translates to:
  /// **'Usuń termin'**
  String get roomChoiceClearOrderDate;

  /// No description provided for @roomChoiceNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka do wyboru'**
  String get roomChoiceNoteLabel;

  /// No description provided for @roomChoiceVariantsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Porównywane warianty'**
  String get roomChoiceVariantsTitle;

  /// No description provided for @roomChoiceAddVariant.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wariant'**
  String get roomChoiceAddVariant;

  /// No description provided for @roomChoiceRemoveVariant.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wariant'**
  String get roomChoiceRemoveVariant;

  /// No description provided for @roomChoiceVariantLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa wariantu'**
  String get roomChoiceVariantLabel;

  /// No description provided for @roomChoiceVariantPriceLabel.
  ///
  /// In pl, this message translates to:
  /// **'Cena brutto za jednostkę'**
  String get roomChoiceVariantPriceLabel;

  /// No description provided for @roomChoiceVariantSupplierLabel.
  ///
  /// In pl, this message translates to:
  /// **'Sklep lub dostawca'**
  String get roomChoiceVariantSupplierLabel;

  /// No description provided for @roomChoiceVariantCodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod produktu'**
  String get roomChoiceVariantCodeLabel;

  /// No description provided for @roomChoiceVariantNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Uwagi do wariantu'**
  String get roomChoiceVariantNoteLabel;

  /// No description provided for @roomChoiceSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz kartę wyboru'**
  String get roomChoiceSaveAction;

  /// No description provided for @roomChoiceSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Karta wyboru została zapisana.'**
  String get roomChoiceSavedMessage;

  /// No description provided for @roomChoiceSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać karty wyboru. Dodaj co najmniej jeden poprawny wariant.'**
  String get roomChoiceSaveError;

  /// No description provided for @roomChoiceSelectionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź wariant'**
  String get roomChoiceSelectionTitle;

  /// No description provided for @roomChoiceSelectionMessage.
  ///
  /// In pl, this message translates to:
  /// **'Wybór zostanie zapisany jako decyzja w karcie pomieszczenia. Nie utworzy kosztu ani zamówienia bez osobnej akcji.'**
  String get roomChoiceSelectionMessage;

  /// No description provided for @roomChoiceCreatePlannedCost.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz szkic kosztu'**
  String get roomChoiceCreatePlannedCost;

  /// No description provided for @roomChoicePlannedCostCreated.
  ///
  /// In pl, this message translates to:
  /// **'Szkic kosztu utworzony'**
  String get roomChoicePlannedCostCreated;

  /// No description provided for @roomChoiceCreateMaterial.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do materiałów'**
  String get roomChoiceCreateMaterial;

  /// No description provided for @roomChoiceMaterialCreated.
  ///
  /// In pl, this message translates to:
  /// **'Materiał dodany'**
  String get roomChoiceMaterialCreated;

  /// No description provided for @roomChoiceCreateDecision.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz decyzję'**
  String get roomChoiceCreateDecision;

  /// No description provided for @roomChoiceDecisionCreated.
  ///
  /// In pl, this message translates to:
  /// **'Decyzja utworzona'**
  String get roomChoiceDecisionCreated;

  /// No description provided for @roomChoiceOutputError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się utworzyć powiązanego rekordu.'**
  String get roomChoiceOutputError;

  /// No description provided for @roomChoiceVatTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz stawkę VAT dla planowanego kosztu'**
  String get roomChoiceVatTitle;

  /// No description provided for @roomChoiceCostName.
  ///
  /// In pl, this message translates to:
  /// **'{choice}: {variant}'**
  String roomChoiceCostName(String choice, String variant);

  /// No description provided for @roomChoiceCostNote.
  ///
  /// In pl, this message translates to:
  /// **'Szkic utworzony z karty wyboru w pomieszczeniu: {room}.'**
  String roomChoiceCostNote(String room);

  /// No description provided for @roomChoiceDecisionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybór w pomieszczeniu {room}: {choice}'**
  String roomChoiceDecisionTitle(String room, String choice);

  /// No description provided for @roomRelatedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane dane'**
  String get roomRelatedTitle;

  /// No description provided for @roomRelatedDecisions.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte decyzje'**
  String get roomRelatedDecisions;

  /// No description provided for @roomRelatedMaterials.
  ///
  /// In pl, this message translates to:
  /// **'Materiały'**
  String get roomRelatedMaterials;

  /// No description provided for @roomRelatedTeams.
  ///
  /// In pl, this message translates to:
  /// **'Ekipy'**
  String get roomRelatedTeams;

  /// No description provided for @roomRelatedPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia techniczne'**
  String get roomRelatedPhotos;

  /// No description provided for @roomRelatedDefects.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte usterki'**
  String get roomRelatedDefects;

  /// No description provided for @roomRelatedCosts.
  ///
  /// In pl, this message translates to:
  /// **'Koszty'**
  String get roomRelatedCosts;

  /// No description provided for @roomManageRelationsAction.
  ///
  /// In pl, this message translates to:
  /// **'Przypisz dane'**
  String get roomManageRelationsAction;

  /// No description provided for @roomRelationsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dane pomieszczenia'**
  String get roomRelationsTitle;

  /// No description provided for @roomRelationsSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj na tej liście'**
  String get roomRelationsSearchHint;

  /// No description provided for @roomRelationsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak elementów do przypisania.'**
  String get roomRelationsEmpty;

  /// No description provided for @roomRelationsAssignedElsewhere.
  ///
  /// In pl, this message translates to:
  /// **'Przypisano do: {roomName}'**
  String roomRelationsAssignedElsewhere(String roomName);

  /// No description provided for @roomRelationsMoveTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przenieść przypisanie?'**
  String get roomRelationsMoveTitle;

  /// No description provided for @roomRelationsMoveMessage.
  ///
  /// In pl, this message translates to:
  /// **'Ten element jest przypisany do pomieszczenia „{roomName}”. Po zatwierdzeniu zostanie przeniesiony tutaj.'**
  String roomRelationsMoveMessage(String roomName);

  /// No description provided for @roomRelationsMoveAction.
  ///
  /// In pl, this message translates to:
  /// **'Przenieś'**
  String get roomRelationsMoveAction;

  /// No description provided for @roomRelationsSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zmienić przypisania.'**
  String get roomRelationsSaveError;

  /// No description provided for @roomRelatedCount.
  ///
  /// In pl, this message translates to:
  /// **'{count}'**
  String roomRelatedCount(int count);

  /// No description provided for @roomSelectedChoiceEditNotice.
  ///
  /// In pl, this message translates to:
  /// **'Edycja ponownie otworzy wybór i będzie wymagała jawnego zatwierdzenia wariantu.'**
  String get roomSelectedChoiceEditNotice;

  /// No description provided for @requiredFieldError.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij wymagane pole.'**
  String get requiredFieldError;

  /// No description provided for @invalidAmountError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kwotę z maksymalnie dwiema cyframi po przecinku.'**
  String get invalidAmountError;

  /// No description provided for @invalidNumberError.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz dodatnią liczbę.'**
  String get invalidNumberError;

  /// No description provided for @materialsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Materiały i dostawy'**
  String get materialsTitle;

  /// No description provided for @materialsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zamówienia, dostawy, składowanie i zwroty'**
  String get materialsSubtitle;

  /// No description provided for @materialsLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie materiałów'**
  String get materialsLoading;

  /// No description provided for @materialsLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać materiałów.'**
  String get materialsLoadError;

  /// No description provided for @materialsNoProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz projekt'**
  String get materialsNoProjectTitle;

  /// No description provided for @materialsNoProjectMessage.
  ///
  /// In pl, this message translates to:
  /// **'Materiały są przypisane do konkretnej budowy lub remontu.'**
  String get materialsNoProjectMessage;

  /// No description provided for @materialsEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak materiałów'**
  String get materialsEmptyTitle;

  /// No description provided for @materialsEmptyMessage.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy materiał, aby kontrolować zamówienie, dostawy i zwroty.'**
  String get materialsEmptyMessage;

  /// No description provided for @materialsNoResultsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak pasujących materiałów'**
  String get materialsNoResultsTitle;

  /// No description provided for @materialsNoResultsMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zmień wyszukiwanie lub filtry statusu.'**
  String get materialsNoResultsMessage;

  /// No description provided for @materialsSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj materiału lub miejsca składowania'**
  String get materialsSearchHint;

  /// No description provided for @materialsClearSearch.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść wyszukiwanie'**
  String get materialsClearSearch;

  /// No description provided for @materialsAddTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj materiał'**
  String get materialsAddTooltip;

  /// No description provided for @materialsLoadMore.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj więcej'**
  String get materialsLoadMore;

  /// No description provided for @materialsOrderedValue.
  ///
  /// In pl, this message translates to:
  /// **'Wartość zamówień'**
  String get materialsOrderedValue;

  /// No description provided for @materialsExpectedReturns.
  ///
  /// In pl, this message translates to:
  /// **'Planowane zwroty'**
  String get materialsExpectedReturns;

  /// No description provided for @materialsDelayedCount.
  ///
  /// In pl, this message translates to:
  /// **'Opóźnienia'**
  String get materialsDelayedCount;

  /// No description provided for @materialsOverdueReturns.
  ///
  /// In pl, this message translates to:
  /// **'Zwroty po terminie'**
  String get materialsOverdueReturns;

  /// No description provided for @materialsOpenDeliveries.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte dostawy'**
  String get materialsOpenDeliveries;

  /// No description provided for @materialStatusPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Planowany'**
  String get materialStatusPlanned;

  /// No description provided for @materialStatusOrdered.
  ///
  /// In pl, this message translates to:
  /// **'Zamówiony'**
  String get materialStatusOrdered;

  /// No description provided for @materialStatusPartiallyDelivered.
  ///
  /// In pl, this message translates to:
  /// **'Częściowo dostarczony'**
  String get materialStatusPartiallyDelivered;

  /// No description provided for @materialStatusDelivered.
  ///
  /// In pl, this message translates to:
  /// **'Dostarczony'**
  String get materialStatusDelivered;

  /// No description provided for @materialStatusDelayed.
  ///
  /// In pl, this message translates to:
  /// **'Opóźniony'**
  String get materialStatusDelayed;

  /// No description provided for @materialStatusReturned.
  ///
  /// In pl, this message translates to:
  /// **'Zwrócony'**
  String get materialStatusReturned;

  /// No description provided for @materialNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy materiał'**
  String get materialNewTitle;

  /// No description provided for @materialEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj materiał'**
  String get materialEditTitle;

  /// No description provided for @materialDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły materiału'**
  String get materialDetailsTitle;

  /// No description provided for @materialNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono materiału.'**
  String get materialNotFound;

  /// No description provided for @materialNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa materiału'**
  String get materialNameLabel;

  /// No description provided for @materialQuantityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość zamówiona'**
  String get materialQuantityLabel;

  /// No description provided for @materialUnitLabel.
  ///
  /// In pl, this message translates to:
  /// **'Jednostka'**
  String get materialUnitLabel;

  /// No description provided for @materialDefaultUnit.
  ///
  /// In pl, this message translates to:
  /// **'szt.'**
  String get materialDefaultUnit;

  /// No description provided for @materialStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap'**
  String get materialStageLabel;

  /// No description provided for @materialRoomLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pomieszczenie'**
  String get materialRoomLabel;

  /// No description provided for @materialSupplierLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dostawca'**
  String get materialSupplierLabel;

  /// No description provided for @materialCostLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powiązany koszt'**
  String get materialCostLabel;

  /// No description provided for @materialReceiptLabel.
  ///
  /// In pl, this message translates to:
  /// **'Paragon lub faktura'**
  String get materialReceiptLabel;

  /// No description provided for @materialOrderedGrossLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wartość zamówienia brutto'**
  String get materialOrderedGrossLabel;

  /// No description provided for @materialStorageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce składowania'**
  String get materialStorageLabel;

  /// No description provided for @materialOrderedToggle.
  ///
  /// In pl, this message translates to:
  /// **'Materiał został zamówiony'**
  String get materialOrderedToggle;

  /// No description provided for @materialOrderedDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data zamówienia'**
  String get materialOrderedDateLabel;

  /// No description provided for @materialExpectedDeliveryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Planowana dostawa'**
  String get materialExpectedDeliveryLabel;

  /// No description provided for @materialReminderToggle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie o terminie'**
  String get materialReminderToggle;

  /// No description provided for @materialNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get materialNoteLabel;

  /// No description provided for @materialNoRelation.
  ///
  /// In pl, this message translates to:
  /// **'Brak przypisania'**
  String get materialNoRelation;

  /// No description provided for @materialSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz materiał'**
  String get materialSaveAction;

  /// No description provided for @materialSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać materiału. Sprawdź powiązania i wartości.'**
  String get materialSaveError;

  /// No description provided for @materialEditTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj materiał'**
  String get materialEditTooltip;

  /// No description provided for @materialDeleteTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń materiał'**
  String get materialDeleteTooltip;

  /// No description provided for @materialDeleteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć materiał?'**
  String get materialDeleteTitle;

  /// No description provided for @materialDeleteMessage.
  ///
  /// In pl, this message translates to:
  /// **'Materiał zostanie usunięty. Powiązane koszty, dokumenty i kontakty pozostaną bez zmian. Materiału z historią dostaw lub zwrotów nie można usunąć.'**
  String get materialDeleteMessage;

  /// No description provided for @materialDeleteAction.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get materialDeleteAction;

  /// No description provided for @materialDeleteInUseError.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw usuń powiązane dostawy i zwroty. Chroni to historię przed przypadkową utratą.'**
  String get materialDeleteInUseError;

  /// No description provided for @materialDeleteError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć materiału.'**
  String get materialDeleteError;

  /// No description provided for @materialOrderedQuantity.
  ///
  /// In pl, this message translates to:
  /// **'Zamówiono'**
  String get materialOrderedQuantity;

  /// No description provided for @materialDeliveredQuantity.
  ///
  /// In pl, this message translates to:
  /// **'Dostarczono'**
  String get materialDeliveredQuantity;

  /// No description provided for @materialReturnedQuantity.
  ///
  /// In pl, this message translates to:
  /// **'Zwrócono'**
  String get materialReturnedQuantity;

  /// No description provided for @materialRelationsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiązania i składowanie'**
  String get materialRelationsTitle;

  /// No description provided for @materialDeliveriesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dostawy'**
  String get materialDeliveriesTitle;

  /// No description provided for @materialAddDeliveryAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj dostawę'**
  String get materialAddDeliveryAction;

  /// No description provided for @materialNoDeliveries.
  ///
  /// In pl, this message translates to:
  /// **'Nie zapisano jeszcze dostaw.'**
  String get materialNoDeliveries;

  /// No description provided for @materialDeliveryExpectedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość w tej dostawie'**
  String get materialDeliveryExpectedLabel;

  /// No description provided for @materialDeliveryDueLabel.
  ///
  /// In pl, this message translates to:
  /// **'Termin dostawy'**
  String get materialDeliveryDueLabel;

  /// No description provided for @materialDeliveryReceivedToggle.
  ///
  /// In pl, this message translates to:
  /// **'Dostawa odebrana'**
  String get materialDeliveryReceivedToggle;

  /// No description provided for @materialDeliveryActualLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość odebrana'**
  String get materialDeliveryActualLabel;

  /// No description provided for @materialDeliveryDocumentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dokument WZ'**
  String get materialDeliveryDocumentLabel;

  /// No description provided for @materialDeliveryContactLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt przy dostawie'**
  String get materialDeliveryContactLabel;

  /// No description provided for @materialDeliveryShortageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Braki ilościowe'**
  String get materialDeliveryShortageLabel;

  /// No description provided for @materialDeliveryDamageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Uszkodzenia i zastrzeżenia'**
  String get materialDeliveryDamageLabel;

  /// No description provided for @materialDeliverySaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz dostawę'**
  String get materialDeliverySaveAction;

  /// No description provided for @materialDeliverySaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać dostawy.'**
  String get materialDeliverySaveError;

  /// No description provided for @materialDeliveryOverTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dostawa przekracza zamówienie'**
  String get materialDeliveryOverTitle;

  /// No description provided for @materialDeliveryOverMessage.
  ///
  /// In pl, this message translates to:
  /// **'Suma odebrana jest większa niż ilość zamówiona. Potwierdzenie skoryguje ilość zamówioną do faktycznie odebranej.'**
  String get materialDeliveryOverMessage;

  /// No description provided for @materialDeliveryOverAction.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź korektę'**
  String get materialDeliveryOverAction;

  /// No description provided for @materialDeliveryDelayed.
  ///
  /// In pl, this message translates to:
  /// **'Po terminie'**
  String get materialDeliveryDelayed;

  /// No description provided for @materialDeliveryReceived.
  ///
  /// In pl, this message translates to:
  /// **'Odebrana'**
  String get materialDeliveryReceived;

  /// No description provided for @materialDeliveryPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanowana'**
  String get materialDeliveryPlanned;

  /// No description provided for @materialReturnsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zwroty'**
  String get materialReturnsTitle;

  /// No description provided for @materialAddReturnAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zwrot'**
  String get materialAddReturnAction;

  /// No description provided for @materialNoReturns.
  ///
  /// In pl, this message translates to:
  /// **'Nie zapisano materiału do zwrotu.'**
  String get materialNoReturns;

  /// No description provided for @materialReturnQuantityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość do zwrotu'**
  String get materialReturnQuantityLabel;

  /// No description provided for @materialReturnDeadlineLabel.
  ///
  /// In pl, this message translates to:
  /// **'Termin zwrotu'**
  String get materialReturnDeadlineLabel;

  /// No description provided for @materialReturnExpectedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Przewidywany zwrot pieniędzy'**
  String get materialReturnExpectedLabel;

  /// No description provided for @materialReturnReceiptRequired.
  ///
  /// In pl, this message translates to:
  /// **'Paragon lub faktura są wymagane'**
  String get materialReturnReceiptRequired;

  /// No description provided for @materialReturnDocumentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dokument zakupu'**
  String get materialReturnDocumentLabel;

  /// No description provided for @materialReturnCompletedToggle.
  ///
  /// In pl, this message translates to:
  /// **'Zwrot wykonany'**
  String get materialReturnCompletedToggle;

  /// No description provided for @materialReturnActualLabel.
  ///
  /// In pl, this message translates to:
  /// **'Faktycznie odzyskana kwota'**
  String get materialReturnActualLabel;

  /// No description provided for @materialReturnSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zwrot'**
  String get materialReturnSaveAction;

  /// No description provided for @materialReturnSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać zwrotu.'**
  String get materialReturnSaveError;

  /// No description provided for @materialReturnOverdue.
  ///
  /// In pl, this message translates to:
  /// **'Termin zwrotu minął'**
  String get materialReturnOverdue;

  /// No description provided for @materialReturnCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Zwrot wykonany'**
  String get materialReturnCompleted;

  /// No description provided for @materialReturnPending.
  ///
  /// In pl, this message translates to:
  /// **'Do zwrotu'**
  String get materialReturnPending;

  /// No description provided for @materialRecordDeleteTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wpis'**
  String get materialRecordDeleteTooltip;

  /// No description provided for @materialRecordDeleteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć ten wpis?'**
  String get materialRecordDeleteTitle;

  /// No description provided for @materialRecordDeleteMessage.
  ///
  /// In pl, this message translates to:
  /// **'Tej operacji nie można cofnąć. Dostawa albo zwrot zniknie z historii materiału.'**
  String get materialRecordDeleteMessage;

  /// No description provided for @materialInvalidQuantity.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz dodatnią ilość z maksymalnie sześcioma cyframi po przecinku.'**
  String get materialInvalidQuantity;

  /// No description provided for @materialDatePickTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę'**
  String get materialDatePickTooltip;

  /// No description provided for @materialRelationMissing.
  ///
  /// In pl, this message translates to:
  /// **'Powiązany rekord został usunięty lub należy do innego projektu.'**
  String get materialRelationMissing;

  /// No description provided for @receiptStageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Etap dokumentu'**
  String get receiptStageLabel;

  /// No description provided for @receiptApplyComponentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw skład dla wszystkich pozycji'**
  String get receiptApplyComponentLabel;

  /// No description provided for @receiptComponentRequiredMessage.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz materiał, robociznę albo wspólną wycenę dla każdej pozycji.'**
  String get receiptComponentRequiredMessage;
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
