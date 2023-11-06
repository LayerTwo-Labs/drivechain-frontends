import 'package:sidesail/rpc/rpc_rawtx.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class WithdrawalBundle {
  WithdrawalBundle({
    required this.hash,
    required this.bundleSize,
    required this.blockHeight,
    required this.withdrawals,
  });

  factory WithdrawalBundle.fromRawTransaction(
    RawTransaction tx,
    BundleInfo info,
    List<Withdrawal> withdrawals,
  ) =>
      WithdrawalBundle(
        hash: tx.hash,
        bundleSize: info.weight,
        blockHeight: info.height,
        withdrawals: withdrawals,
      );

  final String hash;

  final int bundleSize;
  final int maxBundleSize = 50 * 1000;

  /// Block number this withdrawal bundle was initiated.
  final int blockHeight;

  final List<Withdrawal> withdrawals;
}

/// A collection of withdrawals that have not yet been proposed into
/// a mainchain withdrawal bundle.
class FutureWithdrawalBundle {
  FutureWithdrawalBundle({
    required this.cumulativeWeight,
    required this.withdrawals,
  });

  final int cumulativeWeight;
  final List<Withdrawal> withdrawals;
}

class Withdrawal {
  Withdrawal({
    required this.mainchainFeesSatoshi,
    required this.amountSatoshi,
    required this.address,
    required this.hashBlindTx,
    required this.refundDestination,
    required this.status,
  });

  final int mainchainFeesSatoshi;
  final int amountSatoshi;
  final String address;
  final String hashBlindTx;
  final String refundDestination;

  // Directly from RPC interface.
  final String status;

  factory Withdrawal.fromJson(Map<String, dynamic> json) => Withdrawal(
        address: json['destination'],
        refundDestination: json['refunddestination'],
        amountSatoshi: json['amount'],
        mainchainFeesSatoshi: json['amountmainchainfee'],
        status: json['status'],
        hashBlindTx: json['hashblindtx'],
      );

  Map<String, dynamic> toJson() => {
        'destination': address,
        'refunddestination': refundDestination,
        'amount': amountSatoshi,
        'amountmainchainfee': mainchainFeesSatoshi,
        'status': status,
        'hashblindtx': hashBlindTx,
      };
}
