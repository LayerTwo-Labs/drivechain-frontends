//
//  Generated code. Do not modify.
//  source: fast_withdrawal/v1/fast_withdrawal.proto
//

import "package:connectrpc/connect.dart" as connect;
import "fast_withdrawal.pb.dart" as fast_withdrawalv1fast_withdrawal;

/// FastWithdrawalService handles fast withdrawal initiation and monitoring
abstract final class FastWithdrawalService {
  /// Fully-qualified name of the FastWithdrawalService service.
  static const name = 'fast_withdrawal.v1.FastWithdrawalService';

  /// InitiateFastWithdrawal starts a fast withdrawal and streams status updates
  static const initiateFastWithdrawal = connect.Spec(
    '/$name/InitiateFastWithdrawal',
    connect.StreamType.server,
    fast_withdrawalv1fast_withdrawal.InitiateFastWithdrawalRequest.new,
    fast_withdrawalv1fast_withdrawal.FastWithdrawalUpdate.new,
  );
}
