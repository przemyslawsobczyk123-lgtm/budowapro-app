import 'package:budowapro/features/materials/data/material_providers.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final materialsControllerProvider =
    AsyncNotifierProvider<MaterialsController, MaterialsState>(
      MaterialsController.new,
    );

final class MaterialsState {
  MaterialsState({
    required this.project,
    required Iterable<MaterialItem> materials,
    required this.summary,
    required this.searchText,
    required Iterable<MaterialStatus> statuses,
    required this.totalCount,
    this.isLoadingMore = false,
  }) : materials = List<MaterialItem>.unmodifiable(materials),
       statuses = Set<MaterialStatus>.unmodifiable(statuses);

  factory MaterialsState.noProject() => MaterialsState(
    project: null,
    materials: const <MaterialItem>[],
    summary: null,
    searchText: '',
    statuses: const <MaterialStatus>{},
    totalCount: 0,
  );

  final Project? project;
  final List<MaterialItem> materials;
  final MaterialDashboardSummary? summary;
  final String searchText;
  final Set<MaterialStatus> statuses;
  final int totalCount;
  final bool isLoadingMore;

  bool get hasMore => materials.length < totalCount;

  MaterialsState copyWith({
    Iterable<MaterialItem>? materials,
    MaterialDashboardSummary? summary,
    String? searchText,
    Iterable<MaterialStatus>? statuses,
    int? totalCount,
    bool? isLoadingMore,
  }) {
    return MaterialsState(
      project: project,
      materials: materials ?? this.materials,
      summary: summary ?? this.summary,
      searchText: searchText ?? this.searchText,
      statuses: statuses ?? this.statuses,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class MaterialsController extends AsyncNotifier<MaterialsState> {
  static const _pageSize = 30;

  @override
  Future<MaterialsState> build() async {
    final projects = await ref.watch(projectsControllerProvider.future);
    final project = projects.selectedProject;
    if (project == null) return MaterialsState.noProject();
    return _load(project: project, searchText: '', statuses: const {});
  }

  Future<void> refresh() async {
    final current = state.value;
    final project = current?.project;
    if (project == null) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading<MaterialsState>();
    final refreshed = await AsyncValue.guard(
      () => _load(
        project: project,
        searchText: current!.searchText,
        statuses: current.statuses,
      ),
    );
    if (!ref.mounted) return;
    state = refreshed;
  }

  Future<void> search(String value) =>
      _replaceFilters(searchText: value.trim());

  Future<void> setStatuses(Set<MaterialStatus> value) {
    return _replaceFilters(statuses: value);
  }

  Future<void> _replaceFilters({
    String? searchText,
    Set<MaterialStatus>? statuses,
  }) async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null) return;
    state = const AsyncLoading<MaterialsState>();
    final filtered = await AsyncValue.guard(
      () => _load(
        project: project,
        searchText: searchText ?? current.searchText,
        statuses: statuses ?? current.statuses,
      ),
    );
    if (!ref.mounted) return;
    state = filtered;
  }

  Future<void> loadMore() async {
    final current = state.requireValue;
    final project = current.project;
    if (project == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData<MaterialsState>(current.copyWith(isLoadingMore: true));
    try {
      final repository = await ref.read(materialRepositoryProvider.future);
      if (!ref.mounted) return;
      final page = await repository.list(
        MaterialQuery(
          projectId: project.id,
          searchText: current.searchText,
          statuses: current.statuses,
        ),
        PageRequest(offset: current.materials.length, limit: _pageSize),
        now: ref.read(materialNowProvider)(),
      );
      if (!ref.mounted) return;
      state = AsyncData<MaterialsState>(
        current.copyWith(
          materials: <MaterialItem>[...current.materials, ...page.items],
          totalCount: page.totalCount,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncData<MaterialsState>(
          current.copyWith(isLoadingMore: false),
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<MaterialsState> _load({
    required Project project,
    required String searchText,
    required Set<MaterialStatus> statuses,
  }) async {
    final repository = await ref.read(materialRepositoryProvider.future);
    final now = ref.read(materialNowProvider)();
    final page = await repository.list(
      MaterialQuery(
        projectId: project.id,
        searchText: searchText,
        statuses: statuses,
      ),
      PageRequest(limit: _pageSize),
      now: now,
    );
    return MaterialsState(
      project: project,
      materials: page.items,
      summary: await repository.summarize(
        projectId: project.id,
        currencyCode: project.currencyCode,
        now: now,
      ),
      searchText: searchText,
      statuses: statuses,
      totalCount: page.totalCount,
    );
  }
}
