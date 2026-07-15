import 'record_context.dart';

enum AuditAction { created, updated, deleted }

enum AuditSource { user, import, assistant, system }

final class AuditMetadata {
  AuditMetadata({
    required String id,
    required ProjectId projectId,
    required String entityType,
    required String entityId,
    required this.action,
    required this.source,
    required DateTime occurredAt,
  }) : id = _requiredValue(id, 'id'),
       projectId = _requiredValue(projectId, 'projectId'),
       entityType = _requiredValue(entityType, 'entityType'),
       entityId = _requiredValue(entityId, 'entityId'),
       occurredAtUtc = occurredAt.toUtc();

  final String id;
  final ProjectId projectId;
  final String entityType;
  final String entityId;
  final AuditAction action;
  final AuditSource source;
  final DateTime occurredAtUtc;

  static String _requiredValue(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'must not be empty');
    }
    return value;
  }
}
