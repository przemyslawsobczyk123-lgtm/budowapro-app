// Seeds one realistic but entirely fictional house-build project for the
// Google Play screenshots.
//
// Every row is written through the app's own repositories (the same code the
// UI uses), so the screenshots show exactly what a real user would see. The
// documents attached to costs and checklist items are generated locally: PDF
// pages with the bundled Roboto font and two procedurally drawn site photos.
// Names, companies and phone numbers are invented; the phone numbers follow
// an obviously fictional "+48 32 000 00 xx" pattern.

import 'dart:io';
import 'dart:math' as math;

import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const storeDemoProjectName = 'Dom jednorodzinny – Gliwice';

final class StoreDemoProject {
  const StoreDemoProject({
    required this.projectId,
    required this.currentStageId,
  });

  final String projectId;
  final String currentStageId;
}

/// Creates the screenshot project. Must run on an empty app database (fresh
/// install), before the app widget is pumped.
Future<StoreDemoProject> seedStoreDemoProject(
  ProviderContainer container,
) async {
  final seeder = _StoreDemoSeeder(
    projects: await container.read(projectRepositoryProvider.future),
    stages: await container.read(stageRepositoryProvider.future),
    costs: await container.read(costRepositoryProvider.future),
    contacts: await container.read(contactRepositoryProvider.future),
    schedule: await container.read(scheduleRepositoryProvider.future),
    documents: await container.read(documentRepositoryProvider.future),
    stager: await container.read(localAttachmentStagerProvider.future),
    clock: container.read(scheduleNotificationGatewayProvider),
  );
  return seeder.seed();
}

const _pln = 'PLN';

final class _StoreDemoSeeder {
  _StoreDemoSeeder({
    required this.projects,
    required this.stages,
    required this.costs,
    required this.contacts,
    required this.schedule,
    required this.documents,
    required this.stager,
    required this.clock,
  });

  final ProjectRepository projects;
  final StageRepository stages;
  final CostRepository costs;
  final ContactRepository contacts;
  final ScheduleRepository schedule;
  final DocumentRepository documents;
  final LocalAttachmentStager stager;
  final ScheduleNotificationGateway clock;

  late final String _timeZoneId;
  late final DateTime _today;
  late final String _projectId;
  late final Map<ProjectStageKey, ProjectStage> _stageByKey;
  late final pw.Font _font;
  late final Directory _workDirectory;
  final Map<String, String> _contactIds = <String, String>{};
  var _documentCounter = 0;

  Future<StoreDemoProject> seed() async {
    _timeZoneId = await clock.currentTimeZoneId();
    final now = clock.toTimeZone(DateTime.now().toUtc(), _timeZoneId);
    _today = DateTime(now.year, now.month, now.day);
    _font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    _workDirectory = await Directory(
      p.join((await getTemporaryDirectory()).path, 'store_demo_seed'),
    ).create(recursive: true);

    final project = await projects.create(
      ProjectDraft(
        name: storeDemoProjectName,
        locationLabel: 'Gliwice, os. Ostropa',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
        areaSquareMeters: 142,
        plannedBudgetMinorUnits: 780000 * 100,
        plannedStart: _at(-220),
        plannedEnd: _at(265),
        currentStage: ProjectStageKey.shellOpen,
      ),
    );
    _projectId = project.id;

    await _seedStages();
    await _seedContacts();
    await _seedCosts();
    await _seedChecklists();
    await _seedStandaloneDocuments();
    await _seedSchedule();

    if (await _workDirectory.exists()) {
      await _workDirectory.delete(recursive: true);
    }
    return StoreDemoProject(
      projectId: _projectId,
      currentStageId: _stage(ProjectStageKey.shellOpen).id,
    );
  }

  // ---------------------------------------------------------------- stages

  Future<void> _seedStages() async {
    final list = await stages.listStages(
      projectId: _projectId,
      template: ProjectTemplate.houseConstruction,
    );
    _stageByKey = <ProjectStageKey, ProjectStage>{
      for (final stage in list)
        if (stage.templateKey != null) stage.templateKey!: stage,
    };
    const plan = <ProjectStageKey, (StageStatus, int, int, int)>{
      ProjectStageKey.formalities: (StageStatus.completed, -400, -230, 28000),
      ProjectStageKey.sitePreparation: (
        StageStatus.completed,
        -225,
        -205,
        14000,
      ),
      ProjectStageKey.stateZero: (StageStatus.completed, -205, -120, 112000),
      ProjectStageKey.shellOpen: (StageStatus.inProgress, -115, 50, 186000),
      ProjectStageKey.shellClosed: (StageStatus.planned, 40, 110, 98000),
      ProjectStageKey.installations: (StageStatus.planned, 110, 170, 105000),
      ProjectStageKey.finishing: (StageStatus.planned, 170, 250, 185000),
      ProjectStageKey.handover: (StageStatus.planned, 250, 265, 4000),
    };
    for (final entry in plan.entries) {
      final (status, start, end, budget) = entry.value;
      await stages.updateStage(
        projectId: _projectId,
        stageId: _stage(entry.key).id,
        input: StageDetailsInput(
          status: status,
          plannedStart: _at(start),
          plannedEnd: _at(end),
          plannedBudgetMinorUnits: budget * 100,
        ),
      );
    }
  }

  ProjectStage _stage(ProjectStageKey key) {
    final stage = _stageByKey[key];
    if (stage == null) throw StateError('Missing template stage $key');
    return stage;
  }

  // -------------------------------------------------------------- contacts

  Future<void> _seedContacts() async {
    final specs =
        <
          (
            String,
            String,
            ContactKind,
            List<ContactRole>,
            List<ProjectStageKey>,
            String,
            String?,
          )
        >[
          (
            'manager',
            'mgr inż. Marek Zieliński',
            ContactKind.person,
            [ContactRole.siteManager],
            [
              ProjectStageKey.stateZero,
              ProjectStageKey.shellOpen,
              ProjectStageKey.shellClosed,
            ],
            '+48 32 000 00 11',
            'Wpisy do dziennika budowy i odbiory zbrojenia.',
          ),
          (
            'crew',
            'Ekipa budowlana Kowalczyk',
            ContactKind.company,
            [ContactRole.generalContractor],
            [ProjectStageKey.stateZero, ProjectStageKey.shellOpen],
            '+48 32 000 00 12',
            'Stan zero i stan surowy otwarty wg umowy.',
          ),
          (
            'wholesale',
            'Hurtownia Budowlana Ostoja',
            ContactKind.company,
            [ContactRole.supplier],
            [ProjectStageKey.stateZero, ProjectStageKey.shellOpen],
            '+48 32 000 00 13',
            'Stal, bloczki, strop. Transport HDS.',
          ),
          (
            'concrete',
            'Betoniarnia Kłodnica',
            ContactKind.company,
            [ContactRole.supplier],
            [ProjectStageKey.stateZero, ProjectStageKey.shellOpen],
            '+48 32 000 00 14',
            'Beton z pompą, zamówienie min. 2 dni wcześniej.',
          ),
          (
            'roofer',
            'Dekarstwo Wiśniewski',
            ContactKind.company,
            [ContactRole.roofer],
            [ProjectStageKey.shellOpen, ProjectStageKey.shellClosed],
            '+48 32 000 00 15',
            null,
          ),
          (
            'windows',
            'Okna Brzozowski',
            ContactKind.company,
            [ContactRole.supplier],
            [ProjectStageKey.shellClosed],
            '+48 32 000 00 16',
            null,
          ),
          (
            'architect',
            'Pracownia Projektowa Linia',
            ContactKind.company,
            [ContactRole.architect],
            [ProjectStageKey.formalities],
            '+48 32 000 00 17',
            null,
          ),
          (
            'surveyor',
            'GeoPunkt – usługi geodezyjne',
            ContactKind.company,
            [ContactRole.surveyor],
            [
              ProjectStageKey.formalities,
              ProjectStageKey.sitePreparation,
              ProjectStageKey.stateZero,
            ],
            '+48 32 000 00 18',
            null,
          ),
          (
            'electrician',
            'Elektro-Instal Nowak',
            ContactKind.company,
            [ContactRole.electrician],
            [ProjectStageKey.installations],
            '+48 32 000 00 19',
            null,
          ),
        ];
    for (final (key, name, kind, roles, stageKeys, phone, note) in specs) {
      final contact = await contacts.create(
        projectId: _projectId,
        draft: ContactDraft(
          displayName: name,
          kind: kind,
          roles: roles,
          stageIds: stageKeys.map((stage) => _stage(stage).id),
          phone: phone,
          note: note,
        ),
      );
      _contactIds[key] = contact.id;
    }
  }

  // ----------------------------------------------------------------- costs

  Future<void> _seedCosts() async {
    for (final spec in _costSpecs) {
      final attachmentIds = <String>[];
      final document = spec.document;
      if (document != null) {
        attachmentIds.add(
          await _stagePdfDocument(
            document,
            amountMinor: spec.grossMinor,
            vat: spec.vat,
            stageKey: spec.stage,
          ),
        );
      }
      final input = CostEntryInput(
        projectId: _projectId,
        name: spec.name,
        type: spec.type,
        component: spec.component,
        status: spec.source == CostSource.manual
            ? spec.status
            : CostStatus.planned,
        amount: VatBreakdown.fromGross(
          Money(minorUnits: spec.grossMinor, currencyCode: _pln),
          spec.vat,
        ),
        entryDate: _at(spec.day),
        stageId: _stage(spec.stage).id,
        contactId: spec.contact == null ? null : _contactIds[spec.contact],
        paymentMethod: spec.payment,
        source: spec.source,
        attachmentIds: attachmentIds,
        note: spec.note,
      );
      if (spec.source == CostSource.manual) {
        await costs.create(ConfirmedCostEntryInput(input));
      } else {
        // OCR entries always pass through the review draft, as in the app.
        final draft = await costs.saveDraft(CostDraftInput(input));
        await costs.confirmDraft(
          projectId: _projectId,
          costEntryId: draft.id,
          status: spec.status,
        );
      }
    }
  }

  // ------------------------------------------------------------ checklists

  Future<void> _seedChecklists() async {
    for (final key in const [
      ProjectStageKey.formalities,
      ProjectStageKey.sitePreparation,
      ProjectStageKey.stateZero,
    ]) {
      final items = await stages.listChecklistItems(
        projectId: _projectId,
        stageId: _stage(key).id,
      );
      await stages.completeChecklistItems(
        projectId: _projectId,
        checklistItemIds: items.map((item) => item.id).toList(),
      );
    }

    final shellOpen = _stage(ProjectStageKey.shellOpen);
    final templateItems = {
      for (final item in await stages.listChecklistItems(
        projectId: _projectId,
        stageId: shellOpen.id,
      ))
        if (item.templateKey != null) item.templateKey!: item,
    };

    final structural =
        templateItems[ChecklistTemplateKey.shellStructuralAcceptance]!;
    await _attachEvidence(
      structural,
      await _stagePhoto(
        fileName: 'IMG_20261_zbrojenie_wienca.jpg',
        title: 'Zdjęcie – zbrojenie wieńca nad parterem',
        day: -12,
        jpeg: _rebarPhoto(),
      ),
    );
    await _updateItem(
      structural,
      status: ChecklistStatus.inProgress,
      due: 4,
      assignee: 'mgr inż. Marek Zieliński',
    );

    await _updateItem(
      templateItems[ChecklistTemplateKey.roofWeatherProtection]!,
      status: ChecklistStatus.todo,
      due: 45,
      assignee: 'Dekarstwo Wiśniewski',
    );

    final openings =
        templateItems[ChecklistTemplateKey.openingAndShadingPreparation]!;
    await _attachEvidence(
      openings,
      await _stagePdfDocument(
        const _DocumentSpec(
          fileName: 'uzgodnienie_otworow_okiennych.pdf',
          title: 'Protokół uzgodnień – otwory okienne i rolety',
          type: ProjectDocumentType.protocol,
          heading: 'PROTOKÓŁ',
          number: 'UZG/07/2026',
          issuer: 'Okna Brzozowski',
          day: -60,
          accent: PdfColors.teal700,
          lines: <String>[
            'Pomiar otworów okiennych parteru – 11 szt.',
            'Nadproża pod rolety zewnętrzne – skrzynki podtynkowe',
            'Ciepły montaż w warstwie izolacji – taśmy paroszczelne',
            'Termin dostawy okien uzgodniony z ekipą budowlaną',
          ],
        ),
        stageKey: ProjectStageKey.shellOpen,
      ),
    );
    await _updateItem(openings, status: ChecklistStatus.completed);

    final safety = templateItems[ChecklistTemplateKey.shellSafetyAndAccess]!;
    await _attachEvidence(
      safety,
      await _stagePhoto(
        fileName: 'IMG_20262_zabezpieczenie_otworow.jpg',
        title: 'Zdjęcie – zabezpieczenie otworów i krawędzi',
        day: -38,
        jpeg: _openingPhoto(),
      ),
    );
    await _updateItem(safety, status: ChecklistStatus.completed);

    await stages.addChecklistItem(
      projectId: _projectId,
      stageId: shellOpen.id,
      title: 'Mury nośne parteru – kontrola pionów i nadproży',
      input: ChecklistItemDetailsInput(
        status: ChecklistStatus.completed,
        importance: ChecklistImportance.normal,
        evidenceRequirement: EvidenceRequirement.none,
        assignee: 'Ekipa budowlana Kowalczyk',
        riskIfSkipped:
            'Odchyłki ścian i źle osadzone nadproża przenoszą się na strop i dach.',
      ),
    );
    await stages.addChecklistItem(
      projectId: _projectId,
      stageId: shellOpen.id,
      title: 'Zbrojenie wieńca i stropu nad parterem',
      input: ChecklistItemDetailsInput(
        status: ChecklistStatus.inProgress,
        importance: ChecklistImportance.high,
        evidenceRequirement: EvidenceRequirement.none,
        dueDate: _at(4),
        assignee: 'Ekipa budowlana Kowalczyk',
        riskIfSkipped:
            'Betonowanie bez odbioru zbrojenia uniemożliwia późniejszą kontrolę.',
      ),
    );
    await stages.addChecklistItem(
      projectId: _projectId,
      stageId: shellOpen.id,
      title: 'Zamówienie więźby dachowej',
      input: ChecklistItemDetailsInput(
        status: ChecklistStatus.todo,
        importance: ChecklistImportance.normal,
        evidenceRequirement: EvidenceRequirement.none,
        dueDate: _at(14),
        assignee: 'Dekarstwo Wiśniewski',
        riskIfSkipped:
            'Drewno zamówione za późno opóźnia zamknięcie budynku przed zimą.',
      ),
    );
  }

  Future<void> _attachEvidence(ChecklistItem item, String attachmentId) {
    return stages.attachEvidence(
      projectId: _projectId,
      checklistItemId: item.id,
      attachmentId: attachmentId,
    );
  }

  Future<void> _updateItem(
    ChecklistItem item, {
    required ChecklistStatus status,
    int? due,
    String? assignee,
  }) {
    return stages.updateChecklistItem(
      projectId: _projectId,
      checklistItemId: item.id,
      input: ChecklistItemDetailsInput(
        status: status,
        importance: item.importance,
        evidenceRequirement: item.evidenceRequirement,
        dueDate: due == null ? null : _at(due),
        assignee: assignee,
      ),
    );
  }

  // -------------------------------------------------- standalone documents

  Future<void> _seedStandaloneDocuments() async {
    final specs = <(_DocumentSpec, ProjectStageKey, String?)>[
      (
        const _DocumentSpec(
          fileName: 'notatka_wizyta_kierownika.pdf',
          title: 'Notatka z wizyty kierownika budowy',
          type: ProjectDocumentType.protocol,
          heading: 'NOTATKA',
          number: 'KB/14/2026',
          issuer: 'Kierownik budowy',
          day: -1,
          accent: PdfColors.indigo700,
          lines: <String>[
            'Sprawdzono piony i nadproża ścian parteru – bez uwag',
            'Zbrojenie wieńca do uzupełnienia w narożnikach',
            'Odbiór zbrojenia stropu przed betonowaniem',
            'Wpis do dziennika budowy, str. 14',
          ],
        ),
        ProjectStageKey.shellOpen,
        'manager',
      ),
      (
        const _DocumentSpec(
          fileName: 'umowa_okna_pcv.pdf',
          title: 'Umowa – okna PCV z montażem',
          type: ProjectDocumentType.contract,
          heading: 'UMOWA',
          number: '118/2026',
          issuer: 'Okna Brzozowski',
          day: -25,
          accent: PdfColors.teal700,
          lines: <String>[
            'Przedmiot: 11 okien PCV i drzwi tarasowe',
            'Montaż ciepły w warstwie izolacji',
            'Zaliczka 30% przy zamówieniu, reszta po montażu',
            'Gwarancja na okna i montaż: 5 lat',
          ],
        ),
        ProjectStageKey.shellClosed,
        'windows',
      ),
      (
        const _DocumentSpec(
          fileName: 'gwarancja_hydroizolacja.pdf',
          title: 'Gwarancja – hydroizolacja fundamentów',
          type: ProjectDocumentType.warranty,
          heading: 'GWARANCJA',
          number: 'GW/03/2026',
          issuer: 'Ekipa budowlana Kowalczyk',
          day: -150,
          accent: PdfColors.blueGrey700,
          lines: <String>[
            'Izolacja pionowa i pozioma ław oraz ścian fundamentowych',
            'Okres gwarancji: 5 lat od odbioru stanu zero',
            'Warunek: zachowanie ciągłości izolacji przy przepustach',
          ],
        ),
        ProjectStageKey.stateZero,
        'crew',
      ),
      (
        const _DocumentSpec(
          fileName: 'pozwolenie_na_budowe.pdf',
          title: 'Pozwolenie na budowę – decyzja',
          type: ProjectDocumentType.other,
          heading: 'DECYZJA',
          number: 'AB.6740.2026',
          issuer: 'Starostwo – wydział budownictwa',
          day: -262,
          accent: PdfColors.grey700,
          lines: <String>[
            'Zatwierdzenie projektu zagospodarowania działki',
            'Pozwolenie na budowę budynku mieszkalnego jednorodzinnego',
            'Decyzja ostateczna',
          ],
        ),
        ProjectStageKey.formalities,
        'architect',
      ),
    ];
    for (final (spec, stageKey, contactKey) in specs) {
      await _stagePdfDocument(
        spec,
        stageKey: stageKey,
        contactKey: contactKey,
        warrantyYears: spec.type == ProjectDocumentType.warranty ? 5 : null,
      );
    }
  }

  // --------------------------------------------------------------- schedule

  Future<void> _seedSchedule() async {
    final shellOpenId = _stage(ProjectStageKey.shellOpen).id;
    final events =
        <
          (
            String,
            ScheduleEventKind,
            ScheduleEventStatus,
            int,
            int?,
            int,
            String,
            int,
          )
        >[
          (
            'Montaż szalunków wieńca',
            ScheduleEventKind.task,
            ScheduleEventStatus.inProgress,
            0,
            7,
            30,
            'Ekipa budowlana Kowalczyk',
            0,
          ),
          (
            'Dostawa stempli i desek szalunkowych',
            ScheduleEventKind.delivery,
            ScheduleEventStatus.planned,
            0,
            13,
            0,
            'Hurtownia Budowlana Ostoja',
            60,
          ),
          (
            'Dostawa stropu Teriva',
            ScheduleEventKind.delivery,
            ScheduleEventStatus.planned,
            1,
            7,
            0,
            'Hurtownia Budowlana Ostoja',
            120,
          ),
          (
            'Układanie belek i pustaków stropowych',
            ScheduleEventKind.task,
            ScheduleEventStatus.planned,
            2,
            8,
            0,
            'Ekipa budowlana Kowalczyk',
            0,
          ),
          (
            'Odbiór zbrojenia stropu i wieńca',
            ScheduleEventKind.acceptance,
            ScheduleEventStatus.planned,
            4,
            10,
            0,
            'mgr inż. Marek Zieliński',
            1440,
          ),
          (
            'Betonowanie stropu i wieńca',
            ScheduleEventKind.task,
            ScheduleEventStatus.planned,
            5,
            7,
            30,
            'Betoniarnia Kłodnica',
            1440,
          ),
          (
            'Wizyta dekarza – pomiar więźby',
            ScheduleEventKind.visit,
            ScheduleEventStatus.planned,
            5,
            16,
            0,
            'Dekarstwo Wiśniewski',
            60,
          ),
          (
            'Płatność – stal zbrojeniowa',
            ScheduleEventKind.payment,
            ScheduleEventStatus.planned,
            6,
            null,
            0,
            'Hurtownia Budowlana Ostoja',
            0,
          ),
          (
            'Spotkanie z elektrykiem – rozmieszczenie gniazd',
            ScheduleEventKind.visit,
            ScheduleEventStatus.planned,
            12,
            17,
            0,
            'Elektro-Instal Nowak',
            120,
          ),
          (
            'Montaż więźby dachowej',
            ScheduleEventKind.task,
            ScheduleEventStatus.planned,
            26,
            7,
            0,
            'Dekarstwo Wiśniewski',
            1440,
          ),
          (
            'Odbiór ścian parteru',
            ScheduleEventKind.acceptance,
            ScheduleEventStatus.completed,
            -9,
            11,
            0,
            'mgr inż. Marek Zieliński',
            0,
          ),
        ];
    for (final (title, kind, status, day, hour, minute, assignee, lead)
        in events) {
      final allDay = hour == null;
      await schedule.create(
        projectId: _projectId,
        input: ScheduleEventInput(
          title: title,
          kind: kind,
          status: status,
          startsAt: clock.fromWallTime(
            _wall(_siteDay(day), hour ?? 0, minute),
            _timeZoneId,
          ),
          timeZoneId: _timeZoneId,
          isAllDay: allDay,
          stageId: shellOpenId,
          assignee: assignee,
          reminderEnabled: lead > 0,
          reminderLeadMinutes: lead,
        ),
      );
    }
  }

  // ------------------------------------------------------------ attachments

  Future<String> _stagePdfDocument(
    _DocumentSpec spec, {
    required ProjectStageKey stageKey,
    int? amountMinor,
    VatRate? vat,
    String? contactKey,
    int? warrantyYears,
  }) async {
    final bytes = await _documentPdf(spec, amountMinor: amountMinor, vat: vat);
    final attachmentId = await _stageFile(
      spec.fileName,
      bytes,
      mediaType: 'application/pdf',
    );
    final documentDate = _at(spec.day);
    await documents.saveDetails(
      projectId: _projectId,
      documentId: attachmentId,
      metadata: DocumentMetadata(
        title: spec.title,
        type: spec.type,
        documentDate: documentDate,
        warrantyStartsAt: warrantyYears == null ? null : documentDate,
        warrantyEndsAt: warrantyYears == null
            ? null
            : _at(spec.day + 365 * warrantyYears),
      ),
      contextLinks: <DocumentRelation>[
        DocumentRelation(
          type: DocumentRelationType.stage,
          targetId: _stage(stageKey).id,
          label: _stageLabels[stageKey]!,
        ),
        if (contactKey != null)
          DocumentRelation(
            type: DocumentRelationType.contact,
            targetId: _contactIds[contactKey]!,
            label: _contactLabels[contactKey]!,
          ),
      ],
    );
    return attachmentId;
  }

  Future<String> _stagePhoto({
    required String fileName,
    required String title,
    required int day,
    required List<int> jpeg,
  }) async {
    final attachmentId = await _stageFile(
      fileName,
      jpeg,
      mediaType: 'image/jpeg',
      source: LocalAttachmentSource.camera,
    );
    await documents.saveDetails(
      projectId: _projectId,
      documentId: attachmentId,
      metadata: DocumentMetadata(
        title: title,
        type: ProjectDocumentType.photo,
        documentDate: _at(day),
      ),
      contextLinks: <DocumentRelation>[
        DocumentRelation(
          type: DocumentRelationType.stage,
          targetId: _stage(ProjectStageKey.shellOpen).id,
          label: _stageLabels[ProjectStageKey.shellOpen]!,
        ),
      ],
    );
    return attachmentId;
  }

  Future<String> _stageFile(
    String fileName,
    List<int> bytes, {
    required String mediaType,
    LocalAttachmentSource source = LocalAttachmentSource.filePicker,
  }) async {
    _documentCounter++;
    final file = File(
      p.join(_workDirectory.path, '${_documentCounter}_$fileName'),
    );
    await file.writeAsBytes(bytes, flush: true);
    final staged = await stager.stage(
      projectId: _projectId,
      pickedFile: PickedLocalAttachment(
        sourceUri: file.uri,
        displayName: fileName,
        reportedByteSize: await file.length(),
        mediaType: mediaType,
        source: source,
      ),
    );
    await file.delete();
    return staged.id;
  }

  // ------------------------------------------------------------- generators

  Future<List<int>> _documentPdf(
    _DocumentSpec spec, {
    int? amountMinor,
    VatRate? vat,
  }) {
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: _font, bold: _font),
    );
    final dateLabel = _dateLabel(_wall(spec.day));
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              color: spec.accent,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    spec.issuer,
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 15,
                    ),
                  ),
                  pw.Text(
                    spec.heading,
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Text(
              '${spec.heading} nr ${spec.number}',
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Data: $dateLabel · Gliwice'),
            pw.SizedBox(height: 18),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _pdfBox('Wystawca', spec.issuer)),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: _pdfBox(
                    'Odbiorca',
                    'Inwestor prywatny – budowa domu jednorodzinnego',
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 22),
            if (amountMinor != null && vat != null)
              ..._invoiceTable(spec, amountMinor, vat)
            else
              ...spec.lines.map(
                (line) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 9),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 6,
                        height: 6,
                        margin: const pw.EdgeInsets.only(top: 5, right: 10),
                        color: spec.accent,
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          line,
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            pw.Spacer(),
            pw.Divider(color: PdfColors.grey400),
            pw.Text(
              'Strona 1 z 1',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );
    return document.save();
  }

  List<pw.Widget> _invoiceTable(
    _DocumentSpec spec,
    int grossMinor,
    VatRate vat,
  ) {
    final breakdown = VatBreakdown.fromGross(
      Money(minorUnits: grossMinor, currencyCode: _pln),
      vat,
    );
    final vatLabel = '${vat.basisPoints ~/ 100}%';
    return <pw.Widget>[
      pw.TableHelper.fromTextArray(
        headers: const <String>['Lp.', 'Nazwa', 'Netto', 'VAT', 'Brutto'],
        data: <List<String>>[
          <String>[
            '1',
            spec.lines.isEmpty ? spec.title : spec.lines.first,
            _money(breakdown.net.minorUnits),
            vatLabel,
            _money(grossMinor),
          ],
        ],
        headerStyle: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
        headerDecoration: pw.BoxDecoration(color: spec.accent),
        cellStyle: const pw.TextStyle(fontSize: 10),
        cellAlignments: const <int, pw.Alignment>{
          0: pw.Alignment.center,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
        },
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      ),
      pw.SizedBox(height: 14),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Razem do zapłaty: ${_money(grossMinor)}',
          style: const pw.TextStyle(fontSize: 15),
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'w tym VAT $vatLabel: ${_money(breakdown.vat.minorUnits)}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ),
    ];
  }

  pw.Widget _pdfBox(String label, String value) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    ),
  );

  /// Ceiling reinforcement seen from above: block infill in perspective with
  /// a rusty rebar grid on top.
  List<int> _rebarPhoto() {
    const width = 1280;
    const height = 960;
    final random = math.Random(41);
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(132, 128, 122));
    // Hollow ceiling blocks in rows that grow towards the camera.
    var y = 0.0;
    var row = 0;
    while (y < height) {
      final rowHeight = 70 + y * 0.16;
      final blockWidth = 150 + y * 0.22;
      final offset = row.isEven ? 0.0 : blockWidth / 2;
      for (var x = -offset; x < width; x += blockWidth) {
        final tone = 150 + random.nextInt(22);
        img.fillRect(
          image,
          x1: (x + 5).round(),
          y1: (y + 4).round(),
          x2: (x + blockWidth - 5).round(),
          y2: (y + rowHeight - 4).round(),
          color: img.ColorRgb8(tone, tone - 6, tone - 14),
        );
      }
      y += rowHeight;
      row++;
    }
    // Longitudinal bars converging to a vanishing point above the frame.
    const vanishX = width / 2;
    const vanishDistance = 1400.0;
    for (var i = -6; i <= 6; i++) {
      final bottomX = vanishX + i * 165.0;
      final topX =
          vanishX +
          (bottomX - vanishX) * (vanishDistance / (vanishDistance + height));
      _bar(image, topX.round(), 0, bottomX.round(), height, 9);
    }
    // Transverse bars, spaced wider towards the camera.
    var barY = 30.0;
    while (barY < height) {
      _bar(image, 0, barY.round(), width, (barY + 6).round(), 8);
      barY += 60 + barY * 0.12;
    }
    _finishPhoto(image, random);
    return img.encodeJpg(image, quality: 86);
  }

  /// Sand-lime block wall with a window opening closed by a striped barrier.
  List<int> _openingPhoto() {
    const width = 1280;
    const height = 960;
    final random = math.Random(17);
    final image = img.Image(width: width, height: height);
    const horizon = 330;
    for (var y = 0; y < horizon; y++) {
      final t = y / horizon;
      img.fillRect(
        image,
        x1: 0,
        y1: y,
        x2: width - 1,
        y2: y,
        color: img.ColorRgb8(
          (122 + 98 * t).round(),
          (168 + 66 * t).round(),
          (222 + 22 * t).round(),
        ),
      );
    }
    img.fillRect(
      image,
      x1: 0,
      y1: horizon,
      x2: width - 1,
      y2: height - 1,
      color: img.ColorRgb8(176, 172, 164),
    );
    const blockHeight = 118;
    const blockWidth = 250;
    for (var y = horizon, row = 0; y < height; y += blockHeight, row++) {
      final offset = row.isEven ? 0 : blockWidth ~/ 2;
      for (var x = -offset; x < width; x += blockWidth) {
        final tone = 214 + random.nextInt(18);
        img.fillRect(
          image,
          x1: x + 4,
          y1: y + 4,
          x2: x + blockWidth - 4,
          y2: y + blockHeight - 4,
          color: img.ColorRgb8(tone, tone - 4, tone - 16),
        );
      }
    }
    // Window opening with a lintel.
    img.fillRect(
      image,
      x1: 430,
      y1: 420,
      x2: 860,
      y2: 900,
      color: img.ColorRgb8(58, 56, 54),
    );
    img.fillRect(
      image,
      x1: 400,
      y1: 380,
      x2: 890,
      y2: 420,
      color: img.ColorRgb8(150, 150, 146),
    );
    // Red and white barrier boards across the opening.
    for (final barrierY in const [560, 720]) {
      for (var x = 380; x < 910; x++) {
        for (var dy = 0; dy < 34; dy++) {
          final red = ((x + dy) ~/ 38).isEven;
          image.setPixelRgb(
            x,
            barrierY + dy,
            red ? 196 : 238,
            red ? 42 : 236,
            red ? 36 : 230,
          );
        }
      }
    }
    _finishPhoto(image, random);
    return img.encodeJpg(image, quality: 86);
  }

  void _bar(img.Image image, int x1, int y1, int x2, int y2, int thickness) {
    img.drawLine(
      image,
      x1: x1 + 3,
      y1: y1 + 4,
      x2: x2 + 3,
      y2: y2 + 4,
      color: img.ColorRgb8(70, 66, 60),
      thickness: thickness,
    );
    img.drawLine(
      image,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: img.ColorRgb8(118, 64, 38),
      thickness: thickness,
    );
    img.drawLine(
      image,
      x1: x1 - 2,
      y1: y1 - 2,
      x2: x2 - 2,
      y2: y2 - 2,
      color: img.ColorRgb8(170, 108, 70),
      thickness: 2,
    );
  }

  void _finishPhoto(img.Image image, math.Random random) {
    img.noise(image, 9, random: random);
    img.gaussianBlur(image, radius: 1);
    final cx = image.width / 2;
    final cy = image.height / 2;
    final maxDistance = math.sqrt(cx * cx + cy * cy);
    for (final pixel in image) {
      final dx = pixel.x - cx;
      final dy = pixel.y - cy;
      final factor =
          1 - 0.32 * math.pow(math.sqrt(dx * dx + dy * dy) / maxDistance, 2);
      pixel
        ..r = pixel.r * factor
        ..g = pixel.g * factor
        ..b = pixel.b * factor;
    }
  }

  // ----------------------------------------------------------------- helpers

  DateTime _wall(int day, [int hour = 12, int minute = 0]) =>
      DateTime(_today.year, _today.month, _today.day + day, hour, minute);

  /// Keeps site events off Sundays (moved to Monday) whatever day the
  /// harness runs on; today's events stay on today.
  int _siteDay(int day) {
    if (day == 0) return day;
    return _wall(day).weekday == DateTime.sunday ? day + 1 : day;
  }

  DateTime _at(int day) => clock.fromWallTime(_wall(day), _timeZoneId);

  static String _dateLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.${value.year}';

  static String _money(int minorUnits) {
    final whole = (minorUnits ~/ 100).toString();
    final fraction = (minorUnits % 100).toString().padLeft(2, '0');
    final groups = <String>[];
    for (var end = whole.length; end > 0; end -= 3) {
      groups.insert(0, whole.substring(math.max(0, end - 3), end));
    }
    return '${groups.join(' ')},$fraction zł';
  }
}

const _stageLabels = <ProjectStageKey, String>{
  ProjectStageKey.formalities: 'Formalności',
  ProjectStageKey.sitePreparation: 'Przygotowanie placu',
  ProjectStageKey.stateZero: 'Stan zero',
  ProjectStageKey.shellOpen: 'Stan surowy otwarty',
  ProjectStageKey.shellClosed: 'Stan surowy zamknięty',
  ProjectStageKey.installations: 'Instalacje',
  ProjectStageKey.finishing: 'Wykończenie',
  ProjectStageKey.handover: 'Odbiór',
};

const _contactLabels = <String, String>{
  'manager': 'mgr inż. Marek Zieliński',
  'crew': 'Ekipa budowlana Kowalczyk',
  'wholesale': 'Hurtownia Budowlana Ostoja',
  'concrete': 'Betoniarnia Kłodnica',
  'roofer': 'Dekarstwo Wiśniewski',
  'windows': 'Okna Brzozowski',
  'architect': 'Pracownia Projektowa Linia',
  'surveyor': 'GeoPunkt – usługi geodezyjne',
  'electrician': 'Elektro-Instal Nowak',
};

final class _DocumentSpec {
  const _DocumentSpec({
    required this.fileName,
    required this.title,
    required this.type,
    required this.heading,
    required this.number,
    required this.issuer,
    required this.day,
    required this.accent,
    this.lines = const <String>[],
  });

  final String fileName;
  final String title;
  final ProjectDocumentType type;
  final String heading;
  final String number;
  final String issuer;
  final int day;
  final PdfColor accent;
  final List<String> lines;
}

final class _CostSpec {
  _CostSpec(
    this.name,
    this.grossMinor,
    this.vat,
    this.component,
    this.stage,
    this.type,
    this.status,
    this.day, {
    this.note,
    this.contact,
    this.payment,
    this.source = CostSource.manual,
    this.document,
  });

  final String name;
  final int grossMinor;
  final VatRate vat;
  final CostComponent component;
  final ProjectStageKey stage;
  final CostEntryType type;
  final CostStatus status;
  final int day;
  final String? note;
  final String? contact;
  final CostPaymentMethod? payment;
  final CostSource source;
  final _DocumentSpec? document;
}

_DocumentSpec _invoice(
  String fileName,
  String title,
  String number,
  String issuer,
  int day,
  PdfColor accent,
  String line,
) => _DocumentSpec(
  fileName: fileName,
  title: title,
  type: ProjectDocumentType.invoice,
  heading: 'FAKTURA VAT',
  number: number,
  issuer: issuer,
  day: day,
  accent: accent,
  lines: <String>[line],
);

const _vat23 = VatRate.standard23;
const _vat8 = VatRate.reduced8;
const _cost = CostEntryType.cost;
const _planned = CostEntryType.planned;
const _material = CostComponent.material;
const _labor = CostComponent.labor;
const _mixed = CostComponent.mixed;
const _transfer = CostPaymentMethod.bankTransfer;

final _costSpecs = <_CostSpec>[
  // Formalities.
  _CostSpec(
    'Projekt domu z adaptacją do działki',
    1490000,
    _vat23,
    _labor,
    ProjectStageKey.formalities,
    _cost,
    CostStatus.paid,
    -330,
    note: 'Projekt gotowy z adaptacją, umowa 14/2025.',
    contact: 'architect',
    payment: _transfer,
    document: _invoice(
      'FV_2025_11_031.pdf',
      'Faktura – projekt i adaptacja',
      'FV/2025/11/031',
      'Pracownia Projektowa Linia',
      -330,
      PdfColors.deepPurple700,
      'Projekt budowlany z adaptacją do warunków działki',
    ),
  ),
  _CostSpec(
    'Mapa do celów projektowych',
    190000,
    _vat23,
    _labor,
    ProjectStageKey.formalities,
    _cost,
    CostStatus.paid,
    -360,
    note: 'Mapa zasadnicza z uzgodnieniem w starostwie.',
    contact: 'surveyor',
    payment: _transfer,
    document: _invoice(
      'FV_2025_10_118.pdf',
      'Faktura – mapa do celów projektowych',
      'FV/2025/10/118',
      'GeoPunkt – usługi geodezyjne',
      -360,
      PdfColors.green800,
      'Mapa do celów projektowych',
    ),
  ),
  _CostSpec(
    'Badania geotechniczne gruntu',
    246000,
    _vat23,
    _labor,
    ProjectStageKey.formalities,
    _cost,
    CostStatus.paid,
    -352,
    note: 'Trzy odwierty do 4 m, opinia geotechniczna.',
    payment: _transfer,
    document: _invoice(
      'FV_2025_10_204.pdf',
      'Faktura – badania geotechniczne',
      'FV/2025/10/204',
      'Pracownia geotechniczna',
      -352,
      PdfColors.brown700,
      'Badania podłoża gruntowego z opinią',
    ),
  ),
  // Site preparation.
  _CostSpec(
    'Ogrodzenie tymczasowe placu budowy',
    369000,
    _vat23,
    _material,
    ProjectStageKey.sitePreparation,
    _cost,
    CostStatus.paid,
    -218,
    note: 'Panele ażurowe 60 m z bramą wjazdową.',
    contact: 'wholesale',
    payment: _transfer,
    document: _invoice(
      'FV_2026_03_077.pdf',
      'Faktura – ogrodzenie tymczasowe',
      'FV/2026/03/077',
      'Hurtownia Budowlana Ostoja',
      -218,
      PdfColors.orange800,
      'Panele ogrodzeniowe z bramą, 60 m',
    ),
  ),
  _CostSpec(
    'Przyłącze prądu budowlanego i rozdzielnica',
    430000,
    _vat23,
    _mixed,
    ProjectStageKey.sitePreparation,
    _cost,
    CostStatus.paid,
    -214,
    note: 'Rozdzielnica budowlana z montażem i pomiarami.',
    contact: 'electrician',
    payment: _transfer,
    document: _invoice(
      'FV_2026_03_112.pdf',
      'Faktura – prąd budowlany',
      'FV/2026/03/112',
      'Elektro-Instal Nowak',
      -214,
      PdfColors.amber800,
      'Rozdzielnica budowlana z montażem',
    ),
  ),
  _CostSpec(
    'Tyczenie budynku – geodeta',
    160000,
    _vat23,
    _labor,
    ProjectStageKey.sitePreparation,
    _cost,
    CostStatus.paid,
    -210,
    note: 'Wytyczenie osi i ław, wpis do dziennika budowy.',
    contact: 'surveyor',
    payment: _transfer,
    document: _invoice(
      'FV_2026_03_141.pdf',
      'Faktura – tyczenie budynku',
      'FV/2026/03/141',
      'GeoPunkt – usługi geodezyjne',
      -210,
      PdfColors.green800,
      'Geodezyjne wytyczenie budynku',
    ),
  ),
  // Foundations.
  _CostSpec(
    'Wykopy pod ławy fundamentowe',
    890000,
    _vat8,
    _labor,
    ProjectStageKey.stateZero,
    _cost,
    CostStatus.paid,
    -201,
    note: 'Koparka przez 3 dni, wywóz urobku.',
    contact: 'crew',
    payment: _transfer,
    document: _invoice(
      'FV_2026_03_208.pdf',
      'Faktura – wykopy fundamentowe',
      'FV/2026/03/208',
      'Ekipa budowlana Kowalczyk',
      -201,
      PdfColors.blue800,
      'Roboty ziemne pod ławy fundamentowe',
    ),
  ),
  _CostSpec(
    'Stal zbrojeniowa – ławy i ściany fundamentowe',
    1128450,
    _vat23,
    _material,
    ProjectStageKey.stateZero,
    _cost,
    CostStatus.paid,
    -196,
    note: '2,4 t stali fi 12 i fi 6 z cięciem.',
    contact: 'wholesale',
    payment: _transfer,
    source: CostSource.invoiceOcr,
    document: _invoice(
      'FV_2026_04_019.pdf',
      'Faktura – stal zbrojeniowa (fundamenty)',
      'FV/2026/04/019',
      'Hurtownia Budowlana Ostoja',
      -196,
      PdfColors.orange800,
      'Pręty żebrowane B500SP fi 12 i fi 6',
    ),
  ),
  _CostSpec(
    'Beton C20/25 – ławy fundamentowe',
    1864000,
    _vat23,
    _material,
    ProjectStageKey.stateZero,
    _cost,
    CostStatus.paid,
    -190,
    note: '38 m³ betonu z pompą.',
    contact: 'concrete',
    payment: _transfer,
    source: CostSource.invoiceOcr,
    document: _invoice(
      'FV_2026_04_064.pdf',
      'Faktura – beton C20/25 (ławy)',
      'FV/2026/04/064',
      'Betoniarnia Kłodnica',
      -190,
      PdfColors.blueGrey800,
      'Beton C20/25 z pompą, 38 m³',
    ),
  ),
  _CostSpec(
    'Bloczki betonowe fundamentowe',
    792180,
    _vat23,
    _material,
    ProjectStageKey.stateZero,
    _cost,
    CostStatus.paid,
    -183,
    note: '1650 szt. M6 z transportem.',
    contact: 'wholesale',
    payment: _transfer,
    document: _invoice(
      'FV_2026_04_102.pdf',
      'Faktura – bloczki fundamentowe',
      'FV/2026/04/102',
      'Hurtownia Budowlana Ostoja',
      -183,
      PdfColors.orange800,
      'Bloczek betonowy M6, 1650 szt.',
    ),
  ),
  _CostSpec(
    'Kanalizacja podposadzkowa i przepusty',
    524000,
    _vat23,
    _mixed,
    ProjectStageKey.stateZero,
    _cost,
    CostStatus.paid,
    -176,
    note: 'Rury PVC 110 i 160, przepusty mediów.',
    payment: _transfer,
    document: _invoice(
      'FV_2026_04_133.pdf',
      'Faktura – kanalizacja podposadzkowa',
      'FV/2026/04/133',
      'Instalacje sanitarne',
      -176,
      PdfColors.cyan800,
      'Kanalizacja podposadzkowa z przepustami',
    ),
  ),
  _CostSpec(
    'Izolacja przeciwwilgociowa i XPS',
    687315,
    _vat23,
    _material,
    ProjectStageKey.stateZero,
    _cost,
    CostStatus.paid,
    -170,
    note: 'Masa bitumiczna, papa, XPS 10 cm.',
    contact: 'wholesale',
    payment: _transfer,
    document: _invoice(
      'FV_2026_04_171.pdf',
      'Faktura – izolacje fundamentów',
      'FV/2026/04/171',
      'Hurtownia Budowlana Ostoja',
      -170,
      PdfColors.orange800,
      'Izolacja przeciwwilgociowa, XPS 10 cm',
    ),
  ),
  _CostSpec(
    'Robocizna – ekipa budowlana, stan zero',
    3150000,
    _vat8,
    _labor,
    ProjectStageKey.stateZero,
    _cost,
    CostStatus.paid,
    -150,
    note: 'Rozliczenie etapu zgodnie z umową.',
    contact: 'crew',
    payment: _transfer,
    document: _invoice(
      'FV_2026_05_012.pdf',
      'Faktura – robocizna, stan zero',
      'FV/2026/05/012',
      'Ekipa budowlana Kowalczyk',
      -150,
      PdfColors.blue800,
      'Wykonanie stanu zero wg umowy',
    ),
  ),
  // Open shell (current stage).
  _CostSpec(
    'Bloczki silikatowe – ściany parteru',
    2436000,
    _vat23,
    _material,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.paid,
    -41,
    note: '24 palety, rozładunek HDS.',
    contact: 'wholesale',
    payment: _transfer,
    source: CostSource.invoiceOcr,
    document: _invoice(
      'FV_2026_08_244.pdf',
      'Faktura – bloczki silikatowe',
      'FV/2026/08/244',
      'Hurtownia Budowlana Ostoja',
      -41,
      PdfColors.orange800,
      'Bloczki silikatowe 24 cm, 24 palety',
    ),
  ),
  _CostSpec(
    'Robocizna – ekipa budowlana, ściany parteru',
    2600000,
    _vat8,
    _labor,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.paid,
    -13,
    note: 'II transza zgodnie z harmonogramem.',
    contact: 'crew',
    payment: _transfer,
    document: _invoice(
      'FV_2026_09_087.pdf',
      'Faktura – robocizna, ściany parteru',
      'FV/2026/09/087',
      'Ekipa budowlana Kowalczyk',
      -13,
      PdfColors.blue800,
      'Murowanie ścian parteru – II transza',
    ),
  ),
  _CostSpec(
    'Wynajem rusztowań – październik',
    145000,
    _vat23,
    _mixed,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.due,
    -6,
    note: 'Rusztowanie elewacyjne 180 m² z montażem.',
    payment: _transfer,
    document: _invoice(
      'FV_2026_10_009.pdf',
      'Faktura – wynajem rusztowań',
      'FV/2026/10/009',
      'Wypożyczalnia sprzętu',
      -6,
      PdfColors.lime800,
      'Wynajem rusztowania elewacyjnego',
    ),
  ),
  _CostSpec(
    'Klej do bloczków silikatowych',
    126040,
    _vat23,
    _material,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.due,
    -8,
    note: '36 worków, odbiór własny.',
    contact: 'wholesale',
    payment: _transfer,
    document: _invoice(
      'FV_2026_09_311.pdf',
      'Faktura – klej do bloczków',
      'FV/2026/09/311',
      'Hurtownia Budowlana Ostoja',
      -8,
      PdfColors.orange800,
      'Zaprawa klejowa do bloczków, 36 worków',
    ),
  ),
  _CostSpec(
    'Nadproża prefabrykowane L19',
    294000,
    _vat23,
    _material,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.due,
    -5,
    note: '18 szt. różnych długości.',
    contact: 'wholesale',
    payment: _transfer,
    document: _invoice(
      'FV_2026_10_021.pdf',
      'Faktura – nadproża L19',
      'FV/2026/10/021',
      'Hurtownia Budowlana Ostoja',
      -5,
      PdfColors.orange800,
      'Belki nadprożowe L19, 18 szt.',
    ),
  ),
  _CostSpec(
    'Stal zbrojeniowa – wieńce i strop',
    638040,
    _vat23,
    _material,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.due,
    -3,
    note: '1,3 t stali, płatność w terminie 14 dni.',
    contact: 'wholesale',
    payment: _transfer,
    document: _invoice(
      'FV_2026_10_048.pdf',
      'Faktura – stal zbrojeniowa (wieńce i strop)',
      'FV/2026/10/048',
      'Hurtownia Budowlana Ostoja',
      -3,
      PdfColors.orange800,
      'Pręty żebrowane B500SP, wieńce i strop',
    ),
  ),
  _CostSpec(
    'Robocizna – zbrojenie wieńca, zaliczka',
    400000,
    _vat8,
    _labor,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.due,
    -2,
    note: 'Zaliczka przed betonowaniem stropu.',
    contact: 'crew',
    payment: _transfer,
    document: _invoice(
      'FV_2026_10_052.pdf',
      'Faktura – zaliczka na zbrojenie wieńca',
      'FV/2026/10/052',
      'Ekipa budowlana Kowalczyk',
      -2,
      PdfColors.blue800,
      'Zbrojenie wieńca – zaliczka',
    ),
  ),
  _CostSpec(
    'Strop Teriva – belki i pustaki',
    1745000,
    _vat23,
    _material,
    ProjectStageKey.shellOpen,
    _cost,
    CostStatus.ordered,
    1,
    note: 'Dostawa na plac z rozładunkiem HDS.',
    contact: 'wholesale',
    payment: _transfer,
    document: const _DocumentSpec(
      fileName: 'oferta_strop_teriva.pdf',
      title: 'Oferta – strop Teriva 112 m²',
      type: ProjectDocumentType.quote,
      heading: 'OFERTA',
      number: 'OF/2026/1187',
      issuer: 'Hurtownia Budowlana Ostoja',
      day: -4,
      accent: PdfColors.orange800,
      lines: <String>['Strop Teriva 4.0 – belki i pustaki, 112 m²'],
    ),
  ),
  _CostSpec(
    'Więźba dachowa z montażem',
    3850000,
    _vat8,
    _mixed,
    ProjectStageKey.shellOpen,
    _planned,
    CostStatus.planned,
    27,
    note: 'Wycena po pomiarze na budowie.',
    contact: 'roofer',
  ),
  // Closed shell.
  _CostSpec(
    'Okna PCV – zaliczka 30%',
    1260000,
    _vat8,
    _mixed,
    ProjectStageKey.shellClosed,
    _cost,
    CostStatus.paid,
    -24,
    note: '11 okien i drzwi tarasowe, montaż ciepły.',
    contact: 'windows',
    payment: _transfer,
    document: _invoice(
      'FV_2026_09_198.pdf',
      'Faktura zaliczkowa – okna PCV',
      'FZ/2026/09/198',
      'Okna Brzozowski',
      -24,
      PdfColors.teal700,
      'Zaliczka 30% – okna PCV z montażem',
    ),
  ),
  // Budget plan lines (the investor's own cost plan).
  _CostSpec(
    'Formalności i projekt – budżet etapu',
    2100000,
    _vat23,
    _labor,
    ProjectStageKey.formalities,
    _planned,
    CostStatus.planned,
    -370,
    note: 'Plan z kosztorysu inwestorskiego.',
  ),
  _CostSpec(
    'Przygotowanie placu – budżet etapu',
    1100000,
    _vat23,
    _mixed,
    ProjectStageKey.sitePreparation,
    _planned,
    CostStatus.planned,
    -226,
    note: 'Plan z kosztorysu inwestorskiego.',
  ),
  _CostSpec(
    'Stan zero – materiały, budżet',
    5200000,
    _vat23,
    _material,
    ProjectStageKey.stateZero,
    _planned,
    CostStatus.planned,
    -206,
    note: 'Plan z kosztorysu inwestorskiego.',
  ),
  _CostSpec(
    'Stan zero – robocizna, budżet',
    4200000,
    _vat8,
    _labor,
    ProjectStageKey.stateZero,
    _planned,
    CostStatus.planned,
    -206,
    note: 'Plan z kosztorysu inwestorskiego.',
  ),
  _CostSpec(
    'Stan surowy otwarty – materiały, budżet',
    9200000,
    _vat23,
    _material,
    ProjectStageKey.shellOpen,
    _planned,
    CostStatus.planned,
    -116,
    note: 'Plan z kosztorysu inwestorskiego.',
  ),
  _CostSpec(
    'Stan surowy otwarty – robocizna, budżet',
    6400000,
    _vat8,
    _labor,
    ProjectStageKey.shellOpen,
    _planned,
    CostStatus.planned,
    -116,
    note: 'Plan z kosztorysu inwestorskiego.',
  ),
  _CostSpec(
    'Okna PCV z montażem – wycena',
    4200000,
    _vat8,
    _mixed,
    ProjectStageKey.shellClosed,
    _planned,
    CostStatus.planned,
    -30,
    note: 'Wycena zaakceptowana, 11 okien i drzwi tarasowe.',
    contact: 'windows',
  ),
];
