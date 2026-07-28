import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/captures/presentation/captures_controller.dart';
import 'package:budowapro/features/captures/presentation/captures_screen.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows open and classified captures at 320 px', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final project = _project();
    final input = CaptureDraftInput(
      projectId: project.id,
      type: CaptureDraftType.cost,
      title: 'Beton na fundament',
      grossAmountMinorUnits: 245000,
      vatRateBasisPoints: 2300,
    );
    final state = CapturesState(
      project: project,
      open: <CaptureDraft>[
        CaptureDraft(
          id: 'capture-open',
          input: input,
          status: CaptureDraftStatus.ready,
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
        CaptureDraft(
          id: 'capture-review',
          input: CaptureDraftInput(
            projectId: project.id,
            type: CaptureDraftType.note,
            title: 'Ustalenia',
          ),
          status: CaptureDraftStatus.needsReview,
          createdAt: DateTime.utc(2026, 7, 27),
          updatedAt: DateTime.utc(2026, 7, 27),
        ),
      ],
      history: <CaptureDraft>[
        CaptureDraft(
          id: 'capture-history',
          input: input,
          status: CaptureDraftStatus.classified,
          targetType: CaptureTargetType.costDraft,
          targetId: 'cost-1',
          createdAt: DateTime.utc(2026, 7, 26),
          updatedAt: DateTime.utc(2026, 7, 26),
        ),
      ],
      openTotal: 2,
      historyTotal: 1,
      openNextPage: PageRequest(offset: 2, limit: 100),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          capturesControllerProvider.overrideWithBuild(
            (ref, notifier) async => state,
          ),
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beton na fundament'), findsOneWidget);
    expect(find.textContaining('Uzupełnij: opis'), findsOneWidget);
    expect(find.byKey(const ValueKey('captureAddButton')), findsOneWidget);
    expect(find.text('Wczytaj kolejne'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Historia (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Szkic kosztu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps inbox usable with 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final project = _project();
    final state = CapturesState(
      project: project,
      open: <CaptureDraft>[
        CaptureDraft(
          id: 'capture-review',
          input: CaptureDraftInput(
            projectId: project.id,
            type: CaptureDraftType.defect,
            title: 'Rysa przy nadprożu',
            content: 'Sprawdzić przed tynkowaniem.',
          ),
          status: CaptureDraftStatus.ready,
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
      ],
      history: const <CaptureDraft>[],
      openTotal: 1,
      historyTotal: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          capturesControllerProvider.overrideWithBuild(
            (ref, notifier) async => state,
          ),
        ],
        child: _app(textScaler: const TextScaler.linear(2)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rysa przy nadprożu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('captureAddButton')));
    await tester.pumpAndSettle();
    expect(find.text('Paragon lub faktura'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps task editor usable with 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: _editorApp(
          project: _project(),
          textScaler: const TextScaler.linear(2),
        ),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .widget<FilledButton>(find.byKey(const ValueKey('openTaskEditor')))
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('captureTitleField')), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('captureDateButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('captureTimeButton')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({TextScaler textScaler = TextScaler.noScaling}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('pl'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: const CapturesScreen(),
  );
}

Widget _editorApp({required Project project, required TextScaler textScaler}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('pl'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: Consumer(
      builder: (context, ref, child) => Scaffold(
        body: Center(
          child: FilledButton(
            key: const ValueKey('openTaskEditor'),
            onPressed: () => showCaptureEditor(
              context,
              ref,
              project: project,
              type: CaptureDraftType.task,
            ),
            child: const Text('Otwórz'),
          ),
        ),
      ),
    ),
  );
}

Project _project() {
  return Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    ),
    templateVersion: 1,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}
