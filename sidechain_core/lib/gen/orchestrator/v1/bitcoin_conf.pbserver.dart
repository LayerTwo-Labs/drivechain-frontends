// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/bitcoin_conf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'bitcoin_conf.pb.dart' as $0;
import 'bitcoin_conf.pbjson.dart';

export 'bitcoin_conf.pb.dart';

abstract class BitcoinConfServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetBitcoinConfigResponse> getBitcoinConfig(
      $pb.ServerContext ctx, $0.GetBitcoinConfigRequest request);
  $async.Future<$0.NetworkChangePlan> prepareNetworkChange(
      $pb.ServerContext ctx, $0.PrepareNetworkChangeRequest request);
  $async.Future<$0.ListNetworksResponse> listNetworks($pb.ServerContext ctx, $0.ListNetworksRequest request);
  $async.Future<$0.TakeNewNetworksResponse> takeNewNetworks($pb.ServerContext ctx, $0.TakeNewNetworksRequest request);
  $async.Future<$0.PlanECashSwitchResponse> planECashSwitch($pb.ServerContext ctx, $0.PlanECashSwitchRequest request);
  $async.Future<$0.SetBitcoinConfigNetworkResponse> setBitcoinConfigNetwork(
      $pb.ServerContext ctx, $0.SetBitcoinConfigNetworkRequest request);
  $async.Future<$0.SetBitcoinConfigDataDirResponse> setBitcoinConfigDataDir(
      $pb.ServerContext ctx, $0.SetBitcoinConfigDataDirRequest request);
  $async.Future<$0.WriteBitcoinConfigResponse> writeBitcoinConfig(
      $pb.ServerContext ctx, $0.WriteBitcoinConfigRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBitcoinConfig':
        return $0.GetBitcoinConfigRequest();
      case 'PrepareNetworkChange':
        return $0.PrepareNetworkChangeRequest();
      case 'ListNetworks':
        return $0.ListNetworksRequest();
      case 'TakeNewNetworks':
        return $0.TakeNewNetworksRequest();
      case 'PlanECashSwitch':
        return $0.PlanECashSwitchRequest();
      case 'SetBitcoinConfigNetwork':
        return $0.SetBitcoinConfigNetworkRequest();
      case 'SetBitcoinConfigDataDir':
        return $0.SetBitcoinConfigDataDirRequest();
      case 'WriteBitcoinConfig':
        return $0.WriteBitcoinConfigRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBitcoinConfig':
        return getBitcoinConfig(ctx, request as $0.GetBitcoinConfigRequest);
      case 'PrepareNetworkChange':
        return prepareNetworkChange(ctx, request as $0.PrepareNetworkChangeRequest);
      case 'ListNetworks':
        return listNetworks(ctx, request as $0.ListNetworksRequest);
      case 'TakeNewNetworks':
        return takeNewNetworks(ctx, request as $0.TakeNewNetworksRequest);
      case 'PlanECashSwitch':
        return planECashSwitch(ctx, request as $0.PlanECashSwitchRequest);
      case 'SetBitcoinConfigNetwork':
        return setBitcoinConfigNetwork(ctx, request as $0.SetBitcoinConfigNetworkRequest);
      case 'SetBitcoinConfigDataDir':
        return setBitcoinConfigDataDir(ctx, request as $0.SetBitcoinConfigDataDirRequest);
      case 'WriteBitcoinConfig':
        return writeBitcoinConfig(ctx, request as $0.WriteBitcoinConfigRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      BitcoinConfServiceBase$messageJson;
}
