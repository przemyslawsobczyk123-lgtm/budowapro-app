import 'package:budowapro/features/costs/data/cost_attachment_picker.dart';
import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/cost_relation.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/costs/domain/vat_breakdown.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cost_form_model.dart';

final costEditorGatewayProvider = FutureProvider<CostEditorGateway>((
  ref,
) async {
  return LocalCostEditorGateway(
    projectRepository: await ref.watch(projectRepositoryProvider.future),
    costRepository: await ref.watch(costRepositoryProvider.future),
    relationReader: await ref.watch(costRelationReaderProvider.future),
    attachmentStager: await ref.watch(costAttachmentStagerProvider.future),
    attachmentPicker: ref.watch(costAttachmentPickerProvider),
    stageRepository: await ref.watch(stageRepositoryProvider.future),
    contactRepository: await ref.watch(contactRepositoryProvider.future),
    utcNow: DateTime.now,
  );
});

abstract interface class CostEditorGateway {
  Future<CostEditorData> load({required String projectId, String? costEntryId});

  Future<CostEntry> save({
    required CostEditorData initialData,
    required CostFormSubmission submission,
    required bool asDraft,
  });

  Future<StagedCostAttachment?> pickAttachment(String projectId);

  Future<void> discardAttachment({
    required String projectId,
    required String attachmentId,
  });

  Future<CostEntry> copyAsDraft({
    required String projectId,
    required String costEntryId,
  });

  Future<CostEntry> changeStatus({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
  });

  Future<void> delete({required String projectId, required String costEntryId});

  Future<Page<CostHistoryEntry>> history({
    required String projectId,
    required String costEntryId,
    required PageRequest page,
  });
}

final class CostEditorData {
  CostEditorData({
    required this.project,
    required this.entry,
    required Iterable<StagedCostAttachment> attachments,
    Iterable<String> categoryOptions = const <String>[],
    Iterable<String> supplierOptions = const <String>[],
    Iterable<ProjectStage> stageOptions = const <ProjectStage>[],
    Iterable<Contact> contactOptions = const <Contact>[],
    this.relations = const CostRelations.empty(),
  }) : attachments = List<StagedCostAttachment>.unmodifiable(attachments),
       categoryOptions = List<String>.unmodifiable(categoryOptions),
       supplierOptions = List<String>.unmodifiable(supplierOptions),
       stageOptions = List<ProjectStage>.unmodifiable(stageOptions),
       contactOptions = List<Contact>.unmodifiable(contactOptions);

  final Project project;
  final CostEntry? entry;
  final List<StagedCostAttachment> attachments;
  final List<String> categoryOptions;
  final List<String> supplierOptions;
  final List<ProjectStage> stageOptions;
  final List<Contact> contactOptions;
  final CostRelations relations;
}

final class CostEditorNotFoundException implements Exception {
  const CostEditorNotFoundException();
}

final class LocalCostEditorGateway implements CostEditorGateway {
  factory LocalCostEditorGateway({
    required ProjectRepository projectRepository,
    required CostRepository costRepository,
    required CostRelationReader relationReader,
    required CostAttachmentStager attachmentStager,
    required CostAttachmentPicker attachmentPicker,
    required DateTime Function() utcNow,
    StageRepository? stageRepository,
    ContactRepository? contactRepository,
  }) {
    return LocalCostEditorGateway._(
      projectRepository,
      costRepository,
      relationReader,
      attachmentStager,
      attachmentPicker,
      stageRepository,
      contactRepository,
      utcNow,
    );
  }

  const LocalCostEditorGateway._(
    this._projectRepository,
    this._costRepository,
    this._relationReader,
    this._attachmentStager,
    this._attachmentPicker,
    this._stageRepository,
    this._contactRepository,
    this._utcNow,
  );

  final ProjectRepository _projectRepository;
  final CostRepository _costRepository;
  final CostRelationReader _relationReader;
  final CostAttachmentStager _attachmentStager;
  final CostAttachmentPicker _attachmentPicker;
  final StageRepository? _stageRepository;
  final ContactRepository? _contactRepository;
  final DateTime Function() _utcNow;

  @override
  Future<CostEditorData> load({
    required String projectId,
    String? costEntryId,
  }) async {
    final project = await _projectRepository.findById(projectId);
    if (project == null || project.isArchived) {
      throw const CostEditorNotFoundException();
    }
    CostEntry? entry;
    var attachments = const <StagedCostAttachment>[];
    var relations = const CostRelations.empty();
    if (costEntryId != null) {
      entry = await _costRepository.findById(
        projectId: projectId,
        costEntryId: costEntryId,
      );
      if (entry == null) {
        throw const CostEditorNotFoundException();
      }
      attachments = await _attachmentStager.listForCost(
        projectId: projectId,
        costEntryId: costEntryId,
      );
      relations = await _relationReader.load(
        projectId: projectId,
        costEntryId: costEntryId,
      );
    }
    final projectEntries = await _costRepository.list(
      CostQuery(projectId: projectId, includeDrafts: true),
      PageRequest(limit: PageRequest.maximumLimit),
    );
    final stageOptions = await _stageRepository?.listStages(
      projectId: projectId,
      template: project.template,
    );
    final contacts = <Contact>[];
    final contactRepository = _contactRepository;
    if (contactRepository != null) {
      var request = PageRequest(limit: PageRequest.maximumLimit);
      while (true) {
        final page = await contactRepository.list(
          ContactQuery(projectId: projectId),
          request,
        );
        contacts.addAll(page.items);
        final nextRequest = page.nextRequest;
        if (nextRequest == null) break;
        request = nextRequest;
      }
      final assignedContactId = entry?.input.contactId;
      if (assignedContactId != null &&
          !contacts.any((contact) => contact.id == assignedContactId)) {
        final assigned = await contactRepository.findById(
          projectId: projectId,
          contactId: assignedContactId,
        );
        if (assigned != null) contacts.add(assigned);
      }
      contacts.sort((left, right) {
        final byName = left.displayName.toLowerCase().compareTo(
          right.displayName.toLowerCase(),
        );
        return byName != 0 ? byName : left.id.compareTo(right.id);
      });
    }
    return CostEditorData(
      project: project,
      entry: entry,
      attachments: attachments,
      categoryOptions: _distinctOptions(
        projectEntries.items.map((item) => item.input.categoryId),
      ),
      supplierOptions: _distinctOptions(
        projectEntries.items.map((item) => item.input.supplierId),
      ),
      stageOptions: stageOptions ?? const <ProjectStage>[],
      contactOptions: contacts,
      relations: relations,
    );
  }

  @override
  Future<CostEntry> save({
    required CostEditorData initialData,
    required CostFormSubmission submission,
    required bool asDraft,
  }) async {
    final entry = initialData.entry;
    final input = parseCostForm(
      submission,
      projectId: initialData.project.id,
      currencyCode: initialData.project.currencyCode,
      asDraft: asDraft || entry?.lifecycle == CostLifecycle.draft,
    );

    if (entry == null) {
      return asDraft
          ? _costRepository.saveDraft(CostDraftInput(input))
          : _costRepository.create(ConfirmedCostEntryInput(input));
    }

    if (entry.lifecycle == CostLifecycle.draft) {
      final draftInput = CostDraftInput(input);
      if (asDraft) {
        return _costRepository.replaceDraft(
          projectId: entry.projectId,
          costEntryId: entry.id,
          input: draftInput,
        );
      }
      return _costRepository.confirmDraft(
        projectId: entry.projectId,
        costEntryId: entry.id,
        status: submission.status,
        replacement: draftInput,
      );
    }

    if (asDraft) {
      throw StateError('A confirmed cost cannot return to draft');
    }
    final confirmedInput = parseCostForm(
      submission,
      projectId: initialData.project.id,
      currencyCode: initialData.project.currencyCode,
      asDraft: false,
    );
    _requireImmutableFinancialFields(entry, confirmedInput);
    if (entry.amount.gross != confirmedInput.amount.gross) {
      final deltaGross = confirmedInput.amount.gross - entry.amount.gross;
      await _costRepository.addCorrection(
        CostCorrectionInput(
          projectId: entry.projectId,
          costEntryId: entry.id,
          reason: CostCorrectionReason.priceCorrection,
          delta: VatBreakdown.fromGross(deltaGross, entry.amount.rate),
        ),
      );
    }
    final updated = await _costRepository.updateDetails(
      projectId: entry.projectId,
      costEntryId: entry.id,
      input: ConfirmedCostDetailsInput(
        name: confirmedInput.name,
        component: confirmedInput.component,
        entryDate: confirmedInput.entryDate,
        stageId: confirmedInput.stageId,
        categoryId: confirmedInput.categoryId,
        supplierId: confirmedInput.supplierId,
        contactId: confirmedInput.contactId,
        quantity: confirmedInput.quantity,
        unit: confirmedInput.unit,
        paymentMethod: confirmedInput.paymentMethod,
        attachmentIds: confirmedInput.attachmentIds,
        note: confirmedInput.note,
      ),
    );
    if (entry.status == confirmedInput.status) {
      return updated;
    }
    return _costRepository.changeStatus(
      projectId: entry.projectId,
      costEntryId: entry.id,
      status: confirmedInput.status,
    );
  }

  @override
  Future<StagedCostAttachment?> pickAttachment(String projectId) async {
    final selected = await _attachmentPicker.pick();
    if (selected == null) {
      return null;
    }
    return _attachmentStager.stage(projectId: projectId, pickedFile: selected);
  }

  @override
  Future<void> discardAttachment({
    required String projectId,
    required String attachmentId,
  }) {
    return _attachmentStager.discard(
      projectId: projectId,
      attachmentId: attachmentId,
    );
  }

  @override
  Future<CostEntry> copyAsDraft({
    required String projectId,
    required String costEntryId,
  }) async {
    final original = await _costRepository.findById(
      projectId: projectId,
      costEntryId: costEntryId,
    );
    if (original == null) {
      throw const CostEditorNotFoundException();
    }
    final input = original.input;
    return _costRepository.saveDraft(
      CostDraftInput(
        CostEntryInput(
          projectId: input.projectId,
          name: input.name,
          type: input.type,
          component: input.component,
          status: input.status,
          amount: input.amount,
          entryDate: _utcNow(),
          stageId: input.stageId,
          categoryId: input.categoryId,
          supplierId: input.supplierId,
          contactId: input.contactId,
          quantity: input.quantity,
          unit: input.unit,
          paymentMethod: input.paymentMethod,
          source: CostSource.manual,
          note: input.note,
        ),
      ),
    );
  }

  @override
  Future<CostEntry> changeStatus({
    required String projectId,
    required String costEntryId,
    required CostStatus status,
  }) {
    return _costRepository.changeStatus(
      projectId: projectId,
      costEntryId: costEntryId,
      status: status,
    );
  }

  @override
  Future<void> delete({
    required String projectId,
    required String costEntryId,
  }) async {
    final attachments = await _attachmentStager.listForCost(
      projectId: projectId,
      costEntryId: costEntryId,
    );
    await _costRepository.delete(
      projectId: projectId,
      costEntryId: costEntryId,
    );
    for (final attachment in attachments) {
      try {
        await _attachmentStager.discardIfUnlinked(
          projectId: projectId,
          attachmentId: attachment.id,
        );
      } on Object {
        // The committed deletion stays successful; startup recovery owns cleanup.
      }
    }
  }

  @override
  Future<Page<CostHistoryEntry>> history({
    required String projectId,
    required String costEntryId,
    required PageRequest page,
  }) {
    return _costRepository.history(
      projectId: projectId,
      costEntryId: costEntryId,
      page: page,
    );
  }
}

void _requireImmutableFinancialFields(
  CostEntry existing,
  CostEntryInput submitted,
) {
  final original = existing.input;
  final amountChanged = original.amount.gross != submitted.amount.gross;
  if (original.type != submitted.type ||
      original.amount.rate != submitted.amount.rate ||
      (amountChanged && original.type != CostEntryType.cost)) {
    throw StateError('Confirmed financial fields require a correction');
  }
}

List<String> _distinctOptions(Iterable<String?> values) {
  final options = values.whereType<String>().toSet().toList()..sort();
  return options;
}
