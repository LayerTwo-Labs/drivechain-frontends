import 'package:bitwindow/pages/welcome/create_another_wallet_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isWalletNameTaken', () {
    test('returns false for empty input', () {
      expect(isWalletNameTaken('', const []), false);
      expect(isWalletNameTaken('   ', const ['Main']), false);
    });

    test('returns false when no existing wallet matches', () {
      expect(isWalletNameTaken('Main', const ['Trading', 'Cold']), false);
    });

    test('returns true on exact match', () {
      expect(isWalletNameTaken('Main', const ['Main', 'Trading']), true);
    });

    test('matches case-insensitively', () {
      expect(isWalletNameTaken('main', const ['Main']), true);
      expect(isWalletNameTaken('MAIN', const ['main']), true);
    });

    test('ignores surrounding whitespace on either side', () {
      expect(isWalletNameTaken('  main  ', const ['Main']), true);
      expect(isWalletNameTaken('main', const ['  Main  ']), true);
    });
  });
}
