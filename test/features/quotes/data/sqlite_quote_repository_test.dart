import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/features/contacts/data/sqlite_contact_repository.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/quotes/data/sqlite_quote_repository.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/quotes/domain/quote_repository.dart';
import 'package:budowapro/features/stages/data/sqlite_stage_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  late SqliteCostRepository costs;
  late SqliteQuoteRepository quotes;
  var quoteId = 0;
  var costId = 0;
  var minute = 0;

  DateTime now() => DateTime.utc(2026, 7, 21, 10, minute++);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_quote_repository_test_',
    );
    databasePath = p.join(temporaryDirectory.path, 'budowapro.db');
    database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    final projects = SqliteProjectRepository(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'project-1',
      utcNow: now,
    );
    await projects.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    await SqliteStageRepository(
      database: database,
      idGenerator: () => 'stage-generated',
      utcNow: now,
    ).listStages(
      projectId: 'project-1',
      template: ProjectTemplate.houseConstruction,
    );
    final contacts = SqliteContactRepository(
      database: database,
      idGenerator: () => 'contact-1',
      utcNow: now,
    );
    await contacts.create(
      projectId: 'project-1',
      draft: ContactDraft(
        displayName: 'Elektro-Pro',
        kind: ContactKind.company,
        roles: const <ContactRole>{ContactRole.electrician},
        stageIds: const <String>{'installations'},
      ),
    );
    costs = SqliteCostRepository(
      database: database,
      idGenerator: () => 'cost-${++costId}',
      utcNow: now,
    );
    quotes = SqliteQuoteRepository(
      database: database,
      costRepository: costs,
      idGenerator: () => 'quote-${++quoteId}',
      utcNow: now,
    );
    await _insertAttachment(database, 'attachment-1');
  });

  tearDown(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('round-trips structured scope, exclusions and attachments', () async {
    final created = await quotes.create(
      projectId: 'project-1',
      draft: _draft(attachmentIds: const <String>['attachment-1']),
    );

    final loaded = await quotes.findById(
      projectId: 'project-1',
      quoteId: created.id,
    );

    expect(loaded?.draft.includedScope.map((line) => line.label), <String>[
      'Okablowanie',
      'Rozdzielnica',
    ]);
    expect(loaded?.draft.excludedScope.single.label, 'Oprawy oswietleniowe');
    expect(loaded?.draft.attachmentIds, <String>['attachment-1']);
    expect(loaded?.draft.amount.gross, _pln(1230000));
    expect(loaded?.draft.stageId, 'installations');
    final stager = CostAttachmentStager(
      database: database,
      fileStore: ProjectFileStore(
        rootDirectory: Directory(p.join(temporaryDirectory.path, 'files')),
      ),
      idGenerator: () => 'unused',
      utcNow: now,
    );
    expect(
      (await stager.listForQuote(
        projectId: 'project-1',
        quoteId: created.id,
      )).single.displayName,
      'oferta.pdf',
    );
    expect(
      await stager.discardIfUnlinked(
        projectId: 'project-1',
        attachmentId: 'attachment-1',
      ),
      isFalse,
    );
  });

  test('filters by contact, stage, status and literal search', () async {
    await quotes.create(projectId: 'project-1', draft: _draft());
    final page = await quotes.list(
      QuoteQuery(
        projectId: 'project-1',
        searchTerm: 'elektro%',
        contactId: 'contact-1',
        stageId: 'installations',
        statuses: const <ContractorQuoteStatus>{ContractorQuoteStatus.received},
      ),
      PageRequest(),
    );

    expect(page.items, isEmpty);
    expect(
      (await quotes.list(
        QuoteQuery(projectId: 'project-1', searchTerm: 'elektro'),
        PageRequest(),
      )).items,
      hasLength(1),
    );
  });

  test('accepts once and creates a linked ordered cost atomically', () async {
    final quote = await quotes.create(
      projectId: 'project-1',
      draft: _draft(attachmentIds: const <String>['attachment-1']),
    );

    final first = await quotes.accept(
      projectId: 'project-1',
      quoteId: quote.id,
      target: QuoteCostTarget.ordered,
    );
    final second = await quotes.accept(
      projectId: 'project-1',
      quoteId: quote.id,
      target: QuoteCostTarget.planned,
    );
    final cost = await costs.findById(
      projectId: 'project-1',
      costEntryId: first.costEntryId,
    );

    expect(first.createdCost, isTrue);
    expect(second.createdCost, isFalse);
    expect(second.costEntryId, first.costEntryId);
    expect(first.quote.status, ContractorQuoteStatus.accepted);
    expect(cost?.type, CostEntryType.planned);
    expect(cost?.status, CostStatus.ordered);
    expect(cost?.input.source, CostSource.offerConversion);
    expect(cost?.input.contactId, 'contact-1');
    expect(cost?.input.supplierId, isNull);
    expect(cost?.input.stageId, 'installations');
    expect(cost?.input.attachmentIds, <String>['attachment-1']);
    expect(cost?.amount.gross, _pln(1230000));
    expect(
      (await costs.list(
        CostQuery(
          projectId: 'project-1',
          sources: const <CostSource>{CostSource.offerConversion},
        ),
        PageRequest(),
      )).items,
      hasLength(1),
    );
  });

  test('failed cost insert leaves quote received', () async {
    final quote = await quotes.create(projectId: 'project-1', draft: _draft());
    final collidingCosts = SqliteCostRepository(
      database: database,
      idGenerator: () => 'collision',
      utcNow: now,
    );
    await collidingCosts.create(
      ConfirmedCostEntryInput(
        CostEntryInput(
          projectId: 'project-1',
          name: 'Existing',
          type: CostEntryType.planned,
          status: CostStatus.planned,
          amount: VatBreakdown.fromGross(_pln(100), VatRate.standard23),
          entryDate: now(),
        ),
      ),
    );
    final collidingQuotes = SqliteQuoteRepository(
      database: database,
      costRepository: collidingCosts,
      idGenerator: () => 'unused',
      utcNow: now,
    );

    await expectLater(
      collidingQuotes.accept(
        projectId: 'project-1',
        quoteId: quote.id,
        target: QuoteCostTarget.planned,
      ),
      throwsA(isA<DatabaseException>()),
    );
    expect(
      (await quotes.findById(
        projectId: 'project-1',
        quoteId: quote.id,
      ))?.status,
      ContractorQuoteStatus.received,
    );
  });

  test(
    'rejected and accepted quotes are locked against unsafe changes',
    () async {
      final rejected = await quotes.create(
        projectId: 'project-1',
        draft: _draft(),
      );
      await quotes.reject(projectId: 'project-1', quoteId: rejected.id);

      await expectLater(
        quotes.update(
          projectId: 'project-1',
          quoteId: rejected.id,
          draft: _draft(),
        ),
        throwsA(isA<QuoteLockedException>()),
      );

      final accepted = await quotes.create(
        projectId: 'project-1',
        draft: _draft(),
      );
      await quotes.accept(
        projectId: 'project-1',
        quoteId: accepted.id,
        target: QuoteCostTarget.planned,
      );
      await expectLater(
        quotes.delete(projectId: 'project-1', quoteId: accepted.id),
        throwsA(isA<QuoteLockedException>()),
      );
    },
  );
}

ContractorQuoteDraft _draft({List<String> attachmentIds = const <String>[]}) {
  return ContractorQuoteDraft(
    contactId: 'contact-1',
    title: 'Instalacja elektryczna',
    variantName: 'Standard',
    amount: VatBreakdown.fromGross(_pln(1230000), VatRate.standard23),
    receivedAt: DateTime.utc(2026, 7, 1),
    validUntil: DateTime.utc(2026, 8, 1),
    includedScope: <QuoteScopeLine>[
      QuoteScopeLine(label: 'Okablowanie'),
      QuoteScopeLine(label: 'Rozdzielnica', details: 'Z opisem obwodow'),
    ],
    excludedScope: <QuoteScopeLine>[
      QuoteScopeLine(label: 'Oprawy oswietleniowe'),
    ],
    attachmentIds: attachmentIds,
    stageId: 'installations',
    note: 'Termin realizacji do uzgodnienia',
  );
}

Future<void> _insertAttachment(AppDatabase database, String id) async {
  final handle = await database.open();
  await handle.insert(AppDatabase.costAttachmentsTable, <String, Object?>{
    'id': id,
    'project_id': 'project-1',
    'display_name': 'oferta.pdf',
    'original_storage_key': '$id.pdf',
    'preview_storage_key': null,
    'media_type': 'application/pdf',
    'byte_size': 100,
    'sha256': null,
    'source': 'file_picker',
    'availability': 'available',
    'imported_at_utc_ms': DateTime.utc(2026, 7, 1).millisecondsSinceEpoch,
  });
}

Money _pln(int minorUnits) =>
    Money(minorUnits: minorUnits, currencyCode: 'PLN');
