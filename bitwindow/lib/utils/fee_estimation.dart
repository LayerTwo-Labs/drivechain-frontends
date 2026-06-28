/// Convert a bitcoind `estimatesmartfee` rate (BTC/kvB) to sat/vB.
double btcPerKvbToSatPerVByte(double btcPerKvb) {
  return (btcPerKvb * 100000000) / 1000;
}

/// Estimate a transaction's virtual size in vbytes.
int estimateTxVBytes({required int numInputs, required int numOutputs}) {
  return 10 + (numInputs * 148) + (numOutputs * 34);
}

/// Total fee in sats for a given fee rate (sat/vB) and tx size (vbytes).
int feeSatsForRate({required double satPerVByte, required int txVBytes}) {
  return (satPerVByte * txVBytes).ceil();
}

/// A single point on the fee-rate-vs-confirmation-target curve.
class FeeRatePoint {
  final int confTarget;
  final double satPerVByte;

  const FeeRatePoint({required this.confTarget, required this.satPerVByte});
}

/// Confirmation targets (in blocks) sampled to build the fee-rate curve.
const List<int> feeRateConfTargets = [1, 2, 3, 6, 12, 24, 48, 144];
