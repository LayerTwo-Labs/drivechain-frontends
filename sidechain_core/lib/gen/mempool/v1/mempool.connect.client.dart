//
//  Generated code. Do not modify.
//  source: mempool/v1/mempool.proto
//

import "package:connectrpc/connect.dart" as connect;

import "mempool.pb.dart" as mempoolv1mempool;
import "mempool.connect.spec.dart" as specs;

/// MempoolService reads the mainchain mempool from the memory of drivechaind.
/// Core's ZMQ sequence feed keeps that copy current.
extension type MempoolServiceClient(connect.Transport _transport) {
  /// ListTransactions gives the newest mempool transactions, newest first.
  Future<mempoolv1mempool.ListTransactionsResponse> listTransactions(
    mempoolv1mempool.ListTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MempoolService.listTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// GetStats gives the size of the mempool and its fee rate buckets.
  Future<mempoolv1mempool.GetStatsResponse> getStats(
    mempoolv1mempool.GetStatsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MempoolService.getStats,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// WatchTransactions sends the full mempool, then each change. A new full
  /// mempool replaces the old one.
  Stream<mempoolv1mempool.WatchTransactionsResponse> watchTransactions(
    mempoolv1mempool.WatchTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.MempoolService.watchTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
