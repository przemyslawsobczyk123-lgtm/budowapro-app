import 'dart:collection';

import 'package:budowapro/shared/models/page.dart';

import 'capture_draft.dart';

abstract interface class CaptureRepository {
  Future<CaptureDraft> create(CaptureDraftInput input);

  Future<CaptureDraft> update({
    required String projectId,
    required String captureId,
    required CaptureDraftInput input,
  });

  Future<CaptureDraft?> findById({
    required String projectId,
    required String captureId,
  });

  Future<Page<CaptureDraft>> list(CaptureDraftQuery query, PageRequest page);

  Future<int> countOpen({required String projectId});

  Future<CaptureDraft> classify({
    required String projectId,
    required String captureId,
    required String currencyCode,
  });

  Future<CaptureDraft> merge({
    required String projectId,
    required String retainedCaptureId,
    required String mergedCaptureId,
  });

  Future<List<String>> reject({
    required String projectId,
    required String captureId,
  });
}

final class CaptureDraftQuery {
  factory CaptureDraftQuery({
    required String projectId,
    Iterable<CaptureDraftStatus> statuses = const <CaptureDraftStatus>[
      CaptureDraftStatus.needsReview,
      CaptureDraftStatus.ready,
    ],
    Iterable<CaptureDraftType> types = const <CaptureDraftType>[],
  }) {
    final normalizedProjectId = projectId.trim();
    if (normalizedProjectId.isEmpty || normalizedProjectId.length > 64) {
      throw ArgumentError.value(projectId, 'projectId');
    }
    return CaptureDraftQuery._(
      projectId: normalizedProjectId,
      statuses: UnmodifiableSetView<CaptureDraftStatus>(statuses.toSet()),
      types: UnmodifiableSetView<CaptureDraftType>(types.toSet()),
    );
  }

  const CaptureDraftQuery._({
    required this.projectId,
    required this.statuses,
    required this.types,
  });

  final String projectId;
  final UnmodifiableSetView<CaptureDraftStatus> statuses;
  final UnmodifiableSetView<CaptureDraftType> types;
}

final class CaptureDraftNotFoundException implements Exception {
  const CaptureDraftNotFoundException();
}

final class CaptureDraftNotReadyException implements Exception {
  const CaptureDraftNotReadyException();
}

final class CaptureDraftMergeException implements Exception {
  const CaptureDraftMergeException();
}
