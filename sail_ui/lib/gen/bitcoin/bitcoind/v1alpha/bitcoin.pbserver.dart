//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
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

import '../../../google/protobuf/empty.pb.dart' as $3;
import 'bitcoin.pb.dart' as $4;
import 'bitcoin.pbjson.dart';

export 'bitcoin.pb.dart';

abstract class BitcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$4.GetBlockchainInfoResponse> getBlockchainInfo(
      $pb.ServerContext ctx, $4.GetBlockchainInfoRequest request);
  $async.Future<$4.GetPeerInfoResponse> getPeerInfo($pb.ServerContext ctx, $4.GetPeerInfoRequest request);
  $async.Future<$4.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $4.GetTransactionRequest request);
  $async.Future<$4.ListSinceBlockResponse> listSinceBlock($pb.ServerContext ctx, $4.ListSinceBlockRequest request);
  $async.Future<$4.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $4.GetNewAddressRequest request);
  $async.Future<$4.GetWalletInfoResponse> getWalletInfo($pb.ServerContext ctx, $4.GetWalletInfoRequest request);
  $async.Future<$4.GetBalancesResponse> getBalances($pb.ServerContext ctx, $4.GetBalancesRequest request);
  $async.Future<$4.SendResponse> send($pb.ServerContext ctx, $4.SendRequest request);
  $async.Future<$4.SendToAddressResponse> sendToAddress($pb.ServerContext ctx, $4.SendToAddressRequest request);
  $async.Future<$4.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $4.BumpFeeRequest request);
  $async.Future<$4.EstimateSmartFeeResponse> estimateSmartFee(
      $pb.ServerContext ctx, $4.EstimateSmartFeeRequest request);
  $async.Future<$4.ImportDescriptorsResponse> importDescriptors(
      $pb.ServerContext ctx, $4.ImportDescriptorsRequest request);
  $async.Future<$4.ListWalletsResponse> listWallets($pb.ServerContext ctx, $3.Empty request);
  $async.Future<$4.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $4.ListUnspentRequest request);
  $async.Future<$4.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $4.ListTransactionsRequest request);
  $async.Future<$4.GetDescriptorInfoResponse> getDescriptorInfo(
      $pb.ServerContext ctx, $4.GetDescriptorInfoRequest request);
  $async.Future<$4.GetAddressInfoResponse> getAddressInfo($pb.ServerContext ctx, $4.GetAddressInfoRequest request);
  $async.Future<$4.GetRawMempoolResponse> getRawMempool($pb.ServerContext ctx, $4.GetRawMempoolRequest request);
  $async.Future<$4.GetRawTransactionResponse> getRawTransaction(
      $pb.ServerContext ctx, $4.GetRawTransactionRequest request);
  $async.Future<$4.DecodeRawTransactionResponse> decodeRawTransaction(
      $pb.ServerContext ctx, $4.DecodeRawTransactionRequest request);
  $async.Future<$4.CreateRawTransactionResponse> createRawTransaction(
      $pb.ServerContext ctx, $4.CreateRawTransactionRequest request);
  $async.Future<$4.GetBlockResponse> getBlock($pb.ServerContext ctx, $4.GetBlockRequest request);
  $async.Future<$4.GetBlockHashResponse> getBlockHash($pb.ServerContext ctx, $4.GetBlockHashRequest request);
  $async.Future<$4.CreateWalletResponse> createWallet($pb.ServerContext ctx, $4.CreateWalletRequest request);
  $async.Future<$4.BackupWalletResponse> backupWallet($pb.ServerContext ctx, $4.BackupWalletRequest request);
  $async.Future<$4.DumpWalletResponse> dumpWallet($pb.ServerContext ctx, $4.DumpWalletRequest request);
  $async.Future<$4.ImportWalletResponse> importWallet($pb.ServerContext ctx, $4.ImportWalletRequest request);
  $async.Future<$4.UnloadWalletResponse> unloadWallet($pb.ServerContext ctx, $4.UnloadWalletRequest request);
  $async.Future<$4.DumpPrivKeyResponse> dumpPrivKey($pb.ServerContext ctx, $4.DumpPrivKeyRequest request);
  $async.Future<$4.ImportPrivKeyResponse> importPrivKey($pb.ServerContext ctx, $4.ImportPrivKeyRequest request);
  $async.Future<$4.ImportAddressResponse> importAddress($pb.ServerContext ctx, $4.ImportAddressRequest request);
  $async.Future<$4.ImportPubKeyResponse> importPubKey($pb.ServerContext ctx, $4.ImportPubKeyRequest request);
  $async.Future<$4.KeyPoolRefillResponse> keyPoolRefill($pb.ServerContext ctx, $4.KeyPoolRefillRequest request);
  $async.Future<$4.GetAccountResponse> getAccount($pb.ServerContext ctx, $4.GetAccountRequest request);
  $async.Future<$4.SetAccountResponse> setAccount($pb.ServerContext ctx, $4.SetAccountRequest request);
  $async.Future<$4.GetAddressesByAccountResponse> getAddressesByAccount(
      $pb.ServerContext ctx, $4.GetAddressesByAccountRequest request);
  $async.Future<$4.ListAccountsResponse> listAccounts($pb.ServerContext ctx, $4.ListAccountsRequest request);
  $async.Future<$4.AddMultisigAddressResponse> addMultisigAddress(
      $pb.ServerContext ctx, $4.AddMultisigAddressRequest request);
  $async.Future<$4.CreateMultisigResponse> createMultisig($pb.ServerContext ctx, $4.CreateMultisigRequest request);
  $async.Future<$4.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $4.CreatePsbtRequest request);
  $async.Future<$4.DecodePsbtResponse> decodePsbt($pb.ServerContext ctx, $4.DecodePsbtRequest request);
  $async.Future<$4.AnalyzePsbtResponse> analyzePsbt($pb.ServerContext ctx, $4.AnalyzePsbtRequest request);
  $async.Future<$4.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $4.CombinePsbtRequest request);
  $async.Future<$4.UtxoUpdatePsbtResponse> utxoUpdatePsbt($pb.ServerContext ctx, $4.UtxoUpdatePsbtRequest request);
  $async.Future<$4.JoinPsbtsResponse> joinPsbts($pb.ServerContext ctx, $4.JoinPsbtsRequest request);
  $async.Future<$4.TestMempoolAcceptResponse> testMempoolAccept(
      $pb.ServerContext ctx, $4.TestMempoolAcceptRequest request);
  $async.Future<$4.GetZmqNotificationsResponse> getZmqNotifications($pb.ServerContext ctx, $3.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockchainInfo':
        return $4.GetBlockchainInfoRequest();
      case 'GetPeerInfo':
        return $4.GetPeerInfoRequest();
      case 'GetTransaction':
        return $4.GetTransactionRequest();
      case 'ListSinceBlock':
        return $4.ListSinceBlockRequest();
      case 'GetNewAddress':
        return $4.GetNewAddressRequest();
      case 'GetWalletInfo':
        return $4.GetWalletInfoRequest();
      case 'GetBalances':
        return $4.GetBalancesRequest();
      case 'Send':
        return $4.SendRequest();
      case 'SendToAddress':
        return $4.SendToAddressRequest();
      case 'BumpFee':
        return $4.BumpFeeRequest();
      case 'EstimateSmartFee':
        return $4.EstimateSmartFeeRequest();
      case 'ImportDescriptors':
        return $4.ImportDescriptorsRequest();
      case 'ListWallets':
        return $3.Empty();
      case 'ListUnspent':
        return $4.ListUnspentRequest();
      case 'ListTransactions':
        return $4.ListTransactionsRequest();
      case 'GetDescriptorInfo':
        return $4.GetDescriptorInfoRequest();
      case 'GetAddressInfo':
        return $4.GetAddressInfoRequest();
      case 'GetRawMempool':
        return $4.GetRawMempoolRequest();
      case 'GetRawTransaction':
        return $4.GetRawTransactionRequest();
      case 'DecodeRawTransaction':
        return $4.DecodeRawTransactionRequest();
      case 'CreateRawTransaction':
        return $4.CreateRawTransactionRequest();
      case 'GetBlock':
        return $4.GetBlockRequest();
      case 'GetBlockHash':
        return $4.GetBlockHashRequest();
      case 'CreateWallet':
        return $4.CreateWalletRequest();
      case 'BackupWallet':
        return $4.BackupWalletRequest();
      case 'DumpWallet':
        return $4.DumpWalletRequest();
      case 'ImportWallet':
        return $4.ImportWalletRequest();
      case 'UnloadWallet':
        return $4.UnloadWalletRequest();
      case 'DumpPrivKey':
        return $4.DumpPrivKeyRequest();
      case 'ImportPrivKey':
        return $4.ImportPrivKeyRequest();
      case 'ImportAddress':
        return $4.ImportAddressRequest();
      case 'ImportPubKey':
        return $4.ImportPubKeyRequest();
      case 'KeyPoolRefill':
        return $4.KeyPoolRefillRequest();
      case 'GetAccount':
        return $4.GetAccountRequest();
      case 'SetAccount':
        return $4.SetAccountRequest();
      case 'GetAddressesByAccount':
        return $4.GetAddressesByAccountRequest();
      case 'ListAccounts':
        return $4.ListAccountsRequest();
      case 'AddMultisigAddress':
        return $4.AddMultisigAddressRequest();
      case 'CreateMultisig':
        return $4.CreateMultisigRequest();
      case 'CreatePsbt':
        return $4.CreatePsbtRequest();
      case 'DecodePsbt':
        return $4.DecodePsbtRequest();
      case 'AnalyzePsbt':
        return $4.AnalyzePsbtRequest();
      case 'CombinePsbt':
        return $4.CombinePsbtRequest();
      case 'UtxoUpdatePsbt':
        return $4.UtxoUpdatePsbtRequest();
      case 'JoinPsbts':
        return $4.JoinPsbtsRequest();
      case 'TestMempoolAccept':
        return $4.TestMempoolAcceptRequest();
      case 'GetZmqNotifications':
        return $3.Empty();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockchainInfo':
        return this.getBlockchainInfo(ctx, request as $4.GetBlockchainInfoRequest);
      case 'GetPeerInfo':
        return this.getPeerInfo(ctx, request as $4.GetPeerInfoRequest);
      case 'GetTransaction':
        return this.getTransaction(ctx, request as $4.GetTransactionRequest);
      case 'ListSinceBlock':
        return this.listSinceBlock(ctx, request as $4.ListSinceBlockRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $4.GetNewAddressRequest);
      case 'GetWalletInfo':
        return this.getWalletInfo(ctx, request as $4.GetWalletInfoRequest);
      case 'GetBalances':
        return this.getBalances(ctx, request as $4.GetBalancesRequest);
      case 'Send':
        return this.send(ctx, request as $4.SendRequest);
      case 'SendToAddress':
        return this.sendToAddress(ctx, request as $4.SendToAddressRequest);
      case 'BumpFee':
        return this.bumpFee(ctx, request as $4.BumpFeeRequest);
      case 'EstimateSmartFee':
        return this.estimateSmartFee(ctx, request as $4.EstimateSmartFeeRequest);
      case 'ImportDescriptors':
        return this.importDescriptors(ctx, request as $4.ImportDescriptorsRequest);
      case 'ListWallets':
        return this.listWallets(ctx, request as $3.Empty);
      case 'ListUnspent':
        return this.listUnspent(ctx, request as $4.ListUnspentRequest);
      case 'ListTransactions':
        return this.listTransactions(ctx, request as $4.ListTransactionsRequest);
      case 'GetDescriptorInfo':
        return this.getDescriptorInfo(ctx, request as $4.GetDescriptorInfoRequest);
      case 'GetAddressInfo':
        return this.getAddressInfo(ctx, request as $4.GetAddressInfoRequest);
      case 'GetRawMempool':
        return this.getRawMempool(ctx, request as $4.GetRawMempoolRequest);
      case 'GetRawTransaction':
        return this.getRawTransaction(ctx, request as $4.GetRawTransactionRequest);
      case 'DecodeRawTransaction':
        return this.decodeRawTransaction(ctx, request as $4.DecodeRawTransactionRequest);
      case 'CreateRawTransaction':
        return this.createRawTransaction(ctx, request as $4.CreateRawTransactionRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $4.GetBlockRequest);
      case 'GetBlockHash':
        return this.getBlockHash(ctx, request as $4.GetBlockHashRequest);
      case 'CreateWallet':
        return this.createWallet(ctx, request as $4.CreateWalletRequest);
      case 'BackupWallet':
        return this.backupWallet(ctx, request as $4.BackupWalletRequest);
      case 'DumpWallet':
        return this.dumpWallet(ctx, request as $4.DumpWalletRequest);
      case 'ImportWallet':
        return this.importWallet(ctx, request as $4.ImportWalletRequest);
      case 'UnloadWallet':
        return this.unloadWallet(ctx, request as $4.UnloadWalletRequest);
      case 'DumpPrivKey':
        return this.dumpPrivKey(ctx, request as $4.DumpPrivKeyRequest);
      case 'ImportPrivKey':
        return this.importPrivKey(ctx, request as $4.ImportPrivKeyRequest);
      case 'ImportAddress':
        return this.importAddress(ctx, request as $4.ImportAddressRequest);
      case 'ImportPubKey':
        return this.importPubKey(ctx, request as $4.ImportPubKeyRequest);
      case 'KeyPoolRefill':
        return this.keyPoolRefill(ctx, request as $4.KeyPoolRefillRequest);
      case 'GetAccount':
        return this.getAccount(ctx, request as $4.GetAccountRequest);
      case 'SetAccount':
        return this.setAccount(ctx, request as $4.SetAccountRequest);
      case 'GetAddressesByAccount':
        return this.getAddressesByAccount(ctx, request as $4.GetAddressesByAccountRequest);
      case 'ListAccounts':
        return this.listAccounts(ctx, request as $4.ListAccountsRequest);
      case 'AddMultisigAddress':
        return this.addMultisigAddress(ctx, request as $4.AddMultisigAddressRequest);
      case 'CreateMultisig':
        return this.createMultisig(ctx, request as $4.CreateMultisigRequest);
      case 'CreatePsbt':
        return this.createPsbt(ctx, request as $4.CreatePsbtRequest);
      case 'DecodePsbt':
        return this.decodePsbt(ctx, request as $4.DecodePsbtRequest);
      case 'AnalyzePsbt':
        return this.analyzePsbt(ctx, request as $4.AnalyzePsbtRequest);
      case 'CombinePsbt':
        return this.combinePsbt(ctx, request as $4.CombinePsbtRequest);
      case 'UtxoUpdatePsbt':
        return this.utxoUpdatePsbt(ctx, request as $4.UtxoUpdatePsbtRequest);
      case 'JoinPsbts':
        return this.joinPsbts(ctx, request as $4.JoinPsbtsRequest);
      case 'TestMempoolAccept':
        return this.testMempoolAccept(ctx, request as $4.TestMempoolAcceptRequest);
      case 'GetZmqNotifications':
        return this.getZmqNotifications(ctx, request as $3.Empty);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoinServiceBase$messageJson;
}
