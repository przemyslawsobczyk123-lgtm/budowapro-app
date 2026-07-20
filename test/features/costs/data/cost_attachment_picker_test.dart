import 'package:budowapro/features/costs/data/cost_attachment_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a selected PDF without loading it into memory', () async {
    final picker = FilePickerCostAttachmentPicker(
      pickFiles: () async => FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'faktura.pdf',
          size: 500,
          path: 'C:/picker-cache/faktura.pdf',
        ),
      ]),
    );

    final selected = await picker.pick();

    expect(selected, isNotNull);
    expect(selected!.displayName, 'faktura.pdf');
    expect(selected.reportedByteSize, 500);
    expect(selected.mediaType, 'application/pdf');
    expect(selected.sourceUri.isScheme('file'), isTrue);
  });

  test('returns null when the system picker is cancelled', () async {
    final picker = FilePickerCostAttachmentPicker(pickFiles: () async => null);

    expect(await picker.pick(), isNull);
  });
}
