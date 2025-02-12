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
  $async.Future<$6.GetBalanceResponse> getBalance($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$6.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$6.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$6.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $6.ListSidechainDepositsRequest request);
  $async.Future<$6.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $6.CreateSidechainDepositRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SendTransaction': return $6.SendTransactionRequest();
      case 'GetBalance': return $1.Empty();
      case 'GetNewAddress': return $1.Empty();
      case 'ListTransactions': return $1.Empty();
      case 'ListSidechainDeposits': return $6.ListSidechainDepositsRequest();
      case 'CreateSidechainDeposit': return $6.CreateSidechainDepositRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SendTransaction': return this.sendTransaction(ctx, request as $6.SendTransactionRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $1.Empty);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $1.Empty);
      case 'ListTransactions': return this.listTransactions(ctx, request as $1.Empty);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $6.ListSidechainDepositsRequest);
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $6.CreateSidechainDepositRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletServiceBase$messageJson;
}

