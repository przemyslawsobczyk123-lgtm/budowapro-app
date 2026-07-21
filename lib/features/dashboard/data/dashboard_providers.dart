import 'package:budowapro/features/costs/data/cost_providers.dart';
import 'package:budowapro/features/dashboard/domain/dashboard_reader.dart';
import 'package:budowapro/features/schedule/data/schedule_providers.dart';
import 'package:budowapro/features/stages/data/stage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_dashboard_reader.dart';

final dashboardReaderProvider = FutureProvider<DashboardReader>((ref) async {
  return RepositoryDashboardReader(
    costRepository: await ref.watch(costRepositoryProvider.future),
    stageRepository: await ref.watch(stageRepositoryProvider.future),
    scheduleRepository: await ref.watch(scheduleRepositoryProvider.future),
  );
});
