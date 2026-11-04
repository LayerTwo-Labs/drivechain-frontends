// This is a generated file - do not edit.
//
// Generated from bmm/v1/bmm.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'bmm.pb.dart' as $1;
import 'bmm.pbjson.dart';

export 'bmm.pb.dart';

abstract class BMMServiceBase extends $pb.GeneratedService {
  $async.Future<$1.StartResponse> start($pb.ServerContext ctx, $1.StartRequest request);
  $async.Future<$1.StopResponse> stop($pb.ServerContext ctx, $1.StopRequest request);
  $async.Future<$1.ClearHistoryResponse> clearHistory($pb.ServerContext ctx, $1.ClearHistoryRequest request);
  $async.Future<$1.WatchResponse> watch($pb.ServerContext ctx, $1.WatchRequest request);
  $async.Future<$1.GetRoundBidsResponse> getRoundBids($pb.ServerContext ctx, $1.GetRoundBidsRequest request);
  $async.Future<$1.CreateBidResponse> createBid($pb.ServerContext ctx, $1.CreateBidRequest request);
  $async.Future<$1.ConnectBidResponse> connectBid($pb.ServerContext ctx, $1.ConnectBidRequest request);
  $async.Future<$1.CancelBidResponse> cancelBid($pb.ServerContext ctx, $1.CancelBidRequest request);
  $async.Future<$1.ListBidsResponse> listBids($pb.ServerContext ctx, $1.ListBidsRequest request);
  $async.Future<$1.PrepareBMMResponse> prepareBMM($pb.ServerContext ctx, $1.PrepareBMMRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Start':
        return $1.StartRequest();
      case 'Stop':
        return $1.StopRequest();
      case 'ClearHistory':
        return $1.ClearHistoryRequest();
      case 'Watch':
        return $1.WatchRequest();
      case 'GetRoundBids':
        return $1.GetRoundBidsRequest();
      case 'CreateBid':
        return $1.CreateBidRequest();
      case 'ConnectBid':
        return $1.ConnectBidRequest();
      case 'CancelBid':
        return $1.CancelBidRequest();
      case 'ListBids':
        return $1.ListBidsRequest();
      case 'PrepareBMM':
        return $1.PrepareBMMRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Start':
        return start(ctx, request as $1.StartRequest);
      case 'Stop':
        return stop(ctx, request as $1.StopRequest);
      case 'ClearHistory':
        return clearHistory(ctx, request as $1.ClearHistoryRequest);
      case 'Watch':
        return watch(ctx, request as $1.WatchRequest);
      case 'GetRoundBids':
        return getRoundBids(ctx, request as $1.GetRoundBidsRequest);
      case 'CreateBid':
        return createBid(ctx, request as $1.CreateBidRequest);
      case 'ConnectBid':
        return connectBid(ctx, request as $1.ConnectBidRequest);
      case 'CancelBid':
        return cancelBid(ctx, request as $1.CancelBidRequest);
      case 'ListBids':
        return listBids(ctx, request as $1.ListBidsRequest);
      case 'PrepareBMM':
        return prepareBMM(ctx, request as $1.PrepareBMMRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BMMServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BMMServiceBase$messageJson;
}
