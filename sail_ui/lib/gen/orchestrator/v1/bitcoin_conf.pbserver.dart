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

import 'bitcoin_conf.pb.dart' as $0;
import 'bitcoin_conf.pbjson.dart';

export 'bitcoin_conf.pb.dart';

abstract class BitcoinConfServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetBitcoinConfigResponse> getBitcoinConfig($pb.ServerContext ctx, $0.GetBitcoinConfigRequest request);
  $async.Future<$0.SetBitcoinConfigNetworkResponse> setBitcoinConfigNetwork($pb.ServerContext ctx, $0.SetBitcoinConfigNetworkRequest request);
  $async.Future<$0.SetBitcoinConfigDataDirResponse> setBitcoinConfigDataDir($pb.ServerContext ctx, $0.SetBitcoinConfigDataDirRequest request);
  $async.Future<$0.WriteBitcoinConfigResponse> writeBitcoinConfig($pb.ServerContext ctx, $0.WriteBitcoinConfigRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBitcoinConfig': return $0.GetBitcoinConfigRequest();
      case 'SetBitcoinConfigNetwork': return $0.SetBitcoinConfigNetworkRequest();
      case 'SetBitcoinConfigDataDir': return $0.SetBitcoinConfigDataDirRequest();
      case 'WriteBitcoinConfig': return $0.WriteBitcoinConfigRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBitcoinConfig': return this.getBitcoinConfig(ctx, request as $0.GetBitcoinConfigRequest);
      case 'SetBitcoinConfigNetwork': return this.setBitcoinConfigNetwork(ctx, request as $0.SetBitcoinConfigNetworkRequest);
      case 'SetBitcoinConfigDataDir': return this.setBitcoinConfigDataDir(ctx, request as $0.SetBitcoinConfigDataDirRequest);
      case 'WriteBitcoinConfig': return this.writeBitcoinConfig(ctx, request as $0.WriteBitcoinConfigRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinConfServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoinConfServiceBase$messageJson;
}

