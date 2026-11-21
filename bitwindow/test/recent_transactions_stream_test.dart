import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/peers_provider.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';

class _StreamBitwindowdAPI extends MockBitwindowdAPI {
  // ignore: close_sinks, the tearDown closes it
  final frames = StreamController<WatchRecentTransactionsResponse>.broadcast();
  List<RecentTransaction> polled = [RecentTransaction(txid: 'polled')];
  int listCalls = 0;

  @override
  Stream<WatchRecentTransactionsResponse> watchRecentTransactions() => frames.stream;

  @override
  Future<List<RecentTransaction>> listRecentTransactions() async {
    listCalls++;
    return polled;
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) async => (<Block>[], false);
}

class _API extends MockAPI {
  _API() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _StreamBitwindowdAPI api = _StreamBitwindowdAPI();

  @override
  BitwindowAPI get bitwindowd => api;
}

class _OfflineTransport implements connect.Transport {
  @override
  Future<connect.UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    I input, [
    connect.CallOptions? options,
  ]) => Future.error(connect.ConnectException(connect.Code.unavailable, 'offline'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  BitcoinServiceClient get bitcoind => BitcoinServiceClient(_OfflineTransport());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WatchRecentTransactionsResponse _frame(List<String> txids) =>
    WatchRecentTransactionsResponse(transactions: [for (final id in txids) RecentTransaction(txid: id)]);

void main() {
  late _API rpc;
  late BlockchainProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = _API()..connected = true;
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    GetIt.I.registerSingleton<BitcoindConnection>(MockBitcoindConnection());
    GetIt.I.registerSingleton<EnforcerRPC>(MockEnforcerRPC());
    GetIt.I.registerSingleton<SyncProvider>(SyncProvider(startTimer: false));
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_FULL);
    GetIt.I.registerSingleton<PeersProvider>(PeersProvider());
    provider = BlockchainProvider(streamRecent: true);
    await pumpEventQueue();
  });

  tearDown(() async {
    provider.dispose();
    await rpc.api.frames.close();
    await GetIt.I.reset();
  });

  test('each frame shows at once', () async {
    expect(provider.recentTransactions.map((t) => t.txid), [
      'polled',
    ], reason: 'the poll fills the list before a frame');
    var notifies = 0;
    var providerNotifies = 0;
    provider.recentChanged.addListener(() => notifies++);
    provider.addListener(() => providerNotifies++);

    rpc.api.frames.add(_frame(['b', 'a']));
    await pumpEventQueue();
    expect(provider.recentTransactions.map((t) => t.txid), ['b', 'a']);

    rpc.api.frames.add(WatchRecentTransactionsResponse(heartbeat: true));
    rpc.api.frames.add(_frame(['c', 'b', 'a']));
    await pumpEventQueue();
    expect(provider.recentTransactions.map((t) => t.txid), ['c', 'b', 'a']);
    expect(notifies, 2, reason: 'a heartbeat changes nothing');
    expect(providerNotifies, 0, reason: 'a new tx rebuilds only what shows the list');
  });

  test('the poll does not read the list while the stream sends it', () async {
    rpc.api.frames.add(_frame(['a']));
    await pumpEventQueue();
    final calls = rpc.api.listCalls;

    await provider.fetch();
    expect(rpc.api.listCalls, calls);
    expect(provider.recentTransactions.map((t) => t.txid), ['a']);
  });

  test('a clear reads the list again until the next frame', () async {
    rpc.api.frames.add(_frame(['a']));
    await pumpEventQueue();
    provider.clear();
    final calls = rpc.api.listCalls;

    await provider.fetch();
    expect(rpc.api.listCalls, calls + 1);
    expect(provider.recentTransactions.map((t) => t.txid), ['polled']);
  });

  test('light mode stops the stream', () async {
    expect(rpc.api.frames.hasListener, isTrue);

    GetIt.I.get<NodeModeProvider>().mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    await provider.fetch();
    await pumpEventQueue();

    expect(rpc.api.frames.hasListener, isFalse);
    expect(provider.recentTransactions, isEmpty);
  });
}
