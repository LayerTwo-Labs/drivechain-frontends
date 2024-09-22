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

import 'package:drivechain_client/gen/google/protobuf/empty.pb.dart' as $0;
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pb.dart' as $1;

export 'drivechain.pb.dart';

@$pb.GrpcServiceName('drivechain.v1.DrivechainService')
class DrivechainServiceClient extends $grpc.Client {
  static final _$listUnconfirmedTransactions = $grpc.ClientMethod<$0.Empty, $1.ListUnconfirmedTransactionsResponse>(
      '/drivechain.v1.DrivechainService/ListUnconfirmedTransactions',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.ListUnconfirmedTransactionsResponse.fromBuffer(value),);
  static final _$listRecentBlocks = $grpc.ClientMethod<$0.Empty, $1.ListRecentBlocksResponse>(
      '/drivechain.v1.DrivechainService/ListRecentBlocks',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.ListRecentBlocksResponse.fromBuffer(value),);
  static final _$getBlockchainInfo = $grpc.ClientMethod<$0.Empty, $1.GetBlockchainInfoResponse>(
      '/drivechain.v1.DrivechainService/GetBlockchainInfo',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetBlockchainInfoResponse.fromBuffer(value),);
  static final _$listPeers = $grpc.ClientMethod<$0.Empty, $1.ListPeersResponse>(
      '/drivechain.v1.DrivechainService/ListPeers',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.ListPeersResponse.fromBuffer(value),);
  static final _$estimateSmartFee = $grpc.ClientMethod<$1.EstimateSmartFeeRequest, $1.EstimateSmartFeeResponse>(
      '/drivechain.v1.DrivechainService/EstimateSmartFee',
      ($1.EstimateSmartFeeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.EstimateSmartFeeResponse.fromBuffer(value),);

  DrivechainServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors,})
      : super(channel, options: options,
        interceptors: interceptors,);

  $grpc.ResponseFuture<$1.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listUnconfirmedTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$1.ListRecentBlocksResponse> listRecentBlocks($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listRecentBlocks, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetBlockchainInfoResponse> getBlockchainInfo($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockchainInfo, request, options: options);
  }

  $grpc.ResponseFuture<$1.ListPeersResponse> listPeers($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listPeers, request, options: options);
  }

  $grpc.ResponseFuture<$1.EstimateSmartFeeResponse> estimateSmartFee($1.EstimateSmartFeeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$estimateSmartFee, request, options: options);
  }
}

@$pb.GrpcServiceName('drivechain.v1.DrivechainService')
abstract class DrivechainServiceBase extends $grpc.Service {
  $core.String get $name => 'drivechain.v1.DrivechainService';

  DrivechainServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.ListUnconfirmedTransactionsResponse>(
        'ListUnconfirmedTransactions',
        listUnconfirmedTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.ListUnconfirmedTransactionsResponse value) => value.writeToBuffer(),),);
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.ListRecentBlocksResponse>(
        'ListRecentBlocks',
        listRecentBlocks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.ListRecentBlocksResponse value) => value.writeToBuffer(),),);
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.GetBlockchainInfoResponse>(
        'GetBlockchainInfo',
        getBlockchainInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.GetBlockchainInfoResponse value) => value.writeToBuffer(),),);
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.ListPeersResponse>(
        'ListPeers',
        listPeers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.ListPeersResponse value) => value.writeToBuffer(),),);
    $addMethod($grpc.ServiceMethod<$1.EstimateSmartFeeRequest, $1.EstimateSmartFeeResponse>(
        'EstimateSmartFee',
        estimateSmartFee_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.EstimateSmartFeeRequest.fromBuffer(value),
        ($1.EstimateSmartFeeResponse value) => value.writeToBuffer(),),);
  }

  $async.Future<$1.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listUnconfirmedTransactions(call, await request);
  }

  $async.Future<$1.ListRecentBlocksResponse> listRecentBlocks_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listRecentBlocks(call, await request);
  }

  $async.Future<$1.GetBlockchainInfoResponse> getBlockchainInfo_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return getBlockchainInfo(call, await request);
  }

  $async.Future<$1.ListPeersResponse> listPeers_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listPeers(call, await request);
  }

  $async.Future<$1.EstimateSmartFeeResponse> estimateSmartFee_Pre($grpc.ServiceCall call, $async.Future<$1.EstimateSmartFeeRequest> request) async {
    return estimateSmartFee(call, await request);
  }

  $async.Future<$1.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$1.ListRecentBlocksResponse> listRecentBlocks($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$1.GetBlockchainInfoResponse> getBlockchainInfo($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$1.ListPeersResponse> listPeers($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$1.EstimateSmartFeeResponse> estimateSmartFee($grpc.ServiceCall call, $1.EstimateSmartFeeRequest request);
}
