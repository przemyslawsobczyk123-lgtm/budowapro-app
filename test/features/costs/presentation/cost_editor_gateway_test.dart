import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/costs/data/cost_attachment_picker.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/costs/presentation/cost_editor_gateway.dart';
import 'package:budowapro/features/costs/presentation/cost_form_model.dart';
import 'package:budowapro/features/projects/data/sqlite_project_repository.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:budowapro/shared/models/page.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late AppDatabase database;
  late SqliteCostRepository costRepository;
  late LocalCostEditorGateway gateway;
  var nextId = 0;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'budowapro_cost_gateway_test_',
    );
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(temporaryDirectory.path, 'budowapro.db'),
    );
    final fileStore = ProjectFileStore(
      rootDirectory: Directory(p.join(temporaryDirectory.path, 'private')),
    );
    final projectRepository = SqliteProjectRepository(
      database: database,
      fileStore: fileStore,
      idGenerator: () => 'project-1',
      utcNow: () => DateTime.utc(2026, 7, 15, 8),
    );
    await projectRepository.create(
      ProjectDraft(
        name: 'Dom',
        type: ProjectType.houseBuild,
        template: ProjectTemplate.houseConstruction,
      ),
    );
    final attachmentStager = CostAttachmentStager(
      database: database,
      fileStore: fileStore,
      idGenerator: () => 'attachment-${++nextId}',
      utcNow: () => DateTime.utc(2026, 7, 15, 9),
    );
    costRepository = SqliteCostRepository(
      database: database,
      idGenerator: () => 'record-${++nextId}',
      utcNow: () => DateTime.utc(2026, 7, 15, 10, nextId),
    );
    gateway = LocalCostEditorGateway(
      projectRepository: projectRepository,
      costRepository: costRepository,
      attachmentStager: attachmentStager,
      attachmentPicker: _FakeAttachmentPicker(),
      utcNow: () => DateTime.utc(2026, 7, 20),
    );
  });

  tearDown(() async {
    await database.close();
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('saves, reloads, copies and deletes a complete local cost', () async {
    final source = File(p.join(temporaryDirectory.path, 'invoice.pdf'));
    await source.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
    final picker = gateway;
    _FakeAttachmentPicker.next = PickedCostAttachment(
      sourceUri: source.uri,
      displayName: 'invoice.pdf',
      reportedByteSize: 4,
      mediaType: 'application/pdf',
    );
    final initial = await picker.load(projectId: 'project-1');
    final attachment = await picker.pickAttachment('project-1');

    final saved = await picker.save(
      initialData: initial,
      submission: _submission(
        status: CostStatus.due,
        attachmentIds: <String>[attachment!.id],
      ),
      asDraft: false,
    );
    final reloaded = await picker.load(
      projectId: 'project-1',
      costEntryId: saved.id,
    );
    final paid = await picker.changeStatus(
      projectId: 'project-1',
      costEntryId: saved.id,
      status: CostStatus.paid,
    );
    final copy = await picker.copyAsDraft(
      projectId: 'project-1',
      costEntryId: saved.id,
    );

    expect(reloaded.attachments.single.displayName, 'invoice.pdf');
    expect(reloaded.categoryOptions, const <String>['materialy']);
    expect(reloaded.supplierOptions, const <String>['betoniarnia']);
    expect(paid.status, CostStatus.paid);
    expect(copy.lifecycle, CostLifecycle.draft);
    expect(copy.status, CostStatus.paid);
    expect(copy.input.attachmentIds, isEmpty);
    expect(copy.entryDate, DateTime.utc(2026, 7, 20));

    await picker.delete(projectId: 'project-1', costEntryId: copy.id);
    expect(
      () => picker.load(projectId: 'project-1', costEntryId: copy.id),
      throwsA(isA<CostEditorNotFoundException>()),
    );
  });

  test(
    'confirmed edit records a price correction without losing history',
    () async {
      final initial = await gateway.load(projectId: 'project-1');
      final saved = await gateway.save(
        initialData: initial,
        submission: _submission(status: CostStatus.paid),
        asDraft: false,
      );
      final editData = await gateway.load(
        projectId: 'project-1',
        costEntryId: saved.id,
      );

      final edited = await gateway.save(
        initialData: editData,
        submission: _submission(status: CostStatus.paid, grossAmount: '999,00'),
        asDraft: false,
      );
      final unchanged = await gateway.load(
        projectId: 'project-1',
        costEntryId: saved.id,
      );
      expect(unchanged.entry!.amount.gross, saved.amount.gross);
      expect(edited.revision, saved.revision + 2);

      final summary = await costRepository.summarize(
        CostSummaryQuery(projectId: 'project-1'),
      );
      expect(summary.actual.minorUnits, 99900);
      final exported = await costRepository.exportRows(
        CostQuery(projectId: 'project-1'),
        PageRequest(limit: 10),
      );
      expect(exported.items.single.effectiveGross.minorUnits, 99900);
    },
  );

  test('updates and confirms an existing draft in one operation', () async {
    final initial = await gateway.load(projectId: 'project-1');
    final draft = await gateway.save(
      initialData: initial,
      submission: _submission(status: CostStatus.due),
      asDraft: true,
    );
    final editData = await gateway.load(
      projectId: 'project-1',
      costEntryId: draft.id,
    );
    expect(editData.entry!.status, CostStatus.due);

    final confirmed = await gateway.save(
      initialData: editData,
      submission: _submission(name: 'Zmieniona nazwa', status: CostStatus.due),
      asDraft: false,
    );

    expect(confirmed.lifecycle, CostLifecycle.confirmed);
    expect(confirmed.status, CostStatus.due);
    expect(confirmed.name, 'Zmieniona nazwa');
    expect(confirmed.revision, 2);
  });

  test(
    'deleting a draft preserves an attachment shared by another cost',
    () async {
      final source = File(p.join(temporaryDirectory.path, 'shared.pdf'));
      await source.writeAsBytes(<int>[4, 3, 2, 1], flush: true);
      _FakeAttachmentPicker.next = PickedCostAttachment(
        sourceUri: source.uri,
        displayName: 'shared.pdf',
        reportedByteSize: 4,
        mediaType: 'application/pdf',
      );
      final initial = await gateway.load(projectId: 'project-1');
      final attachment = await gateway.pickAttachment('project-1');
      final first = await gateway.save(
        initialData: initial,
        submission: _submission(attachmentIds: <String>[attachment!.id]),
        asDraft: true,
      );
      final second = await gateway.save(
        initialData: initial,
        submission: _submission(
          name: 'Drugi szkic',
          attachmentIds: <String>[attachment.id],
        ),
        asDraft: true,
      );

      await gateway.delete(projectId: 'project-1', costEntryId: first.id);

      final remaining = await gateway.load(
        projectId: 'project-1',
        costEntryId: second.id,
      );
      expect(remaining.attachments.single.id, attachment.id);
    },
  );
}

CostFormSubmission _submission({
  String name = 'Faktura za beton',
  CostStatus status = CostStatus.paid,
  String grossAmount = '1230,00',
  Iterable<String> attachmentIds = const <String>[],
}) {
  return CostFormSubmission(
    name: name,
    type: CostEntryType.cost,
    status: status,
    grossAmount: grossAmount,
    vatRate: VatRate.standard23,
    entryDate: DateTime.utc(2026, 7, 15),
    stageId: 'state_zero',
    categoryId: 'materialy',
    supplierId: 'betoniarnia',
    quantity: '10',
    unit: 'm3',
    paymentMethod: CostPaymentMethod.bankTransfer,
    note: 'Dostawa rano',
    attachmentIds: attachmentIds,
  );
}

final class _FakeAttachmentPicker implements CostAttachmentPicker {
  static PickedCostAttachment? next;

  @override
  Future<PickedCostAttachment?> pick() async {
    final selected = next;
    next = null;
    return selected;
  }
}
