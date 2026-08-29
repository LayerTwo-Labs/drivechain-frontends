//
//  Generated code. Do not modify.
//  source: bbc/v1/bbc.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bbc.pb.dart" as bbcv1bbc;
import "bbc.connect.spec.dart" as specs;

/// Big Block Covenant is a Bitcoin Core fork run as a drivechain sidechain, so its RPC
/// surface is Core's rather than the CUSF one the other sidechains expose.
extension type BbcServiceClient (connect.Transport _transport) {
  /// Get current block count.
  Future<bbcv1bbc.GetBlockCountResponse> getBlockCount(
    bbcv1bbc.GetBlockCountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.getBlockCount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the node's chain state.
  Future<bbcv1bbc.GetBlockchainInfoResponse> getBlockchainInfo(
    bbcv1bbc.GetBlockchainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.getBlockchainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Report whether the node has caught up with the mainchain.
  Future<bbcv1bbc.GetSidechainInfoResponse> getSidechainInfo(
    bbcv1bbc.GetSidechainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.getSidechainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the mainchain block hash the node is following.
  Future<bbcv1bbc.GetMainchainTipResponse> getMainchainTip(
    bbcv1bbc.GetMainchainTipRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.getMainchainTip,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the sidechain block a mainchain block commits to, empty when none.
  Future<bbcv1bbc.GetBmmCommitmentResponse> getBmmCommitment(
    bbcv1bbc.GetBmmCommitmentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.getBmmCommitment,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new address from the wallet.
  Future<bbcv1bbc.GetNewAddressResponse> getNewAddress(
    bbcv1bbc.GetNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Send to a sidechain address.
  Future<bbcv1bbc.SendResponse> send(
    bbcv1bbc.SendRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.send,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Estimate the fee rate in sats per kvB.
  Future<bbcv1bbc.EstimateFeeResponse> estimateFee(
    bbcv1bbc.EstimateFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.estimateFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List wallet UTXOs.
  Future<bbcv1bbc.ListUtxosResponse> listUtxos(
    bbcv1bbc.ListUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.listUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List wallet transactions, most recent first.
  Future<bbcv1bbc.ListTransactionsResponse> listTransactions(
    bbcv1bbc.ListTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.listTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stop the node.
  Future<bbcv1bbc.StopResponse> stop(
    bbcv1bbc.StopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BbcService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
