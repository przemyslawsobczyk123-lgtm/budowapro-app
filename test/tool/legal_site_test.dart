import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const publicOrigin = 'https://budowaproapp.pl';
  const contactEmail = 'kontakt@budowaproapp.pl';

  test('custom domain and sitemap point to the production origin', () {
    expect(_read('site/CNAME').trim(), 'budowaproapp.pl');

    final robots = _read('site/robots.txt');
    final sitemap = _read('site/sitemap.xml');
    expect(robots, contains('$publicOrigin/sitemap.xml'));
    for (final path in <String>[
      '/',
      '/privacy/',
      '/terms/',
      '/support/',
      '/data-deletion/',
    ]) {
      expect(sitemap, contains('<loc>$publicOrigin$path</loc>'));
    }
  });

  test('public pages use canonical production URLs and one support email', () {
    final pages = <String, String>{
      'site/index.html': '$publicOrigin/',
      'site/privacy/index.html': '$publicOrigin/privacy/',
      'site/terms/index.html': '$publicOrigin/terms/',
      'site/support/index.html': '$publicOrigin/support/',
      'site/data-deletion/index.html': '$publicOrigin/data-deletion/',
    };

    for (final entry in pages.entries) {
      final html = _read(entry.key);
      expect(html, contains('rel="canonical" href="${entry.value}"'));
      expect(html, contains(contactEmail));
      expect(html, isNot(contains('@gmail.com')));
    }
  });

  test('privacy policy includes Google Play disclosure essentials', () {
    final policy = _read('site/privacy/index.html');

    for (final requiredText in <String>[
      'Polityka prywatności',
      'Wydawca i administrator korespondencji:',
      'Przemysław Sobczyk',
      'NIP 6443558164',
      'administratorem danych',
      'Dane przechowywane lokalnie',
      'Google ML Kit',
      'Uprawnienia urządzenia',
      'Przechowywanie i usuwanie',
      'Bezpieczeństwo',
      'kontakt@budowaproapp.pl',
    ]) {
      expect(policy, contains(requiredText));
    }
  });

  test('terms identify the legal provider without a private email', () {
    final terms = _read('site/terms/index.html');

    expect(terms, contains('Przemysław Sobczyk'));
    expect(terms, contains('NIP 6443558164'));
    expect(terms, contains('kontakt@budowaproapp.pl'));
    expect(terms, isNot(contains('@gmail.com')));
  });

  test('deletion page accurately explains the local no-account flow', () {
    final deletion = _read('site/data-deletion/index.html');
    final normalized = deletion.toLowerCase();

    expect(normalized, contains('nie tworzy kont użytkowników'));
    expect(deletion, contains('Usuń wszystkie dane BudowaPRO'));
    expect(normalized, contains('wydawca nie posiada zdalnej kopii'));
  });
}

String _read(String path) => File(path).readAsStringSync();
