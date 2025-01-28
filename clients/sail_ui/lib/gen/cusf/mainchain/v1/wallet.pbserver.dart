//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/wallet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'wallet.pb.dart' as $6;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$6.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle($pb.ServerContext ctx, $6.BroadcastWithdrawalBundleRequest request);
  $async.Future<$6.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction($pb.ServerContext ctx, $6.CreateBmmCriticalDataTransactionRequest request);
  $async.Future<$6.CreateDepositTransactionResponse> createDepositTransaction($pb.ServerContext ctx, $6.CreateDepositTransactionRequest request);
  $async.Future<$6.CreateNewAddressResponse> createNewAddress($pb.ServerContext ctx, $6.CreateNewAddressRequest request);
  $async.Future<$6.CreateSidechainProposalResponse> createSidechainProposal($pb.ServerContext ctx, $6.CreateSidechainProposalRequest request);
  $async.Future<$6.CreateWalletResponse> createWallet($pb.ServerContext ctx, $6.CreateWalletRequest request);
  $async.Future<$6.GetBalanceResponse> getBalance($pb.ServerContext ctx, $6.GetBalanceRequest request);
  $async.Future<$6.ListSidechainDepositTransactionsResponse> listSidechainDepositTransactions($pb.ServerContext ctx, $6.ListSidechainDepositTransactionsRequest request);
  $async.Future<$6.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $6.ListTransactionsRequest request);
  $async.Future<$6.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $6.SendTransactionRequest request);
  $async.Future<$6.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $6.UnlockWalletRequest request);
  $async.Future<$6.GenerateBlocksResponse> generateBlocks($pb.ServerContext ctx, $6.GenerateBlocksRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'BroadcastWithdrawalBundle': return $6.BroadcastWithdrawalBundleRequest();
      case 'CreateBmmCriticalDataTransaction': return $6.CreateBmmCriticalDataTransactionRequest();
      case 'CreateDepositTransaction': return $6.CreateDepositTransactionRequest();
      case 'CreateNewAddress': return $6.CreateNewAddressRequest();
      case 'CreateSidechainProposal': return $6.CreateSidechainProposalRequest();
      case 'CreateWallet': return $6.CreateWalletRequest();
      case 'GetBalance': return $6.GetBalanceRequest();
      case 'ListSidechainDepositTransactions': return $6.ListSidechainDepositTransactionsRequest();
      case 'ListTransactions': return $6.ListTransactionsRequest();
      case 'SendTransaction': return $6.SendTransactionRequest();
      case 'UnlockWallet': return $6.UnlockWalletRequest();
      case 'GenerateBlocks': return $6.GenerateBlocksRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'BroadcastWithdrawalBundle': return this.broadcastWithdrawalBundle(ctx, request as $6.BroadcastWithdrawalBundleRequest);
      case 'CreateBmmCriticalDataTransaction': return this.createBmmCriticalDataTransaction(ctx, request as $6.CreateBmmCriticalDataTransactionRequest);
      case 'CreateDepositTransaction': return this.createDepositTransaction(ctx, request as $6.CreateDepositTransactionRequest);
      case 'CreateNewAddress': return this.createNewAddress(ctx, request as $6.CreateNewAddressRequest);
      case 'CreateSidechainProposal': return this.createSidechainProposal(ctx, request as $6.CreateSidechainProposalRequest);
      case 'CreateWallet': return this.createWallet(ctx, request as $6.CreateWalletRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $6.GetBalanceRequest);
      case 'ListSidechainDepositTransactions': return this.listSidechainDepositTransactions(ctx, request as $6.ListSidechainDepositTransactionsRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $6.ListTransactionsRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $6.SendTransactionRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $6.UnlockWalletRequest);
      case 'GenerateBlocks': return this.generateBlocks(ctx, request as $6.GenerateBlocksRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

