import 'package:budowapro/features/technical_photos/domain/technical_photo.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('query normalizes search and reports active filter count', () {
    final query = TechnicalPhotoQuery(
      projectId: ' project-1 ',
      searchText: ' KUCHNIA ',
      albumIds: const <String>{'album-1'},
      stageIds: const <String>{'installations'},
      installationTypes: const <TechnicalInstallationType>{
        TechnicalInstallationType.water,
      },
      tags: const <String>{' Woda '},
    );

    expect(query.projectId, 'project-1');
    expect(query.searchText, 'kuchnia');
    expect(query.tags, <String>{'woda'});
    expect(query.activeFilterCount, 4);
  });

  test('query rejects too many values and an invalid date range', () {
    expect(
      () => TechnicalPhotoQuery(
        projectId: 'project-1',
        albumIds: Set<String>.from(
          List<String>.generate(51, (index) => 'album-$index'),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => TechnicalPhotoQuery(
        projectId: 'project-1',
        fromInclusive: DateTime.utc(2026, 8, 1),
        toExclusive: DateTime.utc(2026, 8, 1),
      ),
      throwsArgumentError,
    );
  });
}
