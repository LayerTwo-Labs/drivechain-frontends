import 'package:sidechain_core/providers/stratum_provider.dart';

/// Plain words for the mining page. The reader knows no mining terms, so every
/// tooltip says what a number means in ordinary language.

/// The largest hash a difficulty of one allows.
final BigInt maxTarget = BigInt.parse('ffff', radix: 16) << 208;

const _scale = 4294967296; // 2^32, so a difficulty below one stays exact.

/// targetOf returns the largest hash that meets a difficulty.
BigInt targetOf(double difficulty) {
  final scaled = BigInt.from((difficulty * _scale).round());
  if (scaled <= BigInt.zero) {
    return maxTarget;
  }
  return maxTarget * BigInt.from(_scale) ~/ scaled;
}

/// hashOf writes a target as a 64-digit hash.
String hashOf(BigInt target) {
  return target.toRadixString(16).padLeft(64, '0');
}

/// leadingZeros counts the zeros a hash of this difficulty starts with.
int leadingZeros(double difficulty) {
  final hash = hashOf(targetOf(difficulty));
  var zeros = 0;
  while (zeros < hash.length && hash[zeros] == '0') {
    zeros++;
  }
  return zeros;
}

const _magnitudes = [
  (1e15, 'quadrillion'),
  (1e12, 'trillion'),
  (1e9, 'billion'),
  (1e6, 'million'),
  (1e3, 'thousand'),
];

/// spellCount writes a rate in plain words, such as `7.33 trillion`.
String spellCount(double value) {
  for (final (size, word) in _magnitudes) {
    if (value >= size) {
      return '${(value / size).toStringAsPrecision(3)} $word';
    }
  }
  return value.toStringAsFixed(0);
}

/// truncateMiddle shortens a long value, such as a hash.
String truncateMiddle(String value, {int keep = 8}) {
  if (value.length <= keep * 2 + 1) {
    return value;
  }
  return '${value.substring(0, keep)}…${value.substring(value.length - keep)}';
}

const hashrateInfoTitle = 'Hashrate';
const bestShareInfoTitle = 'Best share';
const blocksFoundInfoTitle = 'Blocks found';
const expectedTimeInfoTitle = 'Expected time to a block';
const recentSharesInfoTitle = 'Recent shares';
const poolAddressInfoTitle = 'Pool address';

const blocksFoundInfo = 'Blocks your miners found since the server started. The reward goes to your payout address.';
const expectedTimeInfo = 'How long a block takes on average, at this hashrate. Luck decides the real time.';
const recentSharesInfo =
    'Each row is one piece of proof that your miner works. The pool counts these, and it pays '
    'you for them.';
const poolAddressInfo = "Type this into your miner's pool settings.";

/// hashrateInfo says how fast the miners guess, and how long a block takes at
/// that speed.
String hashrateInfo({
  required double hashrate,
  required double networkHashrate,
  required double networkDifficulty,
  required String formattedHashrate,
  required String formattedNetwork,
}) {
  const opening = 'How many guesses per second your miners make.';
  if (hashrate <= 0) {
    return '$opening No miner is connected.';
  }
  final spelled = '$formattedHashrate is ${spellCount(hashrate)} guesses each second.';
  final expected = expectedTimeToBlock(networkDifficulty, hashrate);
  if (networkHashrate <= 0 || expected == null) {
    return '$opening $spelled';
  }
  return '$opening $spelled The whole network makes $formattedNetwork, so your miner is expected to find a block '
      'every ${formatLongDuration(expected)}.';
}

/// bestShareInfo says how close the best share came to a block, in zeros.
String bestShareInfo({required double bestShare, required bool won, required double networkDifficulty}) {
  final needed = leadingZeros(networkDifficulty);
  final reached = bestShare <= 0 ? 0 : leadingZeros(bestShare);
  if (won) {
    return 'The closest your miner came to a block. Your best guess reached $reached zeros, and it won a block.';
  }
  final opening =
      'The closest your miner came to a block. To win, your miner must produce a hash that starts with '
      'at least $needed zeros';
  if (reached >= needed) {
    final target = truncateMiddle(hashOf(targetOf(networkDifficulty)));
    return '$opening, and is a smaller number than $target. Your best guess reached $reached zeros, but the digits '
        'after them were too big.';
  }
  return '$opening. Your best guess started with $reached.';
}
