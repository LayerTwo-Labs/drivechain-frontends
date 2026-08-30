import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// The script kind of the address that holds a coin. BitWindow reads the kind
/// from the address only when the backend reports no weight for the coin.
enum CoinScriptKind { p2pkh, p2sh, p2wpkh, p2wsh, p2tr, unknown }

/// The largest weight, in weight units, that one input of this kind costs.
///
/// The orchestrator computes the same numbers from each coin's descriptor, and
/// sends them on `UnspentOutput.inputWeightUnits`. These values only cover a
/// coin the backend could not describe. A signature is 71 or 72 bytes, so each
/// number takes the larger one.
int fallbackInputWeightUnits(CoinScriptKind kind) {
  switch (kind) {
    case CoinScriptKind.p2pkh:
      return 592;
    case CoinScriptKind.p2sh:
      return 364;
    case CoinScriptKind.p2wpkh:
      return 272;
    // A 2-of-3 script. A wider script costs more, so a coin the backend cannot
    // describe reads low here.
    case CoinScriptKind.p2wsh:
      return 418;
    case CoinScriptKind.p2tr:
      return 231;
    case CoinScriptKind.unknown:
      return 592;
  }
}

/// The weight of one output, by the kind of address it pays.
int outputWeightUnits(CoinScriptKind kind) {
  // 8 bytes of value, the script length byte, and the script.
  switch (kind) {
    case CoinScriptKind.p2pkh:
      return 4 * (8 + 1 + 25);
    case CoinScriptKind.p2sh:
      return 4 * (8 + 1 + 23);
    case CoinScriptKind.p2wpkh:
      return 4 * (8 + 1 + 22);
    case CoinScriptKind.p2wsh:
    case CoinScriptKind.p2tr:
    case CoinScriptKind.unknown:
      return 4 * (8 + 1 + 34);
  }
}

/// The output kind a wallet of this address type receives to. An unknown type
/// takes the widest output, so the size never reads low.
CoinScriptKind destinationKindFor(wmpb.AddressType type) {
  switch (type) {
    case wmpb.AddressType.ADDRESS_TYPE_SEGWIT:
      return CoinScriptKind.p2wpkh;
    case wmpb.AddressType.ADDRESS_TYPE_TAPROOT:
      return CoinScriptKind.p2tr;
    default:
      // A legacy or nested segwit wallet advertises no type. It derives no
      // taproot address, so the send must ask for nothing in particular, and
      // the size takes the widest output.
      return CoinScriptKind.unknown;
  }
}

/// The address type to ask the backend for, so the send matches the plan.
wmpb.AddressType addressTypeFor(CoinScriptKind kind) {
  switch (kind) {
    case CoinScriptKind.p2wpkh:
      return wmpb.AddressType.ADDRESS_TYPE_SEGWIT;
    case CoinScriptKind.p2tr:
      return wmpb.AddressType.ADDRESS_TYPE_TAPROOT;
    default:
      return wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED;
  }
}

/// Version and locktime, both four bytes, with no witness discount.
const int _versionAndLocktimeWeight = 4 * 8;

/// The segwit marker and flag, one weight unit each.
const int _segwitMarkerWeight = 2;

/// Bitcoin Core relays no transaction above this size.
const int maxStandardTxVbytes = 100000;

/// The planner stops a transaction here, not at [maxStandardTxVbytes]. The
/// margin covers a coin the backend could not describe.
const int consolidationTargetVbytes = 98000;

/// The smallest amount an output of this kind may carry. Bitcoin Core sizes
/// dust from what the output costs to make and to spend again, so a taproot
/// output may hold less than a legacy one.
int dustThresholdFor(CoinScriptKind kind) {
  switch (kind) {
    case CoinScriptKind.p2pkh:
      return 546;
    case CoinScriptKind.p2sh:
      return 540;
    case CoinScriptKind.p2wpkh:
      return 294;
    case CoinScriptKind.p2wsh:
    case CoinScriptKind.p2tr:
      return 330;
    case CoinScriptKind.unknown:
      // The widest threshold, so an output this cannot read stays spendable.
      return 546;
  }
}

/// The byte count of a Bitcoin compact size integer.
int compactSizeLength(int value) {
  if (value < 0xfd) {
    return 1;
  }
  if (value <= 0xffff) {
    return 3;
  }
  if (value <= 0xffffffff) {
    return 5;
  }
  return 9;
}

/// Reads the script kind from the address text.
CoinScriptKind coinScriptKind(String address) {
  final lower = address.toLowerCase();

  if (lower.startsWith('bc1p') || lower.startsWith('tb1p') || lower.startsWith('bcrt1p')) {
    return CoinScriptKind.p2tr;
  }
  if (lower.startsWith('bc1q') || lower.startsWith('tb1q') || lower.startsWith('bcrt1q')) {
    // A 20 byte program encodes to 42 characters, and a 32 byte program to 62.
    return lower.length >= 60 ? CoinScriptKind.p2wsh : CoinScriptKind.p2wpkh;
  }
  if (address.startsWith('1') || address.startsWith('m') || address.startsWith('n')) {
    return CoinScriptKind.p2pkh;
  }
  if (address.startsWith('3') || address.startsWith('2')) {
    return CoinScriptKind.p2sh;
  }
  return CoinScriptKind.unknown;
}

/// True when no number bounds what [coin] costs to spend.
///
/// A taproot address hides its script tree, and a script path spend costs far
/// more than a key path spend. The address says nothing about which one this
/// coin takes, so a coin the backend could not size stays out of every plan.
bool coinSizeIsUnknown(UnspentOutput coin) {
  if (coin.inputWeightUnits > 0) {
    return false;
  }
  final kind = coinScriptKind(coin.address);
  return kind == CoinScriptKind.p2tr || kind == CoinScriptKind.unknown;
}

/// What [coin] costs to spend, in weight units.
///
/// The orchestrator reads this from the coin's own descriptor, so it is exact
/// for every script the wallet holds. The address fallback only covers a
/// backend that reports no descriptor, and only for a kind the address bounds.
int coinInputWeightUnits(UnspentOutput coin) {
  if (coin.inputWeightUnits > 0) {
    return coin.inputWeightUnits;
  }
  return fallbackInputWeightUnits(coinScriptKind(coin.address));
}

/// True when spending [coin] adds a witness to the transaction.
///
/// A kind this cannot read counts as no witness, because that adds the empty
/// witness byte below instead of dropping it. The consolidation tab runs on a
/// single-signature wallet, so every P2SH coin it sees is nested segwit.
bool coinHasWitness(UnspentOutput coin) {
  switch (coinScriptKind(coin.address)) {
    case CoinScriptKind.p2sh:
    case CoinScriptKind.p2wpkh:
    case CoinScriptKind.p2wsh:
    case CoinScriptKind.p2tr:
      return true;
    case CoinScriptKind.p2pkh:
    case CoinScriptKind.unknown:
      return false;
  }
}

/// The exact virtual size of a transaction that spends [inputCount] inputs of
/// [inputWeightUnits] total weight into one output.
int consolidationVbytes({
  required int inputCount,
  required int inputWeightUnits,
  required bool hasWitness,
  required CoinScriptKind destinationKind,
  int witnessFreeInputCount = 0,
}) {
  var weight = _versionAndLocktimeWeight;
  weight += 4 * compactSizeLength(inputCount);
  weight += 4 * compactSizeLength(1);
  if (hasWitness) {
    weight += _segwitMarkerWeight;
    // Segwit serialization gives every input a witness field, so an input
    // without one still costs the empty item count byte.
    weight += witnessFreeInputCount;
  }
  weight += inputWeightUnits;
  weight += outputWeightUnits(destinationKind);
  // Weight rounds up to a whole vbyte, the same way Bitcoin Core does.
  return (weight + 3) ~/ 4;
}

/// One consolidation transaction: many coins in, one coin out.
class ConsolidationBatch {
  final List<UnspentOutput> inputs;
  final int feeRateSatPerVbyte;
  final CoinScriptKind destinationKind;

  const ConsolidationBatch({
    required this.inputs,
    required this.feeRateSatPerVbyte,
    this.destinationKind = CoinScriptKind.p2tr,
  });

  int get inputWeightUnits => inputs.fold(0, (sum, u) => sum + coinInputWeightUnits(u));

  int get witnessFreeInputCount => inputs.where((u) => !coinHasWitness(u)).length;

  int get vbytes => consolidationVbytes(
    inputCount: inputs.length,
    inputWeightUnits: inputWeightUnits,
    hasWitness: inputs.any(coinHasWitness),
    destinationKind: destinationKind,
    witnessFreeInputCount: witnessFreeInputCount,
  );

  int get feeSats => vbytes * feeRateSatPerVbyte;

  int get inputSats => inputs.fold(0, (sum, u) => sum + u.valueSats.toInt());

  int get outputSats => inputSats - feeSats;

  List<String> get outpoints => inputs.map((u) => u.output).toList();
}

/// Why the plan leaves a coin out.
enum ConsolidationSkipReason {
  /// The coin is frozen, so the user marked it as unspendable.
  frozen,

  /// Nothing bounds what the coin costs to spend, so no transaction can hold
  /// it safely.
  unknownSize,

  /// The coin is worth less than the fee to spend it.
  tooSmall,

  /// The coin has no partner left to merge with.
  alone,
}

class ConsolidationSkip {
  final UnspentOutput coin;
  final ConsolidationSkipReason reason;

  const ConsolidationSkip(this.coin, this.reason);
}

class ConsolidationPlan {
  final List<ConsolidationBatch> batches;
  final List<ConsolidationSkip> skipped;
  final int feeRateSatPerVbyte;

  const ConsolidationPlan({
    required this.batches,
    required this.skipped,
    required this.feeRateSatPerVbyte,
  });

  bool get isEmpty => batches.isEmpty;

  int get transactionCount => batches.length;

  int get coinCount => batches.fold(0, (sum, b) => sum + b.inputs.length);

  int get totalVbytes => batches.fold(0, (sum, b) => sum + b.vbytes);

  int get largestVbytes => batches.fold(0, (largest, b) => b.vbytes > largest ? b.vbytes : largest);

  int get totalFeeSats => batches.fold(0, (sum, b) => sum + b.feeSats);

  int get totalInputSats => batches.fold(0, (sum, b) => sum + b.inputSats);

  int get totalOutputSats => batches.fold(0, (sum, b) => sum + b.outputSats);

  /// The coins the selection leaves behind: one per transaction, plus every
  /// selected coin the plan left out. It counts no coin outside the
  /// selection, so a caller that reports a wallet total must add those.
  int get resultCoinCount => batches.length + skipped.length;

  /// True when every coin carried a weight the backend measured.
  bool get everyCoinMeasured => batches.every((b) => b.inputs.every((u) => u.inputWeightUnits > 0));

  List<UnspentOutput> skippedFor(ConsolidationSkipReason reason) =>
      skipped.where((s) => s.reason == reason).map((s) => s.coin).toList();
}

/// Splits [coins] into transactions that each stay below
/// [consolidationTargetVbytes]. The weight of every coin caps a transaction,
/// not the coin count, because each script kind costs a different amount.
///
/// The plan drops a frozen coin, a coin worth less than its own input fee, and
/// a final coin that has nothing left to merge with.
ConsolidationPlan planConsolidation({
  required List<UnspentOutput> coins,
  required int feeRateSatPerVbyte,
  Set<String> frozenOutpoints = const {},
  CoinScriptKind destinationKind = CoinScriptKind.p2tr,
}) {
  if (feeRateSatPerVbyte < 1) {
    throw ArgumentError.value(feeRateSatPerVbyte, 'feeRateSatPerVbyte', 'must be 1 or more');
  }

  final skipped = <ConsolidationSkip>[];
  final spendable = <UnspentOutput>[];

  for (final coin in coins) {
    if (frozenOutpoints.contains(coin.output)) {
      skipped.add(ConsolidationSkip(coin, ConsolidationSkipReason.frozen));
      continue;
    }
    // The coin must cover the fee to spend itself, or it loses money.
    final ownCostSats = ((coinInputWeightUnits(coin) + 3) ~/ 4) * feeRateSatPerVbyte;
    if (coinSizeIsUnknown(coin)) {
      skipped.add(ConsolidationSkip(coin, ConsolidationSkipReason.unknownSize));
      continue;
    }
    if (coin.valueSats.toInt() <= ownCostSats) {
      skipped.add(ConsolidationSkip(coin, ConsolidationSkipReason.tooSmall));
      continue;
    }
    spendable.add(coin);
  }

  // Smallest first, so the earliest transaction clears the coins that cost the
  // most to keep.
  spendable.sort((a, b) => a.valueSats.compareTo(b.valueSats));

  final batches = <ConsolidationBatch>[];
  var current = <UnspentOutput>[];
  var currentWeight = 0;
  var currentHasWitness = false;
  var currentWitnessFree = 0;

  ConsolidationBatch batchOf(List<UnspentOutput> inputs) => ConsolidationBatch(
    inputs: inputs,
    feeRateSatPerVbyte: feeRateSatPerVbyte,
    destinationKind: destinationKind,
  );

  void flush() {
    if (current.isEmpty) {
      return;
    }

    // A single coin cannot merge with itself. Move one coin out of the last
    // transaction, so the tail gets a partner instead of a drop.
    if (current.length == 1 && batches.isNotEmpty) {
      final previous = batches.last;
      if (previous.inputs.length >= 3) {
        final trimmed = batchOf(previous.inputs.sublist(0, previous.inputs.length - 1));
        final tail = batchOf([previous.inputs.last, ...current]);
        final dust = dustThresholdFor(destinationKind);
        if (trimmed.outputSats >= dust && tail.outputSats >= dust) {
          batches[batches.length - 1] = trimmed;
          current = tail.inputs;
        }
      }
    }

    if (current.length >= 2) {
      final batch = batchOf(current);
      if (batch.outputSats >= dustThresholdFor(destinationKind)) {
        batches.add(batch);
      } else {
        skipped.addAll(current.map((c) => ConsolidationSkip(c, ConsolidationSkipReason.tooSmall)));
      }
    } else {
      skipped.addAll(current.map((c) => ConsolidationSkip(c, ConsolidationSkipReason.alone)));
    }

    current = [];
    currentWeight = 0;
    currentHasWitness = false;
    currentWitnessFree = 0;
  }

  for (final coin in spendable) {
    final weight = coinInputWeightUnits(coin);
    final witness = coinHasWitness(coin);

    // Measure the transaction the coin would join, not an estimate of it. Both
    // count fields and the segwit marker change with the set.
    final wouldBe = consolidationVbytes(
      inputCount: current.length + 1,
      inputWeightUnits: currentWeight + weight,
      hasWitness: currentHasWitness || witness,
      destinationKind: destinationKind,
      witnessFreeInputCount: currentWitnessFree + (witness ? 0 : 1),
    );
    if (current.isNotEmpty && wouldBe > consolidationTargetVbytes) {
      flush();
    }

    current.add(coin);
    currentWeight += weight;
    currentHasWitness = currentHasWitness || witness;
    if (!witness) {
      currentWitnessFree++;
    }
  }
  flush();

  return ConsolidationPlan(
    batches: batches,
    skipped: skipped,
    feeRateSatPerVbyte: feeRateSatPerVbyte,
  );
}
