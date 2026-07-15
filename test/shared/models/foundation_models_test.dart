import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/shared/models/audit_metadata.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:budowapro/shared/models/record_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores dates as UTC milliseconds and restores a UTC value', () {
    final localDate = DateTime(2026, 7, 15, 12, 30);

    final stored = DatabaseValueCodec.dateTimeToUtcMilliseconds(localDate);
    final restored = DatabaseValueCodec.utcMillisecondsToDateTime(stored);

    expect(restored, localDate.toUtc());
    expect(restored.isUtc, isTrue);
  });

  test('record context requires a project identifier', () {
    expect(() => RecordContext(projectId: ''), throwsArgumentError);
    expect(RecordContext(projectId: 'project-1').projectId, 'project-1');
  });

  test('record context rejects empty optional identifiers', () {
    final invalidContexts = <RecordContext Function()>[
      () => RecordContext(projectId: 'project-1', stageId: ' '),
      () => RecordContext(projectId: 'project-1', roomId: ''),
      () => RecordContext(projectId: 'project-1', contactId: ''),
      () => RecordContext(projectId: 'project-1', checklistItemId: ''),
      () => RecordContext(projectId: 'project-1', costItemId: ''),
      () => RecordContext(projectId: 'project-1', planPinId: ''),
    ];

    for (final createContext in invalidContexts) {
      expect(createContext, throwsArgumentError);
    }
  });

  test('audit metadata normalizes its timestamp to UTC', () {
    final audit = AuditMetadata(
      id: 'audit-1',
      projectId: 'project-1',
      entityType: 'cost',
      entityId: 'cost-1',
      action: AuditAction.created,
      source: AuditSource.user,
      occurredAt: DateTime(2026, 7, 15, 12, 30),
    );

    expect(audit.occurredAtUtc.isUtc, isTrue);
    expect(audit.occurredAtUtc, DateTime(2026, 7, 15, 12, 30).toUtc());
  });

  test('page request validates bounds and advances by page size', () {
    final firstPage = PageRequest();

    expect(firstPage.offset, 0);
    expect(firstPage.limit, PageRequest.defaultLimit);
    expect(firstPage.next(), PageRequest(offset: PageRequest.defaultLimit));
    expect(() => PageRequest(offset: -1), throwsRangeError);
    expect(() => PageRequest(limit: 0), throwsRangeError);
    expect(
      () => PageRequest(limit: PageRequest.maximumLimit + 1),
      throwsRangeError,
    );
  });

  test('page reports whether more persisted rows are available', () {
    final page = Page<String>(
      items: const <String>['a', 'b'],
      totalCount: 3,
      request: PageRequest(limit: 2),
    );

    expect(page.hasNext, isTrue);
    expect(page.nextRequest, PageRequest(offset: 2, limit: 2));
  });
}
