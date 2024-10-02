//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
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

import '../../google/protobuf/empty.pb.dart' as $1;
import 'bitcoind.pb.dart' as $0;

export 'bitcoind.pb.dart';

@$pb.GrpcServiceName('bitcoind.v1.BitcoindService')
class BitcoindServiceClient extends $grpc.Client {
  static final _$listUnconfirmedTransactions = $grpc.ClientMethod<$0.ListUnconfirmedTransactionsRequest, $0.ListUnconfirmedTransactionsResponse>(
      '/bitcoind.v1.BitcoindService/ListUnconfirmedTransactions',
      ($0.ListUnconfirmedTransactionsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListUnconfirmedTransactionsResponse.fromBuffer(value));
  static final _$listRecentBlocks = $grpc.ClientMethod<$0.ListRecentBlocksRequest, $0.ListRecentBlocksResponse>(
      '/bitcoind.v1.BitcoindService/ListRecentBlocks',
      ($0.ListRecentBlocksRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListRecentBlocksResponse.fromBuffer(value));
  static final _$getBlockchainInfo = $grpc.ClientMethod<$1.Empty, $0.GetBlockchainInfoResponse>(
      '/bitcoind.v1.BitcoindService/GetBlockchainInfo',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBlockchainInfoResponse.fromBuffer(value));
  static final _$listPeers = $grpc.ClientMethod<$1.Empty, $0.ListPeersResponse>(
      '/bitcoind.v1.BitcoindService/ListPeers',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListPeersResponse.fromBuffer(value));
  static final _$estimateSmartFee = $grpc.ClientMethod<$0.EstimateSmartFeeRequest, $0.EstimateSmartFeeResponse>(
      '/bitcoind.v1.BitcoindService/EstimateSmartFee',
      ($0.EstimateSmartFeeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.EstimateSmartFeeResponse.fromBuffer(value));

  BitcoindServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions($0.ListUnconfirmedTransactionsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listUnconfirmedTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListRecentBlocksResponse> listRecentBlocks($0.ListRecentBlocksRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listRecentBlocks, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBlockchainInfoResponse> getBlockchainInfo($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockchainInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListPeersResponse> listPeers($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listPeers, request, options: options);
  }

  $grpc.ResponseFuture<$0.EstimateSmartFeeResponse> estimateSmartFee($0.EstimateSmartFeeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$estimateSmartFee, request, options: options);
  }
}

@$pb.GrpcServiceName('bitcoind.v1.BitcoindService')
abstract class BitcoindServiceBase extends $grpc.Service {
  $core.String get $name => 'bitcoind.v1.BitcoindService';

  BitcoindServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListUnconfirmedTransactionsRequest, $0.ListUnconfirmedTransactionsResponse>(
        'ListUnconfirmedTransactions',
        listUnconfirmedTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListUnconfirmedTransactionsRequest.fromBuffer(value),
        ($0.ListUnconfirmedTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListRecentBlocksRequest, $0.ListRecentBlocksResponse>(
        'ListRecentBlocks',
        listRecentBlocks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListRecentBlocksRequest.fromBuffer(value),
        ($0.ListRecentBlocksResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.GetBlockchainInfoResponse>(
        'GetBlockchainInfo',
        getBlockchainInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.GetBlockchainInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListPeersResponse>(
        'ListPeers',
        listPeers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListPeersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EstimateSmartFeeRequest, $0.EstimateSmartFeeResponse>(
        'EstimateSmartFee',
        estimateSmartFee_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EstimateSmartFeeRequest.fromBuffer(value),
        ($0.EstimateSmartFeeResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions_Pre($grpc.ServiceCall call, $async.Future<$0.ListUnconfirmedTransactionsRequest> request) async {
    return listUnconfirmedTransactions(call, await request);
  }

  $async.Future<$0.ListRecentBlocksResponse> listRecentBlocks_Pre($grpc.ServiceCall call, $async.Future<$0.ListRecentBlocksRequest> request) async {
    return listRecentBlocks(call, await request);
  }

  $async.Future<$0.GetBlockchainInfoResponse> getBlockchainInfo_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return getBlockchainInfo(call, await request);
  }

  $async.Future<$0.ListPeersResponse> listPeers_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listPeers(call, await request);
  }

  $async.Future<$0.EstimateSmartFeeResponse> estimateSmartFee_Pre($grpc.ServiceCall call, $async.Future<$0.EstimateSmartFeeRequest> request) async {
    return estimateSmartFee(call, await request);
  }

  $async.Future<$0.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions($grpc.ServiceCall call, $0.ListUnconfirmedTransactionsRequest request);
  $async.Future<$0.ListRecentBlocksResponse> listRecentBlocks($grpc.ServiceCall call, $0.ListRecentBlocksRequest request);
  $async.Future<$0.GetBlockchainInfoResponse> getBlockchainInfo($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$0.ListPeersResponse> listPeers($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$0.EstimateSmartFeeResponse> estimateSmartFee($grpc.ServiceCall call, $0.EstimateSmartFeeRequest request);
}
