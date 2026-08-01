import 'dart:math';

import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/diary/data/journal_providers.dart';
import 'package:budowapro/features/materials/data/material_providers.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/rooms/data/room_choice_output_service.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_room_repository.dart';

final roomRepositoryProvider = FutureProvider<RoomRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteRoomRepository(
    database: database,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final roomChoiceOutputServiceProvider = FutureProvider<RoomChoiceOutputService>(
  (ref) async {
    return RoomChoiceOutputService(
      await ref.watch(roomRepositoryProvider.future),
      await ref.watch(costRepositoryProvider.future),
      await ref.watch(journalRepositoryProvider.future),
      await ref.watch(materialRepositoryProvider.future),
      DateTime.now,
    );
  },
);

String _secureId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
