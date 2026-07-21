import 'dart:collection';

enum ContactKind { person, company }

enum ContactRole {
  generalContractor,
  siteManager,
  architect,
  electrician,
  plumber,
  heatingAndVentilation,
  surveyor,
  roofer,
  carpenter,
  plasterer,
  tiler,
  painter,
  supplier,
  inspector,
  other,
}

final class ContactDraft {
  factory ContactDraft({
    required String displayName,
    required ContactKind kind,
    required Iterable<ContactRole> roles,
    Iterable<String> stageIds = const <String>[],
    String? phone,
    String? email,
    String? taxId,
    String? note,
    int? rating,
  }) {
    final normalizedRoles = Set<ContactRole>.of(roles);
    if (normalizedRoles.isEmpty) {
      throw ArgumentError.value(roles, 'roles', 'must not be empty');
    }
    if (rating != null && (rating < 1 || rating > 5)) {
      throw RangeError.range(rating, 1, 5, 'rating');
    }
    final normalizedEmail = _optionalText(email, 'email', 254)?.toLowerCase();
    if (normalizedEmail != null && !_emailPattern.hasMatch(normalizedEmail)) {
      throw ArgumentError.value(email, 'email');
    }
    return ContactDraft._(
      displayName: _requiredText(displayName, 'displayName', 160),
      kind: kind,
      roles: UnmodifiableSetView<ContactRole>(normalizedRoles),
      stageIds: UnmodifiableSetView<String>(
        stageIds.map((value) => _requiredText(value, 'stageId', 64)).toSet(),
      ),
      phone: _optionalText(phone, 'phone', 40),
      email: normalizedEmail,
      taxId: _optionalText(taxId, 'taxId', 24),
      note: _optionalText(note, 'note', 2000),
      rating: rating,
    );
  }

  const ContactDraft._({
    required this.displayName,
    required this.kind,
    required this.roles,
    required this.stageIds,
    required this.phone,
    required this.email,
    required this.taxId,
    required this.note,
    required this.rating,
  });

  final String displayName;
  final ContactKind kind;
  final UnmodifiableSetView<ContactRole> roles;
  final UnmodifiableSetView<String> stageIds;
  final String? phone;
  final String? email;
  final String? taxId;
  final String? note;
  final int? rating;
}

final class Contact {
  factory Contact({
    required String id,
    required String projectId,
    required ContactDraft draft,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isArchived = false,
  }) {
    final createdAtUtc = createdAt.toUtc();
    final updatedAtUtc = updatedAt.toUtc();
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(updatedAt, 'updatedAt');
    }
    return Contact._(
      id: _requiredText(id, 'id', 64),
      projectId: _requiredText(projectId, 'projectId', 64),
      draft: draft,
      isArchived: isArchived,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const Contact._({
    required this.id,
    required this.projectId,
    required this.draft,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String projectId;
  final ContactDraft draft;
  final bool isArchived;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get displayName => draft.displayName;
  ContactKind get kind => draft.kind;
  UnmodifiableSetView<ContactRole> get roles => draft.roles;
  UnmodifiableSetView<String> get stageIds => draft.stageIds;
  String? get phone => draft.phone;
  String? get email => draft.email;
  String? get taxId => draft.taxId;
  String? get note => draft.note;
  int? get rating => draft.rating;
}

final class ContactQuery {
  factory ContactQuery({
    required String projectId,
    String? searchTerm,
    ContactRole? role,
    String? stageId,
    bool includeArchived = false,
  }) {
    return ContactQuery._(
      projectId: _requiredText(projectId, 'projectId', 64),
      searchTerm: _optionalText(searchTerm, 'searchTerm', 160)?.toLowerCase(),
      role: role,
      stageId: _optionalText(stageId, 'stageId', 64),
      includeArchived: includeArchived,
    );
  }

  const ContactQuery._({
    required this.projectId,
    required this.searchTerm,
    required this.role,
    required this.stageId,
    required this.includeArchived,
  });

  final String projectId;
  final String? searchTerm;
  final ContactRole? role;
  final String? stageId;
  final bool includeArchived;
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

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
  if (normalized.length > maximumLength) {
    throw ArgumentError.value(value, name);
  }
  return normalized;
}
