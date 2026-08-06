import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final output = Directory(p.join('store', 'google-play', 'screenshots'));
  await output.create(recursive: true);
  final driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (name, bytes, [arguments]) async {
      if (bytes.isEmpty) return false;
      await File(
        p.join(output.path, '$name.png'),
      ).writeAsBytes(bytes, flush: true);
      return true;
    },
    writeResponseOnFailure: true,
  );
}
