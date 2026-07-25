import 'dart:async';

final class LocalDataMaintenanceLock {
  Completer<void>? _maintenanceRelease;
  Completer<void>? _idle;
  var _activeOperations = 0;

  Future<T> runOperation<T>(Future<T> Function() action) async {
    while (true) {
      final maintenance = _maintenanceRelease;
      if (maintenance == null) break;
      await maintenance.future;
    }

    _activeOperations += 1;
    try {
      return await action();
    } finally {
      _activeOperations -= 1;
      if (_activeOperations == 0) {
        _idle?.complete();
        _idle = null;
      }
    }
  }

  Future<T> runMaintenance<T>(Future<T> Function() action) async {
    while (true) {
      final maintenance = _maintenanceRelease;
      if (maintenance == null) break;
      await maintenance.future;
    }

    final release = Completer<void>();
    _maintenanceRelease = release;
    try {
      if (_activeOperations > 0) {
        _idle ??= Completer<void>();
        await _idle!.future;
      }
      return await action();
    } finally {
      if (identical(_maintenanceRelease, release)) {
        _maintenanceRelease = null;
      }
      release.complete();
    }
  }
}
