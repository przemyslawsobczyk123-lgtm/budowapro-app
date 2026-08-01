import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_editor_gateway.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_details_screen.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photo_form_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('new technical photo is described and saved at 320 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final gateway = _FakeTechnicalPhotoEditorGateway(_editorData());
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              onPressed: () => context.push('/photo'),
              child: const Text('open-photo'),
            ),
          ),
        ),
        GoRoute(
          path: '/photo',
          builder: (context, state) => const TechnicalPhotoFormScreen(
            projectId: 'project-1',
            attachmentId: 'photo-1',
            isNew: true,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          technicalPhotoEditorGatewayProvider.overrideWith(
            (ref) async => gateway,
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('open-photo'));
    await tester.pumpAndSettle();

    expect(find.text('Opisz zdjęcie techniczne'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const ValueKey('technicalPhotoTitleField')),
      'Bednarka przed betonowaniem',
    );
    for (var index = 0; index < 4; index++) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('technicalPhotoSaveButton')));
    await tester.pumpAndSettle();

    expect(gateway.saved?.title, 'Bednarka przed betonowaniem');
    expect(gateway.saved?.albumId, 'album-1');
    expect(gateway.saved?.stageId, 'stage-1');
    expect(find.text('open-photo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details keep metadata visible when the image file is missing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final gateway = _FakeTechnicalPhotoEditorGateway(
      _editorData(withPhoto: true),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          technicalPhotoEditorGatewayProvider.overrideWith(
            (ref) async => gateway,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TechnicalPhotoDetailsScreen(
            projectId: 'project-1',
            attachmentId: 'photo-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Uziom przed betonowaniem'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('technicalPhotoDetailsMissingFile')),
      findsOneWidget,
    );
    expect(find.text('Fundament'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing a technical photo preserves typed links', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final gateway = _FakeTechnicalPhotoEditorGateway(
      _editorData(withPhoto: true),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          technicalPhotoEditorGatewayProvider.overrideWith(
            (ref) async => gateway,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TechnicalPhotoFormScreen(
            projectId: 'project-1',
            attachmentId: 'photo-1',
            isNew: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var index = 0; index < 5; index++) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('technicalPhotoSaveButton')));
    await tester.pumpAndSettle();

    expect(gateway.saved?.links, hasLength(1));
    expect(gateway.saved?.links.single.type, TechnicalPhotoLinkType.defect);
    expect(gateway.saved?.links.single.targetId, 'defect-1');
    expect(tester.takeException(), isNull);
  });
}

TechnicalPhotoEditorData _editorData({bool withPhoto = false}) {
  final now = DateTime.utc(2026, 7, 30, 10);
  final project = Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    ),
    createdAt: now,
    updatedAt: now,
  );
  final stage = ProjectStage(
    id: 'stage-1',
    projectId: project.id,
    templateKey: ProjectStageKey.stateZero,
    status: StageStatus.inProgress,
    sortOrder: 0,
    progress: StageProgress.fromCounts(
      totalItems: 1,
      completedItems: 0,
      skippedItems: 0,
      blockedItems: 0,
    ),
    createdAt: now,
    updatedAt: now,
  );
  return TechnicalPhotoEditorData(
    project: project,
    attachment: StagedLocalAttachment(
      id: 'photo-1',
      projectId: project.id,
      displayName: 'uziom.jpg',
      byteSize: 2048,
      mediaType: 'image/jpeg',
      sha256: 'abc',
      hasPreview: false,
      importedAtUtc: now,
    ),
    photo: withPhoto
        ? TechnicalPhoto(
            attachmentId: 'photo-1',
            projectId: project.id,
            albumId: 'album-1',
            title: 'Uziom przed betonowaniem',
            capturedAt: now,
            installationType: TechnicalInstallationType.grounding,
            stageId: stage.id,
            zoneLabel: 'Fundament',
            contractorContactId: 'contact-1',
            checklistItemId: 'check-1',
            description: 'Bednarka połączona przed zalaniem betonu.',
            tags: const <String>['bednarka', 'uziom'],
            links: const <TechnicalPhotoLink>[
              TechnicalPhotoLink(
                type: TechnicalPhotoLinkType.defect,
                targetId: 'defect-1',
              ),
            ],
            displayName: 'uziom.jpg',
            mediaType: 'image/jpeg',
            hasPreview: false,
            importedAt: now,
          )
        : null,
    albums: <TechnicalAlbumOverview>[
      TechnicalAlbumOverview(
        album: TechnicalAlbum(
          id: 'album-1',
          projectId: project.id,
          title: 'Przed betonowaniem',
          kind: TechnicalAlbumKind.beforeConcrete,
          stageId: stage.id,
          createdAt: now,
          updatedAt: now,
        ),
        photoCount: 0,
      ),
    ],
    stages: <ProjectStage>[stage],
    contacts: <Contact>[
      Contact(
        id: 'contact-1',
        projectId: project.id,
        draft: ContactDraft(
          displayName: 'Elektryk',
          kind: ContactKind.person,
          roles: const <ContactRole>{ContactRole.electrician},
        ),
        createdAt: now,
        updatedAt: now,
      ),
    ],
    checklistItems: <ChecklistItem>[
      ChecklistItem(
        id: 'check-1',
        projectId: project.id,
        stageId: stage.id,
        customTitle: 'Uziom fundamentowy',
        status: ChecklistStatus.todo,
        importance: ChecklistImportance.critical,
        evidenceRequirement: EvidenceRequirement.photo,
        evidenceIds: const <String>[],
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    linkOptions: const <TechnicalPhotoLinkOption>[
      TechnicalPhotoLinkOption(
        type: TechnicalPhotoLinkType.defect,
        targetId: 'defect-1',
        label: 'Nieszczelne przejście instalacyjne',
      ),
    ],
  );
}

final class _FakeTechnicalPhotoEditorGateway
    implements TechnicalPhotoEditorGateway {
  _FakeTechnicalPhotoEditorGateway(this.data);

  final TechnicalPhotoEditorData data;
  TechnicalPhotoInput? saved;

  @override
  Future<TechnicalPhotoEditorData> load({
    required String projectId,
    required String attachmentId,
  }) async => data;

  @override
  Future<TechnicalPhoto> save(
    TechnicalPhotoInput input, {
    required bool isNew,
  }) async {
    saved = input;
    return TechnicalPhoto(
      attachmentId: data.attachment.id,
      projectId: data.project.id,
      albumId: input.albumId,
      title: input.title,
      capturedAt: input.capturedAtUtc,
      installationType: input.installationType,
      stageId: input.stageId,
      zoneLabel: input.zoneLabel,
      contractorContactId: input.contractorContactId,
      checklistItemId: input.checklistItemId,
      description: input.description,
      tags: input.tags,
      links: input.links,
      displayName: data.attachment.displayName,
      mediaType: data.attachment.mediaType!,
      hasPreview: data.attachment.hasPreview,
      importedAt: data.attachment.importedAtUtc,
    );
  }
}
