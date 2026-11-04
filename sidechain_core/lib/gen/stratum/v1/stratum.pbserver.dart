// This is a generated file - do not edit.
//
// Generated from stratum/v1/stratum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'stratum.pb.dart' as $1;
import 'stratum.pbjson.dart';

export 'stratum.pb.dart';

abstract class StratumServiceBase extends $pb.GeneratedService {
  $async.Future<$1.StartStratumResponse> startStratum($pb.ServerContext ctx, $1.StartStratumRequest request);
  $async.Future<$1.StopStratumResponse> stopStratum($pb.ServerContext ctx, $1.StopStratumRequest request);
  $async.Future<$1.GetStratumStatusResponse> getStratumStatus(
      $pb.ServerContext ctx, $1.GetStratumStatusRequest request);
  $async.Future<$1.SetTargetResponse> setTarget($pb.ServerContext ctx, $1.SetTargetRequest request);
  $async.Future<$1.ListTargetsResponse> listTargets($pb.ServerContext ctx, $1.ListTargetsRequest request);
  $async.Future<$1.SetWorkModeResponse> setWorkMode($pb.ServerContext ctx, $1.SetWorkModeRequest request);
  $async.Future<$1.SetMiningSettingsResponse> setMiningSettings(
      $pb.ServerContext ctx, $1.SetMiningSettingsRequest request);
  $async.Future<$1.GetHashrateHistoryResponse> getHashrateHistory(
      $pb.ServerContext ctx, $1.GetHashrateHistoryRequest request);
  $async.Future<$1.ListPoolBlocksResponse> listPoolBlocks($pb.ServerContext ctx, $1.ListPoolBlocksRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'StartStratum':
        return $1.StartStratumRequest();
      case 'StopStratum':
        return $1.StopStratumRequest();
      case 'GetStratumStatus':
        return $1.GetStratumStatusRequest();
      case 'SetTarget':
        return $1.SetTargetRequest();
      case 'ListTargets':
        return $1.ListTargetsRequest();
      case 'SetWorkMode':
        return $1.SetWorkModeRequest();
      case 'SetMiningSettings':
        return $1.SetMiningSettingsRequest();
      case 'GetHashrateHistory':
        return $1.GetHashrateHistoryRequest();
      case 'ListPoolBlocks':
        return $1.ListPoolBlocksRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'StartStratum':
        return startStratum(ctx, request as $1.StartStratumRequest);
      case 'StopStratum':
        return stopStratum(ctx, request as $1.StopStratumRequest);
      case 'GetStratumStatus':
        return getStratumStatus(ctx, request as $1.GetStratumStatusRequest);
      case 'SetTarget':
        return setTarget(ctx, request as $1.SetTargetRequest);
      case 'ListTargets':
        return listTargets(ctx, request as $1.ListTargetsRequest);
      case 'SetWorkMode':
        return setWorkMode(ctx, request as $1.SetWorkModeRequest);
      case 'SetMiningSettings':
        return setMiningSettings(ctx, request as $1.SetMiningSettingsRequest);
      case 'GetHashrateHistory':
        return getHashrateHistory(ctx, request as $1.GetHashrateHistoryRequest);
      case 'ListPoolBlocks':
        return listPoolBlocks(ctx, request as $1.ListPoolBlocksRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => StratumServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => StratumServiceBase$messageJson;
}
