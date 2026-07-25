import 'dart:collection';

const backupFormatName = 'budowapro-backup';
const backupFormatVersion = 1;
const backupManifestPath = 'manifest.json';
const backupChecksumsPath = 'checksums.json';
const backupDatabasePath = 'database/budowapro.db';

final class BackupManifest {
  BackupManifest({
    required this.createdAtUtc,
    required this.schemaVersion,
    required this.projectCount,
    required this.payloadFileCount,
    required this.payloadBytes,
  }) {
    if (!createdAtUtc.isUtc ||
        schemaVersion < 1 ||
        projectCount < 0 ||
        payloadFileCount < 1 ||
        payloadBytes < 1) {
      throw ArgumentError('Manifest contains invalid values');
    }
  }

  factory BackupManifest.fromJson(Map<String, Object?> json) {
    _requireExactKeys(json, const <String>{
      'format',
      'version',
      'createdAt',
      'schemaVersion',
      'database',
      'projects',
      'checksums',
      'projectCount',
      'payloadFileCount',
      'payloadBytes',
    });
    if (json['format'] != backupFormatName ||
        json['version'] != backupFormatVersion ||
        json['database'] != backupDatabasePath ||
        json['projects'] != 'projects/' ||
        json['checksums'] != backupChecksumsPath) {
      throw const FormatException('Unsupported backup manifest');
    }
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    final schemaVersion = json['schemaVersion'];
    final projectCount = json['projectCount'];
    final payloadFileCount = json['payloadFileCount'];
    final payloadBytes = json['payloadBytes'];
    if (createdAt == null ||
        !createdAt.isUtc ||
        schemaVersion is! int ||
        projectCount is! int ||
        payloadFileCount is! int ||
        payloadBytes is! int) {
      throw const FormatException('Invalid backup manifest values');
    }
    return BackupManifest(
      createdAtUtc: createdAt,
      schemaVersion: schemaVersion,
      projectCount: projectCount,
      payloadFileCount: payloadFileCount,
      payloadBytes: payloadBytes,
    );
  }

  final DateTime createdAtUtc;
  final int schemaVersion;
  final int projectCount;
  final int payloadFileCount;
  final int payloadBytes;

  Map<String, Object?> toJson() => <String, Object?>{
    'format': backupFormatName,
    'version': backupFormatVersion,
    'createdAt': createdAtUtc.toIso8601String(),
    'schemaVersion': schemaVersion,
    'database': backupDatabasePath,
    'projects': 'projects/',
    'checksums': backupChecksumsPath,
    'projectCount': projectCount,
    'payloadFileCount': payloadFileCount,
    'payloadBytes': payloadBytes,
  };
}

final class BackupChecksumEntry {
  BackupChecksumEntry({
    required this.path,
    required this.byteSize,
    required this.sha256,
  }) {
    if (path.isEmpty ||
        byteSize < 0 ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256)) {
      throw ArgumentError('Checksum entry contains invalid values');
    }
  }

  factory BackupChecksumEntry.fromJson(Map<String, Object?> json) {
    _requireExactKeys(json, const <String>{'path', 'byteSize', 'sha256'});
    final path = json['path'];
    final byteSize = json['byteSize'];
    final sha256 = json['sha256'];
    if (path is! String || byteSize is! int || sha256 is! String) {
      throw const FormatException('Invalid checksum entry');
    }
    try {
      return BackupChecksumEntry(
        path: path,
        byteSize: byteSize,
        sha256: sha256,
      );
    } on ArgumentError {
      throw const FormatException('Invalid checksum entry values');
    }
  }

  final String path;
  final int byteSize;
  final String sha256;

  Map<String, Object?> toJson() => <String, Object?>{
    'path': path,
    'byteSize': byteSize,
    'sha256': sha256,
  };
}

final class BackupChecksumCatalog {
  BackupChecksumCatalog(Iterable<BackupChecksumEntry> entries)
    : entries = UnmodifiableListView<BackupChecksumEntry>(
        List<BackupChecksumEntry>.of(entries),
      ) {
    final paths = this.entries.map((entry) => entry.path).toSet();
    if (paths.length != this.entries.length || this.entries.isEmpty) {
      throw ArgumentError('Checksum paths must be unique and non-empty');
    }
  }

  factory BackupChecksumCatalog.fromJson(Map<String, Object?> json) {
    _requireExactKeys(json, const <String>{'format', 'version', 'files'});
    if (json['format'] != 'budowapro-checksums' ||
        json['version'] != backupFormatVersion) {
      throw const FormatException('Unsupported checksum catalog');
    }
    final files = json['files'];
    if (files is! List<Object?>) {
      throw const FormatException('Invalid checksum file list');
    }
    try {
      return BackupChecksumCatalog(
        files.map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Invalid checksum item');
          }
          return BackupChecksumEntry.fromJson(item);
        }),
      );
    } on ArgumentError {
      throw const FormatException('Invalid checksum catalog values');
    }
  }

  final UnmodifiableListView<BackupChecksumEntry> entries;

  Map<String, Object?> toJson() => <String, Object?>{
    'format': 'budowapro-checksums',
    'version': backupFormatVersion,
    'files': <Map<String, Object?>>[
      for (final entry in entries) entry.toJson(),
    ],
  };
}

void _requireExactKeys(Map<String, Object?> json, Set<String> expected) {
  if (json.keys.toSet().length != expected.length ||
      !json.keys.toSet().containsAll(expected)) {
    throw const FormatException('Unexpected JSON fields');
  }
}
