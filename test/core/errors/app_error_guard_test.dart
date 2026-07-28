import 'package:budowapro/core/errors/app_error_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production diagnostic never includes private exception contents', () {
    const privateValue =
        r'C:\private\Jan Kowalski\paragon-123.pdf, telefon 500600700';

    final diagnostic = AppErrorGuard.diagnosticFor(
      StateError(privateValue),
      releaseMode: true,
    );

    expect(diagnostic, AppErrorGuard.productionDiagnostic);
    expect(diagnostic, isNot(contains('Jan Kowalski')));
    expect(diagnostic, isNot(contains('500600700')));
    expect(diagnostic, isNot(contains('paragon-123.pdf')));
  });

  test('development diagnostic keeps only the exception type', () {
    final diagnostic = AppErrorGuard.diagnosticFor(
      StateError(r'C:\private\Jan Kowalski\database.db'),
      releaseMode: false,
    );

    expect(diagnostic, contains('StateError'));
    expect(diagnostic, isNot(contains('Jan Kowalski')));
    expect(diagnostic, isNot(contains('database.db')));
  });
}
