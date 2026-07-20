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
  CostLifecycle lifecycle = CostLifecycle.confirmed,
  CostStatus status = CostStatus.paid,
}) => CostEntry(
  id: 'cost-1',
  input: CostEntryInput(
    projectId: 'project-1',
    name: 'Beton B20',
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
  Future<Page<CostEntry>> list(CostQuery query, PageRequest page) async =>
      Page(items: entries, totalCount: entries.length, request: page);

  @override
  Future<CostSummary> summarize(CostSummaryQuery query) async =>
      CostSummary.fromTotals(
        planned: Money.zero('PLN'),
        actual: Money.zero('PLN'),
      );

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
