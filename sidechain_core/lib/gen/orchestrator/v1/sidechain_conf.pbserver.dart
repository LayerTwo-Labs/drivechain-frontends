// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/sidechain_conf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'sidechain_conf.pb.dart' as $0;
import 'sidechain_conf.pbjson.dart';

export 'sidechain_conf.pb.dart';

abstract class SidechainConfServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetSidechainConfigResponse> getSidechainConfig(
      $pb.ServerContext ctx, $0.GetSidechainConfigRequest request);
  $async.Future<$0.WriteSidechainConfigResponse> writeSidechainConfig(
      $pb.ServerContext ctx, $0.WriteSidechainConfigRequest request);
  $async.Future<$0.SyncSidechainNetworkFromBitcoinConfResponse> syncSidechainNetworkFromBitcoinConf(
      $pb.ServerContext ctx, $0.SyncSidechainNetworkFromBitcoinConfRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetSidechainConfig':
        return $0.GetSidechainConfigRequest();
      case 'WriteSidechainConfig':
        return $0.WriteSidechainConfigRequest();
      case 'SyncSidechainNetworkFromBitcoinConf':
        return $0.SyncSidechainNetworkFromBitcoinConfRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetSidechainConfig':
        return getSidechainConfig(ctx, request as $0.GetSidechainConfigRequest);
      case 'WriteSidechainConfig':
        return writeSidechainConfig(ctx, request as $0.WriteSidechainConfigRequest);
      case 'SyncSidechainNetworkFromBitcoinConf':
        return syncSidechainNetworkFromBitcoinConf(ctx, request as $0.SyncSidechainNetworkFromBitcoinConfRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SidechainConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      SidechainConfServiceBase$messageJson;
}
