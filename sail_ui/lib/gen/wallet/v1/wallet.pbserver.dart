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
import 'wallet.pb.dart' as $8;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$8.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $8.CreateBitcoinCoreWalletRequest request);
  $async.Future<$8.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $8.SendTransactionRequest request);
  $async.Future<$8.GetBalanceResponse> getBalance($pb.ServerContext ctx, $8.GetBalanceRequest request);
  $async.Future<$8.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $8.GetNewAddressRequest request);
  $async.Future<$8.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $8.ListTransactionsRequest request);
  $async.Future<$8.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $8.ListUnspentRequest request);
  $async.Future<$8.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $8.ListReceiveAddressesRequest request);
  $async.Future<$8.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $8.ListSidechainDepositsRequest request);
  $async.Future<$8.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $8.CreateSidechainDepositRequest request);
  $async.Future<$8.SignMessageResponse> signMessage($pb.ServerContext ctx, $8.SignMessageRequest request);
  $async.Future<$8.VerifyMessageResponse> verifyMessage($pb.ServerContext ctx, $8.VerifyMessageRequest request);
  $async.Future<$8.GetStatsResponse> getStats($pb.ServerContext ctx, $8.GetStatsRequest request);
  $async.Future<$1.Empty> unlockWallet($pb.ServerContext ctx, $8.UnlockWalletRequest request);
  $async.Future<$1.Empty> lockWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> isWalletUnlocked($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$8.CreateChequeResponse> createCheque($pb.ServerContext ctx, $8.CreateChequeRequest request);
  $async.Future<$8.GetChequeResponse> getCheque($pb.ServerContext ctx, $8.GetChequeRequest request);
  $async.Future<$8.GetChequePrivateKeyResponse> getChequePrivateKey($pb.ServerContext ctx, $8.GetChequePrivateKeyRequest request);
  $async.Future<$8.ListChequesResponse> listCheques($pb.ServerContext ctx, $8.ListChequesRequest request);
  $async.Future<$8.CheckChequeFundingResponse> checkChequeFunding($pb.ServerContext ctx, $8.CheckChequeFundingRequest request);
  $async.Future<$8.SweepChequeResponse> sweepCheque($pb.ServerContext ctx, $8.SweepChequeRequest request);
  $async.Future<$1.Empty> deleteCheque($pb.ServerContext ctx, $8.DeleteChequeRequest request);
  $async.Future<$1.Empty> setUTXOMetadata($pb.ServerContext ctx, $8.SetUTXOMetadataRequest request);
  $async.Future<$8.GetUTXOMetadataResponse> getUTXOMetadata($pb.ServerContext ctx, $8.GetUTXOMetadataRequest request);
  $async.Future<$1.Empty> setCoinSelectionStrategy($pb.ServerContext ctx, $8.SetCoinSelectionStrategyRequest request);
  $async.Future<$8.GetCoinSelectionStrategyResponse> getCoinSelectionStrategy($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return $8.CreateBitcoinCoreWalletRequest();
      case 'SendTransaction': return $8.SendTransactionRequest();
      case 'GetBalance': return $8.GetBalanceRequest();
      case 'GetNewAddress': return $8.GetNewAddressRequest();
      case 'ListTransactions': return $8.ListTransactionsRequest();
      case 'ListUnspent': return $8.ListUnspentRequest();
      case 'ListReceiveAddresses': return $8.ListReceiveAddressesRequest();
      case 'ListSidechainDeposits': return $8.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit': return $8.CreateSidechainDepositRequest();
      case 'SignMessage': return $8.SignMessageRequest();
      case 'VerifyMessage': return $8.VerifyMessageRequest();
      case 'GetStats': return $8.GetStatsRequest();
      case 'UnlockWallet': return $8.UnlockWalletRequest();
      case 'LockWallet': return $1.Empty();
      case 'IsWalletUnlocked': return $1.Empty();
      case 'CreateCheque': return $8.CreateChequeRequest();
      case 'GetCheque': return $8.GetChequeRequest();
      case 'GetChequePrivateKey': return $8.GetChequePrivateKeyRequest();
      case 'ListCheques': return $8.ListChequesRequest();
      case 'CheckChequeFunding': return $8.CheckChequeFundingRequest();
      case 'SweepCheque': return $8.SweepChequeRequest();
      case 'DeleteCheque': return $8.DeleteChequeRequest();
      case 'SetUTXOMetadata': return $8.SetUTXOMetadataRequest();
      case 'GetUTXOMetadata': return $8.GetUTXOMetadataRequest();
      case 'SetCoinSelectionStrategy': return $8.SetCoinSelectionStrategyRequest();
      case 'GetCoinSelectionStrategy': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $8.CreateBitcoinCoreWalletRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $8.SendTransactionRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $8.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $8.GetNewAddressRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $8.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $8.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $8.ListReceiveAddressesRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $8.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $8.CreateSidechainDepositRequest);
      case 'SignMessage': return this.signMessage(ctx, request as $8.SignMessageRequest);
      case 'VerifyMessage': return this.verifyMessage(ctx, request as $8.VerifyMessageRequest);
      case 'GetStats': return this.getStats(ctx, request as $8.GetStatsRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $8.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $1.Empty);
      case 'IsWalletUnlocked': return this.isWalletUnlocked(ctx, request as $1.Empty);
      case 'CreateCheque': return this.createCheque(ctx, request as $8.CreateChequeRequest);
      case 'GetCheque': return this.getCheque(ctx, request as $8.GetChequeRequest);
      case 'GetChequePrivateKey': return this.getChequePrivateKey(ctx, request as $8.GetChequePrivateKeyRequest);
      case 'ListCheques': return this.listCheques(ctx, request as $8.ListChequesRequest);
      case 'CheckChequeFunding': return this.checkChequeFunding(ctx, request as $8.CheckChequeFundingRequest);
      case 'SweepCheque': return this.sweepCheque(ctx, request as $8.SweepChequeRequest);
      case 'DeleteCheque': return this.deleteCheque(ctx, request as $8.DeleteChequeRequest);
      case 'SetUTXOMetadata': return this.setUTXOMetadata(ctx, request as $8.SetUTXOMetadataRequest);
      case 'GetUTXOMetadata': return this.getUTXOMetadata(ctx, request as $8.GetUTXOMetadataRequest);
      case 'SetCoinSelectionStrategy': return this.setCoinSelectionStrategy(ctx, request as $8.SetCoinSelectionStrategyRequest);
      case 'GetCoinSelectionStrategy': return this.getCoinSelectionStrategy(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

