//
//  Generated code. Do not modify.
//  source: orchestrator/v1/sidechain_conf.proto
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

import 'sidechain_conf.pb.dart' as $10;
import 'sidechain_conf.pbjson.dart';

export 'sidechain_conf.pb.dart';

abstract class SidechainConfServiceBase extends $pb.GeneratedService {
  $async.Future<$10.GetSidechainConfigResponse> getSidechainConfig($pb.ServerContext ctx, $10.GetSidechainConfigRequest request);
  $async.Future<$10.WriteSidechainConfigResponse> writeSidechainConfig($pb.ServerContext ctx, $10.WriteSidechainConfigRequest request);
  $async.Future<$10.SyncSidechainNetworkFromBitcoinConfResponse> syncSidechainNetworkFromBitcoinConf($pb.ServerContext ctx, $10.SyncSidechainNetworkFromBitcoinConfRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetSidechainConfig': return $10.GetSidechainConfigRequest();
      case 'WriteSidechainConfig': return $10.WriteSidechainConfigRequest();
      case 'SyncSidechainNetworkFromBitcoinConf': return $10.SyncSidechainNetworkFromBitcoinConfRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetSidechainConfig': return this.getSidechainConfig(ctx, request as $10.GetSidechainConfigRequest);
      case 'WriteSidechainConfig': return this.writeSidechainConfig(ctx, request as $10.WriteSidechainConfigRequest);
      case 'SyncSidechainNetworkFromBitcoinConf': return this.syncSidechainNetworkFromBitcoinConf(ctx, request as $10.SyncSidechainNetworkFromBitcoinConfRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SidechainConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SidechainConfServiceBase$messageJson;
}

