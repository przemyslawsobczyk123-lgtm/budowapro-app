import 'dart:async';

import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/shared/models/page.dart';

final class FakeProjectRepository implements ProjectRepository {
  factory FakeProjectRepository({
    Iterable<Project> projects = const <Project>[],
    String? selectedProjectId,
    Map<String, int> linkedFileCounts = const <String, int>{},
    Map<String, int> linkedRecordCounts = const <String, int>{},
  }) {
    return FakeProjectRepository._(
      List<Project>.of(projects),
      selectedProjectId,
      Map<String, int>.of(linkedFileCounts),
      Map<String, int>.of(linkedRecordCounts),
    );
  }

  FakeProjectRepository._(
    this._projects,
    this._selectedProjectId,
    this._linkedFileCounts,
    this._linkedRecordCounts,
  );

  final List<Project> _projects;
  final Map<String, int> _linkedFileCounts;
  final Map<String, int> _linkedRecordCounts;
  String? _selectedProjectId;
  var _identifier = 0;

  int deleteCallCount = 0;
  int listCallCount = 0;
  int selectedCallCount = 0;
  Object? selectError;
  Completer<void>? listGate;
  Completer<void>? selectGate;
  final List<String> selectCalls = <String>[];

  @override
  Future<Project> create(ProjectDraft draft) async {
    final timestamp = DateTime.utc(2026, 7, 15, 10, _identifier);
    final project = Project(
      id: 'fake-project-${++_identifier}',
      draft: draft,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    _projects.add(project);
    _selectedProjectId = project.id;
    return project;
  }

  @override
  Future<void> delete(String projectId) async {
    final index = _projects.indexWhere((project) => project.id == projectId);
    if (index < 0) {
      throw const ProjectNotFoundException();
    }
    deleteCallCount += 1;
    _projects.removeAt(index);
    _linkedFileCounts.remove(projectId);
    _linkedRecordCounts.remove(projectId);
    if (_selectedProjectId == projectId) {
      _selectedProjectId = _projects
          .where((project) => !project.isArchived)
          .firstOrNull
          ?.id;
    }
  }

  @override
  Future<ProjectDeletionImpact> deletionImpact(String projectId) async {
    final project = await findById(projectId);
    if (project == null) {
      throw const ProjectNotFoundException();
    }
    return ProjectDeletionImpact(
      project: project,
      linkedFileCount: _linkedFileCounts[projectId] ?? 0,
      linkedRecordCount: _linkedRecordCounts[projectId] ?? 0,
    );
  }

  @override
  Future<Project?> findById(String projectId) async {
    return _projects.where((project) => project.id == projectId).firstOrNull;
  }

  @override
  Future<Page<Project>> list(
    PageRequest request, {
    bool includeArchived = false,
  }) async {
    listCallCount += 1;
    final gate = listGate;
    if (gate != null) {
      await gate.future;
    }
    final matching =
        _projects
            .where((project) => includeArchived || !project.isArchived)
            .toList(growable: false)
          ..sort((left, right) {
            final dateOrder = right.updatedAtUtc.compareTo(left.updatedAtUtc);
            return dateOrder != 0 ? dateOrder : left.id.compareTo(right.id);
          });
    final start = request.offset.clamp(0, matching.length);
    final end = (start + request.limit).clamp(start, matching.length);
    return Page<Project>(
      items: matching.sublist(start, end),
      totalCount: matching.length,
      request: request,
    );
  }

  @override
  Future<void> select(String projectId) async {
    selectCalls.add(projectId);
    final gate = selectGate;
    if (gate != null) {
      await gate.future;
    }
    final error = selectError;
    if (error != null) {
      throw error;
    }
    final project = await findById(projectId);
    if (project == null || project.isArchived) {
      throw const ProjectNotFoundException();
    }
    _selectedProjectId = projectId;
  }

  @override
  Future<Project?> selected() async {
    selectedCallCount += 1;
    final selectedId = _selectedProjectId;
    if (selectedId == null) {
      return null;
    }
    final project = await findById(selectedId);
    return project == null || project.isArchived ? null : project;
  }

  @override
  Future<Project> setArchived(
    String projectId, {
    required bool isArchived,
  }) async {
    final existing = await findById(projectId);
    if (existing == null) {
      throw const ProjectNotFoundException();
    }
    final updated = Project(
      id: existing.id,
      draft: existing.draft,
      createdAt: existing.createdAtUtc,
      updatedAt: existing.updatedAtUtc.add(const Duration(minutes: 1)),
      isArchived: isArchived,
      templateVersion: existing.templateVersion,
    );
    _replace(updated);
    if (isArchived && _selectedProjectId == projectId) {
      _selectedProjectId = _projects
          .where((project) => !project.isArchived)
          .firstOrNull
          ?.id;
    }
    return updated;
  }

  @override
  Future<Project> update(String projectId, ProjectDraft draft) async {
    final existing = await findById(projectId);
    if (existing == null) {
      throw const ProjectNotFoundException();
    }
    final updated = Project(
      id: existing.id,
      draft: draft,
      createdAt: existing.createdAtUtc,
      updatedAt: existing.updatedAtUtc.add(const Duration(minutes: 1)),
      isArchived: existing.isArchived,
      templateVersion: existing.templateVersion,
    );
    _replace(updated);
    return updated;
  }

  void _replace(Project project) {
    final index = _projects.indexWhere((item) => item.id == project.id);
    _projects[index] = project;
  }
}
