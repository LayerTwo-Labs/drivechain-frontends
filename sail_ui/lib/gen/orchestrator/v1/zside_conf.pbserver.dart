//
//  Generated code. Do not modify.
//  source: orchestrator/v1/zside_conf.proto
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

import 'zside_conf.pb.dart' as $8;
import 'zside_conf.pbjson.dart';

export 'zside_conf.pb.dart';

abstract class ZSideConfServiceBase extends $pb.GeneratedService {
  $async.Future<$8.GetZSideConfigResponse> getZSideConfig($pb.ServerContext ctx, $8.GetZSideConfigRequest request);
  $async.Future<$8.WriteZSideConfigResponse> writeZSideConfig(
      $pb.ServerContext ctx, $8.WriteZSideConfigRequest request);
  $async.Future<$8.ZSideSyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
      $pb.ServerContext ctx, $8.ZSideSyncNetworkFromBitcoinConfRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetZSideConfig':
        return $8.GetZSideConfigRequest();
      case 'WriteZSideConfig':
        return $8.WriteZSideConfigRequest();
      case 'SyncNetworkFromBitcoinConf':
        return $8.ZSideSyncNetworkFromBitcoinConfRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetZSideConfig':
        return this.getZSideConfig(ctx, request as $8.GetZSideConfigRequest);
      case 'WriteZSideConfig':
        return this.writeZSideConfig(ctx, request as $8.WriteZSideConfigRequest);
      case 'SyncNetworkFromBitcoinConf':
        return this.syncNetworkFromBitcoinConf(ctx, request as $8.ZSideSyncNetworkFromBitcoinConfRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideConfServiceBase$messageJson;
}
