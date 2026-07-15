typedef ProjectId = String;
typedef StageId = String;
typedef RoomId = String;
typedef ContactId = String;
typedef AttachmentId = String;

final class RecordContext {
  RecordContext({
    required ProjectId projectId,
    StageId? stageId,
    RoomId? roomId,
    ContactId? contactId,
    String? checklistItemId,
    String? costItemId,
    String? planPinId,
  }) : projectId = _requiredId(projectId, 'projectId'),
       stageId = _optionalId(stageId, 'stageId'),
       roomId = _optionalId(roomId, 'roomId'),
       contactId = _optionalId(contactId, 'contactId'),
       checklistItemId = _optionalId(checklistItemId, 'checklistItemId'),
       costItemId = _optionalId(costItemId, 'costItemId'),
       planPinId = _optionalId(planPinId, 'planPinId');

  final ProjectId projectId;
  final StageId? stageId;
  final RoomId? roomId;
  final ContactId? contactId;
  final String? checklistItemId;
  final String? costItemId;
  final String? planPinId;

  static String _requiredId(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'must not be empty');
    }
    return value;
  }

  static String? _optionalId(String? value, String name) {
    if (value == null) {
      return null;
    }
    return _requiredId(value, name);
  }
}
