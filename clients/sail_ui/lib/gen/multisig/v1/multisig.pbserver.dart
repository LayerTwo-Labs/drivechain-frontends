//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
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

import 'multisig.pb.dart' as $0;
import 'multisig.pbjson.dart';

export 'multisig.pb.dart';

abstract class MultisigServiceBase extends $pb.GeneratedService {
  $async.Future<$0.AddMultisigAddressResponse> addMultisigAddress($pb.ServerContext ctx, $0.AddMultisigAddressRequest request);
  $async.Future<$0.ImportAddressResponse> importAddress($pb.ServerContext ctx, $0.ImportAddressRequest request);
  $async.Future<$0.GetAddressInfoResponse> getAddressInfo($pb.ServerContext ctx, $0.GetAddressInfoRequest request);
  $async.Future<$0.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $0.ListUnspentRequest request);
  $async.Future<$0.ListAddressGroupingsResponse> listAddressGroupings($pb.ServerContext ctx, $0.ListAddressGroupingsRequest request);
  $async.Future<$0.CreateRawTransactionResponse> createRawTransaction($pb.ServerContext ctx, $0.CreateRawTransactionRequest request);
  $async.Future<$0.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $0.CreatePsbtRequest request);
  $async.Future<$0.WalletCreateFundedPsbtResponse> walletCreateFundedPsbt($pb.ServerContext ctx, $0.WalletCreateFundedPsbtRequest request);
  $async.Future<$0.DecodePsbtResponse> decodePsbt($pb.ServerContext ctx, $0.DecodePsbtRequest request);
  $async.Future<$0.AnalyzePsbtResponse> analyzePsbt($pb.ServerContext ctx, $0.AnalyzePsbtRequest request);
  $async.Future<$0.WalletProcessPsbtResponse> walletProcessPsbt($pb.ServerContext ctx, $0.WalletProcessPsbtRequest request);
  $async.Future<$0.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $0.CombinePsbtRequest request);
  $async.Future<$0.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $0.FinalizePsbtRequest request);
  $async.Future<$0.UtxoUpdatePsbtResponse> utxoUpdatePsbt($pb.ServerContext ctx, $0.UtxoUpdatePsbtRequest request);
  $async.Future<$0.JoinPsbtsResponse> joinPsbts($pb.ServerContext ctx, $0.JoinPsbtsRequest request);
  $async.Future<$0.SignRawTransactionWithWalletResponse> signRawTransactionWithWallet($pb.ServerContext ctx, $0.SignRawTransactionWithWalletRequest request);
  $async.Future<$0.SendRawTransactionResponse> sendRawTransaction($pb.ServerContext ctx, $0.SendRawTransactionRequest request);
  $async.Future<$0.TestMempoolAcceptResponse> testMempoolAccept($pb.ServerContext ctx, $0.TestMempoolAcceptRequest request);
  $async.Future<$0.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $0.GetTransactionRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'AddMultisigAddress': return $0.AddMultisigAddressRequest();
      case 'ImportAddress': return $0.ImportAddressRequest();
      case 'GetAddressInfo': return $0.GetAddressInfoRequest();
      case 'ListUnspent': return $0.ListUnspentRequest();
      case 'ListAddressGroupings': return $0.ListAddressGroupingsRequest();
      case 'CreateRawTransaction': return $0.CreateRawTransactionRequest();
      case 'CreatePsbt': return $0.CreatePsbtRequest();
      case 'WalletCreateFundedPsbt': return $0.WalletCreateFundedPsbtRequest();
      case 'DecodePsbt': return $0.DecodePsbtRequest();
      case 'AnalyzePsbt': return $0.AnalyzePsbtRequest();
      case 'WalletProcessPsbt': return $0.WalletProcessPsbtRequest();
      case 'CombinePsbt': return $0.CombinePsbtRequest();
      case 'FinalizePsbt': return $0.FinalizePsbtRequest();
      case 'UtxoUpdatePsbt': return $0.UtxoUpdatePsbtRequest();
      case 'JoinPsbts': return $0.JoinPsbtsRequest();
      case 'SignRawTransactionWithWallet': return $0.SignRawTransactionWithWalletRequest();
      case 'SendRawTransaction': return $0.SendRawTransactionRequest();
      case 'TestMempoolAccept': return $0.TestMempoolAcceptRequest();
      case 'GetTransaction': return $0.GetTransactionRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'AddMultisigAddress': return this.addMultisigAddress(ctx, request as $0.AddMultisigAddressRequest);
      case 'ImportAddress': return this.importAddress(ctx, request as $0.ImportAddressRequest);
      case 'GetAddressInfo': return this.getAddressInfo(ctx, request as $0.GetAddressInfoRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $0.ListUnspentRequest);
      case 'ListAddressGroupings': return this.listAddressGroupings(ctx, request as $0.ListAddressGroupingsRequest);
      case 'CreateRawTransaction': return this.createRawTransaction(ctx, request as $0.CreateRawTransactionRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $0.CreatePsbtRequest);
      case 'WalletCreateFundedPsbt': return this.walletCreateFundedPsbt(ctx, request as $0.WalletCreateFundedPsbtRequest);
      case 'DecodePsbt': return this.decodePsbt(ctx, request as $0.DecodePsbtRequest);
      case 'AnalyzePsbt': return this.analyzePsbt(ctx, request as $0.AnalyzePsbtRequest);
      case 'WalletProcessPsbt': return this.walletProcessPsbt(ctx, request as $0.WalletProcessPsbtRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $0.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $0.FinalizePsbtRequest);
      case 'UtxoUpdatePsbt': return this.utxoUpdatePsbt(ctx, request as $0.UtxoUpdatePsbtRequest);
      case 'JoinPsbts': return this.joinPsbts(ctx, request as $0.JoinPsbtsRequest);
      case 'SignRawTransactionWithWallet': return this.signRawTransactionWithWallet(ctx, request as $0.SignRawTransactionWithWalletRequest);
      case 'SendRawTransaction': return this.sendRawTransaction(ctx, request as $0.SendRawTransactionRequest);
      case 'TestMempoolAccept': return this.testMempoolAccept(ctx, request as $0.TestMempoolAcceptRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $0.GetTransactionRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MultisigServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MultisigServiceBase$messageJson;
}

