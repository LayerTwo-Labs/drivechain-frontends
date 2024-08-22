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

import '../../google/protobuf/empty.pb.dart' as $1;
import 'drivechain.pb.dart' as $0;

export 'drivechain.pb.dart';

@$pb.GrpcServiceName('drivechain.v1.DrivechainService')
class DrivechainServiceClient extends $grpc.Client {
  static final _$sendTransaction = $grpc.ClientMethod<$0.SendTransactionRequest, $0.SendTransactionResponse>(
      '/drivechain.v1.DrivechainService/SendTransaction',
      ($0.SendTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SendTransactionResponse.fromBuffer(value));
  static final _$getBalance = $grpc.ClientMethod<$1.Empty, $0.GetBalanceResponse>(
      '/drivechain.v1.DrivechainService/GetBalance',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBalanceResponse.fromBuffer(value));
  static final _$getNewAddress = $grpc.ClientMethod<$1.Empty, $0.GetNewAddressResponse>(
      '/drivechain.v1.DrivechainService/GetNewAddress',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetNewAddressResponse.fromBuffer(value));
  static final _$listTransactions = $grpc.ClientMethod<$1.Empty, $0.ListTransactionsResponse>(
      '/drivechain.v1.DrivechainService/ListTransactions',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListTransactionsResponse.fromBuffer(value));
  static final _$listUnconfirmedTransactions = $grpc.ClientMethod<$1.Empty, $0.ListUnconfirmedTransactionsResponse>(
      '/drivechain.v1.DrivechainService/ListUnconfirmedTransactions',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListUnconfirmedTransactionsResponse.fromBuffer(value));
  static final _$listRecentBlocks = $grpc.ClientMethod<$1.Empty, $0.ListRecentBlocksResponse>(
      '/drivechain.v1.DrivechainService/ListRecentBlocks',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListRecentBlocksResponse.fromBuffer(value));

  DrivechainServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.SendTransactionResponse> sendTransaction($0.SendTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBalanceResponse> getBalance($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBalance, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetNewAddressResponse> getNewAddress($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNewAddress, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListTransactionsResponse> listTransactions($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listUnconfirmedTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListRecentBlocksResponse> listRecentBlocks($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listRecentBlocks, request, options: options);
  }
}

@$pb.GrpcServiceName('drivechain.v1.DrivechainService')
abstract class DrivechainServiceBase extends $grpc.Service {
  $core.String get $name => 'drivechain.v1.DrivechainService';

  DrivechainServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SendTransactionRequest, $0.SendTransactionResponse>(
        'SendTransaction',
        sendTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SendTransactionRequest.fromBuffer(value),
        ($0.SendTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.GetBalanceResponse>(
        'GetBalance',
        getBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.GetBalanceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.GetNewAddressResponse>(
        'GetNewAddress',
        getNewAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.GetNewAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListTransactionsResponse>(
        'ListTransactions',
        listTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListUnconfirmedTransactionsResponse>(
        'ListUnconfirmedTransactions',
        listUnconfirmedTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListUnconfirmedTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListRecentBlocksResponse>(
        'ListRecentBlocks',
        listRecentBlocks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListRecentBlocksResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.SendTransactionResponse> sendTransaction_Pre($grpc.ServiceCall call, $async.Future<$0.SendTransactionRequest> request) async {
    return sendTransaction(call, await request);
  }

  $async.Future<$0.GetBalanceResponse> getBalance_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return getBalance(call, await request);
  }

  $async.Future<$0.GetNewAddressResponse> getNewAddress_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return getNewAddress(call, await request);
  }

  $async.Future<$0.ListTransactionsResponse> listTransactions_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listTransactions(call, await request);
  }

  $async.Future<$0.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listUnconfirmedTransactions(call, await request);
  }

  $async.Future<$0.ListRecentBlocksResponse> listRecentBlocks_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listRecentBlocks(call, await request);
  }

  $async.Future<$0.SendTransactionResponse> sendTransaction($grpc.ServiceCall call, $0.SendTransactionRequest request);
  $async.Future<$0.GetBalanceResponse> getBalance($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$0.GetNewAddressResponse> getNewAddress($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$0.ListTransactionsResponse> listTransactions($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$0.ListUnconfirmedTransactionsResponse> listUnconfirmedTransactions($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$0.ListRecentBlocksResponse> listRecentBlocks($grpc.ServiceCall call, $1.Empty request);
}
