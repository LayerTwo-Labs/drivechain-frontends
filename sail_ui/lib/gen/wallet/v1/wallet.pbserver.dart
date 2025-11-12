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
import 'wallet.pb.dart' as $7;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$7.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $7.CreateBitcoinCoreWalletRequest request);
  $async.Future<$7.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $7.SendTransactionRequest request);
  $async.Future<$7.GetBalanceResponse> getBalance($pb.ServerContext ctx, $7.GetBalanceRequest request);
  $async.Future<$7.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $7.GetNewAddressRequest request);
  $async.Future<$7.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $7.ListTransactionsRequest request);
  $async.Future<$7.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $7.ListUnspentRequest request);
  $async.Future<$7.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $7.ListReceiveAddressesRequest request);
  $async.Future<$7.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $7.ListSidechainDepositsRequest request);
  $async.Future<$7.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $7.CreateSidechainDepositRequest request);
  $async.Future<$7.SignMessageResponse> signMessage($pb.ServerContext ctx, $7.SignMessageRequest request);
  $async.Future<$7.VerifyMessageResponse> verifyMessage($pb.ServerContext ctx, $7.VerifyMessageRequest request);
  $async.Future<$7.GetStatsResponse> getStats($pb.ServerContext ctx, $7.GetStatsRequest request);
  $async.Future<$1.Empty> unlockWallet($pb.ServerContext ctx, $7.UnlockWalletRequest request);
  $async.Future<$1.Empty> lockWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> isWalletUnlocked($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$7.CreateChequeResponse> createCheque($pb.ServerContext ctx, $7.CreateChequeRequest request);
  $async.Future<$7.GetChequeResponse> getCheque($pb.ServerContext ctx, $7.GetChequeRequest request);
  $async.Future<$7.GetChequePrivateKeyResponse> getChequePrivateKey($pb.ServerContext ctx, $7.GetChequePrivateKeyRequest request);
  $async.Future<$7.ListChequesResponse> listCheques($pb.ServerContext ctx, $7.ListChequesRequest request);
  $async.Future<$7.CheckChequeFundingResponse> checkChequeFunding($pb.ServerContext ctx, $7.CheckChequeFundingRequest request);
  $async.Future<$7.SweepChequeResponse> sweepCheque($pb.ServerContext ctx, $7.SweepChequeRequest request);
  $async.Future<$1.Empty> deleteCheque($pb.ServerContext ctx, $7.DeleteChequeRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return $7.CreateBitcoinCoreWalletRequest();
      case 'SendTransaction': return $7.SendTransactionRequest();
      case 'GetBalance': return $7.GetBalanceRequest();
      case 'GetNewAddress': return $7.GetNewAddressRequest();
      case 'ListTransactions': return $7.ListTransactionsRequest();
      case 'ListUnspent': return $7.ListUnspentRequest();
      case 'ListReceiveAddresses': return $7.ListReceiveAddressesRequest();
      case 'ListSidechainDeposits': return $7.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit': return $7.CreateSidechainDepositRequest();
      case 'SignMessage': return $7.SignMessageRequest();
      case 'VerifyMessage': return $7.VerifyMessageRequest();
      case 'GetStats': return $7.GetStatsRequest();
      case 'UnlockWallet': return $7.UnlockWalletRequest();
      case 'LockWallet': return $1.Empty();
      case 'IsWalletUnlocked': return $1.Empty();
      case 'CreateCheque': return $7.CreateChequeRequest();
      case 'GetCheque': return $7.GetChequeRequest();
      case 'GetChequePrivateKey': return $7.GetChequePrivateKeyRequest();
      case 'ListCheques': return $7.ListChequesRequest();
      case 'CheckChequeFunding': return $7.CheckChequeFundingRequest();
      case 'SweepCheque': return $7.SweepChequeRequest();
      case 'DeleteCheque': return $7.DeleteChequeRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $7.CreateBitcoinCoreWalletRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $7.SendTransactionRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $7.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $7.GetNewAddressRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $7.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $7.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $7.ListReceiveAddressesRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $7.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $7.CreateSidechainDepositRequest);
      case 'SignMessage': return this.signMessage(ctx, request as $7.SignMessageRequest);
      case 'VerifyMessage': return this.verifyMessage(ctx, request as $7.VerifyMessageRequest);
      case 'GetStats': return this.getStats(ctx, request as $7.GetStatsRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $7.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $1.Empty);
      case 'IsWalletUnlocked': return this.isWalletUnlocked(ctx, request as $1.Empty);
      case 'CreateCheque': return this.createCheque(ctx, request as $7.CreateChequeRequest);
      case 'GetCheque': return this.getCheque(ctx, request as $7.GetChequeRequest);
      case 'GetChequePrivateKey': return this.getChequePrivateKey(ctx, request as $7.GetChequePrivateKeyRequest);
      case 'ListCheques': return this.listCheques(ctx, request as $7.ListChequesRequest);
      case 'CheckChequeFunding': return this.checkChequeFunding(ctx, request as $7.CheckChequeFundingRequest);
      case 'SweepCheque': return this.sweepCheque(ctx, request as $7.SweepChequeRequest);
      case 'DeleteCheque': return this.deleteCheque(ctx, request as $7.DeleteChequeRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

