import 'dart:io';

import 'package:budowapro/features/captures/data/capture_attachment_picker.dart';
import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a supported local photo', () async {
    final picker = FilePickerCaptureAttachmentPicker(
      pickPhoto: () async => FilePickerResult(<PlatformFile>[
        PlatformFile(name: 'budowa.png', size: 12, path: 'C:/temp/budowa.png'),
      ]),
    );

    final result = await picker.pick(CaptureDraftType.photo);

    expect(result, isNotNull);
    expect(result!.mediaType, 'image/png');
    expect(result.displayName, 'budowa.png');
  });

  test('rejects a photo format unsupported by local image processing', () {
    final picker = FilePickerCaptureAttachmentPicker(
      pickPhoto: () async => FilePickerResult(<PlatformFile>[
        PlatformFile(name: 'budowa.gif', size: 12, path: 'C:/temp/budowa.gif'),
      ]),
    );

    expect(
      picker.pick(CaptureDraftType.photo),
      throwsA(isA<FileSystemException>()),
    );
  });
}
