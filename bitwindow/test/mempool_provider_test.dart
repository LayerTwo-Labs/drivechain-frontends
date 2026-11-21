import 'package:bitwindow/providers/mempool_provider.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sidechain_core/gen/mempool/v1/mempool.connect.client.dart';
import 'package:sidechain_core/gen/mempool/v1/mempool.pb.dart' as mempoolpb;
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';

/// Answers as drivechaind does: a plain getrawmempool holds txids only, and
/// GetStats sums the mempool in sats.
class _Transport implements connect.Transport {
  Map<String, (int vsize, int feeSats)> mempool = {};
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
      out = GetRawMempoolResponse(txids: mempool.keys);
    } else if (input is mempoolpb.GetStatsRequest) {
      mempoolCalls++;
      out = _stats(input.bucketEdges);
    } else if (input is EstimateSmartFeeRequest) {
      out = EstimateSmartFeeResponse(feeRate: input.confTarget.toInt() == 144 ? 0 : 0.00002);
    } else {
      throw UnimplementedError('$input');
    }
    return connect.UnaryResponse(spec, connect.Headers(), out as O, connect.Headers());
  }

  mempoolpb.GetStatsResponse _stats(List<double> edges) {
    final res = mempoolpb.GetStatsResponse(
      buckets: [for (final e in edges) mempoolpb.FeeBucket(minFeeRate: e)],
    );
    final rates = <double>[];
    for (final (vsize, fee) in mempool.values) {
      final rate = fee / vsize;
      rates.add(rate);
      res.txCount += 1;
      res.vsize += vsize;
      res.feeSats += fee;
      final b = res.buckets.lastWhere((b) => b.minFeeRate <= rate);
      b.txCount += 1;
      b.vsize += vsize;
      b.feeSats += fee;
    }
    rates.sort();
    res.medianFeeRate = rates.isEmpty ? 0 : rates[rates.length ~/ 2];
    return res;
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
  MempoolServiceClient get mempool => MempoolServiceClient(transport);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

(int, int) _tx(int vsize, int feeSats) => (vsize, feeSats);

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

  test('a stream frame shows at once and keeps the estimates', () async {
    transport.mempool = {'a': _tx(100, 300)};
    final provider = MempoolProvider();
    await provider.fetch();
    var notified = 0;
    provider.addListener(() => notified++);
    await pumpEventQueue();
    final calls = transport.mempoolCalls;

    transport.mempool = {'a': _tx(100, 300), 'b': _tx(100, 900)};
    provider.applyFrame(mempoolpb.WatchStatsResponse(stats: transport._stats([0, 1, 2, 5, 10, 20, 50, 100])));
    expect(notified, 1);
    expect(provider.stats.txCount, 2);
    expect(provider.stats.feeEstimates, isNotEmpty);

    provider.applyFrame(mempoolpb.WatchStatsResponse(heartbeat: true));
    expect(notified, 1);
    expect(transport.mempoolCalls, calls, reason: 'a frame reads nothing');
  });
}
