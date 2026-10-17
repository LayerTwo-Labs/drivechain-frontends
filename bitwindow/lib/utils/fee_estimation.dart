import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart' show EstimateSmartFeeRequest;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' show PreviewSendResponse;
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

/// The fee fields of a send request. An estimated rate goes to the backend as
/// a rate, so the fee fits the inputs it picks. A typed fee goes as a fixed fee.
({int? feeRateSatPerVbyte, int? fixedFeeSats}) sendFee({
  required double? estimatedSatPerVByte,
  required int typedFeeSats,
}) {
  if (estimatedSatPerVByte != null) {
    return (feeRateSatPerVbyte: estimatedSatPerVByte.ceil(), fixedFeeSats: null);
  }
  return (feeRateSatPerVbyte: null, fixedFeeSats: typedFeeSats);
}

/// The destinations of a send, with the sats of each address summed. Null
/// while a recipient has no address or no amount.
Map<String, int>? sendDestinations(Iterable<({String address, int sats})> recipients) {
  final destinations = <String, int>{};
  for (final r in recipients) {
    if (r.address.isEmpty || r.sats <= 0) {
      return null;
    }
    destinations[r.address] = (destinations[r.address] ?? 0) + r.sats;
  }
  return destinations.isEmpty ? null : destinations;
}

/// Identifies the send a fee preview prices, so a form change that keeps the
/// send the same asks for no new preview.
String feePreviewKey({
  required String walletId,
  required Map<String, int> destinations,
  required int feeRateSatPerVbyte,
  required bool subtractFeeFromAmount,
  required Iterable<String> requiredOutpoints,
  required Iterable<String> frozenOutpoints,
  required Iterable<String> walletOutpoints,
}) {
  String sorted(Iterable<String> items) => (items.toList()..sort()).join(',');
  return [
    walletId,
    feeRateSatPerVbyte,
    subtractFeeFromAmount,
    sorted(destinations.entries.map((e) => '${e.key}=${e.value}')),
    sorted(requiredOutpoints),
    sorted(frozenOutpoints),
    sorted(walletOutpoints),
  ].join('|');
}

/// The coins a send spends. Core picks coins at random, so a send without a
/// coin selection pins the coins of the preview that priced the current form.
List<T> sendInputs<T>({
  required List<T> selected,
  required String? currentKey,
  required String? pricedKey,
  required List<T> pricedInputs,
}) {
  if (selected.isNotEmpty || currentKey == null || currentKey != pricedKey) {
    return selected;
  }
  return pricedInputs;
}

/// The fees of a previewed send: the payment, and the BIP47 notification a
/// first payment publishes before it.
int previewFeeSats(PreviewSendResponse preview) => preview.feeSats.toInt() + preview.notificationFeeSats.toInt();

/// The amount MAX puts in a recipient. A first BIP47 payment cannot spend the
/// coin of its notification, so MAX keeps that coin back with the payment fee.
int maxSendAmountSats({
  required int availableSats,
  required int otherRecipientsSats,
  required int paymentFeeSats,
  required int notificationCoinSats,
}) => availableSats - otherRecipientsSats - notificationCoinSats - paymentFeeSats;

/// The smallest payment the backend sends to an address.
const dustSats = 546;

/// Time the send page waits after the last form change before it asks for a
/// fee preview.
const feePreviewDebounce = Duration(milliseconds: 400);

/// A single point on the fee-rate-vs-confirmation-target curve.
class FeeRatePoint {
  final int confTarget;
  final double satPerVByte;

  const FeeRatePoint({required this.confTarget, required this.satPerVByte});
}

/// Confirmation targets (in blocks) sampled to build the fee-rate curve.
const List<int> feeRateConfTargets = [1, 2, 3, 6, 12, 24, 48, 144];
