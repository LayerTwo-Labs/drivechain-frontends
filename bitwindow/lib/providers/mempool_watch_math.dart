import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pb.dart';

/// Everything derived from what the watcher recorded: a transaction's fee
/// rate as mined, when it was first seen, when it resolved, and per block
/// the lowest included fee rate and the fees collected.

/// A pending transaction scoring above this counts as censored.
const alarmScore = 100.0;

/// A block's reference fee rate F* spreads its fees over a full block.
const blockVbytes = 1000000;

/// Block stats keyed by height.
typedef BlockStatsByHeight = Map<int, BlockStats>;

/// The height a transaction is measured up to: its resolving block, or the
/// tip while it is pending.
int referenceHeight(MempoolTransaction tx, int tip) => tx.hasResolvedHeight() ? tx.resolvedHeight : tip;

int blocksWaited(MempoolTransaction tx, int tip) {
  final waited = referenceHeight(tx, tip) - tx.firstSeenHeight;
  return waited > 0 ? waited : 0;
}

/// F* at [height]: the fees of the last recorded block at or below it that
/// collected any, spread over a full block. Null before such a block.
double? referenceFeeRateAt(BlockStatsByHeight stats, int height) {
  var best = -1;
  for (final b in stats.values) {
    if (b.height <= height && b.height > best && b.totalFeeSats > 0) {
      best = b.height;
    }
  }
  return best < 0 ? null : stats[best]!.totalFeeSats.toInt() / blockVbytes;
}

/// Blocks mined while the transaction waited whose lowest included fee rate
/// it would have met.
int blocksEligible(MempoolTransaction tx, BlockStatsByHeight stats, int tip) {
  if (!tx.hasDetails) {
    return 0;
  }
  final end = referenceHeight(tx, tip);
  var n = 0;
  for (final b in stats.values) {
    if (b.height > tx.firstSeenHeight && b.height <= end && b.minFeeRate <= tx.feeRate) {
      n++;
    }
  }
  return n;
}

/// (fee rate - F*) / F* * blocks waited. Null without fee details or before
/// any block with fees.
double? scoreOf(MempoolTransaction tx, BlockStatsByHeight stats, int tip) {
  if (!tx.hasDetails) {
    return null;
  }
  final fstar = referenceFeeRateAt(stats, referenceHeight(tx, tip));
  if (fstar == null || fstar <= 0) {
    return null;
  }
  return (tx.feeRate - fstar) / fstar * blocksWaited(tx, tip);
}

bool isAlarmed(MempoolTransaction tx, BlockStatsByHeight stats, int tip) {
  final score = scoreOf(tx, stats, tip);
  return score != null && score > alarmScore;
}

Duration waitedFor(MempoolTransaction tx, DateTime now) {
  final end = tx.hasResolvedAt() ? tx.resolvedAt.toDateTime() : now;
  return end.difference(tx.firstSeen.toDateTime());
}

enum MempoolWatchSort { feeRate, fee, vsize, firstSeen, blocksWaited, blocksEligible, score, timeWaited }

/// Orders like the server does: the sort key, then fee rate descending, then
/// txid. Rows without a score sort last whichever direction is chosen.
int compareMempoolTx(
  MempoolWatchSort sort,
  bool descending,
  BlockStatsByHeight stats,
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
      primary = direction(blocksEligible(a, stats, tip).compareTo(blocksEligible(b, stats, tip)));
    case MempoolWatchSort.timeWaited:
      primary = direction(waitedFor(a, now).compareTo(waitedFor(b, now)));
    case MempoolWatchSort.score:
      final sa = scoreOf(a, stats, tip);
      final sb = scoreOf(b, stats, tip);
      if (sa == null || sb == null) {
        primary = sa == null && sb == null ? 0 : (sa == null ? 1 : -1);
      } else {
        primary = direction(sa.compareTo(sb));
      }
  }
  if (primary != 0) {
    return primary;
  }
  final byFeeRate = b.feeRate.compareTo(a.feeRate);
  return byFeeRate != 0 ? byFeeRate : a.txid.compareTo(b.txid);
}
