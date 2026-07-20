import 'dart:math';

import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_stage_repository.dart';

final stageRepositoryProvider = FutureProvider<StageRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteStageRepository(
    database: database,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final projectStagesProvider = FutureProvider.autoDispose
    .family<List<ProjectStage>, Project>((ref, project) async {
      final repository = await ref.watch(stageRepositoryProvider.future);
      return repository.listStages(
        projectId: project.id,
        template: project.template,
      );
    });

String _secureId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
