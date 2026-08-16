//
//  Generated code. Do not modify.
//  source: inquisition/v1/inquisition.proto
//

import "package:connectrpc/connect.dart" as connect;
import "inquisition.pb.dart" as inquisitionv1inquisition;
import "inquisition.connect.spec.dart" as specs;

/// Inquisition is a Bitcoin Core fork run as a drivechain sidechain, so its RPC
/// surface is Core's rather than the CUSF one the other sidechains expose.
extension type InquisitionServiceClient(connect.Transport _transport) {
  /// Get current block count.
  Future<inquisitionv1inquisition.GetBlockCountResponse> getBlockCount(
    inquisitionv1inquisition.GetBlockCountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.getBlockCount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the node's chain state.
  Future<inquisitionv1inquisition.GetBlockchainInfoResponse> getBlockchainInfo(
    inquisitionv1inquisition.GetBlockchainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.getBlockchainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Report whether the node has caught up with the mainchain.
  Future<inquisitionv1inquisition.GetSidechainInfoResponse> getSidechainInfo(
    inquisitionv1inquisition.GetSidechainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.getSidechainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the mainchain block hash the node is following.
  Future<inquisitionv1inquisition.GetMainchainTipResponse> getMainchainTip(
    inquisitionv1inquisition.GetMainchainTipRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.getMainchainTip,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the sidechain block a mainchain block commits to, empty when none.
  Future<inquisitionv1inquisition.GetBmmCommitmentResponse> getBmmCommitment(
    inquisitionv1inquisition.GetBmmCommitmentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.getBmmCommitment,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new address from the wallet.
  Future<inquisitionv1inquisition.GetNewAddressResponse> getNewAddress(
    inquisitionv1inquisition.GetNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Send to a sidechain address.
  Future<inquisitionv1inquisition.SendResponse> send(
    inquisitionv1inquisition.SendRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.send,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Estimate the fee rate in sats per kvB.
  Future<inquisitionv1inquisition.EstimateFeeResponse> estimateFee(
    inquisitionv1inquisition.EstimateFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.estimateFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List wallet UTXOs.
  Future<inquisitionv1inquisition.ListUtxosResponse> listUtxos(
    inquisitionv1inquisition.ListUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.listUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List wallet transactions, most recent first.
  Future<inquisitionv1inquisition.ListTransactionsResponse> listTransactions(
    inquisitionv1inquisition.ListTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.listTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stop the node.
  Future<inquisitionv1inquisition.StopResponse> stop(
    inquisitionv1inquisition.StopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.InquisitionService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
