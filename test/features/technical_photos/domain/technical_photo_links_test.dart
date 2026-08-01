import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes and deduplicates typed technical photo links', () {
    final input = TechnicalPhotoInput(
      projectId: 'project-1',
      attachmentId: 'photo-1',
      albumId: 'album-1',
      title: 'Rozdzielnica przed tynkiem',
      capturedAt: DateTime.utc(2026, 7, 31),
      installationType: TechnicalInstallationType.electrical,
      links: const <TechnicalPhotoLink>[
        TechnicalPhotoLink(
          type: TechnicalPhotoLinkType.cost,
          targetId: 'cost-1',
        ),
        TechnicalPhotoLink(
          type: TechnicalPhotoLinkType.cost,
          targetId: 'cost-1',
        ),
        TechnicalPhotoLink(
          type: TechnicalPhotoLinkType.defect,
          targetId: 'defect-1',
        ),
      ],
    );

    expect(input.links, hasLength(2));
    expect(input.links.map((link) => link.type), <TechnicalPhotoLinkType>[
      TechnicalPhotoLinkType.cost,
      TechnicalPhotoLinkType.defect,
    ]);
  });

  test('rejects too many typed links', () {
    expect(
      () => TechnicalPhotoInput(
        projectId: 'project-1',
        attachmentId: 'photo-1',
        albumId: 'album-1',
        title: 'Instalacja',
        capturedAt: DateTime.utc(2026, 7, 31),
        installationType: TechnicalInstallationType.other,
        links: List<TechnicalPhotoLink>.generate(
          21,
          (index) => TechnicalPhotoLink(
            type: TechnicalPhotoLinkType.cost,
            targetId: 'cost-$index',
          ),
        ),
      ),
      throwsArgumentError,
    );
  });
}
