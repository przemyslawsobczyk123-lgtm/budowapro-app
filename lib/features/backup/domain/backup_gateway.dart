import 'package:budowapro/features/backup/domain/backup_models.dart';

final class BackupSelection {
  const BackupSelection({required this.preview, required this.token});

  final BackupPreview preview;
  final String token;
}

abstract interface class BackupGateway {
  Future<BackupPreview> createAndShare({required String shareTitle});

  Future<BackupSelection?> pickAndInspect();

  Future<BackupPreview> restore(BackupSelection selection);
}
