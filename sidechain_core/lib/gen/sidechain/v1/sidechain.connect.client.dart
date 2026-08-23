//
//  Generated code. Do not modify.
//  source: sidechain/v1/sidechain.proto
//

import "package:connectrpc/connect.dart" as connect;
import "sidechain.pb.dart" as sidechainv1sidechain;
import "sidechain.connect.spec.dart" as specs;

/// SidechainService provides API for sidechain monitoring and fast withdrawal detection
extension type SidechainServiceClient (connect.Transport _transport) {
  /// GetDetectedWithdrawals returns all detected fast withdrawal transactions
  Future<sidechainv1sidechain.GetDetectedWithdrawalsResponse> getDetectedWithdrawals(
    sidechainv1sidechain.GetDetectedWithdrawalsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainService.getDetectedWithdrawals,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// GetWithdrawalByTxid returns a specific withdrawal by transaction ID
  Future<sidechainv1sidechain.GetWithdrawalByTxidResponse> getWithdrawalByTxid(
    sidechainv1sidechain.GetWithdrawalByTxidRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainService.getWithdrawalByTxid,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
