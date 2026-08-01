import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults statuses by journal type and normalizes UTC dates', () {
    final input = JournalEntryInput(
      projectId: 'project-1',
      type: JournalEntryType.decision,
      title: 'Wariant izolacji',
      occurredAt: DateTime(2026, 7, 30, 10),
    );

    expect(input.status, JournalEntryStatus.proposal);
    expect(input.occurredAt.isUtc, isTrue);
  });

  test('keeps only unique attachment ids and rejects an invalid status', () {
    final input = JournalEntryInput(
      projectId: 'project-1',
      type: JournalEntryType.note,
      title: 'Notatka',
      occurredAt: DateTime.now(),
      attachmentIds: const <String>['file-1', 'file-1', 'file-2'],
    );

    expect(input.attachmentIds, <String>['file-1', 'file-2']);
    expect(
      () => JournalEntryInput(
        projectId: 'project-1',
        type: JournalEntryType.defect,
        title: 'Usterka',
        occurredAt: DateTime.now(),
        status: JournalEntryStatus.approved,
      ),
      throwsArgumentError,
    );
  });
}
