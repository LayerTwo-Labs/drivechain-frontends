//
//  Generated code. Do not modify.
//  source: orchestrator/v1/thunder_conf.proto
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

import 'thunder_conf.pb.dart' as $10;
import 'thunder_conf.pbjson.dart';

export 'thunder_conf.pb.dart';

abstract class ThunderConfServiceBase extends $pb.GeneratedService {
  $async.Future<$10.GetThunderConfigResponse> getThunderConfig($pb.ServerContext ctx, $10.GetThunderConfigRequest request);
  $async.Future<$10.WriteThunderConfigResponse> writeThunderConfig($pb.ServerContext ctx, $10.WriteThunderConfigRequest request);
  $async.Future<$10.SyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf($pb.ServerContext ctx, $10.SyncNetworkFromBitcoinConfRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetThunderConfig': return $10.GetThunderConfigRequest();
      case 'WriteThunderConfig': return $10.WriteThunderConfigRequest();
      case 'SyncNetworkFromBitcoinConf': return $10.SyncNetworkFromBitcoinConfRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetThunderConfig': return this.getThunderConfig(ctx, request as $10.GetThunderConfigRequest);
      case 'WriteThunderConfig': return this.writeThunderConfig(ctx, request as $10.WriteThunderConfigRequest);
      case 'SyncNetworkFromBitcoinConf': return this.syncNetworkFromBitcoinConf(ctx, request as $10.SyncNetworkFromBitcoinConfRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ThunderConfServiceBase$messageJson;
}

