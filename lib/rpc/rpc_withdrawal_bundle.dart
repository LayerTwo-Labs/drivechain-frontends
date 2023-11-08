import 'package:collection/collection.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/rpc/models/bundle_info.dart';
import 'package:sidesail/rpc/models/raw_transaction.dart';

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

  double get totalBitcoin => satoshiToBTC(withdrawals.map((e) => e.amountSatoshi).toList().sum);
  double get totalFeesBitcoin => satoshiToBTC(withdrawals.map((e) => e.mainchainFeesSatoshi).toList().sum);

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

  // TODO: what even is this? From testchain codebase:  Hash of transaction minus the serialization output
  // No clue what the user can use this for.
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
