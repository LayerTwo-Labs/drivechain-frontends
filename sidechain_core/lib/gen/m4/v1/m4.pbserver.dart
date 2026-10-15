//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'm4.pb.dart' as $0;
import 'm4.pbjson.dart';

export 'm4.pb.dart';

abstract class M4ServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetM4HistoryResponse> getM4History($pb.ServerContext ctx, $0.GetM4HistoryRequest request);
  $async.Future<$0.GetVotesResponse> getVotes($pb.ServerContext ctx, $0.GetVotesRequest request);
  $async.Future<$0.SetBundleUpvoteResponse> setBundleUpvote($pb.ServerContext ctx, $0.SetBundleUpvoteRequest request);
  $async.Future<$0.SetVotePolicyResponse> setVotePolicy($pb.ServerContext ctx, $0.SetVotePolicyRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetM4History': return $0.GetM4HistoryRequest();
      case 'GetVotes': return $0.GetVotesRequest();
      case 'SetBundleUpvote': return $0.SetBundleUpvoteRequest();
      case 'SetVotePolicy': return $0.SetVotePolicyRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetM4History': return this.getM4History(ctx, request as $0.GetM4HistoryRequest);
      case 'GetVotes': return this.getVotes(ctx, request as $0.GetVotesRequest);
      case 'SetBundleUpvote': return this.setBundleUpvote(ctx, request as $0.SetBundleUpvoteRequest);
      case 'SetVotePolicy': return this.setVotePolicy(ctx, request as $0.SetVotePolicyRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => M4ServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => M4ServiceBase$messageJson;
}

