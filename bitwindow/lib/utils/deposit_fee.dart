import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Confirmation targets, in blocks, a deposit can be paid for.
const List<int> depositFeeTargets = [1, 3, 6, 24];

String depositFeeTargetLabel(int confTarget) => confTarget == 1 ? 'Next block (1)' : '$confTarget blocks';

/// The rate a deposit falls back to when no backend can estimate one.
const double minimumFeeRate = 1;

/// Holds the deposit fee field on an estimated rate.
class DepositFeeEstimate {
  final TextEditingController controller;

  int confTarget;
  double satPerVByte = minimumFeeRate;
  bool estimated = false;

  DepositFeeEstimate(this.controller, {this.confTarget = 1});

  /// A deposit spends a couple of inputs and pays the sidechain plus change.
  int get vBytes => estimateTxVBytes(numInputs: 2, numOutputs: 2);

  int get feeSats => feeSatsForRate(satPerVByte: satPerVByte, txVBytes: vBytes);

  String get hint {
    if (!estimated) {
      return 'No fee estimate yet. Paying the ${_rate(minimumFeeRate)} sat/vB minimum.';
    }
    return '$feeSats sats at ${_rate(satPerVByte)} sat/vB, for a $vBytes vB deposit.';
  }

  /// Fills the fee field from the rate for [target], or from the minimum rate
  /// when no backend can estimate one. [keepEdits] keeps a typed fee.
  Future<void> refresh(int target, {bool keepEdits = false}) async {
    confTarget = target;
    final before = controller.text;
    double? rate;
    try {
      rate = await feeRateForTarget(target);
    } catch (_) {
      rate = null;
    }
    // A later pick may have overtaken this read while it was in flight.
    if (target != confTarget || (keepEdits && controller.text != before)) {
      return;
    }
    estimated = rate != null;
    satPerVByte = rate ?? minimumFeeRate;
    controller.text = satoshiToBTC(feeSats).toStringAsFixed(8);
  }

  static String _rate(double satPerVByte) =>
      satPerVByte == satPerVByte.roundToDouble() ? satPerVByte.toStringAsFixed(0) : satPerVByte.toStringAsFixed(2);
}
