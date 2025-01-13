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

import 'wallet.pb.dart' as $2;

export 'wallet.pb.dart';

@$pb.GrpcServiceName('cusf.mainchain.v1.WalletService')
class WalletServiceClient extends $grpc.Client {
  static final _$broadcastWithdrawalBundle = $grpc.ClientMethod<$2.BroadcastWithdrawalBundleRequest, $2.BroadcastWithdrawalBundleResponse>(
      '/cusf.mainchain.v1.WalletService/BroadcastWithdrawalBundle',
      ($2.BroadcastWithdrawalBundleRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.BroadcastWithdrawalBundleResponse.fromBuffer(value));
  static final _$createBmmCriticalDataTransaction = $grpc.ClientMethod<$2.CreateBmmCriticalDataTransactionRequest, $2.CreateBmmCriticalDataTransactionResponse>(
      '/cusf.mainchain.v1.WalletService/CreateBmmCriticalDataTransaction',
      ($2.CreateBmmCriticalDataTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.CreateBmmCriticalDataTransactionResponse.fromBuffer(value));
  static final _$createDepositTransaction = $grpc.ClientMethod<$2.CreateDepositTransactionRequest, $2.CreateDepositTransactionResponse>(
      '/cusf.mainchain.v1.WalletService/CreateDepositTransaction',
      ($2.CreateDepositTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.CreateDepositTransactionResponse.fromBuffer(value));
  static final _$createNewAddress = $grpc.ClientMethod<$2.CreateNewAddressRequest, $2.CreateNewAddressResponse>(
      '/cusf.mainchain.v1.WalletService/CreateNewAddress',
      ($2.CreateNewAddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.CreateNewAddressResponse.fromBuffer(value));
  static final _$createSidechainProposal = $grpc.ClientMethod<$2.CreateSidechainProposalRequest, $2.CreateSidechainProposalResponse>(
      '/cusf.mainchain.v1.WalletService/CreateSidechainProposal',
      ($2.CreateSidechainProposalRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.CreateSidechainProposalResponse.fromBuffer(value));
  static final _$getBalance = $grpc.ClientMethod<$2.GetBalanceRequest, $2.GetBalanceResponse>(
      '/cusf.mainchain.v1.WalletService/GetBalance',
      ($2.GetBalanceRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GetBalanceResponse.fromBuffer(value));
  static final _$listTransactions = $grpc.ClientMethod<$2.ListTransactionsRequest, $2.ListTransactionsResponse>(
      '/cusf.mainchain.v1.WalletService/ListTransactions',
      ($2.ListTransactionsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ListTransactionsResponse.fromBuffer(value));
  static final _$sendTransaction = $grpc.ClientMethod<$2.SendTransactionRequest, $2.SendTransactionResponse>(
      '/cusf.mainchain.v1.WalletService/SendTransaction',
      ($2.SendTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.SendTransactionResponse.fromBuffer(value));
  static final _$generateBlocks = $grpc.ClientMethod<$2.GenerateBlocksRequest, $2.GenerateBlocksResponse>(
      '/cusf.mainchain.v1.WalletService/GenerateBlocks',
      ($2.GenerateBlocksRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GenerateBlocksResponse.fromBuffer(value));
  static final _$unlockWallet = $grpc.ClientMethod<$2.UnlockWalletRequest, $2.UnlockWalletResponse>(
      '/cusf.mainchain.v1.WalletService/UnlockWallet',
      ($2.UnlockWalletRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.UnlockWalletResponse.fromBuffer(value));
  static final _$createWallet = $grpc.ClientMethod<$2.CreateWalletRequest, $2.CreateWalletResponse>(
      '/cusf.mainchain.v1.WalletService/CreateWallet',
      ($2.CreateWalletRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.CreateWalletResponse.fromBuffer(value));

  WalletServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$2.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle($2.BroadcastWithdrawalBundleRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$broadcastWithdrawalBundle, request, options: options);
  }

  $grpc.ResponseFuture<$2.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction($2.CreateBmmCriticalDataTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createBmmCriticalDataTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$2.CreateDepositTransactionResponse> createDepositTransaction($2.CreateDepositTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createDepositTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$2.CreateNewAddressResponse> createNewAddress($2.CreateNewAddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createNewAddress, request, options: options);
  }

  $grpc.ResponseStream<$2.CreateSidechainProposalResponse> createSidechainProposal($2.CreateSidechainProposalRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$createSidechainProposal, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$2.GetBalanceResponse> getBalance($2.GetBalanceRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBalance, request, options: options);
  }

  $grpc.ResponseFuture<$2.ListTransactionsResponse> listTransactions($2.ListTransactionsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$2.SendTransactionResponse> sendTransaction($2.SendTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendTransaction, request, options: options);
  }

  $grpc.ResponseStream<$2.GenerateBlocksResponse> generateBlocks($2.GenerateBlocksRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$generateBlocks, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$2.UnlockWalletResponse> unlockWallet($2.UnlockWalletRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$unlockWallet, request, options: options);
  }

  $grpc.ResponseFuture<$2.CreateWalletResponse> createWallet($2.CreateWalletRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createWallet, request, options: options);
  }
}

@$pb.GrpcServiceName('cusf.mainchain.v1.WalletService')
abstract class WalletServiceBase extends $grpc.Service {
  $core.String get $name => 'cusf.mainchain.v1.WalletService';

  WalletServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.BroadcastWithdrawalBundleRequest, $2.BroadcastWithdrawalBundleResponse>(
        'BroadcastWithdrawalBundle',
        broadcastWithdrawalBundle_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.BroadcastWithdrawalBundleRequest.fromBuffer(value),
        ($2.BroadcastWithdrawalBundleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.CreateBmmCriticalDataTransactionRequest, $2.CreateBmmCriticalDataTransactionResponse>(
        'CreateBmmCriticalDataTransaction',
        createBmmCriticalDataTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.CreateBmmCriticalDataTransactionRequest.fromBuffer(value),
        ($2.CreateBmmCriticalDataTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.CreateDepositTransactionRequest, $2.CreateDepositTransactionResponse>(
        'CreateDepositTransaction',
        createDepositTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.CreateDepositTransactionRequest.fromBuffer(value),
        ($2.CreateDepositTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.CreateNewAddressRequest, $2.CreateNewAddressResponse>(
        'CreateNewAddress',
        createNewAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.CreateNewAddressRequest.fromBuffer(value),
        ($2.CreateNewAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.CreateSidechainProposalRequest, $2.CreateSidechainProposalResponse>(
        'CreateSidechainProposal',
        createSidechainProposal_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $2.CreateSidechainProposalRequest.fromBuffer(value),
        ($2.CreateSidechainProposalResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetBalanceRequest, $2.GetBalanceResponse>(
        'GetBalance',
        getBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.GetBalanceRequest.fromBuffer(value),
        ($2.GetBalanceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.ListTransactionsRequest, $2.ListTransactionsResponse>(
        'ListTransactions',
        listTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.ListTransactionsRequest.fromBuffer(value),
        ($2.ListTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.SendTransactionRequest, $2.SendTransactionResponse>(
        'SendTransaction',
        sendTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.SendTransactionRequest.fromBuffer(value),
        ($2.SendTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GenerateBlocksRequest, $2.GenerateBlocksResponse>(
        'GenerateBlocks',
        generateBlocks_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $2.GenerateBlocksRequest.fromBuffer(value),
        ($2.GenerateBlocksResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.UnlockWalletRequest, $2.UnlockWalletResponse>(
        'UnlockWallet',
        unlockWallet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.UnlockWalletRequest.fromBuffer(value),
        ($2.UnlockWalletResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.CreateWalletRequest, $2.CreateWalletResponse>(
        'CreateWallet',
        createWallet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.CreateWalletRequest.fromBuffer(value),
        ($2.CreateWalletResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle_Pre($grpc.ServiceCall call, $async.Future<$2.BroadcastWithdrawalBundleRequest> request) async {
    return broadcastWithdrawalBundle(call, await request);
  }

  $async.Future<$2.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction_Pre($grpc.ServiceCall call, $async.Future<$2.CreateBmmCriticalDataTransactionRequest> request) async {
    return createBmmCriticalDataTransaction(call, await request);
  }

  $async.Future<$2.CreateDepositTransactionResponse> createDepositTransaction_Pre($grpc.ServiceCall call, $async.Future<$2.CreateDepositTransactionRequest> request) async {
    return createDepositTransaction(call, await request);
  }

  $async.Future<$2.CreateNewAddressResponse> createNewAddress_Pre($grpc.ServiceCall call, $async.Future<$2.CreateNewAddressRequest> request) async {
    return createNewAddress(call, await request);
  }

  $async.Stream<$2.CreateSidechainProposalResponse> createSidechainProposal_Pre($grpc.ServiceCall call, $async.Future<$2.CreateSidechainProposalRequest> request) async* {
    yield* createSidechainProposal(call, await request);
  }

  $async.Future<$2.GetBalanceResponse> getBalance_Pre($grpc.ServiceCall call, $async.Future<$2.GetBalanceRequest> request) async {
    return getBalance(call, await request);
  }

  $async.Future<$2.ListTransactionsResponse> listTransactions_Pre($grpc.ServiceCall call, $async.Future<$2.ListTransactionsRequest> request) async {
    return listTransactions(call, await request);
  }

  $async.Future<$2.SendTransactionResponse> sendTransaction_Pre($grpc.ServiceCall call, $async.Future<$2.SendTransactionRequest> request) async {
    return sendTransaction(call, await request);
  }

  $async.Stream<$2.GenerateBlocksResponse> generateBlocks_Pre($grpc.ServiceCall call, $async.Future<$2.GenerateBlocksRequest> request) async* {
    yield* generateBlocks(call, await request);
  }

  $async.Future<$2.UnlockWalletResponse> unlockWallet_Pre($grpc.ServiceCall call, $async.Future<$2.UnlockWalletRequest> request) async {
    return unlockWallet(call, await request);
  }

  $async.Future<$2.CreateWalletResponse> createWallet_Pre($grpc.ServiceCall call, $async.Future<$2.CreateWalletRequest> request) async {
    return createWallet(call, await request);
  }

  $async.Future<$2.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle($grpc.ServiceCall call, $2.BroadcastWithdrawalBundleRequest request);
  $async.Future<$2.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction($grpc.ServiceCall call, $2.CreateBmmCriticalDataTransactionRequest request);
  $async.Future<$2.CreateDepositTransactionResponse> createDepositTransaction($grpc.ServiceCall call, $2.CreateDepositTransactionRequest request);
  $async.Future<$2.CreateNewAddressResponse> createNewAddress($grpc.ServiceCall call, $2.CreateNewAddressRequest request);
  $async.Stream<$2.CreateSidechainProposalResponse> createSidechainProposal($grpc.ServiceCall call, $2.CreateSidechainProposalRequest request);
  $async.Future<$2.GetBalanceResponse> getBalance($grpc.ServiceCall call, $2.GetBalanceRequest request);
  $async.Future<$2.ListTransactionsResponse> listTransactions($grpc.ServiceCall call, $2.ListTransactionsRequest request);
  $async.Future<$2.SendTransactionResponse> sendTransaction($grpc.ServiceCall call, $2.SendTransactionRequest request);
  $async.Stream<$2.GenerateBlocksResponse> generateBlocks($grpc.ServiceCall call, $2.GenerateBlocksRequest request);
  $async.Future<$2.UnlockWalletResponse> unlockWallet($grpc.ServiceCall call, $2.UnlockWalletRequest request);
  $async.Future<$2.CreateWalletResponse> createWallet($grpc.ServiceCall call, $2.CreateWalletRequest request);
}
