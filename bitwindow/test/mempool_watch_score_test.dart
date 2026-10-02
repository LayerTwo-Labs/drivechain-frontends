import 'package:bitwindow/providers/mempool_watch_math.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sidechain_core/gen/google/protobuf/timestamp.pb.dart';

MempoolTransaction tx(
  String txid, {
  double? feeRate,
  int firstSeenHeight = 100,
  int? resolvedHeight,
  DateTime? firstSeen,
}) {
  return MempoolTransaction(
    txid: txid,
    hasDetails: feeRate != null,
    feeRate: feeRate ?? 0,
    firstSeenHeight: firstSeenHeight,
    resolvedHeight: resolvedHeight,
    firstSeen: Timestamp.fromDateTime(firstSeen ?? DateTime.utc(2026, 1, 1)),
  );
}

BlockStats block(int height, {double floor = 1, int totalFee = 4000000}) {
  return BlockStats(height: height, minFeeRate: floor, totalFeeSats: Int64(totalFee));
}

void main() {
  // Blocks 101..119 collected 4 BTC each, so F* = 4 sat/vB; block 120 is
  // empty and block 121 collected 2 BTC.
  final stats = <int, BlockStats>{
    for (var h = 101; h <= 119; h++) h: block(h, floor: h.isEven ? 6 : 2),
    120: block(120, floor: 0, totalFee: 0),
    121: block(121, floor: 1, totalFee: 2000000),
  };

  group('derivations', () {
    test('blocks waited runs to the resolving block or the tip', () {
      expect(blocksWaited(tx('a'), 119), 19);
      expect(blocksWaited(tx('a', resolvedHeight: 105), 119), 5);
      expect(blocksWaited(tx('a', firstSeenHeight: 130), 119), 0);
    });

    test('F* comes from the last block with fees at or below the height', () {
      expect(referenceFeeRateAt(stats, 119), closeTo(4, 1e-9));
      expect(referenceFeeRateAt(stats, 120), closeTo(4, 1e-9), reason: 'skips the empty block');
      expect(referenceFeeRateAt(stats, 121), closeTo(2, 1e-9));
      expect(referenceFeeRateAt(stats, 100), isNull);
    });

    test('blocks eligible counts blocks whose floor the fee rate met', () {
      expect(blocksEligible(tx('a', feeRate: 3), stats, 119), 10, reason: 'odd heights have floor 2');
      expect(blocksEligible(tx('a', feeRate: 8), stats, 119), 19);
      expect(blocksEligible(tx('a', feeRate: 8, resolvedHeight: 104), stats, 119), 4);
      expect(blocksEligible(tx('a'), stats, 119), 0, reason: 'no details');
    });
  });

  group('scoreOf', () {
    test('scales the fee rate premium over F* by blocks waited', () {
      expect(scoreOf(tx('a', feeRate: 8), stats, 119), closeTo(19, 1e-9));
      expect(scoreOf(tx('a', feeRate: 2), stats, 119), closeTo(-9.5, 1e-9));
    });

    test('resolved rows use F* at their own block', () {
      expect(scoreOf(tx('a', feeRate: 6, resolvedHeight: 121), stats, 200), closeTo(42, 1e-9));
    });

    test('is unknown without details or without any block with fees', () {
      expect(scoreOf(tx('a'), stats, 119), isNull);
      expect(scoreOf(tx('a', feeRate: 6), {}, 119), isNull);
    });
  });

  test('isAlarmed needs a score strictly above the threshold', () {
    expect(isAlarmed(tx('a', feeRate: 8, firstSeenHeight: 19), stats, 119), isFalse, reason: 'exactly 100');
    expect(isAlarmed(tx('a', feeRate: 8, firstSeenHeight: 18), stats, 119), isTrue);
    expect(isAlarmed(tx('a', firstSeenHeight: 0), stats, 119), isFalse);
  });

  group('compareMempoolTx', () {
    final now = DateTime.utc(2026, 1, 2);
    final rich = tx('rich', feeRate: 8);
    final fair = tx('fair', feeRate: 6);
    final patient = tx('patient', feeRate: 5, firstSeenHeight: 79);
    final blind = tx('blind', firstSeenHeight: 59);

    List<String> order(MempoolWatchSort sort, bool descending) {
      final rows = [blind, fair, patient, rich]
        ..sort((a, b) => compareMempoolTx(sort, descending, stats, 119, now, a, b));
      return rows.map((r) => r.txid).toList();
    }

    test('ranks by score with unknown scores last', () {
      expect(order(MempoolWatchSort.score, true), ['rich', 'patient', 'fair', 'blind']);
      expect(order(MempoolWatchSort.score, false), ['fair', 'patient', 'rich', 'blind']);
    });

    test('breaks ties on blocks waited by fee rate', () {
      expect(order(MempoolWatchSort.blocksWaited, true), ['blind', 'patient', 'rich', 'fair']);
    });

    test('orders time waited from first seen to resolution or now', () {
      final old = tx('old', feeRate: 5, firstSeen: DateTime.utc(2025, 12, 1));
      final young = tx('young', feeRate: 5, firstSeen: DateTime.utc(2026, 1, 1));
      final rows = [young, old]
        ..sort((a, b) => compareMempoolTx(MempoolWatchSort.timeWaited, true, stats, 119, now, a, b));
      expect(rows.first.txid, 'old');
    });
  });
}
