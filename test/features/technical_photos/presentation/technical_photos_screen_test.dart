import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photos_controller.dart';
import 'package:budowapro/features/technical_photos/presentation/technical_photos_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('technical library fits 320 px and handles a missing preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(_state()));
    await tester.pumpAndSettle();

    expect(find.text('Dokumentacja techniczna'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('technicalPhotoSearchField')),
      findsOneWidget,
    );
    expect(find.textContaining('Przed zalaniem betonem'), findsWidgets);
    expect(find.text('Uziom przed betonowaniem'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('technicalPhotoMissingPreview')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('technical library remains usable at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(_state(), textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Uziom przed betonowaniem'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('technicalPhotoAddButton')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _app(
  TechnicalPhotosState state, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [
      technicalPhotosControllerProvider.overrideWithBuild(
        (ref, notifier) async => state,
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const TechnicalPhotosScreen(),
    ),
  );
}

TechnicalPhotosState _state() {
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
    id: 'state-zero',
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
  final album = TechnicalAlbum(
    id: 'album-1',
    projectId: project.id,
    title: 'Przed zalaniem betonem',
    kind: TechnicalAlbumKind.beforeConcrete,
    stageId: stage.id,
    createdAt: now,
    updatedAt: now,
  );
  return TechnicalPhotosState(
    project: project,
    albums: <TechnicalAlbumOverview>[
      TechnicalAlbumOverview(album: album, photoCount: 1),
    ],
    photos: <TechnicalPhoto>[
      TechnicalPhoto(
        attachmentId: 'photo-1',
        projectId: project.id,
        albumId: album.id,
        title: 'Uziom przed betonowaniem',
        capturedAt: now,
        installationType: TechnicalInstallationType.grounding,
        stageId: stage.id,
        zoneLabel: 'Fundament',
        tags: const <String>['bednarka'],
        displayName: 'uziom.jpg',
        mediaType: 'image/jpeg',
        hasPreview: true,
        importedAt: now,
      ),
    ],
    stages: <ProjectStage>[stage],
    totalCount: 1,
    nextPage: null,
    filters: const TechnicalPhotoFilters(),
  );
}
