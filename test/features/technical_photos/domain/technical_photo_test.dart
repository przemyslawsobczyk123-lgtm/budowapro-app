import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes album text and photo tags without losing capture time', () {
    final album = TechnicalAlbum(
      id: 'album-1',
      projectId: 'project-1',
      title: '  Instalacje przed tynkiem  ',
      kind: TechnicalAlbumKind.beforePlaster,
      stageId: 'installations',
      description: '  Dowody przed zakryciem.  ',
      createdAt: DateTime.parse('2026-07-31T12:00:00+02:00'),
      updatedAt: DateTime.parse('2026-07-31T12:00:00+02:00'),
    );
    final photo = TechnicalPhoto(
      attachmentId: 'photo-1',
      projectId: 'project-1',
      albumId: album.id,
      title: '  Kuchnia - woda i prad  ',
      capturedAt: DateTime.parse('2026-07-30T09:15:00+02:00'),
      installationType: TechnicalInstallationType.water,
      stageId: 'installations',
      zoneLabel: '  Kuchnia  ',
      contractorContactId: 'contact-1',
      checklistItemId: 'checklist-1',
      description: '  Trasy przed tynkiem.  ',
      tags: const <String>[' Woda ', 'kuchnia', 'woda', 'PRZED TYNKIEM'],
      displayName: 'IMG_1001.jpg',
      mediaType: 'image/jpeg',
      hasPreview: true,
      importedAt: DateTime.parse('2026-07-31T10:00:00+02:00'),
    );

    expect(album.title, 'Instalacje przed tynkiem');
    expect(album.description, 'Dowody przed zakryciem.');
    expect(photo.title, 'Kuchnia - woda i prad');
    expect(photo.zoneLabel, 'Kuchnia');
    expect(photo.description, 'Trasy przed tynkiem.');
    expect(photo.tags, <String>['kuchnia', 'przed tynkiem', 'woda']);
    expect(photo.capturedAtUtc, DateTime.utc(2026, 7, 30, 7, 15));
    expect(photo.isImage, isTrue);
  });

  test('rejects unsupported media and excessive or malformed tags', () {
    TechnicalPhoto build({
      String mediaType = 'image/jpeg',
      Iterable<String> tags = const <String>[],
    }) => TechnicalPhoto(
      attachmentId: 'photo-1',
      projectId: 'project-1',
      albumId: 'album-1',
      title: 'Uziom fundamentowy',
      capturedAt: DateTime.utc(2026, 7, 31),
      installationType: TechnicalInstallationType.grounding,
      tags: tags,
      displayName: 'evidence.jpg',
      mediaType: mediaType,
      hasPreview: false,
      importedAt: DateTime.utc(2026, 7, 31),
    );

    expect(() => build(mediaType: 'application/pdf'), throwsArgumentError);
    expect(
      () => build(tags: List<String>.generate(13, (index) => 'tag-$index')),
      throwsArgumentError,
    );
    expect(() => build(tags: <String>['x' * 33]), throwsArgumentError);
  });

  test('requires album dates in order and one project identity', () {
    expect(
      () => TechnicalAlbum(
        id: 'album-1',
        projectId: 'project-1',
        title: 'Przed betonem',
        kind: TechnicalAlbumKind.beforeConcrete,
        createdAt: DateTime.utc(2026, 7, 31, 12),
        updatedAt: DateTime.utc(2026, 7, 31, 11),
      ),
      throwsArgumentError,
    );
    expect(
      () => TechnicalPhoto(
        attachmentId: 'photo-1',
        projectId: ' ',
        albumId: 'album-1',
        title: 'Zdjecie',
        capturedAt: DateTime.utc(2026, 7, 31),
        installationType: TechnicalInstallationType.other,
        displayName: 'photo.jpg',
        mediaType: 'image/jpeg',
        hasPreview: false,
        importedAt: DateTime.utc(2026, 7, 31),
      ),
      throwsArgumentError,
    );
  });
}
