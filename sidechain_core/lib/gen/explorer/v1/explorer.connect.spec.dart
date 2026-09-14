//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
//

import "package:connectrpc/connect.dart" as connect;
import "explorer.pb.dart" as explorerv1explorer;

/// ExplorerService serves a block explorer for one sidechain.
/// A light client runs no node, so it reads a hosted index. A full node answers
/// from its own chain, and a node keeps no address history, so the address call
/// needs an index either way.
abstract final class ExplorerService {
  /// Fully-qualified name of the ExplorerService service.
  static const name = 'explorer.v1.ExplorerService';

  /// GetOverview answers the explorer landing page: the newest blocks, what
  /// happened last, and what the treasury holds.
  static const getOverview = connect.Spec(
    '/$name/GetOverview',
    connect.StreamType.unary,
    explorerv1explorer.GetOverviewRequest.new,
    explorerv1explorer.GetOverviewResponse.new,
  );

  /// GetBlock reads one block and what it carried. The request names either a
  /// hash or a height.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    explorerv1explorer.GetBlockRequest.new,
    explorerv1explorer.GetBlockResponse.new,
  );

  /// ListBlocks reads a page of block headers, newest first, so a reader can
  /// walk back to the genesis block.
  static const listBlocks = connect.Spec(
    '/$name/ListBlocks',
    connect.StreamType.unary,
    explorerv1explorer.ListBlocksRequest.new,
    explorerv1explorer.ListBlocksResponse.new,
  );

  /// GetTransaction reads one transaction, with the coins on both sides.
  static const getTransaction = connect.Spec(
    '/$name/GetTransaction',
    connect.StreamType.unary,
    explorerv1explorer.GetTransactionRequest.new,
    explorerv1explorer.GetTransactionResponse.new,
  );

  /// GetSignedTransaction exports a transaction with its stored signatures.
  static const getSignedTransaction = connect.Spec(
    '/$name/GetSignedTransaction',
    connect.StreamType.unary,
    explorerv1explorer.GetSignedTransactionRequest.new,
    explorerv1explorer.GetSignedTransactionResponse.new,
  );

  /// RebroadcastTransaction sends a pending transaction to connected peers.
  static const rebroadcastTransaction = connect.Spec(
    '/$name/RebroadcastTransaction',
    connect.StreamType.unary,
    explorerv1explorer.RebroadcastTransactionRequest.new,
    explorerv1explorer.RebroadcastTransactionResponse.new,
  );

  /// BroadcastTransaction submits a signed transaction to the sidechain node.
  static const broadcastTransaction = connect.Spec(
    '/$name/BroadcastTransaction',
    connect.StreamType.unary,
    explorerv1explorer.BroadcastTransactionRequest.new,
    explorerv1explorer.BroadcastTransactionResponse.new,
  );

  /// GetAddress reads what an address holds and what it did. It needs an index,
  /// because no sidechain node keeps an address history.
  static const getAddress = connect.Spec(
    '/$name/GetAddress',
    connect.StreamType.unary,
    explorerv1explorer.GetAddressRequest.new,
    explorerv1explorer.GetAddressResponse.new,
  );

  /// GetWithdrawals reads the bundle the chain proposes to the mainchain.
  static const getWithdrawals = connect.Spec(
    '/$name/GetWithdrawals',
    connect.StreamType.unary,
    explorerv1explorer.GetWithdrawalsRequest.new,
    explorerv1explorer.GetWithdrawalsResponse.new,
  );
}
