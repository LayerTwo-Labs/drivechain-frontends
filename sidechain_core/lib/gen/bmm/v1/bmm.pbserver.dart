//
//  Generated code. Do not modify.
//  source: bmm/v1/bmm.proto
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

import 'bmm.pb.dart' as $3;
import 'bmm.pbjson.dart';

export 'bmm.pb.dart';

abstract class BMMServiceBase extends $pb.GeneratedService {
  $async.Future<$3.StartResponse> start($pb.ServerContext ctx, $3.StartRequest request);
  $async.Future<$3.StopResponse> stop($pb.ServerContext ctx, $3.StopRequest request);
  $async.Future<$3.ClearHistoryResponse> clearHistory($pb.ServerContext ctx, $3.ClearHistoryRequest request);
  $async.Future<$3.WatchResponse> watch($pb.ServerContext ctx, $3.WatchRequest request);
  $async.Future<$3.GetRoundBidsResponse> getRoundBids($pb.ServerContext ctx, $3.GetRoundBidsRequest request);
  $async.Future<$3.CreateBidResponse> createBid($pb.ServerContext ctx, $3.CreateBidRequest request);
  $async.Future<$3.ConnectBidResponse> connectBid($pb.ServerContext ctx, $3.ConnectBidRequest request);
  $async.Future<$3.ListBidsResponse> listBids($pb.ServerContext ctx, $3.ListBidsRequest request);
  $async.Future<$3.AttackBidResponse> attackBid($pb.ServerContext ctx, $3.AttackBidRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Start': return $3.StartRequest();
      case 'Stop': return $3.StopRequest();
      case 'ClearHistory': return $3.ClearHistoryRequest();
      case 'Watch': return $3.WatchRequest();
      case 'GetRoundBids': return $3.GetRoundBidsRequest();
      case 'CreateBid': return $3.CreateBidRequest();
      case 'ConnectBid': return $3.ConnectBidRequest();
      case 'ListBids': return $3.ListBidsRequest();
      case 'AttackBid': return $3.AttackBidRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Start': return this.start(ctx, request as $3.StartRequest);
      case 'Stop': return this.stop(ctx, request as $3.StopRequest);
      case 'ClearHistory': return this.clearHistory(ctx, request as $3.ClearHistoryRequest);
      case 'Watch': return this.watch(ctx, request as $3.WatchRequest);
      case 'GetRoundBids': return this.getRoundBids(ctx, request as $3.GetRoundBidsRequest);
      case 'CreateBid': return this.createBid(ctx, request as $3.CreateBidRequest);
      case 'ConnectBid': return this.connectBid(ctx, request as $3.ConnectBidRequest);
      case 'ListBids': return this.listBids(ctx, request as $3.ListBidsRequest);
      case 'AttackBid': return this.attackBid(ctx, request as $3.AttackBidRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BMMServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BMMServiceBase$messageJson;
}

