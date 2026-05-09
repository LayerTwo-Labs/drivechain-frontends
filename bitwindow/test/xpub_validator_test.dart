import 'package:bitwindow/pages/welcome/create_another_wallet_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isPlausibleXpubOrDescriptor', () {
    test('rejects empty string', () {
      expect(isPlausibleXpubOrDescriptor(''), false);
      expect(isPlausibleXpubOrDescriptor('   '), false);
    });

    test('rejects free-form text without parentheses', () {
      expect(isPlausibleXpubOrDescriptor('hello world'), false);
      expect(isPlausibleXpubOrDescriptor('not-an-xpub'), false);
    });

    test('accepts a real-shape xpub', () {
      const xpub =
          'xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz';
      expect(isPlausibleXpubOrDescriptor(xpub), true);
    });

    test('accepts wpkh descriptor', () {
      expect(isPlausibleXpubOrDescriptor('wpkh(xpub.../0/*)'), true);
    });

    test('accepts wsh multi descriptor', () {
      expect(isPlausibleXpubOrDescriptor('wsh(multi(2,xpub1,xpub2))'), true);
    });

    test('trims surrounding whitespace before validating', () {
      expect(
        isPlausibleXpubOrDescriptor('   wpkh(xpub.../0/*)   '),
        true,
      );
    });
  });
}
