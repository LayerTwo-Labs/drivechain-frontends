//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
//

import "package:connectrpc/connect.dart" as connect;
import "m4.pb.dart" as m4v1m4;
import "m4.connect.spec.dart" as specs;

/// M4 Explorer Service
extension type M4ServiceClient (connect.Transport _transport) {
  /// Get M4 voting history
  Future<m4v1m4.GetM4HistoryResponse> getM4History(
    m4v1m4.GetM4HistoryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.getM4History,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the votes the enforcer puts in the next block it builds.
  Future<m4v1m4.GetVotesResponse> getVotes(
    m4v1m4.GetVotesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.getVotes,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Upvote one pending bundle of a sidechain, or clear the upvote.
  Future<m4v1m4.SetBundleUpvoteResponse> setBundleUpvote(
    m4v1m4.SetBundleUpvoteRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.setBundleUpvote,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set the vote for a sidechain that has no upvote.
  Future<m4v1m4.SetVotePolicyResponse> setVotePolicy(
    m4v1m4.SetVotePolicyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.setVotePolicy,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
