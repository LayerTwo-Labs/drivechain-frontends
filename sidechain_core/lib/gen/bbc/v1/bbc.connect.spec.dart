//
//  Generated code. Do not modify.
//  source: bbc/v1/bbc.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bbc.pb.dart" as bbcv1bbc;

/// Big Block Covenant is a Bitcoin Core fork run as a drivechain sidechain, so its RPC
/// surface is Core's rather than the CUSF one the other sidechains expose.
abstract final class BbcService {
  /// Fully-qualified name of the BbcService service.
  static const name = 'bbc.v1.BbcService';

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    bbcv1bbc.GetBlockCountRequest.new,
    bbcv1bbc.GetBlockCountResponse.new,
  );

  /// Get the node's chain state.
  static const getBlockchainInfo = connect.Spec(
    '/$name/GetBlockchainInfo',
    connect.StreamType.unary,
    bbcv1bbc.GetBlockchainInfoRequest.new,
    bbcv1bbc.GetBlockchainInfoResponse.new,
  );

  /// Report whether the node has caught up with the mainchain.
  static const getSidechainInfo = connect.Spec(
    '/$name/GetSidechainInfo',
    connect.StreamType.unary,
    bbcv1bbc.GetSidechainInfoRequest.new,
    bbcv1bbc.GetSidechainInfoResponse.new,
  );

  /// Get the mainchain block hash the node is following.
  static const getMainchainTip = connect.Spec(
    '/$name/GetMainchainTip',
    connect.StreamType.unary,
    bbcv1bbc.GetMainchainTipRequest.new,
    bbcv1bbc.GetMainchainTipResponse.new,
  );

  /// Get the sidechain block a mainchain block commits to, empty when none.
  static const getBmmCommitment = connect.Spec(
    '/$name/GetBmmCommitment',
    connect.StreamType.unary,
    bbcv1bbc.GetBmmCommitmentRequest.new,
    bbcv1bbc.GetBmmCommitmentResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    bbcv1bbc.GetNewAddressRequest.new,
    bbcv1bbc.GetNewAddressResponse.new,
  );

  /// Send to a sidechain address.
  static const send = connect.Spec(
    '/$name/Send',
    connect.StreamType.unary,
    bbcv1bbc.SendRequest.new,
    bbcv1bbc.SendResponse.new,
  );

  /// Estimate the fee rate in sats per kvB.
  static const estimateFee = connect.Spec(
    '/$name/EstimateFee',
    connect.StreamType.unary,
    bbcv1bbc.EstimateFeeRequest.new,
    bbcv1bbc.EstimateFeeResponse.new,
  );

  /// List wallet UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    bbcv1bbc.ListUtxosRequest.new,
    bbcv1bbc.ListUtxosResponse.new,
  );

  /// List wallet transactions, most recent first.
  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    bbcv1bbc.ListTransactionsRequest.new,
    bbcv1bbc.ListTransactionsResponse.new,
  );

  /// Stop the node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    bbcv1bbc.StopRequest.new,
    bbcv1bbc.StopResponse.new,
  );
}
