//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/wallet.proto
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

import 'wallet.pb.dart' as $1;

export 'wallet.pb.dart';

@$pb.GrpcServiceName('cusf.mainchain.v1.WalletService')
class WalletServiceClient extends $grpc.Client {
  static final _$broadcastWithdrawalBundle = $grpc.ClientMethod<$1.BroadcastWithdrawalBundleRequest, $1.BroadcastWithdrawalBundleResponse>(
      '/cusf.mainchain.v1.WalletService/BroadcastWithdrawalBundle',
      ($1.BroadcastWithdrawalBundleRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.BroadcastWithdrawalBundleResponse.fromBuffer(value));
  static final _$createBmmCriticalDataTransaction = $grpc.ClientMethod<$1.CreateBmmCriticalDataTransactionRequest, $1.CreateBmmCriticalDataTransactionResponse>(
      '/cusf.mainchain.v1.WalletService/CreateBmmCriticalDataTransaction',
      ($1.CreateBmmCriticalDataTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.CreateBmmCriticalDataTransactionResponse.fromBuffer(value));
  static final _$createDepositTransaction = $grpc.ClientMethod<$1.CreateDepositTransactionRequest, $1.CreateDepositTransactionResponse>(
      '/cusf.mainchain.v1.WalletService/CreateDepositTransaction',
      ($1.CreateDepositTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.CreateDepositTransactionResponse.fromBuffer(value));
  static final _$createNewAddress = $grpc.ClientMethod<$1.CreateNewAddressRequest, $1.CreateNewAddressResponse>(
      '/cusf.mainchain.v1.WalletService/CreateNewAddress',
      ($1.CreateNewAddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.CreateNewAddressResponse.fromBuffer(value));
  static final _$generateBlocks = $grpc.ClientMethod<$1.GenerateBlocksRequest, $1.GenerateBlocksResponse>(
      '/cusf.mainchain.v1.WalletService/GenerateBlocks',
      ($1.GenerateBlocksRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GenerateBlocksResponse.fromBuffer(value));

  WalletServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle($1.BroadcastWithdrawalBundleRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$broadcastWithdrawalBundle, request, options: options);
  }

  $grpc.ResponseFuture<$1.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction($1.CreateBmmCriticalDataTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createBmmCriticalDataTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$1.CreateDepositTransactionResponse> createDepositTransaction($1.CreateDepositTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createDepositTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$1.CreateNewAddressResponse> createNewAddress($1.CreateNewAddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createNewAddress, request, options: options);
  }

  $grpc.ResponseFuture<$1.GenerateBlocksResponse> generateBlocks($1.GenerateBlocksRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$generateBlocks, request, options: options);
  }
}

@$pb.GrpcServiceName('cusf.mainchain.v1.WalletService')
abstract class WalletServiceBase extends $grpc.Service {
  $core.String get $name => 'cusf.mainchain.v1.WalletService';

  WalletServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.BroadcastWithdrawalBundleRequest, $1.BroadcastWithdrawalBundleResponse>(
        'BroadcastWithdrawalBundle',
        broadcastWithdrawalBundle_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.BroadcastWithdrawalBundleRequest.fromBuffer(value),
        ($1.BroadcastWithdrawalBundleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.CreateBmmCriticalDataTransactionRequest, $1.CreateBmmCriticalDataTransactionResponse>(
        'CreateBmmCriticalDataTransaction',
        createBmmCriticalDataTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.CreateBmmCriticalDataTransactionRequest.fromBuffer(value),
        ($1.CreateBmmCriticalDataTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.CreateDepositTransactionRequest, $1.CreateDepositTransactionResponse>(
        'CreateDepositTransaction',
        createDepositTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.CreateDepositTransactionRequest.fromBuffer(value),
        ($1.CreateDepositTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.CreateNewAddressRequest, $1.CreateNewAddressResponse>(
        'CreateNewAddress',
        createNewAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.CreateNewAddressRequest.fromBuffer(value),
        ($1.CreateNewAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GenerateBlocksRequest, $1.GenerateBlocksResponse>(
        'GenerateBlocks',
        generateBlocks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GenerateBlocksRequest.fromBuffer(value),
        ($1.GenerateBlocksResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle_Pre($grpc.ServiceCall call, $async.Future<$1.BroadcastWithdrawalBundleRequest> request) async {
    return broadcastWithdrawalBundle(call, await request);
  }

  $async.Future<$1.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction_Pre($grpc.ServiceCall call, $async.Future<$1.CreateBmmCriticalDataTransactionRequest> request) async {
    return createBmmCriticalDataTransaction(call, await request);
  }

  $async.Future<$1.CreateDepositTransactionResponse> createDepositTransaction_Pre($grpc.ServiceCall call, $async.Future<$1.CreateDepositTransactionRequest> request) async {
    return createDepositTransaction(call, await request);
  }

  $async.Future<$1.CreateNewAddressResponse> createNewAddress_Pre($grpc.ServiceCall call, $async.Future<$1.CreateNewAddressRequest> request) async {
    return createNewAddress(call, await request);
  }

  $async.Future<$1.GenerateBlocksResponse> generateBlocks_Pre($grpc.ServiceCall call, $async.Future<$1.GenerateBlocksRequest> request) async {
    return generateBlocks(call, await request);
  }

  $async.Future<$1.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle($grpc.ServiceCall call, $1.BroadcastWithdrawalBundleRequest request);
  $async.Future<$1.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction($grpc.ServiceCall call, $1.CreateBmmCriticalDataTransactionRequest request);
  $async.Future<$1.CreateDepositTransactionResponse> createDepositTransaction($grpc.ServiceCall call, $1.CreateDepositTransactionRequest request);
  $async.Future<$1.CreateNewAddressResponse> createNewAddress($grpc.ServiceCall call, $1.CreateNewAddressRequest request);
  $async.Future<$1.GenerateBlocksResponse> generateBlocks($grpc.ServiceCall call, $1.GenerateBlocksRequest request);
}
