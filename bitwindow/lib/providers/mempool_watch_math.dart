import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pb.dart';

/// Everything derived from what the watcher recorded: a transaction's fee
/// rate, when it was first seen, and per block the lowest included fee rate
/// and the fees collected.

/// A pending transaction scoring above this counts as censored.
const alarmScore = 100.0;

/// A block's reference fee rate F* spreads its fees over a full block.
const blockVbytes = 1000000;

/// F* is averaged over this many blocks, so one light block does not swing it.
const referenceBlocks = 6;

/// Block stats keyed by height.
typedef BlockStatsByHeight = Map<int, BlockStats>;

int blocksWaited(MempoolTransaction tx, int tip) {
  final waited = tip - tx.firstSeenHeight;
  return waited > 0 ? waited : 0;
}

/// F* at [height]: the mean fees of the last [referenceBlocks] recorded
/// blocks at or below it, spread over a full block. Null before any block.
double? referenceFeeRateAt(BlockStatsByHeight stats, int height) {
  final recent = stats.values.where((b) => b.height <= height).toList()..sort((a, b) => b.height.compareTo(a.height));
  if (recent.isEmpty) {
    return null;
  }
  final window = recent.take(referenceBlocks);
  final fees = window.fold<int>(0, (sum, b) => sum + b.totalFeeSats.toInt());
  return fees / window.length / blockVbytes;
}

/// Blocks mined while the transaction waited whose lowest included fee rate
/// it would have met.
int blocksEligible(MempoolTransaction tx, BlockStatsByHeight stats, int tip) {
  var n = 0;
  for (final b in stats.values) {
    if (b.height > tx.firstSeenHeight && b.height <= tip && b.minFeeRate <= tx.feeRate) {
      n++;
    }
  }
  return n;
}

/// (fee rate - F*) / F* * blocks waited. Null before any block with fees.
double? scoreOf(MempoolTransaction tx, double? fstar, int tip) {
  if (fstar == null || fstar <= 0) {
    return null;
  }
  return (tx.feeRate - fstar) / fstar * blocksWaited(tx, tip);
}

bool isAlarmed(MempoolTransaction tx, double? fstar, int tip) {
  final score = scoreOf(tx, fstar, tip);
  return score != null && score > alarmScore;
}

Duration waitedFor(MempoolTransaction tx, DateTime now) => now.difference(tx.firstSeen.toDateTime());

enum MempoolWatchSort { feeRate, fee, vsize, firstSeen, blocksWaited, blocksEligible, score, timeWaited }

/// Orders by the sort key, then fee rate descending, then txid. [eligible]
/// holds blocks eligible by txid, counted once rather than per comparison.
int compareMempoolTx(
  MempoolWatchSort sort,
  bool descending,
  double? fstar,
  Map<String, int> eligible,
  int tip,
  DateTime now,
  MempoolTransaction a,
  MempoolTransaction b,
) {
  int direction(int cmp) => descending ? -cmp : cmp;
  final int primary;
  switch (sort) {
    case MempoolWatchSort.feeRate:
      primary = direction(a.feeRate.compareTo(b.feeRate));
    case MempoolWatchSort.fee:
      primary = direction(a.feeSats.compareTo(b.feeSats));
    case MempoolWatchSort.vsize:
      primary = direction(a.vsize.compareTo(b.vsize));
    case MempoolWatchSort.firstSeen:
      primary = direction(a.firstSeen.toDateTime().compareTo(b.firstSeen.toDateTime()));
    case MempoolWatchSort.blocksWaited:
      primary = direction(blocksWaited(a, tip).compareTo(blocksWaited(b, tip)));
    case MempoolWatchSort.blocksEligible:
      primary = direction((eligible[a.txid] ?? 0).compareTo(eligible[b.txid] ?? 0));
    case MempoolWatchSort.timeWaited:
      primary = direction(waitedFor(a, now).compareTo(waitedFor(b, now)));
    case MempoolWatchSort.score:
      final sa = scoreOf(a, fstar, tip);
      final sb = scoreOf(b, fstar, tip);
      primary = sa == null || sb == null ? 0 : direction(sa.compareTo(sb));
  }
  if (primary != 0) {
    return primary;
  }
  final byFeeRate = b.feeRate.compareTo(a.feeRate);
  return byFeeRate != 0 ? byFeeRate : a.txid.compareTo(b.txid);
}
