import 'package:bitwindow/providers/mempool_watch_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/google/protobuf/timestamp.pb.dart';

import 'mocks/api_mock.dart';

const _tip = 1000;

BlockStats _block(int height, double minFeeRate, {int fees = 6000000}) =>
    BlockStats(height: height, minFeeRate: minFeeRate, totalFeeSats: Int64(fees));

MempoolTransaction _tx(String txid, double feeRate, int firstSeenHeight) => MempoolTransaction(
  txid: txid,
  feeSats: Int64((feeRate * 200).round()),
  vsize: 200,
  feeRate: feeRate,
  firstSeen: Timestamp.fromDateTime(DateTime(2026, 10, 1)),
  firstSeenHeight: firstSeenHeight,
);

class _Bitwindowd extends MockBitwindowdAPI {
  List<BlockStats> blocks = [];
  List<MempoolTransaction> txs = [];
  int statusCalls = 0;

  @override
  Future<GetMempoolWatchStatusResponse> getMempoolWatchStatus() async {
    statusCalls++;
    return GetMempoolWatchStatusResponse(enabled: true, running: true, tipHeight: _tip);
  }

  @override
  Future<List<BlockStats>> listBlockStats(int fromHeight, int toHeight) async => blocks;

  @override
  Future<ListMempoolTransactionsResponse> listMempoolTransactions(ListMempoolTransactionsRequest request) async =>
      ListMempoolTransactionsResponse(transactions: txs, total: Int64(txs.length));
}

class _API extends MockAPI {
  _API(this._bitwindowd) : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _Bitwindowd _bitwindowd;

  @override
  BitwindowAPI get bitwindowd => _bitwindowd;
}

void main() {
  group('reference fee rate', () {
    test('is null before any block', () {
      expect(referenceFeeRateAt({}, _tip), isNull);
    });

    test('spreads the mean fees of the last blocks over a full block', () {
      final stats = {
        for (var h = _tip - 9; h <= _tip; h++) h: _block(h, 1, fees: h > _tip - referenceBlocks ? 12000000 : 0),
      };
      expect(referenceFeeRateAt(stats, _tip), 12000000 / blockVbytes);
    });

    test('ignores blocks above the height', () {
      final stats = {_tip: _block(_tip, 1, fees: 3000000), _tip + 1: _block(_tip + 1, 1, fees: 9000000)};
      expect(referenceFeeRateAt(stats, _tip), 3);
    });
  });

  test('blocks eligible counts blocks after first seen whose floor the rate met', () {
    final stats = {
      _tip - 3: _block(_tip - 3, 1),
      _tip - 2: _block(_tip - 2, 5),
      _tip - 1: _block(_tip - 1, 20),
      _tip: _block(_tip, 5),
      _tip + 1: _block(_tip + 1, 1),
    };
    expect(blocksEligible(_tx('a', 10, _tip - 3), stats, _tip), 2);
    expect(blocksEligible(_tx('a', 30, _tip - 3), stats, _tip), 3);
    expect(blocksEligible(_tx('a', 30, _tip), stats, _tip), 0);
  });

  group('score', () {
    test('is null without a reference fee rate', () {
      expect(scoreOf(_tx('a', 10, _tip - 5), null, _tip), isNull);
      expect(scoreOf(_tx('a', 10, _tip - 5), 0, _tip), isNull);
    });

    test('weighs the gap to the reference fee rate by blocks waited', () {
      expect(scoreOf(_tx('a', 30, _tip - 4), 10, _tip), 8);
      expect(scoreOf(_tx('a', 5, _tip - 4), 10, _tip), -2);
    });

    test('alarms only above the alarm score', () {
      expect(isAlarmed(_tx('a', 30, _tip - 50), 10, _tip), isFalse);
      expect(isAlarmed(_tx('a', 30, _tip - 51), 10, _tip), isTrue);
    });
  });

  test('fee floors match only for the same heights and rates', () {
    final a = {1: _block(1, 2), 2: _block(2, 3)};
    expect(sameFeeFloors(a, {1: _block(1, 2, fees: 1), 2: _block(2, 3)}), isTrue);
    expect(sameFeeFloors(a, {1: _block(1, 2)}), isFalse);
    expect(sameFeeFloors(a, {1: _block(1, 2), 3: _block(3, 3)}), isFalse);
    expect(sameFeeFloors(a, {1: _block(1, 2), 2: _block(2, 4)}), isFalse);
  });

  group('provider', () {
    late _Bitwindowd bitwindowd;
    late MempoolWatchProvider provider;

    setUp(() async {
      await GetIt.I.reset();
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
      bitwindowd = _Bitwindowd()
        ..blocks = [_block(_tip - 1, 5), _block(_tip, 5)]
        ..txs = [_tx('a', 10, _tip - 2)];
      GetIt.I.registerSingleton<BitwindowRPC>(_API(bitwindowd)..connected = true);
      provider = MempoolWatchProvider();
    });

    tearDown(() async {
      provider.dispose();
      await GetIt.I.reset();
    });

    Future<void> listen() async {
      provider.addListener(() {});
      await pumpEventQueue();
    }

    test('does not fetch without a listener', () async {
      await provider.fetch();
      expect(bitwindowd.statusCalls, 0);
    });

    test('counts eligible blocks for a new transaction', () async {
      await listen();
      bitwindowd.txs = [...bitwindowd.txs, _tx('b', 3, _tip - 2)];
      await provider.fetch();
      expect(provider.eligible(bitwindowd.txs[0]), 2);
      expect(provider.eligible(bitwindowd.txs[1]), 0);
    });

    test('counts again when a fee floor changes at the same tip', () async {
      await listen();
      expect(provider.eligible(bitwindowd.txs.single), 2);

      bitwindowd.blocks = [_block(_tip - 1, 5), _block(_tip, 50)];
      await provider.fetch();
      expect(provider.eligible(bitwindowd.txs.single), 1);
    });
  });
}
