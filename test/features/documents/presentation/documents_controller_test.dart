import 'dart:async';
import 'dart:io';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/documents/presentation/documents_controller.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/presentation/projects_controller.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'starts filters and stager with the first page and previews before filters finish',
    () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'budowapro-documents-controller-',
      );
      final database = AppDatabase(
        factory: databaseFactoryFfi,
        path: '${temporaryDirectory.path}/documents.db',
      );
      final stager = LocalAttachmentStager(
        database: database,
        fileStore: ProjectFileStore(rootDirectory: temporaryDirectory),
        idGenerator: () => 'attachment-id',
        utcNow: () => DateTime.utc(2026, 8, 12),
      );
      addTearDown(() async {
        await database.close();
        await temporaryDirectory.delete(recursive: true);
      });

      final repository = _ControlledDocumentRepository();
      final stagerResult = Completer<LocalAttachmentStager>();
      final previewResult = Completer<Map<String, File>>();
      var stagerProviderStarted = false;
      var previewStarted = false;
      final project = _project();
      final document = _document(project.id);
      final container = ProviderContainer(
        overrides: [
          projectsControllerProvider.overrideWithBuild(
            (ref, notifier) async => ProjectsState(
              projects: <Project>[project],
              selectedProject: project,
            ),
          ),
          documentRepositoryProvider.overrideWith((ref) async => repository),
          localAttachmentStagerProvider.overrideWith((ref) {
            stagerProviderStarted = true;
            return stagerResult.future;
          }),
          documentPreviewFilesProvider.overrideWithValue(({
            required projectId,
            required attachmentIds,
            required stager,
          }) {
            previewStarted = true;
            expect(projectId, project.id);
            expect(attachmentIds, <String>[document.id]);
            return previewResult.future;
          }),
        ],
      );
      addTearDown(container.dispose);

      final stateFuture = container.read(documentsControllerProvider.future);
      await _flushEvents();

      expect(repository.listStarted, isTrue);
      expect(repository.filterOptionsStarted, isTrue);
      expect(stagerProviderStarted, isTrue);
      expect(repository.listResult.isCompleted, isFalse);

      stagerResult.complete(stager);
      repository.listResult.complete(
        Page<ProjectDocument>(
          items: <ProjectDocument>[document],
          totalCount: 1,
          request: PageRequest(limit: DocumentsController.pageSize),
        ),
      );
      await _flushEvents();

      expect(previewStarted, isTrue);
      expect(repository.filterOptionsResult.isCompleted, isFalse);

      previewResult.complete(const <String, File>{});
      repository.filterOptionsResult.complete(DocumentFilterOptions());
      final state = await stateFuture;

      expect(state.documents, <ProjectDocument>[document]);
      expect(state.filterOptions.stages, isEmpty);
      expect(state.previewFiles, isEmpty);
    },
  );

  test(
    'holds an early stager error until repository loading settles',
    () async {
      final repository = _ControlledDocumentRepository();
      final repositoryResult = Completer<DocumentRepository>();
      final stagerResult = Completer<LocalAttachmentStager>();
      final project = _project();
      final container = ProviderContainer(
        overrides: [
          projectsControllerProvider.overrideWithBuild(
            (ref, notifier) async => ProjectsState(
              projects: <Project>[project],
              selectedProject: project,
            ),
          ),
          documentRepositoryProvider.overrideWith(
            (ref) => repositoryResult.future,
          ),
          localAttachmentStagerProvider.overrideWith(
            (ref) => stagerResult.future,
          ),
          documentPreviewFilesProvider.overrideWithValue(
            ({required projectId, required attachmentIds, required stager}) =>
                throw StateError('preview must not start'),
          ),
        ],
      );
      addTearDown(() {
        if (!repositoryResult.isCompleted) {
          repositoryResult.complete(repository);
        }
        if (!stagerResult.isCompleted) {
          stagerResult.completeError(StateError('stager cleanup'));
        }
        if (!repository.listResult.isCompleted) {
          repository.listResult.complete(
            Page<ProjectDocument>(
              items: const <ProjectDocument>[],
              totalCount: 0,
              request: PageRequest(limit: DocumentsController.pageSize),
            ),
          );
        }
        if (!repository.filterOptionsResult.isCompleted) {
          repository.filterOptionsResult.complete(DocumentFilterOptions());
        }
        container.dispose();
      });

      final loading = container.read(documentsControllerProvider.future);
      final errorExpectation = expectLater(loading, throwsA(isA<StateError>()));
      await _flushEvents();

      stagerResult.completeError(StateError('stager failed'));
      await _flushEvents();
      repositoryResult.complete(repository);
      await _flushEvents();

      repository.listResult.complete(
        Page<ProjectDocument>(
          items: const <ProjectDocument>[],
          totalCount: 0,
          request: PageRequest(limit: DocumentsController.pageSize),
        ),
      );
      repository.filterOptionsResult.complete(DocumentFilterOptions());
      await errorExpectation;
    },
  );
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

Project _project() {
  final now = DateTime.utc(2026, 8, 12);
  return Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

ProjectDocument _document(String projectId) => ProjectDocument(
  id: 'document-1',
  projectId: projectId,
  displayName: 'faktura.pdf',
  metadata: DocumentMetadata(
    title: 'Faktura',
    type: ProjectDocumentType.invoice,
  ),
  byteSize: 1024,
  mediaType: 'application/pdf',
  importedAt: DateTime.utc(2026, 8, 12),
  relations: const <DocumentRelation>[],
);

final class _ControlledDocumentRepository implements DocumentRepository {
  final Completer<Page<ProjectDocument>> listResult =
      Completer<Page<ProjectDocument>>();
  final Completer<DocumentFilterOptions> filterOptionsResult =
      Completer<DocumentFilterOptions>();

  bool listStarted = false;
  bool filterOptionsStarted = false;

  @override
  Future<Page<ProjectDocument>> list(DocumentQuery query, PageRequest page) {
    listStarted = true;
    return listResult.future;
  }

  @override
  Future<DocumentFilterOptions> filterOptions({required String projectId}) {
    filterOptionsStarted = true;
    return filterOptionsResult.future;
  }

  @override
  Future<ProjectDocument?> findById({
    required String projectId,
    required String documentId,
  }) => throw UnimplementedError();

  @override
  Future<List<ProjectDocument>> findPotentialDuplicates({
    required String projectId,
    required String sha256,
    String? excludingDocumentId,
  }) => throw UnimplementedError();

  @override
  Future<ProjectDocument> replaceContextLinks({
    required String projectId,
    required String documentId,
    required Iterable<DocumentRelation> links,
  }) => throw UnimplementedError();

  @override
  Future<ProjectDocument> saveDetails({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
    required Iterable<DocumentRelation> contextLinks,
  }) => throw UnimplementedError();

  @override
  Future<ProjectDocument> updateMetadata({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
  }) => throw UnimplementedError();
}
