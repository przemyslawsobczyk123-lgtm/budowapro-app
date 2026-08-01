import 'dart:math';

import 'package:budowapro/features/diary/data/sqlite_journal_repository.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/documents/data/local_attachment_stager.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/features/punch_list/domain/punch_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sqlite_punch_repository.dart';
import 'protocol_pdf_gateway.dart';

typedef DefectTarget = ({String projectId, String defectId});
typedef AcceptanceProtocolTarget = ({String projectId, String protocolId});
typedef PunchAttachmentTarget = ({String projectId, String attachmentId});

final punchRepositoryProvider = FutureProvider<PunchRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return SqlitePunchRepository(
    database: database,
    journalRepository: SqliteJournalRepository(
      database: database,
      idGenerator: _secureId,
      utcNow: DateTime.now,
    ),
    idGenerator: _secureId,
    utcNow: DateTime.now,
  );
});

final protocolPdfGatewayProvider = Provider<ProtocolPdfGateway>((ref) {
  return LocalProtocolPdfGateway.forDevice();
});

final defectProvider = FutureProvider.autoDispose
    .family<DefectRecord?, DefectTarget>((ref, target) async {
      return (await ref.watch(
        punchRepositoryProvider.future,
      )).findDefectById(projectId: target.projectId, defectId: target.defectId);
    });

final acceptanceProtocolProvider = FutureProvider.autoDispose
    .family<AcceptanceProtocol?, AcceptanceProtocolTarget>((ref, target) async {
      return (await ref.watch(punchRepositoryProvider.future)).findProtocolById(
        projectId: target.projectId,
        protocolId: target.protocolId,
      );
    });

final punchAttachmentProvider = FutureProvider.autoDispose
    .family<StagedLocalAttachment?, PunchAttachmentTarget>((ref, target) async {
      return (await ref.watch(localAttachmentStagerProvider.future)).findById(
        projectId: target.projectId,
        attachmentId: target.attachmentId,
      );
    });

final protocolDefectOptionsProvider = FutureProvider.autoDispose
    .family<List<DefectRecord>, String>((ref, projectId) async {
      final repository = await ref.watch(punchRepositoryProvider.future);
      final defects = <DefectRecord>[];
      var request = PageRequest(limit: PageRequest.maximumLimit);
      while (true) {
        final page = await repository.listDefects(
          DefectQuery(projectId: projectId),
          request,
        );
        defects.addAll(page.items);
        final next = page.nextRequest;
        if (next == null) return List<DefectRecord>.unmodifiable(defects);
        request = next;
      }
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
