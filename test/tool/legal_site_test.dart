import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const publicOrigin = 'https://budowaproapp.pl';
  const contactEmail = 'kontakt@budowaproapp.pl';
  const providerAddress = 'Przygraniczna 40, 41-203 Sosnowiec';

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
    final normalizedPolicy = policy.replaceAll(RegExp(r'\s+'), ' ');

    for (final requiredText in <String>[
      'Polityka prywatności',
      'Administrator korespondencji:',
      'Przemysław Sobczyk',
      'NIP 6443558164',
      'administratorem danych',
      'Dane przechowywane lokalnie',
      'Google ML Kit',
      'Uprawnienia urządzenia',
      'adres IP',
      'odwiedzone podstrony',
      'niezależny administrator',
      'Podstawy prawne',
      'art. 6 ust. 1 lit. b RODO',
      'art. 6 ust. 1 lit. f RODO',
      'Korespondencja i wsparcie',
      'Odbiorcy danych',
      'Przekazywanie poza EOG',
      'standardowe klauzule umowne',
      'kopię zabezpieczeń',
      'Przechowywanie i usuwanie',
      'ograniczenia przetwarzania',
      'wniesienia sprzeciwu',
      'Bezpieczeństwo',
      'kontakt@budowaproapp.pl',
    ]) {
      expect(
        normalizedPolicy.toLowerCase(),
        contains(requiredText.toLowerCase()),
      );
    }
  });

  test('terms cover the statutory electronic-service essentials', () {
    final terms = _read('site/terms/index.html');
    final normalized = terms.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    for (final requiredText in <String>[
      'Regulamin świadczenia usług drogą elektroniczną',
      'Przemysław Sobczyk',
      'NIP 6443558164',
      providerAddress,
      'kontakt@budowaproapp.pl',
      'Rodzaje i zakres usług',
      'Wymagania techniczne i zagrożenia',
      'Zawarcie i rozwiązanie umowy',
      'Reklamacje',
      '14 dni',
      'ustawowych praw konsumenta',
    ]) {
      expect(terms, contains(requiredText));
    }
    expect(
      normalized,
      contains('zakazane jest dostarczanie treści o charakterze bezprawnym'),
    );
    expect(terms, isNot(contains('@gmail.com')));
  });

  test('all public pages use a restrictive static-site security baseline', () {
    for (final path in <String>[
      'site/index.html',
      'site/privacy/index.html',
      'site/terms/index.html',
      'site/support/index.html',
      'site/data-deletion/index.html',
      'site/404.html',
    ]) {
      final html = _read(path);
      expect(html, contains('http-equiv="Content-Security-Policy"'));
      expect(html, contains("default-src 'none'"));
      expect(html, contains('name="referrer" content="no-referrer"'));
      expect(html, isNot(contains('<script')));
      expect(html, isNot(contains('<form')));
      expect(html.toLowerCase(), isNot(contains('google-analytics')));
    }
  });

  test('deletion page accurately explains the local no-account flow', () {
    final deletion = _read('site/data-deletion/index.html');
    final normalized = deletion.toLowerCase();

    expect(normalized, contains('nie tworzy kont użytkowników'));
    expect(deletion, contains('Usuń wszystkie dane BudowaPRO'));
    expect(normalized, contains('wydawca nie posiada zdalnej kopii'));
  });

  test('store declaration contains final ML Kit Data safety answers', () {
    final declaration = _read('store/privacy/store-declarations.md');

    for (final requiredText in <String>[
      'Odpowiedzi do formularza Google Play Data safety',
      'App activity > App interactions',
      'App info and performance > Diagnostics',
      'Device or other IDs > Device or other IDs',
      'Collected: Yes',
      'Shared: No',
      'Purpose: Analytics',
      'Required: No',
      'Encrypted in transit: Yes',
    ]) {
      expect(declaration, contains(requiredText));
    }
    expect(declaration, isNot(contains('Kategorie do sprawdzenia')));
    expect(declaration, isNot(contains('Możliwe zaszyfrowane metryki')));
  });
}

String _read(String path) => File(path).readAsStringSync();
