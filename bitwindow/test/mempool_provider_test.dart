import 'package:bitwindow/providers/mempool_provider.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';

class _Transport implements connect.Transport {
  Map<String, MempoolEntry> mempool = {};
  int mempoolCalls = 0;

  @override
  Future<connect.UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    I input, [
    connect.CallOptions? options,
  ]) async {
    final Object out;
    if (input is GetRawMempoolRequest) {
      mempoolCalls++;
      out = GetRawMempoolResponse(transactions: mempool.entries);
    } else if (input is EstimateSmartFeeRequest) {
      out = EstimateSmartFeeResponse(feeRate: input.confTarget.toInt() == 144 ? 0 : 0.00002);
    } else {
      throw UnimplementedError('$input');
    }
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

MempoolEntry _tx(int vsize, double feeSats) => MempoolEntry(
  virtualSize: vsize,
  fees: MempoolEntry_Fees(base: feeSats),
);

void main() {
  late _Transport transport;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BitwindowRPC>(MockAPI(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD)..connected = true);
    transport = _Transport();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator(transport));
  });

  tearDown(() => GetIt.I.reset());

  test('the mempool is not read before a widget listens', () async {
    final provider = MempoolProvider();
    await pumpEventQueue();
    expect(transport.mempoolCalls, 0);

    void listener() {}
    provider.addListener(listener);
    await pumpEventQueue();
    expect(transport.mempoolCalls, 1);
    provider.removeListener(listener);
  });

  test('the stats hold the buckets, the median and the estimates', () async {
    transport.mempool = {'a': _tx(100, 50), 'b': _tx(100, 300), 'c': _tx(200, 600), 'd': _tx(100, 15000)};
    final provider = MempoolProvider();

    await provider.fetch();

    final stats = provider.stats;
    expect(stats.txCount, 4);
    expect(stats.totalVsize, 500);
    expect(stats.totalFees, 15950);
    expect(stats.medianFeeRate, 3);
    expect(
      [for (final b in stats.feeBuckets) '${b.label}:${b.txCount}:${b.totalVsize}:${b.totalFees}'],
      [
        '0-1:1:100:50.0',
        '2-5:2:300:900.0',
        '100+:1:100:15000.0',
      ],
    );
    expect([for (final e in stats.feeEstimates) e.blocks], [1, 3, 6, 12, 24]);
    expect(stats.feeEstimates.first.feeRate, closeTo(2, 1e-9));
  });

  test('a fetch with the same mempool does not notify', () async {
    transport.mempool = {'a': _tx(100, 300)};
    final provider = MempoolProvider();
    await provider.fetch();
    var notified = 0;
    provider.addListener(() => notified++);
    await pumpEventQueue();

    await provider.fetch();
    expect(notified, 0);

    transport.mempool = {'a': _tx(100, 300), 'b': _tx(100, 900)};
    await provider.fetch();
    expect(notified, 1);
  });
}
