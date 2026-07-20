import 'package:budowapro/features/costs/data/cost_attachment_picker.dart';
import 'package:budowapro/features/costs/data/cost_attachment_stager.dart';
import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stagePlanGatewayProvider = FutureProvider<StagePlanGateway>((ref) async {
  return StagePlanGateway(
    repository: await ref.watch(stageRepositoryProvider.future),
    attachmentPicker: ref.watch(costAttachmentPickerProvider),
    attachmentStager: await ref.watch(costAttachmentStagerProvider.future),
  );
});

final class StagePlanGateway {
  const StagePlanGateway({
    required this.repository,
    required this._attachmentPicker,
    required this._attachmentStager,
  });

  final StageRepository repository;
  final CostAttachmentPicker _attachmentPicker;
  final CostAttachmentStager _attachmentStager;

  Future<bool> pickAndAttachEvidence({
    required String projectId,
    required String checklistItemId,
  }) async {
    final picked = await _attachmentPicker.pick();
    if (picked == null) {
      return false;
    }
    final staged = await _attachmentStager.stage(
      projectId: projectId,
      pickedFile: picked,
    );
    try {
      await repository.attachEvidence(
        projectId: projectId,
        checklistItemId: checklistItemId,
        attachmentId: staged.id,
      );
    } on Object catch (error, stackTrace) {
      await _attachmentStager.discardIfUnlinked(
        projectId: projectId,
        attachmentId: staged.id,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
    return true;
  }
}
