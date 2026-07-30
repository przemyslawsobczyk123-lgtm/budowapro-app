import 'dart:io';

import 'package:budowapro/core/config/storage_policy.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import 'local_attachment_stager.dart';

typedef PickLocalFiles = Future<FilePickerResult?> Function();

abstract interface class LocalAttachmentPicker {
  Future<PickedLocalAttachment?> pick();
}

final class FilePickerLocalAttachmentPicker implements LocalAttachmentPicker {
  FilePickerLocalAttachmentPicker({PickLocalFiles? pickFiles})
    : _pickFiles = pickFiles ?? _pickSingleFile;

  final PickLocalFiles _pickFiles;

  @override
  Future<PickedLocalAttachment?> pick() async {
    final result = await _pickFiles();
    if (result == null) {
      return null;
    }
    final selected = result.files.single;
    final sourcePath = selected.path;
    if (sourcePath == null) {
      throw const FileSystemException('Selected file has no local path');
    }
    return PickedLocalAttachment(
      sourceUri: Uri.file(
        sourcePath,
        windows: p.windows.isAbsolute(sourcePath),
      ),
      displayName: selected.name,
      reportedByteSize: selected.size,
      mediaType: _mediaTypeFor(selected.name),
    );
  }

  static Future<FilePickerResult?> _pickSingleFile() {
    return FilePicker.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: StoragePolicy.supportedAttachmentExtensions.toList(
        growable: false,
      ),
    );
  }
}

typedef CostAttachmentPicker = LocalAttachmentPicker;
typedef FilePickerCostAttachmentPicker = FilePickerLocalAttachmentPicker;

String? _mediaTypeFor(String fileName) {
  return switch (p.extension(fileName).toLowerCase()) {
    '.pdf' => 'application/pdf',
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.webp' => 'image/webp',
    '.heic' => 'image/heic',
    '.txt' => 'text/plain',
    '.doc' => 'application/msword',
    '.docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.xls' => 'application/vnd.ms-excel',
    '.xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    _ => null,
  };
}
