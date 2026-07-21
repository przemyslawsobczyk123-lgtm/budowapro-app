import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('metadata normalizes dates and validates warranty period', () {
    final metadata = DocumentMetadata(
      title: '  Gwarancja pompy ciepla  ',
      type: ProjectDocumentType.warranty,
      documentDate: DateTime(2026, 7, 10, 12),
      warrantyStartsAt: DateTime(2026, 7, 1),
      warrantyEndsAt: DateTime(2031, 7, 1),
      warrantyReminderAt: DateTime(2031, 6, 1),
    );

    expect(metadata.title, 'Gwarancja pompy ciepla');
    expect(metadata.documentDateUtc!.isUtc, isTrue);
    expect(
      () => DocumentMetadata(
        title: 'Gwarancja',
        type: ProjectDocumentType.warranty,
        warrantyStartsAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => DocumentMetadata(
        title: 'Gwarancja',
        type: ProjectDocumentType.warranty,
        warrantyStartsAt: DateTime.utc(2027),
        warrantyEndsAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
  });

  test('warranty state is deterministic at its boundaries', () {
    final metadata = DocumentMetadata(
      title: 'Karta gwarancyjna',
      type: ProjectDocumentType.warranty,
      warrantyStartsAt: DateTime.utc(2026, 1, 1),
      warrantyEndsAt: DateTime.utc(2026, 8, 20),
    );

    expect(
      metadata.warrantyStateAt(DateTime.utc(2026, 7, 20)),
      DocumentWarrantyState.active,
    );
    expect(
      metadata.warrantyStateAt(DateTime.utc(2026, 7, 21)),
      DocumentWarrantyState.expiringSoon,
    );
    expect(
      metadata.warrantyStateAt(DateTime.utc(2026, 8, 20)),
      DocumentWarrantyState.expiringSoon,
    );
    expect(
      metadata.warrantyStateAt(DateTime.utc(2026, 8, 21)),
      DocumentWarrantyState.expired,
    );
  });

  test('document rejects duplicate typed relations', () {
    expect(
      () => _document(
        relations: <DocumentRelation>[
          DocumentRelation(
            type: DocumentRelationType.cost,
            targetId: 'cost-1',
            label: 'Faktura za material',
          ),
          DocumentRelation(
            type: DocumentRelationType.cost,
            targetId: 'cost-1',
            label: 'Ten sam koszt',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('query normalizes search and counts grouped filters', () {
    final query = DocumentQuery(
      projectId: 'project-1',
      searchText: '  POMPA  ',
      types: const <ProjectDocumentType>{ProjectDocumentType.warranty},
      stageIds: const <String>{'stage-1'},
      fromInclusive: DateTime(2026, 1, 1),
      toExclusive: DateTime(2027, 1, 1),
    );

    expect(query.searchText, 'pompa');
    expect(query.activeFilterCount, 4);
    expect(query.fromInclusiveUtc!.isUtc, isTrue);
  });

  test('document recognizes supported in-app preview media', () {
    expect(_document(mediaType: 'application/pdf').isPdf, isTrue);
    expect(_document(mediaType: 'image/jpeg').isImage, isTrue);
    expect(_document(mediaType: 'application/vnd.ms-excel').isImage, isFalse);
  });
}

ProjectDocument _document({
  String? mediaType,
  Iterable<DocumentRelation> relations = const <DocumentRelation>[],
}) {
  return ProjectDocument(
    id: 'document-1',
    projectId: 'project-1',
    displayName: 'dokument.pdf',
    metadata: DocumentMetadata(
      title: 'Dokument',
      type: ProjectDocumentType.other,
    ),
    byteSize: 120,
    mediaType: mediaType,
    importedAt: DateTime.utc(2026, 7, 1),
    relations: relations,
  );
}
