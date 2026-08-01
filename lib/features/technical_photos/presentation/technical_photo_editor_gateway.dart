import 'dart:io';

import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:budowapro/features/diary/data/journal_providers.dart';
import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/diary/domain/journal_repository.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/punch_list/data/punch_providers.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/domain/punch_repository.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/features/technical_photos/data/technical_photo_providers.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef TechnicalPhotoEditorTarget = ({String projectId, String attachmentId});

final technicalPhotoEditorGatewayProvider =
    FutureProvider<TechnicalPhotoEditorGateway>((ref) async {
      return LocalTechnicalPhotoEditorGateway(
        projectRepository: await ref.watch(projectRepositoryProvider.future),
        contactRepository: await ref.watch(contactRepositoryProvider.future),
        costRepository: await ref.watch(costRepositoryProvider.future),
        journalRepository: await ref.watch(journalRepositoryProvider.future),
        punchRepository: await ref.watch(punchRepositoryProvider.future),
        stageRepository: await ref.watch(stageRepositoryProvider.future),
        technicalPhotoRepository: await ref.watch(
          technicalPhotoRepositoryProvider.future,
        ),
        attachmentStager: await ref.watch(localAttachmentStagerProvider.future),
      );
    });

final technicalPhotoEditorDataProvider = FutureProvider.autoDispose
    .family<TechnicalPhotoEditorData, TechnicalPhotoEditorTarget>((
      ref,
      target,
    ) async {
      return (await ref.watch(
        technicalPhotoEditorGatewayProvider.future,
      )).load(projectId: target.projectId, attachmentId: target.attachmentId);
    });

abstract interface class TechnicalPhotoEditorGateway {
  Future<TechnicalPhotoEditorData> load({
    required String projectId,
    required String attachmentId,
  });

  Future<TechnicalPhoto> save(TechnicalPhotoInput input, {required bool isNew});
}

final class TechnicalPhotoEditorData {
  TechnicalPhotoEditorData({
    required this.project,
    required this.attachment,
    required this.photo,
    required Iterable<TechnicalAlbumOverview> albums,
    required Iterable<ProjectStage> stages,
    required Iterable<Contact> contacts,
    required Iterable<ChecklistItem> checklistItems,
    Iterable<TechnicalPhotoLinkOption> linkOptions =
        const <TechnicalPhotoLinkOption>[],
    this.originalFile,
    this.previewFile,
  }) : albums = List<TechnicalAlbumOverview>.unmodifiable(albums),
       stages = List<ProjectStage>.unmodifiable(stages),
       contacts = List<Contact>.unmodifiable(contacts),
       checklistItems = List<ChecklistItem>.unmodifiable(checklistItems),
       linkOptions = List<TechnicalPhotoLinkOption>.unmodifiable(linkOptions);

  final Project project;
  final StagedLocalAttachment attachment;
  final TechnicalPhoto? photo;
  final List<TechnicalAlbumOverview> albums;
  final List<ProjectStage> stages;
  final List<Contact> contacts;
  final List<ChecklistItem> checklistItems;
  final List<TechnicalPhotoLinkOption> linkOptions;
  final File? originalFile;
  final File? previewFile;
}

final class TechnicalPhotoLinkOption {
  const TechnicalPhotoLinkOption({
    required this.type,
    required this.targetId,
    required this.label,
  });

  final TechnicalPhotoLinkType type;
  final String targetId;
  final String label;
}

final class TechnicalPhotoEditorNotFoundException implements Exception {
  const TechnicalPhotoEditorNotFoundException();
}

final class LocalTechnicalPhotoEditorGateway
    implements TechnicalPhotoEditorGateway {
  factory LocalTechnicalPhotoEditorGateway({
    required ProjectRepository projectRepository,
    required ContactRepository contactRepository,
    required CostRepository costRepository,
    required JournalRepository journalRepository,
    required PunchRepository punchRepository,
    required StageRepository stageRepository,
    required TechnicalPhotoRepository technicalPhotoRepository,
    required LocalAttachmentStager attachmentStager,
  }) => LocalTechnicalPhotoEditorGateway._(
    projectRepository,
    contactRepository,
    costRepository,
    journalRepository,
    punchRepository,
    stageRepository,
    technicalPhotoRepository,
    attachmentStager,
  );

  const LocalTechnicalPhotoEditorGateway._(
    this._projectRepository,
    this._contactRepository,
    this._costRepository,
    this._journalRepository,
    this._punchRepository,
    this._stageRepository,
    this._technicalPhotoRepository,
    this._attachmentStager,
  );

  final ProjectRepository _projectRepository;
  final ContactRepository _contactRepository;
  final CostRepository _costRepository;
  final JournalRepository _journalRepository;
  final PunchRepository _punchRepository;
  final StageRepository _stageRepository;
  final TechnicalPhotoRepository _technicalPhotoRepository;
  final LocalAttachmentStager _attachmentStager;

  @override
  Future<TechnicalPhotoEditorData> load({
    required String projectId,
    required String attachmentId,
  }) async {
    final project = await _projectRepository.findById(projectId);
    final attachment = await _attachmentStager.findById(
      projectId: projectId,
      attachmentId: attachmentId,
    );
    if (project == null || project.isArchived || attachment == null) {
      throw const TechnicalPhotoEditorNotFoundException();
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
    return TechnicalPhotoEditorData(
      project: project,
      attachment: attachment,
      photo: await _technicalPhotoRepository.findPhotoById(
        projectId: projectId,
        attachmentId: attachmentId,
      ),
      albums: await _technicalPhotoRepository.listAlbums(projectId: projectId),
      stages: await _stageRepository.listStages(
        projectId: projectId,
        template: project.template,
      ),
      contacts: contacts,
      checklistItems: await _stageRepository.listProjectChecklistItems(
        projectId: projectId,
      ),
      linkOptions: await _linkOptions(projectId),
      originalFile: await _attachmentStager.originalFile(
        projectId: projectId,
        attachmentId: attachmentId,
      ),
      previewFile: await _attachmentStager.previewFile(
        projectId: projectId,
        attachmentId: attachmentId,
      ),
    );
  }

  Future<List<TechnicalPhotoLinkOption>> _linkOptions(String projectId) async {
    final options = <TechnicalPhotoLinkOption>[];
    var costRequest = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await _costRepository.list(
        CostQuery(projectId: projectId),
        costRequest,
      );
      options.addAll(
        page.items.map(
          (entry) => TechnicalPhotoLinkOption(
            type: TechnicalPhotoLinkType.cost,
            targetId: entry.id,
            label: entry.name,
          ),
        ),
      );
      final next = page.nextRequest;
      if (next == null) break;
      costRequest = next;
    }

    var journalRequest = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await _journalRepository.list(
        JournalEntryQuery(
          projectId: projectId,
          types: const <JournalEntryType>{
            JournalEntryType.decision,
            JournalEntryType.scopeChange,
          },
        ),
        journalRequest,
      );
      options.addAll(
        page.items.map(
          (entry) => TechnicalPhotoLinkOption(
            type: TechnicalPhotoLinkType.decision,
            targetId: entry.id,
            label: entry.title,
          ),
        ),
      );
      final next = page.nextRequest;
      if (next == null) break;
      journalRequest = next;
    }

    var defectRequest = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await _punchRepository.listDefects(
        DefectQuery(projectId: projectId),
        defectRequest,
      );
      options.addAll(
        page.items.map(
          (defect) => TechnicalPhotoLinkOption(
            type: TechnicalPhotoLinkType.defect,
            targetId: defect.id,
            label: defect.title,
          ),
        ),
      );
      final next = page.nextRequest;
      if (next == null) break;
      defectRequest = next;
    }

    var protocolRequest = PageRequest(limit: PageRequest.maximumLimit);
    while (true) {
      final page = await _punchRepository.listProtocols(
        AcceptanceProtocolQuery(projectId: projectId),
        protocolRequest,
      );
      options.addAll(
        page.items.map(
          (protocol) => TechnicalPhotoLinkOption(
            type: TechnicalPhotoLinkType.acceptanceProtocol,
            targetId: protocol.id,
            label: protocol.title,
          ),
        ),
      );
      final next = page.nextRequest;
      if (next == null) break;
      protocolRequest = next;
    }
    return options;
  }

  @override
  Future<TechnicalPhoto> save(
    TechnicalPhotoInput input, {
    required bool isNew,
  }) {
    return isNew
        ? _technicalPhotoRepository.createPhoto(input)
        : _technicalPhotoRepository.updatePhoto(input);
  }
}
