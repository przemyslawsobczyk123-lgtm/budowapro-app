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

  @override
  String get projectsLoading => 'Ładowanie projektów…';

  @override
  String get projectsLoadError => 'Nie udało się wczytać projektów.';

  @override
  String get retryAction => 'Spróbuj ponownie';

  @override
  String get cancelAction => 'Anuluj';

  @override
  String get unsavedChangesTitle => 'Niezapisane zmiany';

  @override
  String get unsavedChangesMessage =>
      'Zmiany w formularzu nie zostały zapisane. Odrzucić je?';

  @override
  String get discardChangesAction => 'Odrzuć zmiany';

  @override
  String get deleteAction => 'Usuń';

  @override
  String get clearAction => 'Wyczyść';

  @override
  String get newProjectTitle => 'Nowy projekt';

  @override
  String get editProjectTitle => 'Edytuj projekt';

  @override
  String get projectBasicsSection => 'Podstawowe dane';

  @override
  String get projectScheduleSection => 'Plan i ustawienia';

  @override
  String get projectNameLabel => 'Nazwa projektu';

  @override
  String get projectLocationLabel => 'Adres lub etykieta';

  @override
  String get projectTypeLabel => 'Typ projektu';

  @override
  String get projectTemplateLabel => 'Szablon etapów';

  @override
  String get projectCurrencyLabel => 'Waluta';

  @override
  String get projectAreaLabel => 'Powierzchnia (m²)';

  @override
  String get projectBudgetLabel => 'Planowany budżet';

  @override
  String get projectPlannedStartLabel => 'Planowany start';

  @override
  String get projectPlannedEndLabel => 'Planowane zakończenie';

  @override
  String get projectDateFormatLabel => 'Format daty';

  @override
  String get projectDateFormatDmy => 'DD.MM.RRRR';

  @override
  String get projectDateFormatYmd => 'RRRR-MM-DD';

  @override
  String get projectCurrentStageLabel => 'Bieżący etap';

  @override
  String get projectCreateAction => 'Utwórz projekt';

  @override
  String get projectSaveChangesAction => 'Zapisz zmiany';

  @override
  String get projectNameRequiredError => 'Podaj nazwę projektu.';

  @override
  String get projectNameTooLongError =>
      'Nazwa może mieć maksymalnie 80 znaków.';

  @override
  String get projectLocationTooLongError =>
      'Adres lub etykieta może mieć maksymalnie 120 znaków.';

  @override
  String get projectAreaInvalidError => 'Wpisz dodatnią liczbę całkowitą.';

  @override
  String get projectBudgetInvalidError =>
      'Wpisz kwotę z maksymalnie dwiema cyframi po przecinku.';

  @override
  String get projectDatesInvalidError =>
      'Data zakończenia nie może być wcześniejsza niż data rozpoczęcia.';

  @override
  String get projectSaveError => 'Nie udało się zapisać projektu.';

  @override
  String get projectCurrencyLockedError =>
      'Nie można zmienić waluty po zapisaniu pierwszego kosztu.';

  @override
  String get projectNotFoundError => 'Nie znaleziono projektu.';

  @override
  String get projectTypeHouseBuild => 'Budowa domu';

  @override
  String get projectTypeHouseRenovation => 'Remont domu';

  @override
  String get projectTypeApartmentRenovation => 'Remont mieszkania';

  @override
  String get projectTemplateHouseConstruction => 'Budowa domu';

  @override
  String get projectTemplateRenovation => 'Remont';

  @override
  String get projectStagePlanning => 'Planowanie';

  @override
  String get projectStageFormalities => 'Formalności';

  @override
  String get projectStageStateZero => 'Stan zero';

  @override
  String get projectStageShellOpen => 'Stan surowy otwarty';

  @override
  String get projectStageShellClosed => 'Stan surowy zamknięty';

  @override
  String get projectStageDemolition => 'Rozbiórka';

  @override
  String get projectStageInstallations => 'Instalacje';

  @override
  String get projectStagePlaster => 'Tynki i wylewki';

  @override
  String get projectStageFinishing => 'Wykończenie';

  @override
  String get projectStageHandover => 'Odbiór';

  @override
  String get projectOverviewTitle => 'Projekt';

  @override
  String get projectOverviewEmptyTitle => 'Brak aktywnego projektu';

  @override
  String get projectOverviewEmptyMessage =>
      'Utwórz pierwszy projekt, aby rozpocząć pracę.';

  @override
  String get projectEditAction => 'Edytuj';

  @override
  String get projectLocationOverviewLabel => 'Lokalizacja';

  @override
  String get projectBudgetOverviewLabel => 'Budżet';

  @override
  String get projectDatesOverviewLabel => 'Terminy';

  @override
  String projectAreaValue(int area) {
    return '$area m²';
  }

  @override
  String projectDateRangeValue(String start, String end) {
    return '$start – $end';
  }

  @override
  String get projectValueNotProvided => 'Nie podano';

  @override
  String projectDeleteDialogTitle(String projectName) {
    return 'Usunąć projekt „$projectName”?';
  }

  @override
  String get projectDeleteWarning => 'Tej operacji nie można cofnąć.';

  @override
  String projectLinkedFilesCount(int count) {
    return 'Powiązane pliki: $count';
  }

  @override
  String projectLinkedRecordsCount(int count) {
    return 'Powiązane rekordy: $count';
  }

  @override
  String get projectDeletionImpactLoading => 'Sprawdzanie powiązań…';

  @override
  String get projectDeletionImpactError =>
      'Nie udało się sprawdzić skutków usunięcia.';

  @override
  String get projectDeleteError => 'Nie udało się usunąć projektu.';

  @override
  String get projectSelectorLabel => 'Projekt';

  @override
  String get projectSelectorChoose => 'Wybierz projekt';

  @override
  String get projectSelectorNewAction => 'Nowy projekt';

  @override
  String get projectSelectorError =>
      'Nie udało się wczytać selektora projektu.';

  @override
  String get projectSelectorSelectError => 'Nie udało się zmienić projektu.';

  @override
  String get costFormNewTitle => 'Nowy wpis';

  @override
  String get costFormEditTitle => 'Edytuj wpis';

  @override
  String get costDetailsTitle => 'Szczegóły wpisu';

  @override
  String get costBudgetAddTooltip => 'Dodaj wpis';

  @override
  String get costBudgetEmptyTitle => 'Brak wpisów';

  @override
  String get costBudgetEmptyMessage => 'Dodaj pierwszy koszt, ofertę lub plan.';

  @override
  String get costBudgetNoProjectTitle => 'Wybierz projekt';

  @override
  String get costBudgetNoProjectMessage => 'Koszty są przypisane do projektu.';

  @override
  String get costBudgetLoadError => 'Nie udało się wczytać kosztów.';

  @override
  String get costBudgetPlannedLabel => 'Plan';

  @override
  String get costBudgetActualLabel => 'Wydatki';

  @override
  String get costBudgetDifferenceLabel => 'Różnica';

  @override
  String get costRegisterSearchHint => 'Szukaj nazwy, dostawcy lub opisu';

  @override
  String get costRegisterFilterTooltip => 'Filtruj i sortuj';

  @override
  String costRegisterResultCount(int count) {
    return 'Wyniki: $count';
  }

  @override
  String get costRegisterNoResultsTitle => 'Brak pasujących wpisów';

  @override
  String get costRegisterNoResultsMessage =>
      'Zmień wyszukiwanie lub usuń część filtrów.';

  @override
  String get costRegisterClearFilters => 'Wyczyść filtry';

  @override
  String get costRegisterFilterTitle => 'Filtry kosztów';

  @override
  String get costRegisterApplyFilters => 'Pokaż wyniki';

  @override
  String get costRegisterResetFilters => 'Wyczyść';

  @override
  String get costRegisterTypeSection => 'Rodzaj wpisu';

  @override
  String get costRegisterStatusSection => 'Status';

  @override
  String get costRegisterContextSection => 'Etap i wykonawca';

  @override
  String get costRegisterPaymentSection => 'Płatność i źródło';

  @override
  String get costRegisterDateSection => 'Zakres dat';

  @override
  String get costRegisterQualitySection => 'Wymaga uzupełnienia';

  @override
  String get costRegisterSortSection => 'Sortowanie';

  @override
  String get costRegisterIncludeDrafts => 'Pokaż szkice';

  @override
  String get costRegisterAllOption => 'Wszystkie';

  @override
  String get costRegisterDateFrom => 'Od';

  @override
  String get costRegisterDateTo => 'Do';

  @override
  String get costRegisterLoadingMore => 'Wczytywanie kolejnych wpisów';

  @override
  String get costRegisterLoadMoreError =>
      'Nie udało się wczytać kolejnych wpisów.';

  @override
  String get costRegisterSortNewest => 'Najnowsze';

  @override
  String get costRegisterSortOldest => 'Najstarsze';

  @override
  String get costRegisterSortAmountDescending => 'Kwota: malejąco';

  @override
  String get costRegisterSortAmountAscending => 'Kwota: rosnąco';

  @override
  String get costRegisterSortName => 'Nazwa: A-Z';

  @override
  String get costCsvExportTooltip => 'Eksportuj CSV';

  @override
  String get costCsvExportTitle => 'Eksport kosztów do CSV';

  @override
  String costCsvExportScope(int count, int filterCount) {
    return 'Rekordy w zakresie: $count, aktywne filtry: $filterCount';
  }

  @override
  String get costCsvExportDestinationLabel => 'Miejsce docelowe';

  @override
  String get costCsvExportDestinationValue =>
      'Wybierzesz je w systemowym panelu po utworzeniu pliku.';

  @override
  String get costCsvExportColumnsHeading => 'Kolumny w pliku';

  @override
  String get costCsvExportAction => 'Utwórz i udostępnij';

  @override
  String costCsvExportSuccess(int count) {
    return 'Wyeksportowane rekordy: $count.';
  }

  @override
  String get costCsvExportError => 'Nie udało się utworzyć pliku CSV.';

  @override
  String get costCsvLifecycleColumn => 'Tryb wpisu';

  @override
  String get costCsvConfirmedValue => 'Zatwierdzony';

  @override
  String get costCsvEffectiveGrossColumn => 'Brutto po korektach';

  @override
  String get costCsvOriginalGrossColumn => 'Brutto pierwotne';

  @override
  String get costCsvCurrencyColumn => 'Waluta';

  @override
  String get costCsvSourceColumn => 'Źródło';

  @override
  String get costCsvAttachmentCountColumn => 'Liczba dokumentów';

  @override
  String get costCsvEmptyValue => 'Brak';

  @override
  String get costWarningMissingDocument => 'Brak dokumentu';

  @override
  String get costWarningMissingDescription => 'Brak opisu';

  @override
  String get costWarningVatToReview => 'Sprawdź VAT 0%';

  @override
  String get costSourceManual => 'Ręcznie';

  @override
  String get costSourceReceiptOcr => 'Paragon OCR';

  @override
  String get costSourceInvoiceOcr => 'Faktura OCR';

  @override
  String get costSourceImported => 'Import';

  @override
  String get costSourceOfferConversion => 'Z oferty';

  @override
  String get costFormBasicsSection => 'Wpis';

  @override
  String get costFormFinancialSection => 'Kwota';

  @override
  String get costFormDetailsSection => 'Szczegóły';

  @override
  String get costFormDocumentsSection => 'Dokumenty';

  @override
  String get costNameLabel => 'Nazwa';

  @override
  String get costTypeLabel => 'Rodzaj';

  @override
  String get costGrossAmountLabel => 'Kwota brutto';

  @override
  String get costVatRateLabel => 'VAT';

  @override
  String get costNetAmountLabel => 'Netto';

  @override
  String get costVatAmountLabel => 'Kwota VAT';

  @override
  String get costDateLabel => 'Data';

  @override
  String get costStageLabel => 'Etap';

  @override
  String get costCategoryLabel => 'Kategoria';

  @override
  String get costSupplierLabel => 'Dostawca';

  @override
  String get costQuantityLabel => 'Ilość';

  @override
  String get costUnitLabel => 'Jednostka';

  @override
  String get costStatusLabel => 'Status';

  @override
  String get costPaymentMethodLabel => 'Metoda płatności';

  @override
  String get costNoteLabel => 'Notatka';

  @override
  String get costTypeCost => 'Koszt';

  @override
  String get costTypeOffer => 'Oferta';

  @override
  String get costTypePlanned => 'Plan';

  @override
  String get costStatusPlanned => 'Planowany';

  @override
  String get costStatusOrdered => 'Zamówiony';

  @override
  String get costStatusDue => 'Do zapłaty';

  @override
  String get costStatusPaid => 'Opłacony';

  @override
  String get costStatusReturned => 'Zwrot';

  @override
  String get costStatusDisputed => 'Sporne';

  @override
  String get costPaymentCash => 'Gotówka';

  @override
  String get costPaymentCard => 'Karta';

  @override
  String get costPaymentBankTransfer => 'Przelew';

  @override
  String get costPaymentBlik => 'BLIK';

  @override
  String get costPaymentOther => 'Inna';

  @override
  String get costVatZero => '0%';

  @override
  String get costVatReduced => '8%';

  @override
  String get costVatStandard => '23%';

  @override
  String get costAddDocumentAction => 'Dodaj dokument';

  @override
  String get costNoDocumentsWarning => 'Brak dokumentu do wpisu.';

  @override
  String costDocumentCount(int count) {
    return 'Dokumenty: $count';
  }

  @override
  String get costSaveDraftAction => 'Zapisz szkic';

  @override
  String get costSaveAction => 'Zapisz koszt';

  @override
  String get costSaveChangesAction => 'Zapisz zmiany';

  @override
  String get costSaveError => 'Nie udało się zapisać wpisu.';

  @override
  String get costLoadError => 'Nie udało się wczytać wpisu.';

  @override
  String get costNotFoundError => 'Nie znaleziono wpisu.';

  @override
  String get costNameRequiredError => 'Podaj nazwę wpisu.';

  @override
  String get costNameTooLongError => 'Nazwa może mieć maksymalnie 120 znaków.';

  @override
  String get costAmountRequiredError => 'Podaj kwotę brutto.';

  @override
  String get costAmountInvalidError =>
      'Wpisz kwotę z maksymalnie dwiema cyframi po przecinku.';

  @override
  String get costAmountTooLargeError => 'Kwota jest za duża.';

  @override
  String get costQuantityUnitRequiredError => 'Podaj ilość i jednostkę.';

  @override
  String get costQuantityInvalidError => 'Wpisz dodatnią ilość.';

  @override
  String get costNoteTooLongError =>
      'Notatka może mieć maksymalnie 2000 znaków.';

  @override
  String get costStatusInvalidError =>
      'Ten status nie pasuje do rodzaju wpisu.';

  @override
  String get costFinancialFieldsLocked =>
      'Zatwierdzone dane finansowe są zablokowane.';

  @override
  String get costDetailsEditAction => 'Edytuj';

  @override
  String get costDetailsCopyDraftAction => 'Kopiuj do szkicu';

  @override
  String get costDetailsMarkPaidAction => 'Oznacz jako opłacony';

  @override
  String get costDetailsDeleteAction => 'Usuń pozycję';

  @override
  String get costDeleteTitle => 'Usunąć pozycję?';

  @override
  String get costDeleteMessage =>
      'Koszt, jego historia i nieużywane dokumenty zostaną trwale usunięte.';

  @override
  String get costDeleteError => 'Nie udało się usunąć szkicu.';

  @override
  String get costDetailsActionError => 'Nie udało się wykonać akcji.';

  @override
  String get costHistorySection => 'Historia';

  @override
  String get costHistoryEmpty => 'Brak historii.';

  @override
  String get costHistoryCreated => 'Utworzono wpis';

  @override
  String get costHistoryDraftSaved => 'Zapisano szkic';

  @override
  String get costHistoryDraftReplaced => 'Zaktualizowano szkic';

  @override
  String get costHistoryConfirmed => 'Zatwierdzono wpis';

  @override
  String get costHistoryDetailsUpdated => 'Zaktualizowano szczegóły';

  @override
  String get costHistoryStatusChanged => 'Zmieniono status';

  @override
  String get costHistoryCorrectionAdded => 'Dodano korektę';

  @override
  String get costDraftLabel => 'Szkic';

  @override
  String get costAttachmentsEmpty => 'Brak dokumentów.';

  @override
  String get costRemoveDocumentTooltip => 'Usuń dokument';

  @override
  String get costDatePickerTooltip => 'Wybierz datę';

  @override
  String get saveAction => 'Zapisz';

  @override
  String get stagePlanLoading => 'Wczytywanie etapów i checklisty';

  @override
  String get stagePlanLoadError => 'Nie udało się wczytać planu projektu.';

  @override
  String get stagePlanNoProjectTitle => 'Najpierw utwórz projekt';

  @override
  String get stagePlanNoProjectMessage =>
      'Etapy i checklisty zostaną dopasowane do budowy domu albo remontu.';

  @override
  String get stagePlanEyebrow => 'Etapy i checklisty';

  @override
  String get stageAddAction => 'Dodaj etap';

  @override
  String get stageReorderAction => 'Zmień kolejność etapów';

  @override
  String get stageEditAction => 'Edytuj etap';

  @override
  String get stageRenameAction => 'Zmień nazwę';

  @override
  String get stageNameLabel => 'Nazwa etapu';

  @override
  String get stageNameRequiredError => 'Podaj nazwę etapu.';

  @override
  String get stageAddTitle => 'Nowy etap';

  @override
  String get stageRenameTitle => 'Nazwa etapu';

  @override
  String get stageReorderTitle => 'Kolejność etapów';

  @override
  String get stageEditTitle => 'Plan etapu';

  @override
  String get stageStatusLabel => 'Status etapu';

  @override
  String get stageStatusPlanned => 'Planowany';

  @override
  String get stageStatusInProgress => 'W realizacji';

  @override
  String get stageStatusBlocked => 'Zablokowany';

  @override
  String get stageStatusCompleted => 'Zakończony';

  @override
  String get stageStartDateLabel => 'Planowany start';

  @override
  String get stageEndDateLabel => 'Planowany koniec';

  @override
  String get stageBudgetLabel => 'Budżet etapu';

  @override
  String get stageBudgetInvalidError =>
      'Wpisz poprawną kwotę z maksymalnie dwiema cyframi po przecinku.';

  @override
  String stageProgressLabel(int resolved, int total) {
    return '$resolved z $total';
  }

  @override
  String stageProgressPercent(int percent) {
    return 'Postęp $percent%';
  }

  @override
  String stageBlockedCount(int count) {
    return 'Zablokowane: $count';
  }

  @override
  String get stageNoChecklistTitle => 'Ten etap nie ma jeszcze checklisty';

  @override
  String get stageNoChecklistMessage =>
      'Dodaj własny punkt, termin i osobę odpowiedzialną.';

  @override
  String get stageMutationError => 'Nie udało się zapisać zmiany.';

  @override
  String get checklistHeading => 'Lista kontrolna';

  @override
  String get checklistAddAction => 'Dodaj punkt';

  @override
  String get checklistAddTitle => 'Nowy punkt checklisty';

  @override
  String get checklistEditTitle => 'Szczegóły punktu';

  @override
  String get checklistTitleLabel => 'Nazwa punktu';

  @override
  String get checklistTitleRequiredError => 'Podaj nazwę punktu.';

  @override
  String get checklistStatusLabel => 'Status';

  @override
  String get checklistStatusTodo => 'Do zrobienia';

  @override
  String get checklistStatusInProgress => 'W trakcie';

  @override
  String get checklistStatusBlocked => 'Zablokowane';

  @override
  String get checklistStatusCompleted => 'Zakończone';

  @override
  String get checklistStatusSkipped => 'Pominięte';

  @override
  String get checklistImportanceLabel => 'Ważność';

  @override
  String get checklistImportanceLow => 'Niska';

  @override
  String get checklistImportanceNormal => 'Normalna';

  @override
  String get checklistImportanceHigh => 'Wysoka';

  @override
  String get checklistImportanceCritical => 'Krytyczna';

  @override
  String get checklistDueDateLabel => 'Termin';

  @override
  String get checklistAssigneeLabel => 'Osoba odpowiedzialna';

  @override
  String get checklistNoteLabel => 'Notatka';

  @override
  String get checklistRiskLabel => 'Ryzyko pominięcia';

  @override
  String get checklistReasonLabel => 'Powód blokady lub pominięcia';

  @override
  String get checklistReasonRequiredError =>
      'Pominięcie punktu wymaga podania powodu.';

  @override
  String get checklistEvidenceLabel => 'Wymagany dowód';

  @override
  String get checklistEvidenceNone => 'Bez dowodu';

  @override
  String get checklistEvidenceAny => 'Dokument lub zdjęcie';

  @override
  String get checklistEvidencePhoto => 'Zdjęcie';

  @override
  String checklistEvidenceCount(int count) {
    return 'Dowody: $count';
  }

  @override
  String get checklistOpenEvidenceAction => 'Otwórz dokumenty dowodowe';

  @override
  String checklistEvidenceItemLabel(int number) {
    return 'Dowód $number';
  }

  @override
  String get checklistEvidenceWaived => 'Udokumentowane odstępstwo';

  @override
  String get checklistEvidenceRequiredTitle => 'Brakuje wymaganego dowodu';

  @override
  String get checklistEvidenceRequiredMessage =>
      'Dodaj lokalne zdjęcie lub dokument. Możesz też jawnie odstąpić od dowodu i zapisać uzasadnienie.';

  @override
  String get checklistAddEvidenceAction => 'Dodaj dowód';

  @override
  String get checklistWaiveEvidenceAction => 'Zapisz odstępstwo';

  @override
  String get checklistWaiverTitle => 'Odstępstwo od dowodu';

  @override
  String get checklistWaiverLabel => 'Uzasadnienie odstępstwa';

  @override
  String get checklistWaiverRequiredError =>
      'Wpisz konkretne uzasadnienie odstępstwa.';

  @override
  String get checklistEvidenceImportError =>
      'Nie udało się dodać dowodu. Sprawdź typ pliku i spróbuj ponownie.';

  @override
  String get checklistSoilResearch => 'Badania gruntu i warunki wodne';

  @override
  String get checklistSoilResearchRisk =>
      'Nieznane warunki gruntowe mogą wymusić zmianę posadowienia i zwiększyć koszt fundamentów.';

  @override
  String get checklistSurveyorBuildingSetout => 'Geodeta i wytyczenie budynku';

  @override
  String get checklistSurveyorBuildingSetoutRisk =>
      'Błąd położenia budynku może naruszyć odległości projektowe i granice działki.';

  @override
  String get checklistSiteRoadPowerWater => 'Droga, prąd i woda na budowę';

  @override
  String get checklistSiteRoadPowerWaterRisk =>
      'Brak mediów lub dojazdu zatrzyma ekipy i dostawy ciężkich materiałów.';

  @override
  String get checklistExcavationFoundationLevels =>
      'Poziomy wykopu, ław i posadowienia';

  @override
  String get checklistExcavationFoundationLevelsRisk =>
      'Błędna rzędna wpływa na wysokość budynku, spadki i odwodnienie działki.';

  @override
  String get checklistUnderSlabSewerAndRisers =>
      'Kanalizacja podposadzkowa i piony';

  @override
  String get checklistUnderSlabSewerAndRisersRisk =>
      'Brak lub zła lokalizacja podejść wymaga kucia posadzki i fundamentu.';

  @override
  String get checklistWaterPenetration => 'Przepust wody';

  @override
  String get checklistWaterPenetrationRisk =>
      'Późniejsze wykonanie przepustu może uszkodzić hydroizolację i konstrukcję.';

  @override
  String get checklistPowerPenetration => 'Przepust prądu';

  @override
  String get checklistPowerPenetrationRisk =>
      'Brak trasy zasilania oznacza wiercenie w gotowym fundamencie.';

  @override
  String get checklistTelecomPenetration => 'Przepust internetu i teletechniki';

  @override
  String get checklistTelecomPenetrationRisk =>
      'Bez rezerwy operator może poprowadzić kabel po elewacji lub przez część mieszkalną.';

  @override
  String get checklistGasPenetration => 'Przepust gazu, jeżeli dotyczy';

  @override
  String get checklistGasPenetrationRisk =>
      'Brak uzgodnionego przepustu utrudni wykonanie przyłącza zgodnie z projektem.';

  @override
  String get checklistGateIntercomGardenReserve =>
      'Rezerwa do bramy, domofonu i ogrodu';

  @override
  String get checklistGateIntercomGardenReserveRisk =>
      'Później potrzebne będą wykopy w gotowym podjeździe i ogrodzie.';

  @override
  String get checklistHeatPumpOutdoorReserve =>
      'Rezerwa do pompy ciepła i jednostek zewnętrznych';

  @override
  String get checklistHeatPumpOutdoorReserveRisk =>
      'Brak zasilania i tras instalacyjnych ograniczy miejsce urządzeń albo wymusi przeróbki.';

  @override
  String get checklistFoundationGrounding => 'Bednarka i uziom fundamentowy';

  @override
  String get checklistFoundationGroundingRisk =>
      'Po betonowaniu nie da się poprawić ciągłości i połączeń uziomu fundamentowego.';

  @override
  String get checklistContinuityMeasurement =>
      'Pomiar ciągłości przed betonowaniem';

  @override
  String get checklistContinuityMeasurementRisk =>
      'Niewykryta przerwa w uziomie pozostanie ukryta w konstrukcji.';

  @override
  String get checklistWaterproofing =>
      'Izolacje poziome, pionowe i hydroizolacje';

  @override
  String get checklistWaterproofingRisk =>
      'Nieszczelności mogą powodować trwałe zawilgocenie ścian i podłogi.';

  @override
  String get checklistDrainage =>
      'Odwodnienie i drenaż, jeżeli wynika z projektu';

  @override
  String get checklistDrainageRisk =>
      'Woda przy fundamencie zwiększa ryzyko przecieków i uszkodzeń izolacji.';

  @override
  String get checklistConcealedWorksPhotos =>
      'Zdjęcia zbrojenia, przepustów i uziomu przed zakryciem';

  @override
  String get checklistConcealedWorksPhotosRisk =>
      'Po zasypaniu nie będzie wiadomo, gdzie przebiegają instalacje i jak wykonano elementy ukryte.';

  @override
  String get checklistConcreteDeliveryAndAcceptance =>
      'Dokument WZ betonu i protokół odbioru';

  @override
  String get checklistConcreteDeliveryAndAcceptanceRisk =>
      'Bez dokumentów trudno potwierdzić klasę betonu, dostawę i odbiór robót.';

  @override
  String get checklistPostFoundationSurvey =>
      'Inwentaryzacja po wykonaniu fundamentów';

  @override
  String get checklistPostFoundationSurveyRisk =>
      'Odchyłki położenia mogą ujawnić się dopiero przy kolejnych etapach lub odbiorze.';

  @override
  String get scheduleWeekTab => '7 dni';

  @override
  String get scheduleStagesTab => 'Etapy';

  @override
  String get scheduleLoading => 'Wczytywanie planu na 7 dni';

  @override
  String get scheduleLoadError => 'Nie udało się wczytać terminów.';

  @override
  String get scheduleEyebrow => 'Terminy i blokady';

  @override
  String get schedulePreviousWeekTooltip => 'Poprzednie 7 dni';

  @override
  String get scheduleNextWeekTooltip => 'Następne 7 dni';

  @override
  String get scheduleReminderSettingsTooltip => 'Ustawienia przypomnień';

  @override
  String get scheduleAddEventTooltip => 'Dodaj termin';

  @override
  String scheduleItemsSummary(int count) {
    return 'Terminy: $count';
  }

  @override
  String scheduleBlockedSummary(int count) {
    return 'Blokowane: $count';
  }

  @override
  String get scheduleEmptyTitle => 'Brak terminów w tych 7 dniach';

  @override
  String get scheduleEmptyMessage =>
      'Dodaj zadanie, wizytę, dostawę, odbiór albo płatność.';

  @override
  String get scheduleTodayLabel => 'Dzisiaj';

  @override
  String get scheduleAllDayLabel => 'Cały dzień';

  @override
  String get scheduleKindLabel => 'Rodzaj';

  @override
  String get scheduleKindTask => 'Zadanie';

  @override
  String get scheduleKindVisit => 'Wizyta';

  @override
  String get scheduleKindDelivery => 'Dostawa';

  @override
  String get scheduleKindAcceptance => 'Odbiór';

  @override
  String get scheduleKindPayment => 'Płatność';

  @override
  String get scheduleStatusLabel => 'Status';

  @override
  String get scheduleStatusPlanned => 'Planowane';

  @override
  String get scheduleStatusInProgress => 'W trakcie';

  @override
  String get scheduleStatusBlocked => 'Zablokowane';

  @override
  String get scheduleStatusCompleted => 'Zakończone';

  @override
  String get scheduleStatusCancelled => 'Odwołane';

  @override
  String scheduleBlockedBy(String title) {
    return 'Blokuje: $title';
  }

  @override
  String scheduleDecisionDue(String date) {
    return 'Decyzja do $date';
  }

  @override
  String get schedulePermissionTitle => 'Przypomnienia są wyłączone';

  @override
  String get schedulePermissionMessage =>
      'Plan działa bez zgody. Włącz powiadomienia, aby dostawać lokalne przypomnienia.';

  @override
  String get schedulePermissionAction => 'Włącz';

  @override
  String get scheduleSettingsTitle => 'Przypomnienia';

  @override
  String get scheduleSettingsTypesHeading => 'Typy terminów';

  @override
  String get scheduleDefaultLeadLabel => 'Domyślne wyprzedzenie';

  @override
  String get scheduleAllDayTimeLabel => 'Godzina dla całego dnia';

  @override
  String get schedulePermissionGranted =>
      'Powiadomienia systemowe są włączone.';

  @override
  String get schedulePermissionDenied =>
      'Brak zgody systemowej. Plan nadal działa.';

  @override
  String get schedulePermissionUnavailable =>
      'Status powiadomień jest niedostępny.';

  @override
  String get scheduleLeadAtTime => 'O czasie';

  @override
  String scheduleLeadMinutes(int count) {
    return '$count min wcześniej';
  }

  @override
  String scheduleLeadHours(int count) {
    return '$count godz. wcześniej';
  }

  @override
  String scheduleLeadDays(int count) {
    return '$count dni wcześniej';
  }

  @override
  String get scheduleNewTitle => 'Nowy termin';

  @override
  String get scheduleEditTitle => 'Edytuj termin';

  @override
  String get scheduleTitleLabel => 'Nazwa';

  @override
  String get scheduleTitleRequiredError => 'Podaj nazwę terminu.';

  @override
  String get scheduleDateLabel => 'Data';

  @override
  String get scheduleTimeLabel => 'Godzina';

  @override
  String get scheduleStageLabel => 'Etap';

  @override
  String get scheduleNoStage => 'Bez etapu';

  @override
  String get scheduleAssigneeLabel => 'Osoba lub ekipa';

  @override
  String get scheduleNoteLabel => 'Notatka';

  @override
  String get scheduleReminderToggle => 'Przypomnienie lokalne';

  @override
  String get scheduleReminderLeadLabel => 'Przypomnij';

  @override
  String get scheduleRescheduleReasonLabel => 'Powód przełożenia';

  @override
  String get scheduleSaveError => 'Nie udało się zapisać terminu.';

  @override
  String get scheduleNotificationBody => 'Nadchodzi termin w planie budowy.';

  @override
  String get scheduleDetailsTitle => 'Szczegóły terminu';

  @override
  String get scheduleSourceMissingTitle => 'Nie znaleziono terminu';

  @override
  String get scheduleSourceMissingMessage =>
      'Rekord mógł zostać usunięty albo należy do innego projektu.';

  @override
  String get scheduleEditAction => 'Edytuj termin';

  @override
  String get scheduleDependenciesHeading => 'Blokady i zależności';

  @override
  String get scheduleDependenciesEmpty => 'Brak blokujących terminów.';

  @override
  String get scheduleDependenciesEditAction => 'Ustaw zależności';

  @override
  String get scheduleDependencySheetTitle => 'Co blokuje ten termin?';

  @override
  String get scheduleDependencyDeadlineTooltip => 'Ustaw termin decyzji';

  @override
  String get scheduleDependencyCycleError =>
      'Ta zależność utworzyłaby zamknięty cykl.';

  @override
  String get scheduleHistoryHeading => 'Historia terminów';

  @override
  String get scheduleHistoryEmpty => 'Termin nie był jeszcze przekładany.';

  @override
  String scheduleHistoryMoved(String from, String to) {
    return 'Z $from na $to';
  }

  @override
  String get scheduleReminderEnabled => 'Przypomnienie włączone';

  @override
  String get scheduleReminderDisabled => 'Przypomnienie wyłączone';

  @override
  String get scheduleMutationError => 'Nie udało się zapisać zmiany.';

  @override
  String get dashboardLoading => 'Ładowanie Startu…';

  @override
  String get dashboardLoadError =>
      'Nie udało się wczytać podsumowania projektu.';

  @override
  String get dashboardEmptyTitle => 'Projekt gotowy do uzupełnienia';

  @override
  String get dashboardEmptyMessage =>
      'Dodaj pierwszy koszt, termin albo rozpocznij checklistę etapu.';

  @override
  String get dashboardStartWithCost => 'Dodaj pierwszy koszt';

  @override
  String get dashboardCurrentStage => 'Aktualny etap';

  @override
  String get dashboardBudgetTitle => 'Budżet projektu';

  @override
  String dashboardSpentOfBudget(String spent, String budget) {
    return '$spent z $budget';
  }

  @override
  String get dashboardRemaining => 'Pozostało';

  @override
  String get dashboardOverBudget => 'Przekroczenie';

  @override
  String get dashboardBudgetNotSet => 'Uzupełnij budżet projektu';

  @override
  String get dashboardSpent => 'Wydano';

  @override
  String get dashboardPlan30 => 'Plan 30 dni';

  @override
  String get dashboardUnpaid => 'Nieopłacone';

  @override
  String dashboardUnpaidItems(int count) {
    return '$count pozycji';
  }

  @override
  String get dashboardQuickActions => 'Szybkie akcje';

  @override
  String get dashboardAddCost => 'Dodaj koszt';

  @override
  String get dashboardOpenBudget => 'Otwórz budżet';

  @override
  String get dashboardOpenChecklists => 'Checklisty etapów';

  @override
  String get dashboardAddSchedule => 'Dodaj termin';

  @override
  String get dashboardCritical => 'Krytyczne zadania';

  @override
  String dashboardCriticalCount(int count) {
    return 'Otwarte: $count';
  }

  @override
  String get dashboardCriticalEmpty => 'Brak otwartych zadań wysokiego ryzyka.';

  @override
  String get dashboardStages => 'Oś etapów';

  @override
  String get dashboardAgenda => 'Dzisiaj na budowie';

  @override
  String dashboardAgendaCount(int count) {
    return 'Wpisy: $count';
  }

  @override
  String get dashboardAgendaEmpty =>
      'Brak zadań, wizyt, dostaw i odbiorów na dziś.';

  @override
  String get dashboardUpcomingVisits => 'Najbliższe wizyty';

  @override
  String dashboardUpcomingVisitsCount(int count) {
    return 'Wizyty: $count';
  }

  @override
  String get dashboardUpcomingVisitsEmpty =>
      'Brak wizyt zaplanowanych na najbliższe 30 dni.';

  @override
  String get dashboardProjectActionsTooltip => 'Zarządzaj projektem';

  @override
  String dashboardStageProgress(int percent) {
    return 'Postęp checklisty: $percent%';
  }

  @override
  String get contactsTitle => 'Ekipy i kontakty';

  @override
  String get contactsAddTooltip => 'Dodaj kontakt';

  @override
  String get contactsSearchHint => 'Szukaj osoby, firmy, telefonu lub e-maila';

  @override
  String get contactsRoleFilterLabel => 'Rola';

  @override
  String get contactsStageFilterLabel => 'Etap';

  @override
  String get contactsAllRoles => 'Wszystkie role';

  @override
  String get contactsAllStages => 'Wszystkie etapy';

  @override
  String contactsResultCount(int count) {
    return 'Kontakty: $count';
  }

  @override
  String get contactsNoProjectTitle => 'Wybierz projekt';

  @override
  String get contactsNoProjectMessage =>
      'Kontakty i wizyty są przypisane do projektu.';

  @override
  String get contactsEmptyTitle => 'Brak kontaktów';

  @override
  String get contactsEmptyMessage =>
      'Dodaj pierwszą ekipę, wykonawcę lub dostawcę.';

  @override
  String get contactsNoResultsTitle => 'Brak pasujących kontaktów';

  @override
  String get contactsNoResultsMessage =>
      'Zmień wyszukiwanie albo filtry roli i etapu.';

  @override
  String get contactsLoadError => 'Nie udało się wczytać kontaktów.';

  @override
  String get contactNewTitle => 'Nowy kontakt';

  @override
  String get contactEditTitle => 'Edytuj kontakt';

  @override
  String get contactDetailsTitle => 'Szczegóły kontaktu';

  @override
  String get contactNameLabel => 'Osoba lub firma';

  @override
  String get contactKindLabel => 'Rodzaj kontaktu';

  @override
  String get contactKindPerson => 'Osoba';

  @override
  String get contactKindCompany => 'Firma';

  @override
  String get contactRolesHeading => 'Role i branże';

  @override
  String get contactStagesHeading => 'Przypisane etapy';

  @override
  String get contactNoStagesAvailable => 'Projekt nie ma jeszcze etapów.';

  @override
  String get contactPhoneLabel => 'Telefon';

  @override
  String get contactEmailLabel => 'E-mail';

  @override
  String get contactTaxIdLabel => 'NIP';

  @override
  String get contactNoteLabel => 'Notatka';

  @override
  String get contactRatingLabel => 'Ocena';

  @override
  String get contactNoRating => 'Bez oceny';

  @override
  String get contactSaveError => 'Nie udało się zapisać kontaktu.';

  @override
  String get contactNameRequiredError => 'Podaj osobę albo nazwę firmy.';

  @override
  String get contactRoleRequiredError => 'Wybierz co najmniej jedną rolę.';

  @override
  String get contactEmailInvalidError => 'Wpisz poprawny adres e-mail.';

  @override
  String get contactLoadError => 'Nie udało się wczytać kontaktu.';

  @override
  String get contactNotFoundTitle => 'Nie znaleziono kontaktu';

  @override
  String get contactNotFoundMessage =>
      'Kontakt mógł zostać usunięty lub należy do innego projektu.';

  @override
  String get contactCallTooltip => 'Zadzwoń';

  @override
  String get contactEmailTooltip => 'Napisz e-mail';

  @override
  String get contactEditTooltip => 'Edytuj kontakt';

  @override
  String get contactCallConfirmTitle => 'Zadzwonić do kontaktu?';

  @override
  String contactCallConfirmMessage(String phone) {
    return 'Telefon otworzy systemową aplikację połączeń dla numeru $phone.';
  }

  @override
  String get contactCallAction => 'Otwórz telefon';

  @override
  String get contactEmailConfirmTitle => 'Napisać do kontaktu?';

  @override
  String contactEmailConfirmMessage(String email) {
    return 'E-mail otworzy systemową aplikację pocztową dla adresu $email.';
  }

  @override
  String get contactEmailAction => 'Otwórz pocztę';

  @override
  String get contactActionError =>
      'Na tym urządzeniu nie znaleziono odpowiedniej aplikacji.';

  @override
  String get contactArchiveAction => 'Archiwizuj';

  @override
  String get contactRestoreAction => 'Przywróć';

  @override
  String get contactArchiveError => 'Nie udało się zmienić stanu kontaktu.';

  @override
  String get contactDeleteConfirmTitle => 'Usunąć kontakt?';

  @override
  String get contactDeleteConfirmMessage =>
      'Kontakt bez historii wizyt i ofert zostanie trwale usunięty.';

  @override
  String get contactDeleteInUseError =>
      'Kontakt ma historię wizyt lub ofert. Zamiast usuwać, zarchiwizuj go.';

  @override
  String get contactDeleteError => 'Nie udało się usunąć kontaktu.';

  @override
  String get contactAboutHeading => 'Dane kontaktowe';

  @override
  String get contactVisitHeading => 'Wizyty na budowie';

  @override
  String get contactAddVisitAction => 'Zaplanuj wizytę';

  @override
  String get contactUpcomingVisits => 'Nadchodzące';

  @override
  String get contactVisitHistory => 'Historia';

  @override
  String get contactUpcomingEmpty => 'Brak zaplanowanych wizyt.';

  @override
  String get contactVisitHistoryEmpty =>
      'Brak zakończonych i odwołanych wizyt.';

  @override
  String get contactRoleGeneralContractor => 'Generalny wykonawca';

  @override
  String get contactRoleSiteManager => 'Kierownik budowy';

  @override
  String get contactRoleArchitect => 'Architekt';

  @override
  String get contactRoleElectrician => 'Elektryk';

  @override
  String get contactRolePlumber => 'Hydraulik';

  @override
  String get contactRoleHeatingVentilation => 'Ogrzewanie i wentylacja';

  @override
  String get contactRoleSurveyor => 'Geodeta';

  @override
  String get contactRoleRoofer => 'Dekarz';

  @override
  String get contactRoleCarpenter => 'Cieśla / stolarz';

  @override
  String get contactRolePlasterer => 'Tynkarz';

  @override
  String get contactRoleTiler => 'Glazurnik';

  @override
  String get contactRolePainter => 'Malarz';

  @override
  String get contactRoleSupplier => 'Dostawca';

  @override
  String get contactRoleInspector => 'Inspektor';

  @override
  String get contactRoleOther => 'Inna rola';

  @override
  String get siteVisitNewTitle => 'Nowa wizyta';

  @override
  String get siteVisitEditTitle => 'Edytuj wizytę';

  @override
  String get siteVisitPurposeLabel => 'Cel wizyty';

  @override
  String get siteVisitExpectedResultLabel => 'Oczekiwany rezultat';

  @override
  String get siteVisitStatusLabel => 'Status wizyty';

  @override
  String get siteVisitStatusPlanned => 'Planowana';

  @override
  String get siteVisitStatusCompleted => 'Wykonana';

  @override
  String get siteVisitStatusCancelled => 'Odwołana';

  @override
  String get siteVisitStatusNoShow => 'Wykonawca nie przyjechał';

  @override
  String get siteVisitDateLabel => 'Data';

  @override
  String get siteVisitTimeLabel => 'Godzina';

  @override
  String get siteVisitAllDayLabel => 'Cały dzień';

  @override
  String get siteVisitStageLabel => 'Etap';

  @override
  String get siteVisitNoStage => 'Bez etapu';

  @override
  String get siteVisitReminderToggle => 'Przypomnienie';

  @override
  String get siteVisitReminderLeadLabel => 'Wyprzedzenie';

  @override
  String get siteVisitResultLabel => 'Rezultat i notatka po wizycie';

  @override
  String get siteVisitAgreementsLabel => 'Ustalenia';

  @override
  String get siteVisitRescheduleReasonLabel => 'Powód zmiany terminu';

  @override
  String get siteVisitPurposeRequiredError => 'Podaj cel wizyty.';

  @override
  String get siteVisitExpectedResultRequiredError =>
      'Podaj oczekiwany rezultat.';

  @override
  String get siteVisitResultRequiredError =>
      'Zapisz rezultat wykonanej wizyty.';

  @override
  String get siteVisitSaveError => 'Nie udało się zapisać wizyty.';

  @override
  String get siteVisitLoadError => 'Nie udało się wczytać wizyty.';

  @override
  String get siteVisitNotificationBody =>
      'Nadchodzi wizyta zaplanowana na budowie.';

  @override
  String get siteVisitResultHeading => 'Wynik wizyty';

  @override
  String get siteVisitAgreementsHeading => 'Ustalenia';

  @override
  String get quotesTitle => 'Oferty wykonawców';

  @override
  String get quotesSearchLabel => 'Szukaj oferty lub wykonawcy';

  @override
  String get quotesStatusAll => 'Wszystkie statusy';

  @override
  String get quoteStatusReceived => 'Otrzymana';

  @override
  String get quoteStatusAccepted => 'Przyjęta';

  @override
  String get quoteStatusRejected => 'Odrzucona';

  @override
  String get quoteStatusExpired => 'Po terminie';

  @override
  String quotesCompareAction(int count) {
    return 'Porównaj ($count)';
  }

  @override
  String get quotesCompareLimit => 'Możesz porównać maksymalnie 4 oferty.';

  @override
  String quotesResultCount(int count) {
    return 'Oferty: $count';
  }

  @override
  String get quotesNoProjectTitle => 'Wybierz projekt';

  @override
  String get quotesNoProjectMessage => 'Oferty są przypisane do projektu.';

  @override
  String get quotesEmptyTitle => 'Brak ofert';

  @override
  String get quotesEmptyMessage =>
      'Dodaj pierwszą ofertę wykonawcy z ceną i zakresem.';

  @override
  String get quotesNoResultsTitle => 'Brak pasujących ofert';

  @override
  String get quotesNoResultsMessage => 'Zmień wyszukiwanie albo filtr statusu.';

  @override
  String get quotesLoadError => 'Nie udało się wczytać ofert.';

  @override
  String get quoteNewTitle => 'Nowa oferta';

  @override
  String get quoteEditTitle => 'Edytuj ofertę';

  @override
  String get quoteDetailsTitle => 'Szczegóły oferty';

  @override
  String get quoteContractorLabel => 'Wykonawca';

  @override
  String get quoteTitleLabel => 'Zakres główny';

  @override
  String get quoteVariantLabel => 'Wariant';

  @override
  String get quoteGrossAmountLabel => 'Kwota brutto';

  @override
  String get quoteVatRateLabel => 'Stawka VAT';

  @override
  String get quoteReceivedDateLabel => 'Data otrzymania';

  @override
  String get quoteValidUntilLabel => 'Ważna do';

  @override
  String get quoteStageLabel => 'Etap';

  @override
  String get quoteNoStage => 'Bez etapu';

  @override
  String get quoteIncludedScopeHeading => 'W cenie';

  @override
  String get quoteExcludedScopeHeading => 'Wykluczenia';

  @override
  String get quoteScopeLineLabel => 'Pozycja zakresu';

  @override
  String get quoteAddScopeLineTooltip => 'Dodaj pozycję';

  @override
  String get quoteRemoveScopeLineTooltip => 'Usuń pozycję';

  @override
  String get quoteAttachmentsHeading => 'Załączniki';

  @override
  String get quoteAddAttachmentAction => 'Dodaj PDF lub zdjęcie';

  @override
  String get quoteNoteLabel => 'Notatka';

  @override
  String get quoteRequiredFieldsError =>
      'Uzupełnij wykonawcę, nazwę, wariant, kwotę i zakres.';

  @override
  String get quoteInvalidAmountError => 'Wpisz poprawną kwotę większą od zera.';

  @override
  String get quoteInvalidValidityError =>
      'Termin ważności nie może być przed datą otrzymania.';

  @override
  String get quoteSaveError => 'Nie udało się zapisać oferty.';

  @override
  String get quoteLoadError => 'Nie udało się wczytać oferty.';

  @override
  String get quoteNotFoundTitle => 'Nie znaleziono oferty';

  @override
  String get quoteNotFoundMessage =>
      'Oferta mogła zostać usunięta lub należy do innego projektu.';

  @override
  String get quoteAttachmentError => 'Nie udało się zaimportować załącznika.';

  @override
  String quoteValidUntilValue(String date) {
    return 'Ważna do $date';
  }

  @override
  String quoteExpiredOnValue(String date) {
    return 'Termin minął $date';
  }

  @override
  String get quoteAcceptAction => 'Przyjmij ofertę';

  @override
  String get quoteRejectAction => 'Odrzuć ofertę';

  @override
  String get quoteAcceptTitle => 'Dodać ofertę do budżetu?';

  @override
  String get quoteAcceptPlannedAction => 'Jako planowany koszt';

  @override
  String get quoteAcceptOrderedAction => 'Jako zamówiony koszt';

  @override
  String get quoteAcceptError => 'Nie udało się przyjąć oferty.';

  @override
  String get quoteRejectConfirmTitle => 'Odrzucić ofertę?';

  @override
  String get quoteRejectConfirmMessage =>
      'Oferta pozostanie w historii ze statusem odrzuconej.';

  @override
  String get quoteRejectError => 'Nie udało się odrzucić oferty.';

  @override
  String get quoteDeleteConfirmTitle => 'Usunąć ofertę?';

  @override
  String get quoteDeleteConfirmMessage =>
      'Nieprzyjęta oferta i jej powiązania zostaną usunięte.';

  @override
  String get quoteDeleteError => 'Nie udało się usunąć oferty.';

  @override
  String get quoteViewCostAction => 'Otwórz koszt w budżecie';

  @override
  String get quoteAcceptedCostHeading => 'Koszt w budżecie';

  @override
  String get quoteComparisonTitle => 'Porównanie ofert';

  @override
  String get quoteComparisonPriceHeading => 'Cena brutto';

  @override
  String get quoteComparisonScopeHeading => 'Różnice zakresu';

  @override
  String get quoteLowestPriceLabel => 'Najniższa cena';

  @override
  String get quotePresenceIncluded => 'W cenie';

  @override
  String get quotePresenceExcluded => 'Wykluczone';

  @override
  String get quotePresenceNotSpecified => 'Brak informacji';

  @override
  String get quoteComparisonNeedsTwo => 'Wybierz co najmniej 2 oferty.';

  @override
  String get contactQuotesHeading => 'Oferty';

  @override
  String get contactAddQuoteAction => 'Dodaj ofertę';

  @override
  String get contactQuotesEmpty => 'Brak ofert tego wykonawcy.';

  @override
  String get documentsTitle => 'Dokumenty';

  @override
  String get documentsSearchLabel => 'Szukaj nazwy lub opisu';

  @override
  String get documentsFiltersAction => 'Filtry';

  @override
  String documentsFiltersCount(int count) {
    return 'Filtry ($count)';
  }

  @override
  String get documentsFilterTitle => 'Filtruj dokumenty';

  @override
  String get documentsFilterTypeAll => 'Wszystkie typy';

  @override
  String get documentsFilterStageAll => 'Wszystkie etapy';

  @override
  String get documentsFilterRoomAll => 'Wszystkie pomieszczenia';

  @override
  String get documentsFilterWarrantyAll => 'Każdy stan gwarancji';

  @override
  String get documentsFilterFromDate => 'Od daty';

  @override
  String get documentsFilterToDate => 'Do daty';

  @override
  String get documentsApplyFiltersAction => 'Pokaż wyniki';

  @override
  String documentsResultCount(int count) {
    return 'Dokumenty: $count';
  }

  @override
  String get documentsLoadMoreAction => 'Wczytaj kolejne';

  @override
  String get documentsNoProjectTitle => 'Wybierz projekt';

  @override
  String get documentsNoProjectMessage =>
      'Dokumenty są przechowywane osobno dla każdego projektu.';

  @override
  String get documentsEmptyTitle => 'Brak dokumentów';

  @override
  String get documentsEmptyMessage =>
      'Dodaj fakturę, umowę, gwarancję, instrukcję albo zdjęcie.';

  @override
  String get documentsNoResultsTitle => 'Brak pasujących dokumentów';

  @override
  String get documentsNoResultsMessage =>
      'Zmień wyszukiwanie albo aktywne filtry.';

  @override
  String get documentsLoadError => 'Nie udało się wczytać dokumentów.';

  @override
  String get documentImportAction => 'Dodaj dokument';

  @override
  String get documentImportError => 'Nie udało się zaimportować dokumentu.';

  @override
  String get documentDuplicateTitle => 'Ten plik może już być zapisany';

  @override
  String documentDuplicateMessage(int count) {
    return 'Znaleziono $count dokumentów z identyczną zawartością. Możesz mimo to zachować osobną pozycję.';
  }

  @override
  String get documentDuplicateContinueAction => 'Zachowaj mimo to';

  @override
  String get documentNewTitle => 'Nowy dokument';

  @override
  String get documentEditTitle => 'Edytuj dokument';

  @override
  String get documentDetailsTitle => 'Szczegóły dokumentu';

  @override
  String get documentViewerTitle => 'Podgląd dokumentu';

  @override
  String get documentTitleLabel => 'Nazwa dokumentu';

  @override
  String get documentTypeLabel => 'Typ dokumentu';

  @override
  String get documentDescriptionLabel => 'Opis';

  @override
  String get documentDateLabel => 'Data dokumentu';

  @override
  String get documentStageLabel => 'Etap';

  @override
  String get documentNoStage => 'Bez etapu';

  @override
  String get documentRoomLabel => 'Pomieszczenie lub strefa';

  @override
  String get documentContactLabel => 'Kontakt';

  @override
  String get documentNoContact => 'Bez kontaktu';

  @override
  String get documentWarrantySection => 'Gwarancja i termin';

  @override
  String get documentWarrantyEnabledLabel => 'Dokument zawiera gwarancję';

  @override
  String get documentWarrantyStartLabel => 'Początek gwarancji';

  @override
  String get documentWarrantyEndLabel => 'Koniec gwarancji';

  @override
  String get documentWarrantyReminderLabel => 'Przypomnienie';

  @override
  String get documentWarrantyReminderHint =>
      'Data pojawi się w informacjach o terminie gwarancji.';

  @override
  String get documentRequiredFieldsError => 'Podaj nazwę i typ dokumentu.';

  @override
  String get documentWarrantyDatesError =>
      'Podaj prawidłowy początek i koniec gwarancji.';

  @override
  String get documentSaveError => 'Nie udało się zapisać dokumentu.';

  @override
  String get documentLoadError => 'Nie udało się wczytać dokumentu.';

  @override
  String get documentNotFoundTitle => 'Nie znaleziono dokumentu';

  @override
  String get documentNotFoundMessage =>
      'Dokument mógł zostać usunięty albo należy do innego projektu.';

  @override
  String get documentOpenAction => 'Otwórz';

  @override
  String get documentShareAction => 'Udostępnij';

  @override
  String get documentShareError => 'Nie udało się udostępnić pliku.';

  @override
  String get documentDeleteTitle => 'Usunąć dokument?';

  @override
  String documentDeleteMessage(int count) {
    return 'Plik oraz $count powiązanych rekordów zostaną odłączone. Tej operacji nie można cofnąć.';
  }

  @override
  String get documentDeleteError => 'Nie udało się usunąć dokumentu.';

  @override
  String get documentRelationsHeading => 'Powiązania';

  @override
  String get documentRelationsEmpty => 'Brak powiązanych rekordów.';

  @override
  String get documentFileHeading => 'Plik źródłowy';

  @override
  String get documentFileNameLabel => 'Nazwa pliku';

  @override
  String get documentFileSizeLabel => 'Rozmiar';

  @override
  String get documentImportedAtLabel => 'Zaimportowano';

  @override
  String get documentOriginalPreservedLabel => 'Oryginał zachowany bez zmian';

  @override
  String get documentPreviewUnavailable =>
      'Podgląd tego formatu nie jest dostępny w aplikacji.';

  @override
  String get documentPreviewUnavailableMessage =>
      'Oryginał pozostaje zapisany i możesz go udostępnić z ekranu szczegółów.';

  @override
  String get documentTypeReceipt => 'Paragon';

  @override
  String get documentTypeInvoice => 'Faktura';

  @override
  String get documentTypeQuote => 'Oferta';

  @override
  String get documentTypeContract => 'Umowa';

  @override
  String get documentTypeDeliveryNote => 'WZ';

  @override
  String get documentTypeProtocol => 'Protokół';

  @override
  String get documentTypeWarranty => 'Gwarancja';

  @override
  String get documentTypeInstruction => 'Instrukcja';

  @override
  String get documentTypeMap => 'Mapa lub rzut';

  @override
  String get documentTypePhoto => 'Zdjęcie';

  @override
  String get documentTypeOther => 'Inny dokument';

  @override
  String get documentWarrantyWithout => 'Bez gwarancji';

  @override
  String get documentWarrantyActive => 'Aktywna';

  @override
  String get documentWarrantyExpiring => 'Wygasa w ciągu 30 dni';

  @override
  String get documentWarrantyExpired => 'Wygasła';

  @override
  String documentWarrantyUntilValue(String date) {
    return 'Gwarancja do $date';
  }

  @override
  String get documentRelationCost => 'Koszt';

  @override
  String get documentRelationStage => 'Etap';

  @override
  String get documentRelationChecklist => 'Checklista';

  @override
  String get documentRelationContact => 'Kontakt';

  @override
  String get documentRelationRoom => 'Pomieszczenie';

  @override
  String get documentRelationQuote => 'Oferta';

  @override
  String get documentRelationDecision => 'Decyzja';

  @override
  String get documentRelationDefect => 'Usterka';

  @override
  String get documentRelationDevice => 'Urządzenie';

  @override
  String get budgetReportTitle => 'Raport budżetowy';

  @override
  String get budgetReportLoading => 'Wczytywanie raportu...';

  @override
  String get budgetReportNoProjectTitle => 'Wybierz projekt';

  @override
  String get budgetReportNoProjectMessage =>
      'Raport budżetowy jest liczony osobno dla każdego projektu.';

  @override
  String get budgetReportLoadError =>
      'Nie udało się wczytać raportu budżetowego.';

  @override
  String get budgetReportRemainingHeading => 'Pozostało do rozdysponowania';

  @override
  String get budgetReportOverBudgetHeading => 'Przekroczenie budżetu';

  @override
  String get budgetReportNoPlan => 'Nie ustawiono';

  @override
  String get budgetReportPlanLabel => 'Plan';

  @override
  String get budgetReportCommittedLabel => 'Zobowiązania';

  @override
  String get budgetReportPaidLabel => 'Zapłacono';

  @override
  String get budgetReportRemainingLabel => 'Pozostało';

  @override
  String get budgetReportBreakdownHeading => 'Struktura kosztów';

  @override
  String get budgetReportDimensionStage => 'Etap';

  @override
  String get budgetReportDimensionCategory => 'Kategoria';

  @override
  String get budgetReportDimensionSupplier => 'Wykonawca';

  @override
  String get budgetReportDimensionMonth => 'Miesiąc';

  @override
  String get budgetReportNoAssignment => 'Bez przypisania';

  @override
  String budgetReportPaidDetail(String amount) {
    return 'Zapłacono $amount';
  }

  @override
  String budgetReportRecordCount(int count) {
    return 'Pozycji: $count';
  }

  @override
  String get budgetReportEmptyCostsTitle => 'Brak kosztów do raportu';

  @override
  String get budgetReportEmptyCostsMessage =>
      'Dodaj zatwierdzony koszt, aby zobaczyć strukturę wydatków.';

  @override
  String get backupTitle => 'Kopia zapasowa i dane';

  @override
  String get backupScopeHeading => 'Wszystkie dane w jednym pliku';

  @override
  String get backupScopeDescription =>
      'Kopia obejmuje projekty, koszty, etapy, harmonogram, kontakty, dokumenty, zdjęcia i pozostałe pliki.';

  @override
  String get backupLocalOnlyDescription =>
      'Dane pozostają lokalne. Po utworzeniu kopii wybierzesz miejsce zapisu w systemowym panelu telefonu.';

  @override
  String get backupCreateHeading => 'Utwórz kopię';

  @override
  String get backupCreateDescription =>
      'Zapisz aktualny stan aplikacji przed ważną zmianą, remontem urządzenia lub odtworzeniem starszej kopii.';

  @override
  String get backupCreateAction => 'Utwórz i zapisz kopię';

  @override
  String get backupCreating => 'Tworzenie i sprawdzanie kopii…';

  @override
  String get backupCreateSuccess => 'Kopia została utworzona.';

  @override
  String get backupCreateError =>
      'Nie udało się utworzyć kopii. Dane w aplikacji nie zostały zmienione.';

  @override
  String get backupRestoreHeading => 'Odtwórz dane';

  @override
  String get backupRestoreDescription =>
      'Najpierw sprawdzimy format, sumy kontrolne, bazę danych i wymagane miejsce. Aktualne dane zostaną zastąpione dopiero po potwierdzeniu.';

  @override
  String get backupPickAction => 'Wybierz plik ZIP';

  @override
  String get backupInspecting => 'Sprawdzanie wybranej kopii…';

  @override
  String get backupInspectError =>
      'Nie można użyć tego pliku. Kopia jest uszkodzona, nieobsługiwana albo nie pochodzi z BudowaPRO.';

  @override
  String get backupCandidateHeading => 'Wybrana kopia';

  @override
  String get backupCreatedLabel => 'Utworzono';

  @override
  String get backupSchemaLabel => 'Wersja danych';

  @override
  String get backupProjectsLabel => 'Projekty';

  @override
  String get backupFilesLabel => 'Pliki';

  @override
  String get backupSizeLabel => 'Rozmiar danych';

  @override
  String get backupRestoreAction => 'Odtwórz tę kopię';

  @override
  String get backupRestoreConfirmTitle => 'Zastąpić wszystkie dane?';

  @override
  String get backupRestoreConfirmMessage =>
      'Aktualne projekty, koszty, dokumenty i zdjęcia zostaną zastąpione zawartością wybranej kopii. Tej operacji nie można cofnąć bez innej kopii zapasowej.';

  @override
  String get backupRestoreConfirmAction => 'Zastąp dane';

  @override
  String get backupRestoring => 'Odtwarzanie i końcowe sprawdzanie danych…';

  @override
  String get backupRestoreSuccess => 'Dane zostały bezpiecznie odtworzone.';

  @override
  String get backupRestoreError =>
      'Nie udało się odtworzyć kopii. Poprzednie dane zostały zachowane.';

  @override
  String backupBytesValue(String value) {
    return '$value B';
  }

  @override
  String backupKilobytesValue(String value) {
    return '$value KB';
  }

  @override
  String backupMegabytesValue(String value) {
    return '$value MB';
  }

  @override
  String backupGigabytesValue(String value) {
    return '$value GB';
  }
}
