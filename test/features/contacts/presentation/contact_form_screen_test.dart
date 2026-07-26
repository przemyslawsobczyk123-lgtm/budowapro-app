import 'dart:async';

import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/contacts/data/contact_providers.dart';
import 'package:budowapro/features/contacts/domain/device_contact.dart';
import 'package:budowapro/features/contacts/presentation/contact_form_screen.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  testWidgets('imports the selected contact name and phone into a new form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final picker = _DeviceContactPicker(
      selection: DeviceContactSelection(
        displayName: 'Jan Kowalski',
        phone: '+48 500 600 700',
      ),
    );

    await tester.pumpWidget(_testApp(picker));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('contactImportButton')));
    await tester.pumpAndSettle();

    expect(picker.pickCount, 1);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('contactNameField')))
          .controller
          ?.text,
      'Jan Kowalski',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('contactPhoneField')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('contactPhoneField')),
          )
          .controller
          ?.text,
      '+48 500 600 700',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps manual entry available after picker cancellation', (
    tester,
  ) async {
    final picker = _DeviceContactPicker();

    await tester.pumpWidget(_testApp(picker));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('contactNameField')),
      'Wpis ręczny',
    );
    await tester.tap(find.byKey(const ValueKey('contactImportButton')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('contactNameField')))
          .controller
          ?.text,
      'Wpis ręczny',
    );
  });

  testWidgets('reports picker failure without clearing the form', (
    tester,
  ) async {
    final picker = _DeviceContactPicker(
      error: const DeviceContactPickerException(
        DeviceContactPickerFailure.unavailable,
      ),
    );

    await tester.pumpWidget(_testApp(picker));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('contactNameField')),
      'Wpis ręczny',
    );
    await tester.tap(find.byKey(const ValueKey('contactImportButton')));
    await tester.pumpAndSettle();

    expect(find.text('Nie udało się otworzyć kontaktów telefonu.'), findsOne);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('contactNameField')))
          .controller
          ?.text,
      'Wpis ręczny',
    );
  });

  testWidgets('does not open a second picker while selection is active', (
    tester,
  ) async {
    final pendingSelection = Completer<DeviceContactSelection?>();
    final picker = _DeviceContactPicker(onPick: () => pendingSelection.future);

    await tester.pumpWidget(_testApp(picker));
    await tester.pumpAndSettle();
    final importButton = find.byKey(const ValueKey('contactImportButton'));
    await tester.tap(importButton);
    await tester.pump();
    await tester.tap(importButton);
    await tester.pump();

    expect(picker.pickCount, 1);
    pendingSelection.complete(null);
    await tester.pumpAndSettle();
  });
}

Widget _testApp(DeviceContactPicker picker) {
  final project = Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
    ),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  return ProviderScope(
    overrides: [
      projectRepositoryProvider.overrideWith(
        (ref) async => FakeProjectRepository(
          projects: <Project>[project],
          selectedProjectId: project.id,
        ),
      ),
      stageRepositoryProvider.overrideWith((ref) async => _StageRepository()),
      deviceContactPickerProvider.overrideWithValue(picker),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: const ContactFormScreen(projectId: 'project-1'),
    ),
  );
}

final class _DeviceContactPicker implements DeviceContactPicker {
  _DeviceContactPicker({this.selection, this.error, this.onPick});

  final DeviceContactSelection? selection;
  final Object? error;
  final Future<DeviceContactSelection?> Function()? onPick;
  int pickCount = 0;

  @override
  Future<DeviceContactSelection?> pick() async {
    pickCount++;
    final failure = error;
    if (failure != null) throw failure;
    final callback = onPick;
    if (callback != null) return callback();
    return selection;
  }
}

final class _StageRepository implements StageRepository {
  @override
  Future<List<ProjectStage>> listStages({
    required String projectId,
    required ProjectTemplate template,
  }) async => const <ProjectStage>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
