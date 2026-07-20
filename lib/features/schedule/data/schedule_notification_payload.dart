import 'dart:convert';

import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';

abstract final class ScheduleNotificationPayload {
  static String encode(ScheduleNotificationTarget target) {
    return jsonEncode(<String, String>{
      'projectId': target.projectId,
      'eventId': target.eventId,
    });
  }

  static ScheduleNotificationTarget? decode(String? payload) {
    if (payload == null || payload.length > 256) return null;
    try {
      final value = jsonDecode(payload);
      if (value is! Map<String, dynamic>) return null;
      final projectId = value['projectId'];
      final eventId = value['eventId'];
      if (!_validId(projectId) || !_validId(eventId)) return null;
      return ScheduleNotificationTarget(
        projectId: projectId! as String,
        eventId: eventId! as String,
      );
    } on FormatException {
      return null;
    }
  }

  static bool _validId(Object? value) {
    return value is String && value.isNotEmpty && value.length <= 64;
  }
}
