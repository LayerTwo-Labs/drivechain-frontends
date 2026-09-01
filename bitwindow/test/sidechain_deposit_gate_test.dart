import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveCanDeposit', () {
    // The case this rule exists for. A light install starts no sidechain
    // daemon, so a gate on the daemon left the deposit button dead for good.
    test('light mode deposits to a chain that reads an index', () {
      expect(
        resolveCanDeposit(
          walletNeedsBackends: false,
          sidechainRunning: false,
          servesLightWallet: true,
        ),
        isTrue,
      );
    });

    // A chain that only proxies to its own daemon can never give an address
    // here, so the button must not offer a deposit that cannot start.
    test('light mode refuses a chain that reads no index', () {
      expect(
        resolveCanDeposit(
          walletNeedsBackends: false,
          sidechainRunning: false,
          servesLightWallet: false,
        ),
        isFalse,
      );
    });

    test('full mode waits for the sidechain daemon', () {
      expect(
        resolveCanDeposit(
          walletNeedsBackends: true,
          sidechainRunning: false,
          servesLightWallet: true,
        ),
        isFalse,
      );
    });

    test('full mode deposits once the sidechain daemon answers', () {
      expect(
        resolveCanDeposit(
          walletNeedsBackends: true,
          sidechainRunning: true,
          servesLightWallet: false,
        ),
        isTrue,
      );
    });
  });
}
