//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
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

import 'drivechain.pb.dart' as $2;

export 'drivechain.pb.dart';

@$pb.GrpcServiceName('drivechain.v1.DrivechainService')
class DrivechainServiceClient extends $grpc.Client {
  static final _$listSidechains = $grpc.ClientMethod<$2.ListSidechainsRequest, $2.ListSidechainsResponse>(
      '/drivechain.v1.DrivechainService/ListSidechains',
      ($2.ListSidechainsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ListSidechainsResponse.fromBuffer(value));
  static final _$listSidechainProposals = $grpc.ClientMethod<$2.ListSidechainProposalsRequest, $2.ListSidechainProposalsResponse>(
      '/drivechain.v1.DrivechainService/ListSidechainProposals',
      ($2.ListSidechainProposalsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ListSidechainProposalsResponse.fromBuffer(value));

  DrivechainServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$2.ListSidechainsResponse> listSidechains($2.ListSidechainsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listSidechains, request, options: options);
  }

  $grpc.ResponseFuture<$2.ListSidechainProposalsResponse> listSidechainProposals($2.ListSidechainProposalsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listSidechainProposals, request, options: options);
  }
}

@$pb.GrpcServiceName('drivechain.v1.DrivechainService')
abstract class DrivechainServiceBase extends $grpc.Service {
  $core.String get $name => 'drivechain.v1.DrivechainService';

  DrivechainServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.ListSidechainsRequest, $2.ListSidechainsResponse>(
        'ListSidechains',
        listSidechains_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.ListSidechainsRequest.fromBuffer(value),
        ($2.ListSidechainsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.ListSidechainProposalsRequest, $2.ListSidechainProposalsResponse>(
        'ListSidechainProposals',
        listSidechainProposals_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.ListSidechainProposalsRequest.fromBuffer(value),
        ($2.ListSidechainProposalsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.ListSidechainsResponse> listSidechains_Pre($grpc.ServiceCall call, $async.Future<$2.ListSidechainsRequest> request) async {
    return listSidechains(call, await request);
  }

  $async.Future<$2.ListSidechainProposalsResponse> listSidechainProposals_Pre($grpc.ServiceCall call, $async.Future<$2.ListSidechainProposalsRequest> request) async {
    return listSidechainProposals(call, await request);
  }

  $async.Future<$2.ListSidechainsResponse> listSidechains($grpc.ServiceCall call, $2.ListSidechainsRequest request);
  $async.Future<$2.ListSidechainProposalsResponse> listSidechainProposals($grpc.ServiceCall call, $2.ListSidechainProposalsRequest request);
}
