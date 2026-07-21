import 'package:budowapro/features/projects/domain/project.dart';

import 'dashboard_snapshot.dart';

abstract interface class DashboardReader {
  Future<DashboardSnapshot> load({
    required Project project,
    required DashboardWindow window,
  });
}

final class DashboardWindow {
  factory DashboardWindow({
    required DateTime todayStart,
    required DateTime todayEndExclusive,
    required DateTime forecastEndExclusive,
  }) {
    final start = todayStart.toUtc();
    final todayEnd = todayEndExclusive.toUtc();
    final forecastEnd = forecastEndExclusive.toUtc();
    if (!start.isBefore(todayEnd) || todayEnd.isAfter(forecastEnd)) {
      throw ArgumentError('dashboard window boundaries are invalid');
    }
    return DashboardWindow._(
      todayStartUtc: start,
      todayEndExclusiveUtc: todayEnd,
      forecastEndExclusiveUtc: forecastEnd,
    );
  }

  const DashboardWindow._({
    required this.todayStartUtc,
    required this.todayEndExclusiveUtc,
    required this.forecastEndExclusiveUtc,
  });

  final DateTime todayStartUtc;
  final DateTime todayEndExclusiveUtc;
  final DateTime forecastEndExclusiveUtc;
}
