import 'package:sidesail/rpc/rpc_rawtx.dart';

class WithdrawalBundle {
  WithdrawalBundle({
    required this.hash,
    required this.bundleSize,
    required this.blockHeight,
    required this.withdrawals,
  });

  factory WithdrawalBundle.fromRawTransaction(
    RawTransaction tx,
  ) =>
      WithdrawalBundle(
        hash: tx.hash,
        bundleSize: tx.size * 4,
        blockHeight: 0, // TODO: how to get this
        withdrawals: tx.vout
            // filter out OP_RETURN
            .where((out) => out.scriptPubKey.type != 'nulldata')
            .map(
              (out) => Withdrawal(
                mainchainFeesSatoshi: 0, // TODO: how to get this
                amountSatoshi: (out.value * 100 * 1000 * 1000).toInt(),
                address: out.scriptPubKey.addresses.first,
              ),
            )
            .toList(),
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
  });

  final int mainchainFeesSatoshi; // TODO: how to obtain?
  final int amountSatoshi;
  final String address;
}
