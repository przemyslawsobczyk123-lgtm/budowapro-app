import 'dart:math';

import 'package:budowapro/features/documents/data/sqlite_document_repository.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/technical_photos/domain/technical_photo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_technical_photo_repository.dart';

final technicalPhotoRepositoryProvider =
    FutureProvider<TechnicalPhotoRepository>((ref) async {
      final database = await ref.watch(appDatabaseProvider.future);
      return SqliteTechnicalPhotoRepository(
        database: database,
        documentRepository: SqliteDocumentRepository(
          database: database,
          utcNow: DateTime.now,
        ),
        idGenerator: _secureId,
        utcNow: DateTime.now,
      );
    });

String _secureId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
