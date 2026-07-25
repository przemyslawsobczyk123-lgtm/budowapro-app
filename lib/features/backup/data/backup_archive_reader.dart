import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'backup_archive_format.dart';

const int maximumBackupArchiveBytes = 0xffffffff;
const int maximumBackupPayloadBytes = 16 * 1024 * 1024 * 1024;
const int maximumBackupEntryBytes = 2 * 1024 * 1024 * 1024;
const int maximumBackupEntryCount = 50000;
const int maximumBackupPathLength = 512;
const int maximumBackupManifestBytes = 256 * 1024;
const int maximumBackupChecksumsBytes = 16 * 1024 * 1024;
const int maximumBackupCentralDirectoryBytes = 64 * 1024 * 1024;

final class BackupArchiveInspection {
  BackupArchiveInspection({
    required this.manifest,
    required this.checksums,
    required this.signature,
    required Set<String> projectIds,
  }) : projectIds = Set<String>.unmodifiable(projectIds);

  final BackupManifest manifest;
  final BackupChecksumCatalog checksums;
  final String signature;
  final Set<String> projectIds;
}

Future<BackupArchiveInspection> inspectBackupArchive(File archiveFile) {
  final archivePath = archiveFile.absolute.path;
  return Isolate.run(() => _inspectBackupArchive(archivePath));
}

Future<BackupArchiveInspection> extractBackupArchive({
  required File archiveFile,
  required Directory stageDirectory,
}) {
  final request = _ArchiveExtractionRequest(
    archivePath: archiveFile.absolute.path,
    stagePath: stageDirectory.absolute.path,
  );
  return Isolate.run(() => _extractBackupArchive(request));
}

BackupArchiveInspection _inspectBackupArchive(String archivePath) {
  final opened = _openValidatedBackupArchive(archivePath);
  try {
    return opened.inspection;
  } finally {
    opened.close();
  }
}

Future<BackupArchiveInspection> _extractBackupArchive(
  _ArchiveExtractionRequest request,
) async {
  final stage = Directory(request.stagePath);
  if (await FileSystemEntity.type(stage.path, followLinks: false) !=
      FileSystemEntityType.notFound) {
    throw const FileSystemException('Restore stage already exists');
  }
  await stage.create(recursive: true);

  final opened = _openValidatedBackupArchive(request.archivePath);
  try {
    for (final checksum in opened.inspection.checksums.entries) {
      final header = opened.headers[checksum.path]!;
      final target = _stageTarget(stage, checksum.path);
      await target.parent.create(recursive: true);
      final output = _BoundedOutputFileStream(
        target.path,
        maximumBytes: checksum.byteSize,
      );
      try {
        ArchiveFile.file(
          header.filename,
          header.uncompressedSize,
          header.file!,
        ).writeContent(output);
        output.flush();
        if (output.length != checksum.byteSize) {
          throw const FormatException(
            'Extracted backup file has an invalid size',
          );
        }
      } finally {
        output.closeSync();
      }

      final digest = await sha256.bind(target.openRead()).first;
      if (digest.toString() != checksum.sha256) {
        throw const FormatException('Backup checksum verification failed');
      }
    }

    final database = _stageTarget(stage, backupDatabasePath);
    final handle = await database.open();
    try {
      final header = await handle.read(16);
      if (!const ListEquality<int>().equals(
        header,
        utf8.encode('SQLite format 3\u0000'),
      )) {
        throw const FormatException('Backup database header is invalid');
      }
    } finally {
      await handle.close();
    }
    return opened.inspection;
  } on Object catch (error, stackTrace) {
    if (await stage.exists()) await stage.delete(recursive: true);
    Error.throwWithStackTrace(error, stackTrace);
  } finally {
    opened.close();
  }
}

_OpenedBackupArchive _openValidatedBackupArchive(String archivePath) {
  final archiveType = FileSystemEntity.typeSync(
    archivePath,
    followLinks: false,
  );
  if (archiveType != FileSystemEntityType.file) {
    throw const FormatException('Backup must be a regular file');
  }
  final archiveLength = File(archivePath).lengthSync();
  if (archiveLength < 22 || archiveLength > maximumBackupArchiveBytes) {
    throw const FormatException('Backup archive size is unsupported');
  }
  _preflightZipDirectory(archivePath, archiveLength);

  final input = InputFileStream(archivePath);
  try {
    final directory = ZipDirectory()..read(input);
    if (directory.numberOfThisDisk != 0 ||
        directory.diskWithTheStartOfTheCentralDirectory != 0 ||
        directory.totalCentralDirectoryEntriesOnThisDisk !=
            directory.totalCentralDirectoryEntries ||
        directory.totalCentralDirectoryEntries !=
            directory.fileHeaders.length ||
        directory.fileHeaders.isEmpty ||
        directory.fileHeaders.length > maximumBackupEntryCount) {
      throw const FormatException('Unsupported ZIP directory');
    }

    final headers = <String, ZipFileHeader>{};
    var totalDeclaredBytes = 0;
    for (final header in directory.fileHeaders) {
      _validateHeader(header, archiveLength);
      if (headers.containsKey(header.filename)) {
        throw const FormatException('Backup contains a duplicate path');
      }
      headers[header.filename] = header;
      totalDeclaredBytes += header.uncompressedSize;
      if (totalDeclaredBytes >
          maximumBackupPayloadBytes +
              maximumBackupManifestBytes +
              maximumBackupChecksumsBytes) {
        throw const FormatException('Backup expands beyond the size limit');
      }
    }

    final manifestHeader = headers[backupManifestPath];
    final checksumsHeader = headers[backupChecksumsPath];
    if (manifestHeader == null || checksumsHeader == null) {
      throw const FormatException('Backup metadata is missing');
    }
    final manifest = BackupManifest.fromJson(
      _decodeJsonObject(
        _readBoundedEntry(manifestHeader, maximumBackupManifestBytes),
      ),
    );
    final checksums = BackupChecksumCatalog.fromJson(
      _decodeJsonObject(
        _readBoundedEntry(checksumsHeader, maximumBackupChecksumsBytes),
      ),
    );
    if (manifest.schemaVersion > 0x7fffffff) {
      throw const FormatException('Backup schema version is unsupported');
    }

    final payloadPaths = headers.keys.toSet()
      ..remove(backupManifestPath)
      ..remove(backupChecksumsPath);
    final checksumPaths = checksums.entries.map((entry) => entry.path).toSet();
    if (payloadPaths.length != checksumPaths.length ||
        !payloadPaths.containsAll(checksumPaths) ||
        !checksumPaths.containsAll(payloadPaths) ||
        !payloadPaths.contains(backupDatabasePath)) {
      throw const FormatException('Backup payload catalog does not match');
    }

    var payloadBytes = 0;
    final projectIds = <String>{};
    for (final checksum in checksums.entries) {
      _validatePayloadPath(checksum.path);
      final header = headers[checksum.path]!;
      if (header.uncompressedSize != checksum.byteSize) {
        throw const FormatException('Backup file size does not match catalog');
      }
      payloadBytes += checksum.byteSize;
      if (checksum.path.startsWith('projects/')) {
        projectIds.add(checksum.path.split('/')[1]);
      }
    }
    if (manifest.payloadFileCount != checksums.entries.length ||
        manifest.payloadBytes != payloadBytes ||
        payloadBytes > maximumBackupPayloadBytes ||
        projectIds.length > manifest.projectCount) {
      throw const FormatException('Backup counters do not match its payload');
    }

    final signatureEntries = checksums.entries.toList()
      ..sort((left, right) => left.path.compareTo(right.path));
    final signature = sha256
        .convert(
          utf8.encode(
            jsonEncode(<String, Object?>{
              'manifest': manifest.toJson(),
              'checksums': <Map<String, Object?>>[
                for (final entry in signatureEntries) entry.toJson(),
              ],
            }),
          ),
        )
        .toString();
    return _OpenedBackupArchive(
      input: input,
      headers: headers,
      inspection: BackupArchiveInspection(
        manifest: manifest,
        checksums: checksums,
        signature: signature,
        projectIds: projectIds,
      ),
    );
  } on Object catch (error, stackTrace) {
    input.closeSync();
    if (error is FormatException) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    Error.throwWithStackTrace(
      const FormatException('Backup archive is invalid'),
      stackTrace,
    );
  }
}

void _validateHeader(ZipFileHeader header, int archiveLength) {
  const allowedFlags = 0x0008 | 0x0800;
  final file = header.file;
  final path = header.filename;
  final unixType = (header.externalFileAttributes >> 16) & 0xf000;
  if (file == null ||
      path.isEmpty ||
      path.length > maximumBackupPathLength ||
      path.endsWith('/') ||
      path.endsWith(r'\') ||
      path.contains(r'\') ||
      path.contains('\u0000') ||
      p.posix.isAbsolute(path) ||
      p.windows.isAbsolute(path) ||
      path.split('/').any((segment) => segment.isEmpty || segment == '.') ||
      path.split('/').contains('..') ||
      header.diskNumberStart != 0 ||
      unixType == 0xa000 ||
      (header.generalPurposeBitFlag & 1) != 0 ||
      (file.flags & 1) != 0 ||
      (header.generalPurposeBitFlag & ~allowedFlags) != 0 ||
      (file.flags & ~allowedFlags) != 0 ||
      (header.compressionMethod != ZipFile.zipCompressionStore &&
          header.compressionMethod != ZipFile.zipCompressionDeflate) ||
      file.filename != path ||
      header.compressedSize < 0 ||
      header.compressedSize > archiveLength ||
      header.uncompressedSize < 0 ||
      header.uncompressedSize > maximumBackupEntryBytes ||
      (header.compressionMethod == ZipFile.zipCompressionStore &&
          header.compressedSize != header.uncompressedSize)) {
    throw const FormatException('Backup contains an unsafe ZIP entry');
  }
  final expectedCompression =
      header.compressionMethod == ZipFile.zipCompressionDeflate
      ? CompressionType.deflate
      : CompressionType.none;
  if (file.compressionMethod != expectedCompression) {
    throw const FormatException('ZIP headers have conflicting compression');
  }
}

void _validatePayloadPath(String path) {
  if (path == backupDatabasePath) return;
  final segments = path.split('/');
  const areas = <String>{'originals', 'previews', 'exports'};
  if (segments.length != 4 ||
      segments.first != 'projects' ||
      !_isSafeSegment(segments[1]) ||
      !areas.contains(segments[2]) ||
      !_isSafeSegment(segments[3]) ||
      segments[3].endsWith('.part')) {
    throw const FormatException('Backup contains an unsupported payload path');
  }
}

bool _isSafeSegment(String value) {
  return value.isNotEmpty &&
      value != '.' &&
      value != '..' &&
      !value.contains('/') &&
      !value.contains(r'\') &&
      !value.contains('\u0000') &&
      !p.posix.isAbsolute(value) &&
      !p.windows.isAbsolute(value);
}

Uint8List _readBoundedEntry(ZipFileHeader header, int maximumBytes) {
  if (header.uncompressedSize > maximumBytes) {
    throw const FormatException('Backup metadata exceeds the size limit');
  }
  final output = _BoundedMemoryOutputStream(maximumBytes);
  ArchiveFile.file(
    header.filename,
    header.uncompressedSize,
    header.file!,
  ).writeContent(output);
  final bytes = output.bytes;
  if (bytes.length != header.uncompressedSize) {
    throw const FormatException('Backup metadata could not be read');
  }
  return bytes;
}

void _preflightZipDirectory(String archivePath, int archiveLength) {
  const maximumTailBytes = 65557;
  final handle = File(archivePath).openSync();
  try {
    final tailLength = min(archiveLength, maximumTailBytes);
    final tailOffset = archiveLength - tailLength;
    handle.setPositionSync(tailOffset);
    final tail = Uint8List.fromList(handle.readSync(tailLength));
    final data = ByteData.sublistView(tail);
    for (var offset = tail.length - 22; offset >= 0; offset -= 1) {
      if (data.getUint32(offset, Endian.little) != ZipDirectory.eocdSignature) {
        continue;
      }
      final commentLength = data.getUint16(offset + 20, Endian.little);
      if (offset + 22 + commentLength != tail.length) continue;
      final diskNumber = data.getUint16(offset + 4, Endian.little);
      final centralDisk = data.getUint16(offset + 6, Endian.little);
      final entriesOnDisk = data.getUint16(offset + 8, Endian.little);
      final entryCount = data.getUint16(offset + 10, Endian.little);
      final centralSize = data.getUint32(offset + 12, Endian.little);
      final centralOffset = data.getUint32(offset + 16, Endian.little);
      final eocdPosition = tailOffset + offset;
      if (diskNumber != 0 ||
          centralDisk != 0 ||
          entriesOnDisk != entryCount ||
          entryCount == 0 ||
          entryCount == 0xffff ||
          entryCount > maximumBackupEntryCount ||
          centralSize == 0xffffffff ||
          centralOffset == 0xffffffff ||
          centralSize > maximumBackupCentralDirectoryBytes ||
          centralOffset + centralSize > eocdPosition) {
        throw const FormatException('Unsupported ZIP directory');
      }
      return;
    }
    throw const FormatException('ZIP end record is missing');
  } finally {
    handle.closeSync();
  }
}

Map<String, Object?> _decodeJsonObject(List<int> bytes) {
  final value = jsonDecode(utf8.decode(bytes, allowMalformed: false));
  if (value is! Map<String, Object?>) {
    throw const FormatException('Backup metadata must be a JSON object');
  }
  return value;
}

File _stageTarget(Directory stage, String archivePath) {
  final target = File(
    p.joinAll(<String>[stage.path, ...archivePath.split('/')]),
  ).absolute;
  final normalizedStage = p.normalize(stage.absolute.path);
  final normalizedTarget = p.normalize(target.path);
  if (!p.isWithin(normalizedStage, normalizedTarget)) {
    throw const FormatException('Backup path escapes restore staging');
  }
  return target;
}

final class _OpenedBackupArchive {
  const _OpenedBackupArchive({
    required this.input,
    required this.headers,
    required this.inspection,
  });

  final InputFileStream input;
  final Map<String, ZipFileHeader> headers;
  final BackupArchiveInspection inspection;

  void close() => input.closeSync();
}

final class _ArchiveExtractionRequest {
  const _ArchiveExtractionRequest({
    required this.archivePath,
    required this.stagePath,
  });

  final String archivePath;
  final String stagePath;
}

final class _BoundedOutputFileStream extends OutputStream {
  _BoundedOutputFileStream(String path, {required this.maximumBytes})
    : _output = OutputFileStream(path),
      super(byteOrder: ByteOrder.littleEndian);

  final OutputFileStream _output;
  final int maximumBytes;

  @override
  int get length => _output.length;

  @override
  bool get isOpen => _output.isOpen;

  @override
  void clear() => closeSync();

  @override
  Future<void> close() => _output.close();

  @override
  void closeSync() => _output.closeSync();

  @override
  void flush() => _output.flush();

  @override
  void writeByte(int value) {
    _reserve(1);
    _output.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final writeLength = length ?? bytes.length;
    if (writeLength < 0 || writeLength > bytes.length) {
      throw const FormatException('Invalid decompressed ZIP chunk');
    }
    _reserve(writeLength);
    _output.writeBytes(bytes, length: writeLength);
  }

  @override
  void writeStream(InputStream stream) {
    const chunkSize = 1024 * 1024;
    while (!stream.isEOS) {
      final length = min(chunkSize, stream.length);
      if (length <= 0) break;
      writeBytes(stream.readBytes(length).toUint8List());
    }
  }

  @override
  Uint8List subset(int start, [int? end]) => _output.subset(start, end);

  void _reserve(int bytes) {
    if (length + bytes > maximumBytes) {
      throw const FormatException('Decompressed ZIP entry exceeds its limit');
    }
  }
}

final class _BoundedMemoryOutputStream extends OutputStream {
  _BoundedMemoryOutputStream(this.maximumBytes)
    : super(byteOrder: ByteOrder.littleEndian);

  final int maximumBytes;
  final BytesBuilder _builder = BytesBuilder(copy: false);
  var _length = 0;

  Uint8List get bytes => _builder.toBytes();

  @override
  int get length => _length;

  @override
  void clear() {
    _builder.clear();
    _length = 0;
  }

  @override
  void flush() {}

  @override
  void writeByte(int value) {
    _reserve(1);
    _builder.addByte(value);
    _length += 1;
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final writeLength = length ?? bytes.length;
    if (writeLength < 0 || writeLength > bytes.length) {
      throw const FormatException('Invalid decompressed ZIP chunk');
    }
    _reserve(writeLength);
    _builder.add(
      writeLength == bytes.length ? bytes : bytes.sublist(0, writeLength),
    );
    _length += writeLength;
  }

  @override
  void writeStream(InputStream stream) {
    const chunkSize = 1024 * 1024;
    while (!stream.isEOS) {
      final length = min(chunkSize, stream.length);
      if (length <= 0) break;
      writeBytes(stream.readBytes(length).toUint8List());
    }
  }

  @override
  Uint8List subset(int start, [int? end]) {
    return Uint8List.sublistView(bytes, start, end);
  }

  void _reserve(int bytes) {
    if (_length + bytes > maximumBytes) {
      throw const FormatException('Decompressed ZIP entry exceeds its limit');
    }
  }
}

final class ListEquality<T> {
  const ListEquality();

  bool equals(List<T> left, List<T> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
