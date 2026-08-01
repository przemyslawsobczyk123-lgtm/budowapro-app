import 'dart:collection';

import 'package:budowapro/shared/models/page.dart';

import 'room.dart';

abstract interface class RoomRepository {
  Future<Page<RoomOverview>> listRooms(RoomQuery query, PageRequest request);

  Future<Room?> findRoom({required String projectId, required String roomId});

  Future<RoomDetails?> findRoomDetails({
    required String projectId,
    required String roomId,
  });

  Future<Room> createRoom(RoomInput input);

  Future<Room> updateRoom({
    required String projectId,
    required String roomId,
    required RoomInput input,
  });

  Future<void> deleteRoom({required String projectId, required String roomId});

  Future<RoomChoice> createChoice({
    required RoomChoiceInput input,
    required Iterable<RoomChoiceVariantInput> variants,
  });

  Future<RoomChoice> updateChoice({
    required String projectId,
    required String choiceId,
    required RoomChoiceInput input,
    required Iterable<RoomChoiceVariantInput> variants,
  });

  Future<RoomChoice> selectVariant({
    required String projectId,
    required String choiceId,
    required String variantId,
  });

  Future<RoomChoice> reopenChoice({
    required String projectId,
    required String choiceId,
  });

  Future<RoomChoice> cancelChoice({
    required String projectId,
    required String choiceId,
  });

  Future<void> deleteChoice({
    required String projectId,
    required String choiceId,
  });

  Future<void> assignRecord({
    required String projectId,
    required String roomId,
    required RoomRecordType type,
    required String recordId,
  });

  Future<void> unassignRecord({
    required String projectId,
    required RoomRecordType type,
    required String recordId,
  });

  Future<void> setContactLinked({
    required String projectId,
    required String roomId,
    required String contactId,
    required bool isLinked,
  });

  Future<List<RoomRelationCandidate>> listRelationCandidates({
    required String projectId,
    required String roomId,
    required RoomRelationKind kind,
    String? searchText,
    int limit = 100,
  });

  Future<RoomChoice> registerChoiceOutput({
    required String projectId,
    required String choiceId,
    required RoomChoiceOutputType outputType,
    required String recordId,
  });

  Future<RoomPortfolioSummary> summarizeProject(String projectId);
}

final class RoomQuery {
  factory RoomQuery({required String projectId, String? searchText}) {
    final normalizedProjectId = projectId.trim();
    if (normalizedProjectId.isEmpty || normalizedProjectId.length > 64) {
      throw ArgumentError.value(projectId, 'projectId');
    }
    final normalizedSearch = searchText?.trim().toLowerCase();
    if (normalizedSearch != null && normalizedSearch.length > 120) {
      throw ArgumentError.value(searchText, 'searchText');
    }
    return RoomQuery._(
      projectId: normalizedProjectId,
      searchText: normalizedSearch == null || normalizedSearch.isEmpty
          ? null
          : normalizedSearch,
    );
  }

  const RoomQuery._({required this.projectId, required this.searchText});

  final String projectId;
  final String? searchText;
}

final class RoomNotFoundException implements Exception {
  const RoomNotFoundException();
}

final class RoomChoiceNotFoundException implements Exception {
  const RoomChoiceNotFoundException();
}

final class RoomConflictException implements Exception {
  const RoomConflictException();
}

final class RoomRelationNotFoundException implements Exception {
  const RoomRelationNotFoundException();
}

final class RoomVariantNotFoundException implements Exception {
  const RoomVariantNotFoundException();
}

final class RoomChoiceOutputExistsException implements Exception {
  const RoomChoiceOutputExistsException();
}

final class RoomChoiceOutputUnavailableException implements Exception {
  const RoomChoiceOutputUnavailableException();
}

UnmodifiableListView<T> boundedVariants<T>(Iterable<T> values) {
  final result = values.toList(growable: false);
  if (result.isEmpty || result.length > RoomFieldLimits.maximumVariants) {
    throw ArgumentError.value(values, 'variants');
  }
  return UnmodifiableListView<T>(result);
}
