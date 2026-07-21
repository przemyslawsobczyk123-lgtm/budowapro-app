import 'dart:collection';

import 'package:budowapro/shared/models/page.dart';

import 'project_document.dart';

abstract interface class DocumentRepository {
  Future<ProjectDocument?> findById({
    required String projectId,
    required String documentId,
  });

  Future<Page<ProjectDocument>> list(DocumentQuery query, PageRequest page);

  Future<DocumentFilterOptions> filterOptions({required String projectId});

  Future<ProjectDocument> updateMetadata({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
  });

  Future<ProjectDocument> replaceContextLinks({
    required String projectId,
    required String documentId,
    required Iterable<DocumentRelation> links,
  });

  Future<ProjectDocument> saveDetails({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
    required Iterable<DocumentRelation> contextLinks,
  });

  Future<List<ProjectDocument>> findPotentialDuplicates({
    required String projectId,
    required String sha256,
    String? excludingDocumentId,
  });
}

enum DocumentSort { newest, oldest, nameAscending }

final class DocumentQuery {
  factory DocumentQuery({
    required String projectId,
    String? searchText,
    Set<ProjectDocumentType> types = const <ProjectDocumentType>{},
    Set<String> stageIds = const <String>{},
    Set<String> roomIds = const <String>{},
    Set<DocumentWarrantyState> warrantyStates = const <DocumentWarrantyState>{},
    DateTime? fromInclusive,
    DateTime? toExclusive,
    DocumentSort sort = DocumentSort.newest,
  }) {
    final fromUtc = fromInclusive?.toUtc();
    final toUtc = toExclusive?.toUtc();
    if (fromUtc != null && toUtc != null && !fromUtc.isBefore(toUtc)) {
      throw ArgumentError.value(toExclusive, 'toExclusive');
    }
    return DocumentQuery._(
      projectId: _requiredText(projectId, 'projectId', 64),
      searchText: _optionalText(searchText, 'searchText', 120)?.toLowerCase(),
      types: UnmodifiableSetView<ProjectDocumentType>(
        Set<ProjectDocumentType>.of(types),
      ),
      stageIds: _ids(stageIds, 'stageIds'),
      roomIds: _ids(roomIds, 'roomIds'),
      warrantyStates: UnmodifiableSetView<DocumentWarrantyState>(
        Set<DocumentWarrantyState>.of(warrantyStates),
      ),
      fromInclusiveUtc: fromUtc,
      toExclusiveUtc: toUtc,
      sort: sort,
    );
  }

  const DocumentQuery._({
    required this.projectId,
    required this.searchText,
    required this.types,
    required this.stageIds,
    required this.roomIds,
    required this.warrantyStates,
    required this.fromInclusiveUtc,
    required this.toExclusiveUtc,
    required this.sort,
  });

  final String projectId;
  final String? searchText;
  final UnmodifiableSetView<ProjectDocumentType> types;
  final UnmodifiableSetView<String> stageIds;
  final UnmodifiableSetView<String> roomIds;
  final UnmodifiableSetView<DocumentWarrantyState> warrantyStates;
  final DateTime? fromInclusiveUtc;
  final DateTime? toExclusiveUtc;
  final DocumentSort sort;

  int get activeFilterCount {
    var count = 0;
    if (searchText != null) count++;
    if (types.isNotEmpty) count++;
    if (stageIds.isNotEmpty) count++;
    if (roomIds.isNotEmpty) count++;
    if (warrantyStates.isNotEmpty) count++;
    if (fromInclusiveUtc != null || toExclusiveUtc != null) count++;
    return count;
  }
}

final class DocumentFilterOption {
  factory DocumentFilterOption({required String id, required String label}) {
    return DocumentFilterOption._(
      id: _requiredText(id, 'id', 120),
      label: _requiredText(label, 'label', 160),
    );
  }

  const DocumentFilterOption._({required this.id, required this.label});

  final String id;
  final String label;
}

final class DocumentFilterOptions {
  DocumentFilterOptions({
    Iterable<DocumentFilterOption> stages = const <DocumentFilterOption>[],
    Iterable<DocumentFilterOption> rooms = const <DocumentFilterOption>[],
  }) : stages = UnmodifiableListView<DocumentFilterOption>(stages),
       rooms = UnmodifiableListView<DocumentFilterOption>(rooms);

  final UnmodifiableListView<DocumentFilterOption> stages;
  final UnmodifiableListView<DocumentFilterOption> rooms;
}

final class DocumentNotFoundException implements Exception {
  const DocumentNotFoundException();
}

UnmodifiableSetView<String> _ids(Iterable<String> source, String name) {
  final values = source.map((value) => _requiredText(value, name, 120)).toSet();
  if (values.length > 50) {
    throw ArgumentError.value(source, name, 'must not exceed 50 values');
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
