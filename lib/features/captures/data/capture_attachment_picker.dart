import 'dart:io';

import 'package:budowapro/core/config/storage_policy.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

abstract interface class CaptureAttachmentPicker {
  Future<PickedLocalAttachment?> pick(CaptureDraftType type);
}

typedef PickCaptureAttachment = Future<FilePickerResult?> Function();

final class FilePickerCaptureAttachmentPicker
    implements CaptureAttachmentPicker {
  FilePickerCaptureAttachmentPicker({
    PickCaptureAttachment? pickPhoto,
    PickCaptureAttachment? pickVoice,
    PickCaptureAttachment? pickDocument,
  }) : _pickPhoto = pickPhoto ?? _pickPhotoFile,
       _pickVoice = pickVoice ?? _pickVoiceFile,
       _pickDocument = pickDocument ?? _pickDocumentFile;

  static const List<String> photoExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  final PickCaptureAttachment _pickPhoto;
  final PickCaptureAttachment _pickVoice;
  final PickCaptureAttachment _pickDocument;

  @override
  Future<PickedLocalAttachment?> pick(CaptureDraftType type) async {
    final result = await switch (type) {
      CaptureDraftType.photo => _pickPhoto(),
      CaptureDraftType.voice => _pickVoice(),
      CaptureDraftType.document => _pickDocument(),
      _ => throw ArgumentError.value(type, 'type'),
    };
    if (result == null) return null;
    final selected = result.files.single;
    final sourcePath = selected.path;
    if (sourcePath == null) {
      throw const FileSystemException('Selected file has no local path');
    }
    final extension = p
        .extension(selected.name)
        .toLowerCase()
        .replaceFirst('.', '');
    if (type == CaptureDraftType.photo &&
        !photoExtensions.contains(extension)) {
      throw const FileSystemException('Selected photo format is unsupported');
    }
    return PickedLocalAttachment(
      sourceUri: Uri.file(sourcePath),
      displayName: selected.name,
      reportedByteSize: selected.size,
      mediaType: _mediaTypeFor(selected.name),
    );
  }

  static Future<FilePickerResult?> _pickPhotoFile() {
    return FilePicker.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: photoExtensions,
    );
  }

  static Future<FilePickerResult?> _pickVoiceFile() {
    return FilePicker.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.audio,
    );
  }

  static Future<FilePickerResult?> _pickDocumentFile() {
    return FilePicker.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: _documentExtensions,
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
