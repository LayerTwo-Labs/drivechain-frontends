//
//  Generated code. Do not modify.
//  source: fast_withdrawal/v1/fast_withdrawal.proto
//

import "package:connectrpc/connect.dart" as connect;
import "fast_withdrawal.pb.dart" as fast_withdrawalv1fast_withdrawal;
import "fast_withdrawal.connect.spec.dart" as specs;

/// FastWithdrawalService handles fast withdrawal initiation and monitoring
extension type FastWithdrawalServiceClient(connect.Transport _transport) {
  /// InitiateFastWithdrawal starts a fast withdrawal and streams status updates
  Stream<fast_withdrawalv1fast_withdrawal.FastWithdrawalUpdate> initiateFastWithdrawal(
    fast_withdrawalv1fast_withdrawal.InitiateFastWithdrawalRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.FastWithdrawalService.initiateFastWithdrawal,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
