import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';

class _CapturingOutput extends LogOutput {
  final List<String> lines = [];

  @override
  void output(OutputEvent event) => lines.addAll(event.lines);
}

class _CountingBitwindowdAPI extends MockBitwindowdAPI {
  int blockCalls = 0;

  Object? txError;
  Duration txDelay = Duration.zero;

  /// Holds the next block answer back, so the two failures land in the other
  /// order than the tick before.
  Duration blockDelay = Duration.zero;

  @override
  Future<List<RecentTransaction>> listRecentTransactions() async {
    if (txDelay > Duration.zero) {
      await Future<void>.delayed(txDelay);
    }
    if (txError case final err?) {
      throw err;
    }
    return [];
  }

  Object? blockError;

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) async {
    blockCalls++;
    if (blockDelay > Duration.zero) {
      await Future<void>.delayed(blockDelay);
    }
    if (blockError case final err?) {
      throw err;
    }
    return (<Block>[Block(height: 7)], false);
  }
}

class _CountingAPI extends MockAPI {
  _CountingAPI() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _CountingBitwindowdAPI api = _CountingBitwindowdAPI();

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

void main() {
  late _CountingAPI rpc;
  late _CapturingOutput output;

  Future<BlockchainProvider> boot(wmpb.NodeMode mode) async {
    await GetIt.I.reset();
    output = _CapturingOutput();
    GetIt.I.registerSingleton<Logger>(Logger(output: output, level: Level.all, printer: SimplePrinter()));
    rpc = _CountingAPI()..connected = true;
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    GetIt.I.registerSingleton<BitcoindConnection>(MockBitcoindConnection());
    GetIt.I.registerSingleton<EnforcerRPC>(MockEnforcerRPC());
    GetIt.I.registerSingleton<SyncProvider>(SyncProvider(startTimer: false));
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = mode);
    return BlockchainProvider();
  }

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('blocks do not poll in light mode', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_LIGHT);
    provider.errors = ['unable to connect to Bitcoin Core'];

    await provider.fetch();

    expect(rpc.api.blockCalls, 0);
    expect(provider.errors, isEmpty);
  });

  test('a skipped poll drops the old blocks', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_FULL);
    await pumpEventQueue();
    expect(provider.blocks, isNotEmpty);

    GetIt.I.get<NodeModeProvider>().mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    await provider.fetch();

    expect(provider.blocks, isEmpty);
  });

  test('a daemon that boots leaves no error behind', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_FULL);
    await pumpEventQueue();
    rpc.api.blockError = Exception('could not list blocks: -28: Loading block index');

    await provider.fetch();

    expect(provider.errors, isEmpty);
    expect(output.lines.where((l) => l.contains('Loading block index')), isEmpty);
  });

  test('a network swap prints the next failure again', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_FULL);
    await pumpEventQueue();
    rpc.api.blockError = Exception('could not list blocks: no such column');
    await provider.fetch();
    await provider.fetch();
    expect(output.lines.where((l) => l.contains('no such column')).length, 1);

    provider.clear();
    await provider.fetch();

    expect(output.lines.where((l) => l.contains('no such column')).length, 2);
  });

  test('two failures print one time, in any order', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_FULL);
    await pumpEventQueue();
    rpc.api.blockError = Exception('could not list blocks: no such column');
    rpc.api.txError = Exception('could not list transactions: no such table');

    // The block call lands last on the first tick, and first on the second.
    rpc.api.blockDelay = const Duration(milliseconds: 20);
    await provider.fetch();
    rpc.api.blockDelay = Duration.zero;
    rpc.api.txDelay = const Duration(milliseconds: 20);
    await provider.fetch();

    expect(output.lines.where((l) => l.contains('no such column')).length, 1);
  });

  test('blocks poll in full mode', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_FULL);

    await provider.fetch();

    expect(rpc.api.blockCalls, greaterThan(0));
  });

  test('blocks do not poll while bitwindowd waits for Core', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_FULL);
    await pumpEventQueue();
    final before = rpc.api.blockCalls;

    GetIt.I.get<SyncProvider>().bitwindowdSyncInfo = SyncInfo(
      progressCurrent: 0,
      progressGoal: 967362,
      lastBlockAt: null,
      waitsForCore: true,
    );
    await provider.fetch();

    expect(rpc.api.blockCalls, before);
    expect(provider.blocks, isEmpty);
  });
}
