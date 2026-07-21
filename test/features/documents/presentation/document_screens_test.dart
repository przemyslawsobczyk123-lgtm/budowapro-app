import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/documents/domain/document_repository.dart';
import 'package:budowapro/features/documents/domain/project_document.dart';
import 'package:budowapro/features/documents/presentation/document_editor_gateway.dart';
import 'package:budowapro/features/documents/presentation/document_form_screen.dart';
import 'package:budowapro/features/documents/presentation/documents_controller.dart';
import 'package:budowapro/features/documents/presentation/documents_screen.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('document library and filters fit a 320 px viewport', (
    tester,
  ) async {
    _compactView(tester);
    final project = _project();
    final state = DocumentsState(
      project: project,
      documents: <ProjectDocument>[
        _document(
          metadata: DocumentMetadata(
            title: 'Faktura za instalacje elektryczna',
            type: ProjectDocumentType.invoice,
            documentDate: DateTime.utc(2026, 7, 18),
            warrantyStartsAt: DateTime.utc(2026, 7, 18),
            warrantyEndsAt: DateTime.utc(2028, 7, 18),
          ),
          relations: <DocumentRelation>[
            DocumentRelation(
              type: DocumentRelationType.stage,
              targetId: 'installations',
              label: 'Instalacje',
            ),
          ],
        ),
      ],
      totalCount: 1,
      nextPage: null,
      filters: const DocumentLibraryFilters(),
      filterOptions: DocumentFilterOptions(
        stages: <DocumentFilterOption>[
          DocumentFilterOption(id: 'installations', label: 'Instalacje'),
        ],
        rooms: <DocumentFilterOption>[
          DocumentFilterOption(id: 'kuchnia', label: 'Kuchnia'),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsControllerProvider.overrideWithBuild(
            (ref, notifier) async => state,
          ),
        ],
        child: _localizedApp(home: const DocumentsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Faktura za instalacje elektryczna'), findsOneWidget);
    expect(find.byKey(const ValueKey('documentSearchField')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('documentFiltersButton')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('applyDocumentFiltersButton')),
      findsOneWidget,
    );
    expect(find.text('Wszystkie pomieszczenia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new warranty document is recognized and saved at 320 px', (
    tester,
  ) async {
    _compactView(tester);
    final gateway = _DocumentGateway(
      DocumentEditorData(
        project: _project(),
        document: _document(
          displayName: 'gwarancja-okna.pdf',
          metadata: DocumentMetadata(
            title: 'gwarancja-okna.pdf',
            type: ProjectDocumentType.other,
          ),
        ),
        stages: const [],
        contacts: const [],
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              onPressed: () => context.push('/form'),
              child: const Text('open-form'),
            ),
          ),
        ),
        GoRoute(
          path: '/form',
          builder: (context, state) => const DocumentFormScreen(
            projectId: 'project-1',
            documentId: 'document-1',
            isNew: true,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentEditorGatewayProvider.overrideWith((ref) async => gateway),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('open-form'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('documentType-warranty')), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('saveDocumentButton')),
    );
    await tester.tap(find.byKey(const ValueKey('saveDocumentButton')));
    await tester.pumpAndSettle();

    expect(gateway.savedMetadata?.type, ProjectDocumentType.warranty);
    expect(gateway.savedMetadata?.warrantyStartsAtUtc, isNotNull);
    expect(gateway.savedMetadata?.warrantyEndsAtUtc, isNotNull);
    expect(find.text('open-form'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

MaterialApp _localizedApp({required Widget home}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.light,
  home: home,
);

void _compactView(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Project _project() {
  final now = DateTime.utc(2026, 7, 20);
  return Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom pod lasem',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

ProjectDocument _document({
  String displayName = 'faktura-instalacje.pdf',
  DocumentMetadata? metadata,
  Iterable<DocumentRelation> relations = const <DocumentRelation>[],
}) => ProjectDocument(
  id: 'document-1',
  projectId: 'project-1',
  displayName: displayName,
  metadata:
      metadata ??
      DocumentMetadata(title: displayName, type: ProjectDocumentType.other),
  byteSize: 2048,
  mediaType: 'application/pdf',
  importedAt: DateTime.utc(2026, 7, 20),
  relations: relations,
);

final class _DocumentGateway implements DocumentEditorGateway {
  _DocumentGateway(this.data);

  final DocumentEditorData data;
  DocumentMetadata? savedMetadata;
  List<DocumentRelation>? savedLinks;

  @override
  Future<DocumentEditorData> load({
    required String projectId,
    required String documentId,
  }) async => data;

  @override
  Future<ProjectDocument> save({
    required String projectId,
    required String documentId,
    required DocumentMetadata metadata,
    required Iterable<DocumentRelation> contextLinks,
  }) async {
    savedMetadata = metadata;
    savedLinks = contextLinks.toList(growable: false);
    return _document(metadata: metadata, relations: savedLinks!);
  }
}
