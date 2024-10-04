//
//  Generated code. Do not modify.
//  source: faucet/v1/faucet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'faucet.pb.dart' as $2;

export 'faucet.pb.dart';

@$pb.GrpcServiceName('faucet.v1.FaucetService')
class FaucetServiceClient extends $grpc.Client {
  static final _$dispenseCoins = $grpc.ClientMethod<$2.DispenseCoinsRequest, $2.DispenseCoinsResponse>(
      '/faucet.v1.FaucetService/DispenseCoins',
      ($2.DispenseCoinsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.DispenseCoinsResponse.fromBuffer(value));
  static final _$listClaims = $grpc.ClientMethod<$2.ListClaimsRequest, $2.ListClaimsResponse>(
      '/faucet.v1.FaucetService/ListClaims',
      ($2.ListClaimsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ListClaimsResponse.fromBuffer(value));

  FaucetServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$2.DispenseCoinsResponse> dispenseCoins($2.DispenseCoinsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$dispenseCoins, request, options: options);
  }

  $grpc.ResponseFuture<$2.ListClaimsResponse> listClaims($2.ListClaimsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listClaims, request, options: options);
  }
}

@$pb.GrpcServiceName('faucet.v1.FaucetService')
abstract class FaucetServiceBase extends $grpc.Service {
  $core.String get $name => 'faucet.v1.FaucetService';

  FaucetServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.DispenseCoinsRequest, $2.DispenseCoinsResponse>(
        'DispenseCoins',
        dispenseCoins_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.DispenseCoinsRequest.fromBuffer(value),
        ($2.DispenseCoinsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.ListClaimsRequest, $2.ListClaimsResponse>(
        'ListClaims',
        listClaims_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.ListClaimsRequest.fromBuffer(value),
        ($2.ListClaimsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.DispenseCoinsResponse> dispenseCoins_Pre($grpc.ServiceCall call, $async.Future<$2.DispenseCoinsRequest> request) async {
    return dispenseCoins(call, await request);
  }

  $async.Future<$2.ListClaimsResponse> listClaims_Pre($grpc.ServiceCall call, $async.Future<$2.ListClaimsRequest> request) async {
    return listClaims(call, await request);
  }

  $async.Future<$2.DispenseCoinsResponse> dispenseCoins($grpc.ServiceCall call, $2.DispenseCoinsRequest request);
  $async.Future<$2.ListClaimsResponse> listClaims($grpc.ServiceCall call, $2.ListClaimsRequest request);
}
