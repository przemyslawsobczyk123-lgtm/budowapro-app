import 'dart:async';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_project_repository.dart';

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final database = await AppDatabase.onDevice();
  ref.onDispose(() {
    unawaited(database.close());
  });
  await database.open();
  return database;
});

final projectFileStoreProvider = FutureProvider<ProjectFileStore>((ref) {
  return ProjectFileStore.createForDevice();
});

final projectRepositoryProvider = FutureProvider<ProjectRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final fileStore = await ref.watch(projectFileStoreProvider.future);
  final repository = SqliteProjectRepository(
    database: database,
    fileStore: fileStore,
  );
  await repository.recoverPendingDeletions();
  return repository;
});
