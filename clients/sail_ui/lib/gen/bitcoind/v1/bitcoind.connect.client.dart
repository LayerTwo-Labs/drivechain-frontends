//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart' as bitcoindv1bitcoind;
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.connect.spec.dart' as specs;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;

extension type BitcoindServiceClient (connect.Transport _transport) {
  /// Lists the ten most recent transactions, both confirmed and unconfirmed.
  Future<bitcoindv1bitcoind.ListRecentTransactionsResponse> listRecentTransactions(
    bitcoindv1bitcoind.ListRecentTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listRecentTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists blocks with pagination support
  Future<bitcoindv1bitcoind.ListBlocksResponse> listBlocks(
    bitcoindv1bitcoind.ListBlocksRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listBlocks,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a specific block by hash or height
  Future<bitcoindv1bitcoind.GetBlockResponse> getBlock(
    bitcoindv1bitcoind.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get basic blockchain info like height, last block time, peers etc.
  Future<bitcoindv1bitcoind.GetBlockchainInfoResponse> getBlockchainInfo(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getBlockchainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists very basic info about all peers
  Future<bitcoindv1bitcoind.ListPeersResponse> listPeers(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listPeers,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists very basic info about all peers
  Future<bitcoindv1bitcoind.EstimateSmartFeeResponse> estimateSmartFee(
    bitcoindv1bitcoind.EstimateSmartFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.estimateSmartFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.GetRawTransactionResponse> getRawTransaction(
    bitcoindv1bitcoind.GetRawTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getRawTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
