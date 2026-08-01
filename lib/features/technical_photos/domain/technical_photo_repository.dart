import 'dart:collection';

import 'package:budowapro/shared/models/page.dart';

import 'technical_photo.dart';

abstract interface class TechnicalPhotoRepository {
  Future<List<TechnicalAlbumOverview>> listAlbums({required String projectId});

  Future<TechnicalAlbum> createAlbum(TechnicalAlbumInput input);

  Future<TechnicalAlbum> updateAlbum({
    required String projectId,
    required String albumId,
    required TechnicalAlbumInput input,
  });

  Future<TechnicalPhoto?> findPhotoById({
    required String projectId,
    required String attachmentId,
  });

  Future<Page<TechnicalPhoto>> listPhotos(
    TechnicalPhotoQuery query,
    PageRequest page,
  );

  Future<TechnicalPhoto> createPhoto(TechnicalPhotoInput input);

  Future<TechnicalPhoto> updatePhoto(TechnicalPhotoInput input);
}

final class TechnicalPhotoQuery {
  factory TechnicalPhotoQuery({
    required String projectId,
    String? searchText,
    Set<String> albumIds = const <String>{},
    Set<String> stageIds = const <String>{},
    Set<TechnicalInstallationType> installationTypes =
        const <TechnicalInstallationType>{},
    Set<String> tags = const <String>{},
    DateTime? fromInclusive,
    DateTime? toExclusive,
  }) {
    final fromUtc = fromInclusive?.toUtc();
    final toUtc = toExclusive?.toUtc();
    if (fromUtc != null && toUtc != null && !fromUtc.isBefore(toUtc)) {
      throw ArgumentError.value(toExclusive, 'toExclusive');
    }
    return TechnicalPhotoQuery._(
      projectId: _requiredText(projectId, 'projectId', 64),
      searchText: _optionalText(searchText, 'searchText', 120)?.toLowerCase(),
      albumIds: _ids(albumIds, 'albumIds'),
      stageIds: _ids(stageIds, 'stageIds'),
      installationTypes: UnmodifiableSetView<TechnicalInstallationType>(
        Set<TechnicalInstallationType>.of(installationTypes),
      ),
      tags: _normalizedTags(tags),
      fromInclusiveUtc: fromUtc,
      toExclusiveUtc: toUtc,
    );
  }

  const TechnicalPhotoQuery._({
    required this.projectId,
    required this.searchText,
    required this.albumIds,
    required this.stageIds,
    required this.installationTypes,
    required this.tags,
    required this.fromInclusiveUtc,
    required this.toExclusiveUtc,
  });

  final String projectId;
  final String? searchText;
  final UnmodifiableSetView<String> albumIds;
  final UnmodifiableSetView<String> stageIds;
  final UnmodifiableSetView<TechnicalInstallationType> installationTypes;
  final UnmodifiableSetView<String> tags;
  final DateTime? fromInclusiveUtc;
  final DateTime? toExclusiveUtc;

  int get activeFilterCount {
    var count = 0;
    if (albumIds.isNotEmpty) count++;
    if (stageIds.isNotEmpty) count++;
    if (installationTypes.isNotEmpty) count++;
    if (tags.isNotEmpty) count++;
    if (fromInclusiveUtc != null || toExclusiveUtc != null) count++;
    return count;
  }
}

final class TechnicalPhotoNotFoundException implements Exception {
  const TechnicalPhotoNotFoundException();
}

final class TechnicalAlbumNotFoundException implements Exception {
  const TechnicalAlbumNotFoundException();
}

final class TechnicalPhotoConflictException implements Exception {
  const TechnicalPhotoConflictException();
}

UnmodifiableSetView<String> _ids(Iterable<String> source, String name) {
  final values = source.map((value) => _requiredText(value, name, 64)).toSet();
  if (values.length > 50) {
    throw ArgumentError.value(source, name, 'must not exceed 50 values');
  }
  return UnmodifiableSetView<String>(values);
}

UnmodifiableSetView<String> _normalizedTags(Iterable<String> source) {
  final values = source
      .map((value) => _requiredText(value, 'tag', 32).toLowerCase())
      .toSet();
  if (values.length > 12) {
    throw ArgumentError.value(source, 'tags', 'must not exceed 12 values');
  }
  return UnmodifiableSetView<String>(values);
}

String _requiredText(String value, String name, int maximumLength) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}

String? _optionalText(String? value, String name, int maximumLength) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return _requiredText(normalized, name, maximumLength);
}
