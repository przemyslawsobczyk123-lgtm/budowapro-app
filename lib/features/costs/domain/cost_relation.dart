import 'dart:collection';

enum CostRelationType { room, material }

abstract interface class CostRelationReader {
  Future<CostRelations> load({
    required String projectId,
    required String costEntryId,
  });
}

final class CostRelations {
  CostRelations(Iterable<CostRelationReference> items)
    : items = UnmodifiableListView<CostRelationReference>(items);

  const CostRelations.empty() : items = const <CostRelationReference>[];

  final List<CostRelationReference> items;

  bool get isEmpty => items.isEmpty;
}

final class CostRelationReference {
  factory CostRelationReference({
    required CostRelationType type,
    required String recordId,
    required String label,
  }) {
    final normalizedId = recordId.trim();
    final normalizedLabel = label.trim();
    if (normalizedId.isEmpty || normalizedId.length > 64) {
      throw ArgumentError.value(recordId, 'recordId');
    }
    if (normalizedLabel.isEmpty || normalizedLabel.length > 160) {
      throw ArgumentError.value(label, 'label');
    }
    return CostRelationReference._(
      type: type,
      recordId: normalizedId,
      label: normalizedLabel,
    );
  }

  const CostRelationReference._({
    required this.type,
    required this.recordId,
    required this.label,
  });

  final CostRelationType type;
  final String recordId;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is CostRelationReference &&
      other.type == type &&
      other.recordId == recordId &&
      other.label == label;

  @override
  int get hashCode => Object.hash(type, recordId, label);
}
