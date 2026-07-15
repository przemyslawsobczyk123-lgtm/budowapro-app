// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'BudowaPRO';

  @override
  String get navStart => 'Start';

  @override
  String get navPlan => 'Plan';

  @override
  String get navBudget => 'Budżet';

  @override
  String get navBuild => 'Budowa';

  @override
  String get navMore => 'Więcej';

  @override
  String get startTitle => 'Centrum budowy';

  @override
  String get startSubtitle => 'Brak aktywnego projektu.';

  @override
  String get planTitle => 'Plan budowy';

  @override
  String get planSubtitle => 'Brak etapów dla aktywnego projektu.';

  @override
  String get budgetTitle => 'Budżet inwestycji';

  @override
  String get budgetSubtitle => 'Brak kosztów dla aktywnego projektu.';

  @override
  String get buildTitle => 'Dokumentacja budowy';

  @override
  String get buildSubtitle => 'Brak dokumentów dla aktywnego projektu.';

  @override
  String get moreTitle => 'Narzędzia projektu';

  @override
  String get moreSubtitle => 'Brak dodatkowych danych projektu.';
}
