import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/costs/data/cost_attachment_picker.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/quotes/data/quote_providers.dart';
import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/features/quotes/domain/quote_repository.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quoteEditorGatewayProvider = FutureProvider<QuoteEditorGateway>((
  ref,
) async {
  return LocalQuoteEditorGateway(
    projectRepository: await ref.watch(projectRepositoryProvider.future),
    contactRepository: await ref.watch(contactRepositoryProvider.future),
    stageRepository: await ref.watch(stageRepositoryProvider.future),
    quoteRepository: await ref.watch(quoteRepositoryProvider.future),
    attachmentStager: await ref.watch(costAttachmentStagerProvider.future),
    attachmentPicker: ref.watch(costAttachmentPickerProvider),
  );
});

abstract interface class QuoteEditorGateway {
  Future<QuoteEditorData> load({required String projectId, String? quoteId});

  Future<ContractorQuote> save({
    required String projectId,
    String? quoteId,
    required ContractorQuoteDraft draft,
  });

  Future<StagedCostAttachment?> pickAttachment(String projectId);

  Future<bool> discardIfUnlinked({
    required String projectId,
    required String attachmentId,
  });
}

final class QuoteEditorData {
  QuoteEditorData({
    required this.project,
    required this.quote,
    required Iterable<Contact> contacts,
    required Iterable<ProjectStage> stages,
    required Iterable<StagedCostAttachment> attachments,
  }) : contacts = List<Contact>.unmodifiable(contacts),
       stages = List<ProjectStage>.unmodifiable(stages),
       attachments = List<StagedCostAttachment>.unmodifiable(attachments);

  final Project project;
  final ContractorQuote? quote;
  final List<Contact> contacts;
  final List<ProjectStage> stages;
  final List<StagedCostAttachment> attachments;
}

final class QuoteEditorNotFoundException implements Exception {
  const QuoteEditorNotFoundException();
}

final class LocalQuoteEditorGateway implements QuoteEditorGateway {
  factory LocalQuoteEditorGateway({
    required ProjectRepository projectRepository,
    required ContactRepository contactRepository,
    required StageRepository stageRepository,
    required QuoteRepository quoteRepository,
    required CostAttachmentStager attachmentStager,
    required CostAttachmentPicker attachmentPicker,
  }) => LocalQuoteEditorGateway._(
    projectRepository,
    contactRepository,
    stageRepository,
    quoteRepository,
    attachmentStager,
    attachmentPicker,
  );

  const LocalQuoteEditorGateway._(
    this._projectRepository,
    this._contactRepository,
    this._stageRepository,
    this._quoteRepository,
    this._attachmentStager,
    this._attachmentPicker,
  );

  final ProjectRepository _projectRepository;
  final ContactRepository _contactRepository;
  final StageRepository _stageRepository;
  final QuoteRepository _quoteRepository;
  final CostAttachmentStager _attachmentStager;
  final CostAttachmentPicker _attachmentPicker;

  @override
  Future<QuoteEditorData> load({
    required String projectId,
    String? quoteId,
  }) async {
    final project = await _projectRepository.findById(projectId);
    if (project == null || project.isArchived) {
      throw const QuoteEditorNotFoundException();
    }
    ContractorQuote? quote;
    var attachments = const <StagedCostAttachment>[];
    if (quoteId != null) {
      quote = await _quoteRepository.findById(
        projectId: projectId,
        quoteId: quoteId,
      );
      if (quote == null) throw const QuoteEditorNotFoundException();
      attachments = await _attachmentStager.listForQuote(
        projectId: projectId,
        quoteId: quoteId,
      );
    }
    final contacts = <Contact>[];
    var request = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await _contactRepository.list(
        ContactQuery(projectId: projectId),
        request,
      );
      contacts.addAll(page.items);
      final next = page.nextRequest;
      if (next == null) break;
      request = next;
    }
    return QuoteEditorData(
      project: project,
      quote: quote,
      contacts: contacts,
      stages: await _stageRepository.listStages(
        projectId: projectId,
        template: project.template,
      ),
      attachments: attachments,
    );
  }

  @override
  Future<ContractorQuote> save({
    required String projectId,
    String? quoteId,
    required ContractorQuoteDraft draft,
  }) {
    if (quoteId == null) {
      return _quoteRepository.create(projectId: projectId, draft: draft);
    }
    return _quoteRepository.update(
      projectId: projectId,
      quoteId: quoteId,
      draft: draft,
    );
  }

  @override
  Future<StagedCostAttachment?> pickAttachment(String projectId) async {
    final selected = await _attachmentPicker.pick();
    if (selected == null) return null;
    return _attachmentStager.stage(projectId: projectId, pickedFile: selected);
  }

  @override
  Future<bool> discardIfUnlinked({
    required String projectId,
    required String attachmentId,
  }) {
    return _attachmentStager.discardIfUnlinked(
      projectId: projectId,
      attachmentId: attachmentId,
    );
  }
}
