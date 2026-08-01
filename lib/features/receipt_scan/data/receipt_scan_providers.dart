import 'dart:math';

import 'package:budowapro/features/costs/data/sqlite_cost_repository.dart';
import 'package:budowapro/features/documents/data/document_providers.dart';
import 'package:budowapro/features/projects/data/project_providers.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_financial.dart';
import 'package:budowapro/features/receipt_scan/domain/receipt_scan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_receipt_scan_gateway.dart';
import 'receipt_capture_adapters.dart';
import 'receipt_ocr_image_preparer.dart';
import 'receipt_text_recognizer.dart';
import 'sqlite_receipt_financial_repository.dart';

final receiptScanGatewayProvider = FutureProvider<ReceiptScanGateway>((
  ref,
) async {
  final stager = await ref.watch(localAttachmentStagerProvider.future);
  return LocalReceiptScanGateway(
    attachmentStore: LocalReceiptAttachmentStore(stager),
    scanner: MlKitReceiptDocumentScanner(),
    filePicker: FilePickerReceiptSourcePicker(),
    imagePreparer: LocalReceiptOcrImagePreparer(),
    textRecognizer: MlKitReceiptTextRecognizer(),
  );
});

final receiptFinancialRepositoryProvider =
    FutureProvider<ReceiptFinancialRepository>((ref) async {
      final database = await ref.watch(appDatabaseProvider.future);
      final costs = SqliteCostRepository(
        database: database,
        idGenerator: _secureReceiptId,
        utcNow: DateTime.now,
      );
      return SqliteReceiptFinancialRepository(
        database: database,
        costRepository: costs,
        idGenerator: _secureReceiptId,
        utcNow: DateTime.now,
      );
    });

final receiptScanDependenciesProvider =
    FutureProvider.family<ReceiptScanDependencies, String>((
      ref,
      projectId,
    ) async {
      final gateway = await ref.watch(receiptScanGatewayProvider.future);
      final financialRepository = await ref.watch(
        receiptFinancialRepositoryProvider.future,
      );
      final projects = await ref.watch(projectRepositoryProvider.future);
      final project = await projects.findById(projectId);
      if (project == null) throw const ProjectNotFoundException();
      final stages = await (await ref.watch(
        stageRepositoryProvider.future,
      )).listStages(projectId: project.id, template: project.template);
      return ReceiptScanDependencies(
        gateway: gateway,
        financialRepository: financialRepository,
        currencyCode: project.currencyCode,
        stages: stages,
        defaultStageId: _stageStorageId(project.currentStage),
      );
    });

final class ReceiptScanDependencies {
  const ReceiptScanDependencies({
    required this.gateway,
    required this.financialRepository,
    required this.currencyCode,
    this.stages = const <ProjectStage>[],
    this.defaultStageId,
  });

  final ReceiptScanGateway gateway;
  final ReceiptFinancialRepository financialRepository;
  final String currencyCode;
  final List<ProjectStage> stages;
  final String? defaultStageId;
}

String _stageStorageId(ProjectStageKey value) => switch (value) {
  ProjectStageKey.planning => 'planning',
  ProjectStageKey.formalities => 'formalities',
  ProjectStageKey.sitePreparation => 'site_preparation',
  ProjectStageKey.stateZero => 'state_zero',
  ProjectStageKey.shellOpen => 'shell_open',
  ProjectStageKey.shellClosed => 'shell_closed',
  ProjectStageKey.demolition => 'demolition',
  ProjectStageKey.installations => 'installations',
  ProjectStageKey.plaster => 'plaster',
  ProjectStageKey.finishing => 'finishing',
  ProjectStageKey.handover => 'handover',
};

String _secureReceiptId() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List<String>.generate(
    24,
    (_) => alphabet[random.nextInt(alphabet.length)],
    growable: false,
  ).join();
}
