//
//  Generated code. Do not modify.
//  source: bitcoin/drivechaind/v1/drivechain.proto
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

import 'drivechain.pb.dart' as $1;

export 'drivechain.pb.dart';

@$pb.GrpcServiceName('bitcoin.drivechaind.v1.DrivechainService')
class DrivechainServiceClient extends $grpc.Client {
  static final _$createSidechainDeposit = $grpc.ClientMethod<$1.CreateSidechainDepositRequest, $1.CreateSidechainDepositResponse>(
      '/bitcoin.drivechaind.v1.DrivechainService/CreateSidechainDeposit',
      ($1.CreateSidechainDepositRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.CreateSidechainDepositResponse.fromBuffer(value));

  DrivechainServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.CreateSidechainDepositResponse> createSidechainDeposit($1.CreateSidechainDepositRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createSidechainDeposit, request, options: options);
  }
}

@$pb.GrpcServiceName('bitcoin.drivechaind.v1.DrivechainService')
abstract class DrivechainServiceBase extends $grpc.Service {
  $core.String get $name => 'bitcoin.drivechaind.v1.DrivechainService';

  DrivechainServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.CreateSidechainDepositRequest, $1.CreateSidechainDepositResponse>(
        'CreateSidechainDeposit',
        createSidechainDeposit_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.CreateSidechainDepositRequest.fromBuffer(value),
        ($1.CreateSidechainDepositResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.CreateSidechainDepositResponse> createSidechainDeposit_Pre($grpc.ServiceCall call, $async.Future<$1.CreateSidechainDepositRequest> request) async {
    return createSidechainDeposit(call, await request);
  }

  $async.Future<$1.CreateSidechainDepositResponse> createSidechainDeposit($grpc.ServiceCall call, $1.CreateSidechainDepositRequest request);
}
