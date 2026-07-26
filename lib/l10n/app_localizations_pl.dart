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
  String get projectStageSitePreparation => 'Przygotowanie placu';

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
  String get stageGuidanceHeading => 'Wskazówki dla tego etapu';

  @override
  String stageGuidanceCount(int count) {
    return 'Porady: $count';
  }

  @override
  String get stageGuidanceAddOwnAction => 'Dodaj własną pozycję';

  @override
  String get stageGuidanceDisclaimerTitle => 'To nie jest projekt wykonawczy';

  @override
  String get stageGuidanceDisclaimerMessage =>
      'To ogólna lista kontrolna do rozmowy z projektantem, kierownikiem budowy, wykonawcą branżowym lub właściwym urzędem. Aktualne wymogi, wymiary, materiały i układ zawsze potwierdź dla swojej działki i dokumentacji.';

  @override
  String get stageGuidanceCheckHeading => 'Sprawdź przed pracą';

  @override
  String get stageGuidanceQuestionsHeading => 'Pytania do fachowca';

  @override
  String get stageGuidanceSourcesHeading => 'Źródła i podstawa';

  @override
  String stageGuidanceVersion(int version, String date) {
    return 'Wersja treści $version • sprawdzono $date';
  }

  @override
  String get stageGuidanceCloseAction => 'Zamknij wskazówkę';

  @override
  String get stageGuidanceEmpty =>
      'Brak gotowych wskazówek dla tego etapu. Możesz dodać własną pozycję do checklisty.';

  @override
  String get stageGuidanceRelatedChecklistHeading =>
      'Powiązane punkty checklisty';

  @override
  String get stageGuidanceSourceRegulation => 'Przepis';

  @override
  String get stageGuidanceSourceStandard => 'Norma';

  @override
  String get stageGuidanceSourceOfficialGuidance => 'Wytyczne techniczne';

  @override
  String get stageGuidanceSourceSystemDocumentation => 'Dokumentacja systemowa';

  @override
  String stageGuidanceSourceRevision(String revision) {
    return 'Wydanie: $revision';
  }

  @override
  String stageGuidanceSourceVerifiedOn(String date) {
    return 'Sprawdzono: $date';
  }

  @override
  String get stageGuidanceSourceTechnicalConditions =>
      'Warunki techniczne budynków i wykaz zmian MRiT';

  @override
  String get stageGuidanceSourceTechnicalConditionsEarthing =>
      'Warunki techniczne § 184 - uziomy instalacji elektrycznej';

  @override
  String get stageGuidanceSourceLowVoltageEarthing =>
      'PN-HD 60364-5-54 - uziemienia i przewody ochronne';

  @override
  String get stageGuidanceSourceElectricalVerification =>
      'PN-HD 60364-6 - sprawdzanie instalacji elektrycznych';

  @override
  String get stageGuidanceSourceLightningProtection =>
      'PN-EN IEC 62305-3 - projektowanie i sprawdzanie LPS';

  @override
  String get stageGuidanceSourceLightningConnections =>
      'PN-EN IEC 62561-1 - elementy połączeniowe';

  @override
  String get stageGuidanceSourceLightningConductors =>
      'PN-EN IEC 62561-2 - przewody i uziomy';

  @override
  String get stageGuidanceSourceItbWaterproofing =>
      'ITB - izolacje części podziemnych budynków';

  @override
  String get stageGuidanceSourcePmbcStandard =>
      'PN-EN 15814 - grubowarstwowe powłoki asfaltowe PMBC';

  @override
  String get stageGuidanceSourceDehnEarthing =>
      'DEHN - poradnik uziomów fundamentowych';

  @override
  String get stageGuidanceSourceHauffEntries =>
      'Hauff-Technik - systemowe przepusty do budynków';

  @override
  String get stageGuidanceSourceRemmersWaterproofing =>
      'Remmers - system hydroizolacji MB 2K';

  @override
  String get stageGuidanceSourceUrsaInsulation =>
      'URSA - termoizolacja fundamentów i cokołów';

  @override
  String get stageGuidanceSourceAluprofShading =>
      'ALUPROF - kompendium systemów osłonowych';

  @override
  String get stageGuidanceSourceConstructionLaw =>
      'Prawo budowlane - aktualny tekst ustawy';

  @override
  String get stageGuidanceSourceGunbProcedures => 'GUNB - procedury budowlane';

  @override
  String get stageGuidanceSourceGunbForms =>
      'GUNB - aktualne formularze budowlane';

  @override
  String get stageGuidanceSourceSpatialPlanning =>
      'MRiT - planowanie przestrzenne';

  @override
  String get stageGuidanceSourceGeotechnicalRegulation =>
      'Rozporządzenie - geotechniczne warunki posadowienia';

  @override
  String get stageGuidanceSourceEurocodeGeotechnical =>
      'Eurokod 7 - projektowanie i badania geotechniczne';

  @override
  String get stageGuidanceSourceGeodeticGuidance =>
      'Budowlane ABC - opracowania geodezyjne';

  @override
  String get stageGuidanceSourceElectronicConstructionLog =>
      'GUNB - Elektroniczny Dziennik Budowy';

  @override
  String get stageGuidanceSourceConstructionSafety =>
      'Rozporządzenie BHP podczas robót budowlanych';

  @override
  String get stageGuidanceSourcePipChecklist =>
      'PIP - lista kontrolna bezpieczeństwa budowy';

  @override
  String get stageGuidanceSourceGddkiaSiteAccess =>
      'GDDKiA - zasady dotyczące zjazdów';

  @override
  String get checklistHeading => 'Lista kontrolna';

  @override
  String get checklistBulkSelectAction => 'Zaznacz wiele';

  @override
  String checklistBulkSelectedCount(int count) {
    return '$count zaznaczonych';
  }

  @override
  String get checklistBulkSelectAllAction => 'Zaznacz wszystkie otwarte';

  @override
  String get checklistBulkCancelAction => 'Zakończ wybieranie';

  @override
  String get checklistBulkCompleteAction => 'Oznacz jako wykonane';

  @override
  String checklistBulkCompletedMessage(int count) {
    return 'Oznaczono jako wykonane: $count.';
  }

  @override
  String checklistBulkEvidencePendingMessage(int completed, int pending) {
    return 'Oznaczono: $completed. Pozostałe wymagają dowodu: $pending.';
  }

  @override
  String get checklistBulkOnlyEvidencePendingMessage =>
      'Wybrane punkty wymagają najpierw dodania dowodu lub zapisanego odstępstwa.';

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
  String get checklistPlanningPermissionBasis =>
      'Sprawdź MPZP albo uzyskaj warunki zabudowy';

  @override
  String get checklistPlanningPermissionBasisRisk =>
      'Projekt niezgodny z ustaleniami planistycznymi może nie uzyskać zgody albo wymagać kosztownych zmian.';

  @override
  String get checklistLandTitleAndRoadAccess =>
      'Sprawdź prawo do działki i dostęp do drogi';

  @override
  String get checklistLandTitleAndRoadAccessRisk =>
      'Niejasne granice, służebności lub brak prawnego dojazdu mogą zablokować projekt i dostawy.';

  @override
  String get checklistDesignMap => 'Zleć mapę do celów projektowych';

  @override
  String get checklistDesignMapRisk =>
      'Nieaktualna lub nieprawidłowa mapa może pominąć uzbrojenie i wymusić korektę projektu.';

  @override
  String get checklistHouseDesignSelection =>
      'Wybierz projekt domu zgodny z działką';

  @override
  String get checklistHouseDesignSelectionRisk =>
      'Zakup projektu przed sprawdzeniem MPZP lub WZ, stron świata, gruntu i budżetu często kończy się zmianami.';

  @override
  String get checklistReadyDesignAdaptation =>
      'Zaadaptuj projekt gotowy do działki, jeżeli dotyczy';

  @override
  String get checklistReadyDesignAdaptationRisk =>
      'Projekt gotowy bez adaptacji nie uwzględnia konkretnej działki, gruntu, otoczenia ani lokalnych wymagań.';

  @override
  String get checklistUtilityConnectionConditions =>
      'Uzyskaj warunki przyłączenia planowanych mediów';

  @override
  String get checklistUtilityConnectionConditionsRisk =>
      'Brak uzgodnień z operatorami może zmienić trasy, koszty i terminy przyłączy.';

  @override
  String get checklistCoordinatedBuildingDesign =>
      'Skompletuj i skoordynuj projekt budowlany oraz techniczny';

  @override
  String get checklistCoordinatedBuildingDesignRisk =>
      'Nieskoordynowane branże powodują kolizje instalacji, konstrukcji i przyłączy już na budowie.';

  @override
  String get checklistBuildingPermitOrNotification =>
      'Uzyskaj pozwolenie albo skutecznie zgłoś budowę';

  @override
  String get checklistBuildingPermitOrNotificationRisk =>
      'Rozpoczęcie bez właściwej podstawy prawnej grozi wstrzymaniem robót i postępowaniem naprawczym.';

  @override
  String get checklistConstructionManagerAppointment =>
      'Ustanów kierownika budowy, jeżeli jest wymagany';

  @override
  String get checklistConstructionManagerAppointmentRisk =>
      'Bez osoby z właściwymi uprawnieniami nie wolno rozpoczynać robót wymagających kierownika.';

  @override
  String get checklistConstructionLog => 'Uzyskaj i uruchom dziennik budowy';

  @override
  String get checklistConstructionLogRisk =>
      'Brak wymaganego dziennika utrudnia legalne rozpoczęcie i rzetelne dokumentowanie robót.';

  @override
  String get checklistConstructionCommencementNotice =>
      'Zawiadom nadzór i projektanta o rozpoczęciu robót';

  @override
  String get checklistConstructionCommencementNoticeRisk =>
      'Zagospodarowanie placu i przyłącza mogą być pracami przygotowawczymi, więc zawiadomienie złóż wcześniej.';

  @override
  String get checklistManagerDocumentationHandover =>
      'Przekaż kierownikowi projekt i dokumentację';

  @override
  String get checklistManagerDocumentationHandoverRisk =>
      'Kierownik bez kompletnego projektu, decyzji i uzgodnień nie może bezpiecznie zorganizować robót.';

  @override
  String get checklistAdditionalPermitsAudit =>
      'Sprawdź dodatkowe zgody i ograniczenia';

  @override
  String get checklistAdditionalPermitsAuditRisk =>
      'Drzewa, zabytki, grunty rolne lub leśne, wody i zjazd z drogi mogą wymagać osobnych decyzji.';

  @override
  String get checklistPreStartDocumentAudit =>
      'Sprawdź komplet dokumentów przed pierwszą pracą';

  @override
  String get checklistPreStartDocumentAuditRisk =>
      'Jedna brakująca decyzja, data ważności lub podpis może zatrzymać rozpoczęcie budowy.';

  @override
  String get checklistSiteLogisticsPlan =>
      'Uzgodnij z kierownikiem logistykę placu';

  @override
  String get checklistSiteLogisticsPlanRisk =>
      'Brak planu wjazdu, składowania i pracy maszyn zwiększa ryzyko kolizji, szkód i przestojów.';

  @override
  String get checklistTemporarySiteFence =>
      'Przygotuj tymczasowe ogrodzenie działki';

  @override
  String get checklistTemporarySiteFenceRisk =>
      'Niezabezpieczony teren naraża osoby postronne na wejście w strefę robót.';

  @override
  String get checklistHeavyEquipmentGate =>
      'Przygotuj szeroką bramę i bezpieczne wejście piesze';

  @override
  String get checklistHeavyEquipmentGateRisk =>
      'Zbyt wąski wjazd lub wspólna trasa pieszych i maszyn utrudni dostawy i zwiększy ryzyko wypadku.';

  @override
  String get checklistStabilizedSiteEntrance =>
      'Przygotuj legalny i utwardzony wjazd';

  @override
  String get checklistStabilizedSiteEntranceRisk =>
      'Grząski albo nieuzgodniony zjazd może zatrzymać ciężki sprzęt, uszkodzić drogę i nanosić błoto.';

  @override
  String get checklistToolStorageContainer =>
      'Ustaw blaszak lub kontener na narzędzia';

  @override
  String get checklistToolStorageContainerRisk =>
      'Źle ustawione lub niezabezpieczone zaplecze utrudnia pracę i zwiększa ryzyko kradzieży albo pożaru.';

  @override
  String get checklistTemporaryConstructionPower =>
      'Zapewnij bezpieczny prąd budowlany';

  @override
  String get checklistTemporaryConstructionPowerRisk =>
      'Prowizoryczne zasilanie bez zabezpieczeń i pomiarów grozi porażeniem, pożarem oraz przestojem.';

  @override
  String get checklistConstructionWaterSupply =>
      'Zapewnij wodę do robót, higieny i picia';

  @override
  String get checklistConstructionWaterSupplyRisk =>
      'Brak rozdzielenia wody technologicznej i pitnej utrudnia roboty oraz bezpieczne zaplecze pracowników.';

  @override
  String get checklistPortableToilet => 'Ustaw toaletę przenośną i punkt mycia';

  @override
  String get checklistPortableToiletRisk =>
      'Brak dostępnego i regularnie serwisowanego zaplecza sanitarnego narusza podstawowe warunki pracy.';

  @override
  String get checklistSiteUtilitiesAndHazardsMarking =>
      'Oznacz uzbrojenie, drzewa i strefy niebezpieczne';

  @override
  String get checklistSiteUtilitiesAndHazardsMarkingRisk =>
      'Nieoznaczone sieci i strefy pracy maszyn zwiększają ryzyko uszkodzeń, porażenia i wypadków.';

  @override
  String get checklistSiteSafetySetup =>
      'Przygotuj tablicę, BIOZ i wyposażenie bezpieczeństwa';

  @override
  String get checklistSiteSafetySetupRisk =>
      'Brak oznakowania, apteczki, gaśnicy lub wymaganej dokumentacji utrudni reakcję na zagrożenie.';

  @override
  String get checklistMaterialAndWasteZones =>
      'Wyznacz miejsca materiałów, dostaw i odpadów';

  @override
  String get checklistMaterialAndWasteZonesRisk =>
      'Chaotyczne składowanie blokuje przejazdy, niszczy materiały i utrudnia legalne przekazanie odpadów.';

  @override
  String get checklistPreConstructionPhotoRecord =>
      'Zrób dokumentację stanu przed budową';

  @override
  String get checklistPreConstructionPhotoRecordRisk =>
      'Bez zdjęć granic, drogi, drzew i sąsiednich ogrodzeń trudno później rozstrzygnąć odpowiedzialność za szkody.';

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
  String get guidancePlanningAndGroundConditionsTitle =>
      'Plan miejscowy, mapa i grunt';

  @override
  String get guidancePlanningAndGroundConditionsTiming =>
      'Przed wyborem i adaptacją projektu domu';

  @override
  String get guidancePlanningAndGroundConditionsSummary =>
      'Najpierw potwierdź w gminie aktualną podstawę planistyczną dla działki: MPZP albo potrzebę uzyskania WZ. Mapa projektowa i rozpoznanie gruntu powinny trafić do projektanta przed ustaleniem posadowienia.';

  @override
  String get guidancePlanningAndGroundConditionsChecks =>
      'Pobierz aktualne ustalenia MPZP albo potwierdź tryb uzyskania WZ i wymagane załączniki.\nSprawdź tytuł prawny, dostęp do drogi oraz ograniczenia widoczne w dokumentach działki.\nZleć mapę do celów projektowych uprawnionemu geodecie.\nUzgodnij z projektantem zakres rozpoznania geotechnicznego i przekaż mu wyniki przed doborem fundamentów.';

  @override
  String get guidancePlanningAndGroundConditionsQuestions =>
      'Czy urząd potwierdził aktualną ścieżkę planistyczną dla tej działki?\nCzy mapa obejmuje potrzebny teren i uzbrojenie?\nCzy warunki gruntowo-wodne mogą zmienić fundament, odwodnienie lub hydroizolację?';

  @override
  String get guidanceDesignUtilitiesAndApprovalsTitle =>
      'Spójny projekt i zgody';

  @override
  String get guidanceDesignUtilitiesAndApprovalsTiming =>
      'Przed złożeniem wniosku lub zgłoszenia i przed zamówieniem robót';

  @override
  String get guidanceDesignUtilitiesAndApprovalsSummary =>
      'Projekt gotowy wymaga adaptacji do działki. Warunki przyłączenia i projekty branżowe skoordynuj z architekturą oraz konstrukcją, a właściwy tryb pozwolenia albo zgłoszenia potwierdź dla konkretnej inwestycji.';

  @override
  String get guidanceDesignUtilitiesAndApprovalsChecks =>
      'Porównaj projekt z MPZP albo WZ, mapą, geotechniką i warunkami przyłączenia.\nZbierz uzgodnione rozwiązania prądu, wody, kanalizacji, gazu i teletechniki.\nSprawdź komplet projektu zagospodarowania działki, projektu architektoniczno-budowlanego i wymaganej dokumentacji technicznej.\nUżyj aktualnego formularza GUNB i sprawdź, czy potrzebne są dodatkowe decyzje lub uzgodnienia.';

  @override
  String get guidanceDesignUtilitiesAndApprovalsQuestions =>
      'Czy adaptujący projektant potwierdził komplet i zgodność wszystkich branż?\nCzy każde przyłącze ma ustaloną trasę, punkt wejścia i odpowiedzialnego wykonawcę?\nCzy urząd wskazał dodatkowe załączniki właściwe dla lokalizacji?';

  @override
  String get guidanceLegalConstructionStartTitle => 'Legalny start budowy';

  @override
  String get guidanceLegalConstructionStartTiming =>
      'Zanim rozpoczną się roboty przygotowawcze na działce';

  @override
  String get guidanceLegalConstructionStartSummary =>
      'Zagospodarowanie terenu budowy, obiekty tymczasowe, przyłącza i wytyczenie geodezyjne mogą stanowić rozpoczęcie budowy. Najpierw zapewnij skuteczną podstawę realizacji, kierownika, dziennik i wymagane zawiadomienie o rozpoczęciu robót.';

  @override
  String get guidanceLegalConstructionStartChecks =>
      'Potwierdź z kierownikiem, że pozwolenie jest wykonalne albo zgłoszenie pozwala rozpocząć roboty.\nUstal kierownika budowy i uzyskaj wymagane oświadczenia.\nZałóż właściwy dziennik budowy: papierowy albo elektroniczny.\nZłóż aktualne zawiadomienie o rozpoczęciu robót wraz z wymaganymi załącznikami.\nPrzekaż kierownikowi zatwierdzony projekt, dokumentację techniczną, decyzje i warunki przyłączy.';

  @override
  String get guidanceLegalConstructionStartQuestions =>
      'Czy kierownik pisemnie potwierdził gotowość do przejęcia budowy?\nCzy zawiadomienie obejmuje właściwy organ i komplet załączników?\nCzy na budowie jest aktualna dokumentacja do kontroli i prowadzenia robót?';

  @override
  String get guidanceSiteLogisticsAndAccessTitle => 'Dojazd i logistyka placu';

  @override
  String get guidanceSiteLogisticsAndAccessTiming =>
      'Przed pierwszą dostawą, koparką i ustawieniem zaplecza';

  @override
  String get guidanceSiteLogisticsAndAccessSummary =>
      'Rozrysuj ruch ciężkiego sprzętu, strefy rozładunku i składowania. Ogrodzenie, brama i utwardzony dojazd mają ograniczać ryzyko dla ludzi, drogi, instalacji podziemnych i przyszłych elementów domu.';

  @override
  String get guidanceSiteLogisticsAndAccessChecks =>
      'Uzgodnij kierunek wjazdu, promień skrętu, szerokość i nośność trasy z dostawcami.\nCo do zasady zabezpiecz teren ogrodzeniem o wysokości co najmniej 1,5 m; gdy nie jest to możliwe, zastosuj rozwiązanie przewidziane w przepisach i uzgodnione z kierownikiem.\nOddziel ruch pieszy od maszyn oraz wyznacz bezpieczne miejsce rozładunku.\nSprawdź formalności dotyczące istniejącego lub tymczasowego zjazdu z drogi.\nUstaw kontener i składowiska poza wykopem, trasami instalacji i zasięgiem pracy maszyn.';

  @override
  String get guidanceSiteLogisticsAndAccessQuestions =>
      'Czy betoniarka, pompa i dźwig wjadą oraz bezpiecznie wyjadą?\nCzy podłoże wytrzyma ruch po deszczu?\nCzy brama i składowiska nie kolidują z przyłączami ani docelowym zagospodarowaniem?';

  @override
  String get guidanceTemporaryUtilitiesAndFacilitiesTitle =>
      'Prąd, woda i zaplecze';

  @override
  String get guidanceTemporaryUtilitiesAndFacilitiesTiming =>
      'Przed uruchomieniem elektronarzędzi i stałej pracy ekip';

  @override
  String get guidanceTemporaryUtilitiesAndFacilitiesSummary =>
      'Tymczasowe instalacje są częścią organizacji bezpiecznej budowy. Zasilanie powinien przygotować i sprawdzić uprawniony elektryk, a woda i toaleta muszą odpowiadać rzeczywistemu składowi ekip oraz zakresowi robót.';

  @override
  String get guidanceTemporaryUtilitiesAndFacilitiesChecks =>
      'Ustal legalny punkt poboru, moc i trasę zasilania bez kabli leżących w przejeździe lub wodzie.\nZleć elektrykowi rozdzielnicę, ochronę przeciwporażeniową, uziemienie i wymagane pomiary.\nZapewnij wodę do robót oraz osobno wodę zdatną do picia, jeśli źródło techniczne jej nie gwarantuje.\nUstaw i regularnie serwisuj toaletę w dostępnym, stabilnym miejscu.\nOznacz istniejące sieci i zabezpiecz punkty poboru przed uszkodzeniem oraz dostępem osób postronnych.';

  @override
  String get guidanceTemporaryUtilitiesAndFacilitiesQuestions =>
      'Czy protokół instalacji tymczasowej i zabezpieczenia są aktualne?\nCzy zapas mocy wystarczy dla planowanego sprzętu?\nKto odpowiada za wodę, opróżnianie toalety i porządek zaplecza?';

  @override
  String get guidanceSiteSafetyAndEvidenceTitle =>
      'Bezpieczeństwo i stan początkowy';

  @override
  String get guidanceSiteSafetyAndEvidenceTiming =>
      'Przed przekazaniem placu ekipie i przed pierwszym wykopem';

  @override
  String get guidanceSiteSafetyAndEvidenceSummary =>
      'Kierownik organizuje zabezpieczenie terenu i ocenia obowiązki dotyczące planu BIOZ oraz tablicy informacyjnej. Zdjęcia stanu początkowego pomagają później rozstrzygać uszkodzenia drogi, granic i sąsiedniego terenu.';

  @override
  String get guidanceSiteSafetyAndEvidenceChecks =>
      'Oznacz granice, uzbrojenie, strefy niebezpieczne, wykopy i miejsca o ograniczonym dostępie.\nPotwierdź z kierownikiem wymagane zabezpieczenia, plan BIOZ, tablicę informacyjną i instrukcje dla ekip.\nZapewnij oświetlenie, dojścia, porządek oraz bezpieczne magazynowanie materiałów i odpadów.\nWykonaj datowane zdjęcia drogi, zjazdu, ogrodzeń, punktów granicznych, zieleni i istniejących sieci.\nZapisz odbiór placu i osoby odpowiedzialne za codzienną kontrolę zabezpieczeń.';

  @override
  String get guidanceSiteSafetyAndEvidenceQuestions =>
      'Czy każda ekipa zna zasady ruchu, składowania i zgłaszania zagrożeń?\nCzy zdjęcia pokazują skalę, lokalizację i cały obszar możliwych uszkodzeń?\nKto kontroluje ogrodzenie, rozdzielnicę i strefy niebezpieczne po pracy?';

  @override
  String get guidanceServicePenetrationsTitle =>
      'Przepusty i instalacje przed betonowaniem';

  @override
  String get guidanceServicePenetrationsTiming =>
      'Przed zbrojeniem, szalowaniem i betonowaniem ław lub płyty';

  @override
  String get guidanceServicePenetrationsSummary =>
      'Zbierz elektryka, instalatora sanitarnego i konstruktora nad jednym rysunkiem przejść. Po betonowaniu brakująca trasa zwykle oznacza przewiert przez konstrukcję lub hydroizolację.';

  @override
  String get guidanceServicePenetrationsChecks =>
      'Ustal osie, rzędne, średnice i sposób uszczelnienia z projektów branżowych.\nSprawdź kanalizację, wodę, prąd, teletechnikę oraz rezerwy do bramy, domofonu, ogrodu, pompy ciepła, PV i ładowarki auta.\nZweryfikuj spadki kanalizacji, miejsca pionów, rewizji i pierwszej studzienki.\nZabezpiecz i oznacz tuleje przed przesunięciem oraz dostaniem się betonu.\nZrób zdjęcia z miarą i odniesieniem do stałych osi budynku przed zakryciem.';

  @override
  String get guidanceServicePenetrationsQuestions =>
      'Czy wszystkie branże zatwierdziły wspólny rysunek przejść?\nKtóre przepusty mają być wodo- lub gazoszczelne?\nCzy później da się wymienić kabel bez kucia?\nJak przejście zachowa ciągłość hydroizolacji i nie osłabi zbrojenia?';

  @override
  String get guidanceFoundationGroundingTitle =>
      'Uziom fundamentowy bez zgadywania';

  @override
  String get guidanceFoundationGroundingTiming =>
      'Projekt przed zbrojeniem; odbiór przed betonowaniem; pomiar po wykonaniu układu';

  @override
  String get guidanceFoundationGroundingSummary =>
      'Nie istnieje jedna właściwa bednarka, liczba szpilek ani uniwersalna rezystancja dla każdego domu. Projektant instalacji elektrycznej dobiera układ do ochrony przeciwporażeniowej, fundamentu i gruntu, a przy LPS także do PN-EN IEC 62305-3. Po wykonaniu fundamentu można zaprojektować uziom otokowy lub pionowe elektrody uziemiające, lecz nie zastępuje to projektu i pomiarów.';

  @override
  String get guidanceFoundationGroundingChecks =>
      'Przed betonowaniem potwierdź projekt uziomu fundamentowego: przebieg, materiał, przekrój, połączenia ze zbrojeniem, wypusty i ochronę przed korozją.\nSprawdź, czy fundament zachowa trwały kontakt elektryczny z gruntem. Przy pełnej izolacji obwodowej, płycie izolowanej lub betonie wodoszczelnym projekt może wymagać uziomu otokowego w gruncie oraz przewodu wyrównania potencjałów w fundamencie.\nJeżeli fundament jest już wykonany, projektant może dobrać zamknięty uziom otokowy albo uziomy pionowe, nazywane szpilkami. Ich materiał, długość, liczba i rozstaw wynikają z warunków gruntu, ryzyka korozji, funkcji układu i wyników pomiarów.\nUstal połączenie z główną szyną uziemiającą oraz wypusty dla LPS, PV i innych projektowanych instalacji. Użyj elementów połączeniowych i uziomów o potwierdzonej zgodności z właściwym środowiskiem pracy.\nPrzed betonowaniem wykonaj oględziny, zdjęcia z miarą i sprawdzenie ciągłości. Po ukończeniu układu zleć pomiary oraz protokół; kryterium odbioru wynika z projektu i zastosowanego środka ochrony, nie z jednej liczby znalezionej w internecie.';

  @override
  String get guidanceFoundationGroundingQuestions =>
      'Jaką funkcję ma pełnić układ: ochronną, funkcjonalną, odgromową czy kilka naraz?\nCzy hydroizolacja, termoizolacja lub beton wodoszczelny odizolują fundament od gruntu?\nCzy projekt przewiduje uziom fundamentowy, otokowy, pionowy lub układ łączony i na jakiej podstawie?\nGdzie będą główna szyna uziemiająca, wypusty i dostępne złącza kontrolne?\nKto wykona odbiór przed betonowaniem, pomiary końcowe i podpisze protokół?';

  @override
  String get guidanceFoundationWaterproofingTitle =>
      'Hydroizolacja dobrana do wody, nie do nazwy produktu';

  @override
  String get guidanceFoundationWaterproofingTiming =>
      'Po rozpoznaniu warunków gruntowo-wodnych, przed zakupem materiałów i zasypaniem';

  @override
  String get guidanceFoundationWaterproofingSummary =>
      'Najpierw określ obciążenie wodą i oczekiwaną zdolność mostkowania rys. Dysperbit może być gruntem lub powłoką przeciwwilgociową zgodnie z kartą konkretnego produktu, lecz nie należy zakładać, że zastąpi izolację przeciwwodną przy naporze wody. KMB/PMBC 2K także musi być dobrane i wykonane jako kompletny system.';

  @override
  String get guidanceFoundationWaterproofingChecks =>
      'Oprzyj rozwiązanie na geotechnice, maksymalnym poziomie wody i projekcie hydroizolacji.\nSprawdź przeznaczenie produktu, deklarację właściwości, wymaganą suchą grubość, liczbę cykli i czas wysychania.\nDopracuj podłoże, fasety, naroża, połączenie izolacji poziomej z pionową oraz każde przejście instalacyjne.\nPo odbiorze hydroizolacji zastosuj kompatybilne mocowanie XPS lub innej termoizolacji i warstwę ochronną przewidzianą w systemie.\nNie przebijaj powłoki mocowaniem i nie zasypuj jej przed wymaganym utwardzeniem.';

  @override
  String get guidanceFoundationWaterproofingQuestions =>
      'Czy występuje tylko wilgoć gruntowa, woda zalegająca czy parcie hydrostatyczne?\nJaka jest minimalna grubość suchej warstwy i jak będzie kontrolowana?\nCzy klej, XPS i membrana ochronna są zgodne z wybraną masą?\nKto odbierze detale przed ich zakryciem?';

  @override
  String get guidanceDrainageAndGroundLevelsTitle =>
      'Drenaż, odpływ i docelowe poziomy terenu';

  @override
  String get guidanceDrainageAndGroundLevelsTiming =>
      'Przed zasypaniem fundamentów i wykonaniem docelowego terenu';

  @override
  String get guidanceDrainageAndGroundLevelsSummary =>
      'Drenaż nie jest automatycznym dodatkiem do każdego domu. Musi wynikać z warunków wodnych i projektu oraz mieć legalne, drożne miejsce odprowadzenia. Folia kubełkowa może pełnić funkcję ochronną lub drenażową w danym systemie, ale sama nie jest hydroizolacją.';

  @override
  String get guidanceDrainageAndGroundLevelsChecks =>
      'Potwierdź zasadność drenażu, poziomy, spadki, obsypkę, studzienki i możliwość czyszczenia.\nUstal odbiornik wody oraz zabezpieczenie przed cofaniem i zamuleniem.\nSprawdź docelowe rzędne tarasów, podjazdu i gruntu przy cokole.\nZaplanuj swobodny spływ wody opadowej od budynku.\nChroń hydroizolację podczas zasypywania zgodnie z wybranym systemem.';

  @override
  String get guidanceDrainageAndGroundLevelsQuestions =>
      'Dokąd woda ma odpływać i czy jest na to zgoda?\nCzy drenaż może działać grawitacyjnie przez cały rok?\nJak będzie kontrolowany i czyszczony?\nCzy docelowe poziomy nie zasłonią cokołu ani wejść do budynku?';

  @override
  String get guidanceConcealedWorksEvidenceTitle =>
      'Odbiór i zdjęcia zanim beton lub grunt wszystko zakryje';

  @override
  String get guidanceConcealedWorksEvidenceTiming =>
      'Bezpośrednio przed każdym betonowaniem, zasypaniem lub zakryciem';

  @override
  String get guidanceConcealedWorksEvidenceSummary =>
      'Zdjęcia bez skali i lokalizacji są mało użyteczne. Udokumentuj elementy ukryte tak, aby po latach można było znaleźć trasę, połączenie i punkt przejścia bez zgadywania.';

  @override
  String get guidanceConcealedWorksEvidenceChecks =>
      'Zrób ujęcie ogólne i zbliżenia z miarą oraz odniesieniem do osi lub narożnika.\nFotografuj zbrojenie, uziom, wypusty, przepusty, kanalizację, detale hydroizolacji i naprawy.\nZapisz odbiór kierownika lub branżysty oraz wymagane protokoły i wyniki prób.\nZachowaj dokument WZ betonu i potwierdzenie jego parametrów.\nPo wykonaniu fundamentów dołącz inwentaryzację geodezyjną.';

  @override
  String get guidanceConcealedWorksEvidenceQuestions =>
      'Czy ze zdjęć da się odtworzyć dokładne położenie elementu?\nCzy wymagane próby i pomiary mają podpisany protokół?\nCzy kierownik zaakceptował roboty przed zgodą na zakrycie?';

  @override
  String get guidanceWindowShadingPreparationTitle =>
      'Detal nadproża pod rolety lub żaluzje';

  @override
  String get guidanceWindowShadingPreparationTiming =>
      'Przed wykonaniem nadproży, zamówieniem okien i zamknięciem projektu elewacji';

  @override
  String get guidanceWindowShadingPreparationSummary =>
      'Nie ma uniwersalnego cofnięcia o 5 cm. Potrzebna wnęka zależy od wybranego systemu, wymiaru skrzynki, pakietu lameli, prowadnic, położenia okna, ocieplenia i konstrukcji nadproża.';

  @override
  String get guidanceWindowShadingPreparationChecks =>
      'Wybierz typ osłony i konkretny system dla każdego otworu.\nUzyskaj detal z wymiarami skrzynki, wnęki, prowadnic, mocowań i dostępu serwisowego.\nUzgodnij detal z architektem i konstruktorem przed zmianą geometrii nadproża.\nSprawdź ciągłość ocieplenia, szczelność połączenia okna oraz ryzyko mostka cieplnego.\nDoprowadź zasilanie i sterowanie do właściwej strony, zachowując dostęp do napędu.';

  @override
  String get guidanceWindowShadingPreparationQuestions =>
      'Roleta czy żaluzja fasadowa i w jakim systemie zabudowy?\nJakie są rzeczywiste wymiary skrzynki i pakietu dla tego okna?\nGdzie będzie rewizja serwisowa, przewód i napęd?\nCzy detal nie osłabia nadproża i mieści projektowaną grubość elewacji?';

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
  String get dashboardScanReceipt => 'Skanuj paragon';

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
  String get contactImportFromPhoneAction => 'Wybierz z kontaktów telefonu';

  @override
  String get contactImportFromPhoneError =>
      'Nie udało się otworzyć kontaktów telefonu.';

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

  @override
  String get receiptScanTitle => 'Skan dokumentu zakupu';

  @override
  String get receiptScanIdleTitle => 'Paragon lub faktura';

  @override
  String get receiptScanIdleMessage =>
      'Zeskanuj paragon lub jednostronicową fakturę albo wybierz plik.';

  @override
  String get receiptScanLocalOnly =>
      'Oryginał i OCR pozostają na tym urządzeniu.';

  @override
  String get receiptScanAction => 'Zeskanuj dokument';

  @override
  String get receiptImportAction => 'Importuj obraz lub PDF';

  @override
  String get receiptCaptureProcessing => 'Zabezpieczanie oryginału…';

  @override
  String get receiptRecognitionProcessing => 'Odczytywanie dokumentu…';

  @override
  String get receiptResultTitle => 'Odczyt z dokumentu';

  @override
  String get receiptBudgetUnchangedTitle => 'Budżet bez zmian';

  @override
  String get receiptBudgetUnchangedMessage =>
      'To propozycja do sprawdzenia. Nie dodano kosztu.';

  @override
  String get receiptSellerLabel => 'Sprzedawca';

  @override
  String get receiptDateLabel => 'Data';

  @override
  String get receiptDocumentNumberLabel => 'Numer dokumentu';

  @override
  String get receiptTotalLabel => 'Razem na dokumencie';

  @override
  String get receiptItemsTotalLabel => 'Suma pozycji';

  @override
  String get receiptUseItemsTotalAction => 'Użyj sumy pozycji';

  @override
  String get receiptReplaceItemsAction => 'Zapisz jako jedną pozycję';

  @override
  String get receiptSingleItemDefaultName => 'Zakup z dokumentu';

  @override
  String get receiptVatLinesLabel => 'Odczytane linie VAT';

  @override
  String get receiptItemLinesLabel => 'Odczytane pozycje';

  @override
  String get receiptRawTextLabel => 'Pełny tekst OCR';

  @override
  String get receiptDiscardAction => 'Odrzuć wynik';

  @override
  String get receiptRetryOcrAction => 'Ponów odczyt';

  @override
  String get receiptScannerUnavailableTitle => 'Skaner jest niedostępny';

  @override
  String get receiptScannerUnavailableMessage =>
      'Możesz zaimportować zdjęcie dokumentu albo PDF z pamięci telefonu.';

  @override
  String get receiptUnsupportedTitle => 'Nieobsługiwany plik';

  @override
  String get receiptUnsupportedMessage =>
      'Wybierz czytelny plik JPG, PNG, WEBP albo PDF.';

  @override
  String get receiptEmptyTextTitle => 'Nie odczytano tekstu';

  @override
  String get receiptEmptyTextMessage =>
      'Spróbuj ponownie lub użyj wyraźniejszego zdjęcia.';

  @override
  String get receiptStorageErrorTitle => 'Nie udało się zabezpieczyć skanu';

  @override
  String get receiptStorageErrorMessage =>
      'Sprawdź wolne miejsce i spróbuj ponownie.';

  @override
  String get receiptRecognitionErrorTitle => 'Nie udało się odczytać dokumentu';

  @override
  String get receiptRecognitionErrorMessage =>
      'Oryginał jest zachowany w tej sesji. Możesz ponowić odczyt.';

  @override
  String get receiptPreviewUnavailable => 'Podgląd jest niedostępny.';

  @override
  String get receiptGatewayLoadError =>
      'Nie udało się przygotować lokalnego skanera.';

  @override
  String get receiptSaveProcessing => 'Zapisywanie szkiców kosztów…';

  @override
  String get receiptReviewTitle => 'Sprawdź dane przed zapisem';

  @override
  String get receiptConfidenceNeedsReview =>
      'Niepewny odczyt. Popraw wartość albo potwierdź ją ręcznie.';

  @override
  String get receiptConfirmFieldTooltip => 'Potwierdź odczytaną wartość';

  @override
  String get receiptSellerRequiredError => 'Wpisz nazwę sprzedawcy.';

  @override
  String get receiptSellerInvalidError =>
      'Nazwa sprzedawcy jest nieprawidłowa.';

  @override
  String get receiptDateRequiredError => 'Wpisz datę z dokumentu.';

  @override
  String get receiptDateInvalidError =>
      'Wpisz prawidłową datę, np. 25.07.2026.';

  @override
  String get receiptDocumentNumberInvalidError =>
      'Numer dokumentu jest za długi lub nieprawidłowy.';

  @override
  String get receiptTotalRequiredError =>
      'Wpisz kwotę razem albo użyj sumy pozycji.';

  @override
  String get receiptTotalInvalidError => 'Wpisz dodatnią kwotę, np. 19,40.';

  @override
  String get receiptItemVatNeedsReview =>
      'OCR nie ustala pewnej stawki VAT. Wybierz stawkę albo potwierdź widoczną wartość.';

  @override
  String get receiptItemNeedsReview =>
      'Sprawdź nazwę, kwotę i stawkę VAT, a następnie potwierdź pozycję.';

  @override
  String get receiptConfirmItemTooltip => 'Potwierdź pozycję i stawkę VAT';

  @override
  String get receiptItemNameLabel => 'Nazwa pozycji';

  @override
  String get receiptGrossAmountLabel => 'Kwota brutto';

  @override
  String get receiptItemNameRequiredError => 'Wpisz nazwę pozycji.';

  @override
  String get receiptItemNameInvalidError =>
      'Nazwa pozycji jest za długa lub nieprawidłowa.';

  @override
  String get receiptItemAmountInvalidError => 'Wpisz dodatnią kwotę brutto.';

  @override
  String get receiptVatRateLabel => 'VAT';

  @override
  String get receiptAddItemAction => 'Dodaj pozycję';

  @override
  String get receiptMergeNextTooltip => 'Połącz z następną pozycją';

  @override
  String get receiptSplitTooltip => 'Podziel pozycję';

  @override
  String get receiptRemoveItemTooltip => 'Usuń pozycję';

  @override
  String get receiptSaveDraftsAction => 'Zapisz szkice kosztów';

  @override
  String get receiptValidationMessage =>
      'Popraw pola oznaczone błędem i potwierdź niepewne odczyty oraz stawki VAT.';

  @override
  String get receiptTotalMismatchTitle => 'Suma pozycji różni się od dokumentu';

  @override
  String get receiptTotalMismatchMessage =>
      'Sprawdź pozycje i kwotę razem. Zapis z różnicą wymaga osobnego potwierdzenia.';

  @override
  String get receiptTotalMismatchAction => 'Potwierdzam różnicę';

  @override
  String get receiptDuplicateTitle => 'Ten dokument może już być zapisany';

  @override
  String get receiptDuplicateMessage =>
      'Znaleziono zgodność pliku albo sprzedawcy, daty i sumy. Sprawdź dane przed utworzeniem kolejnych szkiców.';

  @override
  String get receiptDuplicateFileReason => 'Identyczna zawartość pliku';

  @override
  String get receiptDuplicateSignatureReason =>
      'Ten sam sprzedawca, data i suma';

  @override
  String get receiptDuplicateSameAttachmentReason =>
      'Ten dokument jest już zapisany';

  @override
  String get receiptDuplicateAlreadySavedMessage =>
      'Ten sam dokument został już zapisany. Usuń bieżący skan albo wróć do istniejących szkiców kosztów.';

  @override
  String get receiptDuplicateContinueAction => 'Zapisz mimo duplikatu';

  @override
  String get receiptSaveError =>
      'Nie udało się zapisać szkiców. Dane korekty i skan pozostały w tej sesji.';

  @override
  String get receiptSavedTitle => 'Szkice kosztów zapisane';

  @override
  String receiptSavedMessage(int count) {
    return 'Liczba zapisanych szkiców kosztów: $count. Utworzono też jeden dokument zakupu. Budżet zmieni się dopiero po zatwierdzeniu kosztów.';
  }

  @override
  String get receiptOpenDraftsAction => 'Otwórz szkice w budżecie';

  @override
  String get receiptDoneAction => 'Gotowe';

  @override
  String get receiptSplitTitle => 'Podziel pozycję';

  @override
  String get receiptSplitFirstHeading => 'Pierwsza pozycja';

  @override
  String get receiptSplitSecondHeading => 'Druga pozycja';

  @override
  String get receiptSplitApplyAction => 'Podziel';
}
