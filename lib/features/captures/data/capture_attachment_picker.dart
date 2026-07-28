import 'dart:io';

import 'package:budowapro/core/config/storage_policy.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

abstract interface class CaptureAttachmentPicker {
  Future<PickedLocalAttachment?> pick(CaptureDraftType type);
}

final class FilePickerCaptureAttachmentPicker
    implements CaptureAttachmentPicker {
  @override
  Future<PickedLocalAttachment?> pick(CaptureDraftType type) async {
    final result = await switch (type) {
      CaptureDraftType.photo => FilePicker.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.image,
      ),
      CaptureDraftType.voice => FilePicker.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.audio,
      ),
      CaptureDraftType.document => FilePicker.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.custom,
        allowedExtensions: _documentExtensions,
      ),
      _ => throw ArgumentError.value(type, 'type'),
    };
    if (result == null) return null;
    final selected = result.files.single;
    final sourcePath = selected.path;
    if (sourcePath == null) {
      throw const FileSystemException('Selected file has no local path');
    }
    return PickedLocalAttachment(
      sourceUri: Uri.file(sourcePath),
      displayName: selected.name,
      reportedByteSize: selected.size,
      mediaType: _mediaTypeFor(selected.name),
    );
  }
}

final List<String> _documentExtensions = StoragePolicy
    .supportedAttachmentExtensions
    .where(
      (extension) => !const <String>{
        'mp3',
        'm4a',
        'aac',
        'wav',
        'ogg',
        'opus',
      }.contains(extension),
    )
    .toList(growable: false);

String? _mediaTypeFor(String fileName) {
  return switch (p.extension(fileName).toLowerCase()) {
    '.pdf' => 'application/pdf',
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.webp' => 'image/webp',
    '.heic' => 'image/heic',
    '.txt' => 'text/plain',
    '.csv' => 'text/csv',
    '.doc' => 'application/msword',
    '.docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.xls' => 'application/vnd.ms-excel',
    '.xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.ppt' => 'application/vnd.ms-powerpoint',
    '.pptx' =>
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    '.mp3' => 'audio/mpeg',
    '.m4a' => 'audio/mp4',
    '.aac' => 'audio/aac',
    '.wav' => 'audio/wav',
    '.ogg' || '.opus' => 'audio/ogg',
    _ => null,
  };
}
