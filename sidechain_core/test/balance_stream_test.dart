import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _StreamedMainchain extends MockBitwindowRPC {
  final frames = StreamController<wmpb.WatchBalanceResponse>();
  int calls = 0;
  Completer<(double, double, double)>? pending;

  @override
  BalanceStream get balanceStream => BalanceStream(subscribe: () => frames.stream, onTransportDeath: () {});

  @override
  Future<(double, double, double)> balances() {
    calls++;
    return pending?.future ?? Future.value((1.0, 0.0, 0.0));
  }

  @override
  void dispose() {
    unawaited(frames.close());
    super.dispose();
  }
}

wmpb.WatchBalanceResponse _frame(double confirmedSats, {double immatureSats = 0}) => wmpb.WatchBalanceResponse(
  walletId: 'w',
  balance: wmpb.GetBalanceResponse(confirmedSats: confirmedSats, immatureSats: immatureSats),
);

void main() {
  late _StreamedMainchain mainchain;
  late BalanceProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BinaryProvider>(MockBinaryProvider());
    mainchain = _StreamedMainchain()..setConnected(true);
    provider = BalanceProvider(connections: [mainchain]);
    await pumpEventQueue();
    mainchain.calls = 0;
  });

  tearDown(() async {
    provider.dispose();
    mainchain.dispose();
    await GetIt.I.reset();
  });

  test('a frame sets the balance at once', () async {
    var notified = 0;
    provider.addListener(() => notified++);

    mainchain.frames.add(_frame(2e8, immatureSats: 5e7));
    await pumpEventQueue();

    expect(provider.balance, 2.0);
    expect(provider.maturingBalance, 0.5);
    expect(notified, 1);
  });

  test('a poll reads no RPC while the stream is up', () async {
    await provider.poll();
    expect(mainchain.calls, 1);

    mainchain.frames.add(_frame(2e8));
    await pumpEventQueue();
    await provider.poll();
    await provider.fetch();
    expect(mainchain.calls, 1);
    expect(provider.balance, 2.0);
  });

  test('a frame wins over a read that was in flight', () async {
    mainchain.pending = Completer();
    final poll = provider.poll();
    await pumpEventQueue();

    mainchain.frames.add(_frame(3e8));
    await pumpEventQueue();
    mainchain.pending!.complete((1.0, 0.0, 0.0));
    await poll;

    expect(provider.balance, 3.0);
  });

  test('a cleared balance comes back from the last frame', () async {
    mainchain.frames.add(_frame(2e8));
    await pumpEventQueue();
    provider.clear();
    expect(provider.balance, 0.0);

    await provider.poll();
    expect(provider.balance, 2.0);
    expect(mainchain.calls, 0);
  });

  test('a frame with no wallet leaves the balance to the poll', () async {
    mainchain.frames.add(_frame(2e8));
    await pumpEventQueue();
    mainchain.frames.add(wmpb.WatchBalanceResponse());
    await pumpEventQueue();

    await provider.poll();
    expect(mainchain.calls, 1);
  });

  test('a network change drops the last frame', () async {
    mainchain.frames.add(_frame(2e8));
    await pumpEventQueue();
    await provider.onNetworkChanged();

    await provider.poll();
    expect(mainchain.calls, 1);
    expect(provider.balance, 1.0);
  });
}
