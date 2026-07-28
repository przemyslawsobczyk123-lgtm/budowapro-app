import 'dart:io';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/check_privacy_policy_url.dart <https-url>',
    );
    exitCode = 64;
    return;
  }

  final uri = Uri.tryParse(arguments.single);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    stderr.writeln('Privacy policy URL must be an absolute HTTPS URL.');
    exitCode = 64;
    return;
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'text/html');
    final response = await request.close().timeout(const Duration(seconds: 15));
    final contentType = response.headers.contentType?.mimeType;
    await response.drain<void>();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      stderr.writeln('Privacy policy returned HTTP ${response.statusCode}.');
      exitCode = 1;
      return;
    }
    if (contentType != 'text/html') {
      stderr.writeln(
        'Privacy policy must return text/html, got ${contentType ?? "none"}.',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln('Privacy policy URL is public HTTPS HTML.');
  } on Object catch (error) {
    stderr.writeln('Privacy policy URL check failed: $error');
    exitCode = 1;
  } finally {
    client.close(force: true);
  }
}
