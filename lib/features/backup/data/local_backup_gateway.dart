import 'dart:io';

import 'package:budowapro/features/backup/domain/backup_gateway.dart';
import 'package:budowapro/features/backup/domain/backup_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'local_backup_service.dart';

typedef PickBackupArchive = Future<File?> Function();
typedef ShareBackupArchive =
    Future<void> Function(File file, String shareTitle);

final class LocalBackupGateway implements BackupGateway {
  factory LocalBackupGateway.forDevice({required LocalBackupService service}) {
    return LocalBackupGateway(
      service: service,
      pickArchive: _pickBackupArchive,
      shareArchive: _shareBackupArchive,
    );
  }

  factory LocalBackupGateway({
    required LocalBackupService service,
    required PickBackupArchive pickArchive,
    required ShareBackupArchive shareArchive,
  }) {
    return LocalBackupGateway._(service, pickArchive, shareArchive);
  }

  LocalBackupGateway._(this._service, this._pickArchive, this._shareArchive);

  final LocalBackupService _service;
  final PickBackupArchive _pickArchive;
  final ShareBackupArchive _shareArchive;
  LocalBackupCandidate? _selectedCandidate;

  @override
  Future<BackupPreview> createAndShare({required String shareTitle}) async {
    final artifact = await _service.createBackup();
    await _shareArchive(artifact.file, shareTitle);
    return artifact.preview;
  }

  @override
  Future<BackupSelection?> pickAndInspect() async {
    final file = await _pickArchive();
    if (file == null) return null;
    final previousCandidate = _selectedCandidate;
    if (previousCandidate != null) {
      await _service.discardCandidate(previousCandidate);
      _selectedCandidate = null;
    }
    final candidate = await _service.inspectBackup(file);
    final token = candidate.preview.candidateToken;
    if (token == null) {
      throw const FormatException('Backup candidate token is missing');
    }
    _selectedCandidate = candidate;
    return BackupSelection(preview: candidate.preview, token: token);
  }

  @override
  Future<BackupPreview> restore(BackupSelection selection) async {
    final candidate = _selectedCandidate;
    if (candidate == null ||
        candidate.preview.candidateToken != selection.token) {
      throw StateError('Backup selection has expired');
    }
    final restored = await _service.restoreBackup(candidate);
    _selectedCandidate = null;
    return restored;
  }
}

Future<File?> _pickBackupArchive() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const <String>['zip'],
    allowMultiple: false,
    withData: false,
  );
  if (result == null) return null;
  final path = result.files.single.path;
  if (path == null || path.isEmpty) {
    throw const FileSystemException('Selected backup has no local path');
  }
  return File(path);
}

Future<void> _shareBackupArchive(File file, String shareTitle) async {
  await SharePlus.instance.share(
    ShareParams(
      files: <XFile>[XFile(file.path, mimeType: 'application/zip')],
      title: shareTitle,
    ),
  );
}
