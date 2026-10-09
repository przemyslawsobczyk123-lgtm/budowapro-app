import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Device half of the store screenshot handshake.
///
/// The host driver (`test_driver/store_screenshots_driver.dart`) polls
/// [pendingMethod] through the VM service. When the test has a request
/// pending, the driver performs it on the emulator (device setup, a real
/// `adb screencap`, cleanup) and confirms through [completeMethod]. Capturing
/// on the host keeps the system status bar in the image, which the in-app
/// `takeScreenshot` cannot do.
final class HostCaptureBridge {
  HostCaptureBridge._();

  static const pendingMethod = 'ext.budowapro.storeShots.pending';
  static const completeMethod = 'ext.budowapro.storeShots.complete';

  /// Asks the host to prepare the emulator (status bar demo mode,
  /// notification permission) before the app shows any data.
  static const setupRequest = '__setup__';

  /// Tells the host that every capture is done.
  static const finishRequest = '__finish__';

  static HostCaptureBridge register() {
    final bridge = HostCaptureBridge._();
    developer.registerExtension(pendingMethod, (method, parameters) async {
      return developer.ServiceExtensionResponse.result(
        jsonEncode(<String, Object?>{'name': bridge._pending ?? ''}),
      );
    });
    developer.registerExtension(completeMethod, (method, parameters) async {
      final name = parameters['name'];
      final result = bridge._result;
      if (name != null && name == bridge._pending && result != null) {
        bridge._pending = null;
        result.complete(parameters['error'] ?? '');
      }
      return developer.ServiceExtensionResponse.result('{}');
    });
    return bridge;
  }

  String? _pending;
  Completer<String>? _result;

  /// Publishes [name] to the host and keeps the app idle until the host
  /// confirms it.
  Future<void> request(
    WidgetTester tester,
    String name, {
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final result = Completer<String>();
    _result = result;
    _pending = name;
    debugPrint('STORE_SHOTS request: $name');
    final deadline = DateTime.now().add(timeout);
    while (!result.isCompleted) {
      if (DateTime.now().isAfter(deadline)) {
        _pending = null;
        throw TestFailure(
          'The host did not handle "$name". Run this test through '
          'test_driver/store_screenshots_driver.dart.',
        );
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    final error = await result.future;
    if (error.isNotEmpty) {
      throw TestFailure('The host could not handle "$name": $error');
    }
  }
}
