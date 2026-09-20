//
//  Generated code. Do not modify.
//  source: stratum/v1/stratum.proto
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

import 'stratum.pb.dart' as $15;
import 'stratum.pbjson.dart';

export 'stratum.pb.dart';

abstract class StratumServiceBase extends $pb.GeneratedService {
  $async.Future<$15.StartStratumResponse> startStratum($pb.ServerContext ctx, $15.StartStratumRequest request);
  $async.Future<$15.StopStratumResponse> stopStratum($pb.ServerContext ctx, $15.StopStratumRequest request);
  $async.Future<$15.GetStratumStatusResponse> getStratumStatus($pb.ServerContext ctx, $15.GetStratumStatusRequest request);
  $async.Future<$15.SetTargetResponse> setTarget($pb.ServerContext ctx, $15.SetTargetRequest request);
  $async.Future<$15.ListTargetsResponse> listTargets($pb.ServerContext ctx, $15.ListTargetsRequest request);
  $async.Future<$15.SetWorkModeResponse> setWorkMode($pb.ServerContext ctx, $15.SetWorkModeRequest request);
  $async.Future<$15.SetMiningSettingsResponse> setMiningSettings($pb.ServerContext ctx, $15.SetMiningSettingsRequest request);
  $async.Future<$15.GetHashrateHistoryResponse> getHashrateHistory($pb.ServerContext ctx, $15.GetHashrateHistoryRequest request);
  $async.Future<$15.ListPoolBlocksResponse> listPoolBlocks($pb.ServerContext ctx, $15.ListPoolBlocksRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'StartStratum': return $15.StartStratumRequest();
      case 'StopStratum': return $15.StopStratumRequest();
      case 'GetStratumStatus': return $15.GetStratumStatusRequest();
      case 'SetTarget': return $15.SetTargetRequest();
      case 'ListTargets': return $15.ListTargetsRequest();
      case 'SetWorkMode': return $15.SetWorkModeRequest();
      case 'SetMiningSettings': return $15.SetMiningSettingsRequest();
      case 'GetHashrateHistory': return $15.GetHashrateHistoryRequest();
      case 'ListPoolBlocks': return $15.ListPoolBlocksRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'StartStratum': return this.startStratum(ctx, request as $15.StartStratumRequest);
      case 'StopStratum': return this.stopStratum(ctx, request as $15.StopStratumRequest);
      case 'GetStratumStatus': return this.getStratumStatus(ctx, request as $15.GetStratumStatusRequest);
      case 'SetTarget': return this.setTarget(ctx, request as $15.SetTargetRequest);
      case 'ListTargets': return this.listTargets(ctx, request as $15.ListTargetsRequest);
      case 'SetWorkMode': return this.setWorkMode(ctx, request as $15.SetWorkModeRequest);
      case 'SetMiningSettings': return this.setMiningSettings(ctx, request as $15.SetMiningSettingsRequest);
      case 'GetHashrateHistory': return this.getHashrateHistory(ctx, request as $15.GetHashrateHistoryRequest);
      case 'ListPoolBlocks': return this.listPoolBlocks(ctx, request as $15.ListPoolBlocksRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => StratumServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => StratumServiceBase$messageJson;
}

