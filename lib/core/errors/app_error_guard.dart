import 'dart:async';

import 'package:flutter/foundation.dart';

abstract final class AppErrorGuard {
  static const productionDiagnostic =
      'BudowaPRO: wystapil nieoczekiwany blad aplikacji.';

  static String diagnosticFor(Object error, {required bool releaseMode}) {
    return releaseMode
        ? productionDiagnostic
        : '$productionDiagnostic (${error.runtimeType})';
  }

  static void run(VoidCallback bootstrap) {
    runZonedGuarded<void>(() {
      FlutterError.onError = (details) {
        _report(details.exception, details.stack ?? StackTrace.current);
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        _report(error, stackTrace);
        return true;
      };
      bootstrap();
    }, _report);
  }

  static void _report(Object error, StackTrace stackTrace) {
    debugPrint(diagnosticFor(error, releaseMode: kReleaseMode));
  }
}
