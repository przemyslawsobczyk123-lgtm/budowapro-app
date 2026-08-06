import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/features/rooms/data/room_providers.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomsControllerProvider =
    AsyncNotifierProvider<RoomsController, RoomsState>(RoomsController.new);

final class RoomsState {
  RoomsState({
    required this.project,
    required Iterable<RoomOverview> rooms,
    required this.summary,
    required this.searchText,
    required this.totalCount,
    this.isLoadingMore = false,
  }) : rooms = List<RoomOverview>.unmodifiable(rooms);

  factory RoomsState.noProject() => RoomsState(
    project: null,
    rooms: const <RoomOverview>[],
    summary: null,
    searchText: '',
    totalCount: 0,
  );

  final Project? project;
  final List<RoomOverview> rooms;
  final RoomPortfolioSummary? summary;
  final String searchText;
  final int totalCount;
  final bool isLoadingMore;

  bool get hasMore => rooms.length < totalCount;

  RoomsState copyWith({
    Iterable<RoomOverview>? rooms,
    RoomPortfolioSummary? summary,
    String? searchText,
    int? totalCount,
    bool? isLoadingMore,
  }) {
    return RoomsState(
      project: project,
      rooms: rooms ?? this.rooms,
      summary: summary ?? this.summary,
      searchText: searchText ?? this.searchText,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class RoomsController extends AsyncNotifier<RoomsState> {
  static const _pageSize = 30;

  @override
  Future<RoomsState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return RoomsState.noProject();
    return _load(project: project, searchText: '');
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current?.project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<RoomsState>();
    final refreshed = await AsyncValue.guard(
      () => _load(project: current!.project!, searchText: current.searchText),
    );
    if (!ref.mounted) return;
    state = refreshed;
  }

  Future<void> search(String value) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null) return;
    final normalized = value.trim();
    state = const AsyncLoading<RoomsState>();
    final searched = await AsyncValue.guard(
      () => _load(project: project, searchText: normalized),
    );
    if (!ref.mounted) return;
    state = searched;
  }

  Future<void> loadMore() async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData<RoomsState>(current.copyWith(isLoadingMore: true));
    try {
      final repository = await ref.read(roomRepositoryProvider.future);
      if (!ref.mounted) return;
      final page = await repository.listRooms(
        RoomQuery(projectId: project.id, searchText: current.searchText),
        PageRequest(offset: current.rooms.length, limit: _pageSize),
      );
      if (!ref.mounted) return;
      state = AsyncData<RoomsState>(
        current.copyWith(
          rooms: <RoomOverview>[...current.rooms, ...page.items],
          totalCount: page.totalCount,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncData<RoomsState>(current.copyWith(isLoadingMore: false));
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<RoomsState> _load({
    required Project project,
    required String searchText,
  }) async {
    final repository = await ref.read(roomRepositoryProvider.future);
    final page = await repository.listRooms(
      RoomQuery(projectId: project.id, searchText: searchText),
      PageRequest(limit: _pageSize),
    );
    return RoomsState(
      project: project,
      rooms: page.items,
      summary: await repository.summarizeProject(project.id),
      searchText: searchText,
      totalCount: page.totalCount,
    );
  }
}
