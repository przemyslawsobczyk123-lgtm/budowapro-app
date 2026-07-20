import 'dart:async';

import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_summary.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_budget_screen.dart';
import 'package:budowapro/features/costs/presentation/cost_details_screen.dart';
import 'package:budowapro/features/costs/presentation/cost_editor_gateway.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/costs/presentation/cost_form_screen.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('retries loading the cost form after a transient error', (
    tester,
  ) async {
    final gateway = _FakeGateway(
      data: CostEditorData(
        project: _project(),
        entry: null,
        attachments: const [],
      ),
      loadFailures: 1,
    );
    await tester.pumpWidget(
      _gatewayApp(gateway, const CostFormScreen(projectId: 'project-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nie udało się wczytać wpisu.'), findsOneWidget);
    await tester.tap(find.text('Spróbuj ponownie'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('costNameField')), findsOneWidget);
    expect(gateway.loadCallCount, 2);
  });

  testWidgets('keeps entered values when cost validation fails', (
    tester,
  ) async {
    final gateway = _FakeGateway(
      data: CostEditorData(
        project: _project(),
        entry: null,
        attachments: const [],
      ),
    );
    await tester.pumpWidget(
      _gatewayApp(gateway, const CostFormScreen(projectId: 'project-1')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('costNameField')),
      'Klej do płytek',
    );
    await tester.enterText(
      find.byKey(const ValueKey('costGrossField')),
      '12,345',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('costSave')));
    await tester.tap(find.byKey(const ValueKey('costSave')));
    await tester.pumpAndSettle();

    expect(find.text('Klej do płytek'), findsOneWidget);
    expect(find.text('12,345'), findsOneWidget);
    expect(
      find.text('Wpisz kwotę z maksymalnie dwiema cyframi po przecinku.'),
      findsOneWidget,
    );
    expect(gateway.saveCallCount, 0);
  });

  testWidgets('edits a cost draft on a 320px screen without invalid status', (
    tester,
  ) async {
    final entry = _entry(
      lifecycle: CostLifecycle.draft,
      status: CostStatus.planned,
    );
    final gateway = _FakeGateway(
      data: CostEditorData(
        project: _project(),
        entry: entry,
        attachments: const [],
      ),
    );
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _gatewayApp(
        gateway,
        CostFormScreen(projectId: 'project-1', costEntryId: entry.id),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Opłacony'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows details and marks a confirmed cost as paid', (
    tester,
  ) async {
    final entry = _entry(status: CostStatus.due);
    final gateway = _FakeGateway(
      data: CostEditorData(
        project: _project(),
        entry: entry,
        attachments: const [],
      ),
    );
    await tester.pumpWidget(
      _gatewayApp(
        gateway,
        CostDetailsScreen(projectId: 'project-1', costEntryId: entry.id),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beton B20'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('costDetailsActions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oznacz jako opłacony'));
    await tester.pumpAndSettle();

    expect(gateway.changedStatus, CostStatus.paid);
  });

  testWidgets('does not offer mark paid for a returned cost', (tester) async {
    final entry = _entry(status: CostStatus.returned);
    final gateway = _FakeGateway(
      data: CostEditorData(
        project: _project(),
        entry: entry,
        attachments: const [],
      ),
    );
    await tester.pumpWidget(
      _gatewayApp(
        gateway,
        CostDetailsScreen(projectId: 'project-1', costEntryId: entry.id),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('costDetailsActions')));
    await tester.pumpAndSettle();

    expect(find.text('Oznacz jako opłacony'), findsNothing);
  });

  testWidgets('deletes a confirmed cost after confirmation', (tester) async {
    final entry = _entry(status: CostStatus.paid);
    final gateway = _FakeGateway(
      data: CostEditorData(
        project: _project(),
        entry: entry,
        attachments: const [],
      ),
    );
    await tester.pumpWidget(
      _gatewayApp(
        gateway,
        CostDetailsScreen(projectId: 'project-1', costEntryId: entry.id),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('costDetailsActions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuń pozycję'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuń'));
    await tester.pumpAndSettle();

    expect(gateway.deletedEntryId, entry.id);
  });

  testWidgets('renders budget CTA and compact cost list', (tester) async {
    final project = _project();
    final costs = _FakeCostRepository(entries: [_entry()]);
    final projects = FakeProjectRepository(
      projects: [project],
      selectedProjectId: project.id,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectRepositoryProvider.overrideWith((ref) async => projects),
          costRepositoryProvider.overrideWith((ref) async => costs),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const CostBudgetScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('costBudgetCreate')), findsOneWidget);
    expect(find.text('Beton B20'), findsOneWidget);
  });

  testWidgets('keeps search text while applying a combined status filter', (
    tester,
  ) async {
    final costs = _FakeCostRepository(entries: [_entry()]);
    await tester.pumpWidget(_budgetApp(costs));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('costRegisterSearch')),
      'beton',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(costs.listQueries.last.searchText, 'beton');
    await tester.tap(find.byKey(const ValueKey('costRegisterFilters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('costFilterStatus-paid')));
    await tester.tap(find.byKey(const ValueKey('costFilterApply')));
    await tester.pumpAndSettle();

    expect(costs.listQueries.last.searchText, 'beton');
    expect(costs.listQueries.last.statuses, <CostStatus>{CostStatus.paid});
    expect(find.text('beton'), findsOneWidget);
  });

  testWidgets('loads the next register page and fits warning rows at 320px', (
    tester,
  ) async {
    final entries = List<CostEntry>.generate(
      65,
      (index) => _entry(id: 'cost-$index', name: 'Koszt $index'),
    );
    final costs = _FakeCostRepository(entries: entries);
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_budgetApp(costs));
    await tester.pumpAndSettle();

    expect(find.text('Brak dokumentu'), findsWidgets);
    for (var attempt = 0; attempt < 4; attempt++) {
      if (costs.pageRequests.any((request) => request.offset == 30)) break;
      await tester.fling(
        find.byKey(const ValueKey('costRegisterScroll')),
        const Offset(0, -3000),
        3000,
      );
      await tester.pumpAndSettle();
    }

    expect(costs.pageRequests.any((request) => request.offset == 30), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter reload cannot leave lazy loading blocked', (
    tester,
  ) async {
    final costs = _FakeCostRepository(
      entries: List<CostEntry>.generate(
        65,
        (index) => _entry(id: 'race-$index', name: 'Pozycja $index'),
      ),
    );
    await tester.pumpWidget(_budgetApp(costs));
    await tester.pumpAndSettle();
    final blockedPage = Completer<void>();
    costs.nextPageGate = blockedPage;

    await tester.fling(
      find.byKey(const ValueKey('costRegisterScroll')),
      const Offset(0, -3000),
      3000,
    );
    await tester.pump(const Duration(seconds: 1));
    expect(costs.pageRequests.any((request) => request.offset == 30), isTrue);

    await tester.fling(
      find.byKey(const ValueKey('costRegisterScroll')),
      const Offset(0, 3000),
      3000,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(
      find.byKey(const ValueKey('costRegisterSearch')),
      'pozycja',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 100));
    expect(costs.listQueries.last.searchText, 'pozycja');

    blockedPage.complete();
    await tester.pumpAndSettle();
    for (var attempt = 0; attempt < 3; attempt++) {
      if (costs.pageRequests.where((request) => request.offset == 30).length >=
          2) {
        break;
      }
      await tester.fling(
        find.byKey(const ValueKey('costRegisterScroll')),
        const Offset(0, -3000),
        3000,
      );
      await tester.pumpAndSettle();
    }

    expect(
      costs.pageRequests.where((request) => request.offset == 30).length,
      greaterThanOrEqualTo(2),
    );
  });
}

Widget _gatewayApp(CostEditorGateway gateway, Widget home) {
  return ProviderScope(
    overrides: [costEditorGatewayProvider.overrideWith((ref) async => gateway)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: home,
    ),
  );
}

Widget _budgetApp(_FakeCostRepository costs) {
  final project = _project();
  final projects = FakeProjectRepository(
    projects: [project],
    selectedProjectId: project.id,
  );
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith((ref) async => projects),
      costRepositoryProvider.overrideWith((ref) async => costs),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: const CostBudgetScreen(),
    ),
  );
}

Project _project() => Project(
  id: 'project-1',
  draft: ProjectDraft(
    name: 'Dom',
    type: ProjectType.houseBuild,
    template: ProjectTemplate.houseConstruction,
  ),
  createdAt: DateTime.utc(2026, 7, 1),
  updatedAt: DateTime.utc(2026, 7, 15),
);

CostEntry _entry({
  String id = 'cost-1',
  String name = 'Beton B20',
  CostLifecycle lifecycle = CostLifecycle.confirmed,
  CostStatus status = CostStatus.paid,
}) => CostEntry(
  id: id,
  input: CostEntryInput(
    projectId: 'project-1',
    name: name,
    type: CostEntryType.cost,
    status: status,
    amount: VatBreakdown.fromGross(
      Money(minorUnits: 123000, currencyCode: 'PLN'),
      VatRate.standard23,
    ),
    entryDate: DateTime.utc(2026, 7, 15),
    note: 'Dostawa rano',
  ),
  lifecycle: lifecycle,
  createdAt: DateTime.utc(2026, 7, 15),
  updatedAt: DateTime.utc(2026, 7, 15),
);

class _FakeGateway implements CostEditorGateway {
  _FakeGateway({required this.data, this.loadFailures = 0});

  CostEditorData data;
  final int loadFailures;
  CostStatus? changedStatus;
  String? deletedEntryId;
  var saveCallCount = 0;
  var loadCallCount = 0;

  @override
  Future<CostEditorData> load({
    required String projectId,
    String? costEntryId,
  }) async {
    loadCallCount += 1;
    if (loadCallCount <= loadFailures) {
      throw StateError('transient load failure');
    }
    return data;
  }

  @override
  Future<CostEntry> save({
    required CostEditorData initialData,
    required CostFormSubmission submission,
    required bool asDraft,
  }) async {
    saveCallCount += 1;
    return data.entry ?? _entry();
  }

  @override
  Future<void> discardAttachment({
    required String projectId,
    required String attachmentId,
  }) async {}

  @override
  Future<CostEntry> copyAsDraft({
    required String projectId,
    required String costEntryId,
  }) async =>
      _entry(lifecycle: CostLifecycle.draft, status: CostStatus.planned);

  @override
  Future<CostEntry> changeStatus({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
  }) async {
    changedStatus = status;
    return _entry(status: status);
  }

  @override
  Future<void> delete({
    required String projectId,
    required String costEntryId,
  }) async {
    deletedEntryId = costEntryId;
  }

  @override
  Future<Page<CostHistoryEntry>> history({
    required String projectId,
    required String costEntryId,
    required PageRequest page,
  }) async =>
      Page(items: const <CostHistoryEntry>[], totalCount: 0, request: page);

  @override
  Future<StagedCostAttachment?> pickAttachment(String projectId) async => null;
}

class _FakeCostRepository implements CostRepository {
  _FakeCostRepository({required this.entries});

  final List<CostEntry> entries;
  final List<CostQuery> listQueries = <CostQuery>[];
  final List<PageRequest> pageRequests = <PageRequest>[];
  Completer<void>? nextPageGate;

  @override
  Future<CostEntry> create(ConfirmedCostEntryInput input) async =>
      throw UnimplementedError();

  @override
  Future<CostEntry> saveDraft(CostDraftInput input) async =>
      throw UnimplementedError();

  @override
  Future<CostEntry> replaceDraft({
    required String projectId,
    required String costEntryId,
    required CostDraftInput input,
  }) async => throw UnimplementedError();

  @override
  Future<CostEntry> confirmDraft({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
    CostDraftInput? replacement,
  }) async => throw UnimplementedError();

  @override
  Future<CostEntry> changeStatus({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
  }) async => throw UnimplementedError();

  @override
  Future<CostEntry> updateDetails({
    required String projectId,
    required String costEntryId,
    required ConfirmedCostDetailsInput input,
  }) async => throw UnimplementedError();

  @override
  Future<CostCorrection> addCorrection(CostCorrectionInput input) async =>
      throw UnimplementedError();

  @override
  Future<CostEntry?> findById({
    required String projectId,
    required String costEntryId,
  }) async => entries.where((item) => item.id == costEntryId).firstOrNull;

  @override
  Future<Page<CostEntry>> list(CostQuery query, PageRequest page) async {
    listQueries.add(query);
    pageRequests.add(page);
    final gate = nextPageGate;
    if (page.offset > 0 && gate != null) {
      nextPageGate = null;
      await gate.future;
    }
    final end = (page.offset + page.limit).clamp(0, entries.length);
    final items = page.offset >= entries.length
        ? const <CostEntry>[]
        : entries.sublist(page.offset, end);
    return Page(items: items, totalCount: entries.length, request: page);
  }

  @override
  Future<CostSummary> summarize(CostSummaryQuery query) async =>
      CostSummary.fromTotals(
        planned: Money.zero('PLN'),
        actual: Money.zero('PLN'),
      );

  @override
  Future<CostFilterOptions> filterOptions({required String projectId}) async =>
      CostFilterOptions();

  @override
  Future<Page<CostHistoryEntry>> history({
    required String projectId,
    required String costEntryId,
    required PageRequest page,
  }) async =>
      Page(items: const <CostHistoryEntry>[], totalCount: 0, request: page);

  @override
  Future<void> delete({
    required String projectId,
    required String costEntryId,
  }) async {}
}
