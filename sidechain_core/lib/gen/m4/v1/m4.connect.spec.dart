//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
//

import "package:connectrpc/connect.dart" as connect;
import "m4.pb.dart" as m4v1m4;

/// M4 Explorer Service
abstract final class M4Service {
  /// Fully-qualified name of the M4Service service.
  static const name = 'm4.v1.M4Service';

  /// Get M4 voting history
  static const getM4History = connect.Spec(
    '/$name/GetM4History',
    connect.StreamType.unary,
    m4v1m4.GetM4HistoryRequest.new,
    m4v1m4.GetM4HistoryResponse.new,
  );

  /// Get the votes the enforcer puts in the next block it builds.
  static const getVotes = connect.Spec(
    '/$name/GetVotes',
    connect.StreamType.unary,
    m4v1m4.GetVotesRequest.new,
    m4v1m4.GetVotesResponse.new,
  );

  /// Upvote one pending bundle of a sidechain, or clear the upvote.
  static const setBundleUpvote = connect.Spec(
    '/$name/SetBundleUpvote',
    connect.StreamType.unary,
    m4v1m4.SetBundleUpvoteRequest.new,
    m4v1m4.SetBundleUpvoteResponse.new,
  );

  /// Set the vote for a sidechain that has no upvote.
  static const setVotePolicy = connect.Spec(
    '/$name/SetVotePolicy',
    connect.StreamType.unary,
    m4v1m4.SetVotePolicyRequest.new,
    m4v1m4.SetVotePolicyResponse.new,
  );
}
