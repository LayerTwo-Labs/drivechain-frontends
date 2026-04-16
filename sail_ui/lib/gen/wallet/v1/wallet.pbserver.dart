// This is a generated file - do not edit.
//
// Generated from wallet/v1/wallet.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $2;

import 'wallet.pb.dart' as $3;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$3.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
      $pb.ServerContext ctx, $3.CreateBitcoinCoreWalletRequest request);
  $async.Future<$3.SendTransactionResponse> sendTransaction(
      $pb.ServerContext ctx, $3.SendTransactionRequest request);
  $async.Future<$3.GetBalanceResponse> getBalance(
      $pb.ServerContext ctx, $3.GetBalanceRequest request);
  $async.Future<$3.GetNewAddressResponse> getNewAddress(
      $pb.ServerContext ctx, $3.GetNewAddressRequest request);
  $async.Future<$3.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $3.ListTransactionsRequest request);
  $async.Future<$3.ListUnspentResponse> listUnspent(
      $pb.ServerContext ctx, $3.ListUnspentRequest request);
  $async.Future<$3.ListReceiveAddressesResponse> listReceiveAddresses(
      $pb.ServerContext ctx, $3.ListReceiveAddressesRequest request);
  $async.Future<$3.ListSidechainDepositsResponse> listSidechainDeposits(
      $pb.ServerContext ctx, $3.ListSidechainDepositsRequest request);
  $async.Future<$3.CreateSidechainDepositResponse> createSidechainDeposit(
      $pb.ServerContext ctx, $3.CreateSidechainDepositRequest request);
  $async.Future<$3.SignMessageResponse> signMessage(
      $pb.ServerContext ctx, $3.SignMessageRequest request);
  $async.Future<$3.VerifyMessageResponse> verifyMessage(
      $pb.ServerContext ctx, $3.VerifyMessageRequest request);
  $async.Future<$3.GetStatsResponse> getStats(
      $pb.ServerContext ctx, $3.GetStatsRequest request);
  $async.Future<$2.Empty> unlockWallet(
      $pb.ServerContext ctx, $3.UnlockWalletRequest request);
  $async.Future<$2.Empty> lockWallet($pb.ServerContext ctx, $2.Empty request);
  $async.Future<$2.Empty> isWalletUnlocked(
      $pb.ServerContext ctx, $2.Empty request);
  $async.Future<$3.CreateChequeResponse> createCheque(
      $pb.ServerContext ctx, $3.CreateChequeRequest request);
  $async.Future<$3.GetChequeResponse> getCheque(
      $pb.ServerContext ctx, $3.GetChequeRequest request);
  $async.Future<$3.GetChequePrivateKeyResponse> getChequePrivateKey(
      $pb.ServerContext ctx, $3.GetChequePrivateKeyRequest request);
  $async.Future<$3.ListChequesResponse> listCheques(
      $pb.ServerContext ctx, $3.ListChequesRequest request);
  $async.Future<$3.CheckChequeFundingResponse> checkChequeFunding(
      $pb.ServerContext ctx, $3.CheckChequeFundingRequest request);
  $async.Future<$3.SweepChequeResponse> sweepCheque(
      $pb.ServerContext ctx, $3.SweepChequeRequest request);
  $async.Future<$2.Empty> deleteCheque(
      $pb.ServerContext ctx, $3.DeleteChequeRequest request);
  $async.Future<$2.Empty> setUTXOMetadata(
      $pb.ServerContext ctx, $3.SetUTXOMetadataRequest request);
  $async.Future<$3.GetUTXOMetadataResponse> getUTXOMetadata(
      $pb.ServerContext ctx, $3.GetUTXOMetadataRequest request);
  $async.Future<$2.Empty> setCoinSelectionStrategy(
      $pb.ServerContext ctx, $3.SetCoinSelectionStrategyRequest request);
  $async.Future<$3.GetCoinSelectionStrategyResponse> getCoinSelectionStrategy(
      $pb.ServerContext ctx, $2.Empty request);
  $async.Future<$3.GetTransactionDetailsResponse> getTransactionDetails(
      $pb.ServerContext ctx, $3.GetTransactionDetailsRequest request);
  $async.Future<$3.GetUTXODistributionResponse> getUTXODistribution(
      $pb.ServerContext ctx, $3.GetUTXODistributionRequest request);
  $async.Future<$3.BumpFeeResponse> bumpFee(
      $pb.ServerContext ctx, $3.BumpFeeRequest request);
  $async.Future<$3.SelectCoinsResponse> selectCoins(
      $pb.ServerContext ctx, $3.SelectCoinsRequest request);
  $async.Future<$3.CreateBackupResponse> createBackup(
      $pb.ServerContext ctx, $2.Empty request);
  $async.Future<$2.Empty> restoreBackup(
      $pb.ServerContext ctx, $3.RestoreBackupRequest request);
  $async.Future<$3.ValidateBackupResponse> validateBackup(
      $pb.ServerContext ctx, $3.ValidateBackupRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet':
        return $3.CreateBitcoinCoreWalletRequest();
      case 'SendTransaction':
        return $3.SendTransactionRequest();
      case 'GetBalance':
        return $3.GetBalanceRequest();
      case 'GetNewAddress':
        return $3.GetNewAddressRequest();
      case 'ListTransactions':
        return $3.ListTransactionsRequest();
      case 'ListUnspent':
        return $3.ListUnspentRequest();
      case 'ListReceiveAddresses':
        return $3.ListReceiveAddressesRequest();
      case 'ListSidechainDeposits':
        return $3.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit':
        return $3.CreateSidechainDepositRequest();
      case 'SignMessage':
        return $3.SignMessageRequest();
      case 'VerifyMessage':
        return $3.VerifyMessageRequest();
      case 'GetStats':
        return $3.GetStatsRequest();
      case 'UnlockWallet':
        return $3.UnlockWalletRequest();
      case 'LockWallet':
        return $2.Empty();
      case 'IsWalletUnlocked':
        return $2.Empty();
      case 'CreateCheque':
        return $3.CreateChequeRequest();
      case 'GetCheque':
        return $3.GetChequeRequest();
      case 'GetChequePrivateKey':
        return $3.GetChequePrivateKeyRequest();
      case 'ListCheques':
        return $3.ListChequesRequest();
      case 'CheckChequeFunding':
        return $3.CheckChequeFundingRequest();
      case 'SweepCheque':
        return $3.SweepChequeRequest();
      case 'DeleteCheque':
        return $3.DeleteChequeRequest();
      case 'SetUTXOMetadata':
        return $3.SetUTXOMetadataRequest();
      case 'GetUTXOMetadata':
        return $3.GetUTXOMetadataRequest();
      case 'SetCoinSelectionStrategy':
        return $3.SetCoinSelectionStrategyRequest();
      case 'GetCoinSelectionStrategy':
        return $2.Empty();
      case 'GetTransactionDetails':
        return $3.GetTransactionDetailsRequest();
      case 'GetUTXODistribution':
        return $3.GetUTXODistributionRequest();
      case 'BumpFee':
        return $3.BumpFeeRequest();
      case 'SelectCoins':
        return $3.SelectCoinsRequest();
      case 'CreateBackup':
        return $2.Empty();
      case 'RestoreBackup':
        return $3.RestoreBackupRequest();
      case 'ValidateBackup':
        return $3.ValidateBackupRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet':
        return createBitcoinCoreWallet(
            ctx, request as $3.CreateBitcoinCoreWalletRequest);
      case 'SendTransaction':
        return sendTransaction(ctx, request as $3.SendTransactionRequest);
      case 'GetBalance':
        return getBalance(ctx, request as $3.GetBalanceRequest);
      case 'GetNewAddress':
        return getNewAddress(ctx, request as $3.GetNewAddressRequest);
      case 'ListTransactions':
        return listTransactions(ctx, request as $3.ListTransactionsRequest);
      case 'ListUnspent':
        return listUnspent(ctx, request as $3.ListUnspentRequest);
      case 'ListReceiveAddresses':
        return listReceiveAddresses(
            ctx, request as $3.ListReceiveAddressesRequest);
      case 'ListSidechainDeposits':
        return listSidechainDeposits(
            ctx, request as $3.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit':
        return createSidechainDeposit(
            ctx, request as $3.CreateSidechainDepositRequest);
      case 'SignMessage':
        return signMessage(ctx, request as $3.SignMessageRequest);
      case 'VerifyMessage':
        return verifyMessage(ctx, request as $3.VerifyMessageRequest);
      case 'GetStats':
        return getStats(ctx, request as $3.GetStatsRequest);
      case 'UnlockWallet':
        return unlockWallet(ctx, request as $3.UnlockWalletRequest);
      case 'LockWallet':
        return lockWallet(ctx, request as $2.Empty);
      case 'IsWalletUnlocked':
        return isWalletUnlocked(ctx, request as $2.Empty);
      case 'CreateCheque':
        return createCheque(ctx, request as $3.CreateChequeRequest);
      case 'GetCheque':
        return getCheque(ctx, request as $3.GetChequeRequest);
      case 'GetChequePrivateKey':
        return getChequePrivateKey(
            ctx, request as $3.GetChequePrivateKeyRequest);
      case 'ListCheques':
        return listCheques(ctx, request as $3.ListChequesRequest);
      case 'CheckChequeFunding':
        return checkChequeFunding(ctx, request as $3.CheckChequeFundingRequest);
      case 'SweepCheque':
        return sweepCheque(ctx, request as $3.SweepChequeRequest);
      case 'DeleteCheque':
        return deleteCheque(ctx, request as $3.DeleteChequeRequest);
      case 'SetUTXOMetadata':
        return setUTXOMetadata(ctx, request as $3.SetUTXOMetadataRequest);
      case 'GetUTXOMetadata':
        return getUTXOMetadata(ctx, request as $3.GetUTXOMetadataRequest);
      case 'SetCoinSelectionStrategy':
        return setCoinSelectionStrategy(
            ctx, request as $3.SetCoinSelectionStrategyRequest);
      case 'GetCoinSelectionStrategy':
        return getCoinSelectionStrategy(ctx, request as $2.Empty);
      case 'GetTransactionDetails':
        return getTransactionDetails(
            ctx, request as $3.GetTransactionDetailsRequest);
      case 'GetUTXODistribution':
        return getUTXODistribution(
            ctx, request as $3.GetUTXODistributionRequest);
      case 'BumpFee':
        return bumpFee(ctx, request as $3.BumpFeeRequest);
      case 'SelectCoins':
        return selectCoins(ctx, request as $3.SelectCoinsRequest);
      case 'CreateBackup':
        return createBackup(ctx, request as $2.Empty);
      case 'RestoreBackup':
        return restoreBackup(ctx, request as $3.RestoreBackupRequest);
      case 'ValidateBackup':
        return validateBackup(ctx, request as $3.ValidateBackupRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => WalletServiceBase$messageJson;
}
