import 'package:budowapro/shared/models/page.dart';

import 'project.dart';

abstract interface class ProjectRepository {
  Future<Project> create(ProjectDraft draft);

  Future<Project> update(String projectId, ProjectDraft draft);

  Future<Project?> findById(String projectId);

  Future<Page<Project>> list(
    PageRequest request, {
    bool includeArchived = false,
  });

  Future<Project?> selected();

  Future<void> select(String projectId);

  Future<Project> setArchived(String projectId, {required bool isArchived});

  Future<ProjectDeletionImpact> deletionImpact(String projectId);

  Future<void> delete(String projectId);
}

final class ProjectDeletionImpact {
  const ProjectDeletionImpact({
    required this.project,
    required this.linkedFileCount,
    required this.linkedRecordCount,
  });

  final Project project;
  final int linkedFileCount;
  final int linkedRecordCount;
}

final class ProjectNotFoundException implements Exception {
  const ProjectNotFoundException();
}
