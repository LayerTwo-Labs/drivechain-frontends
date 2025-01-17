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
import 'wallet.pb.dart' as $4;

export 'wallet.pb.dart';

@$pb.GrpcServiceName('wallet.v1.WalletService')
class WalletServiceClient extends $grpc.Client {
  static final _$sendTransaction = $grpc.ClientMethod<$4.SendTransactionRequest, $4.SendTransactionResponse>(
      '/wallet.v1.WalletService/SendTransaction',
      ($4.SendTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $4.SendTransactionResponse.fromBuffer(value));
  static final _$getBalance = $grpc.ClientMethod<$1.Empty, $4.GetBalanceResponse>(
      '/wallet.v1.WalletService/GetBalance',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $4.GetBalanceResponse.fromBuffer(value));
  static final _$getNewAddress = $grpc.ClientMethod<$1.Empty, $4.GetNewAddressResponse>(
      '/wallet.v1.WalletService/GetNewAddress',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $4.GetNewAddressResponse.fromBuffer(value));
  static final _$listTransactions = $grpc.ClientMethod<$1.Empty, $4.ListTransactionsResponse>(
      '/wallet.v1.WalletService/ListTransactions',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $4.ListTransactionsResponse.fromBuffer(value));
  static final _$listSidechainDeposits = $grpc.ClientMethod<$4.ListSidechainDepositsRequest, $4.ListSidechainDepositsResponse>(
      '/wallet.v1.WalletService/ListSidechainDeposits',
      ($4.ListSidechainDepositsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $4.ListSidechainDepositsResponse.fromBuffer(value));
  static final _$createSidechainDeposit = $grpc.ClientMethod<$4.CreateSidechainDepositRequest, $4.CreateSidechainDepositResponse>(
      '/wallet.v1.WalletService/CreateSidechainDeposit',
      ($4.CreateSidechainDepositRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $4.CreateSidechainDepositResponse.fromBuffer(value));

  WalletServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$4.SendTransactionResponse> sendTransaction($4.SendTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$4.GetBalanceResponse> getBalance($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBalance, request, options: options);
  }

  $grpc.ResponseFuture<$4.GetNewAddressResponse> getNewAddress($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNewAddress, request, options: options);
  }

  $grpc.ResponseFuture<$4.ListTransactionsResponse> listTransactions($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$4.ListSidechainDepositsResponse> listSidechainDeposits($4.ListSidechainDepositsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listSidechainDeposits, request, options: options);
  }

  $grpc.ResponseFuture<$4.CreateSidechainDepositResponse> createSidechainDeposit($4.CreateSidechainDepositRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createSidechainDeposit, request, options: options);
  }
}

@$pb.GrpcServiceName('wallet.v1.WalletService')
abstract class WalletServiceBase extends $grpc.Service {
  $core.String get $name => 'wallet.v1.WalletService';

  WalletServiceBase() {
    $addMethod($grpc.ServiceMethod<$4.SendTransactionRequest, $4.SendTransactionResponse>(
        'SendTransaction',
        sendTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $4.SendTransactionRequest.fromBuffer(value),
        ($4.SendTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $4.GetBalanceResponse>(
        'GetBalance',
        getBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($4.GetBalanceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $4.GetNewAddressResponse>(
        'GetNewAddress',
        getNewAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($4.GetNewAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $4.ListTransactionsResponse>(
        'ListTransactions',
        listTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($4.ListTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$4.ListSidechainDepositsRequest, $4.ListSidechainDepositsResponse>(
        'ListSidechainDeposits',
        listSidechainDeposits_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $4.ListSidechainDepositsRequest.fromBuffer(value),
        ($4.ListSidechainDepositsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$4.CreateSidechainDepositRequest, $4.CreateSidechainDepositResponse>(
        'CreateSidechainDeposit',
        createSidechainDeposit_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $4.CreateSidechainDepositRequest.fromBuffer(value),
        ($4.CreateSidechainDepositResponse value) => value.writeToBuffer()));
  }

  $async.Future<$4.SendTransactionResponse> sendTransaction_Pre($grpc.ServiceCall call, $async.Future<$4.SendTransactionRequest> request) async {
    return sendTransaction(call, await request);
  }

  $async.Future<$4.GetBalanceResponse> getBalance_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return getBalance(call, await request);
  }

  $async.Future<$4.GetNewAddressResponse> getNewAddress_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return getNewAddress(call, await request);
  }

  $async.Future<$4.ListTransactionsResponse> listTransactions_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listTransactions(call, await request);
  }

  $async.Future<$4.ListSidechainDepositsResponse> listSidechainDeposits_Pre($grpc.ServiceCall call, $async.Future<$4.ListSidechainDepositsRequest> request) async {
    return listSidechainDeposits(call, await request);
  }

  $async.Future<$4.CreateSidechainDepositResponse> createSidechainDeposit_Pre($grpc.ServiceCall call, $async.Future<$4.CreateSidechainDepositRequest> request) async {
    return createSidechainDeposit(call, await request);
  }

  $async.Future<$4.SendTransactionResponse> sendTransaction($grpc.ServiceCall call, $4.SendTransactionRequest request);
  $async.Future<$4.GetBalanceResponse> getBalance($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$4.GetNewAddressResponse> getNewAddress($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$4.ListTransactionsResponse> listTransactions($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$4.ListSidechainDepositsResponse> listSidechainDeposits($grpc.ServiceCall call, $4.ListSidechainDepositsRequest request);
  $async.Future<$4.CreateSidechainDepositResponse> createSidechainDeposit($grpc.ServiceCall call, $4.CreateSidechainDepositRequest request);
}
