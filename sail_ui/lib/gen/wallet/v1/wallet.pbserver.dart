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
  $async.Future<$7.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $7.SendTransactionRequest request);
  $async.Future<$7.GetBalanceResponse> getBalance($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$7.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$7.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$7.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$7.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$7.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $7.ListSidechainDepositsRequest request);
  $async.Future<$7.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $7.CreateSidechainDepositRequest request);
  $async.Future<$7.SignMessageResponse> signMessage($pb.ServerContext ctx, $7.SignMessageRequest request);
  $async.Future<$7.VerifyMessageResponse> verifyMessage($pb.ServerContext ctx, $7.VerifyMessageRequest request);
  $async.Future<$7.GetStatsResponse> getStats($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SendTransaction': return $7.SendTransactionRequest();
      case 'GetBalance': return $1.Empty();
      case 'GetNewAddress': return $1.Empty();
      case 'ListTransactions': return $1.Empty();
      case 'ListUnspent': return $1.Empty();
      case 'ListReceiveAddresses': return $1.Empty();
      case 'ListSidechainDeposits': return $7.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit': return $7.CreateSidechainDepositRequest();
      case 'SignMessage': return $7.SignMessageRequest();
      case 'VerifyMessage': return $7.VerifyMessageRequest();
      case 'GetStats': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SendTransaction': return this.sendTransaction(ctx, request as $7.SendTransactionRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $1.Empty);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $1.Empty);
      case 'ListTransactions': return this.listTransactions(ctx, request as $1.Empty);
      case 'ListUnspent': return this.listUnspent(ctx, request as $1.Empty);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $1.Empty);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $7.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $7.CreateSidechainDepositRequest);
      case 'SignMessage': return this.signMessage(ctx, request as $7.SignMessageRequest);
      case 'VerifyMessage': return this.verifyMessage(ctx, request as $7.VerifyMessageRequest);
      case 'GetStats': return this.getStats(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

