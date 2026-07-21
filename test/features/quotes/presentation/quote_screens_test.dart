import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/quotes/data/quote_providers.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/quotes/domain/quote_repository.dart';
import 'package:budowapro/features/quotes/presentation/quote_comparison_screen.dart';
import 'package:budowapro/features/quotes/presentation/quote_editor_gateway.dart';
import 'package:budowapro/features/quotes/presentation/quote_form_screen.dart';
import 'package:budowapro/features/quotes/presentation/quotes_screen.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('selects quotes and opens comparison at 320 px', (tester) async {
    _compactView(tester);
    final repository = _QuoteRepository();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const QuotesScreen()),
        GoRoute(
          path: '/projects/:projectId/quotes/compare',
          builder: (_, state) => Scaffold(
            body: Text('compare:${state.uri.queryParameters['ids']}'),
          ),
        ),
        GoRoute(
          path: '/projects/:projectId/quotes/new',
          builder: (_, _) => const Scaffold(body: Text('new-quote')),
        ),
        GoRoute(
          path: '/projects/:projectId/quotes/:quoteId',
          builder: (_, _) => const Scaffold(body: Text('quote-details')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      _scope(
        quoteRepository: repository,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Instalacja elektryczna'), findsWidgets);
    await tester.ensureVisible(find.byKey(const ValueKey('quoteCompare-a')));
    await tester.tap(find.byKey(const ValueKey('quoteCompare-a')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('quoteCompare-b')));
    await tester.tap(find.byKey(const ValueKey('quoteCompare-b')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('compareQuotesButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('compare:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('comparison exposes price and scope differences at 320 px', (
    tester,
  ) async {
    _compactView(tester);
    final gateway = _QuoteGateway();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quoteEditorGatewayProvider.overrideWith((ref) async => gateway),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const QuoteComparisonScreen(
            projectId: 'project-1',
            quoteIds: <String>['a', 'b'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Najniższa cena'), findsOneWidget);
    expect(find.text('W cenie'), findsWidgets);
    expect(find.text('Wykluczone'), findsWidgets);
    expect(find.text('Brak informacji'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates a structured quote form at 320 px', (tester) async {
    _compactView(tester);
    final gateway = _QuoteGateway();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              onPressed: () => context.push('/form'),
              child: const Text('open-form'),
            ),
          ),
        ),
        GoRoute(
          path: '/form',
          builder: (context, state) => const QuoteFormScreen(
            projectId: 'project-1',
            initialContactId: 'contact-1',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quoteEditorGatewayProvider.overrideWith((ref) async => gateway),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('open-form'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('quoteTitleField')),
      'Instalacja elektryczna',
    );
    await tester.enterText(
      find.byKey(const ValueKey('quoteVariantField')),
      'Standard',
    );
    await tester.enterText(
      find.byKey(const ValueKey('quoteGrossField')),
      '12300,00',
    );
    await tester.enterText(
      find.byKey(const ValueKey('W cenie-0')),
      'Okablowanie',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('saveQuoteButton')));
    await tester.tap(find.byKey(const ValueKey('saveQuoteButton')));
    await tester.pumpAndSettle();

    expect(gateway.savedDraft?.includedScope.single.label, 'Okablowanie');
    expect(gateway.savedDraft?.amount.gross.minorUnits, 1230000);
    expect(gateway.savedDraft?.validUntilUtc.hour, isNot(0));
    expect(find.text('open-form'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _scope({
  required QuoteRepository quoteRepository,
  required Widget child,
}) {
  final project = _project();
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith(
        (ref) async => FakeProjectRepository(
          projects: [project],
          selectedProjectId: project.id,
        ),
      ),
      quoteRepositoryProvider.overrideWith((ref) async => quoteRepository),
      contactRepositoryProvider.overrideWith(
        (ref) async => _ContactRepository(),
      ),
      stageRepositoryProvider.overrideWith((ref) async => _StageRepository()),
    ],
    child: child,
  );
}

void _compactView(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

final class _QuoteRepository implements QuoteRepository {
  @override
  Future<Page<ContractorQuote>> list(
    QuoteQuery query,
    PageRequest request,
  ) async {
    final values = <ContractorQuote>[_quote('a'), _quote('b', cheaper: true)];
    return Page(items: values, totalCount: values.length, request: request);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ContactRepository implements ContactRepository {
  @override
  Future<Page<Contact>> list(ContactQuery query, PageRequest request) async {
    return Page(items: [_contact()], totalCount: 1, request: request);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _StageRepository implements StageRepository {
  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) async => const <ProjectStage>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _QuoteGateway implements QuoteEditorGateway {
  ContractorQuoteDraft? savedDraft;

  @override
  Future<QuoteEditorData> load({
    required String projectId,
    String? quoteId,
  }) async {
    return QuoteEditorData(
      project: _project(),
      quote: quoteId == null ? null : _quote(quoteId, cheaper: quoteId == 'b'),
      contacts: [_contact()],
      stages: const <ProjectStage>[],
      attachments: const [],
    );
  }

  @override
  Future<ContractorQuote> save({
    required String projectId,
    String? quoteId,
    required ContractorQuoteDraft draft,
  }) async {
    savedDraft = draft;
    return ContractorQuote(
      id: quoteId ?? 'saved',
      projectId: projectId,
      draft: draft,
      status: ContractorQuoteStatus.received,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ContractorQuote _quote(String id, {bool cheaper = false}) {
  return ContractorQuote(
    id: id,
    projectId: 'project-1',
    draft: ContractorQuoteDraft(
      contactId: 'contact-1',
      title: 'Instalacja elektryczna',
      variantName: id == 'a' ? 'Standard' : 'Ekonomiczny',
      amount: VatBreakdown.fromGross(
        Money(minorUnits: cheaper ? 900000 : 1000000, currencyCode: 'PLN'),
        VatRate.standard23,
      ),
      receivedAt: DateTime.utc(2026, 7, 1),
      validUntil: DateTime.utc(2026, 8, 1),
      includedScope: <QuoteScopeLine>[
        QuoteScopeLine(label: 'Okablowanie'),
        if (!cheaper) QuoteScopeLine(label: 'Rozdzielnica'),
      ],
      excludedScope: cheaper
          ? <QuoteScopeLine>[QuoteScopeLine(label: 'Rozdzielnica')]
          : <QuoteScopeLine>[QuoteScopeLine(label: 'Pomiary')],
    ),
    status: ContractorQuoteStatus.received,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}

Contact _contact() => Contact(
  id: 'contact-1',
  projectId: 'project-1',
  draft: ContactDraft(
    displayName: 'Elektro-Pro',
    kind: ContactKind.company,
    roles: const <ContactRole>{ContactRole.electrician},
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

Project _project() => Project(
  id: 'project-1',
  draft: ProjectDraft(
    name: 'Dom',
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
  ),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
