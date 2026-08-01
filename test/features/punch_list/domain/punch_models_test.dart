import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes a defect and keeps explicit closure requirements', () {
    final input = DefectInput(
      projectId: ' project-1 ',
      title: ' Wilgoc przy przepuscie ',
      occurredAt: DateTime.parse('2026-07-31T10:00:00+02:00'),
      severity: DefectSeverity.critical,
      roomLabel: ' Kotlownia ',
      description: ' Slad wilgoci przy rurze. ',
      requiresResolutionPhoto: true,
      requiresSignedProtocol: true,
    );

    expect(input.projectId, 'project-1');
    expect(input.title, 'Wilgoc przy przepuscie');
    expect(input.occurredAtUtc, DateTime.utc(2026, 7, 31, 8));
    expect(input.roomLabel, 'Kotlownia');
    expect(input.description, 'Slad wilgoci przy rurze.');
    expect(input.status, JournalEntryStatus.open);
    expect(input.requiresResolutionPhoto, isTrue);
    expect(input.requiresSignedProtocol, isTrue);
  });

  test('rejects statuses that do not belong to a defect', () {
    expect(
      () => DefectInput(
        projectId: 'project-1',
        title: 'Usterka',
        occurredAt: DateTime.utc(2026, 7, 31),
        severity: DefectSeverity.medium,
        status: JournalEntryStatus.approved,
      ),
      throwsArgumentError,
    );
  });

  test('signed protocol requires at least one imported signed document', () {
    expect(
      () => AcceptanceProtocolInput(
        projectId: 'project-1',
        title: 'Odbior instalacji',
        inspectedAt: DateTime.utc(2026, 7, 31),
        status: AcceptanceProtocolStatus.signed,
        defectIds: const <String>['defect-1'],
      ),
      throwsArgumentError,
    );

    final input = AcceptanceProtocolInput(
      projectId: 'project-1',
      title: 'Odbior instalacji',
      inspectedAt: DateTime.utc(2026, 7, 31),
      status: AcceptanceProtocolStatus.signed,
      defectIds: const <String>['defect-1', 'defect-1'],
      signedAttachmentIds: const <String>['signed-1', 'signed-1'],
    );

    expect(input.defectIds, <String>['defect-1']);
    expect(input.signedAttachmentIds, <String>['signed-1']);
  });

  test('summary counts every non-closed state and overdue deadlines', () {
    final now = DateTime.utc(2026, 7, 31, 12);
    final defects = <DefectRecord>[
      _defect(
        id: 'critical-overdue',
        severity: DefectSeverity.critical,
        dueAt: now.subtract(const Duration(minutes: 1)),
      ),
      _defect(
        id: 'fixed-open',
        status: JournalEntryStatus.fixed,
        severity: DefectSeverity.low,
      ),
      _defect(
        id: 'closed',
        status: JournalEntryStatus.closed,
        severity: DefectSeverity.critical,
        dueAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    final summary = PunchSummary.fromDefects(defects, now: now);

    expect(summary.openCount, 2);
    expect(summary.criticalCount, 1);
    expect(summary.overdueCount, 1);
  });
}

DefectRecord _defect({
  required String id,
  JournalEntryStatus status = JournalEntryStatus.open,
  DefectSeverity severity = DefectSeverity.medium,
  DateTime? dueAt,
}) {
  return DefectRecord(
    entry: JournalEntry(
      id: id,
      input: JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.defect,
        title: id,
        occurredAt: DateTime.utc(2026, 7, 30),
        status: status,
        defectSeverity: severity,
        dueAt: dueAt,
      ),
      createdAt: DateTime.utc(2026, 7, 30),
      updatedAt: DateTime.utc(2026, 7, 30),
      revision: 1,
    ),
  );
}
