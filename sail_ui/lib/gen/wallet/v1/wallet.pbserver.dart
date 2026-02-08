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
import 'wallet.pb.dart' as $10;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$10.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $10.CreateBitcoinCoreWalletRequest request);
  $async.Future<$10.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $10.SendTransactionRequest request);
  $async.Future<$10.GetBalanceResponse> getBalance($pb.ServerContext ctx, $10.GetBalanceRequest request);
  $async.Future<$10.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $10.GetNewAddressRequest request);
  $async.Future<$10.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $10.ListTransactionsRequest request);
  $async.Future<$10.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $10.ListUnspentRequest request);
  $async.Future<$10.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $10.ListReceiveAddressesRequest request);
  $async.Future<$10.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $10.ListSidechainDepositsRequest request);
  $async.Future<$10.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $10.CreateSidechainDepositRequest request);
  $async.Future<$10.SignMessageResponse> signMessage($pb.ServerContext ctx, $10.SignMessageRequest request);
  $async.Future<$10.VerifyMessageResponse> verifyMessage($pb.ServerContext ctx, $10.VerifyMessageRequest request);
  $async.Future<$10.GetStatsResponse> getStats($pb.ServerContext ctx, $10.GetStatsRequest request);
  $async.Future<$1.Empty> unlockWallet($pb.ServerContext ctx, $10.UnlockWalletRequest request);
  $async.Future<$1.Empty> lockWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> isWalletUnlocked($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$10.CreateChequeResponse> createCheque($pb.ServerContext ctx, $10.CreateChequeRequest request);
  $async.Future<$10.GetChequeResponse> getCheque($pb.ServerContext ctx, $10.GetChequeRequest request);
  $async.Future<$10.GetChequePrivateKeyResponse> getChequePrivateKey($pb.ServerContext ctx, $10.GetChequePrivateKeyRequest request);
  $async.Future<$10.ListChequesResponse> listCheques($pb.ServerContext ctx, $10.ListChequesRequest request);
  $async.Future<$10.CheckChequeFundingResponse> checkChequeFunding($pb.ServerContext ctx, $10.CheckChequeFundingRequest request);
  $async.Future<$10.SweepChequeResponse> sweepCheque($pb.ServerContext ctx, $10.SweepChequeRequest request);
  $async.Future<$1.Empty> deleteCheque($pb.ServerContext ctx, $10.DeleteChequeRequest request);
  $async.Future<$1.Empty> setUTXOMetadata($pb.ServerContext ctx, $10.SetUTXOMetadataRequest request);
  $async.Future<$10.GetUTXOMetadataResponse> getUTXOMetadata($pb.ServerContext ctx, $10.GetUTXOMetadataRequest request);
  $async.Future<$1.Empty> setCoinSelectionStrategy($pb.ServerContext ctx, $10.SetCoinSelectionStrategyRequest request);
  $async.Future<$10.GetCoinSelectionStrategyResponse> getCoinSelectionStrategy($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$10.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $10.GetTransactionDetailsRequest request);
  $async.Future<$10.GetUTXODistributionResponse> getUTXODistribution($pb.ServerContext ctx, $10.GetUTXODistributionRequest request);
  $async.Future<$10.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $10.BumpFeeRequest request);
  $async.Future<$10.SelectCoinsResponse> selectCoins($pb.ServerContext ctx, $10.SelectCoinsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return $10.CreateBitcoinCoreWalletRequest();
      case 'SendTransaction': return $10.SendTransactionRequest();
      case 'GetBalance': return $10.GetBalanceRequest();
      case 'GetNewAddress': return $10.GetNewAddressRequest();
      case 'ListTransactions': return $10.ListTransactionsRequest();
      case 'ListUnspent': return $10.ListUnspentRequest();
      case 'ListReceiveAddresses': return $10.ListReceiveAddressesRequest();
      case 'ListSidechainDeposits': return $10.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit': return $10.CreateSidechainDepositRequest();
      case 'SignMessage': return $10.SignMessageRequest();
      case 'VerifyMessage': return $10.VerifyMessageRequest();
      case 'GetStats': return $10.GetStatsRequest();
      case 'UnlockWallet': return $10.UnlockWalletRequest();
      case 'LockWallet': return $1.Empty();
      case 'IsWalletUnlocked': return $1.Empty();
      case 'CreateCheque': return $10.CreateChequeRequest();
      case 'GetCheque': return $10.GetChequeRequest();
      case 'GetChequePrivateKey': return $10.GetChequePrivateKeyRequest();
      case 'ListCheques': return $10.ListChequesRequest();
      case 'CheckChequeFunding': return $10.CheckChequeFundingRequest();
      case 'SweepCheque': return $10.SweepChequeRequest();
      case 'DeleteCheque': return $10.DeleteChequeRequest();
      case 'SetUTXOMetadata': return $10.SetUTXOMetadataRequest();
      case 'GetUTXOMetadata': return $10.GetUTXOMetadataRequest();
      case 'SetCoinSelectionStrategy': return $10.SetCoinSelectionStrategyRequest();
      case 'GetCoinSelectionStrategy': return $1.Empty();
      case 'GetTransactionDetails': return $10.GetTransactionDetailsRequest();
      case 'GetUTXODistribution': return $10.GetUTXODistributionRequest();
      case 'BumpFee': return $10.BumpFeeRequest();
      case 'SelectCoins': return $10.SelectCoinsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $10.CreateBitcoinCoreWalletRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $10.SendTransactionRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $10.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $10.GetNewAddressRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $10.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $10.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $10.ListReceiveAddressesRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $10.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $10.CreateSidechainDepositRequest);
      case 'SignMessage': return this.signMessage(ctx, request as $10.SignMessageRequest);
      case 'VerifyMessage': return this.verifyMessage(ctx, request as $10.VerifyMessageRequest);
      case 'GetStats': return this.getStats(ctx, request as $10.GetStatsRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $10.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $1.Empty);
      case 'IsWalletUnlocked': return this.isWalletUnlocked(ctx, request as $1.Empty);
      case 'CreateCheque': return this.createCheque(ctx, request as $10.CreateChequeRequest);
      case 'GetCheque': return this.getCheque(ctx, request as $10.GetChequeRequest);
      case 'GetChequePrivateKey': return this.getChequePrivateKey(ctx, request as $10.GetChequePrivateKeyRequest);
      case 'ListCheques': return this.listCheques(ctx, request as $10.ListChequesRequest);
      case 'CheckChequeFunding': return this.checkChequeFunding(ctx, request as $10.CheckChequeFundingRequest);
      case 'SweepCheque': return this.sweepCheque(ctx, request as $10.SweepChequeRequest);
      case 'DeleteCheque': return this.deleteCheque(ctx, request as $10.DeleteChequeRequest);
      case 'SetUTXOMetadata': return this.setUTXOMetadata(ctx, request as $10.SetUTXOMetadataRequest);
      case 'GetUTXOMetadata': return this.getUTXOMetadata(ctx, request as $10.GetUTXOMetadataRequest);
      case 'SetCoinSelectionStrategy': return this.setCoinSelectionStrategy(ctx, request as $10.SetCoinSelectionStrategyRequest);
      case 'GetCoinSelectionStrategy': return this.getCoinSelectionStrategy(ctx, request as $1.Empty);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $10.GetTransactionDetailsRequest);
      case 'GetUTXODistribution': return this.getUTXODistribution(ctx, request as $10.GetUTXODistributionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $10.BumpFeeRequest);
      case 'SelectCoins': return this.selectCoins(ctx, request as $10.SelectCoinsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

