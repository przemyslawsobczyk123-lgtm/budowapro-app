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
  String get costRegisterComponentSection => 'Skład kosztu';

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
  String get costCsvComponentColumn => 'Skład kosztu';

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
  String get costComponentLabel => 'Skład kosztu';

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
  String get costComponentMaterial => 'Materiał';

  @override
  String get costComponentLabor => 'Robocizna';

  @override
  String get costComponentMixed => 'Wspólna wycena: materiał + robocizna';

  @override
  String get costComponentUnassigned => 'Nieprzypisane';

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
      'Rodzaj i status zatwierdzonego wpisu są zablokowane.';

  @override
  String get costAmountCorrectionHint =>
      'Zmiana kwoty zapisze korektę i zachowa pierwotną wartość w historii.';

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
  String get costRelationsSection => 'Powiązane dane';

  @override
  String get costRelationRoomLabel => 'Pomieszczenie';

  @override
  String get costRelationMaterialLabel => 'Materiał';

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
  String get stageCurrentLabel => 'Bieżący etap';

  @override
  String get stageSetCurrentAction => 'Ustaw jako bieżący';

  @override
  String get stageCompleteAction => 'Oznacz jako ukończony';

  @override
  String get stageReopenAction => 'Wznów etap';

  @override
  String get stageCompleteWithOpenItemsTitle => 'Etap ma otwarte punkty';

  @override
  String stageCompleteWithOpenItemsMessage(int count) {
    return 'Pozostało otwartych punktów: $count. Możesz mimo to oznaczyć etap jako ukończony, jeśli świadomie przenosisz je poza zakres albo rozliczysz je później.';
  }

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
  String get stageGuidanceSourceConcreteExecution =>
      'PN-EN 13670 - wykonywanie konstrukcji z betonu';

  @override
  String get stageGuidanceSourceMasonryExecution =>
      'PN-EN 1996-2 - wykonanie konstrukcji murowych';

  @override
  String get stageGuidanceSourceItbRoofCoverings =>
      'ITB - wykonanie i odbiór pokryć dachowych';

  @override
  String get stageGuidanceSourceWindowPerformance =>
      'PN-EN 14351-1+A2 - właściwości okien i drzwi zewnętrznych';

  @override
  String get stageGuidanceSourceItbWindowInstallation =>
      'ITB WTWiORB B6 - montaż okien i drzwi balkonowych';

  @override
  String get stageGuidanceSourceWaterInstallation =>
      'PN-EN 806-4 - wykonanie instalacji wodociągowych';

  @override
  String get stageGuidanceSourceSurfaceHeating =>
      'PN-EN 1264-4 - instalowanie ogrzewania płaszczyznowego';

  @override
  String get stageGuidanceSourceVentilationAcceptance =>
      'PN-EN 12599 - odbiór wentylacji i klimatyzacji';

  @override
  String get stageGuidanceSourceItbTileFinishes =>
      'ITB - okładziny i posadzki z płytek ceramicznych';

  @override
  String get stageGuidanceSourceLiquidWaterproofing =>
      'PN-EN 14891 - ciekłe wyroby wodochronne pod płytki';

  @override
  String get stageGuidanceSourceItbWetAreaWaterproofing =>
      'ITB WTWiORB C6 - zabezpieczenia wodochronne pomieszczeń mokrych';

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
  String get checklistBuiltInRiskTitle => 'Dlaczego ten punkt jest ważny';

  @override
  String get checklistRiskOverrideLabel => 'Własny opis ryzyka';

  @override
  String get checklistRiskOverrideHint =>
      'Pozostaw puste, aby używać opisu BudowaPRO.';

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
  String get checklistPlanningScopeAndBudget =>
      'Ustal zakres remontu, budżet i rezerwę';

  @override
  String get checklistPlanningScopeAndBudgetRisk =>
      'Brak zakresu i rezerwy utrudnia porównanie ofert oraz zwiększa ryzyko kosztownych zmian w trakcie robót.';

  @override
  String get checklistExistingBuildingSurvey =>
      'Zrób inwentaryzację istniejącego stanu';

  @override
  String get checklistExistingBuildingSurveyRisk =>
      'Nieudokumentowane wymiary, instalacje i uszkodzenia mogą prowadzić do kolizji oraz sporów przy remoncie.';

  @override
  String get checklistDesignDecisionsRegister =>
      'Zapisz decyzje materiałowe i wykonawcze';

  @override
  String get checklistDesignDecisionsRegisterRisk =>
      'Ustalenia ustne łatwo się rozchodzą, a późniejsze zmiany zwiększają koszt i opóźnienie.';

  @override
  String get checklistDemolitionHazardSurvey =>
      'Sprawdź zagrożenia przed rozbiórką';

  @override
  String get checklistDemolitionHazardSurveyRisk =>
      'Nieznany azbest, szkło, instalacje pod napięciem lub niestabilne elementy mogą zagrozić zdrowiu i konstrukcji.';

  @override
  String get checklistUtilityDisconnectionAndProtection =>
      'Odłącz i zabezpiecz istniejące instalacje';

  @override
  String get checklistUtilityDisconnectionAndProtectionRisk =>
      'Pozostawione zasilanie, gaz, woda lub kanalizacja może spowodować porażenie, zalanie albo pożar.';

  @override
  String get checklistDemolitionPlanAndWaste =>
      'Ustal kolejność rozbiórki i odbiór odpadów';

  @override
  String get checklistDemolitionPlanAndWasteRisk =>
      'Brak kolejności może naruszyć stateczność budynku, a odpady bez segregacji utrudnią legalne przekazanie.';

  @override
  String get checklistNeighborAndCommonAreaProtection =>
      'Zabezpiecz sąsiadów i części wspólne';

  @override
  String get checklistNeighborAndCommonAreaProtectionRisk =>
      'Pył, hałas, drgania i uszkodzenia komunikacji wspólnej mogą zatrzymać prace i wywołać roszczenia.';

  @override
  String get checklistDemolitionCompletionInspection =>
      'Odbierz stan po rozbiórce';

  @override
  String get checklistDemolitionCompletionInspectionRisk =>
      'Pozostawione odpady, otwarte przejścia lub niezinwentaryzowane uszkodzenia utrudnią bezpieczny kolejny etap.';

  @override
  String get checklistShellStructuralAcceptance =>
      'Odbierz konstrukcję i elementy przed zakryciem';

  @override
  String get checklistShellStructuralAcceptanceRisk =>
      'Błąd zbrojenia, geometrii lub otworu po zakryciu jest trudny do wykrycia i naprawy.';

  @override
  String get checklistRoofWeatherProtection =>
      'Zabezpiecz dach i odwodnienie przed opadami';

  @override
  String get checklistRoofWeatherProtectionRisk =>
      'Nieszczelne przejścia, obróbki lub rynny mogą zawilgocić konstrukcję i wnętrze.';

  @override
  String get checklistOpeningAndShadingPreparation =>
      'Uzgodnij otwory pod okna i osłony';

  @override
  String get checklistOpeningAndShadingPreparationRisk =>
      'Brak detalu rolety lub żaluzji przed nadprożem może wymusić mostek cieplny albo przeróbkę konstrukcji.';

  @override
  String get checklistShellSafetyAndAccess =>
      'Zabezpiecz otwory, schody i komunikację';

  @override
  String get checklistShellSafetyAndAccessRisk =>
      'Niezabezpieczone krawędzie, otwory i tymczasowe schody są bezpośrednim ryzykiem wypadku.';

  @override
  String get checklistWindowDoorAcceptance =>
      'Odbierz montaż okien i drzwi zewnętrznych';

  @override
  String get checklistWindowDoorAcceptanceRisk =>
      'Brak podparcia, mocowania lub ciągłości uszczelnienia powoduje nieszczelności i problemy z użytkowaniem.';

  @override
  String get checklistWeatherTightnessAndMoisture =>
      'Sprawdź szczelność budynku i wilgoć';

  @override
  String get checklistWeatherTightnessAndMoistureRisk =>
      'Zakrycie przecieków lub mokrych przegród utrwala zawilgocenie, pleśń i odspojenia wykończenia.';

  @override
  String get checklistTemporaryVentilationAndHeating =>
      'Ustal wietrzenie, osuszanie i ogrzewanie technologiczne';

  @override
  String get checklistTemporaryVentilationAndHeatingRisk =>
      'Nieprawidłowe suszenie lub wychłodzenie może uszkodzić świeże warstwy i materiały.';

  @override
  String get checklistInstallationCoordination =>
      'Skoordynuj wszystkie trasy instalacji';

  @override
  String get checklistInstallationCoordinationRisk =>
      'Brak wspólnego planu prowadzi do kolizji, kucia i przypadkowego osłabiania konstrukcji.';

  @override
  String get checklistElectricalInstallationRoutes =>
      'Wykonaj i sprawdź trasy elektryczne';

  @override
  String get checklistElectricalInstallationRoutesRisk =>
      'Błędne trasy, brak ochrony lub niewłaściwe przepusty mogą uniemożliwić bezpieczny odbiór instalacji.';

  @override
  String get checklistWaterSewerHeatingRoutes =>
      'Wykonaj trasy wody, kanalizacji i ogrzewania';

  @override
  String get checklistWaterSewerHeatingRoutesRisk =>
      'Brak spadków, rewizji, izolacji lub dostępu serwisowego często oznacza kucie po wykończeniu.';

  @override
  String get checklistVentilationAndLowVoltageRoutes =>
      'Wykonaj wentylację i teletechnikę';

  @override
  String get checklistVentilationAndLowVoltageRoutesRisk =>
      'Zgniecione kanały, brak izolacji lub rezerw ograniczy działanie wentylacji i późniejszą rozbudowę.';

  @override
  String get checklistInstallationTests => 'Wykonaj próby i pomiary instalacji';

  @override
  String get checklistInstallationTestsRisk =>
      'Zakrycie instalacji bez protokołu utrudnia wykrycie nieszczelności, błędów ochrony i wad działania.';

  @override
  String get checklistConcealedInstallationPhotos =>
      'Zapisz zdjęcia instalacji przed zakryciem';

  @override
  String get checklistConcealedInstallationPhotosRisk =>
      'Bez zdjęć z miarą późniejsze wiercenie, serwis i znalezienie trasy są obarczone zgadywaniem.';

  @override
  String get checklistSubstrateInspection =>
      'Sprawdź podłoża przed tynkami i wylewkami';

  @override
  String get checklistSubstrateInspectionRisk =>
      'Wilgotne, słabe lub zabrudzone podłoże może spowodować pękanie i odspajanie warstw.';

  @override
  String get checklistPlasterAndScreedExecution =>
      'Wykonaj tynki i wylewki według technologii';

  @override
  String get checklistPlasterAndScreedExecutionRisk =>
      'Zła temperatura, pielęgnacja lub dylatacje zwiększają ryzyko pęknięć i nierówności.';

  @override
  String get checklistFloorHeatingCommissioning =>
      'Wykonaj próbę i wygrzewanie ogrzewania podłogowego';

  @override
  String get checklistFloorHeatingCommissioningRisk =>
      'Brak próby przed wylewką ukrywa nieszczelność, a brak wygrzewania może uszkodzić późniejszą podłogę.';

  @override
  String get checklistPlasterScreedAcceptance =>
      'Odbierz równość, wilgotność i dylatacje';

  @override
  String get checklistPlasterScreedAcceptanceRisk =>
      'Wykończenie na nieodebranym podłożu przenosi wady na płytki, panele i farby.';

  @override
  String get checklistWetAreaWaterproofing =>
      'Wykonaj hydroizolację pomieszczeń mokrych';

  @override
  String get checklistWetAreaWaterproofingRisk =>
      'Płytki i fuga nie zastępują systemowej hydroizolacji, a nieszczelne detale mogą uszkodzić przegrody.';

  @override
  String get checklistFinishMaterialsAndSamples =>
      'Zatwierdź materiały, próbki i układy';

  @override
  String get checklistFinishMaterialsAndSamplesRisk =>
      'Brak próbki i zatwierdzonego układu kończy się różnicami koloru, formatu lub zakresu dostawy.';

  @override
  String get checklistFloorsWallsCeilings =>
      'Wykonaj i odbierz podłogi, ściany oraz sufity';

  @override
  String get checklistFloorsWallsCeilingsRisk =>
      'Nieodebrane powierzchnie mogą mieć wady widoczne dopiero po montażu wyposażenia i oświetlenia.';

  @override
  String get checklistJoineryAndPainting =>
      'Zamontuj stolarkę wewnętrzną i wykonaj malowanie';

  @override
  String get checklistJoineryAndPaintingRisk =>
      'Brak ochrony i kolejności robót zwiększa ryzyko uszkodzeń, zabrudzeń i poprawek.';

  @override
  String get checklistSystemsCommissioning => 'Uruchom i wyreguluj urządzenia';

  @override
  String get checklistSystemsCommissioningRisk =>
      'Bez uruchomienia i regulacji ogrzewanie, wentylacja, alarm lub automatyka mogą nie działać zgodnie z założeniami.';

  @override
  String get checklistWarrantiesAndManuals =>
      'Zbierz gwarancje, instrukcje i karty serwisowe';

  @override
  String get checklistWarrantiesAndManualsRisk =>
      'Brak dokumentów utrudnia serwis, reklamację i późniejszą bezpieczną obsługę urządzeń.';

  @override
  String get checklistAsBuiltDocumentation =>
      'Skompletuj dokumentację powykonawczą';

  @override
  String get checklistAsBuiltDocumentationRisk =>
      'Nieaktualna dokumentacja utrudnia odbiór, serwis i potwierdzenie zgodności wykonania.';

  @override
  String get checklistAsBuiltSurvey =>
      'Zleć geodezyjną inwentaryzację powykonawczą';

  @override
  String get checklistAsBuiltSurveyRisk =>
      'Brak inwentaryzacji może zablokować prawidłowe zakończenie procesu i ujawnić błędne położenie sieci lub obiektu.';

  @override
  String get checklistTestsCertificates =>
      'Zbierz protokoły prób, pomiarów i certyfikaty';

  @override
  String get checklistTestsCertificatesRisk =>
      'Bez protokołów trudno potwierdzić bezpieczeństwo i poprawne uruchomienie instalacji.';

  @override
  String get checklistConstructionCompletionNotice =>
      'Zweryfikuj tryb zakończenia budowy i użytkowania';

  @override
  String get checklistConstructionCompletionNoticeRisk =>
      'Przystąpienie do użytkowania bez właściwego zawiadomienia lub pozwolenia może naruszać procedurę budowlaną.';

  @override
  String get checklistDefectsAndHandover =>
      'Zamknij listę usterek i przekazanie domu';

  @override
  String get checklistDefectsAndHandoverRisk =>
      'Brak protokołu odbioru, terminów i odpowiedzialności utrudnia egzekwowanie poprawek.';

  @override
  String get guidancePlanningScopeAndSurveyTitle =>
      'Zakres remontu i stan istniejący';

  @override
  String get guidancePlanningScopeAndSurveyTiming =>
      'Przed zamówieniem ofert, materiałów i pierwszych prac';

  @override
  String get guidancePlanningScopeAndSurveySummary =>
      'W remoncie zacznij od inwentaryzacji, zakresu i budżetu, a nie od przypadkowego zakupu materiałów. Ustal, które ściany, instalacje i elementy są istniejące, a które mają zostać zmienione; w budynku wielorodzinnym sprawdź zasady zarządcy i części wspólne.';

  @override
  String get guidancePlanningScopeAndSurveyChecks =>
      'Zapisz pomiary, zdjęcia, istniejące uszkodzenia, trasy instalacji i miejsca wymagające odkrywek.\nPodziel zakres na roboty konieczne, warianty i wyposażenie; dodaj rezerwę budżetową oraz terminy decyzji.\nSprawdź, czy zmiana układu, instalacji, elewacji, wentylacji lub elementów konstrukcyjnych wymaga projektanta, zgody właściciela albo zarządcy.\nZbierz próbki i karty techniczne materiałów, zanim wykonawca wyceni rozwiązanie.\nUtwórz jedną wersję rysunków, ustaleń i zdjęć dla ekip.';

  @override
  String get guidancePlanningScopeAndSurveyQuestions =>
      'Czy zakres obejmuje także demontaż, wywóz, zabezpieczenia i odtworzenie?\nCzy znamy przebieg instalacji, grubości przegród i stan podłoży?\nCzy planowana zmiana dotyka konstrukcji, części wspólnych, elewacji lub dróg ewakuacji?\nKto zatwierdza każdą zmianę przed wykonaniem?';

  @override
  String get guidanceDemolitionSafetyAndUtilitiesTitle =>
      'Rozbiórka bez niespodzianek';

  @override
  String get guidanceDemolitionSafetyAndUtilitiesTiming =>
      'Przed pierwszym skuciem, cięciem lub demontażem';

  @override
  String get guidanceDemolitionSafetyAndUtilitiesSummary =>
      'Rozbiórkę planuj od rozpoznania zagrożeń i odłączenia mediów. Nie zakładaj, że ściana jest działowa, a instalacja nieczynna; elementy konstrukcyjne, materiały zawierające azbest i instalacje wymagają właściwej oceny oraz fachowego wykonania.';

  @override
  String get guidanceDemolitionSafetyAndUtilitiesChecks =>
      'Potwierdź z projektantem lub kierownikiem, które elementy są nośne i w jakiej kolejności można je usuwać.\nZidentyfikuj azbest, szkło, stare izolacje, pyły, substancje niebezpieczne i miejsca o podwyższonym ryzyku.\nOdłącz, sprawdź i zabezpiecz prąd, gaz, wodę, ogrzewanie, kanalizację oraz teletechnikę.\nZabezpiecz sąsiadów, części wspólne, okna, drzwi, wentylację i drogi ewakuacji przed pyłem i gruzem.\nUstal segregację, transport i legalne przekazanie odpadów; po rozbiórce wykonaj odbiór odkrytych podłoży i instalacji.';

  @override
  String get guidanceDemolitionSafetyAndUtilitiesQuestions =>
      'Kto potwierdzi odłączenie każdej instalacji?\nCzy w budynku występują materiały wymagające specjalistycznego usunięcia?\nCzy rozbiórka może zmienić stateczność lub ochronę przeciwpożarową?\nJak udokumentujemy stan sąsiadujących lokali i części wspólnych przed pracą?';

  @override
  String get guidancePlasterAndScreedExecutionTitle =>
      'Tynki, wylewki i dojrzewanie';

  @override
  String get guidancePlasterAndScreedExecutionTiming =>
      'Po próbach instalacji, przed montażem podłóg i szczelną zabudową';

  @override
  String get guidancePlasterAndScreedExecutionSummary =>
      'Tynki i wylewki wykonuj dopiero po zamknięciu tras oraz udokumentowaniu prób. O wyniku decydują rodzaj podłoża, materiał, warunki w pomieszczeniu, dylatacje i czas dojrzewania, a nie jedna uniwersalna recepta.';

  @override
  String get guidancePlasterAndScreedExecutionChecks =>
      'Sprawdź nośność, czystość, wilgotność i przygotowanie podłoża zgodnie z kartą systemu.\nPrzed wylewką potwierdź próby ogrzewania podłogowego, oznaczenie pętli, osłony rur i taśmy brzegowe.\nZachowaj dylatacje konstrukcyjne i zaprojektuj podział pól zgodnie z pomieszczeniami, ogrzewaniem i okładziną.\nUstal temperaturę, wentylację, ochronę przed przeciągiem, mrozem i zbyt szybkim wysychaniem.\nPo dojrzewaniu zmierz równość i wilgotność metodą wymaganą przez planowaną podłogę.';

  @override
  String get guidancePlasterAndScreedExecutionQuestions =>
      'Czy każda warstwa ma kartę techniczną i wymagany czas dojrzewania?\nCzy przejścia i dylatacje są zgodne z projektem podłóg?\nCzy protokół ogrzewania podłogowego jest kompletny przed wylewką?\nJakie kryteria odbioru przyjmujemy dla równości, wilgotności i spękań?';

  @override
  String get guidanceHandoverAndOccupancyTitle =>
      'Dokumenty, odbiór i użytkowanie';

  @override
  String get guidanceHandoverAndOccupancyTiming =>
      'Przed przekazaniem domu i przed rozpoczęciem użytkowania';

  @override
  String get guidanceHandoverAndOccupancySummary =>
      'Odbiór to nie tylko oględziny pomieszczeń. Zamknij dokumentację powykonawczą, geodezję, protokoły, instrukcje, listę usterek i właściwą procedurę zakończenia lub użytkowania. Dla remontu zakres formalny może być inny niż dla budowy domu, więc potwierdź go dla konkretnej inwestycji.';

  @override
  String get guidanceHandoverAndOccupancyChecks =>
      'Zbierz aktualny projekt, zmiany zaakceptowane przez właściwe osoby, zdjęcia robót zakrytych i dokumentację powykonawczą.\nDołącz geodezyjną inwentaryzację powykonawczą, jeżeli wynika z zakresu inwestycji i przepisów.\nSkompletuj protokoły instalacji, prób, pomiarów, uruchomień, kominiarskie i inne wymagane dla obiektu.\nSprawdź z kierownikiem lub urzędem, czy potrzebne jest zawiadomienie o zakończeniu budowy czy pozwolenie na użytkowanie; nie przenoś tej procedury automatycznie na zwykły remont.\nPodpisz protokół przekazania z listą usterek, terminami, gwarancjami, instrukcjami i stanami liczników.';

  @override
  String get guidanceHandoverAndOccupancyQuestions =>
      'Jaki tryb zakończenia i użytkowania dotyczy tej inwestycji?\nCzy dokumentacja powykonawcza pokazuje rzeczywiste trasy i zmiany?\nCzy wszystkie próby, pomiary i uruchomienia mają podpisane protokoły?\nKto i do kiedy usuwa każdą usterkę z protokołu przekazania?';

  @override
  String get guidancePlanningAndGroundConditionsTitle =>
      'Plan miejscowy, mapa i grunt';

  @override
  String get guidancePlanningAndGroundConditionsTiming =>
      'Przed ostatecznym wyborem lub adaptacją projektu i posadowienia';

  @override
  String get guidancePlanningAndGroundConditionsSummary =>
      'Najpierw potwierdź w gminie aktualną podstawę planistyczną dla działki: MPZP albo potrzebę uzyskania WZ. Mapa i wyniki rozpoznania gruntu powinny trafić do projektanta adaptującego i konstruktora, zanim zaprojektują płytę, ławy albo inne posadowienie. Kierownik budowy realizuje zatwierdzony projekt, nie zastępuje projektanta konstrukcji.';

  @override
  String get guidancePlanningAndGroundConditionsChecks =>
      'Pobierz aktualne ustalenia MPZP albo potwierdź tryb uzyskania WZ i wymagane załączniki.\nSprawdź tytuł prawny, dostęp do drogi oraz ograniczenia widoczne w dokumentach działki.\nZleć mapę do celów projektowych uprawnionemu geodecie.\nUzgodnij z projektantem zakres rozpoznania geotechnicznego i przekaż wyniki projektantowi konstrukcji przed doborem posadowienia.\nPrzed robotami ziemnymi przekaż kierownikowi zatwierdzony projekt i opinię geotechniczną; rozbieżności ujawnione w wykopie konsultuj z projektantem przed dalszymi pracami.';

  @override
  String get guidancePlanningAndGroundConditionsQuestions =>
      'Czy urząd potwierdził aktualną ścieżkę planistyczną dla tej działki?\nCzy mapa obejmuje potrzebny teren i uzbrojenie?\nCzy projektant konstrukcji otrzymał wyniki badań przed doborem płyty, ław lub innego posadowienia?\nCo zrobić, jeśli warunki w wykopie różnią się od rozpoznanych?';

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
      'Tymczasowe ogrodzenie, szeroka brama dla pojazdów, utwardzony wjazd oraz bezpiecznie ustawiony blaszak lub kontener tworzą podstawę sprawnej logistyki. Wymiary przejazdu i nośność trasy dobierz do rzeczywistego ciężkiego sprzętu, nie do jednej uniwersalnej liczby.';

  @override
  String get guidanceSiteLogisticsAndAccessChecks =>
      'Zabezpiecz teren tymczasowym ogrodzeniem o wysokości co najmniej 1,5 m albo innym rozwiązaniem dopuszczonym przez przepisy, gdy ogrodzenie nie jest możliwe.\nZaplanuj szeroką bramę dla pojazdów oraz osobne, bezpieczne wejście piesze.\nUzgodnij szerokość, wysokość przejazdu, promień skrętu i nośność utwardzonego wjazdu z dostawcą betonu, pompą, HDS-em i innym planowanym sprzętem.\nSprawdź uzbrojenie podziemne, odwodnienie oraz formalności istniejącego lub tymczasowego zjazdu z drogi.\nUstaw blaszak lub kontener na stabilnym podłożu, poza drogami transportowymi, wykopem i strefami niebezpiecznymi; zapewnij zamknięcie i wentylację.\nPrzed ustawieniem zaplecza potwierdź z projektantem lub urzędem, czy sposób i czas użytkowania wymagają dodatkowej formalności.';

  @override
  String get guidanceSiteLogisticsAndAccessQuestions =>
      'Czy betoniarka, pompa, HDS lub dźwig wjadą i wyjadą bez cofania w niebezpieczną strefę?\nCzy podłoże wytrzyma ruch po deszczu i umożliwi oczyszczenie kół przed wyjazdem?\nCzy brama, blaszak i składowiska nie kolidują z przyłączami ani docelowym zagospodarowaniem?\nKto codziennie sprawdza ogrodzenie, zamknięcie bramy i porządek dróg?';

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
  String get guidanceStructuralShellChecksTitle =>
      'Konstrukcja przed betonem i zakryciem';

  @override
  String get guidanceStructuralShellChecksTiming =>
      'Przed każdym betonowaniem, zakryciem połączeń i usunięciem podpór';

  @override
  String get guidanceStructuralShellChecksSummary =>
      'Odbieraj elementy konstrukcyjne według projektu przed ich zakryciem. Nie istnieje jedna liczba dni, po której zawsze wolno rozszalować strop: decydują projekt, technologia, warunki dojrzewania i osiągnięta wytrzymałość.';

  @override
  String get guidanceStructuralShellChecksChecks =>
      'Sprawdź zbrojenie, otuliny, deskowanie, przepusty, kotwy i elementy osadzane przed betonowaniem.\nPorównaj z projektem geometrię ścian, stropów, otworów, nadproży, wieńców, schodów i konstrukcji dachu.\nPotwierdź stateczność tymczasową, stężenia i sposób podparcia; nie zmieniaj otworów ani elementów nośnych bez projektanta.\nZabezpiecz świeży beton i mur zgodnie z projektem, pogodą i instrukcją zastosowanej technologii.\nZapisz odbiór robót zanikających i wykonaj zdjęcia z miarą przed zakryciem.';

  @override
  String get guidanceStructuralShellChecksQuestions =>
      'Czy kierownik odebrał element przed betonowaniem lub zakryciem?\nCzy wszystkie otwory i przepusty są zgodne ze skoordynowanymi projektami branżowymi?\nNa jakiej podstawie ustalono termin usunięcia podpór?\nCzy zmiana wykonawcza ma akceptację właściwego projektanta?';

  @override
  String get guidanceRoofAndWeatherProtectionTitle =>
      'Dach i ochrona stanu otwartego przed wodą';

  @override
  String get guidanceRoofAndWeatherProtectionTiming =>
      'Przed pierwszym opadem i przed zakryciem każdej warstwy dachu';

  @override
  String get guidanceRoofAndWeatherProtectionSummary =>
      'Pokrycie jest częścią zaprojektowanego przekrycia dachowego. Szczelność zależy także od podłoża, warstwy wstępnego krycia, obróbek, przejść, odwodnienia i montażu zgodnego z wybranym systemem.';

  @override
  String get guidanceRoofAndWeatherProtectionChecks =>
      'Sprawdź podłoże, spadki, warstwę wstępnego krycia i wymagane szczeliny wentylacyjne przed pokryciem.\nOdbierz obróbki kominów, okien dachowych, koszy, kalenicy, okapu i wszystkich przejść instalacyjnych.\nZapewnij drożne odwodnienie oraz kontrolowany odpływ z dala od niezabezpieczonych ścian i fundamentów.\nZabezpieczaj tymczasowo otwory i przerwane roboty przed opadem oraz silnym wiatrem.\nUdokumentuj warstwy ukryte i użyte materiały przed ich zakryciem.';

  @override
  String get guidanceRoofAndWeatherProtectionQuestions =>
      'Czy detal każdego przejścia pochodzi z projektu i instrukcji wybranego systemu?\nDokąd odpłynie woda podczas budowy i po wykonaniu rynien?\nCzy połączenia będą dostępne do kontroli przed ociepleniem lub zabudową?\nKto odbiera pokrycie i obróbki przed zamknięciem kolejnych warstw?';

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
  String get guidanceWindowDoorInstallationTitle =>
      'Stolarka: podparcie, mocowanie i szczelność';

  @override
  String get guidanceWindowDoorInstallationTiming =>
      'Przed zamówieniem stolarki, montażem i zakryciem złączy';

  @override
  String get guidanceWindowDoorInstallationSummary =>
      'Potwierdź parametry wyrobu oraz indywidualny detal montażu do muru, progu i elewacji. Sama piana nie zastępuje mechanicznego mocowania ani kompletnego uszczelnienia zaprojektowanego połączenia.';

  @override
  String get guidanceWindowDoorInstallationChecks =>
      'Zmierz otwory i potwierdź poziomy gotowych posadzek, parapetów, progów, rolet i elewacji przed zamówieniem.\nDobierz położenie, podparcie, łączniki i uszczelnienie do projektu, rodzaju muru oraz instrukcji producenta stolarki i systemu montażowego.\nSprawdź mechaniczne mocowanie, stabilne podparcie, ciągłość uszczelnień i zabezpieczenie piany przed wilgocią oraz promieniowaniem UV.\nZachowaj drożność odwodnień profili, parapetów i progów; sprawdź spadki oraz zakończenia.\nPrzed zakryciem złączy sprawdź działanie skrzydeł, okucia, uszkodzenia i wykonaj zdjęcia detali.';

  @override
  String get guidanceWindowDoorInstallationQuestions =>
      'Czy zamówienie podaje uzgodnione właściwości i wymiary każdego wyrobu?\nKto przygotował detal mocowania i uszczelnienia dla tego muru oraz progu?\nCzy rolety, parapety i ocieplenie nie przerwą ciągłości połączenia?\nCzy złącze można jeszcze odebrać przed jego zakryciem?';

  @override
  String get guidanceClosedShellMoistureControlTitle =>
      'Zamknięty budynek bez uwięzionej wilgoci';

  @override
  String get guidanceClosedShellMoistureControlTiming =>
      'Po montażu stolarki, przed tynkami, wylewkami i szczelną zabudową';

  @override
  String get guidanceClosedShellMoistureControlSummary =>
      'Po zamknięciu budynku woda opadowa i wilgoć technologiczna nie mogą pozostać bez kontroli. Zapewnij szczelność zewnętrzną, odpływ wody oraz planowane wietrzenie, osuszanie i ogrzewanie zgodne z technologią robót.';

  @override
  String get guidanceClosedShellMoistureControlChecks =>
      'Sprawdź dach, obróbki, rynny, parapety, progi i przejścia po opadzie, zanim połączenia zostaną zabudowane.\nUsuń źródła przecieków oraz wodę stojącą; nie przykrywaj zawilgoconych przegród.\nUstal kontrolowane wietrzenie lub osuszanie podczas mokrych robót i zapisuj warunki wymagane przez materiały.\nChroń budynek przed niekontrolowanym wychłodzeniem, kondensacją i zamarzaniem świeżych warstw.\nJeżeli wymaga tego projekt, umowa lub standard energetyczny, zaplanuj badanie szczelności przed końcowym zakryciem złączy.';

  @override
  String get guidanceClosedShellMoistureControlQuestions =>
      'Czy po deszczu widać przecieki albo wodę w progach i narożach?\nJak będzie usuwana wilgoć z tynków i wylewek?\nKtóre połączenia trzeba sprawdzić przed ich zabudową?\nCzy badanie szczelności jest wymagane i na jakim etapie będzie najbardziej użyteczne?';

  @override
  String get guidanceInstallationRoutesAndAccessTitle =>
      'Koordynacja tras i dostęp serwisowy';

  @override
  String get guidanceInstallationRoutesAndAccessTiming =>
      'Przed bruzdowaniem, przewiertami, zabudową i wykonaniem posadzek';

  @override
  String get guidanceInstallationRoutesAndAccessSummary =>
      'Elektrykę, wodę, kanalizację, ogrzewanie, wentylację, internet, alarm, PV i automatykę sprawdź na jednym skoordynowanym planie. Kolizje rozwiązuj przed wykonaniem, a nie przez przypadkowe osłabianie konstrukcji.';

  @override
  String get guidanceInstallationRoutesAndAccessChecks =>
      'Uzgodnij trasy, poziomy, przejścia, strefy montażowe i odpowiedzialność każdej branży.\nNie wykonuj bruzd ani przewiertów w elementach konstrukcyjnych bez zgody właściwego projektanta.\nSprawdź rozdział instalacji, izolacje, spadki kanalizacji oraz ochronę przewodów w miejscach skrzyżowań i przejść.\nZapewnij dostęp do rozdzielaczy, zaworów, filtrów, syfonów, rewizji, urządzeń i elementów wymagających czyszczenia.\nPrzed zakryciem sfotografuj trasy z miarą i odniesieniem do stałych krawędzi pomieszczeń.';

  @override
  String get guidanceInstallationRoutesAndAccessQuestions =>
      'Czy wszystkie branże pracują na aktualnej, wspólnej wersji rysunków?\nKtóre elementy muszą pozostać dostępne po wykończeniu?\nCzy przewiert lub bruzda ma akceptację konstruktora, jeśli dotyka elementu nośnego?\nCzy zdjęcia pozwolą później bezpiecznie wiercić i serwisować instalacje?';

  @override
  String get guidanceInstallationTestsAndEvidenceTitle =>
      'Próby i pomiary przed zakryciem';

  @override
  String get guidanceInstallationTestsAndEvidenceTiming =>
      'Po wykonaniu instalacji, zanim przykryją ją tynk, wylewka, izolacja lub zabudowa';

  @override
  String get guidanceInstallationTestsAndEvidenceSummary =>
      'Każda branża ma własny zakres prób i kryteria odbioru. Nie stosuj jednego internetowego ciśnienia ani czasu do wszystkich systemów: parametry wynikają z projektu, normy właściwej dla instalacji i instrukcji użytego systemu.';

  @override
  String get guidanceInstallationTestsAndEvidenceChecks =>
      'Wykonaj i zapisz właściwe próby szczelności instalacji wodnych, kanalizacyjnych, grzewczych i innych przewodów przed zakryciem.\nZleć osobie z wymaganymi kwalifikacjami oględziny, próby i pomiary instalacji elektrycznej wraz z protokołem.\nSprawdź obiegi ogrzewania płaszczyznowego przed wylewką, oznacz pętle i zachowaj wymagane ciśnienie robocze lub kontrolne zgodnie z systemem.\nSprawdź wentylację przed zabudową: drożność, mocowanie, izolację, dostęp do czyszczenia, a przy odbiorze także wymagane pomiary.\nDołącz zdjęcia, wyniki, datę, użyte urządzenie pomiarowe i podpis odpowiedzialnej osoby.';

  @override
  String get guidanceInstallationTestsAndEvidenceQuestions =>
      'Jaki dokument określa parametry próby dla tej konkretnej instalacji?\nKto ma uprawnienia lub kwalifikacje do wykonania i podpisania pomiarów?\nCzy wynik zapisano przed zakryciem oraz powiązano z właściwym obiegiem lub pomieszczeniem?\nCzy usterkę usunięto i próbę powtórzono po naprawie?';

  @override
  String get guidanceFinishSubstratesAndHeatingTitle =>
      'Podłoże gotowe przed wykończeniem';

  @override
  String get guidanceFinishSubstratesAndHeatingTiming =>
      'Przed gruntowaniem, malowaniem, klejeniem płytek i układaniem podłóg';

  @override
  String get guidanceFinishSubstratesAndHeatingSummary =>
      'Nośność, równość, czystość i wilgotność podłoża sprawdzaj metodą oraz limitem wymaganym przez konkretny podkład, klej i okładzinę. Jedna wartość procentowa nie jest poprawna dla wszystkich materiałów i metod pomiaru.';

  @override
  String get guidanceFinishSubstratesAndHeatingChecks =>
      'Zidentyfikuj rodzaj podłoża i sprawdź jego nośność, spękania, równość, czystość oraz warunki powierzchniowe.\nZapisz pomiar wilgotności z datą, miejscem, metodą i rodzajem podkładu; porównaj wynik z wymaganiem wybranego systemu.\nPrzed montażem podłogi wykonaj wymagane uruchomienie lub wygrzewanie ogrzewania podłogowego i zachowaj protokół.\nPrzenieś przewidziane dylatacje oraz sprawdź ich zgodność z układem pomieszczeń, ogrzewaniem i formatem okładziny.\nZapewnij temperaturę, wentylację i czas dojrzewania warstw zgodne z kartami technicznymi.';

  @override
  String get guidanceFinishSubstratesAndHeatingQuestions =>
      'Jaką metodą zmierzono wilgotność i jaki limit podaje producent systemu?\nCzy podłoże ma pęknięcia lub dylatacje wymagające rozwiązania przed okładziną?\nCzy istnieje podpisany protokół uruchomienia ogrzewania podłogowego?\nCzy warunki w pomieszczeniu pozwalają na wykonanie i dojrzewanie wybranych materiałów?';

  @override
  String get guidanceWetAreaWaterproofingTitle =>
      'Pomieszczenie mokre jako kompletny system';

  @override
  String get guidanceWetAreaWaterproofingTiming =>
      'Przed klejeniem płytek i zakryciem narożników, odpływów oraz przejść';

  @override
  String get guidanceWetAreaWaterproofingSummary =>
      'Płytki i fuga nie są samodzielną hydroizolacją. Dobierz kompletny, kompatybilny system do podłoża i przewidywanego obciążenia wodą; sama nazwa „folia w płynie” nie potwierdza przydatności w każdym miejscu.';

  @override
  String get guidanceWetAreaWaterproofingChecks =>
      'Określ strefy narażone na wodę, rodzaj podłoża, ogrzewanie i wymagany zakres hydroizolacji.\nSprawdź deklarowane zastosowanie wyrobu, przygotowanie podłoża, wymaganą liczbę warstw, zużycie i czas schnięcia.\nWykonaj systemowe uszczelnienia narożników, dylatacji, odpływów, progów i wszystkich przejść instalacyjnych.\nUżyj kompatybilnych gruntów, taśm, manszet, hydroizolacji, kleju i fugi bez mieszania przypadkowych systemów.\nOdbierz i sfotografuj ciągłość izolacji przed ułożeniem płytek; wymagane próby wykonaj zgodnie z projektem i systemem.';

  @override
  String get guidanceWetAreaWaterproofingQuestions =>
      'Jakie obciążenie wodą przewidziano w tej strefie?\nCzy produkt jest przeznaczony pod płytki i zgodny z podłożem oraz ogrzewaniem?\nJak rozwiązano odpływ, spadki, narożniki i przejścia rurowe?\nKto odbierze hydroizolację przed jej zakryciem?';

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
  String get budgetReportBasePlanLabel => 'Plan bazowy';

  @override
  String get budgetReportDecisionDeltaLabel => 'Zatwierdzone zmiany';

  @override
  String get budgetReportAdjustedPlanLabel => 'Plan po zmianach';

  @override
  String get budgetReportDecisionImpactHeading => 'Wpływ decyzji';

  @override
  String budgetReportDecisionImpactMessage(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zatwierdzonych decyzji',
      many: '$count zatwierdzonych decyzji',
      few: '$count zatwierdzone decyzje',
      one: '1 zatwierdzona decyzja',
    );
    return '$_temp0 · termin $days dni';
  }

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
  String get budgetReportDimensionComponent => 'Skład kosztu';

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
      'Dane pozostają lokalne do chwili eksportu. Kopia ZIP nie jest szyfrowana i może zawierać dokumenty, kontakty oraz zdjęcia, dlatego zapisz ją w zaufanym miejscu.';

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

  @override
  String get captureInboxTitle => 'Skrzynka szybkich zapisów';

  @override
  String captureInboxOpenTab(int count) {
    return 'Otwarte ($count)';
  }

  @override
  String captureInboxHistoryTab(int count) {
    return 'Historia ($count)';
  }

  @override
  String get captureInboxNoProjectTitle => 'Wybierz projekt';

  @override
  String get captureInboxNoProjectMessage =>
      'Szybkie zapisy są zawsze przypisane do konkretnej budowy lub remontu.';

  @override
  String get captureInboxEmptyTitle => 'Skrzynka jest pusta';

  @override
  String get captureInboxEmptyMessage =>
      'Dodaj zdjęcie, dokument, notatkę, koszt lub zadanie przyciskiem plus.';

  @override
  String get captureInboxHistoryEmptyTitle => 'Brak uporządkowanych zapisów';

  @override
  String get captureInboxHistoryEmptyMessage =>
      'Tutaj pojawią się pozycje po zatwierdzeniu.';

  @override
  String get captureInboxLoadError => 'Nie udało się wczytać skrzynki.';

  @override
  String get captureAddTooltip => 'Dodaj szybki zapis';

  @override
  String get captureAddTitle => 'Co chcesz zapisać?';

  @override
  String get captureLoadMoreAction => 'Wczytaj kolejne';

  @override
  String get captureLoadingMore => 'Wczytywanie…';

  @override
  String get captureTypeReceiptInvoice => 'Paragon lub faktura';

  @override
  String get captureTypeAll => 'Wszystkie';

  @override
  String get captureTypePhoto => 'Zdjęcie';

  @override
  String get captureTypeDocument => 'Dokument';

  @override
  String get captureTypeNote => 'Notatka';

  @override
  String get captureTypeVoice => 'Nagranie';

  @override
  String get captureTypeCost => 'Koszt';

  @override
  String get captureTypeTask => 'Zadanie';

  @override
  String get captureTypeDecision => 'Decyzja';

  @override
  String get captureTypeDefect => 'Usterka';

  @override
  String get captureStatusReady => 'Gotowe do zatwierdzenia';

  @override
  String get captureStatusNeedsReview => 'Wymaga uzupełnienia';

  @override
  String get captureStatusClassified => 'Uporządkowane';

  @override
  String captureMissingFields(String fields) {
    return 'Uzupełnij: $fields';
  }

  @override
  String get captureMissingTitle => 'tytuł';

  @override
  String get captureMissingContent => 'opis';

  @override
  String get captureMissingAttachment => 'plik';

  @override
  String get captureMissingGrossAmount => 'kwotę brutto';

  @override
  String get captureMissingVatRate => 'stawkę VAT';

  @override
  String get captureMissingScheduledAt => 'termin';

  @override
  String get captureEditTooltip => 'Uzupełnij lub popraw';

  @override
  String get captureApproveTooltip => 'Zatwierdź i przypisz';

  @override
  String get captureMergeTooltip => 'Połącz podobne zapisy';

  @override
  String get captureRejectTooltip => 'Odrzuć zapis';

  @override
  String get captureRejectTitle => 'Odrzucić szybki zapis?';

  @override
  String get captureRejectMessage =>
      'Niepowiązany plik lokalny także zostanie usunięty. Tej operacji nie można cofnąć.';

  @override
  String get captureMergeTitle => 'Połącz z podobnym zapisem';

  @override
  String get captureMergeEmpty => 'Brak innego otwartego zapisu tego typu.';

  @override
  String get captureEditorNewTitle => 'Nowy szybki zapis';

  @override
  String get captureEditorEditTitle => 'Uzupełnij zapis';

  @override
  String get captureTitleLabel => 'Tytuł';

  @override
  String get captureContentLabel => 'Opis lub ustalenia';

  @override
  String captureGrossAmountLabel(String currencyCode) {
    return 'Kwota brutto ($currencyCode)';
  }

  @override
  String get captureVatRateLabel => 'VAT';

  @override
  String get captureDateLabel => 'Data';

  @override
  String get captureTimeLabel => 'Godzina';

  @override
  String get captureChooseDateAction => 'Wybierz datę';

  @override
  String get captureChooseTimeAction => 'Wybierz godzinę';

  @override
  String get captureSaveDraftAction => 'Zapisz w skrzynce';

  @override
  String get captureUpdateAction => 'Zapisz zmiany';

  @override
  String get captureValidationTitle => 'Uzupełnij wymagane pola';

  @override
  String get captureValidationMessage =>
      'Zapis może pozostać niekompletny, ale tytuł ułatwi jego późniejsze odnalezienie.';

  @override
  String get captureActionError => 'Nie udało się wykonać operacji.';

  @override
  String get capturePickCancelled => 'Nie wybrano pliku.';

  @override
  String get captureClassifiedDocument => 'Dokumentacja';

  @override
  String get captureClassifiedCost => 'Szkic kosztu';

  @override
  String get captureClassifiedTask => 'Harmonogram';

  @override
  String get captureClassifiedNote => 'Notatka';

  @override
  String get captureClassifiedDecision => 'Decyzja';

  @override
  String get captureClassifiedDefect => 'Usterka';

  @override
  String get captureCostDraftNotice =>
      'Po zatwierdzeniu powstanie szkic kosztu. Suma budowy zmieni się dopiero po jego potwierdzeniu.';

  @override
  String get captureVoiceNotice =>
      'Nagranie zostanie zachowane lokalnie. Transkrypcja nie jest wymagana.';

  @override
  String get captureFileNotice =>
      'Plik jest kopiowany do prywatnej pamięci projektu.';

  @override
  String get captureSavedMessage => 'Zapis dodano do skrzynki.';

  @override
  String get captureApprovedMessage => 'Zapis został uporządkowany.';

  @override
  String get legalCenterTitle => 'Prywatność i prawo';

  @override
  String get legalCenterTileSubtitle => 'Polityka, warunki i kontrola danych';

  @override
  String get legalDocumentsSection => 'Dokumenty i ustawienia';

  @override
  String get privacyPolicyTitle => 'Polityka prywatności';

  @override
  String get privacyPolicyTileSubtitle =>
      'Jak aplikacja przechowuje i przetwarza dane';

  @override
  String get termsOfUseTitle => 'Warunki użytkowania';

  @override
  String get termsOfUseTileSubtitle =>
      'Zasady korzystania i granice porad budowlanych';

  @override
  String get privacySettingsTitle => 'Ustawienia prywatności';

  @override
  String get privacySettingsTileSubtitle =>
      'Status usług, uprawnień i kopii danych';

  @override
  String get openSourceLicensesTitle => 'Licencje open source';

  @override
  String get legalApplicationSection => 'Aplikacja';

  @override
  String get legalAppVersionLabel => 'Wersja aplikacji';

  @override
  String get legalAppPackageLabel => 'Identyfikator pakietu';

  @override
  String get legalAppVersionLoading => 'Odczytywanie wersji';

  @override
  String get legalAppVersionUnavailable => 'Wersja niedostępna';

  @override
  String get legalPublisherSection => 'Wydawca i kontakt';

  @override
  String get legalPublisherLabel => 'Wydawca aplikacji';

  @override
  String get legalContactLabel => 'Kontakt w sprawach prywatności';

  @override
  String get legalNotConfiguredValue => 'Nie skonfigurowano do wydania';

  @override
  String get legalEmailSubject => 'BudowaPRO — prywatność';

  @override
  String get legalPublicPolicyLabel => 'Publiczna kopia polityki';

  @override
  String get legalSupportUrlLabel => 'Publiczna strona wsparcia';

  @override
  String get legalDocumentVersion => 'Wersja 1.0 · obowiązuje od 28.07.2026';

  @override
  String get legalIntroTitle => 'Prywatność dostępna w aplikacji';

  @override
  String get legalIntroMessage =>
      'W jednym miejscu sprawdzisz zasady, faktyczne przepływy danych i sposoby zarządzania lokalną zawartością.';

  @override
  String get legalReleaseConfigMissingTitle => 'Wydanie wymaga uzupełnienia';

  @override
  String legalReleaseConfigMissingMessage(String fields) {
    return 'Brakuje: $fields. Kompilacja release pozostaje zablokowana, aby nie opublikować niepełnych danych prawnych.';
  }

  @override
  String get legalMissingPublisherRequirement => 'nazwa wydawcy';

  @override
  String get legalMissingEmailRequirement => 'prawidłowy e-mail';

  @override
  String get legalMissingPublicUrlRequirement =>
      'publiczny adres HTTPS polityki';

  @override
  String get legalMissingSupportUrlRequirement =>
      'publiczny adres HTTPS wsparcia';

  @override
  String get legalOpenLinkError => 'Nie udało się otworzyć odnośnika.';

  @override
  String get privacyPolicyIntro =>
      'Poniższe sekcje opisują rzeczywiste działanie BudowaPRO. Rozwiń temat, aby przeczytać szczegóły.';

  @override
  String get termsOfUseIntro =>
      'BudowaPRO pomaga organizować budowę lub remont, ale nie zastępuje projektu, kierownika budowy ani uprawnionego specjalisty.';

  @override
  String get legalOfficialSourcesTitle => 'Oficjalne źródła';

  @override
  String get legalSourceMlKitTerms => 'Google ML Kit — warunki i prywatność';

  @override
  String get legalSourceMlKitDisclosure =>
      'Google ML Kit — ujawnianie danych w Google Play';

  @override
  String get legalSourceGooglePrivacy => 'Google — polityka prywatności';

  @override
  String get legalSourceGdpr => 'RODO — rozporządzenie (UE) 2016/679';

  @override
  String get legalSourceUodo => 'UODO — prawo do złożenia skargi';

  @override
  String get privacySectionPublisherTitle => '1. Wydawca i zakres polityki';

  @override
  String privacySectionPublisherBody(String publisher, String contact) {
    return 'Podmiot wskazany jako wydawca BudowaPRO: $publisher. Kontakt w sprawach prywatności: $contact. Aplikacja nie wymaga konta i nie ma serwera BudowaPRO. Wydawca nie ma zdalnego dostępu do treści zapisanych wyłącznie w prywatnej pamięci aplikacji.';
  }

  @override
  String get privacySectionLocalDataTitle => '2. Dane przechowywane lokalnie';

  @override
  String get privacySectionLocalDataBody =>
      'Na urządzeniu mogą być zapisane dane projektów, budżetów, kosztów, wykonawców i kontaktów, terminów, notatek, decyzji, usterek, dokumentów, zdjęć, skanów, wyników OCR oraz ręcznych kopii zapasowych. BudowaPRO zapisuje je w prywatnej pamięci aplikacji. Nie przesyła tych treści do własnego backendu, ponieważ taki backend nie istnieje.';

  @override
  String get privacySectionPurposeTitle => '3. Cel i sposób przetwarzania';

  @override
  String get privacySectionPurposeBody =>
      'Lokalne operacje uruchamiasz samodzielnie, aby prowadzić projekt, liczyć koszty, planować prace, przechowywać dokumentację i tworzyć kopie. BudowaPRO nie używa danych do reklam, profilowania, sprzedaży danych ani marketingu. Nie ma automatycznych decyzji wywołujących skutki prawne.';

  @override
  String get privacySectionOcrTitle => '4. Skaner i Google ML Kit';

  @override
  String get privacySectionOcrBody =>
      'Rozpoznawanie obrazu i tekstu odbywa się na urządzeniu. Zgodnie z dokumentacją Google obrazy, tekst wejściowy i wynik OCR nie są wysyłane do serwerów Google. Biblioteki ML Kit mogą jednak kontaktować się z Google po aktualizacje i wysyłać zaszyfrowane metryki techniczne: informacje o urządzeniu i aplikacji, identyfikator instalacji, parametry i wydajność funkcji, typy zdarzeń oraz kody błędów. Google używa ich do diagnostyki i analityki wykorzystania ML Kit.';

  @override
  String get privacySectionSharingTitle => '5. Odbiorcy i udostępnianie';

  @override
  String get privacySectionSharingBody =>
      'Poza technicznymi metrykami ML Kit BudowaPRO nie udostępnia danych automatycznie. Eksport CSV, kopia ZIP, telefon, e-mail albo systemowe udostępnianie uruchamiają się dopiero po Twojej akcji i przekazują wybraną zawartość do wskazanej przez Ciebie aplikacji lub dostawcy. Ręczna kopia ZIP nie jest szyfrowana i może zawierać dokumenty, kontakty oraz zdjęcia. Dalsze przetwarzanie podlega zasadom wybranego odbiorcy.';

  @override
  String get privacySectionRetentionTitle =>
      '6. Okres przechowywania i usuwanie';

  @override
  String get privacySectionRetentionBody =>
      'Dane pozostają w aplikacji do czasu usunięcia rekordu lub projektu, wyczyszczenia danych aplikacji albo jej odinstalowania. Ręcznie wyeksportowane pliki pozostają w wybranej lokalizacji do czasu, aż usuniesz je osobno. Android wyklucza prywatne pliki BudowaPRO z kopii chmurowej i transferu urządzenie–urządzenie. Na iOS systemowa kopia urządzenia może objąć dane aplikacji zgodnie z ustawieniami i zasadami Apple.';

  @override
  String get privacySectionRightsTitle => '7. Kontrola danych i prawa';

  @override
  String privacySectionRightsBody(String contact) {
    return 'Dane lokalne możesz przeglądać, poprawiać, eksportować i usuwać w aplikacji. Ponieważ wydawca nie posiada ich zdalnej kopii, nie może zwrócić ani usunąć jej za Ciebie. Pytania dotyczące działania aplikacji kieruj na: $contact. W zakresie objętym RODO możesz realizować prawa wobec właściwego administratora danych i złożyć skargę do Prezesa UODO.';
  }

  @override
  String get privacySectionSecurityTitle => '8. Bezpieczeństwo';

  @override
  String get privacySectionSecurityBody =>
      'BudowaPRO używa prywatnych katalogów aplikacji, weryfikuje kopie i ogranicza uprawnienia systemowe. Chroń telefon blokadą ekranu i przechowuj ręczne kopie w zaufanym miejscu. Żadne zabezpieczenie nie usuwa ryzyka utraty danych po uszkodzeniu urządzenia, złośliwym oprogramowaniu lub udostępnieniu odblokowanego telefonu.';

  @override
  String get privacySectionChangesTitle => '9. Zmiany polityki';

  @override
  String get privacySectionChangesBody =>
      'Istotna zmiana funkcji, dostawcy SDK lub przepływu danych wymaga aktualizacji tej polityki i sekcji Bezpieczeństwo danych w Google Play. Aktualna wersja pozostaje dostępna w aplikacji oraz pod publicznym adresem wskazanym w Google Play.';

  @override
  String get termsSectionProviderTitle => '1. Usługodawca';

  @override
  String termsSectionProviderBody(String publisher, String contact) {
    return 'BudowaPRO udostępnia: $publisher. Kontakt: $contact. Korzystanie z aplikacji nie wymaga utworzenia konta ani zawarcia odpłatnej subskrypcji w tej wersji.';
  }

  @override
  String get termsSectionPurposeTitle => '2. Przeznaczenie aplikacji';

  @override
  String get termsSectionPurposeBody =>
      'Aplikacja służy do prywatnego organizowania budowy lub remontu: kosztów, etapów, kontaktów, dokumentów, terminów, zdjęć i notatek. Użytkownik może korzystać z niej wyłącznie zgodnie z prawem i prawami osób trzecich.';

  @override
  String get termsSectionSafetyTitle =>
      '3. Informacje budowlane i bezpieczeństwo';

  @override
  String get termsSectionSafetyBody =>
      'Checklisty i wskazówki mają charakter organizacyjny i informacyjny. Nie są projektem budowlanym, opinią techniczną ani indywidualnym doborem rozwiązania. Przed wykonaniem robót zweryfikuj aktualne przepisy, projekt, warunki gruntowe, instrukcje producenta i ustalenia z projektantem, kierownikiem budowy lub osobą z wymaganymi uprawnieniami.';

  @override
  String get termsSectionUserDataTitle => '4. Dane użytkownika i kopie';

  @override
  String get termsSectionUserDataBody =>
      'Odpowiadasz za legalność wprowadzanych kontaktów, zdjęć i dokumentów oraz za posiadanie prawa do ich użycia. Dane są lokalne. Regularnie twórz ręczną kopię i sprawdzaj możliwość jej odtworzenia. Usunięcie projektu, wyczyszczenie pamięci lub utrata telefonu może być nieodwracalne bez poprawnej kopii.';

  @override
  String get termsSectionOcrTitle => '5. OCR i obliczenia';

  @override
  String get termsSectionOcrBody =>
      'OCR może błędnie odczytać nazwę, datę, pozycję, VAT lub kwotę. Każdy wynik trzeba sprawdzić przed zapisem i zatwierdzeniem kosztu. Podsumowania zależą od poprawności danych wprowadzonych lub zaakceptowanych przez użytkownika.';

  @override
  String get termsSectionAvailabilityTitle => '6. Dostępność i aktualizacje';

  @override
  String get termsSectionAvailabilityBody =>
      'Nie gwarantuje się nieprzerwanego działania na każdym urządzeniu ani zgodności ze wszystkimi formatami dokumentów. Aktualizacje mogą poprawiać bezpieczeństwo, zgodność z Androidem i zakres funkcji, z zachowaniem lokalnych danych w ramach obsługiwanych migracji.';

  @override
  String get termsSectionLiabilityTitle => '7. Odpowiedzialność';

  @override
  String get termsSectionLiabilityBody =>
      'Wydawca odpowiada w granicach bezwzględnie obowiązującego prawa. Warunki nie wyłączają ani nie ograniczają ustawowych praw konsumenta. Użytkownik odpowiada za decyzje budowlane podjęte bez wymaganej weryfikacji specjalisty oraz za skutki podania nieprawidłowych danych.';

  @override
  String get termsSectionLawTitle => '8. Prawo i spory';

  @override
  String get termsSectionLawBody =>
      'Stosuje się prawo polskie, bez uszczerbku dla bezwzględnie obowiązujących praw konsumenta wynikających z prawa miejsca jego zamieszkania. Spór można najpierw zgłosić wydawcy na podany adres kontaktowy.';

  @override
  String get termsSectionChangesTitle => '9. Zmiany warunków';

  @override
  String get termsSectionChangesBody =>
      'Nowa wersja warunków powinna otrzymać nową datę i być dostępna przed publikacją aktualizacji, jeżeli zmiana wpływa na prawa użytkownika lub sposób działania aplikacji.';

  @override
  String get privacySettingsIntro =>
      'BudowaPRO nie ma konta, reklam ani własnej analityki. Ten ekran pokazuje realne ustawienia i wyjątek techniczny związany z Google ML Kit.';

  @override
  String get privacyStatusSection => 'Bieżący status';

  @override
  String get privacyStatusLocalTitle => 'Treści projektu pozostają lokalnie';

  @override
  String get privacyStatusLocalSubtitle =>
      'Baza, zdjęcia, dokumenty i OCR są zapisywane w prywatnej pamięci aplikacji.';

  @override
  String get privacyStatusAccountTitle => 'Brak konta i synchronizacji';

  @override
  String get privacyStatusAccountSubtitle =>
      'BudowaPRO nie ma logowania, profilu użytkownika ani własnego backendu.';

  @override
  String get privacyStatusTrackingTitle =>
      'Brak reklam i śledzenia marketingowego';

  @override
  String get privacyStatusTrackingSubtitle =>
      'Aplikacja nie używa reklam, Firebase Analytics ani Crashlytics. Metryki techniczne ML Kit opisano osobno.';

  @override
  String get privacyStatusMlKitTitle => 'Techniczne metryki Google ML Kit';

  @override
  String get privacyStatusMlKitSubtitle =>
      'Po użyciu skanera lub OCR Google może otrzymać metryki urządzenia, aplikacji, wydajności i błędów — bez obrazu, tekstu dokumentu i wyniku OCR.';

  @override
  String get privacyPermissionsSection => 'Uprawnienia i usługi Androida';

  @override
  String get privacyPermissionNotificationsTitle => 'Powiadomienia';

  @override
  String get privacyPermissionNotificationsSubtitle =>
      'Służą wyłącznie lokalnym przypomnieniom i są uruchamiane po decyzji użytkownika.';

  @override
  String get privacyPermissionContactsTitle => 'Kontakty';

  @override
  String get privacyPermissionContactsSubtitle =>
      'Wybierasz pojedynczy kontakt przez systemowy selektor. Aplikacja nie żąda szerokiego odczytu książki kontaktów.';

  @override
  String get privacyPermissionFilesTitle => 'Zdjęcia, pliki i aparat';

  @override
  String get privacyPermissionFilesSubtitle =>
      'Systemowy selektor lub skaner otwiera się dopiero po Twojej akcji. Manifest nie żąda szerokiego dostępu do pamięci ani kontaktów.';

  @override
  String get privacyAutomaticBackupTitle => 'Kopie systemowe urządzenia';

  @override
  String get privacyAutomaticBackupSubtitle =>
      'Android wyklucza prywatne pliki BudowaPRO z kopii chmurowej i transferu na nowe urządzenie. Na iOS systemowa kopia urządzenia może objąć dane aplikacji zgodnie z ustawieniami Apple. Ręczna kopia ZIP nie jest szyfrowana.';

  @override
  String get privacyDataControlSection => 'Kontrola danych';

  @override
  String get privacyCreateBackupTitle => 'Utwórz lub odtwórz kopię';

  @override
  String get privacyCreateBackupSubtitle =>
      'Sam wybierasz lokalizację. Plik ZIP nie jest szyfrowany, dlatego przechowuj go w zaufanym miejscu.';

  @override
  String get privacyDeleteDataSection => 'Trwałe usuwanie';

  @override
  String get privacyDeleteDataHelp =>
      'Możesz usunąć wszystkie dane zapisane przez BudowaPRO bezpośrednio tutaj. Eksporty i ręczne kopie zapisane poza aplikacją trzeba usunąć osobno.';

  @override
  String get privacyDeleteAllTitle => 'Usuń wszystkie dane BudowaPRO';

  @override
  String get privacyDeleteAllSubtitle =>
      'Projekty, koszty, kontakty, dokumenty, zdjęcia, OCR i szkice zostaną trwale usunięte.';

  @override
  String get privacyDeleteAllWarning =>
      'Tej operacji nie można cofnąć. Przed usunięciem utwórz kopię, jeśli chcesz zachować dane.';

  @override
  String get privacyDeleteAllConfirmTitle => 'Usunąć wszystkie dane?';

  @override
  String get privacyDeleteAllConfirmMessage =>
      'Zostanie usunięta baza BudowaPRO oraz wszystkie lokalne pliki projektów. Aby potwierdzić, wpisz dokładnie poniższą frazę.';

  @override
  String get privacyDeleteAllPhraseLabel => 'Fraza potwierdzająca';

  @override
  String get privacyDeleteAllConfirmationPhrase => 'USUŃ DANE';

  @override
  String get privacyDeleteAllConfirmAction => 'Usuń bezpowrotnie';

  @override
  String get privacyDeleteAllError =>
      'Nie udało się dokończyć usuwania danych. Spróbuj ponownie.';

  @override
  String get journalTitle => 'Dziennik budowy';

  @override
  String get journalSubtitle =>
      'Notatki, decyzje, usterki i zmiany zakresu w jednym miejscu.';

  @override
  String get journalEmptyTitle => 'Dziennik jest pusty';

  @override
  String get journalEmptyMessage =>
      'Dodaj pierwszy wpis dnia, notatkę, decyzję albo usterkę.';

  @override
  String get journalNoProjectTitle => 'Wybierz projekt';

  @override
  String get journalNoProjectMessage =>
      'Dziennik jest przypisany do wybranej budowy lub remontu.';

  @override
  String get journalLoadError => 'Nie udało się wczytać dziennika.';

  @override
  String get journalAddTooltip => 'Dodaj wpis';

  @override
  String get journalAllFilter => 'Wszystkie';

  @override
  String get journalSearchHint => 'Szukaj po tytule i treści';

  @override
  String get journalLoadMore => 'Pokaż starsze wpisy';

  @override
  String get journalTypeDaily => 'Wpis dnia';

  @override
  String get journalTypeNote => 'Notatka';

  @override
  String get journalTypeDecision => 'Decyzja';

  @override
  String get journalTypeDefect => 'Usterka';

  @override
  String get journalTypeScopeChange => 'Zmiana zakresu';

  @override
  String get journalStatusDraft => 'Szkic';

  @override
  String get journalStatusOpen => 'Otwarte';

  @override
  String get journalStatusInProgress => 'W toku';

  @override
  String get journalStatusProposal => 'Propozycja';

  @override
  String get journalStatusPending => 'Do decyzji';

  @override
  String get journalStatusApproved => 'Zatwierdzone';

  @override
  String get journalStatusRejected => 'Odrzucone';

  @override
  String get journalStatusImplemented => 'Wdrożone';

  @override
  String get journalStatusRecheck => 'Do sprawdzenia';

  @override
  String get journalStatusFixed => 'Naprawione';

  @override
  String get journalStatusClosed => 'Zamknięte';

  @override
  String get journalNewTitle => 'Nowy wpis';

  @override
  String get journalEditTitle => 'Edytuj wpis';

  @override
  String get journalDetailsTitle => 'Szczegóły wpisu';

  @override
  String get journalTitleLabel => 'Tytuł';

  @override
  String get journalDateLabel => 'Data wpisu';

  @override
  String get journalStageLabel => 'Etap';

  @override
  String get journalStageNone => 'Bez przypisanego etapu';

  @override
  String get journalPersonLabel => 'Osoba odpowiedzialna';

  @override
  String get journalPersonNone => 'Bez przypisanej osoby';

  @override
  String get journalDecisionMakerLabel => 'Osoba decyzyjna';

  @override
  String get journalDecisionMakerNone => 'Nie wskazano osoby decyzyjnej';

  @override
  String get journalStatusLabel => 'Status';

  @override
  String get journalBodyLabel => 'Treść';

  @override
  String get journalWeatherLabel => 'Pogoda';

  @override
  String get journalPeopleLabel => 'Ekipa / osoby na budowie';

  @override
  String get journalWorkLabel => 'Wykonane prace';

  @override
  String get journalDeliveriesLabel => 'Dostawy';

  @override
  String get journalDelaysLabel => 'Opóźnienia i przeszkody';

  @override
  String get journalNextStepsLabel => 'Kolejne kroki';

  @override
  String get journalProblemLabel => 'Problem lub pytanie';

  @override
  String get journalVariantsLabel => 'Rozważane warianty';

  @override
  String get journalSelectedOptionLabel => 'Wybrany wariant';

  @override
  String get journalRationaleLabel => 'Uzasadnienie';

  @override
  String get journalDueDateLabel => 'Termin sprawdzenia / realizacji';

  @override
  String get journalClearDueDate => 'Wyczyść termin';

  @override
  String get journalSaveAction => 'Zapisz wpis';

  @override
  String get journalSavedMessage => 'Wpis zapisany.';

  @override
  String get journalSaveError =>
      'Nie udało się zapisać wpisu. Sprawdź pola i spróbuj ponownie.';

  @override
  String get journalEditTooltip => 'Edytuj wpis';

  @override
  String get journalChangeStatusTooltip => 'Zmień status';

  @override
  String get journalHistoryTitle => 'Historia zmian';

  @override
  String journalHistoryCount(int count) {
    return 'Wersje: $count';
  }

  @override
  String get journalAttachmentsTitle => 'Załączniki';

  @override
  String get journalAttachmentAdd => 'Dodaj plik';

  @override
  String get journalAttachmentRemove => 'Usuń załącznik';

  @override
  String journalAttachmentCount(int count) {
    return 'Załączniki: $count';
  }

  @override
  String get journalRelatedRecordsTitle => 'Powiązane rekordy';

  @override
  String get journalStageLink => 'Otwórz etap';

  @override
  String get journalContactLink => 'Otwórz osobę';

  @override
  String get journalRevisionCreated => 'Utworzono';

  @override
  String get journalRevisionUpdated => 'Zmieniono';

  @override
  String get journalRevisionStatusChanged => 'Zmieniono status';

  @override
  String get journalNoContent => 'Brak dodatkowej treści.';

  @override
  String get journalTypeRequiredError => 'Wybierz typ wpisu.';

  @override
  String get journalTitleRequiredError => 'Wpisz tytuł.';

  @override
  String get journalBodyRequiredError => 'Dodaj treść wpisu.';

  @override
  String get journalDatePickerLabel => 'Wybierz datę';

  @override
  String get journalAttachmentError => 'Nie udało się dodać pliku.';

  @override
  String get journalAttachmentRemoveConfirm => 'Usunąć załącznik z wpisu?';

  @override
  String get journalCostImpactLabel => 'Wpływ kosztowy';

  @override
  String get journalScheduleImpactLabel => 'Wpływ na termin';

  @override
  String get journalCostImpactHint => 'np. 1250,00 lub -300,00';

  @override
  String get journalScheduleImpactHint => 'np. 2 lub -1';

  @override
  String get journalImpactInvalidError =>
      'Wpisz poprawną kwotę i pełną liczbę dni.';

  @override
  String get journalBlockedRecordsTitle => 'Blokowane zadania';

  @override
  String get journalBlockedRecordsEmpty =>
      'Ta decyzja nie blokuje żadnego zadania z harmonogramu.';

  @override
  String get journalBlockedRecordsSelect => 'Wybierz zadania';

  @override
  String get journalBlockedRecordsDone => 'Gotowe';

  @override
  String get journalApproveAction => 'Zatwierdź decyzję';

  @override
  String get journalApprovalTitle => 'Zatwierdzenie';

  @override
  String get journalApprovalPersonLabel => 'Zatwierdził(a)';

  @override
  String get journalApprovalDateLabel => 'Data zatwierdzenia';

  @override
  String get journalApprovalDialogTitle => 'Zatwierdź wybrany wariant';

  @override
  String get journalApprovalDialogMessage =>
      'Potwierdź osobę zatwierdzającą. Od tej chwili delta decyzji będzie widoczna w raporcie budżetu.';

  @override
  String get journalApprovalContactRequired =>
      'Dodaj kontakt lub wskaż osobę, która zatwierdza decyzję.';

  @override
  String get journalApprovalOptionRequired => 'Najpierw wpisz wybrany wariant.';

  @override
  String get journalApprovalSuccess =>
      'Decyzja zatwierdzona i uwzględniona w raporcie.';

  @override
  String get journalApprovalError => 'Nie udało się zatwierdzić decyzji.';

  @override
  String get journalApprovalManagedInDetails =>
      'Zatwierdzenie i wdrożenie zmienisz w szczegółach wpisu.';

  @override
  String get journalDaysSuffix => 'dni';

  @override
  String get technicalPhotosTitle => 'Dokumentacja techniczna';

  @override
  String get technicalPhotosSubtitle =>
      'Zdjęcia robót zanikających, instalacji i odbiorów';

  @override
  String get technicalPhotosLoading => 'Wczytywanie dokumentacji technicznej';

  @override
  String get technicalPhotosLoadError =>
      'Nie udało się wczytać dokumentacji technicznej.';

  @override
  String get technicalPhotosNoProjectTitle => 'Wybierz projekt';

  @override
  String get technicalPhotosNoProjectMessage =>
      'Zdjęcia techniczne są przypisane do wybranej budowy lub remontu.';

  @override
  String get technicalPhotosEmptyTitle => 'Brak zdjęć technicznych';

  @override
  String get technicalPhotosEmptyMessage =>
      'Dodaj zdjęcie przed zakryciem instalacji, zalaniem betonu albo wykonaniem kolejnej warstwy.';

  @override
  String get technicalPhotosSearchHint =>
      'Szukaj po nazwie, opisie, strefie lub tagu';

  @override
  String get technicalPhotosAddTooltip => 'Dodaj zdjęcie techniczne';

  @override
  String get technicalPhotosAlbumAddTooltip => 'Utwórz album';

  @override
  String get technicalPhotosFilterTooltip => 'Filtry zdjęć';

  @override
  String get technicalPhotosAllAlbums => 'Wszystkie';

  @override
  String technicalPhotosCount(int count) {
    return 'Zdjęcia: $count';
  }

  @override
  String get technicalPhotosLoadMore => 'Wczytaj kolejne zdjęcia';

  @override
  String get technicalPhotosMissingPreview => 'Podgląd pliku jest niedostępny';

  @override
  String get technicalPhotosImportError => 'Nie udało się dodać zdjęcia.';

  @override
  String get technicalPhotosUnsupportedFile =>
      'Wybierz plik obrazu, np. JPG, PNG lub HEIC.';

  @override
  String get technicalAlbumNewTitle => 'Nowy album techniczny';

  @override
  String get technicalAlbumTitleLabel => 'Nazwa albumu';

  @override
  String get technicalAlbumKindLabel => 'Rodzaj albumu';

  @override
  String get technicalAlbumDescriptionLabel => 'Cel i zakres albumu';

  @override
  String get technicalAlbumCreateAction => 'Utwórz album';

  @override
  String get technicalAlbumCreateError => 'Nie udało się utworzyć albumu.';

  @override
  String get technicalAlbumRequiredError => 'Najpierw utwórz album techniczny.';

  @override
  String get technicalAlbumBeforeConcrete => 'Przed betonowaniem';

  @override
  String get technicalAlbumBeforeBackfill => 'Przed zasypaniem';

  @override
  String get technicalAlbumBeforePlaster => 'Przed tynkowaniem';

  @override
  String get technicalAlbumBeforeScreed => 'Przed wylewką';

  @override
  String get technicalAlbumBeforeTiles => 'Przed płytkami';

  @override
  String get technicalAlbumAsBuilt => 'Stan powykonawczy';

  @override
  String get technicalAlbumCustom => 'Własny album';

  @override
  String get technicalFiltersTitle => 'Filtry dokumentacji';

  @override
  String get technicalFilterAlbumLabel => 'Album';

  @override
  String get technicalFilterStageLabel => 'Etap';

  @override
  String get technicalFilterInstallationLabel => 'Instalacja lub zakres';

  @override
  String get technicalFilterTagLabel => 'Tag';

  @override
  String get technicalFilterAllStages => 'Wszystkie etapy';

  @override
  String get technicalFilterAllInstallations => 'Wszystkie instalacje';

  @override
  String get technicalFilterAllTags => 'Wszystkie tagi';

  @override
  String get technicalPhotoNewTitle => 'Opisz zdjęcie techniczne';

  @override
  String get technicalPhotoEditTitle => 'Edytuj zdjęcie techniczne';

  @override
  String get technicalPhotoDetailsTitle => 'Szczegóły zdjęcia';

  @override
  String get technicalPhotoTitleLabel => 'Nazwa zdjęcia';

  @override
  String get technicalPhotoDateLabel => 'Data wykonania zdjęcia';

  @override
  String get technicalPhotoZoneLabel => 'Pomieszczenie lub strefa';

  @override
  String get technicalPhotoContractorLabel => 'Wykonawca';

  @override
  String get technicalPhotoChecklistLabel => 'Punkt checklisty jako dowód';

  @override
  String get technicalPhotoDescriptionLabel => 'Opis tego, co widać';

  @override
  String get technicalPhotoTagsLabel => 'Tagi oddzielone przecinkami';

  @override
  String get technicalPhotoNoContact => 'Bez wykonawcy';

  @override
  String get technicalPhotoNoChecklist => 'Bez powiązania z checklistą';

  @override
  String get technicalPhotoNoStage => 'Bez przypisanego etapu';

  @override
  String get technicalPhotoSaveAction => 'Zapisz zdjęcie';

  @override
  String get technicalPhotoSaveError =>
      'Nie udało się zapisać zdjęcia. Sprawdź wymagane pola.';

  @override
  String get technicalPhotoSavedMessage =>
      'Zdjęcie zapisane w dokumentacji technicznej.';

  @override
  String get technicalPhotoNotFound =>
      'Zdjęcie nie istnieje albo zostało usunięte.';

  @override
  String get technicalPhotoOpenFile => 'Otwórz pełne zdjęcie';

  @override
  String get technicalPhotoEditTooltip => 'Edytuj opis zdjęcia';

  @override
  String get technicalPhotoLinkedChecklist => 'Dowód do checklisty';

  @override
  String get technicalInstallationStructure => 'Konstrukcja';

  @override
  String get technicalInstallationElectrical => 'Elektryka';

  @override
  String get technicalInstallationWater => 'Woda';

  @override
  String get technicalInstallationSewage => 'Kanalizacja';

  @override
  String get technicalInstallationHeating => 'Ogrzewanie';

  @override
  String get technicalInstallationVentilation => 'Wentylacja';

  @override
  String get technicalInstallationWaterproofing => 'Hydroizolacja';

  @override
  String get technicalInstallationInsulation => 'Izolacja termiczna';

  @override
  String get technicalInstallationGrounding =>
      'Uziemienie i połączenia wyrównawcze';

  @override
  String get technicalInstallationOther => 'Inny zakres';

  @override
  String get punchTitle => 'Usterki i odbiory';

  @override
  String get punchSubtitle => 'Usterki, poprawki i protokoły odbioru';

  @override
  String get punchDefectsTab => 'Usterki';

  @override
  String get punchProtocolsTab => 'Protokoły';

  @override
  String get punchLoading => 'Wczytywanie usterek i protokołów';

  @override
  String get punchLoadError => 'Nie udało się wczytać usterek i protokołów.';

  @override
  String get punchNoProjectTitle => 'Wybierz projekt';

  @override
  String get punchNoProjectMessage =>
      'Usterki i odbiory są przypisane do wybranej budowy lub remontu.';

  @override
  String get punchSearchHint => 'Szukaj usterki lub protokołu';

  @override
  String get punchFilterTooltip => 'Filtry usterek';

  @override
  String get punchFiltersTitle => 'Filtry usterek';

  @override
  String get punchOpenCounter => 'Otwarte';

  @override
  String get punchCriticalCounter => 'Krytyczne';

  @override
  String get punchOverdueCounter => 'Po terminie';

  @override
  String punchDefectCount(int count) {
    return 'Usterki: $count';
  }

  @override
  String punchProtocolCount(int count) {
    return 'Protokoły: $count';
  }

  @override
  String get punchLoadMore => 'Wczytaj kolejne';

  @override
  String get punchDefectsEmptyTitle => 'Brak usterek';

  @override
  String get punchDefectsEmptyMessage =>
      'Dodaj pierwszą usterkę i przypisz termin, etap oraz osobę odpowiedzialną.';

  @override
  String get punchProtocolsEmptyTitle => 'Brak protokołów';

  @override
  String get punchProtocolsEmptyMessage =>
      'Utwórz protokół odbioru i powiąż z nim sprawdzane usterki.';

  @override
  String get punchAddDefectTooltip => 'Dodaj usterkę';

  @override
  String get punchAddProtocolTooltip => 'Dodaj protokół odbioru';

  @override
  String get punchStatusLabel => 'Status';

  @override
  String get punchStatusOpen => 'Otwarta';

  @override
  String get punchStatusInProgress => 'W naprawie';

  @override
  String get punchStatusRecheck => 'Do ponownej kontroli';

  @override
  String get punchStatusFixed => 'Naprawiona';

  @override
  String get punchStatusClosed => 'Zamknięta';

  @override
  String get punchSeverityLabel => 'Ważność';

  @override
  String get punchSeverityLow => 'Niska';

  @override
  String get punchSeverityMedium => 'Średnia';

  @override
  String get punchSeverityHigh => 'Wysoka';

  @override
  String get punchSeverityCritical => 'Krytyczna';

  @override
  String get punchOverdueOnly => 'Tylko po terminie';

  @override
  String get punchAllStages => 'Wszystkie etapy';

  @override
  String get punchAllContacts => 'Wszystkie osoby';

  @override
  String get punchRoomFilterLabel => 'Pomieszczenie lub strefa';

  @override
  String get punchClearFilters => 'Wyczyść filtry';

  @override
  String get punchApplyFilters => 'Zastosuj';

  @override
  String get defectNewTitle => 'Nowa usterka';

  @override
  String get defectEditTitle => 'Edytuj usterkę';

  @override
  String get defectDetailsTitle => 'Szczegóły usterki';

  @override
  String get defectTitleLabel => 'Nazwa usterki';

  @override
  String get defectDescriptionLabel => 'Opis i oczekiwany sposób poprawy';

  @override
  String get defectOccurredAtLabel => 'Data zgłoszenia';

  @override
  String get defectDueAtLabel => 'Termin poprawy';

  @override
  String get defectClearDueAt => 'Usuń termin';

  @override
  String get defectStageLabel => 'Etap';

  @override
  String get defectNoStage => 'Bez przypisanego etapu';

  @override
  String get defectRoomLabel => 'Pomieszczenie lub strefa';

  @override
  String get defectResponsibleLabel => 'Osoba odpowiedzialna';

  @override
  String get defectNoResponsible => 'Bez przypisanej osoby';

  @override
  String get defectRequiresPhoto =>
      'Wymagaj zdjęcia po naprawie przed zamknięciem';

  @override
  String get defectRequiresProtocol =>
      'Wymagaj podpisanego protokołu przed zamknięciem';

  @override
  String get defectReportEvidenceTitle => 'Zdjęcia przy zgłoszeniu';

  @override
  String get defectResolutionEvidenceTitle => 'Zdjęcia po naprawie';

  @override
  String get defectAddEvidence => 'Dodaj zdjęcie';

  @override
  String get defectRemoveEvidence => 'Usuń załącznik';

  @override
  String get defectNoEvidence => 'Brak zdjęć';

  @override
  String get defectUnsupportedEvidence =>
      'Wybierz plik obrazu, np. JPG, PNG lub HEIC.';

  @override
  String get defectSaveAction => 'Zapisz usterkę';

  @override
  String get defectSavedMessage => 'Usterka została zapisana.';

  @override
  String get defectSaveError =>
      'Nie udało się zapisać usterki. Sprawdź wymagane pola.';

  @override
  String get defectNotFound => 'Usterka nie istnieje albo została usunięta.';

  @override
  String get defectEditTooltip => 'Edytuj usterkę';

  @override
  String get defectCloseAction => 'Zamknij usterkę';

  @override
  String get defectSetStatusAction => 'Zmień status';

  @override
  String get defectClosureReady => 'Komplet dowodów do zamknięcia';

  @override
  String get defectClosureMissingPhoto => 'Dodaj zdjęcie po naprawie.';

  @override
  String get defectClosureMissingProtocol =>
      'Dodaj podpisany protokół powiązany z usterką.';

  @override
  String get defectStatusChangeError =>
      'Nie udało się zmienić statusu usterki.';

  @override
  String get defectAttachmentError => 'Nie udało się dodać załącznika.';

  @override
  String get protocolNewTitle => 'Nowy protokół odbioru';

  @override
  String get protocolEditTitle => 'Edytuj protokół';

  @override
  String get protocolDetailsTitle => 'Szczegóły protokołu';

  @override
  String get protocolTitleLabel => 'Nazwa protokołu';

  @override
  String get protocolDateLabel => 'Data odbioru';

  @override
  String get protocolStatusLabel => 'Status protokołu';

  @override
  String get protocolStatusDraft => 'Szkic';

  @override
  String get protocolStatusFinalized => 'Gotowy do podpisu';

  @override
  String get protocolStatusSigned => 'Podpisany';

  @override
  String get protocolStageLabel => 'Etap';

  @override
  String get protocolRoomLabel => 'Pomieszczenie lub strefa';

  @override
  String get protocolContractorLabel => 'Wykonawca';

  @override
  String get protocolNotesLabel => 'Ustalenia i uwagi z odbioru';

  @override
  String get protocolDefectsTitle => 'Usterki w protokole';

  @override
  String get protocolSelectDefects => 'Wybierz usterki';

  @override
  String get protocolNoDefects => 'Brak powiązanych usterek';

  @override
  String get protocolSignedFilesTitle => 'Podpisany dokument';

  @override
  String get protocolAddSignedFile => 'Dodaj skan lub PDF';

  @override
  String get protocolNoSignedFile => 'Brak podpisanego dokumentu';

  @override
  String get protocolSignedFileRequired =>
      'Status „Podpisany” wymaga skanu lub pliku PDF.';

  @override
  String get protocolUnsupportedFile => 'Wybierz obraz albo plik PDF.';

  @override
  String get protocolSaveAction => 'Zapisz protokół';

  @override
  String get protocolSavedMessage => 'Protokół został zapisany.';

  @override
  String get protocolSaveError =>
      'Nie udało się zapisać protokołu. Sprawdź wymagane pola.';

  @override
  String get protocolNotFound => 'Protokół nie istnieje albo został usunięty.';

  @override
  String get protocolEditTooltip => 'Edytuj protokół';

  @override
  String get protocolGeneratePdf => 'Utwórz PDF protokołu';

  @override
  String get protocolSelectDefectsDone => 'Gotowe';

  @override
  String get protocolPdfTitle => 'Protokół odbioru';

  @override
  String get protocolPdfProjectLabel => 'Projekt';

  @override
  String get protocolPdfDefectTitleLabel => 'Usterka';

  @override
  String get protocolPdfDeadlineLabel => 'Termin';

  @override
  String get protocolPdfSignaturesTitle => 'Potwierdzenie odbioru';

  @override
  String get protocolPdfInvestorSignature => 'Podpis inwestora';

  @override
  String get protocolPdfContractorSignature => 'Podpis wykonawcy';

  @override
  String get protocolPdfGeneratedNotice =>
      'Dokument wygenerowany lokalnie w BudowaPRO. Sam wydruk nie zastępuje podpisanego protokołu.';

  @override
  String get protocolPdfShareError =>
      'Nie udało się utworzyć lub udostępnić pliku PDF.';

  @override
  String get technicalPhotoLinksTitle => 'Powiązania zdjęcia';

  @override
  String get technicalPhotoNoLink => 'Bez powiązania';

  @override
  String get technicalPhotoCostLink => 'Koszt';

  @override
  String get technicalPhotoDecisionLink => 'Decyzja lub zmiana zakresu';

  @override
  String get technicalPhotoDefectLink => 'Usterka';

  @override
  String get technicalPhotoProtocolLink => 'Protokół odbioru';

  @override
  String get dashboardAddDefect => 'Dodaj usterkę';

  @override
  String get dashboardOpenPunch => 'Usterki i odbiory';

  @override
  String get dashboardOpenTechnicalPhotos => 'Zdjęcia etapów';

  @override
  String get roomsTitle => 'Pomieszczenia';

  @override
  String get roomsSubtitle => 'Budżety, wybory i postęp każdego pomieszczenia';

  @override
  String get roomsLoading => 'Wczytywanie pomieszczeń';

  @override
  String get roomsLoadError => 'Nie udało się wczytać pomieszczeń.';

  @override
  String get roomsNoProjectTitle => 'Wybierz projekt';

  @override
  String get roomsNoProjectMessage =>
      'Pomieszczenia są przypisane do wybranej budowy lub remontu.';

  @override
  String get roomsEmptyTitle => 'Brak pomieszczeń';

  @override
  String get roomsEmptyMessage =>
      'Dodaj pierwsze pomieszczenie, aby osobno pilnować budżetu, wyborów i usterek.';

  @override
  String get roomsSearchHint => 'Szukaj pomieszczenia lub kondygnacji';

  @override
  String get roomsSearchAction => 'Szukaj';

  @override
  String get roomsClearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get roomsAddTooltip => 'Dodaj pomieszczenie';

  @override
  String get roomsLoadMore => 'Wczytaj kolejne';

  @override
  String roomsRoomCount(int count) {
    return 'Pomieszczenia: $count';
  }

  @override
  String get roomsPlannedTotal => 'Budżet pomieszczeń';

  @override
  String get roomsActualTotal => 'Koszt przypisany';

  @override
  String get roomsOpenChoices => 'Otwarte wybory';

  @override
  String get roomNewTitle => 'Nowe pomieszczenie';

  @override
  String get roomEditTitle => 'Edytuj pomieszczenie';

  @override
  String get roomDetailsTitle => 'Karta pomieszczenia';

  @override
  String get roomNameLabel => 'Nazwa pomieszczenia lub strefy';

  @override
  String get roomFloorLabel => 'Kondygnacja lub część budynku';

  @override
  String get roomStandardLabel => 'Standard wykończenia';

  @override
  String get roomStandardBasic => 'Podstawowy';

  @override
  String get roomStandardStandard => 'Standardowy';

  @override
  String get roomStandardElevated => 'Podwyższony';

  @override
  String get roomStandardCustom => 'Indywidualny';

  @override
  String get roomDimensionsTitle => 'Wymiary pomieszczenia';

  @override
  String get roomLengthLabel => 'Długość';

  @override
  String get roomWidthLabel => 'Szerokość';

  @override
  String get roomHeightLabel => 'Wysokość';

  @override
  String get roomMetersSuffix => 'm';

  @override
  String get roomBudgetLabel => 'Planowany budżet';

  @override
  String get roomNoteLabel => 'Notatka';

  @override
  String get roomSaveAction => 'Zapisz pomieszczenie';

  @override
  String get roomSavedMessage => 'Pomieszczenie zostało zapisane.';

  @override
  String get roomSaveError =>
      'Nie udało się zapisać pomieszczenia. Sprawdź wymagane pola.';

  @override
  String get roomConflictError =>
      'Pomieszczenie o tej nazwie już istnieje na wskazanej kondygnacji.';

  @override
  String get roomNotFound =>
      'Pomieszczenie nie istnieje albo zostało usunięte.';

  @override
  String get roomEditTooltip => 'Edytuj pomieszczenie';

  @override
  String get roomDeleteTooltip => 'Usuń pomieszczenie';

  @override
  String get roomDeleteTitle => 'Usunąć pomieszczenie?';

  @override
  String get roomDeleteMessage =>
      'Usunięte zostaną karty wyborów i przypisania. Koszty, zdjęcia, kontakty i usterki pozostaną w projekcie.';

  @override
  String get roomDeleteAction => 'Usuń pomieszczenie';

  @override
  String get roomDeleteError => 'Nie udało się usunąć pomieszczenia.';

  @override
  String get roomBudgetPlanned => 'Plan';

  @override
  String get roomBudgetActual => 'Wydano';

  @override
  String get roomBudgetRemaining => 'Pozostało';

  @override
  String get roomNoBudget => 'Nie ustawiono budżetu';

  @override
  String get roomChoicesTitle => 'Wybory i warianty';

  @override
  String get roomAddChoiceAction => 'Dodaj wybór';

  @override
  String get roomNoChoices => 'Brak kart wyborów';

  @override
  String get roomNoChoicesMessage =>
      'Dodaj np. płytki, drzwi, armaturę lub kolor farby i porównaj warianty.';

  @override
  String get roomChoiceStatusOpen => 'Do wyboru';

  @override
  String get roomChoiceStatusSelected => 'Wybrano';

  @override
  String get roomChoiceStatusCancelled => 'Anulowano';

  @override
  String get roomChoiceSelectAction => 'Wybierz wariant';

  @override
  String get roomChoiceReopenAction => 'Zmień wybór';

  @override
  String get roomChoiceCancelAction => 'Anuluj wybór';

  @override
  String get roomChoiceEditTooltip => 'Edytuj kartę wyboru';

  @override
  String get roomChoiceDeleteTooltip => 'Usuń kartę wyboru';

  @override
  String roomChoiceEstimatedTotal(String amount) {
    return 'Szacunkowo: $amount';
  }

  @override
  String roomChoiceQuantityWithWaste(String quantity, String unit) {
    return 'Ilość z zapasem: $quantity $unit';
  }

  @override
  String roomChoiceOrderDue(String date) {
    return 'Zamów do: $date';
  }

  @override
  String get roomChoiceNewTitle => 'Nowa karta wyboru';

  @override
  String get roomChoiceEditTitle => 'Edytuj kartę wyboru';

  @override
  String get roomChoiceTitleLabel => 'Co wybierasz?';

  @override
  String get roomChoiceQuantityLabel => 'Ilość';

  @override
  String get roomChoiceUnitLabel => 'Jednostka';

  @override
  String get roomChoiceWasteLabel => 'Zapas';

  @override
  String get roomChoiceWasteSuffix => '%';

  @override
  String get roomChoiceOrderDateLabel => 'Termin zamówienia';

  @override
  String get roomChoiceNoOrderDate => 'Bez terminu zamówienia';

  @override
  String get roomChoiceClearOrderDate => 'Usuń termin';

  @override
  String get roomChoiceNoteLabel => 'Notatka do wyboru';

  @override
  String get roomChoiceVariantsTitle => 'Porównywane warianty';

  @override
  String get roomChoiceAddVariant => 'Dodaj wariant';

  @override
  String get roomChoiceRemoveVariant => 'Usuń wariant';

  @override
  String get roomChoiceVariantLabel => 'Nazwa wariantu';

  @override
  String get roomChoiceVariantPriceLabel => 'Cena brutto za jednostkę';

  @override
  String get roomChoiceVariantSupplierLabel => 'Sklep lub dostawca';

  @override
  String get roomChoiceVariantCodeLabel => 'Kod produktu';

  @override
  String get roomChoiceVariantNoteLabel => 'Uwagi do wariantu';

  @override
  String get roomChoiceSaveAction => 'Zapisz kartę wyboru';

  @override
  String get roomChoiceSavedMessage => 'Karta wyboru została zapisana.';

  @override
  String get roomChoiceSaveError =>
      'Nie udało się zapisać karty wyboru. Dodaj co najmniej jeden poprawny wariant.';

  @override
  String get roomChoiceSelectionTitle => 'Potwierdź wariant';

  @override
  String get roomChoiceSelectionMessage =>
      'Wybór zostanie zapisany jako decyzja w karcie pomieszczenia. Nie utworzy kosztu ani zamówienia bez osobnej akcji.';

  @override
  String get roomChoiceCreatePlannedCost => 'Utwórz szkic kosztu';

  @override
  String get roomChoicePlannedCostCreated => 'Szkic kosztu utworzony';

  @override
  String get roomChoiceCreateMaterial => 'Dodaj do materiałów';

  @override
  String get roomChoiceMaterialCreated => 'Materiał dodany';

  @override
  String get roomChoiceCreateDecision => 'Utwórz decyzję';

  @override
  String get roomChoiceDecisionCreated => 'Decyzja utworzona';

  @override
  String get roomChoiceOutputError =>
      'Nie udało się utworzyć powiązanego rekordu.';

  @override
  String get roomChoiceVatTitle => 'Wybierz stawkę VAT dla planowanego kosztu';

  @override
  String roomChoiceCostName(String choice, String variant) {
    return '$choice: $variant';
  }

  @override
  String roomChoiceCostNote(String room) {
    return 'Szkic utworzony z karty wyboru w pomieszczeniu: $room.';
  }

  @override
  String roomChoiceDecisionTitle(String room, String choice) {
    return 'Wybór w pomieszczeniu $room: $choice';
  }

  @override
  String get roomRelatedTitle => 'Powiązane dane';

  @override
  String get roomRelatedDecisions => 'Otwarte decyzje';

  @override
  String get roomRelatedMaterials => 'Materiały';

  @override
  String get roomRelatedTeams => 'Ekipy';

  @override
  String get roomRelatedPhotos => 'Zdjęcia techniczne';

  @override
  String get roomRelatedDefects => 'Otwarte usterki';

  @override
  String get roomRelatedCosts => 'Koszty';

  @override
  String get roomManageRelationsAction => 'Przypisz dane';

  @override
  String get roomRelationsTitle => 'Dane pomieszczenia';

  @override
  String get roomRelationsSearchHint => 'Szukaj na tej liście';

  @override
  String get roomRelationsEmpty => 'Brak elementów do przypisania.';

  @override
  String roomRelationsAssignedElsewhere(String roomName) {
    return 'Przypisano do: $roomName';
  }

  @override
  String get roomRelationsMoveTitle => 'Przenieść przypisanie?';

  @override
  String roomRelationsMoveMessage(String roomName) {
    return 'Ten element jest przypisany do pomieszczenia „$roomName”. Po zatwierdzeniu zostanie przeniesiony tutaj.';
  }

  @override
  String get roomRelationsMoveAction => 'Przenieś';

  @override
  String get roomRelationsSaveError => 'Nie udało się zmienić przypisania.';

  @override
  String roomRelatedCount(int count) {
    return '$count';
  }

  @override
  String get roomSelectedChoiceEditNotice =>
      'Edycja ponownie otworzy wybór i będzie wymagała jawnego zatwierdzenia wariantu.';

  @override
  String get requiredFieldError => 'Uzupełnij wymagane pole.';

  @override
  String get invalidAmountError =>
      'Wpisz kwotę z maksymalnie dwiema cyframi po przecinku.';

  @override
  String get invalidNumberError => 'Wpisz dodatnią liczbę.';

  @override
  String get materialsTitle => 'Materiały i dostawy';

  @override
  String get materialsSubtitle => 'Zamówienia, dostawy, składowanie i zwroty';

  @override
  String get materialsLoading => 'Wczytywanie materiałów';

  @override
  String get materialsLoadError => 'Nie udało się wczytać materiałów.';

  @override
  String get materialsNoProjectTitle => 'Wybierz projekt';

  @override
  String get materialsNoProjectMessage =>
      'Materiały są przypisane do konkretnej budowy lub remontu.';

  @override
  String get materialsEmptyTitle => 'Brak materiałów';

  @override
  String get materialsEmptyMessage =>
      'Dodaj pierwszy materiał, aby kontrolować zamówienie, dostawy i zwroty.';

  @override
  String get materialsNoResultsTitle => 'Brak pasujących materiałów';

  @override
  String get materialsNoResultsMessage =>
      'Zmień wyszukiwanie lub filtry statusu.';

  @override
  String get materialsSearchHint => 'Szukaj materiału lub miejsca składowania';

  @override
  String get materialsClearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get materialsAddTooltip => 'Dodaj materiał';

  @override
  String get materialsLoadMore => 'Wczytaj więcej';

  @override
  String get materialsOrderedValue => 'Wartość zamówień';

  @override
  String get materialsExpectedReturns => 'Planowane zwroty';

  @override
  String get materialsDelayedCount => 'Opóźnienia';

  @override
  String get materialsOverdueReturns => 'Zwroty po terminie';

  @override
  String get materialsOpenDeliveries => 'Otwarte dostawy';

  @override
  String get materialStatusPlanned => 'Planowany';

  @override
  String get materialStatusOrdered => 'Zamówiony';

  @override
  String get materialStatusPartiallyDelivered => 'Częściowo dostarczony';

  @override
  String get materialStatusDelivered => 'Dostarczony';

  @override
  String get materialStatusDelayed => 'Opóźniony';

  @override
  String get materialStatusReturned => 'Zwrócony';

  @override
  String get materialNewTitle => 'Nowy materiał';

  @override
  String get materialEditTitle => 'Edytuj materiał';

  @override
  String get materialDetailsTitle => 'Szczegóły materiału';

  @override
  String get materialNotFound => 'Nie znaleziono materiału.';

  @override
  String get materialNameLabel => 'Nazwa materiału';

  @override
  String get materialQuantityLabel => 'Ilość zamówiona';

  @override
  String get materialUnitLabel => 'Jednostka';

  @override
  String get materialDefaultUnit => 'szt.';

  @override
  String get materialStageLabel => 'Etap';

  @override
  String get materialRoomLabel => 'Pomieszczenie';

  @override
  String get materialSupplierLabel => 'Dostawca';

  @override
  String get materialCostLabel => 'Powiązany koszt';

  @override
  String get materialReceiptLabel => 'Paragon lub faktura';

  @override
  String get materialOrderedGrossLabel => 'Wartość zamówienia brutto';

  @override
  String get materialStorageLabel => 'Miejsce składowania';

  @override
  String get materialOrderedToggle => 'Materiał został zamówiony';

  @override
  String get materialOrderedDateLabel => 'Data zamówienia';

  @override
  String get materialExpectedDeliveryLabel => 'Planowana dostawa';

  @override
  String get materialReminderToggle => 'Przypomnienie o terminie';

  @override
  String get materialNoteLabel => 'Notatka';

  @override
  String get materialNoRelation => 'Brak przypisania';

  @override
  String get materialSaveAction => 'Zapisz materiał';

  @override
  String get materialSaveError =>
      'Nie udało się zapisać materiału. Sprawdź powiązania i wartości.';

  @override
  String get materialEditTooltip => 'Edytuj materiał';

  @override
  String get materialDeleteTooltip => 'Usuń materiał';

  @override
  String get materialDeleteTitle => 'Usunąć materiał?';

  @override
  String get materialDeleteMessage =>
      'Usunięte zostaną także jego dostawy i zwroty. Koszt, dokumenty i kontakty pozostaną bez zmian.';

  @override
  String get materialDeleteAction => 'Usuń';

  @override
  String get materialDeleteError => 'Nie udało się usunąć materiału.';

  @override
  String get materialOrderedQuantity => 'Zamówiono';

  @override
  String get materialDeliveredQuantity => 'Dostarczono';

  @override
  String get materialReturnedQuantity => 'Zwrócono';

  @override
  String get materialRelationsTitle => 'Powiązania i składowanie';

  @override
  String get materialDeliveriesTitle => 'Dostawy';

  @override
  String get materialAddDeliveryAction => 'Dodaj dostawę';

  @override
  String get materialNoDeliveries => 'Nie zapisano jeszcze dostaw.';

  @override
  String get materialDeliveryExpectedLabel => 'Ilość w tej dostawie';

  @override
  String get materialDeliveryDueLabel => 'Termin dostawy';

  @override
  String get materialDeliveryReceivedToggle => 'Dostawa odebrana';

  @override
  String get materialDeliveryActualLabel => 'Ilość odebrana';

  @override
  String get materialDeliveryDocumentLabel => 'Dokument WZ';

  @override
  String get materialDeliveryContactLabel => 'Kontakt przy dostawie';

  @override
  String get materialDeliveryShortageLabel => 'Braki ilościowe';

  @override
  String get materialDeliveryDamageLabel => 'Uszkodzenia i zastrzeżenia';

  @override
  String get materialDeliverySaveAction => 'Zapisz dostawę';

  @override
  String get materialDeliverySaveError => 'Nie udało się zapisać dostawy.';

  @override
  String get materialDeliveryOverTitle => 'Dostawa przekracza zamówienie';

  @override
  String get materialDeliveryOverMessage =>
      'Suma odebrana jest większa niż ilość zamówiona. Potwierdzenie skoryguje ilość zamówioną do faktycznie odebranej.';

  @override
  String get materialDeliveryOverAction => 'Potwierdź korektę';

  @override
  String get materialDeliveryDelayed => 'Po terminie';

  @override
  String get materialDeliveryReceived => 'Odebrana';

  @override
  String get materialDeliveryPlanned => 'Zaplanowana';

  @override
  String get materialReturnsTitle => 'Zwroty';

  @override
  String get materialAddReturnAction => 'Dodaj zwrot';

  @override
  String get materialNoReturns => 'Nie zapisano materiału do zwrotu.';

  @override
  String get materialReturnQuantityLabel => 'Ilość do zwrotu';

  @override
  String get materialReturnDeadlineLabel => 'Termin zwrotu';

  @override
  String get materialReturnExpectedLabel => 'Przewidywany zwrot pieniędzy';

  @override
  String get materialReturnReceiptRequired => 'Paragon lub faktura są wymagane';

  @override
  String get materialReturnDocumentLabel => 'Dokument zakupu';

  @override
  String get materialReturnCompletedToggle => 'Zwrot wykonany';

  @override
  String get materialReturnActualLabel => 'Faktycznie odzyskana kwota';

  @override
  String get materialReturnSaveAction => 'Zapisz zwrot';

  @override
  String get materialReturnSaveError => 'Nie udało się zapisać zwrotu.';

  @override
  String get materialReturnOverdue => 'Termin zwrotu minął';

  @override
  String get materialReturnCompleted => 'Zwrot wykonany';

  @override
  String get materialReturnPending => 'Do zwrotu';

  @override
  String get materialRecordDeleteTooltip => 'Usuń wpis';

  @override
  String get materialInvalidQuantity =>
      'Wpisz dodatnią ilość z maksymalnie sześcioma cyframi po przecinku.';

  @override
  String get materialDatePickTooltip => 'Wybierz datę';

  @override
  String get materialRelationMissing =>
      'Powiązany rekord został usunięty lub należy do innego projektu.';

  @override
  String get receiptStageLabel => 'Etap dokumentu';

  @override
  String get receiptApplyComponentLabel => 'Ustaw skład dla wszystkich pozycji';

  @override
  String get receiptComponentRequiredMessage =>
      'Wybierz materiał, robociznę albo wspólną wycenę dla każdej pozycji.';
}
