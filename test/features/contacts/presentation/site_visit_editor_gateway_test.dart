import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/features/contacts/domain/site_visit_repository.dart';
import 'package:budowapro/features/contacts/presentation/site_visit_editor_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'notification failure never rolls back a persisted site visit',
    () async {
      final repository = _VisitRepository();
      final gateway = SiteVisitEditorGateway(
        repository: repository,
        notifications: _FailingNotifications(),
      );

      final visit = await gateway.save(
        projectId: 'project-1',
        draft: _draft(),
        preferences: ReminderPreferences.defaults(),
        notificationBody: 'Nadchodzi wizyta',
      );

      expect(repository.saved, isTrue);
      expect(visit.id, 'visit-1');
    },
  );
}

SiteVisitDraft _draft() => SiteVisitDraft(
  contactId: 'contact-1',
  purpose: 'Ustalenie instalacji',
  expectedResult: 'Lista ustalen',
  status: SiteVisitStatus.planned,
  startsAt: DateTime.utc(2026, 7, 24, 8),
  timeZoneId: 'Europe/Warsaw',
  isAllDay: false,
  reminderEnabled: true,
  reminderLeadMinutes: 60,
);

final class _VisitRepository implements SiteVisitRepository {
  bool saved = false;

  @override
  Future<SiteVisit> create({
    required String projectId,
    required SiteVisitDraft draft,
  }) async {
    saved = true;
    return SiteVisit(
      id: 'visit-1',
      projectId: projectId,
      draft: draft,
      createdAt: DateTime.utc(2026, 7, 21),
      updatedAt: DateTime.utc(2026, 7, 21),
    );
  }

  @override
  Future<SiteVisit?> findById({
    required String projectId,
    required String visitId,
  }) => throw UnimplementedError();

  @override
  Future<List<SiteVisit>> listForContact({
    required String projectId,
    required String contactId,
  }) => throw UnimplementedError();

  @override
  Future<SiteVisit> update({
    required String projectId,
    required String visitId,
    required SiteVisitDraft draft,
    String? rescheduleReason,
  }) => throw UnimplementedError();
}

final class _FailingNotifications implements ScheduleNotificationGateway {
  @override
  Future<void> schedule(ScheduleNotificationRequest request) {
    throw StateError('permission denied');
  }

  @override
  Future<void> cancel(ScheduleEvent event) => throw UnimplementedError();

  @override
  Future<String> currentTimeZoneId() => throw UnimplementedError();

  @override
  DateTime fromWallTime(DateTime wallTime, String timeZoneId) =>
      throw UnimplementedError();

  @override
  Future<void> initialize(
    void Function(ScheduleNotificationTarget target) onOpen,
  ) => throw UnimplementedError();

  @override
  Future<NotificationPermissionState> permissionState() =>
      throw UnimplementedError();

  @override
  Future<NotificationPermissionState> requestPermission() =>
      throw UnimplementedError();

  @override
  DateTime toTimeZone(DateTime instant, String timeZoneId) =>
      throw UnimplementedError();
}
