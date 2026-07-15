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
