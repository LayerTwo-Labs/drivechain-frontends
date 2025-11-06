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
import 'wallet.pb.dart' as $6;
import 'wallet.pbjson.dart';

export 'wallet.pb.dart';

abstract class WalletServiceBase extends $pb.GeneratedService {
  $async.Future<$6.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $6.SendTransactionRequest request);
  $async.Future<$6.GetBalanceResponse> getBalance($pb.ServerContext ctx, $6.GetBalanceRequest request);
  $async.Future<$6.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $6.GetNewAddressRequest request);
  $async.Future<$6.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $6.ListTransactionsRequest request);
  $async.Future<$6.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $6.ListUnspentRequest request);
  $async.Future<$6.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $6.ListReceiveAddressesRequest request);
  $async.Future<$6.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $6.ListSidechainDepositsRequest request);
  $async.Future<$6.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $6.CreateSidechainDepositRequest request);
  $async.Future<$6.SignMessageResponse> signMessage($pb.ServerContext ctx, $6.SignMessageRequest request);
  $async.Future<$6.VerifyMessageResponse> verifyMessage($pb.ServerContext ctx, $6.VerifyMessageRequest request);
  $async.Future<$6.GetStatsResponse> getStats($pb.ServerContext ctx, $6.GetStatsRequest request);
  $async.Future<$1.Empty> unlockWallet($pb.ServerContext ctx, $6.UnlockWalletRequest request);
  $async.Future<$1.Empty> lockWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> isWalletUnlocked($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$6.CreateChequeResponse> createCheque($pb.ServerContext ctx, $6.CreateChequeRequest request);
  $async.Future<$6.GetChequeResponse> getCheque($pb.ServerContext ctx, $6.GetChequeRequest request);
  $async.Future<$6.GetChequePrivateKeyResponse> getChequePrivateKey($pb.ServerContext ctx, $6.GetChequePrivateKeyRequest request);
  $async.Future<$6.ListChequesResponse> listCheques($pb.ServerContext ctx, $6.ListChequesRequest request);
  $async.Future<$6.CheckChequeFundingResponse> checkChequeFunding($pb.ServerContext ctx, $6.CheckChequeFundingRequest request);
  $async.Future<$6.SweepChequeResponse> sweepCheque($pb.ServerContext ctx, $6.SweepChequeRequest request);
  $async.Future<$1.Empty> deleteCheque($pb.ServerContext ctx, $6.DeleteChequeRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SendTransaction': return $6.SendTransactionRequest();
      case 'GetBalance': return $6.GetBalanceRequest();
      case 'GetNewAddress': return $6.GetNewAddressRequest();
      case 'ListTransactions': return $6.ListTransactionsRequest();
      case 'ListUnspent': return $6.ListUnspentRequest();
      case 'ListReceiveAddresses': return $6.ListReceiveAddressesRequest();
      case 'ListSidechainDeposits': return $6.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit': return $6.CreateSidechainDepositRequest();
      case 'SignMessage': return $6.SignMessageRequest();
      case 'VerifyMessage': return $6.VerifyMessageRequest();
      case 'GetStats': return $6.GetStatsRequest();
      case 'UnlockWallet': return $6.UnlockWalletRequest();
      case 'LockWallet': return $1.Empty();
      case 'IsWalletUnlocked': return $1.Empty();
      case 'CreateCheque': return $6.CreateChequeRequest();
      case 'GetCheque': return $6.GetChequeRequest();
      case 'GetChequePrivateKey': return $6.GetChequePrivateKeyRequest();
      case 'ListCheques': return $6.ListChequesRequest();
      case 'CheckChequeFunding': return $6.CheckChequeFundingRequest();
      case 'SweepCheque': return $6.SweepChequeRequest();
      case 'DeleteCheque': return $6.DeleteChequeRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SendTransaction': return this.sendTransaction(ctx, request as $6.SendTransactionRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $6.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $6.GetNewAddressRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $6.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $6.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $6.ListReceiveAddressesRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $6.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $6.CreateSidechainDepositRequest);
      case 'SignMessage': return this.signMessage(ctx, request as $6.SignMessageRequest);
      case 'VerifyMessage': return this.verifyMessage(ctx, request as $6.VerifyMessageRequest);
      case 'GetStats': return this.getStats(ctx, request as $6.GetStatsRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $6.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $1.Empty);
      case 'IsWalletUnlocked': return this.isWalletUnlocked(ctx, request as $1.Empty);
      case 'CreateCheque': return this.createCheque(ctx, request as $6.CreateChequeRequest);
      case 'GetCheque': return this.getCheque(ctx, request as $6.GetChequeRequest);
      case 'GetChequePrivateKey': return this.getChequePrivateKey(ctx, request as $6.GetChequePrivateKeyRequest);
      case 'ListCheques': return this.listCheques(ctx, request as $6.ListChequesRequest);
      case 'CheckChequeFunding': return this.checkChequeFunding(ctx, request as $6.CheckChequeFundingRequest);
      case 'SweepCheque': return this.sweepCheque(ctx, request as $6.SweepChequeRequest);
      case 'DeleteCheque': return this.deleteCheque(ctx, request as $6.DeleteChequeRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

