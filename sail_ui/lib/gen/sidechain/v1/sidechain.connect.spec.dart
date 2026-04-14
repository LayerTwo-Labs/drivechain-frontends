//
//  Generated code. Do not modify.
//  source: sidechain/v1/sidechain.proto
//

import "package:connectrpc/connect.dart" as connect;
import "sidechain.pb.dart" as sidechainv1sidechain;

/// SidechainService provides API for sidechain monitoring and fast withdrawal detection
abstract final class SidechainService {
  /// Fully-qualified name of the SidechainService service.
  static const name = 'sidechain.v1.SidechainService';

  /// GetDetectedWithdrawals returns all detected fast withdrawal transactions
  static const getDetectedWithdrawals = connect.Spec(
    '/$name/GetDetectedWithdrawals',
    connect.StreamType.unary,
    sidechainv1sidechain.GetDetectedWithdrawalsRequest.new,
    sidechainv1sidechain.GetDetectedWithdrawalsResponse.new,
  );

  /// GetWithdrawalByTxid returns a specific withdrawal by transaction ID
  static const getWithdrawalByTxid = connect.Spec(
    '/$name/GetWithdrawalByTxid',
    connect.StreamType.unary,
    sidechainv1sidechain.GetWithdrawalByTxidRequest.new,
    sidechainv1sidechain.GetWithdrawalByTxidResponse.new,
  );
}
