import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveL1Gate', () {
    // An electrum wallet runs neither daemon, which is the case that used to
    // leave the tab showing empty tables and buttons that fail.
    test('nothing running is a stopped gate', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          coreConnected: false,
          enforcerConnected: false,
          coming: false,
          synced: false,
          chainIsEmpty: false,
        ),
        L1Gate.stopped,
      );
    });

    test('half the stack still blocks', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          coreConnected: true,
          enforcerConnected: false,
          coming: false,
          synced: true,
          chainIsEmpty: false,
        ),
        L1Gate.stopped,
      );
    });

    // Starting must not offer the start button again.
    test('a boot in flight reads as starting', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          coreConnected: false,
          enforcerConnected: false,
          coming: true,
          synced: false,
          chainIsEmpty: false,
        ),
        L1Gate.starting,
      );
    });

    // Running but behind the tip is the subtle one: the tables would populate
    // with a stale view of BIP300 state.
    test('running but unsynced is not ready', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          coreConnected: true,
          enforcerConnected: true,
          coming: false,
          synced: false,
          chainIsEmpty: false,
        ),
        L1Gate.syncing,
      );
    });

    test('both up and synced opens the tab', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          coreConnected: true,
          enforcerConnected: true,
          coming: false,
          synced: true,
          chainIsEmpty: false,
        ),
        L1Gate.ready,
      );
    });

    // An electrum wallet reads BIP300 state from the hosted orchestrator, and
    // StartWithL1 is a no-op for it — gating would block a working tab behind a
    // button that cannot do anything.
    test('an electrum wallet is never gated on local daemons', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: false,
          coreConnected: false,
          enforcerConnected: false,
          coming: false,
          synced: false,
          chainIsEmpty: false,
        ),
        L1Gate.ready,
      );
    });

    // A fresh regtest node reports 0/0 forever until someone mines, and
    // SyncInfo.isSynced needs a non-zero goal — the orchestrator calls that
    // steady state (health.go), so the tab must not sit behind a sync bar.
    test('an empty regtest chain counts as synced', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          coreConnected: true,
          enforcerConnected: true,
          coming: false,
          synced: false,
          chainIsEmpty: true,
        ),
        L1Gate.ready,
      );
    });

    // Once regtest has blocks it is catching up like any other chain, so the
    // empty-chain bypass must not hand back a stale view of BIP300 state.
    test('a regtest chain with blocks still has to sync', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          coreConnected: true,
          enforcerConnected: true,
          coming: false,
          synced: false,
          chainIsEmpty: false,
        ),
        L1Gate.syncing,
      );
    });
  });
}
