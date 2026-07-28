import 'dart:io';

import 'package:image/image.dart' as image;
import 'package:path/path.dart' as p;

const _maximumPlayIconBytes = 1024 * 1024;

Future<void> main() async {
  final source = File(
    p.join('assets', 'branding', 'budowapro_launcher_icon.png'),
  );
  final target = File(p.join('assets', 'store', 'google-play-icon-512.png'));
  if (!await source.exists()) {
    throw StateError('BudowaPRO launcher icon is missing.');
  }
  final decoded = image.decodePng(await source.readAsBytes());
  if (decoded == null) {
    throw StateError('BudowaPRO launcher icon is not a valid PNG.');
  }
  final resized = image.copyResize(
    decoded,
    width: 512,
    height: 512,
    interpolation: image.Interpolation.cubic,
  );
  final encoded = image.encodePng(resized, level: 9);
  if (encoded.length > _maximumPlayIconBytes) {
    throw StateError('Generated Google Play icon exceeds 1 MB.');
  }
  await target.parent.create(recursive: true);
  await target.writeAsBytes(encoded, flush: true);
  stdout.writeln('Generated ${target.path}: 512x512, ${encoded.length} bytes.');
}
