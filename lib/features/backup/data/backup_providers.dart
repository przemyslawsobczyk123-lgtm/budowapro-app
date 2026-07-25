import 'dart:io';
import 'dart:math';

import 'package:budowapro/features/backup/domain/backup_gateway.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'local_backup_gateway.dart';
import 'local_backup_service.dart';

final backupGatewayProvider = FutureProvider<BackupGateway>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final fileStore = await ref.watch(projectFileStoreProvider.future);
  final service = LocalBackupService(
    database: database,
    fileStore: fileStore,
    outputDirectoryProvider: () async {
      final temporaryDirectory = await getTemporaryDirectory();
      return Directory(p.join(temporaryDirectory.path, 'budowapro-backups'));
    },
    utcNow: DateTime.now,
    idGenerator: _secureId,
  );
  return LocalBackupGateway.forDevice(service: service);
});

String _secureId() {
  final random = Random.secure();
  return List<int>.generate(
    16,
    (_) => random.nextInt(256),
    growable: false,
  ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}
