import 'package:budowapro/features/contacts/data/contact_action_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds encoded phone and e-mail system actions', () async {
    final launched = <Uri>[];
    final gateway = UrlLauncherContactActionGateway(
      launcher: (uri) async {
        launched.add(uri);
        return true;
      },
    );

    await gateway.call('+48 500 600 700');
    await gateway.email('biuro@example.pl');

    expect(launched[0].scheme, 'tel');
    expect(launched[0].path, '+48500600700');
    expect(launched[1], Uri(scheme: 'mailto', path: 'biuro@example.pl'));
  });

  test('reports a missing system handler', () async {
    final gateway = UrlLauncherContactActionGateway(
      launcher: (_) async => false,
    );

    await expectLater(
      gateway.call('+48500600700'),
      throwsA(isA<ContactActionUnavailableException>()),
    );
  });
}
