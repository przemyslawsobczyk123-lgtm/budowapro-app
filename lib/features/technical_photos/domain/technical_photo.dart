import 'dart:collection';

enum TechnicalAlbumKind {
  beforeConcrete,
  beforeBackfill,
  beforePlaster,
  beforeScreed,
  beforeTiles,
  asBuilt,
  custom,
}

enum TechnicalInstallationType {
  structure,
  electrical,
  water,
  sewage,
  heating,
  ventilation,
  waterproofing,
  insulation,
  grounding,
  other,
}

enum TechnicalPhotoLinkType { cost, decision, defect, acceptanceProtocol }

final class TechnicalPhotoLink {
  const TechnicalPhotoLink({required this.type, required this.targetId});

  final TechnicalPhotoLinkType type;
  final String targetId;
}

final class TechnicalAlbumInput {
  factory TechnicalAlbumInput({
    required String projectId,
    required String title,
    required TechnicalAlbumKind kind,
    String? stageId,
    String? description,
  }) => TechnicalAlbumInput._(
    projectId: _requiredText(projectId, 'projectId', 64),
    title: _requiredText(title, 'title', 120),
    kind: kind,
    stageId: _optionalText(stageId, 'stageId', 64),
    description: _optionalText(description, 'description', 1000),
  );

  const TechnicalAlbumInput._({
    required this.projectId,
    required this.title,
    required this.kind,
    required this.stageId,
    required this.description,
  });

  final String projectId;
  final String title;
  final TechnicalAlbumKind kind;
  final String? stageId;
  final String? description;
}

final class TechnicalAlbum {
  factory TechnicalAlbum({
    required String id,
    required String projectId,
    required String title,
    required TechnicalAlbumKind kind,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? stageId,
    String? description,
  }) {
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return TechnicalAlbum._(
      id: _requiredText(id, 'id', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      title: _requiredText(title, 'title', 120),
      kind: kind,
      stageId: _optionalText(stageId, 'stageId', 64),
      description: _optionalText(description, 'description', 1000),
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const TechnicalAlbum._({
    required this.id,
    required this.projectId,
    required this.title,
    required this.kind,
    required this.stageId,
    required this.description,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String projectId;
  final String title;
  final TechnicalAlbumKind kind;
  final String? stageId;
  final String? description;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class TechnicalAlbumOverview {
  factory TechnicalAlbumOverview({
    required TechnicalAlbum album,
    required int photoCount,
  }) {
    if (photoCount < 0) {
      throw RangeError.value(photoCount, 'photoCount');
    }
    return TechnicalAlbumOverview._(album: album, photoCount: photoCount);
  }

  const TechnicalAlbumOverview._({
    required this.album,
    required this.photoCount,
  });

  final TechnicalAlbum album;
  final int photoCount;
}

final class TechnicalPhotoInput {
  factory TechnicalPhotoInput({
    required String projectId,
    required String attachmentId,
    required String albumId,
    required String title,
    required DateTime capturedAt,
    required TechnicalInstallationType installationType,
    String? stageId,
    String? zoneLabel,
    String? contractorContactId,
    String? checklistItemId,
    String? description,
    Iterable<String> tags = const <String>[],
    Iterable<TechnicalPhotoLink> links = const <TechnicalPhotoLink>[],
  }) => TechnicalPhotoInput._(
    projectId: _requiredText(projectId, 'projectId', 64),
    attachmentId: _requiredText(attachmentId, 'attachmentId', 64),
    albumId: _requiredText(albumId, 'albumId', 64),
    title: _requiredText(title, 'title', 160),
    capturedAtUtc: capturedAt.toUtc(),
    installationType: installationType,
    stageId: _optionalText(stageId, 'stageId', 64),
    zoneLabel: _optionalText(zoneLabel, 'zoneLabel', 120),
    contractorContactId: _optionalText(
      contractorContactId,
      'contractorContactId',
      64,
    ),
    checklistItemId: _optionalText(checklistItemId, 'checklistItemId', 64),
    description: _optionalText(description, 'description', 2000),
    tags: _tags(tags),
    links: _links(links),
  );

  const TechnicalPhotoInput._({
    required this.projectId,
    required this.attachmentId,
    required this.albumId,
    required this.title,
    required this.capturedAtUtc,
    required this.installationType,
    required this.stageId,
    required this.zoneLabel,
    required this.contractorContactId,
    required this.checklistItemId,
    required this.description,
    required this.tags,
    required this.links,
  });

  final String projectId;
  final String attachmentId;
  final String albumId;
  final String title;
  final DateTime capturedAtUtc;
  final TechnicalInstallationType installationType;
  final String? stageId;
  final String? zoneLabel;
  final String? contractorContactId;
  final String? checklistItemId;
  final String? description;
  final UnmodifiableListView<String> tags;
  final UnmodifiableListView<TechnicalPhotoLink> links;
}

final class TechnicalPhoto {
  factory TechnicalPhoto({
    required String attachmentId,
    required String projectId,
    required String albumId,
    required String title,
    required DateTime capturedAt,
    required TechnicalInstallationType installationType,
    required String displayName,
    required String mediaType,
    required bool hasPreview,
    required DateTime importedAt,
    String? stageId,
    String? zoneLabel,
    String? contractorContactId,
    String? checklistItemId,
    String? description,
    Iterable<String> tags = const <String>[],
    Iterable<TechnicalPhotoLink> links = const <TechnicalPhotoLink>[],
  }) {
    final normalizedMediaType = _requiredText(
      mediaType,
      'mediaType',
      120,
    ).toLowerCase();
    if (!normalizedMediaType.startsWith('image/')) {
      throw ArgumentError.value(mediaType, 'mediaType', 'must be an image');
    }
    return TechnicalPhoto._(
      attachmentId: _requiredText(attachmentId, 'attachmentId', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      albumId: _requiredText(albumId, 'albumId', 64),
      title: _requiredText(title, 'title', 160),
      capturedAtUtc: capturedAt.toUtc(),
      installationType: installationType,
      stageId: _optionalText(stageId, 'stageId', 64),
      zoneLabel: _optionalText(zoneLabel, 'zoneLabel', 120),
      contractorContactId: _optionalText(
        contractorContactId,
        'contractorContactId',
        64,
      ),
      checklistItemId: _optionalText(checklistItemId, 'checklistItemId', 64),
      description: _optionalText(description, 'description', 2000),
      tags: _tags(tags),
      links: _links(links),
      displayName: _requiredText(displayName, 'displayName', 255),
      mediaType: normalizedMediaType,
      hasPreview: hasPreview,
      importedAtUtc: importedAt.toUtc(),
    );
  }

  const TechnicalPhoto._({
    required this.attachmentId,
    required this.projectId,
    required this.albumId,
    required this.title,
    required this.capturedAtUtc,
    required this.installationType,
    required this.stageId,
    required this.zoneLabel,
    required this.contractorContactId,
    required this.checklistItemId,
    required this.description,
    required this.tags,
    required this.links,
    required this.displayName,
    required this.mediaType,
    required this.hasPreview,
    required this.importedAtUtc,
  });

  final String attachmentId;
  final String projectId;
  final String albumId;
  final String title;
  final DateTime capturedAtUtc;
  final TechnicalInstallationType installationType;
  final String? stageId;
  final String? zoneLabel;
  final String? contractorContactId;
  final String? checklistItemId;
  final String? description;
  final UnmodifiableListView<String> tags;
  final UnmodifiableListView<TechnicalPhotoLink> links;
  final String displayName;
  final String mediaType;
  final bool hasPreview;
  final DateTime importedAtUtc;

  bool get isImage => mediaType.startsWith('image/');
}

UnmodifiableListView<TechnicalPhotoLink> _links(
  Iterable<TechnicalPhotoLink> source,
) {
  final values = <TechnicalPhotoLink>[];
  final keys = <String>{};
  for (final link in source) {
    final targetId = _requiredText(link.targetId, 'targetId', 64);
    final key = '${link.type.name}:$targetId';
    if (keys.add(key)) {
      values.add(TechnicalPhotoLink(type: link.type, targetId: targetId));
    }
  }
  if (values.length > 20) {
    throw ArgumentError.value(source, 'links', 'must not exceed 20 values');
  }
  return UnmodifiableListView<TechnicalPhotoLink>(values);
}

UnmodifiableListView<String> _tags(Iterable<String> source) {
  final values =
      source
          .map((value) => _requiredText(value, 'tag', 32).toLowerCase())
          .toSet()
          .toList()
        ..sort();
  if (values.length > 12) {
    throw ArgumentError.value(source, 'tags', 'must not exceed 12 values');
  }
  return UnmodifiableListView<String>(values);
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
