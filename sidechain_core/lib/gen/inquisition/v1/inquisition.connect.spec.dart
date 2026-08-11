//
//  Generated code. Do not modify.
//  source: inquisition/v1/inquisition.proto
//

import "package:connectrpc/connect.dart" as connect;
import "inquisition.pb.dart" as inquisitionv1inquisition;

/// Inquisition is a Bitcoin Core fork run as a drivechain sidechain, so its RPC
/// surface is Core's rather than the CUSF one the other sidechains expose.
abstract final class InquisitionService {
  /// Fully-qualified name of the InquisitionService service.
  static const name = 'inquisition.v1.InquisitionService';

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    inquisitionv1inquisition.GetBlockCountRequest.new,
    inquisitionv1inquisition.GetBlockCountResponse.new,
  );

  /// Get the node's chain state.
  static const getBlockchainInfo = connect.Spec(
    '/$name/GetBlockchainInfo',
    connect.StreamType.unary,
    inquisitionv1inquisition.GetBlockchainInfoRequest.new,
    inquisitionv1inquisition.GetBlockchainInfoResponse.new,
  );

  /// Report whether the node has caught up with the mainchain.
  static const getSidechainInfo = connect.Spec(
    '/$name/GetSidechainInfo',
    connect.StreamType.unary,
    inquisitionv1inquisition.GetSidechainInfoRequest.new,
    inquisitionv1inquisition.GetSidechainInfoResponse.new,
  );

  /// Get the mainchain block hash the node is following.
  static const getMainchainTip = connect.Spec(
    '/$name/GetMainchainTip',
    connect.StreamType.unary,
    inquisitionv1inquisition.GetMainchainTipRequest.new,
    inquisitionv1inquisition.GetMainchainTipResponse.new,
  );

  /// Get the sidechain block a mainchain block commits to, empty when none.
  static const getBmmCommitment = connect.Spec(
    '/$name/GetBmmCommitment',
    connect.StreamType.unary,
    inquisitionv1inquisition.GetBmmCommitmentRequest.new,
    inquisitionv1inquisition.GetBmmCommitmentResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    inquisitionv1inquisition.GetNewAddressRequest.new,
    inquisitionv1inquisition.GetNewAddressResponse.new,
  );

  /// Send to a sidechain address.
  static const send = connect.Spec(
    '/$name/Send',
    connect.StreamType.unary,
    inquisitionv1inquisition.SendRequest.new,
    inquisitionv1inquisition.SendResponse.new,
  );

  /// Estimate the fee rate in sats per kvB.
  static const estimateFee = connect.Spec(
    '/$name/EstimateFee',
    connect.StreamType.unary,
    inquisitionv1inquisition.EstimateFeeRequest.new,
    inquisitionv1inquisition.EstimateFeeResponse.new,
  );

  /// List wallet UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    inquisitionv1inquisition.ListUtxosRequest.new,
    inquisitionv1inquisition.ListUtxosResponse.new,
  );

  /// List wallet transactions, most recent first.
  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    inquisitionv1inquisition.ListTransactionsRequest.new,
    inquisitionv1inquisition.ListTransactionsResponse.new,
  );

  /// Stop the node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    inquisitionv1inquisition.StopRequest.new,
    inquisitionv1inquisition.StopResponse.new,
  );
}
