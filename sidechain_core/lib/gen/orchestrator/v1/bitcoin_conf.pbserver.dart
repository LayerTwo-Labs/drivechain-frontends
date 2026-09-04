//
//  Generated code. Do not modify.
//  source: orchestrator/v1/bitcoin_conf.proto
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

import 'bitcoin_conf.pb.dart' as $8;
import 'bitcoin_conf.pbjson.dart';

export 'bitcoin_conf.pb.dart';

abstract class BitcoinConfServiceBase extends $pb.GeneratedService {
  $async.Future<$8.GetBitcoinConfigResponse> getBitcoinConfig($pb.ServerContext ctx, $8.GetBitcoinConfigRequest request);
  $async.Future<$8.NetworkChangePlan> prepareNetworkChange($pb.ServerContext ctx, $8.PrepareNetworkChangeRequest request);
  $async.Future<$8.ListNetworksResponse> listNetworks($pb.ServerContext ctx, $8.ListNetworksRequest request);
  $async.Future<$8.TakeNewNetworksResponse> takeNewNetworks($pb.ServerContext ctx, $8.TakeNewNetworksRequest request);
  $async.Future<$8.PlanECashSwitchResponse> planECashSwitch($pb.ServerContext ctx, $8.PlanECashSwitchRequest request);
  $async.Future<$8.SetBitcoinConfigNetworkResponse> setBitcoinConfigNetwork($pb.ServerContext ctx, $8.SetBitcoinConfigNetworkRequest request);
  $async.Future<$8.SetBitcoinConfigDataDirResponse> setBitcoinConfigDataDir($pb.ServerContext ctx, $8.SetBitcoinConfigDataDirRequest request);
  $async.Future<$8.WriteBitcoinConfigResponse> writeBitcoinConfig($pb.ServerContext ctx, $8.WriteBitcoinConfigRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBitcoinConfig': return $8.GetBitcoinConfigRequest();
      case 'PrepareNetworkChange': return $8.PrepareNetworkChangeRequest();
      case 'ListNetworks': return $8.ListNetworksRequest();
      case 'TakeNewNetworks': return $8.TakeNewNetworksRequest();
      case 'PlanECashSwitch': return $8.PlanECashSwitchRequest();
      case 'SetBitcoinConfigNetwork': return $8.SetBitcoinConfigNetworkRequest();
      case 'SetBitcoinConfigDataDir': return $8.SetBitcoinConfigDataDirRequest();
      case 'WriteBitcoinConfig': return $8.WriteBitcoinConfigRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBitcoinConfig': return this.getBitcoinConfig(ctx, request as $8.GetBitcoinConfigRequest);
      case 'PrepareNetworkChange': return this.prepareNetworkChange(ctx, request as $8.PrepareNetworkChangeRequest);
      case 'ListNetworks': return this.listNetworks(ctx, request as $8.ListNetworksRequest);
      case 'TakeNewNetworks': return this.takeNewNetworks(ctx, request as $8.TakeNewNetworksRequest);
      case 'PlanECashSwitch': return this.planECashSwitch(ctx, request as $8.PlanECashSwitchRequest);
      case 'SetBitcoinConfigNetwork': return this.setBitcoinConfigNetwork(ctx, request as $8.SetBitcoinConfigNetworkRequest);
      case 'SetBitcoinConfigDataDir': return this.setBitcoinConfigDataDir(ctx, request as $8.SetBitcoinConfigDataDirRequest);
      case 'WriteBitcoinConfig': return this.writeBitcoinConfig(ctx, request as $8.WriteBitcoinConfigRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoinConfServiceBase$messageJson;
}

