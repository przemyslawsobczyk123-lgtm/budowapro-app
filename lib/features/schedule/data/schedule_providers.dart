import 'dart:math';

import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:budowapro/features/schedule/domain/schedule_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_schedule_notification_gateway.dart';
import 'sqlite_schedule_repository.dart';

final scheduleRepositoryProvider = FutureProvider<ScheduleRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqliteScheduleRepository(
    database: database,
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final scheduleNotificationGatewayProvider =
    Provider<ScheduleNotificationGateway>((ref) {
      return LocalScheduleNotificationGateway();
    });

final scheduleUtcNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final scheduleNotificationTargetProvider =
    NotifierProvider<
      ScheduleNotificationTargetController,
      ScheduleNotificationTarget?
    >(ScheduleNotificationTargetController.new);

final scheduleNotificationBootstrapProvider = FutureProvider<void>((ref) async {
  final gateway = ref.watch(scheduleNotificationGatewayProvider);
  try {
    await gateway.initialize(
      ref.read(scheduleNotificationTargetProvider.notifier).open,
    );
  } on Object {
    // Device notifications are optional; app data remains fully usable.
  }
});

final class ScheduleNotificationTargetController
    extends Notifier<ScheduleNotificationTarget?> {
  @override
  ScheduleNotificationTarget? build() => null;

  void open(ScheduleNotificationTarget target) => state = target;

  void clear() => state = null;
}

String _secureId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
