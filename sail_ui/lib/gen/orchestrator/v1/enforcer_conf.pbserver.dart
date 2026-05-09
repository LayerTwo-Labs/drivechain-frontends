//
//  Generated code. Do not modify.
//  source: orchestrator/v1/enforcer_conf.proto
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

import 'enforcer_conf.pb.dart' as $4;
import 'enforcer_conf.pbjson.dart';

export 'enforcer_conf.pb.dart';

abstract class EnforcerConfServiceBase extends $pb.GeneratedService {
  $async.Future<$4.GetEnforcerConfigResponse> getEnforcerConfig($pb.ServerContext ctx, $4.GetEnforcerConfigRequest request);
  $async.Future<$4.WriteEnforcerConfigResponse> writeEnforcerConfig($pb.ServerContext ctx, $4.WriteEnforcerConfigRequest request);
  $async.Future<$4.SyncNodeRpcFromBitcoinConfResponse> syncNodeRpcFromBitcoinConf($pb.ServerContext ctx, $4.SyncNodeRpcFromBitcoinConfRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetEnforcerConfig': return $4.GetEnforcerConfigRequest();
      case 'WriteEnforcerConfig': return $4.WriteEnforcerConfigRequest();
      case 'SyncNodeRpcFromBitcoinConf': return $4.SyncNodeRpcFromBitcoinConfRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetEnforcerConfig': return this.getEnforcerConfig(ctx, request as $4.GetEnforcerConfigRequest);
      case 'WriteEnforcerConfig': return this.writeEnforcerConfig(ctx, request as $4.WriteEnforcerConfigRequest);
      case 'SyncNodeRpcFromBitcoinConf': return this.syncNodeRpcFromBitcoinConf(ctx, request as $4.SyncNodeRpcFromBitcoinConfRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => EnforcerConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => EnforcerConfServiceBase$messageJson;
}

