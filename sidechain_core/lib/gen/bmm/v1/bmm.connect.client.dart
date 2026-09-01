//
//  Generated code. Do not modify.
//  source: bmm/v1/bmm.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bmm.pb.dart" as bmmv1bmm;
import "bmm.connect.spec.dart" as specs;

/// BMMService drives blind merged mining for a sidechain, paid for by any
/// wallet rather than the enforcer's. A bid is an M8 whose fee buys inclusion;
/// the block it commits to connects once a miner takes that M8.
/// A bid names the mainchain tip it was built on, so it is only valid in the
/// very next block. A round is one such tip: every bid competing for it, and
/// what became of them.
extension type BMMServiceClient (connect.Transport _transport) {
  /// Start bids on every new mainchain tip and connects the blocks miners take,
  /// until Stop. Bids are funded by the wallet the request names, and are
  /// opened at Core's next block fee and raised toward max_bid_sats when a
  /// competitor outbids us.
  Future<bmmv1bmm.StartResponse> start(
    bmmv1bmm.StartRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BMMService.start,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bmmv1bmm.StopResponse> stop(
    bmmv1bmm.StopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BMMService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bmmv1bmm.ClearHistoryResponse> clearHistory(
    bmmv1bmm.ClearHistoryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BMMService.clearHistory,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Watch streams the round being bid on now plus recent finished rounds. The
  /// full state goes out on every frame, so a reconnect needs no delta merge.
  Stream<bmmv1bmm.WatchResponse> watch(
    bmmv1bmm.WatchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.BMMService.watch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// GetRoundBids returns every bid seen for one round. A losing bid never
  /// confirms and leaves the mempool, so this is limited to what was observed
  /// while that round was open.
  Future<bmmv1bmm.GetRoundBidsResponse> getRoundBids(
    bmmv1bmm.GetRoundBidsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BMMService.getRoundBids,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// CreateBid assembles a sidechain block and broadcasts one M8 bid for it;
  /// ConnectBid connects that block once a miner includes the bid. Use these to
  /// drive a single attempt by hand; Start does both on a loop.
  Future<bmmv1bmm.CreateBidResponse> createBid(
    bmmv1bmm.CreateBidRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BMMService.createBid,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bmmv1bmm.ConnectBidResponse> connectBid(
    bmmv1bmm.ConnectBidRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BMMService.connectBid,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ListBids reads the competing bids for the slot out of the mainchain
  /// mempool, highest bid first.
  Future<bmmv1bmm.ListBidsResponse> listBids(
    bmmv1bmm.ListBidsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BMMService.listBids,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
