import 'dart:async';

import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/materials/data/material_providers.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/features/materials/presentation/materials_controller.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_project_repository.dart';

void main() {
  test('starts material list and summary reads concurrently', () async {
    final project = _project();
    final materials = _ConcurrentMaterialRepository();
    final projects = FakeProjectRepository(
      projects: <Project>[project],
      selectedProjectId: project.id,
    );
    final container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWith((ref) async => projects),
        materialRepositoryProvider.overrideWith((ref) async => materials),
        materialNowProvider.overrideWith(
          (ref) =>
              () => DateTime.utc(2026, 8, 11, 12),
        ),
      ],
    );
    addTearDown(() {
      if (!materials.listCompleter.isCompleted) {
        materials.listCompleter.complete(_emptyPage());
      }
      if (!materials.summaryCompleter.isCompleted) {
        materials.summaryCompleter.complete(materials.summary);
      }
      container.dispose();
    });

    final loading = container.read(materialsControllerProvider.future);
    await _waitUntil(() => materials.listCalled);

    expect(materials.summaryCalled, isTrue);

    materials.summaryCompleter.complete(materials.summary);
    materials.listCompleter.complete(_emptyPage());
    final state = await loading;
    expect(state.materials, isEmpty);
    expect(state.summary, same(materials.summary));
  });

  test(
    'reports an early summary error after the pending page settles',
    () async {
      final project = _project();
      final materials = _ConcurrentMaterialRepository();
      final projects = FakeProjectRepository(
        projects: <Project>[project],
        selectedProjectId: project.id,
      );
      final container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWith((ref) async => projects),
          materialRepositoryProvider.overrideWith((ref) async => materials),
          materialNowProvider.overrideWith(
            (ref) =>
                () => DateTime.utc(2026, 8, 11, 12),
          ),
        ],
      );
      addTearDown(() {
        if (!materials.listCompleter.isCompleted) {
          materials.listCompleter.complete(_emptyPage());
        }
        if (!materials.summaryCompleter.isCompleted) {
          materials.summaryCompleter.complete(materials.summary);
        }
        container.dispose();
      });

      final loading = container.read(materialsControllerProvider.future);
      final errorExpectation = expectLater(loading, throwsA(isA<StateError>()));
      await _waitUntil(() => materials.listCalled && materials.summaryCalled);

      materials.summaryCompleter.completeError(StateError('summary failed'));
      await Future<void>.delayed(Duration.zero);
      expect(materials.listCompleter.isCompleted, isFalse);

      materials.listCompleter.complete(_emptyPage());
      await errorExpectation;
    },
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 20 && !condition(); attempt++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(condition(), isTrue, reason: 'Asynchronous operation did not start');
}

Project _project() {
  final now = DateTime.utc(2026, 8, 11, 12);
  return Project(
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
}

Page<MaterialItem> _emptyPage() {
  return Page<MaterialItem>(
    items: const <MaterialItem>[],
    totalCount: 0,
    request: PageRequest(limit: 30),
  );
}

final class _ConcurrentMaterialRepository implements MaterialRepository {
  final listCompleter = Completer<Page<MaterialItem>>();
  final summaryCompleter = Completer<MaterialDashboardSummary>();
  final summary = MaterialDashboardSummary(
    projectId: 'project-1',
    orderedValue: Money.zero('PLN'),
    expectedReturnValue: Money.zero('PLN'),
    delayedCount: 0,
    overdueReturnCount: 0,
    openDeliveryCount: 0,
  );
  bool listCalled = false;
  bool summaryCalled = false;

  @override
  Future<Page<MaterialItem>> list(
    MaterialQuery query,
    PageRequest request, {
    required DateTime now,
  }) {
    listCalled = true;
    return listCompleter.future;
  }

  @override
  Future<MaterialDashboardSummary> summarize({
    required String projectId,
    required String currencyCode,
    required DateTime now,
  }) {
    summaryCalled = true;
    return summaryCompleter.future;
  }

  @override
  Future<MaterialItem> create(MaterialInput input) =>
      throw UnimplementedError();

  @override
  Future<void> delete({
    required String projectId,
    required String materialId,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteDelivery({
    required String projectId,
    required String materialId,
    required String deliveryId,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteReturn({
    required String projectId,
    required String materialId,
    required String returnId,
  }) => throw UnimplementedError();

  @override
  Future<MaterialItem?> findById({
    required String projectId,
    required String materialId,
  }) => throw UnimplementedError();

  @override
  Future<MaterialDelivery> saveDelivery({
    String? deliveryId,
    required MaterialDeliveryInput input,
    bool confirmOrderedQuantityCorrection = false,
  }) => throw UnimplementedError();

  @override
  Future<MaterialReturn> saveReturn({
    String? returnId,
    required MaterialReturnInput input,
  }) => throw UnimplementedError();

  @override
  Future<MaterialItem> update({
    required String projectId,
    required String materialId,
    required MaterialInput input,
  }) => throw UnimplementedError();
}
