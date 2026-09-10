import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveL1Gate', () {
    test('light mode without a remote endpoint stays unavailable despite old connection state', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: false,
          remoteEnforcerAvailable: false,
          coreConnected: true,
          enforcerConnected: true,
          coming: false,
          synced: true,
          chainIsEmpty: false,
        ),
        L1Gate.unavailable,
      );
    });

    // An electrum wallet runs neither daemon, which is the case that used to
    // leave the tab showing empty tables and buttons that fail.
    test('nothing running is a stopped gate', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: true,
          remoteEnforcerAvailable: false,
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
          remoteEnforcerAvailable: false,
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
          remoteEnforcerAvailable: false,
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
          remoteEnforcerAvailable: false,
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
          remoteEnforcerAvailable: false,
          coreConnected: true,
          enforcerConnected: true,
          coming: false,
          synced: true,
          chainIsEmpty: false,
        ),
        L1Gate.ready,
      );
    });

    test('light mode waits for the remote enforcer', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: false,
          remoteEnforcerAvailable: true,
          coreConnected: false,
          enforcerConnected: false,
          coming: false,
          synced: false,
          chainIsEmpty: false,
        ),
        L1Gate.stopped,
      );
    });

    test('light mode opens without local Core after the enforcer sync', () {
      expect(
        resolveL1Gate(
          walletNeedsBackends: false,
          remoteEnforcerAvailable: true,
          coreConnected: false,
          enforcerConnected: true,
          coming: false,
          synced: true,
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
          remoteEnforcerAvailable: false,
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
          remoteEnforcerAvailable: false,
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

  // A user who reads the unavailable card must learn where light mode does
  // serve sidechains, not only that this network does not.
  group('lightSidechainNetworksLine', () {
    test('names the networks that host an enforcer', () {
      expect(
        lightSidechainNetworksLine(['Alphanet']),
        'Light mode serves sidechains on Alphanet.',
      );
      expect(
        lightSidechainNetworksLine(['Alphanet', 'signet']),
        'Light mode serves sidechains on Alphanet, signet.',
      );
    });

    test('says so when no network hosts one', () {
      expect(
        lightSidechainNetworksLine([]),
        'No network hosts an enforcer yet, so light mode serves sidechains nowhere.',
      );
    });
  });
}
