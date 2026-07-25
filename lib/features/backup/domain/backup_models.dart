final class BackupPreview {
  BackupPreview({
    required this.createdAt,
    required this.schemaVersion,
    required this.projectCount,
    required this.payloadFileCount,
    required this.payloadBytes,
    this.candidateToken,
  }) : createdAtUtc = createdAt.toUtc() {
    if (schemaVersion < 1 ||
        projectCount < 0 ||
        payloadFileCount < 1 ||
        payloadBytes < 1) {
      throw ArgumentError('Backup preview contains invalid counters');
    }
  }

  final DateTime createdAt;
  final DateTime createdAtUtc;
  final int schemaVersion;
  final int projectCount;
  final int payloadFileCount;
  final int payloadBytes;
  final String? candidateToken;
}
