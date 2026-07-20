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
