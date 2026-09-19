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

import 'stratum.pb.dart' as $1;
import 'stratum.pbjson.dart';

export 'stratum.pb.dart';

abstract class StratumServiceBase extends $pb.GeneratedService {
  $async.Future<$1.StartStratumResponse> startStratum($pb.ServerContext ctx, $1.StartStratumRequest request);
  $async.Future<$1.StopStratumResponse> stopStratum($pb.ServerContext ctx, $1.StopStratumRequest request);
  $async.Future<$1.GetStratumStatusResponse> getStratumStatus($pb.ServerContext ctx, $1.GetStratumStatusRequest request);
  $async.Future<$1.SetTargetResponse> setTarget($pb.ServerContext ctx, $1.SetTargetRequest request);
  $async.Future<$1.ListTargetsResponse> listTargets($pb.ServerContext ctx, $1.ListTargetsRequest request);
  $async.Future<$1.SetWorkModeResponse> setWorkMode($pb.ServerContext ctx, $1.SetWorkModeRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'StartStratum': return $1.StartStratumRequest();
      case 'StopStratum': return $1.StopStratumRequest();
      case 'GetStratumStatus': return $1.GetStratumStatusRequest();
      case 'SetTarget': return $1.SetTargetRequest();
      case 'ListTargets': return $1.ListTargetsRequest();
      case 'SetWorkMode': return $1.SetWorkModeRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'StartStratum': return this.startStratum(ctx, request as $1.StartStratumRequest);
      case 'StopStratum': return this.stopStratum(ctx, request as $1.StopStratumRequest);
      case 'GetStratumStatus': return this.getStratumStatus(ctx, request as $1.GetStratumStatusRequest);
      case 'SetTarget': return this.setTarget(ctx, request as $1.SetTargetRequest);
      case 'ListTargets': return this.listTargets(ctx, request as $1.ListTargetsRequest);
      case 'SetWorkMode': return this.setWorkMode(ctx, request as $1.SetWorkModeRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => StratumServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => StratumServiceBase$messageJson;
}

