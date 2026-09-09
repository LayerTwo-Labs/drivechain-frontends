import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _Bmm extends ChangeNotifier implements BMMProvider {
  @override
  double maxBidAmount = 0.0002;

  @override
  int get suggestedBidSats => 188;

  @override
  bool running = false;

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
      ..enforcerSyncInfo = SyncInfo(progressCurrent: 42, progressGoal: 42, lastBlockAt: null);
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

  test('a mode change blocks bids even when Core and the enforcer are ready', () {
    var changes = 0;
    model.addListener(() => changes++);
    expect(model.canBid, isTrue);

    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(changes, 1);
    expect(model.canBid, isFalse);
    expect(model.bidBlockedReason, 'BMM is unavailable in light mode');

    mode.setMode(wmpb.NodeMode.NODE_MODE_FULL);

    expect(changes, 2);
    expect(model.canBid, isTrue);
  });

  test('light mode states the BMM limit before a Core connection error', () {
    sync.mainchainError = 'Core is unavailable';
    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(model.bidBlockedReason, 'BMM is unavailable in light mode');
  });

  test('light mode pauses a saved target and permits Stop', () async {
    bmm.running = true;
    mode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(model.running, isTrue);
    expect(model.canBid, isFalse);
    expect(model.slotStatus, 'Paused');
    await model.stopBidding();
    expect(bmm.stops, 1);
  });
}
