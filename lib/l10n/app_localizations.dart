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
