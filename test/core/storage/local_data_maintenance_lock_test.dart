import 'dart:async';

import 'package:budowapro/core/storage/local_data_maintenance_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maintenance waits for active work and blocks new operations', () async {
    final lock = LocalDataMaintenanceLock();
    final firstRelease = Completer<void>();
    final firstStarted = Completer<void>();
    final maintenanceStarted = Completer<void>();
    final maintenanceRelease = Completer<void>();
    var secondStarted = false;

    final first = lock.runOperation(() async {
      firstStarted.complete();
      await firstRelease.future;
    });
    await firstStarted.future;
    final maintenance = lock.runMaintenance(() async {
      maintenanceStarted.complete();
      await maintenanceRelease.future;
    });
    final second = lock.runOperation(() async {
      secondStarted = true;
    });

    await Future<void>.delayed(Duration.zero);
    expect(maintenanceStarted.isCompleted, isFalse);
    expect(secondStarted, isFalse);

    firstRelease.complete();
    await maintenanceStarted.future;
    expect(secondStarted, isFalse);

    maintenanceRelease.complete();
    await Future.wait<void>(<Future<void>>[first, maintenance, second]);
    expect(secondStarted, isTrue);
  });
}
