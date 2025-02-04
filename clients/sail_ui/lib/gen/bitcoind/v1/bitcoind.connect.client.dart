//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitcoind.pb.dart" as bitcoindv1bitcoind;
import "bitcoind.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

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

  /// Lists the ten most recent blocks, lightly populated with data.
  Future<bitcoindv1bitcoind.ListRecentBlocksResponse> listRecentBlocks(
    bitcoindv1bitcoind.ListRecentBlocksRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listRecentBlocks,
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
}
