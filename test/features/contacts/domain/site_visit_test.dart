import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final startsAt = DateTime.parse('2026-07-24T09:00:00+02:00');
  final now = DateTime.utc(2026, 7, 21, 10);

  test('normalizes visit time and exposes its schedule projection', () {
    final visit = SiteVisit(
      id: 'visit-1',
      projectId: 'project-1',
      draft: SiteVisitDraft(
        contactId: 'contact-1',
        purpose: '  Ustalenie tras przewodow ',
        expectedResult: ' Zatwierdzony przebieg instalacji. ',
        status: SiteVisitStatus.planned,
        startsAt: startsAt,
        timeZoneId: 'Europe/Warsaw',
        isAllDay: false,
        reminderEnabled: true,
        reminderLeadMinutes: 120,
        stageId: 'stage-1',
      ),
      createdAt: now,
      updatedAt: now,
    );

    expect(visit.startsAtUtc, DateTime.utc(2026, 7, 24, 7));
    expect(visit.purpose, 'Ustalenie tras przewodow');
    expect(visit.expectedResult, 'Zatwierdzony przebieg instalacji.');
    expect(visit.scheduleEvent.kind.name, 'visit');
    expect(visit.scheduleEvent.title, visit.purpose);
    expect(visit.scheduleEvent.startsAtUtc, visit.startsAtUtc);
  });

  test('completed visit requires a result and no-show remains resolved', () {
    expect(
      () => _draft(status: SiteVisitStatus.completed),
      throwsArgumentError,
    );

    final noShow = SiteVisit(
      id: 'visit-2',
      projectId: 'project-1',
      draft: _draft(status: SiteVisitStatus.noShow),
      createdAt: now,
      updatedAt: now,
    );

    expect(noShow.isResolved, isTrue);
    expect(noShow.scheduleEvent.isResolved, isTrue);
  });

  test('rejects invalid end time and reminder lead', () {
    expect(
      () => _draft(endsAt: startsAt.subtract(const Duration(minutes: 1))),
      throwsArgumentError,
    );
    expect(() => _draft(reminderLeadMinutes: 10081), throwsRangeError);
  });
}

SiteVisitDraft _draft({
  SiteVisitStatus status = SiteVisitStatus.planned,
  DateTime? endsAt,
  int reminderLeadMinutes = 60,
  String? result,
}) {
  return SiteVisitDraft(
    contactId: 'contact-1',
    purpose: 'Odbior instalacji',
    expectedResult: 'Lista ustalen',
    status: status,
    startsAt: DateTime.parse('2026-07-24T09:00:00+02:00'),
    endsAt: endsAt,
    timeZoneId: 'Europe/Warsaw',
    isAllDay: false,
    reminderEnabled: true,
    reminderLeadMinutes: reminderLeadMinutes,
    result: result,
  );
}
