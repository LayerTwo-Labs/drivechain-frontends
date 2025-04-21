//
//  Generated code. Do not modify.
//  source: faucet/v1/faucet.proto
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

import 'faucet.pb.dart' as $6;
import 'faucet.pbjson.dart';

export 'faucet.pb.dart';

abstract class FaucetServiceBase extends $pb.GeneratedService {
  $async.Future<$6.DispenseCoinsResponse> dispenseCoins($pb.ServerContext ctx, $6.DispenseCoinsRequest request);
  $async.Future<$6.ListClaimsResponse> listClaims($pb.ServerContext ctx, $6.ListClaimsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'DispenseCoins': return $6.DispenseCoinsRequest();
      case 'ListClaims': return $6.ListClaimsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'DispenseCoins': return this.dispenseCoins(ctx, request as $6.DispenseCoinsRequest);
      case 'ListClaims': return this.listClaims(ctx, request as $6.ListClaimsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FaucetServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => FaucetServiceBase$messageJson;
}

