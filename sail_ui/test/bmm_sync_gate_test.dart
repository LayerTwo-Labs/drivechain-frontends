import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sidechain_core/sidechain_core.dart';

SyncInfo _info(int blocks, int headers) =>
    SyncInfo(progressCurrent: blocks.toDouble(), progressGoal: headers.toDouble(), lastBlockAt: null);

void main() {
  late SyncProvider sync;

  setUp(() {
    sync = SyncProvider(startTimer: false);
    sync.mainchainSyncInfo = _info(8725, 8725);
  });

  test('bidding unlocks once the enforcer is level with core', () {
    sync.enforcerSyncInfo = _info(8725, 8725);
    expect(bidBlockedReasonFor(sync), isNull);
  });

  // Without Core the orchestrator reports the enforcer's goal as its own
  // height, so it reads as synced however far behind it is.
  test('bidding is blocked when bitcoin core is unavailable', () {
    sync.enforcerSyncInfo = _info(4000, 4000);
    sync.mainchainError = 'not running';
    expect(bidBlockedReasonFor(sync), 'Waiting for Bitcoin Core');
  });

  test('bidding is blocked before core reports a height', () {
    sync.mainchainSyncInfo = null;
    sync.enforcerSyncInfo = _info(8725, 8725);
    expect(bidBlockedReasonFor(sync), 'Waiting for Bitcoin Core');
  });

  test('bidding is blocked while the enforcer trails core', () {
    sync.enforcerSyncInfo = _info(4000, 8725);
    expect(bidBlockedReasonFor(sync), 'Enforcer is syncing — 4000 of 8725 blocks');
  });

  test('bidding is blocked before any height is known', () {
    sync.enforcerSyncInfo = _info(0, 0);
    expect(bidBlockedReasonFor(sync), isNotNull);
  });

  test('bidding is blocked when the enforcer is not running', () {
    sync.enforcerSyncInfo = _info(8725, 8725);
    sync.enforcerError = 'not running';
    expect(bidBlockedReasonFor(sync), 'Waiting for the enforcer to start');
  });

  test('bidding is blocked before the first poll lands', () {
    expect(bidBlockedReasonFor(sync), 'Waiting for the enforcer to start');
  });
}
