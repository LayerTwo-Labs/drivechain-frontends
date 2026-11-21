//
//  Generated code. Do not modify.
//  source: mempool/v1/mempool.proto
//

import "package:connectrpc/connect.dart" as connect;

import "mempool.pb.dart" as mempoolv1mempool;

/// MempoolService reads the mainchain mempool from the memory of drivechaind.
/// Core's ZMQ sequence feed keeps that copy current.
abstract final class MempoolService {
  /// Fully-qualified name of the MempoolService service.
  static const name = 'mempool.v1.MempoolService';

  /// ListTransactions gives the newest mempool transactions, newest first.
  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    mempoolv1mempool.ListTransactionsRequest.new,
    mempoolv1mempool.ListTransactionsResponse.new,
  );

  /// GetStats gives the size of the mempool and its fee rate buckets.
  static const getStats = connect.Spec(
    '/$name/GetStats',
    connect.StreamType.unary,
    mempoolv1mempool.GetStatsRequest.new,
    mempoolv1mempool.GetStatsResponse.new,
  );

  /// WatchTransactions sends the full mempool, then each change. A new full
  /// mempool replaces the old one.
  static const watchTransactions = connect.Spec(
    '/$name/WatchTransactions',
    connect.StreamType.server,
    mempoolv1mempool.WatchTransactionsRequest.new,
    mempoolv1mempool.WatchTransactionsResponse.new,
  );
}
