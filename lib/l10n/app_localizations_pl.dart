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
}
