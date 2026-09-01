import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveCanDeposit', () {
    // The case this rule exists for. A light install starts no sidechain
    // daemon, so a gate on the daemon left the deposit button dead for good.
    test('light mode deposits with no sidechain daemon', () {
      expect(
        resolveCanDeposit(walletNeedsBackends: false, sidechainRunning: false),
        isTrue,
      );
    });

    test('full mode waits for the sidechain daemon', () {
      expect(
        resolveCanDeposit(walletNeedsBackends: true, sidechainRunning: false),
        isFalse,
      );
    });

    test('full mode deposits once the sidechain daemon answers', () {
      expect(
        resolveCanDeposit(walletNeedsBackends: true, sidechainRunning: true),
        isTrue,
      );
    });
  });
}
