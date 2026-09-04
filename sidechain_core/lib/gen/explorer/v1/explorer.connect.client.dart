//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
//

import "package:connectrpc/connect.dart" as connect;
import "explorer.pb.dart" as explorerv1explorer;
import "explorer.connect.spec.dart" as specs;

/// ExplorerService serves a block explorer for one sidechain.
/// A light client runs no node, so it reads a hosted index. A full node answers
/// from its own chain, and a node keeps no address history, so the address call
/// needs an index either way.
extension type ExplorerServiceClient (connect.Transport _transport) {
  /// GetOverview answers the explorer landing page: the newest blocks, what
  /// happened last, and what the treasury holds.
  Future<explorerv1explorer.GetOverviewResponse> getOverview(
    explorerv1explorer.GetOverviewRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExplorerService.getOverview,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// GetBlock reads one block and what it carried. The request names either a
  /// hash or a height.
  Future<explorerv1explorer.GetBlockResponse> getBlock(
    explorerv1explorer.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExplorerService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// GetTransaction reads one transaction, with the coins on both sides.
  Future<explorerv1explorer.GetTransactionResponse> getTransaction(
    explorerv1explorer.GetTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExplorerService.getTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// GetAddress reads what an address holds and what it did. It needs an index,
  /// because no sidechain node keeps an address history.
  Future<explorerv1explorer.GetAddressResponse> getAddress(
    explorerv1explorer.GetAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExplorerService.getAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// GetWithdrawals reads the bundle the chain proposes to the mainchain.
  Future<explorerv1explorer.GetWithdrawalsResponse> getWithdrawals(
    explorerv1explorer.GetWithdrawalsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExplorerService.getWithdrawals,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
