import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/rooms/data/room_providers.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/features/rooms/presentation/room_details_screen.dart';
import 'package:budowapro/features/rooms/presentation/room_relations_screen.dart';
import 'package:budowapro/features/rooms/presentation/rooms_controller.dart';
import 'package:budowapro/features/rooms/presentation/rooms_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('room list fits 320 px and remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _roomsApp(_roomsState(), textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pomieszczenia'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('roomSearchField')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('roomSearchField')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('roomTile-room-1')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('roomTile-room-1')), findsOneWidget);
    expect(find.text('Kuchnia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('variant is selected only after confirmation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeRoomRepository(_roomDetails());
    await tester.pumpWidget(_detailsApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Płytki ścienne'), findsOneWidget);
    expect(find.text('Do wyboru'), findsOneWidget);
    await tester.tap(find.byTooltip('Wybierz wariant').first);
    await tester.pumpAndSettle();

    expect(find.text('Potwierdź wariant'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Wybierz wariant'));
    await tester.pumpAndSettle();

    expect(find.text('Wybrano'), findsOneWidget);
    expect(find.text('Utwórz szkic kosztu'), findsOneWidget);
    expect(find.text('Dodaj do materiałów'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('relation tabs fit a 320 px screen', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeRoomRepository(_roomDetails());
    await tester.pumpWidget(_relationsApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Dane pomieszczenia'), findsOneWidget);
    expect(find.text('Koszty'), findsWidgets);
    expect(find.text('Brak elementów do przypisania.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _roomsApp(RoomsState state, {required TextScaler textScaler}) {
  return ProviderScope(
    overrides: [
      roomsControllerProvider.overrideWithBuild((ref, notifier) async => state),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const RoomsScreen(),
    ),
  );
}

Widget _detailsApp(RoomRepository repository) {
  return ProviderScope(
    overrides: [roomRepositoryProvider.overrideWith((ref) async => repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RoomDetailsScreen(projectId: 'project-1', roomId: 'room-1'),
    ),
  );
}

Widget _relationsApp(RoomRepository repository) {
  return ProviderScope(
    overrides: [roomRepositoryProvider.overrideWith((ref) async => repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RoomRelationsScreen(projectId: 'project-1', roomId: 'room-1'),
    ),
  );
}

RoomsState _roomsState() {
  final now = DateTime.utc(2026, 7, 31, 12);
  final project = Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currencyCode: 'PLN',
    ),
    createdAt: now,
    updatedAt: now,
  );
  final room = Room(
    id: 'room-1',
    input: RoomInput(
      projectId: project.id,
      name: 'Kuchnia',
      floorLabel: 'Parter',
      standard: RoomStandard.elevated,
      plannedBudget: Money(minorUnits: 2500000, currencyCode: 'PLN'),
    ),
    createdAt: now,
    updatedAt: now,
  );
  final overview = RoomOverview(
    room: room,
    actualCost: Money(minorUnits: 500000, currencyCode: 'PLN'),
    openChoiceCount: 2,
    openDecisionCount: 1,
    materialCount: 0,
    contactCount: 1,
    technicalPhotoCount: 3,
    openDefectCount: 1,
  );
  return RoomsState(
    project: project,
    rooms: <RoomOverview>[overview],
    summary: RoomPortfolioSummary(
      projectId: project.id,
      roomCount: 1,
      plannedBudget: Money(minorUnits: 2500000, currencyCode: 'PLN'),
      actualCost: Money(minorUnits: 500000, currencyCode: 'PLN'),
      openChoiceCount: 2,
    ),
    searchText: '',
    totalCount: 1,
  );
}

RoomDetails _roomDetails() {
  final now = DateTime.utc(2026, 7, 31, 12);
  final room = Room(
    id: 'room-1',
    input: RoomInput(
      projectId: 'project-1',
      name: 'Łazienka',
      standard: RoomStandard.standard,
    ),
    createdAt: now,
    updatedAt: now,
  );
  final variant = RoomChoiceVariant(
    id: 'variant-1',
    choiceId: 'choice-1',
    input: RoomChoiceVariantInput(
      projectId: 'project-1',
      label: 'Gres jasny',
      unitGrossPrice: Money(minorUnits: 12999, currencyCode: 'PLN'),
    ),
    createdAt: now,
    updatedAt: now,
  );
  final choice = RoomChoice(
    id: 'choice-1',
    input: RoomChoiceInput(
      projectId: 'project-1',
      roomId: room.id,
      title: 'Płytki ścienne',
    ),
    variants: <RoomChoiceVariant>[variant],
    status: RoomChoiceStatus.open,
    selectedVariantId: null,
    createdAt: now,
    updatedAt: now,
  );
  return RoomDetails(
    overview: RoomOverview(
      room: room,
      actualCost: Money.zero('PLN'),
      openChoiceCount: 1,
      openDecisionCount: 0,
      materialCount: 0,
      contactCount: 0,
      technicalPhotoCount: 0,
      openDefectCount: 0,
    ),
    choices: <RoomChoice>[choice],
    contactIds: const <String>[],
  );
}

final class _FakeRoomRepository implements RoomRepository {
  _FakeRoomRepository(this.details);

  RoomDetails details;

  @override
  Future<RoomDetails?> findRoomDetails({
    required String projectId,
    required String roomId,
  }) async => details;

  @override
  Future<RoomChoice> selectVariant({
    required String projectId,
    required String choiceId,
    required String variantId,
  }) async {
    final previous = details.choices.single;
    final selected = RoomChoice(
      id: previous.id,
      input: previous.input,
      variants: previous.variants,
      status: RoomChoiceStatus.selected,
      selectedVariantId: variantId,
      createdAt: previous.createdAtUtc,
      updatedAt: previous.updatedAtUtc.add(const Duration(seconds: 1)),
    );
    details = RoomDetails(
      overview: details.overview,
      choices: <RoomChoice>[selected],
      contactIds: details.contactIds,
    );
    return selected;
  }

  @override
  Future<List<RoomRelationCandidate>> listRelationCandidates({
    required String projectId,
    required String roomId,
    required RoomRelationKind kind,
    String? searchText,
    int limit = 100,
  }) async => const <RoomRelationCandidate>[];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
