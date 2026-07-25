import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/exports/domain/cost_csv_export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_cost_csv_export_gateway.dart';

final costCsvExportGatewayProvider = FutureProvider<CostCsvExportGateway>((
  ref,
) async {
  final repository = await ref.watch(costRepositoryProvider.future);
  return LocalCostCsvExportGateway.forDevice(repository: repository);
});
