import 'package:bitwindow/providers/mempool_watch_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/google/protobuf/timestamp.pb.dart';
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

const _tip = 500;

class _FakeBitwindowd extends MockBitwindowdAPI {
  final List<MempoolTransaction> pending;
  final List<MempoolTransaction> history;
  final List<ListMempoolTransactionsRequest> requests = [];
  int statsRequests = 0;

  _FakeBitwindowd({required this.pending, required this.history});

  @override
  Future<GetMempoolWatchStatusResponse> getMempoolWatchStatus() async {
    return GetMempoolWatchStatusResponse(enabled: true, running: true, tipHeight: _tip);
  }

  /// Every block collected 4 BTC, so F* = 4 sat/vB, with a floor of 3.
  @override
  Future<List<BlockStats>> listBlockStats(int fromHeight, int toHeight) async {
    statsRequests++;
    return [
      for (var h = fromHeight; h <= toHeight; h++) BlockStats(height: h, minFeeRate: 3, totalFeeSats: Int64(4000000)),
    ];
  }

  @override
  Future<ListMempoolTransactionsResponse> listMempoolTransactions(ListMempoolTransactionsRequest request) async {
    requests.add(request);
    final source = request.status == MempoolTxStatus.MEMPOOL_TX_STATUS_PENDING ? pending : history;
    final matching = source.where((tx) => request.minFeeRate == 0 || tx.feeRate > request.minFeeRate).toList();
    final page = matching.skip(request.offset).take(request.limit).toList();
    return ListMempoolTransactionsResponse(transactions: page, total: Int64(matching.length), tipHeight: _tip);
  }
}

class _FakeApi extends MockAPI {
  @override
  final BitwindowAPI bitwindowd;

  _FakeApi(this.bitwindowd) : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD) {
    connected = true;
  }
}

MempoolTransaction tx(String txid, double feeRate, int blocksWaited, {int? resolvedHeight}) {
  return MempoolTransaction(
    txid: txid,
    hasDetails: true,
    feeRate: feeRate,
    firstSeenHeight: (resolvedHeight ?? _tip) - blocksWaited,
    resolvedHeight: resolvedHeight,
    firstSeen: Timestamp.fromDateTime(DateTime.utc(2026, 1, 1)),
  );
}

/// Listening and every setter kick off a fetch; wait for it to land.
Future<void> settled(MempoolWatchProvider provider) async {
  while (provider.isFetching) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<MempoolWatchProvider> _providerAgainst(_FakeBitwindowd fake) async {
  await registerTestDependencies();
  if (GetIt.I.isRegistered<BitwindowRPC>()) {
    await GetIt.I.unregister<BitwindowRPC>();
  }
  GetIt.I.registerSingleton<BitwindowRPC>(_FakeApi(fake));
  final provider = MempoolWatchProvider();
  provider.addListener(() {});
  await settled(provider);
  return provider;
}

void main() {
  testWidgets('pending view loads every candidate above F* and ranks by score', (tester) {
    return tester.runAsync(() async {
      final pending = [
        for (var i = 0; i < 1200; i++) tx('c$i', 5 + (i % 7), 1 + i % 50),
        tx('cheap', 2, 300),
        tx('star', 12, 90),
      ];
      final fake = _FakeBitwindowd(pending: pending, history: []);
      final provider = await _providerAgainst(fake);

      expect(provider.referenceFeeRate, closeTo(4, 1e-9));
      expect(fake.statsRequests, 1);
      expect(fake.requests.where((r) => r.minFeeRate == 4).length, 3, reason: 'three pages of 500');
      expect(provider.total, 1201);
      expect(provider.rows.length, 1201);
      expect(provider.rows.first.txid, 'star');
      expect(provider.waited(provider.rows.first), 90);
      expect(provider.eligible(provider.rows.first), 90, reason: 'every block floor was 3');
      expect(provider.rows.any((r) => r.txid == 'cheap'), isFalse);
      expect(provider.truncated, isFalse);
      expect(provider.alarmCount, provider.rows.where((r) => provider.score(r)! > alarmScore).length);
      expect(provider.alarm, isTrue);

      final scores = provider.rows.map((r) => provider.score(r)!).toList();
      for (var i = 1; i < scores.length; i++) {
        expect(scores[i], lessThanOrEqualTo(scores[i - 1]));
      }
    });
  });

  testWidgets('pending view applies the local score threshold and the row cap', (tester) {
    return tester.runAsync(() async {
      final pending = [for (var i = 0; i < 2600; i++) tx('c$i', 8, i % 3)];
      final fake = _FakeBitwindowd(pending: pending, history: []);
      final provider = await _providerAgainst(fake);

      expect(provider.rows.length, lessThanOrEqualTo(maxPendingRows));
      expect(provider.truncated, isTrue);
      expect(provider.rows.every((r) => provider.score(r)! > 0), isTrue, reason: 'score above 0 by default');

      provider.setMinScore(1.5);
      await settled(provider);
      expect(provider.rows.every((r) => provider.score(r)! > 1.5), isTrue);

      provider.setShowAll(true);
      await settled(provider);
      expect(fake.requests.last.minFeeRate, 0);
      expect(provider.rows.length, maxPendingRows);
    });
  });

  testWidgets('history tab pages through the server and keeps the server order', (tester) {
    return tester.runAsync(() async {
      final history = [for (var i = 0; i < 450; i++) tx('h$i', 3, 5, resolvedHeight: 400)];
      final fake = _FakeBitwindowd(pending: [tx('p', 9, 200)], history: history);
      final provider = await _providerAgainst(fake);

      provider.setTab(MempoolWatchTab.history);
      await settled(provider);
      provider.setSort(MempoolWatchSort.feeRate, true);
      await settled(provider);
      expect(provider.rows.length, 200);
      expect(provider.total, 450);
      expect(provider.alarmCount, 1, reason: 'alarm still counts the pending set');
      expect(fake.requests.last.sortBy, MempoolTxSort.MEMPOOL_TX_SORT_FEE_RATE);

      await provider.loadMore();
      await provider.loadMore();
      expect(provider.rows.length, 450);
      expect(provider.rows.map((r) => r.txid).toList(), history.map((r) => r.txid).toList());
      expect(provider.waited(provider.rows.first), 5, reason: 'measured up to its own block');

      provider.setSort(MempoolWatchSort.score, false);
      await settled(provider);
      expect(fake.requests.last.sortBy, MempoolTxSort.MEMPOOL_TX_SORT_FIRST_SEEN, reason: 'derived sorts fall back');
      expect(provider.rows.take(3).map((r) => r.txid).toList(), [
        'h0',
        'h1',
        'h10',
      ], reason: 'equal scores fall back to txid');
    });
  });
}
