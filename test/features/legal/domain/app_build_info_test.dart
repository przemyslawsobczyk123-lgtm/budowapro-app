import 'package:budowapro/features/legal/domain/app_build_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats the public version with its monotonic build number', () {
    const info = AppBuildInfo(
      version: '1.2.3',
      buildNumber: '45',
      packageName: 'pl.budowapro',
    );

    expect(info.displayVersion, '1.2.3 (45)');
  });
}
