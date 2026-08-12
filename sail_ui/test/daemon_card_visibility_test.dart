import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  // A wallet that runs the stack always shows both cards, running or not —
  // "not connected" is the whole point when it should be connected.
  test('a wallet that needs the daemons always shows them', () {
    expect(
      showDaemonCard(walletNeedsBackends: true, connected: false, initializing: false),
      isTrue,
    );
  });

  // Switching to an electrum wallet leaves Core and the enforcer running.
  // Hiding them then throws away the sync status the user is looking for.
  test('a running daemon stays visible on an electrum wallet', () {
    expect(
      showDaemonCard(walletNeedsBackends: false, connected: true, initializing: false),
      isTrue,
    );
    expect(
      showDaemonCard(walletNeedsBackends: false, connected: false, initializing: true),
      isTrue,
    );
  });

  // Only when there is genuinely nothing to report does the card go away.
  test('an electrum wallet with no stack hides the card', () {
    expect(
      showDaemonCard(walletNeedsBackends: false, connected: false, initializing: false),
      isFalse,
    );
  });
}
