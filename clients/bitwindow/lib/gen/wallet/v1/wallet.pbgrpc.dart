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

import '../../google/protobuf/empty.pb.dart' as $1;
import 'wallet.pb.dart' as $3;

export 'wallet.pb.dart';

@$pb.GrpcServiceName('wallet.v1.WalletService')
class WalletServiceClient extends $grpc.Client {
  static final _$sendTransaction = $grpc.ClientMethod<$3.SendTransactionRequest, $3.SendTransactionResponse>(
      '/wallet.v1.WalletService/SendTransaction',
      ($3.SendTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.SendTransactionResponse.fromBuffer(value));
  static final _$getBalance = $grpc.ClientMethod<$1.Empty, $3.GetBalanceResponse>(
      '/wallet.v1.WalletService/GetBalance',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.GetBalanceResponse.fromBuffer(value));
  static final _$getNewAddress = $grpc.ClientMethod<$1.Empty, $3.GetNewAddressResponse>(
      '/wallet.v1.WalletService/GetNewAddress',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.GetNewAddressResponse.fromBuffer(value));
  static final _$listTransactions = $grpc.ClientMethod<$1.Empty, $3.ListTransactionsResponse>(
      '/wallet.v1.WalletService/ListTransactions',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.ListTransactionsResponse.fromBuffer(value));
  static final _$listSidechainDeposits = $grpc.ClientMethod<$3.ListSidechainDepositsRequest, $3.ListSidechainDepositsResponse>(
      '/wallet.v1.WalletService/ListSidechainDeposits',
      ($3.ListSidechainDepositsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.ListSidechainDepositsResponse.fromBuffer(value));
  static final _$createSidechainDeposit = $grpc.ClientMethod<$3.CreateSidechainDepositRequest, $3.CreateSidechainDepositResponse>(
      '/wallet.v1.WalletService/CreateSidechainDeposit',
      ($3.CreateSidechainDepositRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.CreateSidechainDepositResponse.fromBuffer(value));

  WalletServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$3.SendTransactionResponse> sendTransaction($3.SendTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$3.GetBalanceResponse> getBalance($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBalance, request, options: options);
  }

  $grpc.ResponseFuture<$3.GetNewAddressResponse> getNewAddress($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNewAddress, request, options: options);
  }

  $grpc.ResponseFuture<$3.ListTransactionsResponse> listTransactions($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$3.ListSidechainDepositsResponse> listSidechainDeposits($3.ListSidechainDepositsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listSidechainDeposits, request, options: options);
  }

  $grpc.ResponseFuture<$3.CreateSidechainDepositResponse> createSidechainDeposit($3.CreateSidechainDepositRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createSidechainDeposit, request, options: options);
  }
}

@$pb.GrpcServiceName('wallet.v1.WalletService')
abstract class WalletServiceBase extends $grpc.Service {
  $core.String get $name => 'wallet.v1.WalletService';

  WalletServiceBase() {
    $addMethod($grpc.ServiceMethod<$3.SendTransactionRequest, $3.SendTransactionResponse>(
        'SendTransaction',
        sendTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.SendTransactionRequest.fromBuffer(value),
        ($3.SendTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $3.GetBalanceResponse>(
        'GetBalance',
        getBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($3.GetBalanceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $3.GetNewAddressResponse>(
        'GetNewAddress',
        getNewAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($3.GetNewAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $3.ListTransactionsResponse>(
        'ListTransactions',
        listTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($3.ListTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.ListSidechainDepositsRequest, $3.ListSidechainDepositsResponse>(
        'ListSidechainDeposits',
        listSidechainDeposits_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.ListSidechainDepositsRequest.fromBuffer(value),
        ($3.ListSidechainDepositsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.CreateSidechainDepositRequest, $3.CreateSidechainDepositResponse>(
        'CreateSidechainDeposit',
        createSidechainDeposit_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.CreateSidechainDepositRequest.fromBuffer(value),
        ($3.CreateSidechainDepositResponse value) => value.writeToBuffer()));
  }

  $async.Future<$3.SendTransactionResponse> sendTransaction_Pre($grpc.ServiceCall call, $async.Future<$3.SendTransactionRequest> request) async {
    return sendTransaction(call, await request);
  }

  $async.Future<$3.GetBalanceResponse> getBalance_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return getBalance(call, await request);
  }

  $async.Future<$3.GetNewAddressResponse> getNewAddress_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return getNewAddress(call, await request);
  }

  $async.Future<$3.ListTransactionsResponse> listTransactions_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listTransactions(call, await request);
  }

  $async.Future<$3.ListSidechainDepositsResponse> listSidechainDeposits_Pre($grpc.ServiceCall call, $async.Future<$3.ListSidechainDepositsRequest> request) async {
    return listSidechainDeposits(call, await request);
  }

  $async.Future<$3.CreateSidechainDepositResponse> createSidechainDeposit_Pre($grpc.ServiceCall call, $async.Future<$3.CreateSidechainDepositRequest> request) async {
    return createSidechainDeposit(call, await request);
  }

  $async.Future<$3.SendTransactionResponse> sendTransaction($grpc.ServiceCall call, $3.SendTransactionRequest request);
  $async.Future<$3.GetBalanceResponse> getBalance($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$3.GetNewAddressResponse> getNewAddress($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$3.ListTransactionsResponse> listTransactions($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$3.ListSidechainDepositsResponse> listSidechainDeposits($grpc.ServiceCall call, $3.ListSidechainDepositsRequest request);
  $async.Future<$3.CreateSidechainDepositResponse> createSidechainDeposit($grpc.ServiceCall call, $3.CreateSidechainDepositRequest request);
}
