import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentEditorGatewayProvider = FutureProvider<DocumentEditorGateway>((
  ref,
) async {
  return LocalDocumentEditorGateway(
    projectRepository: await ref.watch(projectRepositoryProvider.future),
    contactRepository: await ref.watch(contactRepositoryProvider.future),
    stageRepository: await ref.watch(stageRepositoryProvider.future),
    documentRepository: await ref.watch(documentRepositoryProvider.future),
  );
});

abstract interface class DocumentEditorGateway {
  Future<DocumentEditorData> load({
    required String projectId,
    required String documentId,
  });

  Future<ProjectDocument> save({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
    required Iterable<DocumentRelation> contextLinks,
  });
}

final class DocumentEditorData {
  DocumentEditorData({
    required this.project,
    required this.document,
    required Iterable<ProjectStage> stages,
    required Iterable<Contact> contacts,
  }) : stages = List<ProjectStage>.unmodifiable(stages),
       contacts = List<Contact>.unmodifiable(contacts);

  final Project project;
  final ProjectDocument document;
  final List<ProjectStage> stages;
  final List<Contact> contacts;
}

final class DocumentEditorNotFoundException implements Exception {
  const DocumentEditorNotFoundException();
}

final class LocalDocumentEditorGateway implements DocumentEditorGateway {
  factory LocalDocumentEditorGateway({
    required ProjectRepository projectRepository,
    required ContactRepository contactRepository,
    required StageRepository stageRepository,
    required DocumentRepository documentRepository,
  }) => LocalDocumentEditorGateway._(
    projectRepository,
    contactRepository,
    stageRepository,
    documentRepository,
  );

  const LocalDocumentEditorGateway._(
    this._projectRepository,
    this._contactRepository,
    this._stageRepository,
    this._documentRepository,
  );

  final ProjectRepository _projectRepository;
  final ContactRepository _contactRepository;
  final StageRepository _stageRepository;
  final DocumentRepository _documentRepository;

  @override
  Future<DocumentEditorData> load({
    required String projectId,
    required String documentId,
  }) async {
    final project = await _projectRepository.findById(projectId);
    final document = await _documentRepository.findById(
      projectId: projectId,
      documentId: documentId,
    );
    if (project == null || project.isArchived || document == null) {
      throw const DocumentEditorNotFoundException();
    }
    final contacts = <Contact>[];
    var request = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await _contactRepository.list(
        ContactQuery(projectId: projectId, includeArchived: true),
        request,
      );
      contacts.addAll(page.items);
      final next = page.nextRequest;
      if (next == null) break;
      request = next;
    }
    return DocumentEditorData(
      project: project,
      document: document,
      stages: await _stageRepository.listStages(
        projectId: projectId,
        template: project.template,
      ),
      contacts: contacts,
    );
  }

  @override
  Future<ProjectDocument> save({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
    required Iterable<DocumentRelation> contextLinks,
  }) async {
    return _documentRepository.saveDetails(
      projectId: projectId,
      documentId: documentId,
      metadata: metadata,
      contextLinks: contextLinks,
    );
  }
}
