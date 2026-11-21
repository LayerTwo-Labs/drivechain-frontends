import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:bitwindow/providers/peers_provider.dart';
import 'package:bitwindow/widgets/peer_count.dart';
import 'package:bitwindow/widgets/traffic_graph_widget.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sidechain_core/sidechain_core.dart';

import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _Transport implements connect.Transport {
  final calls = <String, int>{};
  int connections = 0;
  List<Peer> peers = [];

  @override
  Future<connect.UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    I input, [
    connect.CallOptions? options,
  ]) async {
    calls.update(spec.procedure.split('/').last, (n) => n + 1, ifAbsent: () => 1);
    final Object out = switch (input) {
      GetPeerInfoRequest() => GetPeerInfoResponse(peers: peers),
      GetNetworkInfoRequest() => GetNetworkInfoResponse(connections: connections),
      _ => throw UnimplementedError('$input'),
    };
    return connect.UnaryResponse(spec, connect.Headers(), out as O, connect.Headers());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  _Orchestrator(this.transport);

  final _Transport transport;

  @override
  BitcoinServiceClient get bitcoind => BitcoinServiceClient(transport);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StatsAPI extends MockBitwindowdAPI {
  int statsCalls = 0;

  @override
  Future<GetNetworkStatsResponse> getNetworkStats() async {
    statsCalls++;
    return GetNetworkStatsResponse();
  }
}

class _API extends MockAPI {
  _API() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _StatsAPI api = _StatsAPI();

  @override
  BitwindowAPI get bitwindowd => api;
}

class _IdlePeers extends ChangeNotifier implements PeersProvider {
  @override
  bool get polling => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Transport transport;
  late _API rpc;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = _API()..connected = true;
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    transport = _Transport();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator(transport));
  });

  tearDown(() => GetIt.I.reset());

  test('network stats are not read before a widget listens', () async {
    final provider = NetworkProvider();
    rpc.notifyListeners();
    await provider.fetch();
    expect(rpc.api.statsCalls, 0);

    void listener() {}
    provider.addListener(listener);
    await pumpEventQueue();
    expect(rpc.api.statsCalls, 1);

    provider.removeListener(listener);
    await provider.fetch();
    expect(rpc.api.statsCalls, 1);
  });

  test('the traffic graph fills the intervals of a pause at the mean rate', () {
    final provider = NetworkProvider();
    final start = DateTime(2026, 11, 20, 12);
    provider.addSample(start, 0, 0);
    provider.addSample(start.add(const Duration(seconds: 5)), 5000, 500);
    provider.addSample(start.add(const Duration(seconds: 65)), 65000, 6500);

    final history = provider.bandwidthHistory;
    expect(history, hasLength(14));
    for (var i = 1; i < history.length; i++) {
      expect(history[i].time.difference(history[i - 1].time), NetworkProvider.sampleInterval);
      expect(history[i].rxBytesPerSec, closeTo(1000, 0.001));
      expect(history[i].txBytesPerSec, closeTo(100, 0.001));
    }
  });

  test('a long pause keeps at most one graph of points', () {
    final provider = NetworkProvider();
    final start = DateTime(2026, 11, 20, 12);
    provider.addSample(start, 0, 0);
    provider.addSample(start.add(const Duration(hours: 1)), 3600, 0);

    final history = provider.bandwidthHistory;
    expect(history, hasLength(NetworkProvider.maxDataPoints));
    expect(history.last.time, start.add(const Duration(hours: 1)));
    expect(history.last.rxBytesPerSec, closeTo(1, 0.001));
  });

  test('the status bar peer count reads no peer list', () async {
    transport.connections = 8;
    GetIt.I.registerSingleton<BitcoindConnection>(MockBitcoindConnection());
    GetIt.I.registerSingleton<EnforcerRPC>(MockEnforcerRPC());
    GetIt.I.registerSingleton<SyncProvider>(SyncProvider(startTimer: false));
    GetIt.I.registerSingleton<PeersProvider>(_IdlePeers());
    final provider = BlockchainProvider();
    await pumpEventQueue();

    expect(provider.peerCount, 8);
    expect(transport.calls['GetPeerInfo'], isNull);
  });

  test('a shown peer list gives the peer count with no network info read', () async {
    transport.peers = [Peer(id: 1), Peer(id: 2)];
    GetIt.I.registerSingleton<BitcoindConnection>(MockBitcoindConnection());
    GetIt.I.registerSingleton<EnforcerRPC>(MockEnforcerRPC());
    GetIt.I.registerSingleton<SyncProvider>(SyncProvider(startTimer: false));
    final peers = PeersProvider()..addListener(() {});
    GetIt.I.registerSingleton<PeersProvider>(peers);
    await pumpEventQueue();
    final provider = BlockchainProvider();
    await pumpEventQueue();

    expect(provider.peerCount, 2);
    expect(transport.calls['GetNetworkInfo'], isNull);
  });

  test('the peer list is read once at start and then only while a widget listens', () async {
    transport.peers = [Peer(id: 1, addr: '10.0.0.1:8333')];
    final provider = PeersProvider();
    await pumpEventQueue();
    expect(transport.calls['GetPeerInfo'], 1);
    expect(provider.peers.single.addr, '10.0.0.1:8333');

    void listener() {}
    provider.addListener(listener);
    await pumpEventQueue();
    expect(transport.calls['GetPeerInfo'], 2);
    provider.removeListener(listener);
  });

  testWidgets('a hover reads the peer list before the tooltip shows', (tester) async {
    final peers = PeersProvider();
    GetIt.I.registerSingleton<PeersProvider>(peers);
    await tester.pumpSailPage(const PeerCount(count: 1));
    expect(transport.calls['GetPeerInfo'], 1);

    transport.peers = [Peer(id: 2, addr: '10.0.0.2:8333')];
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('1 peer')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 200));

    expect(transport.calls['GetPeerInfo'], 2);
    expect(find.text('Peer id=2 addr=10.0.0.2:8333'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(seconds: 2));
    await peers.fetch();
    await tester.pump();
    expect(transport.calls['GetPeerInfo'], 3);
  });

  testWidgets('a hidden traffic graph reads no network stats', (tester) async {
    GetIt.I.registerSingleton<NetworkProvider>(NetworkProvider());
    final shown = ValueNotifier(false);
    await tester.pumpSailPage(
      ValueListenableBuilder(
        valueListenable: shown,
        builder: (_, on, _) => TickerMode(enabled: on, child: const TrafficGraphWidget()),
      ),
    );
    expect(rpc.api.statsCalls, 0);

    shown.value = true;
    await tester.pump();
    expect(rpc.api.statsCalls, 1);
  });
}
