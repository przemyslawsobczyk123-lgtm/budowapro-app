import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/shared/models/page.dart';

import 'punch_models.dart';

abstract interface class PunchRepository {
  Future<DefectRecord> createDefect(DefectInput input);

  Future<DefectRecord> updateDefect({
    required String projectId,
    required String defectId,
    required DefectInput input,
  });

  Future<DefectRecord?> findDefectById({
    required String projectId,
    required String defectId,
  });

  Future<Page<DefectRecord>> listDefects(
    DefectQuery query,
    PageRequest request,
  );

  Future<PunchSummary> summarizeDefects({
    required String projectId,
    required DateTime now,
  });

  Future<DefectRecord> setDefectStatus({
    required String projectId,
    required String defectId,
    required JournalEntryStatus status,
  });

  Future<AcceptanceProtocol> createProtocol(AcceptanceProtocolInput input);

  Future<AcceptanceProtocol> updateProtocol({
    required String projectId,
    required String protocolId,
    required AcceptanceProtocolInput input,
  });

  Future<AcceptanceProtocol?> findProtocolById({
    required String projectId,
    required String protocolId,
  });

  Future<Page<AcceptanceProtocol>> listProtocols(
    AcceptanceProtocolQuery query,
    PageRequest request,
  );
}

final class DefectNotFoundException implements Exception {
  const DefectNotFoundException();
}

final class AcceptanceProtocolNotFoundException implements Exception {
  const AcceptanceProtocolNotFoundException();
}

final class PunchRelationNotFoundException implements Exception {
  const PunchRelationNotFoundException();
}

final class DefectClosureEvidenceRequiredException implements Exception {
  const DefectClosureEvidenceRequiredException();
}

final class DefectClosureProtocolRequiredException implements Exception {
  const DefectClosureProtocolRequiredException();
}
