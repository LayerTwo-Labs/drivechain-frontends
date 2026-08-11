import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart' show EstimateSmartFeeRequest;
import 'package:sail_ui/sail_ui.dart';

/// Fee rate in ${activeTicker.feeRate} for a confirmation target in blocks.
/// Null when neither the wallet backend nor Bitcoin Core can estimate one.
Future<double?> feeRateForTarget(int confTarget) async {
  final orchestrator = GetIt.I<OrchestratorRPC>();
  // Electrum wallets have no Bitcoin Core; fee comes from esplora via the backend.
  try {
    final rate = await orchestrator.wallet.estimateFee(confTarget);
    if (rate != null && rate > 0) {
      return rate;
    }
  } catch (_) {
    // fall through to Bitcoin Core for core-backed wallets
  }
  final response = await orchestrator.bitcoind.estimateSmartFee(
    EstimateSmartFeeRequest()..confTarget = Int64(confTarget),
  );
  if (!response.hasFeeRate() || response.feeRate <= 0) {
    return null;
  }
  return btcPerKvbToSatPerVByte(response.feeRate);
}

/// Convert a bitcoind `estimatesmartfee` rate (BTC/kvB) to ${activeTicker.feeRate}.
double btcPerKvbToSatPerVByte(double btcPerKvb) {
  return (btcPerKvb * 100000000) / 1000;
}

/// Estimate a transaction's virtual size in vbytes.
int estimateTxVBytes({required int numInputs, required int numOutputs}) {
  return 10 + (numInputs * 148) + (numOutputs * 34);
}

/// Total fee in sats for a given fee rate (${activeTicker.feeRate}) and tx size (vbytes).
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
