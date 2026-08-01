import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/presentation/materials_controller.dart';
import 'package:budowapro/features/materials/presentation/materials_screen.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('material list fits 320 px with 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(_state(), const TextScaler.linear(2)));
    await tester.pumpAndSettle();

    expect(find.text('Materiały i dostawy'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('materialSearchField')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('materialTile-material-1')),
      180,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Bloczek silikatowy'), findsOneWidget);
    expect(find.text('Opóźniony'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('material list exposes a useful empty state', (tester) async {
    final state = _state(materials: const <MaterialItem>[]);

    await tester.pumpWidget(_app(state, TextScaler.noScaling));
    await tester.pumpAndSettle();

    expect(find.text('Brak materiałów'), findsOneWidget);
    expect(find.byKey(const ValueKey('materialAddButton')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(MaterialsState state, TextScaler textScaler) {
  return ProviderScope(
    overrides: [
      materialsControllerProvider.overrideWithBuild(
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
      home: const MaterialsScreen(),
    ),
  );
}

MaterialsState _state({List<MaterialItem>? materials}) {
  final now = DateTime.utc(2026, 8, 1, 12);
  final project = Project(
    id: 'project-1',
    draft: ProjectDraft(
      name: 'Dom',
      type: ProjectType.houseBuild,
      template: ProjectTemplate.houseConstruction,
      currencyCode: 'PLN',
    ),
    createdAt: now,
    updatedAt: now,
  );
  final values = materials ?? <MaterialItem>[_material(now)];
  return MaterialsState(
    project: project,
    materials: values,
    summary: MaterialDashboardSummary(
      projectId: project.id,
      orderedValue: Money(minorUnits: 125000, currencyCode: 'PLN'),
      expectedReturnValue: Money(minorUnits: 25000, currencyCode: 'PLN'),
      delayedCount: values.isEmpty ? 0 : 1,
      overdueReturnCount: 0,
      openDeliveryCount: values.isEmpty ? 0 : 1,
    ),
    searchText: '',
    statuses: const <MaterialStatus>{},
    totalCount: values.length,
  );
}

MaterialItem _material(DateTime now) {
  return MaterialItem(
    id: 'material-1',
    input: MaterialInput(
      projectId: 'project-1',
      name: 'Bloczek silikatowy',
      orderedQuantity: MaterialQuantity(unscaledValue: 10, scale: 0),
      unit: 'pal.',
      stageId: 'shell_open',
      orderedAt: DateTime.utc(2026, 7, 20),
      orderedGross: Money(minorUnits: 125000, currencyCode: 'PLN'),
      storageLocation: 'Plac przy bramie',
    ),
    deliveries: <MaterialDelivery>[
      MaterialDelivery(
        id: 'delivery-1',
        input: MaterialDeliveryInput(
          projectId: 'project-1',
          materialId: 'material-1',
          expectedQuantity: MaterialQuantity(unscaledValue: 10, scale: 0),
          dueAt: DateTime.utc(2026, 7, 30),
        ),
        createdAt: DateTime.utc(2026, 7, 20),
        updatedAt: DateTime.utc(2026, 7, 20),
      ),
    ],
    returns: const <MaterialReturn>[],
    createdAt: DateTime.utc(2026, 7, 20),
    updatedAt: now,
  );
}
