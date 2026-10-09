// Host side of the Google Play screenshot harness.
//
// integration_test/store_screenshots_test.dart asks this driver for every
// capture through a VM service extension. The driver takes a real
// `adb screencap` of the emulator (status bar in System UI demo mode: 12:00,
// full battery and signal, no notifications), drops the alpha channel and
// writes `<name>.png` into STORE_SHOTS_OUT. Only emulators are accepted.
//
//   STORE_SHOTS_DEVICE=emulator-5560 STORE_SHOTS_OUT=build/store_screenshots \
//   flutter drive -d emulator-5560 \
//     --driver=test_driver/store_screenshots_driver.dart \
//     --target=integration_test/store_screenshots_test.dart
//
// Uninstall pl.budowapro from the emulator first: the test needs an empty
// database. The adb binary is taken from ADB, ANDROID_HOME, ANDROID_SDK_ROOT
// or PATH, in that order.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart' as p;

const _pendingMethod = 'ext.budowapro.storeShots.pending';
const _completeMethod = 'ext.budowapro.storeShots.complete';
const _setupRequest = '__setup__';
const _finishRequest = '__finish__';
const _packageName = 'pl.budowapro';

Future<void> main() async {
  final serial = Platform.environment['STORE_SHOTS_DEVICE']?.trim() ?? '';
  if (!RegExp(r'^emulator-\d+$').hasMatch(serial)) {
    stderr.writeln(
      'Set STORE_SHOTS_DEVICE to the emulator serial (emulator-NNNN). '
      'Store screenshots are never taken on physical devices.',
    );
    exit(64);
  }
  final adb = _Adb(_adbExecutable(), serial);
  if ((await adb.shell(<String>['getprop', 'ro.kernel.qemu'])).trim() != '1') {
    stderr.writeln('$serial does not report itself as an emulator.');
    exit(64);
  }
  final output = Directory(
    Platform.environment['STORE_SHOTS_OUT'] ??
        p.join('build', 'store_screenshots', serial),
  );
  await output.create(recursive: true);

  final driver = await FlutterDriver.connect();
  final bridge = _CaptureBridge(driver: driver, adb: adb, output: output);
  unawaited(bridge.run());
  await integrationDriver(driver: driver, writeResponseOnFailure: true);
}

final class _CaptureBridge {
  _CaptureBridge({
    required this.driver,
    required this.adb,
    required this.output,
  });

  final FlutterDriver driver;
  final _Adb adb;
  final Directory output;
  var _finished = false;

  Future<void> run() async {
    final isolateId = driver.appIsolate.id!;
    while (!_finished) {
      var name = '';
      try {
        final response = await driver.serviceClient.callServiceExtension(
          _pendingMethod,
          isolateId: isolateId,
        );
        name = response.json?['name'] as String? ?? '';
      } on Object {
        // The test has not registered the extension yet, or it has ended.
      }
      if (name.isNotEmpty) {
        var error = '';
        try {
          await _handle(name);
        } on Object catch (exception) {
          error = '$exception';
          stderr.writeln('STORE_SHOTS failed "$name": $exception');
        }
        await driver.serviceClient.callServiceExtension(
          _completeMethod,
          isolateId: isolateId,
          args: <String, String>{'name': name, 'error': error},
        );
        if (name == _finishRequest) _finished = true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  Future<void> _handle(String name) async {
    switch (name) {
      case _setupRequest:
        await _setUpDevice();
      case _finishRequest:
        await _demo(<String>['exit']);
      default:
        if (!RegExp(r'^[a-z0-9-]+$').hasMatch(name)) {
          throw ArgumentError.value(name, 'name', 'is not a safe file name');
        }
        await _capture(name);
    }
  }

  Future<void> _setUpDevice() async {
    await adb.shell(<String>[
      'settings',
      'put',
      'global',
      'sysui_demo_allowed',
      '1',
    ]);
    await _demo(<String>['enter']);
    await _demo(<String>['clock', '-e', 'hhmm', '1200']);
    await _demo(<String>[
      'battery',
      '-e',
      'level',
      '100',
      '-e',
      'plugged',
      'false',
      '-e',
      'powersave',
      'false',
    ]);
    await _demo(<String>[
      'network',
      '-e',
      'wifi',
      'show',
      '-e',
      'level',
      '4',
      '-e',
      'fully',
      'true',
    ]);
    await _demo(<String>[
      'network',
      '-e',
      'mobile',
      'show',
      '-e',
      'datatype',
      'none',
      '-e',
      'level',
      '4',
      '-e',
      'fully',
      'true',
    ]);
    await _demo(<String>['notifications', '-e', 'visible', 'false']);
    await _demo(<String>[
      'status',
      '-e',
      'volume',
      'hide',
      '-e',
      'bluetooth',
      'hide',
      '-e',
      'location',
      'hide',
      '-e',
      'alarm',
      'hide',
      '-e',
      'sync',
      'hide',
      '-e',
      'mute',
      'hide',
      '-e',
      'speakerphone',
      'hide',
    ]);
    // Without the runtime permission the Plan tab shows its reminder banner.
    await adb.shell(<String>[
      'pm',
      'grant',
      _packageName,
      'android.permission.POST_NOTIFICATIONS',
    ]);
  }

  Future<void> _demo(List<String> command) {
    return adb.shell(<String>[
      'am',
      'broadcast',
      '-a',
      'com.android.systemui.demo',
      '-e',
      'command',
      ...command,
    ]);
  }

  Future<void> _capture(String name) async {
    final focus = await adb.shell(<String>['dumpsys', 'window', 'displays']);
    if (!focus.contains('mCurrentFocus=Window{') ||
        !RegExp('mCurrentFocus=Window\\{[^}]*$_packageName').hasMatch(focus)) {
      throw StateError('$_packageName is not the focused window');
    }
    // Two identical frames in a row: nothing is animating.
    var previous = await adb.screencap();
    for (var attempt = 0; attempt < 6; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final current = await adb.screencap();
      if (_sameBytes(previous, current)) break;
      previous = current;
    }
    final decoded = img.decodePng(previous);
    if (decoded == null) throw StateError('screencap returned no PNG');
    final rgb = _withoutAlpha(decoded);
    final file = File(p.join(output.path, '$name.png'));
    await file.writeAsBytes(img.encodePng(rgb), flush: true);
    stdout.writeln(
      'STORE_SHOTS saved ${file.path} (${rgb.width}x${rgb.height}, '
      '${rgb.numChannels} channels)',
    );
  }

  static img.Image _withoutAlpha(img.Image source) {
    final rgb = img.Image(width: source.width, height: source.height);
    for (final pixel in source) {
      final alpha = source.numChannels == 4 ? pixel.aNormalized : 1.0;
      rgb.setPixelRgb(
        pixel.x,
        pixel.y,
        (pixel.r * alpha + 255 * (1 - alpha)).round(),
        (pixel.g * alpha + 255 * (1 - alpha)).round(),
        (pixel.b * alpha + 255 * (1 - alpha)).round(),
      );
    }
    return rgb;
  }

  static bool _sameBytes(Uint8List left, Uint8List right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

final class _Adb {
  _Adb(this.executable, this.serial);

  final String executable;
  final String serial;

  Future<String> shell(List<String> arguments) async {
    final result = await Process.run(executable, <String>[
      '-s',
      serial,
      'shell',
      ...arguments,
    ]);
    if (result.exitCode != 0) {
      throw ProcessException(
        executable,
        arguments,
        '${result.stderr}',
        result.exitCode,
      );
    }
    return '${result.stdout}';
  }

  Future<Uint8List> screencap() async {
    final result = await Process.run(executable, <String>[
      '-s',
      serial,
      'exec-out',
      'screencap',
      '-p',
    ], stdoutEncoding: null);
    if (result.exitCode != 0) {
      throw ProcessException(
        executable,
        const <String>['exec-out', 'screencap', '-p'],
        '${result.stderr}',
        result.exitCode,
      );
    }
    return Uint8List.fromList(result.stdout as List<int>);
  }
}

String _adbExecutable() {
  final environment = Platform.environment;
  final explicit = environment['ADB'];
  if (explicit != null && explicit.isNotEmpty) return explicit;
  final binary = Platform.isWindows ? 'adb.exe' : 'adb';
  for (final variable in const <String>['ANDROID_HOME', 'ANDROID_SDK_ROOT']) {
    final sdk = environment[variable];
    if (sdk == null || sdk.isEmpty) continue;
    final candidate = File(p.join(sdk, 'platform-tools', binary));
    if (candidate.existsSync()) return candidate.path;
  }
  return 'adb';
}
