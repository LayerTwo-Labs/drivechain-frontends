import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _Bmm extends ChangeNotifier implements BMMProvider {
  @override
  double maxBidAmount = 0.0002;

  @override
  int get suggestedBidSats => 188;

  @override
  bool running = false;

  @override
  bmmpb.Bid? get liveBid => null;

  int stops = 0;

  @override
  Future<void> stopBidding() async => stops++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Mode extends NodeModeProvider {
  bool get hasModeListeners => hasListeners;

  void setMode(wmpb.NodeMode value) {
    mode = value;
    notifyListeners();
  }
}

void main() {
  late _Mode mode;
  late _Bmm bmm;
  late SyncProvider sync;
  late BMMViewModel model;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    mode = _Mode()..mode = wmpb.NodeMode.NODE_MODE_FULL;
    bmm = _Bmm();
    sync = SyncProvider(startTimer: false)
      ..mainchainSyncInfo = SyncInfo(progressCurrent: 42, progressGoal: 42, lastBlockAt: null)
      ..enforcerSyncInfo = SyncInfo(progressCurrent: 42, progressGoal: 42, lastBlockAt: null)
      ..chainSourceSyncInfo = SyncInfo(progressCurrent: 42, progressGoal: 42, lastBlockAt: null);
    GetIt.I.registerSingleton<NodeModeProvider>(mode);
    GetIt.I.registerSingleton<BMMProvider>(bmm);
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<SyncProvider>(sync);
    model = BMMViewModel();
  });

  tearDown(() async {
    model.dispose();
    expect(mode.hasModeListeners, isFalse);
    sync.dispose();
    bmm.dispose();
    mode.dispose();
    await GetIt.I.reset();
  });

  test('light mode bids, and a Core outage never blocks it', () {
    var changes = 0;
    model.addListener(() => changes++);
    expect(model.canBid, isTrue);

    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(changes, 1);
    expect(model.canBid, isTrue, reason: 'light mode places an opening bid');
    expect(model.bidBlockedReason, isNull);

    sync.mainchainError = 'Core is unavailable';

    expect(model.canBid, isTrue, reason: 'a light install runs no Core to wait for');
  });

  test('full mode still waits for Core', () {
    sync.mainchainError = 'Core is unavailable';

    expect(model.canBid, isFalse);
    expect(model.bidBlockedReason, 'Waiting for Bitcoin Core');
  });

  test('light mode waits for an enforcer behind the chain source', () {
    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);
    sync.enforcerSyncInfo = SyncInfo(progressCurrent: 40, progressGoal: 40, lastBlockAt: null);

    expect(model.canBid, isFalse, reason: 'a bid on a stale tip pays for a round it cannot win');
    expect(model.bidBlockedReason, 'Enforcer is syncing — 40 of 42 blocks');
  });

  test('light mode bids with an enforcer ahead of the chain source', () {
    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);
    sync.enforcerSyncInfo = SyncInfo(progressCurrent: 43, progressGoal: 43, lastBlockAt: null);

    expect(model.bidBlockedReason, isNull, reason: 'an electrum server that trails must not stop a bid');
  });

  test('light mode waits without a chain source tip', () {
    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);
    sync.chainSourceError = 'electrum is not reachable';

    expect(model.bidBlockedReason, 'Waiting for the wallet chain source');
  });

  test('light mode says it cannot raise', () {
    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(model.isLight, isTrue);
    expect(raiseUnavailableInLightMode, contains('never raises'));
    expect(raiseUnavailableInLightMode, contains('reads no rival bid'));
  });

  test('light mode reports the bid state, not a pause', () async {
    bmm.running = true;
    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(model.running, isTrue);
    expect(model.slotStatus, 'Assembling');
    await model.stopBidding();
    expect(bmm.stops, 1);
  });
}
