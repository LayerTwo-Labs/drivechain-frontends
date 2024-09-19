//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
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

import '../../google/protobuf/empty.pb.dart' as $0;
import 'wallet.pb.dart' as $2;

export 'wallet.pb.dart';

@$pb.GrpcServiceName('wallet.v1.WalletService')
class WalletServiceClient extends $grpc.Client {
  static final _$sendTransaction = $grpc.ClientMethod<$2.SendTransactionRequest, $2.SendTransactionResponse>(
      '/wallet.v1.WalletService/SendTransaction',
      ($2.SendTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.SendTransactionResponse.fromBuffer(value));
  static final _$getBalance = $grpc.ClientMethod<$0.Empty, $2.GetBalanceResponse>(
      '/wallet.v1.WalletService/GetBalance',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GetBalanceResponse.fromBuffer(value));
  static final _$getNewAddress = $grpc.ClientMethod<$0.Empty, $2.GetNewAddressResponse>(
      '/wallet.v1.WalletService/GetNewAddress',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GetNewAddressResponse.fromBuffer(value));
  static final _$listTransactions = $grpc.ClientMethod<$0.Empty, $2.ListTransactionsResponse>(
      '/wallet.v1.WalletService/ListTransactions',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ListTransactionsResponse.fromBuffer(value));

  WalletServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$2.SendTransactionResponse> sendTransaction($2.SendTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetBalanceResponse> getBalance($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBalance, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetNewAddressResponse> getNewAddress($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNewAddress, request, options: options);
  }

  $grpc.ResponseFuture<$2.ListTransactionsResponse> listTransactions($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTransactions, request, options: options);
  }
}

@$pb.GrpcServiceName('wallet.v1.WalletService')
abstract class WalletServiceBase extends $grpc.Service {
  $core.String get $name => 'wallet.v1.WalletService';

  WalletServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.SendTransactionRequest, $2.SendTransactionResponse>(
        'SendTransaction',
        sendTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.SendTransactionRequest.fromBuffer(value),
        ($2.SendTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $2.GetBalanceResponse>(
        'GetBalance',
        getBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($2.GetBalanceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $2.GetNewAddressResponse>(
        'GetNewAddress',
        getNewAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($2.GetNewAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $2.ListTransactionsResponse>(
        'ListTransactions',
        listTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($2.ListTransactionsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.SendTransactionResponse> sendTransaction_Pre($grpc.ServiceCall call, $async.Future<$2.SendTransactionRequest> request) async {
    return sendTransaction(call, await request);
  }

  $async.Future<$2.GetBalanceResponse> getBalance_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return getBalance(call, await request);
  }

  $async.Future<$2.GetNewAddressResponse> getNewAddress_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return getNewAddress(call, await request);
  }

  $async.Future<$2.ListTransactionsResponse> listTransactions_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listTransactions(call, await request);
  }

  $async.Future<$2.SendTransactionResponse> sendTransaction($grpc.ServiceCall call, $2.SendTransactionRequest request);
  $async.Future<$2.GetBalanceResponse> getBalance($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$2.GetNewAddressResponse> getNewAddress($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$2.ListTransactionsResponse> listTransactions($grpc.ServiceCall call, $0.Empty request);
}
