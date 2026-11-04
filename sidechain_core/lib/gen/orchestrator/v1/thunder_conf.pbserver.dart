// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/thunder_conf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'thunder_conf.pb.dart' as $0;
import 'thunder_conf.pbjson.dart';

export 'thunder_conf.pb.dart';

abstract class ThunderConfServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetThunderConfigResponse> getThunderConfig(
      $pb.ServerContext ctx, $0.GetThunderConfigRequest request);
  $async.Future<$0.WriteThunderConfigResponse> writeThunderConfig(
      $pb.ServerContext ctx, $0.WriteThunderConfigRequest request);
  $async.Future<$0.SyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
      $pb.ServerContext ctx, $0.SyncNetworkFromBitcoinConfRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetThunderConfig':
        return $0.GetThunderConfigRequest();
      case 'WriteThunderConfig':
        return $0.WriteThunderConfigRequest();
      case 'SyncNetworkFromBitcoinConf':
        return $0.SyncNetworkFromBitcoinConfRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetThunderConfig':
        return getThunderConfig(ctx, request as $0.GetThunderConfigRequest);
      case 'WriteThunderConfig':
        return writeThunderConfig(ctx, request as $0.WriteThunderConfigRequest);
      case 'SyncNetworkFromBitcoinConf':
        return syncNetworkFromBitcoinConf(ctx, request as $0.SyncNetworkFromBitcoinConfRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      ThunderConfServiceBase$messageJson;
}
