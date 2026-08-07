//
//  Generated code. Do not modify.
//  source: bmm/v1/bmm.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bmm.pb.dart" as bmmv1bmm;

/// BMMService drives blind merged mining for a sidechain, paid for by any
/// wallet rather than the enforcer's. A bid is an M8 whose fee buys inclusion;
/// the block it commits to connects once a miner takes that M8.
/// A bid names the mainchain tip it was built on, so it is only valid in the
/// very next block. A round is one such tip: every bid competing for it, and
/// what became of them.
abstract final class BMMService {
  /// Fully-qualified name of the BMMService service.
  static const name = 'bmm.v1.BMMService';

  /// Start bids on every new mainchain tip and connects the blocks miners take,
  /// until Stop. Bids are funded by whichever wallet is active at the time, and
  /// are raised toward max_bid_sats when a competitor outbids us.
  static const start = connect.Spec(
    '/$name/Start',
    connect.StreamType.unary,
    bmmv1bmm.StartRequest.new,
    bmmv1bmm.StartResponse.new,
  );

  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    bmmv1bmm.StopRequest.new,
    bmmv1bmm.StopResponse.new,
  );

  static const clearHistory = connect.Spec(
    '/$name/ClearHistory',
    connect.StreamType.unary,
    bmmv1bmm.ClearHistoryRequest.new,
    bmmv1bmm.ClearHistoryResponse.new,
  );

  /// Watch streams the round being bid on now plus recent finished rounds. The
  /// full state goes out on every frame, so a reconnect needs no delta merge.
  static const watch = connect.Spec(
    '/$name/Watch',
    connect.StreamType.server,
    bmmv1bmm.WatchRequest.new,
    bmmv1bmm.WatchResponse.new,
  );

  /// GetRoundBids returns every bid seen for one round. A losing bid never
  /// confirms and leaves the mempool, so this is limited to what was observed
  /// while that round was open.
  static const getRoundBids = connect.Spec(
    '/$name/GetRoundBids',
    connect.StreamType.unary,
    bmmv1bmm.GetRoundBidsRequest.new,
    bmmv1bmm.GetRoundBidsResponse.new,
  );

  /// CreateBid assembles a sidechain block and broadcasts one M8 bid for it;
  /// ConnectBid connects that block once a miner includes the bid. Use these to
  /// drive a single attempt by hand; Start does both on a loop.
  static const createBid = connect.Spec(
    '/$name/CreateBid',
    connect.StreamType.unary,
    bmmv1bmm.CreateBidRequest.new,
    bmmv1bmm.CreateBidResponse.new,
  );

  static const connectBid = connect.Spec(
    '/$name/ConnectBid',
    connect.StreamType.unary,
    bmmv1bmm.ConnectBidRequest.new,
    bmmv1bmm.ConnectBidResponse.new,
  );

  /// ListBids reads the competing bids for the slot out of the mainchain
  /// mempool, highest bid first.
  static const listBids = connect.Spec(
    '/$name/ListBids',
    connect.StreamType.unary,
    bmmv1bmm.ListBidsRequest.new,
    bmmv1bmm.ListBidsResponse.new,
  );

  /// GriefBid bids on a slot with a commitment to no real block, then never
  /// connects it, so an honest block loses the slot for that mainchain block.
  /// A teaching tool for the BMM stall attack; rejected on mainnet.
  static const griefBid = connect.Spec(
    '/$name/GriefBid',
    connect.StreamType.unary,
    bmmv1bmm.GriefBidRequest.new,
    bmmv1bmm.GriefBidResponse.new,
  );
}
