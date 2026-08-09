import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.connect.client.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pbenum.dart';

/// Blind merged mining, served by the orchestrator's BMMService. Bidding runs
/// in the backend: [start] turns it on and [watch] reports what it does.
class OrchestratorBmmRPC {
  late BMMServiceClient _unaryClient;
  late BMMServiceClient _streamClient;

  OrchestratorBmmRPC.fromTransports({
    required connect.Transport unary,
    required connect.Transport stream,
  }) {
    _unaryClient = BMMServiceClient(unary);
    _streamClient = BMMServiceClient(stream);
  }

  /// Bid on every new mainchain tip until [stop], raising toward [maxBidSats]
  /// when a competitor outbids us.
  Future<void> start({
    required BinaryType sidechain,
    required int minBidSats,
    required int maxBidSats,
  }) async {
    await _unaryClient.start(
      bmmpb.StartRequest(
        sidechain: sidechain,
        minBidSats: Int64(minBidSats),
        maxBidSats: Int64(maxBidSats),
      ),
    );
  }

  Future<void> stop(BinaryType sidechain) async {
    await _unaryClient.stop(bmmpb.StopRequest(sidechain: sidechain));
  }

  Future<void> clearHistory(BinaryType sidechain) async {
    await _unaryClient.clearHistory(bmmpb.ClearHistoryRequest(sidechain: sidechain));
  }

  /// The round being bid on plus recent finished rounds. Every frame carries
  /// the full state, so a reconnect needs no merge.
  Stream<bmmpb.WatchResponse> watch(BinaryType sidechain) {
    return _streamClient.watch(bmmpb.WatchRequest(sidechain: sidechain));
  }

  /// Every bid seen for one round, for the "see all bids" drilldown.
  Future<bmmpb.Round> roundBids({
    required BinaryType sidechain,
    required String prevMainHash,
  }) async {
    final resp = await _unaryClient.getRoundBids(
      bmmpb.GetRoundBidsRequest(sidechain: sidechain, prevMainHash: prevMainHash),
    );
    return resp.round;
  }

  /// One bid, outside the automated loop.
  Future<bmmpb.CreateBidResponse> createBid({
    required BinaryType sidechain,
    required int bidSats,
    String? walletId,
    String? replaceTxid,
  }) {
    return _unaryClient.createBid(
      bmmpb.CreateBidRequest(
        sidechain: sidechain,
        walletId: walletId ?? '',
        bidSats: Int64(bidSats),
        replaceTxid: replaceTxid ?? '',
      ),
    );
  }

  /// Bids on a slot with a commitment to no real block. Demonstrates the BMM
  /// stall attack; the backend rejects it on mainnet.
  Future<bmmpb.GriefBidResponse> griefBid({
    required BinaryType sidechain,
    required int bidSats,
    String? walletId,
  }) {
    return _unaryClient.griefBid(
      bmmpb.GriefBidRequest(
        sidechain: sidechain,
        walletId: walletId ?? '',
        bidSats: Int64(bidSats),
      ),
    );
  }
}
