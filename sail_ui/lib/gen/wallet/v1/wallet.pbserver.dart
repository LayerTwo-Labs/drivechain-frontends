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
import 'wallet.pb.dart' as $13;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$13.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
      $pb.ServerContext ctx, $13.CreateBitcoinCoreWalletRequest request);
  $async.Future<$13.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $13.SendTransactionRequest request);
  $async.Future<$13.GetBalanceResponse> getBalance($pb.ServerContext ctx, $13.GetBalanceRequest request);
  $async.Future<$13.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $13.GetNewAddressRequest request);
  $async.Future<$13.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $13.ListTransactionsRequest request);
  $async.Future<$13.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $13.ListUnspentRequest request);
  $async.Future<$13.ListReceiveAddressesResponse> listReceiveAddresses(
      $pb.ServerContext ctx, $13.ListReceiveAddressesRequest request);
  $async.Future<$13.ListSidechainDepositsResponse> listSidechainDeposits(
      $pb.ServerContext ctx, $13.ListSidechainDepositsRequest request);
  $async.Future<$13.CreateSidechainDepositResponse> createSidechainDeposit(
      $pb.ServerContext ctx, $13.CreateSidechainDepositRequest request);
  $async.Future<$13.SignMessageResponse> signMessage($pb.ServerContext ctx, $13.SignMessageRequest request);
  $async.Future<$13.VerifyMessageResponse> verifyMessage($pb.ServerContext ctx, $13.VerifyMessageRequest request);
  $async.Future<$13.GetStatsResponse> getStats($pb.ServerContext ctx, $13.GetStatsRequest request);
  $async.Future<$1.Empty> unlockWallet($pb.ServerContext ctx, $13.UnlockWalletRequest request);
  $async.Future<$1.Empty> lockWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> isWalletUnlocked($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$13.CreateChequeResponse> createCheque($pb.ServerContext ctx, $13.CreateChequeRequest request);
  $async.Future<$13.GetChequeResponse> getCheque($pb.ServerContext ctx, $13.GetChequeRequest request);
  $async.Future<$13.GetChequePrivateKeyResponse> getChequePrivateKey(
      $pb.ServerContext ctx, $13.GetChequePrivateKeyRequest request);
  $async.Future<$13.ListChequesResponse> listCheques($pb.ServerContext ctx, $13.ListChequesRequest request);
  $async.Future<$13.CheckChequeFundingResponse> checkChequeFunding(
      $pb.ServerContext ctx, $13.CheckChequeFundingRequest request);
  $async.Future<$13.SweepChequeResponse> sweepCheque($pb.ServerContext ctx, $13.SweepChequeRequest request);
  $async.Future<$1.Empty> deleteCheque($pb.ServerContext ctx, $13.DeleteChequeRequest request);
  $async.Future<$1.Empty> setUTXOMetadata($pb.ServerContext ctx, $13.SetUTXOMetadataRequest request);
  $async.Future<$13.GetUTXOMetadataResponse> getUTXOMetadata($pb.ServerContext ctx, $13.GetUTXOMetadataRequest request);
  $async.Future<$1.Empty> setCoinSelectionStrategy($pb.ServerContext ctx, $13.SetCoinSelectionStrategyRequest request);
  $async.Future<$13.GetCoinSelectionStrategyResponse> getCoinSelectionStrategy($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$13.GetTransactionDetailsResponse> getTransactionDetails(
      $pb.ServerContext ctx, $13.GetTransactionDetailsRequest request);
  $async.Future<$13.GetUTXODistributionResponse> getUTXODistribution(
      $pb.ServerContext ctx, $13.GetUTXODistributionRequest request);
  $async.Future<$13.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $13.BumpFeeRequest request);
  $async.Future<$13.SelectCoinsResponse> selectCoins($pb.ServerContext ctx, $13.SelectCoinsRequest request);
  $async.Future<$13.CreateBackupResponse> createBackup($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> restoreBackup($pb.ServerContext ctx, $13.RestoreBackupRequest request);
  $async.Future<$13.ValidateBackupResponse> validateBackup($pb.ServerContext ctx, $13.ValidateBackupRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet':
        return $13.CreateBitcoinCoreWalletRequest();
      case 'SendTransaction':
        return $13.SendTransactionRequest();
      case 'GetBalance':
        return $13.GetBalanceRequest();
      case 'GetNewAddress':
        return $13.GetNewAddressRequest();
      case 'ListTransactions':
        return $13.ListTransactionsRequest();
      case 'ListUnspent':
        return $13.ListUnspentRequest();
      case 'ListReceiveAddresses':
        return $13.ListReceiveAddressesRequest();
      case 'ListSidechainDeposits':
        return $13.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit':
        return $13.CreateSidechainDepositRequest();
      case 'SignMessage':
        return $13.SignMessageRequest();
      case 'VerifyMessage':
        return $13.VerifyMessageRequest();
      case 'GetStats':
        return $13.GetStatsRequest();
      case 'UnlockWallet':
        return $13.UnlockWalletRequest();
      case 'LockWallet':
        return $1.Empty();
      case 'IsWalletUnlocked':
        return $1.Empty();
      case 'CreateCheque':
        return $13.CreateChequeRequest();
      case 'GetCheque':
        return $13.GetChequeRequest();
      case 'GetChequePrivateKey':
        return $13.GetChequePrivateKeyRequest();
      case 'ListCheques':
        return $13.ListChequesRequest();
      case 'CheckChequeFunding':
        return $13.CheckChequeFundingRequest();
      case 'SweepCheque':
        return $13.SweepChequeRequest();
      case 'DeleteCheque':
        return $13.DeleteChequeRequest();
      case 'SetUTXOMetadata':
        return $13.SetUTXOMetadataRequest();
      case 'GetUTXOMetadata':
        return $13.GetUTXOMetadataRequest();
      case 'SetCoinSelectionStrategy':
        return $13.SetCoinSelectionStrategyRequest();
      case 'GetCoinSelectionStrategy':
        return $1.Empty();
      case 'GetTransactionDetails':
        return $13.GetTransactionDetailsRequest();
      case 'GetUTXODistribution':
        return $13.GetUTXODistributionRequest();
      case 'BumpFee':
        return $13.BumpFeeRequest();
      case 'SelectCoins':
        return $13.SelectCoinsRequest();
      case 'CreateBackup':
        return $1.Empty();
      case 'RestoreBackup':
        return $13.RestoreBackupRequest();
      case 'ValidateBackup':
        return $13.ValidateBackupRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet':
        return this.createBitcoinCoreWallet(ctx, request as $13.CreateBitcoinCoreWalletRequest);
      case 'SendTransaction':
        return this.sendTransaction(ctx, request as $13.SendTransactionRequest);
      case 'GetBalance':
        return this.getBalance(ctx, request as $13.GetBalanceRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $13.GetNewAddressRequest);
      case 'ListTransactions':
        return this.listTransactions(ctx, request as $13.ListTransactionsRequest);
      case 'ListUnspent':
        return this.listUnspent(ctx, request as $13.ListUnspentRequest);
      case 'ListReceiveAddresses':
        return this.listReceiveAddresses(ctx, request as $13.ListReceiveAddressesRequest);
      case 'ListSidechainDeposits':
        return this.listSidechainDeposits(ctx, request as $13.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit':
        return this.createSidechainDeposit(ctx, request as $13.CreateSidechainDepositRequest);
      case 'SignMessage':
        return this.signMessage(ctx, request as $13.SignMessageRequest);
      case 'VerifyMessage':
        return this.verifyMessage(ctx, request as $13.VerifyMessageRequest);
      case 'GetStats':
        return this.getStats(ctx, request as $13.GetStatsRequest);
      case 'UnlockWallet':
        return this.unlockWallet(ctx, request as $13.UnlockWalletRequest);
      case 'LockWallet':
        return this.lockWallet(ctx, request as $1.Empty);
      case 'IsWalletUnlocked':
        return this.isWalletUnlocked(ctx, request as $1.Empty);
      case 'CreateCheque':
        return this.createCheque(ctx, request as $13.CreateChequeRequest);
      case 'GetCheque':
        return this.getCheque(ctx, request as $13.GetChequeRequest);
      case 'GetChequePrivateKey':
        return this.getChequePrivateKey(ctx, request as $13.GetChequePrivateKeyRequest);
      case 'ListCheques':
        return this.listCheques(ctx, request as $13.ListChequesRequest);
      case 'CheckChequeFunding':
        return this.checkChequeFunding(ctx, request as $13.CheckChequeFundingRequest);
      case 'SweepCheque':
        return this.sweepCheque(ctx, request as $13.SweepChequeRequest);
      case 'DeleteCheque':
        return this.deleteCheque(ctx, request as $13.DeleteChequeRequest);
      case 'SetUTXOMetadata':
        return this.setUTXOMetadata(ctx, request as $13.SetUTXOMetadataRequest);
      case 'GetUTXOMetadata':
        return this.getUTXOMetadata(ctx, request as $13.GetUTXOMetadataRequest);
      case 'SetCoinSelectionStrategy':
        return this.setCoinSelectionStrategy(ctx, request as $13.SetCoinSelectionStrategyRequest);
      case 'GetCoinSelectionStrategy':
        return this.getCoinSelectionStrategy(ctx, request as $1.Empty);
      case 'GetTransactionDetails':
        return this.getTransactionDetails(ctx, request as $13.GetTransactionDetailsRequest);
      case 'GetUTXODistribution':
        return this.getUTXODistribution(ctx, request as $13.GetUTXODistributionRequest);
      case 'BumpFee':
        return this.bumpFee(ctx, request as $13.BumpFeeRequest);
      case 'SelectCoins':
        return this.selectCoins(ctx, request as $13.SelectCoinsRequest);
      case 'CreateBackup':
        return this.createBackup(ctx, request as $1.Empty);
      case 'RestoreBackup':
        return this.restoreBackup(ctx, request as $13.RestoreBackupRequest);
      case 'ValidateBackup':
        return this.validateBackup(ctx, request as $13.ValidateBackupRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}
