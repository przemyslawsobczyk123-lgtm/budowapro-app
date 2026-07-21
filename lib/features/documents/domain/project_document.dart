import 'dart:collection';

enum ProjectDocumentType {
  receipt,
  invoice,
  quote,
  contract,
  deliveryNote,
  protocol,
  warranty,
  instruction,
  map,
  photo,
  other,
}

enum DocumentWarrantyState { withoutWarranty, active, expiringSoon, expired }

enum DocumentRelationType {
  cost,
  stage,
  checklistItem,
  contact,
  room,
  quote,
  decision,
  defect,
  device,
}

final class DocumentRelation {
  factory DocumentRelation({
    required DocumentRelationType type,
    required String targetId,
    required String label,
  }) {
    return DocumentRelation._(
      type: type,
      targetId: _requiredText(targetId, 'targetId', 120),
      label: _requiredText(label, 'label', 160),
    );
  }

  const DocumentRelation._({
    required this.type,
    required this.targetId,
    required this.label,
  });

  final DocumentRelationType type;
  final String targetId;
  final String label;
}

final class DocumentMetadata {
  factory DocumentMetadata({
    required String title,
    required ProjectDocumentType type,
    String? description,
    DateTime? documentDate,
    DateTime? warrantyStartsAt,
    DateTime? warrantyEndsAt,
    DateTime? warrantyReminderAt,
  }) {
    final startsAtUtc = warrantyStartsAt?.toUtc();
    final endsAtUtc = warrantyEndsAt?.toUtc();
    final reminderAtUtc = warrantyReminderAt?.toUtc();
    if ((startsAtUtc == null) != (endsAtUtc == null)) {
      throw ArgumentError(
        'Warranty start and end must either both be set or both be absent',
      );
    }
    if (startsAtUtc != null && endsAtUtc!.isBefore(startsAtUtc)) {
      throw ArgumentError.value(
        warrantyEndsAt,
        'warrantyEndsAt',
        'must not be before warrantyStartsAt',
      );
    }
    if (reminderAtUtc != null) {
      if (endsAtUtc == null) {
        throw ArgumentError.value(
          warrantyReminderAt,
          'warrantyReminderAt',
          'requires a warranty period',
        );
      }
      if (reminderAtUtc.isAfter(endsAtUtc)) {
        throw ArgumentError.value(
          warrantyReminderAt,
          'warrantyReminderAt',
          'must not be after warrantyEndsAt',
        );
      }
    }
    return DocumentMetadata._(
      title: _requiredText(title, 'title', 160),
      type: type,
      description: _optionalText(description, 'description', 2000),
      documentDateUtc: documentDate?.toUtc(),
      warrantyStartsAtUtc: startsAtUtc,
      warrantyEndsAtUtc: endsAtUtc,
      warrantyReminderAtUtc: reminderAtUtc,
    );
  }

  const DocumentMetadata._({
    required this.title,
    required this.type,
    required this.description,
    required this.documentDateUtc,
    required this.warrantyStartsAtUtc,
    required this.warrantyEndsAtUtc,
    required this.warrantyReminderAtUtc,
  });

  final String title;
  final ProjectDocumentType type;
  final String? description;
  final DateTime? documentDateUtc;
  final DateTime? warrantyStartsAtUtc;
  final DateTime? warrantyEndsAtUtc;
  final DateTime? warrantyReminderAtUtc;

  DocumentWarrantyState warrantyStateAt(
    DateTime instant, {
    Duration expiringWindow = const Duration(days: 30),
  }) {
    if (expiringWindow.isNegative) {
      throw ArgumentError.value(expiringWindow, 'expiringWindow');
    }
    final end = warrantyEndsAtUtc;
    if (end == null) return DocumentWarrantyState.withoutWarranty;
    final now = instant.toUtc();
    if (end.isBefore(now)) return DocumentWarrantyState.expired;
    if (!end.isAfter(now.add(expiringWindow))) {
      return DocumentWarrantyState.expiringSoon;
    }
    return DocumentWarrantyState.active;
  }
}

final class ProjectDocument {
  factory ProjectDocument({
    required String id,
    required String projectId,
    required String displayName,
    required DocumentMetadata metadata,
    required int byteSize,
    required DateTime importedAt,
    required Iterable<DocumentRelation> relations,
    String? mediaType,
    String? sha256,
    bool hasPreview = false,
  }) {
    if (byteSize < 0) {
      throw RangeError.value(byteSize, 'byteSize', 'must not be negative');
    }
    final relationList = relations.toList(growable: false);
    final relationKeys = relationList
        .map((relation) => '${relation.type.name}:${relation.targetId}')
        .toSet();
    if (relationKeys.length != relationList.length) {
      throw ArgumentError.value(relations, 'relations', 'contains duplicates');
    }
    return ProjectDocument._(
      id: _requiredText(id, 'id', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      displayName: _requiredText(displayName, 'displayName', 255),
      metadata: metadata,
      byteSize: byteSize,
      mediaType: _optionalText(mediaType, 'mediaType', 120),
      sha256: _optionalSha256(sha256),
      hasPreview: hasPreview,
      importedAtUtc: importedAt.toUtc(),
      relations: UnmodifiableListView<DocumentRelation>(relationList),
    );
  }

  const ProjectDocument._({
    required this.id,
    required this.projectId,
    required this.displayName,
    required this.metadata,
    required this.byteSize,
    required this.mediaType,
    required this.sha256,
    required this.hasPreview,
    required this.importedAtUtc,
    required this.relations,
  });

  final String id;
  final String projectId;
  final String displayName;
  final DocumentMetadata metadata;
  final int byteSize;
  final String? mediaType;
  final String? sha256;
  final bool hasPreview;
  final DateTime importedAtUtc;
  final UnmodifiableListView<DocumentRelation> relations;

  bool get isPdf => mediaType == 'application/pdf';

  bool get isImage => mediaType?.startsWith('image/') ?? false;
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

String? _optionalSha256(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(normalized)) {
    throw ArgumentError.value(value, 'sha256');
  }
  return normalized;
}
