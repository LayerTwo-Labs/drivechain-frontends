//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
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

import '../../google/protobuf/empty.pb.dart' as $1;
import 'wallet.pb.dart' as $12;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$12.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $12.CreateBitcoinCoreWalletRequest request);
  $async.Future<$12.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $12.SendTransactionRequest request);
  $async.Future<$12.GetBalanceResponse> getBalance($pb.ServerContext ctx, $12.GetBalanceRequest request);
  $async.Future<$12.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $12.GetNewAddressRequest request);
  $async.Future<$12.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $12.ListTransactionsRequest request);
  $async.Future<$12.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $12.ListUnspentRequest request);
  $async.Future<$12.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $12.ListReceiveAddressesRequest request);
  $async.Future<$12.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $12.ListSidechainDepositsRequest request);
  $async.Future<$12.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $12.CreateSidechainDepositRequest request);
  $async.Future<$12.SignMessageResponse> signMessage($pb.ServerContext ctx, $12.SignMessageRequest request);
  $async.Future<$12.VerifyMessageResponse> verifyMessage($pb.ServerContext ctx, $12.VerifyMessageRequest request);
  $async.Future<$12.GetStatsResponse> getStats($pb.ServerContext ctx, $12.GetStatsRequest request);
  $async.Future<$1.Empty> unlockWallet($pb.ServerContext ctx, $12.UnlockWalletRequest request);
  $async.Future<$1.Empty> lockWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> isWalletUnlocked($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$12.CreateChequeResponse> createCheque($pb.ServerContext ctx, $12.CreateChequeRequest request);
  $async.Future<$12.GetChequeResponse> getCheque($pb.ServerContext ctx, $12.GetChequeRequest request);
  $async.Future<$12.GetChequePrivateKeyResponse> getChequePrivateKey($pb.ServerContext ctx, $12.GetChequePrivateKeyRequest request);
  $async.Future<$12.ListChequesResponse> listCheques($pb.ServerContext ctx, $12.ListChequesRequest request);
  $async.Future<$12.CheckChequeFundingResponse> checkChequeFunding($pb.ServerContext ctx, $12.CheckChequeFundingRequest request);
  $async.Future<$12.SweepChequeResponse> sweepCheque($pb.ServerContext ctx, $12.SweepChequeRequest request);
  $async.Future<$1.Empty> deleteCheque($pb.ServerContext ctx, $12.DeleteChequeRequest request);
  $async.Future<$1.Empty> setUTXOMetadata($pb.ServerContext ctx, $12.SetUTXOMetadataRequest request);
  $async.Future<$12.GetUTXOMetadataResponse> getUTXOMetadata($pb.ServerContext ctx, $12.GetUTXOMetadataRequest request);
  $async.Future<$1.Empty> setCoinSelectionStrategy($pb.ServerContext ctx, $12.SetCoinSelectionStrategyRequest request);
  $async.Future<$12.GetCoinSelectionStrategyResponse> getCoinSelectionStrategy($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$12.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $12.GetTransactionDetailsRequest request);
  $async.Future<$12.GetUTXODistributionResponse> getUTXODistribution($pb.ServerContext ctx, $12.GetUTXODistributionRequest request);
  $async.Future<$12.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $12.BumpFeeRequest request);
  $async.Future<$12.SelectCoinsResponse> selectCoins($pb.ServerContext ctx, $12.SelectCoinsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return $12.CreateBitcoinCoreWalletRequest();
      case 'SendTransaction': return $12.SendTransactionRequest();
      case 'GetBalance': return $12.GetBalanceRequest();
      case 'GetNewAddress': return $12.GetNewAddressRequest();
      case 'ListTransactions': return $12.ListTransactionsRequest();
      case 'ListUnspent': return $12.ListUnspentRequest();
      case 'ListReceiveAddresses': return $12.ListReceiveAddressesRequest();
      case 'ListSidechainDeposits': return $12.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit': return $12.CreateSidechainDepositRequest();
      case 'SignMessage': return $12.SignMessageRequest();
      case 'VerifyMessage': return $12.VerifyMessageRequest();
      case 'GetStats': return $12.GetStatsRequest();
      case 'UnlockWallet': return $12.UnlockWalletRequest();
      case 'LockWallet': return $1.Empty();
      case 'IsWalletUnlocked': return $1.Empty();
      case 'CreateCheque': return $12.CreateChequeRequest();
      case 'GetCheque': return $12.GetChequeRequest();
      case 'GetChequePrivateKey': return $12.GetChequePrivateKeyRequest();
      case 'ListCheques': return $12.ListChequesRequest();
      case 'CheckChequeFunding': return $12.CheckChequeFundingRequest();
      case 'SweepCheque': return $12.SweepChequeRequest();
      case 'DeleteCheque': return $12.DeleteChequeRequest();
      case 'SetUTXOMetadata': return $12.SetUTXOMetadataRequest();
      case 'GetUTXOMetadata': return $12.GetUTXOMetadataRequest();
      case 'SetCoinSelectionStrategy': return $12.SetCoinSelectionStrategyRequest();
      case 'GetCoinSelectionStrategy': return $1.Empty();
      case 'GetTransactionDetails': return $12.GetTransactionDetailsRequest();
      case 'GetUTXODistribution': return $12.GetUTXODistributionRequest();
      case 'BumpFee': return $12.BumpFeeRequest();
      case 'SelectCoins': return $12.SelectCoinsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $12.CreateBitcoinCoreWalletRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $12.SendTransactionRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $12.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $12.GetNewAddressRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $12.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $12.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $12.ListReceiveAddressesRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $12.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $12.CreateSidechainDepositRequest);
      case 'SignMessage': return this.signMessage(ctx, request as $12.SignMessageRequest);
      case 'VerifyMessage': return this.verifyMessage(ctx, request as $12.VerifyMessageRequest);
      case 'GetStats': return this.getStats(ctx, request as $12.GetStatsRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $12.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $1.Empty);
      case 'IsWalletUnlocked': return this.isWalletUnlocked(ctx, request as $1.Empty);
      case 'CreateCheque': return this.createCheque(ctx, request as $12.CreateChequeRequest);
      case 'GetCheque': return this.getCheque(ctx, request as $12.GetChequeRequest);
      case 'GetChequePrivateKey': return this.getChequePrivateKey(ctx, request as $12.GetChequePrivateKeyRequest);
      case 'ListCheques': return this.listCheques(ctx, request as $12.ListChequesRequest);
      case 'CheckChequeFunding': return this.checkChequeFunding(ctx, request as $12.CheckChequeFundingRequest);
      case 'SweepCheque': return this.sweepCheque(ctx, request as $12.SweepChequeRequest);
      case 'DeleteCheque': return this.deleteCheque(ctx, request as $12.DeleteChequeRequest);
      case 'SetUTXOMetadata': return this.setUTXOMetadata(ctx, request as $12.SetUTXOMetadataRequest);
      case 'GetUTXOMetadata': return this.getUTXOMetadata(ctx, request as $12.GetUTXOMetadataRequest);
      case 'SetCoinSelectionStrategy': return this.setCoinSelectionStrategy(ctx, request as $12.SetCoinSelectionStrategyRequest);
      case 'GetCoinSelectionStrategy': return this.getCoinSelectionStrategy(ctx, request as $1.Empty);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $12.GetTransactionDetailsRequest);
      case 'GetUTXODistribution': return this.getUTXODistribution(ctx, request as $12.GetUTXODistributionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $12.BumpFeeRequest);
      case 'SelectCoins': return this.selectCoins(ctx, request as $12.SelectCoinsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

