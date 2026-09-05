import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  group('transactionCount', () {
    test('names an empty block, one transaction, and many', () {
      expect(transactionCount(0), 'No transactions');
      expect(transactionCount(1), '1 transaction');
      expect(transactionCount(4), '4 transactions');
    });
  });

  group('explorerAge', () {
    int agoBy(Duration back) => DateTime.now().subtract(back).millisecondsSinceEpoch ~/ 1000;

    test('a block with no time reads empty', () {
      expect(explorerAge(0), '');
      expect(explorerAge(-1), '');
    });

    test('reads minutes, hours and days', () {
      expect(explorerAge(agoBy(const Duration(seconds: 20))), 'just now');
      expect(explorerAge(agoBy(const Duration(minutes: 1, seconds: 5))), '1 minute ago');
      expect(explorerAge(agoBy(const Duration(minutes: 34))), '34 minutes ago');
      expect(explorerAge(agoBy(const Duration(hours: 1, minutes: 2))), '1 hour ago');
      expect(explorerAge(agoBy(const Duration(hours: 9))), '9 hours ago');
      expect(explorerAge(agoBy(const Duration(days: 2, hours: 3))), '2 days ago');
    });
  });

  group('ageRefreshDue', () {
    final now = DateTime(2026, 9, 5, 12, 0);

    test('a quiet chain redraws once a minute', () {
      expect(ageRefreshDue(now.subtract(const Duration(seconds: 30)), now), isFalse);
      expect(ageRefreshDue(now.subtract(const Duration(minutes: 1)), now), isTrue);
      expect(ageRefreshDue(now.subtract(const Duration(hours: 2)), now), isTrue);
    });
  });
}
